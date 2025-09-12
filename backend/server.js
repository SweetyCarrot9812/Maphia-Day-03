require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { connectDB, checkDBStatus } = require('./config/database');

// Express 앱 생성
const app = express();
const PORT = process.env.PORT || 3000;

// 데이터베이스 연결
connectDB();

// 미들웨어 설정
app.use(helmet({
  contentSecurityPolicy: false // 개발 환경에서는 CSP 비활성화
}));

// CORS 설정
const corsOptions = {
  origin: function (origin, callback) {
    // 개발 환경에서는 모든 localhost 허용
    if (!origin || 
        origin.includes('localhost') || 
        origin.includes('127.0.0.1') ||
        origin.includes('10.0.2.2') || // Android 에뮬레이터
        process.env.NODE_ENV === 'development') {
      callback(null, true);
    } else if (process.env.CORS_ORIGIN && origin === process.env.CORS_ORIGIN) {
      callback(null, true);
    } else {
      callback(new Error('CORS 정책에 의해 차단되었습니다'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15분
  max: process.env.NODE_ENV === 'production' ? 100 : 1000, // 개발환경에서는 더 관대하게
  message: {
    success: false,
    message: '너무 많은 요청이 감지되었습니다. 잠시 후 다시 시도해주세요.'
  },
  standardHeaders: true,
  legacyHeaders: false
});

app.use(limiter);

// Body parsing 미들웨어
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 요청 로깅 (개발 환경에서만)
if (process.env.NODE_ENV === 'development') {
  app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
    next();
  });
}

// 기존 라우트 설정 (HaneulTone)
app.use('/api/auth', require('./routes/auth'));
app.use('/api/user', require('./routes/user'));
app.use('/api/sessions', require('./routes/sessions'));

// Clintest 학습 루프 v1 라우트 설정
app.use('/api/concepts', require('./routes/concepts'));
app.use('/api/problems', require('./routes/problems'));
app.use('/api/learning', require('./routes/learning'));
app.use('/api/obsidian', require('./routes/obsidian'));
app.use('/api/pipeline', require('./routes/pipeline'));

// 루트 경로
app.get('/', (req, res) => {
  const dbStatus = checkDBStatus();
  res.json({
    message: 'Hanoa Backend API 서버가 실행 중입니다',
    version: '2.0.0',
    timestamp: new Date().toISOString(),
    database: checkDBStatus(),
    platforms: ['HaneulTone', 'Clintest Learning Loop v1'],
    endpoints: {
      // HaneulTone (기존)
      auth: '/api/auth (POST /register, POST /login, PUT /change-password, GET /verify)',
      user: '/api/user (GET /profile, PUT /profile, GET /stats, DELETE /account)',
      sessions: '/api/sessions (POST /, GET /, GET /:id, DELETE /:id, GET /stats/summary)',
      
      // Clintest Learning Loop v1 (신규)
      concepts: '/api/concepts (GET /sync, POST /sync, GET /:id, DELETE /:id, GET /)',
      problems: '/api/problems (POST /generate, POST /duplicate-check, GET /, GET /:id, PUT /:id, DELETE /:id)',
      learning: '/api/learning (GET /next-session, POST /submit-attempt, POST /trigger-regen, GET /stats)',
      obsidian: '/api/obsidian (POST /setup-vault, GET /status, POST /manual-scan, DELETE /stop-watching, GET /vault-info)',
      pipeline: '/api/pipeline (GET /status, POST /run, GET /jobs, GET /jobs/:id, DELETE /jobs/:id, POST /test-generation)'
    }
  });
});

// 헬스 체크 엔드포인트
app.get('/health', (req, res) => {
  const dbStatus = checkDBStatus();
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    database: checkDBStatus(),
    uptime: process.uptime()
  });
});

// API 문서 엔드포인트
app.get('/api', (req, res) => {
  res.json({
    name: 'HaneulTone API',
    version: '1.0.0',
    description: 'AI 보컬 트레이너 앱을 위한 백엔드 API',
    endpoints: {
      'POST /api/auth/register': '회원가입',
      'POST /api/auth/login': '로그인',
      'PUT /api/auth/change-password': '비밀번호 변경 (인증 필요)',
      'GET /api/auth/verify': '토큰 검증 (인증 필요)',
      'GET /api/user/profile': '사용자 프로필 조회 (인증 필요)',
      'PUT /api/user/profile': '사용자 프로필 업데이트 (인증 필요)',
      'GET /api/user/stats': '사용자 통계 조회 (인증 필요)',
      'DELETE /api/user/account': '계정 삭제 (인증 필요)',
      'POST /api/sessions': '연습 세션 저장 (인증 필요)',
      'GET /api/sessions': '연습 세션 목록 조회 (인증 필요)',
      'GET /api/sessions/:id': '연습 세션 상세 조회 (인증 필요)',
      'DELETE /api/sessions/:id': '연습 세션 삭제 (인증 필요)',
      'GET /api/sessions/stats/summary': '세션 통계 조회 (인증 필요)'
    },
    authentication: 'Bearer Token (JWT)',
    database: checkDBStatus()
  });
});

// 404 처리
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: '요청하신 리소스를 찾을 수 없습니다',
    path: req.originalUrl
  });
});

// 전역 에러 핸들러
app.use((error, req, res, next) => {
  console.error('서버 오류:', error);
  
  // CORS 에러 처리
  if (error.message.includes('CORS')) {
    return res.status(403).json({
      success: false,
      message: 'CORS 정책에 의해 차단되었습니다'
    });
  }

  // JSON 파싱 에러 처리
  if (error.type === 'entity.parse.failed') {
    return res.status(400).json({
      success: false,
      message: '잘못된 JSON 형식입니다'
    });
  }

  // MongoDB 에러 처리
  if (error.name === 'CastError') {
    return res.status(400).json({
      success: false,
      message: '잘못된 ID 형식입니다'
    });
  }

  // 검증 에러 처리
  if (error.name === 'ValidationError') {
    const messages = Object.values(error.errors).map(e => e.message);
    return res.status(400).json({
      success: false,
      message: messages.join(', ')
    });
  }

  // 기본 에러 응답
  res.status(500).json({
    success: false,
    message: process.env.NODE_ENV === 'production' 
      ? '서버 내부 오류가 발생했습니다' 
      : error.message
  });
});

// 서버 시작
app.listen(PORT, () => {
  console.log(`🚀 HaneulTone API 서버 시작됨`);
  console.log(`📍 포트: ${PORT}`);
  console.log(`🌍 환경: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📚 API 문서: http://localhost:${PORT}/api`);
  console.log(`🏥 헬스 체크: http://localhost:${PORT}/health`);
  
  if (process.env.NODE_ENV === 'development') {
    console.log(`\n개발 환경 설정:`);
    console.log(`- MongoDB URI: ${process.env.MONGODB_URI || '설정되지 않음'}`);
    console.log(`- JWT Secret: ${process.env.JWT_SECRET ? '설정됨' : '설정되지 않음'}`);
    console.log(`- CORS Origin: ${process.env.CORS_ORIGIN || 'localhost 허용'}`);
  }
});

// 예상치 못한 에러 처리
process.on('uncaughtException', (error) => {
  console.error('예상치 못한 에러:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('처리되지 않은 Promise 거부:', reason);
  process.exit(1);
});

module.exports = app;