/**
 * Clintest Desktop 학습 루프 v1 - 학습 세션 및 SRS API
 * 
 * 역할: Again/Good 2버튼 SRS 시스템 및 학습 기록 관리
 * 원칙: 오답 기반 재출제, 취약도 계산, 적응형 학습
 */

const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');
const { getDB } = require('../config/database');
const { verifyFirebaseToken } = require('../middleware/auth');

/**
 * GET /api/learning/next-session
 * 다음 학습 세션 (문제 세트) 반환
 * SRS 스케줄링 + 난이도 분포 적용
 */
router.get('/next-session', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { count = 10 } = req.query;
    
    const sessionCount = Math.min(parseInt(count), 20); // 최대 20문제
    
    // 현재 시간 기준 출제 가능한 문제들 조회
    const sessions = await db.collection('sessions')
      .find({ 
        ownerUid: uid,
        'items.dueAt': { $lte: new Date() }
      })
      .toArray();
    
    // SRS 아이템들 수집
    let dueItems = [];
    sessions.forEach(session => {
      session.items.forEach(item => {
        if (new Date(item.dueAt) <= new Date()) {
          dueItems.push({
            ...item,
            sessionId: session._id
          });
        }
      });
    });
    
    // 난이도별 분포 적용 (쉬움 30%, 보통 50%, 어려움 20%)
    const difficultyTargets = {
      easy: Math.ceil(sessionCount * 0.3),
      medium: Math.ceil(sessionCount * 0.5),  
      hard: Math.floor(sessionCount * 0.2)
    };
    
    let selectedItems = [];
    
    // 각 난이도별로 문제 선택
    for (const [difficultyGroup, targetCount] of Object.entries(difficultyTargets)) {
      const difficultyPattern = getDifficultyPattern(difficultyGroup);
      
      const itemsInDifficulty = dueItems.filter(item => 
        difficultyPattern.test(item.difficulty || 'B1')
      );
      
      // 우선순위: SRS 간격이 긴 순서 (오래된 문제 우선)
      itemsInDifficulty.sort((a, b) => {
        const aInterval = a.srsState?.interval || 1;
        const bInterval = b.srsState?.interval || 1;
        return bInterval - aInterval;
      });
      
      selectedItems.push(...itemsInDifficulty.slice(0, targetCount));
    }
    
    // 부족한 경우 전체에서 추가 선택
    if (selectedItems.length < sessionCount) {
      const remaining = dueItems.filter(item => 
        !selectedItems.some(selected => 
          selected.problemId === item.problemId
        )
      );
      
      selectedItems.push(...remaining.slice(0, sessionCount - selectedItems.length));
    }
    
    // 문제 상세 정보 조회
    const problemIds = selectedItems.map(item => new ObjectId(item.problemId));
    const problems = await db.collection('problems')
      .find({ 
        _id: { $in: problemIds },
        ownerUid: uid 
      }, {
        projection: { embedding: 0 } // 임베딩 제외
      })
      .toArray();
    
    // 문제와 SRS 정보 결합
    const sessionProblems = selectedItems.map(item => {
      const problem = problems.find(p => p._id.toString() === item.problemId);
      return {
        ...problem,
        srsState: item.srsState,
        sessionItemId: `${item.sessionId}_${item.problemId}`
      };
    }).filter(p => p._id); // 유효한 문제만
    
    res.json({
      success: true,
      data: {
        problems: sessionProblems,
        totalDueItems: dueItems.length,
        sessionCount: sessionProblems.length,
        difficultyDistribution: calculateActualDistribution(sessionProblems)
      }
    });
    
  } catch (error) {
    console.error('Next session error:', error);
    res.status(500).json({
      success: false,
      message: '다음 세션 조회 실패',
      error: error.message
    });
  }
});

/**
 * POST /api/learning/submit-attempt
 * 학습 시도 제출 및 SRS 업데이트
 * Again/Good 2버튼만 지원
 */
router.post('/submit-attempt', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { 
      problemId, 
      chosenIndex, 
      isCorrect, 
      latencyMs, 
      result, // "Again" | "Good"
      explainSeen = false 
    } = req.body;
    
    // 필수 필드 검증
    if (!problemId || typeof chosenIndex !== 'number' || !result) {
      return res.status(400).json({
        success: false,
        message: 'problemId, chosenIndex, result는 필수입니다'
      });
    }
    
    if (!['Again', 'Good'].includes(result)) {
      return res.status(400).json({
        success: false,
        message: 'result는 Again 또는 Good이어야 합니다'
      });
    }
    
    // 시도 기록 저장
    const attempt = {
      ownerUid: uid,
      problemId: problemId,
      chosenIndex: chosenIndex,
      isCorrect: isCorrect,
      latencyMs: latencyMs || 0,
      at: new Date(),
      explainSeen: explainSeen,
      srsResult: result,
      weakConcepts: [] // TODO: 취약 개념 분석
    };
    
    const attemptResult = await db.collection('attempts').insertOne(attempt);
    
    // SRS 상태 업데이트
    const srsUpdate = calculateSRSUpdate(result, isCorrect);
    
    const sessionUpdateResult = await db.collection('sessions').updateOne(
      { 
        ownerUid: uid,
        'items.problemId': problemId 
      },
      { 
        $set: {
          'items.$.srsState.interval': srsUpdate.newInterval,
          'items.$.srsState.ef': srsUpdate.newEF,
          'items.$.srsState.streak': srsUpdate.newStreak,
          'items.$.dueAt': srsUpdate.nextDueAt,
          'items.$.lastResult': result,
          'items.$.lastAttemptAt': new Date(),
          updatedAt: new Date()
        }
      }
    );
    
    // 취약도 계산 및 재출제 트리거 확인
    const shouldTriggerRegen = await checkWeaknessAndTriggerRegen(
      db, uid, problemId, isCorrect, result
    );
    
    res.json({
      success: true,
      data: {
        attemptId: attemptResult.insertedId,
        srsUpdate: srsUpdate,
        sessionUpdated: sessionUpdateResult.modifiedCount > 0,
        regenTriggered: shouldTriggerRegen,
        nextDueAt: srsUpdate.nextDueAt
      }
    });
    
  } catch (error) {
    console.error('Submit attempt error:', error);
    res.status(500).json({
      success: false,
      message: '학습 시도 제출 실패',
      error: error.message
    });
  }
});

/**
 * POST /api/learning/trigger-regen
 * 취약 개념 기반 재출제 큐 생성
 */
router.post('/trigger-regen', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { concepts, targetCount = 5 } = req.body;
    
    if (!concepts || !Array.isArray(concepts)) {
      return res.status(400).json({
        success: false,
        message: 'concepts 배열은 필수입니다'
      });
    }
    
    // 기존 pending 작업 확인
    const existingJob = await db.collection('regen_queue').findOne({
      ownerUid: uid,
      status: 'pending',
      weakConcepts: { $in: concepts }
    });
    
    if (existingJob) {
      return res.json({
        success: true,
        data: {
          jobId: existingJob._id,
          message: '이미 해당 개념에 대한 재출제 작업이 진행 중입니다'
        }
      });
    }
    
    // 새 재출제 작업 생성
    const regenJob = {
      ownerUid: uid,
      weakConcepts: concepts,
      targetCount: Math.min(targetCount, 10), // 최대 10문제
      contextRefs: {
        obsidianNoteIds: [] // TODO: 관련 개념 노트 찾기
      },
      status: 'pending',
      createdAt: new Date(),
      error: null
    };
    
    const insertResult = await db.collection('regen_queue').insertOne(regenJob);
    
    res.json({
      success: true,
      data: {
        jobId: insertResult.insertedId,
        concepts: concepts,
        targetCount: targetCount,
        message: '재출제 작업이 큐에 추가되었습니다'
      }
    });
    
  } catch (error) {
    console.error('Trigger regen error:', error);
    res.status(500).json({
      success: false,
      message: '재출제 트리거 실패',
      error: error.message
    });
  }
});

/**
 * GET /api/learning/stats
 * 학습 통계 및 취약도 분석
 */
router.get('/stats', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { period = '7d' } = req.query;
    
    // 기간별 시도 기록 조회
    const periodDate = getPeriodDate(period);
    
    const attempts = await db.collection('attempts')
      .find({ 
        ownerUid: uid,
        at: { $gte: periodDate }
      })
      .sort({ at: -1 })
      .toArray();
    
    // 기본 통계 계산
    const totalAttempts = attempts.length;
    const correctAttempts = attempts.filter(a => a.isCorrect).length;
    const accuracyRate = totalAttempts > 0 ? correctAttempts / totalAttempts : 0;
    
    // 개념별 취약도 분석
    const conceptWeakness = await analyzeConceptWeakness(db, uid, attempts);
    
    // SRS 상태 분포
    const sessions = await db.collection('sessions')
      .find({ ownerUid: uid })
      .toArray();
    
    let srsDistribution = { due: 0, learning: 0, mature: 0 };
    let totalItems = 0;
    
    sessions.forEach(session => {
      session.items.forEach(item => {
        totalItems++;
        const interval = item.srsState?.interval || 1;
        if (new Date(item.dueAt) <= new Date()) {
          srsDistribution.due++;
        } else if (interval < 21) {
          srsDistribution.learning++;
        } else {
          srsDistribution.mature++;
        }
      });
    });
    
    res.json({
      success: true,
      data: {
        period: period,
        basicStats: {
          totalAttempts,
          correctAttempts,
          accuracyRate: Math.round(accuracyRate * 100),
          averageLatency: attempts.length > 0 ? 
            Math.round(attempts.reduce((sum, a) => sum + (a.latencyMs || 0), 0) / attempts.length) : 0
        },
        conceptWeakness: conceptWeakness,
        srsDistribution: {
          ...srsDistribution,
          total: totalItems
        }
      }
    });
    
  } catch (error) {
    console.error('Learning stats error:', error);
    res.status(500).json({
      success: false,
      message: '학습 통계 조회 실패',
      error: error.message
    });
  }
});

// === Helper Functions ===

function getDifficultyPattern(difficultyGroup) {
  const patterns = {
    easy: /^A[1-3]$/,
    medium: /^B[1-3]$/,
    hard: /^C[1-3]$/
  };
  return patterns[difficultyGroup] || /^B[1-3]$/;
}

function calculateActualDistribution(problems) {
  const distribution = { easy: 0, medium: 0, hard: 0 };
  
  problems.forEach(problem => {
    const difficulty = problem.difficulty || 'B1';
    if (/^A[1-3]$/.test(difficulty)) {
      distribution.easy++;
    } else if (/^B[1-3]$/.test(difficulty)) {
      distribution.medium++;
    } else if (/^C[1-3]$/.test(difficulty)) {
      distribution.hard++;
    }
  });
  
  return distribution;
}

function calculateSRSUpdate(result, isCorrect) {
  // SM-2 알고리즘 기반 간소화 버전
  const baseInterval = 1;
  const easyFactor = 2.5;
  
  if (result === 'Again') {
    return {
      newInterval: baseInterval,
      newEF: Math.max(1.3, easyFactor - 0.2),
      newStreak: 0,
      nextDueAt: new Date(Date.now() + baseInterval * 24 * 60 * 60 * 1000)
    };
  }
  
  // "Good" 결과
  const newInterval = baseInterval * Math.pow(easyFactor, 1);
  const nextDueAt = new Date(Date.now() + newInterval * 24 * 60 * 60 * 1000);
  
  return {
    newInterval: Math.ceil(newInterval),
    newEF: easyFactor,
    newStreak: 1,
    nextDueAt: nextDueAt
  };
}

async function checkWeaknessAndTriggerRegen(db, uid, problemId, isCorrect, result) {
  if (isCorrect && result === 'Good') {
    return false; // 정답이면 재출제 불필요
  }
  
  // TODO: 개념별 오답률 계산 및 임계값 확인
  // TODO: 취약도 상위 개념들로 재출제 작업 자동 생성
  
  return false; // 현재는 수동 트리거만 지원
}

async function analyzeConceptWeakness(db, uid, attempts) {
  // TODO: EWMA 기반 개념별 취약도 계산
  // 현재는 단순한 오답률 계산
  
  const conceptStats = {};
  
  attempts.forEach(attempt => {
    // 문제의 concepts 정보가 필요 (별도 조회 필요)
    // 여기서는 샘플 구현
  });
  
  return []; // 임시
}

function getPeriodDate(period) {
  const now = new Date();
  const periods = {
    '1d': 1,
    '7d': 7,
    '30d': 30
  };
  
  const days = periods[period] || 7;
  return new Date(now.getTime() - days * 24 * 60 * 60 * 1000);
}

module.exports = router;