const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      // MongoDB 연결 옵션 (최신 Mongoose 버전용)
      maxPoolSize: 10, // 최대 연결 풀 크기
      serverSelectionTimeoutMS: 5000, // 서버 선택 타임아웃
      socketTimeoutMS: 45000, // 소켓 타임아웃
    });

    console.log(`✅ MongoDB 연결 성공: ${conn.connection.host}`);
    
    // 연결 이벤트 리스너
    mongoose.connection.on('error', (err) => {
      console.error('❌ MongoDB 연결 오류:', err);
    });

    mongoose.connection.on('disconnected', () => {
      console.warn('⚠️  MongoDB 연결 끊김');
    });

    mongoose.connection.on('reconnected', () => {
      console.log('🔄 MongoDB 재연결 성공');
    });

    // 프로세스 종료시 연결 정리
    process.on('SIGINT', async () => {
      try {
        await mongoose.connection.close();
        console.log('🔌 MongoDB 연결 종료');
        process.exit(0);
      } catch (err) {
        console.error('MongoDB 연결 종료 중 오류:', err);
        process.exit(1);
      }
    });

  } catch (error) {
    console.error('❌ MongoDB 연결 실패:', error.message);
    
    // 개발 환경에서는 MongoDB 없이도 서버 실행 허용
    if (process.env.NODE_ENV === 'development') {
      console.warn('⚠️  개발 환경에서 MongoDB 없이 서버를 실행합니다. 데이터베이스 기능은 사용할 수 없습니다.');
      return;
    }
    
    // 프로덕션 환경에서는 여전히 종료
    process.exit(1);
  }
};

// 데이터베이스 상태 확인 함수
const checkDBStatus = () => {
  const state = mongoose.connection.readyState;
  const stateMap = {
    0: '연결 끊김',
    1: '연결됨',
    2: '연결 중',
    3: '연결 해제 중'
  };
  
  return {
    state: stateMap[state] || '알 수 없음',
    isConnected: state === 1
  };
};

module.exports = {
  connectDB,
  checkDBStatus
};