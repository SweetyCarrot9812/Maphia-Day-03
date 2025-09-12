const express = require('express');
const Session = require('../models/Session');
const { authenticateToken } = require('../middleware/auth');
const { sessionValidation } = require('../middleware/validation');

const router = express.Router();

// 모든 라우트는 인증 필요
router.use(authenticateToken);

// 연습 세션 저장
router.post('/', sessionValidation, async (req, res) => {
  try {
    const userId = req.user._id;
    const sessionData = {
      ...req.body,
      userId
    };

    // correctNotes가 totalNotes보다 클 수 없도록 검증
    if (sessionData.correctNotes > sessionData.totalNotes) {
      return res.status(400).json({
        success: false,
        message: '정확한 음표 수는 전체 음표 수보다 클 수 없습니다'
      });
    }

    const newSession = new Session(sessionData);
    await newSession.save();

    res.status(201).json({
      success: true,
      message: '연습 세션이 성공적으로 저장되었습니다',
      session: newSession
    });

  } catch (error) {
    console.error('Save session error:', error);
    res.status(500).json({
      success: false,
      message: '세션 저장 중 오류가 발생했습니다'
    });
  }
});

// 사용자의 연습 세션 목록 조회
router.get('/', async (req, res) => {
  try {
    const userId = req.user._id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const sessionType = req.query.sessionType; // 선택적 필터
    
    // 페이지네이션 계산
    const skip = (page - 1) * limit;
    
    // 쿼리 조건 설정
    const query = { userId };
    if (sessionType) {
      query.sessionType = sessionType;
    }

    // 세션 조회 (최신순)
    const sessions = await Session.find(query)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .select('-analysisData.pitchData -analysisData.timeStamps'); // 큰 데이터는 제외

    // 전체 개수 조회
    const totalCount = await Session.countDocuments(query);

    res.json({
      success: true,
      sessions,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(totalCount / limit),
        totalCount,
        hasNext: page < Math.ceil(totalCount / limit),
        hasPrev: page > 1
      }
    });

  } catch (error) {
    console.error('Get sessions error:', error);
    res.status(500).json({
      success: false,
      message: '세션 조회 중 오류가 발생했습니다'
    });
  }
});

// 특정 세션 상세 조회
router.get('/:sessionId', async (req, res) => {
  try {
    const userId = req.user._id;
    const { sessionId } = req.params;

    const session = await Session.findOne({ 
      _id: sessionId, 
      userId 
    });

    if (!session) {
      return res.status(404).json({
        success: false,
        message: '세션을 찾을 수 없습니다'
      });
    }

    res.json({
      success: true,
      session
    });

  } catch (error) {
    console.error('Get session detail error:', error);
    res.status(500).json({
      success: false,
      message: '세션 상세 조회 중 오류가 발생했습니다'
    });
  }
});

// 세션 삭제
router.delete('/:sessionId', async (req, res) => {
  try {
    const userId = req.user._id;
    const { sessionId } = req.params;

    const deletedSession = await Session.findOneAndDelete({ 
      _id: sessionId, 
      userId 
    });

    if (!deletedSession) {
      return res.status(404).json({
        success: false,
        message: '세션을 찾을 수 없습니다'
      });
    }

    res.json({
      success: true,
      message: '세션이 성공적으로 삭제되었습니다'
    });

  } catch (error) {
    console.error('Delete session error:', error);
    res.status(500).json({
      success: false,
      message: '세션 삭제 중 오류가 발생했습니다'
    });
  }
});

// 세션 통계 조회
router.get('/stats/summary', async (req, res) => {
  try {
    const userId = req.user._id;
    const { period } = req.query; // 'week', 'month', 'year' 중 하나

    let dateFilter = {};
    const now = new Date();
    
    switch (period) {
      case 'week':
        dateFilter = {
          createdAt: {
            $gte: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
          }
        };
        break;
      case 'month':
        dateFilter = {
          createdAt: {
            $gte: new Date(now.getFullYear(), now.getMonth(), 1)
          }
        };
        break;
      case 'year':
        dateFilter = {
          createdAt: {
            $gte: new Date(now.getFullYear(), 0, 1)
          }
        };
        break;
    }

    const matchCondition = { userId, ...dateFilter };

    // 기본 통계
    const basicStats = await Session.aggregate([
      { $match: matchCondition },
      {
        $group: {
          _id: null,
          totalSessions: { $sum: 1 },
          avgAccuracy: { $avg: '$accuracyMean' },
          avgStability: { $avg: '$stabilitySd' },
          totalPracticeTime: { $sum: '$duration' },
          bestAccuracy: { $min: '$accuracyMean' },
          totalNotes: { $sum: '$totalNotes' },
          totalCorrectNotes: { $sum: '$correctNotes' }
        }
      }
    ]);

    // 일별 통계 (최근 30일)
    const dailyStats = await Session.aggregate([
      { 
        $match: { 
          userId, 
          createdAt: { 
            $gte: new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000) 
          }
        }
      },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' },
            day: { $dayOfMonth: '$createdAt' }
          },
          sessions: { $sum: 1 },
          avgAccuracy: { $avg: '$accuracyMean' },
          totalTime: { $sum: '$duration' }
        }
      },
      { $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 } }
    ]);

    const stats = basicStats[0] || {
      totalSessions: 0,
      avgAccuracy: 0,
      avgStability: 0,
      totalPracticeTime: 0,
      bestAccuracy: 0,
      totalNotes: 0,
      totalCorrectNotes: 0
    };

    res.json({
      success: true,
      period,
      stats: {
        ...stats,
        overallAccuracyRate: stats.totalNotes > 0 ? 
          (stats.totalCorrectNotes / stats.totalNotes * 100) : 0,
        dailyStats
      }
    });

  } catch (error) {
    console.error('Get session stats error:', error);
    res.status(500).json({
      success: false,
      message: '세션 통계 조회 중 오류가 발생했습니다'
    });
  }
});

module.exports = router;