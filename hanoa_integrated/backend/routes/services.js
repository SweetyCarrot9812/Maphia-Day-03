const express = require('express');
const router = express.Router();

const firebaseService = require('../lib/firebase_service');
const jwtService = require('../lib/jwt_service');
const logger = require('../lib/logger');
const { verifyHanoaToken, requireServiceAccess } = require('../middleware/auth');

/**
 * POST /api/services/:serviceName/verify
 * 다른 서비스에서 토큰 검증 요청 (서비스 간 통신용)
 * 
 * 사용 예시:
 * - Clintest 서버 → Hanoa Hub: POST /api/services/clintest/verify
 * - Lingumo 서버 → Hanoa Hub: POST /api/services/lingumo/verify
 */
router.post('/:serviceName/verify', async (req, res) => {
  try {
    const { serviceName } = req.params;
    const { token, requiredPermission } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        error: 'MISSING_TOKEN',
        message: 'token이 필요합니다.'
      });
    }

    // 1. Hanoa 토큰 검증
    const verifyResult = jwtService.verifyToken(token, 'access');
    
    if (!verifyResult.success) {
      return res.status(401).json({
        success: false,
        error: verifyResult.error,
        message: verifyResult.message
      });
    }

    // 2. 서비스 접근 권한 실시간 확인
    const accessResult = await firebaseService.checkServiceAccess(
      verifyResult.payload.uid, 
      serviceName
    );

    if (!accessResult.hasAccess) {
      let message = '서비스 접근 권한이 없습니다.';
      let statusCode = 403;

      switch (accessResult.reason) {
        case 'USER_NOT_FOUND':
          message = '사용자를 찾을 수 없습니다.';
          statusCode = 404;
          break;
        case 'SERVICE_NOT_FOUND':
          message = '서비스를 찾을 수 없습니다.';
          statusCode = 404;
          break;
        case 'SUBSCRIPTION_INACTIVE':
          message = '서비스 구독이 비활성화되어 있습니다.';
          break;
        case 'SUBSCRIPTION_EXPIRED':
          message = '서비스 구독이 만료되었습니다.';
          break;
      }

      return res.status(statusCode).json({
        success: false,
        error: accessResult.reason,
        message
      });
    }

    // 3. 특정 권한 확인 (요청된 경우)
    let hasPermission = true;
    if (requiredPermission) {
      hasPermission = accessResult.permissions.includes(requiredPermission) ||
                     accessResult.permissions.includes('admin:all');
                     
      if (!hasPermission) {
        return res.status(403).json({
          success: false,
          error: 'INSUFFICIENT_PERMISSIONS',
          message: `${requiredPermission} 권한이 필요합니다.`,
          requiredPermission,
          userPermissions: accessResult.permissions
        });
      }
    }

    // 4. 사용자 활동 기록
    await firebaseService.updateUserActivity(verifyResult.payload.uid, serviceName);

    // 5. 서비스에 사용자 정보 반환
    res.json({
      success: true,
      user: {
        uid: verifyResult.payload.uid,
        email: verifyResult.payload.email,
        name: verifyResult.payload.name
      },
      serviceAccess: {
        isActive: accessResult.subscription.isActive,
        plan: accessResult.subscription.plan,
        permissions: accessResult.permissions
      },
      hasPermission
    });

    logger.info(`🔐 서비스 ${serviceName}에서 사용자 ${verifyResult.payload.email} 토큰 검증 완료`);

  } catch (error) {
    logger.error('❌ 서비스 토큰 검증 오류:', error);
    res.status(500).json({
      success: false,
      error: 'SERVICE_VERIFICATION_FAILED',
      message: '서비스 토큰 검증 중 오류가 발생했습니다.'
    });
  }
});

/**
 * GET /api/services
 * 사용 가능한 서비스 목록 및 상태 조회
 */
router.get('/', async (req, res) => {
  try {
    const services = {
      clintest: {
        name: 'Clintest',
        description: '의학/간호학 학습 플랫폼',
        status: 'active',
        url: process.env.CLINTEST_URL,
        availablePlans: ['free', 'basic', 'premium'],
        permissions: [
          'read:questions',
          'write:attempts',
          'read:progress',
          'read:analytics',
          'admin:content'
        ]
      },
      lingumo: {
        name: 'Lingumo',
        description: '언어 학습 플랫폼',
        status: 'active',
        url: process.env.LINGUMO_URL,
        availablePlans: ['free', 'basic', 'premium'],
        permissions: [
          'read:lessons',
          'write:progress',
          'read:dictionary',
          'admin:curriculum'
        ]
      },
      haneul_tone: {
        name: 'HaneulTone',
        description: '성악 학습 플랫폼',
        status: 'coming_soon',
        url: process.env.HANEUL_TONE_URL,
        availablePlans: ['free', 'basic', 'premium'],
        permissions: [
          'read:scores',
          'write:practice',
          'read:theory'
        ]
      },
      areum_fit: {
        name: 'AreumFit',
        description: '피트니스 플랫폼',
        status: 'coming_soon',
        url: null,
        availablePlans: ['free', 'basic', 'premium'],
        permissions: [
          'read:workouts',
          'write:progress',
          'read:nutrition'
        ]
      }
    };

    res.json({
      success: true,
      services
    });

  } catch (error) {
    logger.error('❌ 서비스 목록 조회 오류:', error);
    res.status(500).json({
      success: false,
      error: 'SERVICES_FETCH_FAILED',
      message: '서비스 목록 조회 중 오류가 발생했습니다.'
    });
  }
});

/**
 * GET /api/services/my
 * 사용자의 서비스 구독 현황 조회
 */
router.get('/my', verifyHanoaToken, async (req, res) => {
  try {
    const userResult = await firebaseService.getHanoaUser(req.hanoaUser.uid);
    
    if (!userResult.success || !userResult.user) {
      return res.status(404).json({
        success: false,
        error: 'USER_NOT_FOUND',
        message: '사용자를 찾을 수 없습니다.'
      });
    }

    const subscriptions = userResult.user.subscriptions || {};
    const myServices = {};

    // 각 서비스별 상세 정보와 함께 구독 상태 반환
    for (const [serviceName, subscription] of Object.entries(subscriptions)) {
      const accessResult = await firebaseService.checkServiceAccess(
        req.hanoaUser.uid, 
        serviceName
      );

      myServices[serviceName] = {
        isActive: subscription.isActive,
        plan: subscription.plan,
        permissions: subscription.permissions || [],
        hasAccess: accessResult.hasAccess,
        accessReason: accessResult.reason || null,
        startDate: subscription.startDate,
        endDate: subscription.endDate
      };
    }

    res.json({
      success: true,
      services: myServices,
      lastActiveService: userResult.user.metadata?.lastActiveService || null
    });

  } catch (error) {
    logger.error('❌ 사용자 서비스 조회 오류:', error);
    res.status(500).json({
      success: false,
      error: 'USER_SERVICES_FETCH_FAILED',
      message: '사용자 서비스 조회 중 오류가 발생했습니다.'
    });
  }
});

/**
 * GET /api/services/health
 * 서비스별 헬스 체크
 */
router.get('/health', async (req, res) => {
  try {
    const services = {
      clintest: process.env.CLINTEST_URL,
      lingumo: process.env.LINGUMO_URL,
      haneul_tone: process.env.HANEUL_TONE_URL
    };

    const healthChecks = {};

    // 각 서비스의 헬스 체크
    await Promise.allSettled(
      Object.entries(services).map(async ([serviceName, url]) => {
        if (!url) {
          healthChecks[serviceName] = { status: 'not_configured', responseTime: null };
          return;
        }

        try {
          const startTime = Date.now();
          const response = await fetch(`${url}/health`, { 
            method: 'GET',
            timeout: 5000 // 5초 타임아웃
          });
          const responseTime = Date.now() - startTime;

          healthChecks[serviceName] = {
            status: response.ok ? 'healthy' : 'unhealthy',
            responseTime,
            statusCode: response.status
          };
        } catch (error) {
          healthChecks[serviceName] = {
            status: 'unreachable',
            responseTime: null,
            error: error.message
          };
        }
      })
    );

    res.json({
      success: true,
      healthChecks,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    logger.error('❌ 서비스 헬스 체크 오류:', error);
    res.status(500).json({
      success: false,
      error: 'HEALTH_CHECK_FAILED',
      message: '서비스 헬스 체크 중 오류가 발생했습니다.'
    });
  }
});

module.exports = router;