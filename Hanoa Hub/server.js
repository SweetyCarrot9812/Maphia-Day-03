const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const morgan = require('morgan');
require('dotenv').config();

const logger = require('./lib/logger');
const firebaseService = require('./lib/firebase_service');
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const serviceRoutes = require('./routes/services');

const app = express();
const PORT = process.env.PORT || 4000;

// 보안 미들웨어
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
}));

// CORS 설정
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'];
app.use(cors({
  origin: allowedOrigins,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15분
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: {
    error: 'TOO_MANY_REQUESTS',
    message: '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.'
  }
});
app.use(limiter);

// 기본 미들웨어
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// 로깅 미들웨어
app.use(morgan('combined', {
  stream: {
    write: (message) => logger.info(message.trim())
  }
}));

// Firebase 초기화
try {
  firebaseService.initialize();
  logger.info('🔥 Firebase Admin SDK 초기화 완료');
} catch (error) {
  logger.error('❌ Firebase 초기화 실패:', error.message);
  process.exit(1);
}

// 헬스 체크
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'hanoa-hub',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// API 라우트
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/services', serviceRoutes);

// 404 핸들러
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'NOT_FOUND',
    message: '요청한 엔드포인트를 찾을 수 없습니다.'
  });
});

// 전역 에러 핸들러
app.use((error, req, res, next) => {
  logger.error('전역 오류:', error);
  
  res.status(error.status || 500).json({
    success: false,
    error: error.code || 'INTERNAL_SERVER_ERROR',
    message: process.env.NODE_ENV === 'production' 
      ? '서버 오류가 발생했습니다.' 
      : error.message
  });
});

// 서버 시작
app.listen(PORT, () => {
  logger.info(`🚀 Hanoa Hub 서버가 포트 ${PORT}에서 실행 중입니다.`);
  logger.info(`🌐 환경: ${process.env.NODE_ENV || 'development'}`);
  logger.info(`📍 헬스체크: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  logger.info('🛑 서버 종료 신호 수신...');
  process.exit(0);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('처리되지 않은 Promise 거부:', reason);
});

module.exports = app;