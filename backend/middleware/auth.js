const jwt = require('jsonwebtoken');
const User = require('../models/User');
const admin = require('firebase-admin');

// Firebase Admin SDK 초기화 (한 번만)
if (!admin.apps.length) {
  try {
    // Service Account Key를 환경변수에서 로드
    const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_KEY ? 
      JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY) : null;
      
    if (serviceAccount) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: process.env.FIREBASE_PROJECT_ID || 'hanoa-97393'
      });
      console.log('✅ Firebase Admin SDK 초기화 완료');
    } else {
      console.log('⚠️ Firebase Service Account Key가 설정되지 않았습니다. JWT만 사용합니다.');
    }
  } catch (error) {
    console.error('❌ Firebase Admin SDK 초기화 실패:', error.message);
  }
}

// JWT 토큰 검증 미들웨어
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({ 
        success: false, 
        message: '액세스 토큰이 없습니다' 
      });
    }

    // JWT 토큰 검증
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // 사용자 정보 조회
    const user = await User.findById(decoded.userId).select('-password');
    
    if (!user) {
      return res.status(401).json({ 
        success: false, 
        message: '유효하지 않은 토큰입니다' 
      });
    }

    // req 객체에 사용자 정보 첨부
    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        success: false, 
        message: '토큰이 만료되었습니다' 
      });
    } else if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        success: false, 
        message: '유효하지 않은 토큰입니다' 
      });
    }
    
    console.error('Authentication error:', error);
    res.status(500).json({ 
      success: false, 
      message: '인증 처리 중 오류가 발생했습니다' 
    });
  }
};

// JWT 토큰 생성 유틸리티
const generateToken = (userId) => {
  return jwt.sign(
    { userId: userId },
    process.env.JWT_SECRET,
    { 
      expiresIn: '7d', // 7일 후 만료
      issuer: 'haneultone-api'
    }
  );
};

// 리프레시 토큰 생성 (장기 토큰)
const generateRefreshToken = (userId) => {
  return jwt.sign(
    { userId: userId, type: 'refresh' },
    process.env.JWT_SECRET,
    { 
      expiresIn: '30d', // 30일 후 만료
      issuer: 'haneultone-api'
    }
  );
};

/**
 * Firebase ID 토큰 검증 미들웨어 (Clintest 학습 루프 v1용)
 */
async function verifyFirebaseToken(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: '인증 토큰이 필요합니다',
        code: 'NO_TOKEN'
      });
    }
    
    const idToken = authHeader.substring(7); // "Bearer " 제거
    
    // Firebase가 설정되지 않았으면 개발 모드로 진행
    if (!admin.apps.length) {
      console.log('🔧 개발 모드: 더미 사용자 인증');
      req.user = {
        uid: 'dev-user-123',
        email: 'dev@example.com',
        name: '개발용 사용자',
        isAdmin: true
      };
      return next();
    }
    
    // Firebase ID 토큰 검증
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    
    // 검증된 사용자 정보를 req.user에 설정
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email || '',
      name: decodedToken.name || decodedToken.email || 'Unknown',
      isAdmin: decodedToken.email === 'tkandpf26@gmail.com', // 슈퍼 어드민
      firebaseUser: decodedToken
    };
    
    next();
    
  } catch (error) {
    console.error('Firebase token verification error:', error);
    
    // 토큰 만료 등 구체적 에러 처리
    let message = '인증 토큰이 유효하지 않습니다';
    let code = 'INVALID_TOKEN';
    
    if (error.code === 'auth/id-token-expired') {
      message = '인증 토큰이 만료되었습니다';
      code = 'TOKEN_EXPIRED';
    } else if (error.code === 'auth/argument-error') {
      message = '인증 토큰 형식이 올바르지 않습니다';
      code = 'MALFORMED_TOKEN';
    }
    
    res.status(401).json({
      success: false,
      message: message,
      code: code
    });
  }
}

/**
 * 관리자 권한 확인 미들웨어
 */
function requireAdmin(req, res, next) {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      message: '인증이 필요합니다'
    });
  }
  
  if (!req.user.isAdmin) {
    return res.status(403).json({
      success: false,
      message: '관리자 권한이 필요합니다'
    });
  }
  
  next();
}

module.exports = {
  authenticateToken,
  generateToken,
  generateRefreshToken,
  verifyFirebaseToken,
  requireAdmin
};