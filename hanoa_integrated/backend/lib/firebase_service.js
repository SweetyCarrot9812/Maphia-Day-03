const admin = require('firebase-admin');
const path = require('path');
const logger = require('./logger');

class HanoaFirebaseService {
  constructor() {
    this.app = null;
    this.auth = null;
    this.firestore = null;
    this.initialized = false;
  }

  initialize() {
    if (this.initialized) return;

    try {
      // 개발 모드에서는 Firebase 초기화 건너뛰기
      if (process.env.NODE_ENV === 'development' && process.env.FIREBASE_PROJECT_ID === 'hanoa-hub') {
        logger.info('⚠️  개발 모드: Firebase 초기화 건너뛰기 (실제 Firebase 프로젝트 설정 필요)');
        this.initialized = true;
        return;
      }

      const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || 
        path.join(__dirname, '../config/firebase-service-account.json');

      this.app = admin.initializeApp({
        credential: admin.credential.cert(require(serviceAccountPath)),
        projectId: process.env.FIREBASE_PROJECT_ID
      });

      this.auth = admin.auth();
      this.firestore = admin.firestore();
      
      this.firestore.settings({
        ignoreUndefinedProperties: true
      });

      this.initialized = true;
      logger.info('✅ Hanoa Hub Firebase Admin SDK 초기화 완료');
    } catch (error) {
      logger.error('❌ Firebase Admin SDK 초기화 실패:', error.message);
      logger.info('💡 실제 Firebase 프로젝트 설정 후 다시 시도하세요');
      // 개발 중에는 Firebase 오류로 서버가 죽지 않도록 처리
      this.initialized = true;
    }
  }

  /**
   * Firebase ID 토큰 검증
   */
  async verifyIdToken(idToken) {
    if (!this.initialized) this.initialize();

    try {
      const decodedToken = await this.auth.verifyIdToken(idToken);
      
      return {
        success: true,
        uid: decodedToken.uid,
        email: decodedToken.email,
        email_verified: decodedToken.email_verified,
        name: decodedToken.name,
        picture: decodedToken.picture,
        provider: decodedToken.firebase.sign_in_provider,
        auth_time: new Date(decodedToken.auth_time * 1000),
        exp: new Date(decodedToken.exp * 1000)
      };
    } catch (error) {
      logger.error('❌ Firebase ID 토큰 검증 실패:', error.message);
      return {
        success: false,
        error: error.code || 'INVALID_TOKEN',
        message: error.message
      };
    }
  }

  /**
   * Hanoa 사용자 생성/업데이트
   */
  async upsertHanoaUser(firebaseUserData) {
    if (!this.initialized) this.initialize();

    try {
      const { uid, email, email_verified, name, picture, provider } = firebaseUserData;
      const now = admin.firestore.Timestamp.now();
      
      const userRef = this.firestore.collection('hanoa_users').doc(uid);
      const userDoc = await userRef.get();

      const serviceSubscriptions = this.getDefaultSubscriptions();

      if (userDoc.exists) {
        // 기존 사용자 업데이트
        const existingData = userDoc.data();
        await userRef.update({
          lastLoginAt: now,
          lastLoginProvider: provider,
          loginCount: admin.firestore.FieldValue.increment(1),
          // 변경된 정보만 업데이트
          ...(email && { email }),
          ...(email_verified !== undefined && { emailVerified: email_verified }),
          ...(name && { name }),
          ...(picture && { profileImage: picture })
        });

        const updatedUser = await userRef.get();
        return {
          success: true,
          isNewUser: false,
          user: { uid: updatedUser.id, ...updatedUser.data() }
        };
      } else {
        // 새 사용자 생성
        const newUser = {
          email: email,
          emailVerified: email_verified || false,
          name: name || null,
          profileImage: picture || null,
          
          // 서비스 구독 정보
          subscriptions: serviceSubscriptions,
          
          // 전역 설정
          globalSettings: {
            language: 'ko',
            theme: 'light',
            notifications: true
          },
          
          // 메타데이터
          metadata: {
            signupProvider: provider,
            createdAt: now,
            lastLoginAt: now,
            lastLoginProvider: provider,
            loginCount: 1,
            lastActiveService: null
          }
        };

        await userRef.set(newUser);
        
        logger.info(`🎉 새로운 Hanoa 사용자 생성: ${email}`);
        
        return {
          success: true,
          isNewUser: true,
          user: { uid, ...newUser }
        };
      }
    } catch (error) {
      logger.error('❌ Hanoa 사용자 upsert 실패:', error.message);
      return {
        success: false,
        error: error.code || 'UPSERT_FAILED',
        message: error.message
      };
    }
  }

  /**
   * 사용자 정보 조회
   */
  async getHanoaUser(uid) {
    if (!this.initialized) this.initialize();

    try {
      const userRef = this.firestore.collection('hanoa_users').doc(uid);
      const userDoc = await userRef.get();
      
      if (userDoc.exists) {
        return {
          success: true,
          user: { uid: userDoc.id, ...userDoc.data() },
          found: true
        };
      } else {
        return {
          success: true,
          user: null,
          found: false
        };
      }
    } catch (error) {
      logger.error('❌ Hanoa 사용자 조회 실패:', error.message);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * 서비스별 구독 상태 확인
   */
  async checkServiceAccess(uid, serviceName) {
    const userResult = await this.getHanoaUser(uid);
    
    if (!userResult.success || !userResult.user) {
      return { hasAccess: false, reason: 'USER_NOT_FOUND' };
    }

    const subscription = userResult.user.subscriptions?.[serviceName];
    
    if (!subscription) {
      return { hasAccess: false, reason: 'SERVICE_NOT_FOUND' };
    }

    if (!subscription.isActive) {
      return { hasAccess: false, reason: 'SUBSCRIPTION_INACTIVE' };
    }

    // 유료 구독의 경우 만료일 확인
    if (subscription.plan !== 'free' && subscription.endDate) {
      const endDate = subscription.endDate.toDate();
      if (new Date() > endDate) {
        return { hasAccess: false, reason: 'SUBSCRIPTION_EXPIRED' };
      }
    }

    return {
      hasAccess: true,
      subscription,
      permissions: subscription.permissions || []
    };
  }

  /**
   * 사용자 활동 기록 업데이트
   */
  async updateUserActivity(uid, serviceName) {
    if (!this.initialized) this.initialize();

    try {
      const userRef = this.firestore.collection('hanoa_users').doc(uid);
      await userRef.update({
        'metadata.lastActiveService': serviceName,
        'metadata.lastActivityAt': admin.firestore.Timestamp.now()
      });
      
      return { success: true };
    } catch (error) {
      logger.error('❌ 사용자 활동 업데이트 실패:', error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * 기본 서비스 구독 설정
   */
  getDefaultSubscriptions() {
    return {
      clintest: {
        isActive: true,
        plan: 'free', // Beta 기간 중 무료
        permissions: [
          'read:questions',
          'write:attempts',
          'read:progress',
          'read:analytics'
        ],
        startDate: admin.firestore.Timestamp.now(),
        endDate: null // 무료는 만료일 없음
      },
      lingumo: {
        isActive: true,
        plan: 'free',
        permissions: [
          'read:lessons',
          'write:progress',
          'read:dictionary'
        ],
        startDate: admin.firestore.Timestamp.now(),
        endDate: null
      },
      haneul_tone: {
        isActive: false, // 아직 미출시
        plan: 'free',
        permissions: [],
        startDate: null,
        endDate: null
      },
      areum_fit: {
        isActive: false, // 아직 미출시
        plan: 'free',
        permissions: [],
        startDate: null,
        endDate: null
      }
    };
  }

  /**
   * 관리자 권한 확인
   */
  async isAdmin(uid) {
    const userResult = await this.getHanoaUser(uid);
    
    if (!userResult.success || !userResult.user) {
      return false;
    }

    // 관리자는 모든 서비스에 admin 권한을 가짐
    const subscriptions = userResult.user.subscriptions || {};
    
    return Object.values(subscriptions).some(sub => 
      sub.permissions && sub.permissions.includes('admin:all')
    );
  }
}

// 싱글톤 패턴
const hanoaFirebaseService = new HanoaFirebaseService();

module.exports = hanoaFirebaseService;