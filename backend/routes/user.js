const express = require('express');
const User = require('../models/User');
const { authenticateToken } = require('../middleware/auth');
const { updateProfileValidation } = require('../middleware/validation');

const router = express.Router();

// 모든 라우트는 인증 필요
router.use(authenticateToken);

// 사용자 프로필 조회
router.get('/profile', async (req, res) => {
  try {
    // authenticateToken 미들웨어에서 req.user에 사용자 정보가 이미 설정됨
    const user = req.user;
    
    res.json({
      success: true,
      user: user
    });

  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: '프로필 조회 중 오류가 발생했습니다'
    });
  }
});

// 사용자 프로필 업데이트
router.put('/profile', updateProfileValidation, async (req, res) => {
  try {
    const userId = req.user._id;
    const updates = req.body;

    // 허용되지 않는 필드 제거
    const allowedUpdates = ['displayName', 'voiceType', 'skillLevel', 'preferences', 'profileImage'];
    const filteredUpdates = {};
    
    Object.keys(updates).forEach(key => {
      if (allowedUpdates.includes(key)) {
        filteredUpdates[key] = updates[key];
      }
    });

    // 사용자 정보 업데이트
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      filteredUpdates,
      { 
        new: true, // 업데이트된 문서 반환
        runValidators: true // 스키마 검증 실행
      }
    );

    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: '사용자를 찾을 수 없습니다'
      });
    }

    res.json({
      success: true,
      message: '프로필이 성공적으로 업데이트되었습니다',
      user: updatedUser
    });

  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: '프로필 업데이트 중 오류가 발생했습니다'
    });
  }
});

// 사용자 통계 조회
router.get('/stats', async (req, res) => {
  try {
    const userId = req.user._id;
    const Session = require('../models/Session');

    // 기본 통계 계산
    const totalSessions = await Session.countDocuments({ userId });
    const recentSessions = await Session.find({ userId })
      .sort({ createdAt: -1 })
      .limit(10);

    // 평균 정확도 계산
    const avgAccuracyResult = await Session.aggregate([
      { $match: { userId: userId } },
      {
        $group: {
          _id: null,
          avgAccuracy: { $avg: '$accuracyMean' },
          avgStability: { $avg: '$stabilitySd' },
          totalPracticeTime: { $sum: '$duration' }
        }
      }
    ]);

    const stats = avgAccuracyResult[0] || {
      avgAccuracy: 0,
      avgStability: 0,
      totalPracticeTime: 0
    };

    // 세션 타입별 통계
    const sessionTypeStats = await Session.aggregate([
      { $match: { userId: userId } },
      {
        $group: {
          _id: '$sessionType',
          count: { $sum: 1 },
          avgAccuracy: { $avg: '$accuracyMean' }
        }
      }
    ]);

    // 월별 연습 세션 수
    const monthlyStats = await Session.aggregate([
      { $match: { userId: userId } },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' }
          },
          sessions: { $sum: 1 },
          totalTime: { $sum: '$duration' }
        }
      },
      { $sort: { '_id.year': -1, '_id.month': -1 } },
      { $limit: 12 }
    ]);

    res.json({
      success: true,
      stats: {
        totalSessions,
        averageAccuracy: Math.round(stats.avgAccuracy * 10) / 10,
        averageStability: Math.round(stats.avgStability * 10) / 10,
        totalPracticeTime: Math.round(stats.totalPracticeTime),
        sessionTypeStats,
        monthlyStats,
        recentSessions: recentSessions.slice(0, 5) // 최근 5개만
      }
    });

  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({
      success: false,
      message: '통계 조회 중 오류가 발생했습니다'
    });
  }
});

// 계정 삭제
router.delete('/account', async (req, res) => {
  try {
    const userId = req.user._id;
    const Session = require('../models/Session');

    // 사용자 관련 모든 세션 삭제
    await Session.deleteMany({ userId });
    
    // 사용자 삭제
    await User.findByIdAndDelete(userId);

    res.json({
      success: true,
      message: '계정이 성공적으로 삭제되었습니다'
    });

  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({
      success: false,
      message: '계정 삭제 중 오류가 발생했습니다'
    });
  }
});

module.exports = router;