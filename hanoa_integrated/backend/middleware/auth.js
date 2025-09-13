const firebaseService = require('../lib/firebase_service');
const jwtService = require('../lib/jwt_service');
const logger = require('../lib/logger');

/**
 * Firebase ID 토큰 검증 미들웨어
 */
async function verifyFirebaseToken(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'MISSING_TOKEN',
        message: 'Authorization 헤더가 필요합니다.'
      });
    }

    const idToken = authHeader.substring(7);
    const verifyResult = await firebaseService.verifyIdToken(idToken);

    if (!verifyResult.success) {
      return res.status(401).json({
        success: false,
        error: verifyResult.error,
        message: verifyResult.message
      });
    }

    req.firebaseUser = verifyResult;
    next();
  } catch (error) {
    logger.error('❌ Firebase 토큰 검증 미들웨어 오류:', error);
    return res.status(500).json({
      success: false,
      error: 'INTERNAL_ERROR',
      message: '토큰 검증 중 오류가 발생했습니다.'
    });
  }
}

/**
 * Hanoa JWT 토큰 검증 미들웨어
 */
function verifyHanoaToken(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'MISSING_TOKEN',
        message: 'Hanoa 토큰이 필요합니다.'
      });
    }

    const token = authHeader.substring(7);
    const verifyResult = jwtService.verifyToken(token, 'access');

    if (!verifyResult.success) {
      return res.status(401).json({
        success: false,
        error: verifyResult.error,
        message: verifyResult.message
      });
    }

    req.hanoaUser = verifyResult.payload;
    next();
  } catch (error) {
    logger.error('❌ Hanoa 토큰 검증 미들웨어 오류:', error);
    return res.status(500).json({
      success: false,
      error: 'INTERNAL_ERROR',
      message: '토큰 검증 중 오류가 발생했습니다.'
    });
  }
}

/**
 * 서비스별 권한 확인 미들웨어 팩토리
 */
function requireServicePermission(serviceName, permission) {
  return (req, res, next) => {
    try {
      if (!req.hanoaUser) {
        return res.status(401).json({
          success: false,
          error: 'UNAUTHORIZED',
          message: '인증이 필요합니다.'
        });
      }

      const hasPermission = jwtService.hasServicePermission(
        req.hanoaUser, 
        serviceName, 
        permission
      );

      if (!hasPermission) {
        return res.status(403).json({
          success: false,
          error: 'INSUFFICIENT_PERMISSIONS',
          message: `${serviceName} 서비스의 ${permission} 권한이 필요합니다.`,
          requiredService: serviceName,
          requiredPermission: permission
        });
      }

      next();
    } catch (error) {
      logger.error('❌ 서비스 권한 확인 미들웨어 오류:', error);
      return res.status(500).json({
        success: false,
        error: 'INTERNAL_ERROR',
        message: '권한 확인 중 오류가 발생했습니다.'
      });
    }
  };
}

/**
 * 관리자 권한 확인 미들웨어
 */
async function requireAdmin(req, res, next) {
  try {
    if (!req.hanoaUser) {
      return res.status(401).json({
        success: false,
        error: 'UNAUTHORIZED',
        message: '인증이 필요합니다.'
      });
    }

    const isAdmin = await firebaseService.isAdmin(req.hanoaUser.uid);
    
    if (!isAdmin) {
      return res.status(403).json({
        success: false,
        error: 'ADMIN_REQUIRED',
        message: '관리자 권한이 필요합니다.'
      });
    }

    next();
  } catch (error) {
    logger.error('❌ 관리자 권한 확인 미들웨어 오류:', error);
    return res.status(500).json({
      success: false,
      error: 'INTERNAL_ERROR',
      message: '권한 확인 중 오류가 발생했습니다.'
    });
  }
}

/**
 * 서비스별 토큰 검증 (다른 서비스에서 사용)
 * 
 * 사용 예시:
 * - Clintest 서버: requireServiceAccess('clintest', 'read:questions')
 * - Lingumo 서버: requireServiceAccess('lingumo', 'read:lessons')
 */
function requireServiceAccess(serviceName, permission) {
  return async (req, res, next) => {
    try {
      // 1. Hanoa 토큰 검증
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({
          success: false,
          error: 'MISSING_TOKEN',
          message: 'Hanoa 토큰이 필요합니다.'
        });
      }

      const token = authHeader.substring(7);
      const verifyResult = jwtService.verifyToken(token, 'access');

      if (!verifyResult.success) {
        return res.status(401).json({
          success: false,
          error: verifyResult.error,
          message: verifyResult.message
        });
      }

      // 2. 서비스 접근 권한 재확인 (실시간 확인)
      const accessResult = await firebaseService.checkServiceAccess(
        verifyResult.payload.uid, 
        serviceName
      );

      if (!accessResult.hasAccess) {
        let message = '서비스 접근 권한이 없습니다.';
        let errorCode = 'SERVICE_ACCESS_DENIED';

        switch (accessResult.reason) {
          case 'USER_NOT_FOUND':
            message = '사용자를 찾을 수 없습니다.';
            errorCode = 'USER_NOT_FOUND';
            break;
          case 'SERVICE_NOT_FOUND':
            message = '서비스를 찾을 수 없습니다.';
            errorCode = 'SERVICE_NOT_FOUND';
            break;
          case 'SUBSCRIPTION_INACTIVE':
            message = '서비스 구독이 비활성화되어 있습니다.';
            errorCode = 'SUBSCRIPTION_INACTIVE';
            break;
          case 'SUBSCRIPTION_EXPIRED':
            message = '서비스 구독이 만료되었습니다.';
            errorCode = 'SUBSCRIPTION_EXPIRED';
            break;
        }

        return res.status(403).json({
          success: false,
          error: errorCode,
          message
        });
      }

      // 3. 특정 권한 확인
      if (permission && !accessResult.permissions.includes(permission)) {
        // admin:all 권한 확인
        if (!accessResult.permissions.includes('admin:all')) {
          return res.status(403).json({
            success: false,
            error: 'INSUFFICIENT_PERMISSIONS',
            message: `${permission} 권한이 필요합니다.`,
            requiredPermission: permission,
            userPermissions: accessResult.permissions
          });
        }
      }

      // 4. 사용자 활동 기록
      await firebaseService.updateUserActivity(verifyResult.payload.uid, serviceName);

      // 5. 요청 객체에 사용자 정보 추가
      req.hanoaUser = verifyResult.payload;
      req.serviceAccess = accessResult;
      
      next();
    } catch (error) {
      logger.error('❌ 서비스 접근 검증 미들웨어 오류:', error);
      return res.status(500).json({
        success: false,
        error: 'INTERNAL_ERROR',
        message: '서비스 접근 검증 중 오류가 발생했습니다.'
      });
    }
  };
}

module.exports = {
  verifyFirebaseToken,
  verifyHanoaToken,
  requireServicePermission,
  requireAdmin,
  requireServiceAccess
};