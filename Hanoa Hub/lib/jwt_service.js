const jwt = require('jsonwebtoken');
const logger = require('./logger');

class HanoaJWTService {
  constructor() {
    this.jwtSecret = process.env.JWT_SECRET;
    this.jwtExpiresIn = process.env.JWT_EXPIRES_IN || '24h';
    this.refreshExpiresIn = process.env.JWT_REFRESH_EXPIRES_IN || '7d';
    
    if (!this.jwtSecret) {
      throw new Error('JWT_SECRET 환경변수가 설정되지 않았습니다.');
    }
  }

  /**
   * Hanoa 토큰 생성
   */
  generateHanoaToken(user) {
    try {
      const payload = {
        uid: user.uid,
        email: user.email,
        name: user.name,
        services: this.formatServicesForToken(user.subscriptions),
        type: 'access'
      };

      const token = jwt.sign(payload, this.jwtSecret, {
        expiresIn: this.jwtExpiresIn,
        issuer: 'hanoa-hub',
        audience: 'hanoa-services'
      });

      logger.info(`🎟️  사용자 ${user.email}의 Hanoa 토큰 생성`);
      
      return {
        success: true,
        token,
        expiresIn: this.jwtExpiresIn
      };
    } catch (error) {
      logger.error('❌ Hanoa 토큰 생성 실패:', error.message);
      return {
        success: false,
        error: 'TOKEN_GENERATION_FAILED',
        message: error.message
      };
    }
  }

  /**
   * 리프레시 토큰 생성
   */
  generateRefreshToken(uid) {
    try {
      const payload = {
        uid,
        type: 'refresh'
      };

      const token = jwt.sign(payload, this.jwtSecret, {
        expiresIn: this.refreshExpiresIn,
        issuer: 'hanoa-hub',
        audience: 'hanoa-services'
      });

      return {
        success: true,
        token,
        expiresIn: this.refreshExpiresIn
      };
    } catch (error) {
      logger.error('❌ 리프레시 토큰 생성 실패:', error.message);
      return {
        success: false,
        error: 'REFRESH_TOKEN_GENERATION_FAILED',
        message: error.message
      };
    }
  }

  /**
   * 토큰 검증
   */
  verifyToken(token, expectedType = 'access') {
    try {
      const decoded = jwt.verify(token, this.jwtSecret, {
        issuer: 'hanoa-hub',
        audience: 'hanoa-services'
      });

      // 토큰 타입 확인
      if (decoded.type !== expectedType) {
        return {
          success: false,
          error: 'INVALID_TOKEN_TYPE',
          message: `Expected ${expectedType} token, got ${decoded.type}`
        };
      }

      return {
        success: true,
        payload: decoded
      };
    } catch (error) {
      logger.warn('⚠️  토큰 검증 실패:', error.message);
      
      let errorCode = 'TOKEN_VERIFICATION_FAILED';
      let message = error.message;

      if (error.name === 'JsonWebTokenError') {
        errorCode = 'INVALID_TOKEN';
        message = '유효하지 않은 토큰입니다.';
      } else if (error.name === 'TokenExpiredError') {
        errorCode = 'TOKEN_EXPIRED';
        message = '토큰이 만료되었습니다.';
      } else if (error.name === 'NotBeforeError') {
        errorCode = 'TOKEN_NOT_ACTIVE';
        message = '토큰이 아직 활성화되지 않았습니다.';
      }

      return {
        success: false,
        error: errorCode,
        message
      };
    }
  }

  /**
   * 서비스별 권한을 토큰용 포맷으로 변환
   */
  formatServicesForToken(subscriptions) {
    if (!subscriptions) return {};

    const services = {};
    
    Object.keys(subscriptions).forEach(serviceName => {
      const subscription = subscriptions[serviceName];
      services[serviceName] = {
        isActive: subscription.isActive,
        plan: subscription.plan,
        permissions: subscription.permissions || []
      };
    });

    return services;
  }

  /**
   * 특정 서비스에 대한 권한 확인
   */
  hasServicePermission(tokenPayload, serviceName, requiredPermission) {
    const service = tokenPayload.services?.[serviceName];
    
    if (!service || !service.isActive) {
      return false;
    }

    // admin:all 권한이 있으면 모든 권한 허용
    if (service.permissions.includes('admin:all')) {
      return true;
    }

    // 특정 권한 확인
    return service.permissions.includes(requiredPermission);
  }

  /**
   * 토큰에서 사용자 정보 추출 (디코딩만, 검증 안함)
   */
  decodeToken(token) {
    try {
      return jwt.decode(token);
    } catch (error) {
      logger.error('❌ 토큰 디코딩 실패:', error.message);
      return null;
    }
  }
}

// 싱글톤 패턴
const hanoaJWTService = new HanoaJWTService();

module.exports = hanoaJWTService;