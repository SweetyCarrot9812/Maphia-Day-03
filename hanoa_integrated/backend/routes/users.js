const express = require('express');
const router = express.Router();

const firebaseService = require('../lib/firebase_service');
const logger = require('../lib/logger');
const { verifyHanoaToken, requireAdmin } = require('../middleware/auth');

/**
 * GET /api/users/profile
 * 현재 사용자 프로필 조회
 */
router.get('/profile', verifyHanoaToken, async (req, res) => {
  try {
    const userResult = await firebaseService.getHanoaUser(req.hanoaUser.uid);
    
    if (!userResult.success || !userResult.user) {
      return res.status(404).json({
        success: false,
        error: 'USER_NOT_FOUND',
        message: '사용자를 찾을 수 없습니다.'
      });
    }

    res.json({
      success: true,
      user: {
        uid: userResult.user.uid,
        email: userResult.user.email,
        name: userResult.user.name,
        profileImage: userResult.user.profileImage,
        emailVerified: userResult.user.emailVerified,
        subscriptions: userResult.user.subscriptions,
        globalSettings: userResult.user.globalSettings,
        metadata: userResult.user.metadata
      }
    });

  } catch (error) {
    logger.error('❌ 사용자 프로필 조회 오류:', error);
    res.status(500).json({
      success: false,
      error: 'PROFILE_FETCH_FAILED',
      message: '프로필 조회 중 오류가 발생했습니다.'
    });
  }
});

/**
 * PUT /api/users/profile
 * 사용자 프로필 업데이트
 */
router.put('/profile', verifyHanoaToken, async (req, res) => {
  try {
    const { name, profileImage } = req.body;
    const uid = req.hanoaUser.uid;

    // 업데이트할 데이터 준비
    const updates = {};
    if (name !== undefined) updates.name = name;
    if (profileImage !== undefined) updates.profileImage = profileImage;

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        error: 'NO_UPDATE_DATA',
        message: '업데이트할 데이터가 없습니다.'
      });
    }

    // Firestore 업데이트
    const userRef = firebaseService.firestore.collection('hanoa_users').doc(uid);
    await userRef.update({
      ...updates,
      'metadata.updatedAt': firebaseService.firestore.FieldValue.serverTimestamp()
    });

    logger.info(`✏️  사용자 프로필 업데이트: ${req.hanoaUser.email}`);

    res.json({
      success: true,
      message: '프로필이 업데이트되었습니다.',
      updated: updates
    });

  } catch (error) {
    logger.error('❌ 사용자 프로필 업데이트 오류:', error);
    res.status(500).json({
      success: false,
      error: 'PROFILE_UPDATE_FAILED',
      message: '프로필 업데이트 중 오류가 발생했습니다.'
    });
  }
});

/**
 * PUT /api/users/settings
 * 전역 설정 업데이트
 */
router.put('/settings', verifyHanoaToken, async (req, res) => {
  try {
    const { language, theme, notifications } = req.body;
    const uid = req.hanoaUser.uid;

    // 설정 데이터 검증
    const settings = {};
    if (language && ['ko', 'en'].includes(language)) {
      settings.language = language;
    }
    if (theme && ['light', 'dark'].includes(theme)) {
      settings.theme = theme;
    }
    if (typeof notifications === 'boolean') {
      settings.notifications = notifications;
    }

    if (Object.keys(settings).length === 0) {
      return res.status(400).json({
        success: false,
        error: 'INVALID_SETTINGS',
        message: '유효하지 않은 설정 데이터입니다.'
      });
    }

    // Firestore 업데이트
    const userRef = firebaseService.firestore.collection('hanoa_users').doc(uid);
    const updateData = {};
    
    Object.keys(settings).forEach(key => {
      updateData[`globalSettings.${key}`] = settings[key];
    });
    updateData['metadata.updatedAt'] = firebaseService.firestore.FieldValue.serverTimestamp();

    await userRef.update(updateData);

    logger.info(`⚙️  사용자 설정 업데이트: ${req.hanoaUser.email}`);

    res.json({
      success: true,
      message: '설정이 업데이트되었습니다.',
      updated: settings
    });

  } catch (error) {
    logger.error('❌ 사용자 설정 업데이트 오류:', error);
    res.status(500).json({
      success: false,
      error: 'SETTINGS_UPDATE_FAILED',
      message: '설정 업데이트 중 오류가 발생했습니다.'
    });
  }
});

/**
 * GET /api/users/subscriptions
 * 사용자 구독 정보 조회
 */
router.get('/subscriptions', verifyHanoaToken, async (req, res) => {
  try {
    const userResult = await firebaseService.getHanoaUser(req.hanoaUser.uid);
    
    if (!userResult.success || !userResult.user) {
      return res.status(404).json({
        success: false,
        error: 'USER_NOT_FOUND',
        message: '사용자를 찾을 수 없습니다.'
      });
    }

    // 구독 정보와 함께 각 서비스 상태 확인
    const subscriptions = userResult.user.subscriptions || {};
    const subscriptionDetails = {};

    for (const [serviceName, subscription] of Object.entries(subscriptions)) {
      const accessResult = await firebaseService.checkServiceAccess(
        req.hanoaUser.uid, 
        serviceName
      );

      subscriptionDetails[serviceName] = {
        ...subscription,
        hasAccess: accessResult.hasAccess,
        accessReason: accessResult.reason
      };
    }

    res.json({
      success: true,
      subscriptions: subscriptionDetails
    });

  } catch (error) {
    logger.error('❌ 구독 정보 조회 오류:', error);
    res.status(500).json({
      success: false,
      error: 'SUBSCRIPTION_FETCH_FAILED',
      message: '구독 정보 조회 중 오류가 발생했습니다.'
    });
  }
});

/**
 * GET /api/users (관리자 전용)
 * 모든 사용자 목록 조회
 */
router.get('/', verifyHanoaToken, requireAdmin, async (req, res) => {
  try {
    const { limit = 50, startAfter } = req.query;
    
    let query = firebaseService.firestore
      .collection('hanoa_users')
      .orderBy('metadata.createdAt', 'desc')
      .limit(parseInt(limit));

    if (startAfter) {
      const startAfterDoc = await firebaseService.firestore
        .collection('hanoa_users')
        .doc(startAfter)
        .get();
      
      if (startAfterDoc.exists) {
        query = query.startAfter(startAfterDoc);
      }
    }

    const snapshot = await query.get();
    const users = [];

    snapshot.forEach(doc => {
      const userData = doc.data();
      users.push({
        uid: doc.id,
        email: userData.email,
        name: userData.name,
        emailVerified: userData.emailVerified,
        subscriptions: userData.subscriptions,
        metadata: userData.metadata
      });
    });

    res.json({
      success: true,
      users,
      hasMore: snapshot.docs.length === parseInt(limit),
      lastUser: users.length > 0 ? users[users.length - 1].uid : null
    });

  } catch (error) {
    logger.error('❌ 사용자 목록 조회 오류:', error);
    res.status(500).json({
      success: false,
      error: 'USERS_FETCH_FAILED',
      message: '사용자 목록 조회 중 오류가 발생했습니다.'
    });
  }
});

/**
 * PUT /api/users/:uid/subscription (관리자 전용)
 * 사용자 구독 상태 변경
 */
router.put('/:uid/subscription', verifyHanoaToken, requireAdmin, async (req, res) => {
  try {
    const { uid } = req.params;
    const { serviceName, isActive, plan, permissions } = req.body;

    // 입력 검증
    if (!serviceName) {
      return res.status(400).json({
        success: false,
        error: 'MISSING_SERVICE_NAME',
        message: '서비스 이름이 필요합니다.'
      });
    }

    const validServices = ['clintest', 'lingumo', 'haneul_tone', 'areum_fit'];
    if (!validServices.includes(serviceName)) {
      return res.status(400).json({
        success: false,
        error: 'INVALID_SERVICE',
        message: '유효하지 않은 서비스입니다.'
      });
    }

    // 업데이트 데이터 준비
    const updates = {};
    if (typeof isActive === 'boolean') {
      updates[`subscriptions.${serviceName}.isActive`] = isActive;
    }
    if (plan && ['free', 'basic', 'premium'].includes(plan)) {
      updates[`subscriptions.${serviceName}.plan`] = plan;
    }
    if (Array.isArray(permissions)) {
      updates[`subscriptions.${serviceName}.permissions`] = permissions;
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        error: 'NO_UPDATE_DATA',
        message: '업데이트할 데이터가 없습니다.'
      });
    }

    updates['metadata.updatedAt'] = firebaseService.firestore.FieldValue.serverTimestamp();

    // Firestore 업데이트
    const userRef = firebaseService.firestore.collection('hanoa_users').doc(uid);
    await userRef.update(updates);

    logger.info(`👨‍💼 관리자 ${req.hanoaUser.email}가 사용자 ${uid}의 ${serviceName} 구독을 변경했습니다.`);

    res.json({
      success: true,
      message: '구독 정보가 업데이트되었습니다.',
      updated: { serviceName, ...updates }
    });

  } catch (error) {
    logger.error('❌ 구독 업데이트 오류:', error);
    res.status(500).json({
      success: false,
      error: 'SUBSCRIPTION_UPDATE_FAILED',
      message: '구독 업데이트 중 오류가 발생했습니다.'
    });
  }
});

module.exports = router;