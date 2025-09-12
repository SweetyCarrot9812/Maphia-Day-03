import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';

import { connectToDatabase, closeDatabaseConnection } from './models/mongodb.js';
import { register, login, authMiddleware } from './auth/auth.js';
import { syncDelta, saveSnapshot } from './routes/sync.js';
import { ingestProposals } from './routes/ai.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 8080;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true,
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});
app.use(limiter);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    ok: true, 
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// Authentication routes
app.post('/auth/register', register);
app.post('/auth/login', login);

// Protected routes
app.use(authMiddleware);

// API routes
app.get('/sync', syncDelta);
app.post('/snapshot', saveSnapshot);
app.post('/ai/ingest', ingestProposals);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Start server
async function startServer() {
  try {
    await connectToDatabase();
    
    app.listen(PORT, () => {
      console.log(`AreumFit API Server running on port ${PORT}`);
      console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Received SIGINT. Gracefully shutting down...');
  await closeDatabaseConnection();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('Received SIGTERM. Gracefully shutting down...');
  await closeDatabaseConnection();
  process.exit(0);
});

startServer();