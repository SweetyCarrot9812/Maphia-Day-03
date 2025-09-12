const express = require('express');
const router = express.Router();

const firebaseService = require('../lib/firebase_service');
const jwtService = require('../lib/jwt_service');
const logger = require('../lib/logger');
const { verifyFirebaseToken, verifyHanoaToken } = require('../middleware/auth');

/**
 * POST /api/auth/login
 * Firebase ID 토큰으로 Hanoa 통합 로그인
 */
router.post('/login', verifyFirebaseToken, async (req, res) => {
  try {
    const { firebaseUser } = req;

    // Hanoa 사용자 생성/업데이트
    const upsertResult = await firebaseService.upsertHanoaUser(firebaseUser);
    
    if (!upsertResult.success) {
      return res.status(500).json({
        success: false,
        error: 'USER_UPSERT_FAILED',
        message: '사용자 정보 저장에 실패했습니다.',
        details: upsertResult.error
      });
    }

    const { user, isNewUser } = upsertResult;

    // Hanoa JWT 토큰 생성
    const tokenResult = jwtService.generateHanoaToken(user);
    const refreshTokenResult = jwtService.generateRefreshToken(user.uid);

    if (!tokenResult.success || !refreshTokenResult.success) {
      return res.status(500).json({
        success: false,
        error: 'TOKEN_GENERATION_FAILED',
        message: '토큰 생성에 실패했습니다.'
      });
    }

    logger.info(`🎉 ${isNewUser ? '신규' : '기존'} 사용자 로그인: ${user.email}`);

    res.json({
      success: true,
      isNewUser,
      user: {
        uid: user.uid,
        email: user.email,
        name: user.name,
        profileImage: user.profileImage,
        subscriptions: user.subscriptions,
        globalSettings: user.globalSettings
      },
      tokens: {
        accessToken: tokenResult.token,
        refreshToken: refreshTokenResult.token,
        expiresIn: tokenResult.expiresIn
      },
      message: isNewUser ? 'Hanoa에 오신 것을 환영합니다!' : '로그인 성공'
    });

  } catch (error) {
    logger.error('❌ Hanoa 로그인 처리 오류:', error);
    res.status(500).json({
      success: false,
      error: 'LOGIN_FAILED',
      message: '로그인 처리 중 오류가 발생했습니다.'
    });
  }
});

/**
 * POST /api/auth/refresh
 * 리프레시 토큰으로 새로운 액세스 토큰 발급
 */
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        error: 'MISSING_REFRESH_TOKEN',
        message: '리프레시 토큰이 필요합니다.'
      });
    }

    // 리프레시 토큰 검증
    const verifyResult = jwtService.verifyToken(refreshToken, 'refresh');
    
    if (!verifyResult.success) {
      return res.status(401).json({
        success: false,
        error: verifyResult.error,
        message: verifyResult.message
      });
    }

    // 사용자 정보 조회
    const userResult = await firebaseService.getHanoaUser(verifyResult.payload.uid);
    
    if (!userResult.success || !userResult.user) {
      return res.status(404).json({
        success: false,
        error: 'USER_NOT_FOUND',
        message: '사용자를 찾을 수 없습니다.'
      });
    }

    // 새로운 액세스 토큰 생성
    const tokenResult = jwtService.generateHanoaToken(userResult.user);
    
    if (!tokenResult.success) {
      return res.status(500).json({
        success: false,
        error: 'TOKEN_GENERATION_FAILED',
        message: '새 토큰 생성에 실패했습니다.'
      });
    }

    res.json({
      success: true,
      token: tokenResult.token,
      expiresIn: tokenResult.expiresIn
    });

  } catch (error) {
    logger.error('❌ 토큰 갱신 오류:', error);
    res.status(500).json({
      success: false,
      error: 'TOKEN_REFRESH_FAILED',
      message: '토큰 갱신 중 오류가 발생했습니다.'
    });
  }
});

/**
 * GET /api/auth/verify
 * Hanoa 토큰 검증 (다른 서비스에서 사용)
 */
router.get('/verify', verifyHanoaToken, async (req, res) => {
  try {
    const { hanoaUser } = req;
    
    // 최신 사용자 정보 조회
    const userResult = await firebaseService.getHanoaUser(hanoaUser.uid);
    
    if (!userResult.success || !userResult.user) {
      return res.status(404).json({
        success: false,
        error: 'USER_NOT_FOUND',
        message: '사용자를 찾을 수 없습니다.'
      });
    }

    res.json({
      success: true,
      valid: true,
      user: {
        uid: userResult.user.uid,
        email: userResult.user.email,
        name: userResult.user.name,
        profileImage: userResult.user.profileImage,
        subscriptions: userResult.user.subscriptions,
        globalSettings: userResult.user.globalSettings
      },
      services: hanoaUser.services // 토큰에서 가져온 서비스 권한
    });

  } catch (error) {
    logger.error('❌ 토큰 검증 오류:', error);
    res.status(500).json({
      success: false,
      error: 'TOKEN_VERIFICATION_FAILED',
      message: '토큰 검증 중 오류가 발생했습니다.'
    });
  }
});

/**
 * POST /api/auth/logout
 * 로그아웃 (클라이언트에서 토큰 삭제)
 */
router.post('/logout', verifyHanoaToken, (req, res) => {
  try {
    logger.info(`👋 사용자 로그아웃: ${req.hanoaUser.email}`);
    
    res.json({
      success: true,
      message: '로그아웃되었습니다.'
    });
  } catch (error) {
    logger.error('❌ 로그아웃 오류:', error);
    res.status(500).json({
      success: false,
      error: 'LOGOUT_FAILED',
      message: '로그아웃 중 오류가 발생했습니다.'
    });
  }
});

/**
 * GET /api/auth/services/:serviceName/check
 * 특정 서비스 접근 권한 확인
 */
router.get('/services/:serviceName/check', verifyHanoaToken, async (req, res) => {
  try {
    const { serviceName } = req.params;
    const { permission } = req.query;

    const accessResult = await firebaseService.checkServiceAccess(
      req.hanoaUser.uid, 
      serviceName
    );

    if (!accessResult.hasAccess) {
      return res.json({
        success: true,
        hasAccess: false,
        reason: accessResult.reason,
        subscription: null
      });
    }

    // 특정 권한 확인
    let hasPermission = true;
    if (permission) {
      hasPermission = accessResult.permissions.includes(permission) ||
                     accessResult.permissions.includes('admin:all');
    }

    res.json({
      success: true,
      hasAccess: true,
      hasPermission,
      subscription: accessResult.subscription,
      permissions: accessResult.permissions
    });

  } catch (error) {
    logger.error('❌ 서비스 접근 권한 확인 오류:', error);
    res.status(500).json({
      success: false,
      error: 'SERVICE_CHECK_FAILED',
      message: '서비스 접근 권한 확인 중 오류가 발생했습니다.'
    });
  }
});

module.exports = router;