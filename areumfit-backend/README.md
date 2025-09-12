# AreumFit Backend API

Personal Health+CrossFit training logger & coach backend server for Hanoa.

## Features

- 🔐 JWT Authentication with bcrypt password hashing
- 🏋️ Exercise management and recommendations
- 📊 Session and set tracking
- 🤖 AI-powered coaching proposals
- 🔄 Real-time synchronization with mobile app
- 📝 Complete change history and snapshots

## Quick Start

### Prerequisites

- Node.js 18+ 
- MongoDB 6+
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration

# Set up MongoDB collections and indexes
node mongodb_setup.js

# Start development server
npm run dev
```

### Environment Variables

```bash
MONGO_URI=mongodb://localhost:27017
MONGO_DB=areumfit
JWT_SECRET=your-super-secret-jwt-key-change-this
JWT_AUD=areumfit-app
JWT_ISS=areumfit-api
PORT=8080
NODE_ENV=development
```

## API Endpoints

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login (returns JWT token)

### Protected Endpoints (require JWT token)
- `GET /sync?since=ISO` - Incremental data synchronization
- `POST /ai/ingest` - Apply AI coaching proposals
- `POST /snapshot` - Manual data snapshot
- `GET /health` - Health check

## Database Collections

- `af_users` - User accounts and authentication
- `af_exercises` - Exercise definitions and configurations
- `af_rules` - Global and exercise-specific rules
- `af_sessions` - Workout sessions
- `af_sets` - Individual exercise sets
- `af_wod_templates` - CrossFit WOD templates
- `af_changelog` - Complete change history

## AI Coaching System

The AI system supports the following proposal types:

- `UPSERT_EXERCISE` - Create/update exercise definitions
- `UPSERT_WOD` - Create/update WOD templates
- `UPSERT_RULE` - Create/update training rules
- `PATCH_NOTES` - Update exercise notes
- `PATCH_CUES` - Update form cues
- `PATCH_WARMUP` - Update warmup protocols

Auto-approval is enabled for rule updates, notes, cues, and warmup patches with confidence ≥ 85%.

## Development

```bash
# Start development server with auto-reload
npm run dev

# Run tests
npm test

# Start production server
npm start
```

## Security Features

- Helmet.js for security headers
- Rate limiting (100 requests per 15 minutes per IP)
- CORS protection
- JWT token validation
- Password hashing with bcrypt
- Input validation with Joi

## Architecture

- **Express.js** - Web framework
- **MongoDB** - Primary database
- **JWT** - Authentication tokens
- **bcrypt** - Password hashing
- **Joi** - Input validation
- **ES Modules** - Modern JavaScript syntax