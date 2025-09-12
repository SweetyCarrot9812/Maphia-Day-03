/**
 * Clintest Desktop 학습 루프 v1 - GPT 파이프라인 관리 API
 * 
 * 역할: GPT-5 문제 생성 파이프라인 모니터링 및 수동 실행
 */

const express = require('express');
const router = express.Router();
const { verifyFirebaseToken, requireAdmin } = require('../middleware/auth');
const gptPipeline = require('../services/gpt-pipeline');

/**
 * GET /api/pipeline/status
 * 파이프라인 상태 조회
 */
router.get('/status', verifyFirebaseToken, async (req, res) => {
  try {
    const status = await gptPipeline.getStatus();
    
    res.json({
      success: true,
      data: status
    });
    
  } catch (error) {
    console.error('Pipeline status error:', error);
    res.status(500).json({
      success: false,
      message: '파이프라인 상태 조회 실패',
      error: error.message
    });
  }
});

/**
 * POST /api/pipeline/run
 * 수동 파이프라인 실행 (관리자 전용)
 */
router.post('/run', verifyFirebaseToken, requireAdmin, async (req, res) => {
  try {
    // 비동기로 실행 (응답은 즉시 반환)
    gptPipeline.processRegenQueue()
      .then(() => {
        console.log('✅ 수동 파이프라인 실행 완료');
      })
      .catch(error => {
        console.error('❌ 수동 파이프라인 실행 실패:', error);
      });
    
    res.json({
      success: true,
      message: '파이프라인 실행이 시작되었습니다',
      data: {
        triggeredAt: new Date(),
        triggeredBy: req.user.uid
      }
    });
    
  } catch (error) {
    console.error('Manual pipeline run error:', error);
    res.status(500).json({
      success: false,
      message: '파이프라인 수동 실행 실패',
      error: error.message
    });
  }
});

/**
 * GET /api/pipeline/jobs
 * 재출제 작업 목록 조회
 */
router.get('/jobs', verifyFirebaseToken, async (req, res) => {
  try {
    const { getDB } = require('../config/database');
    const db = getDB();
    const { uid } = req.user;
    
    const { status, page = 1, limit = 20 } = req.query;
    
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);
    const skip = (pageNum - 1) * limitNum;
    
    // 필터 조건 (사용자 본인 작업만)
    let filter = { ownerUid: uid };
    
    if (status) {
      filter.status = status;
    }
    
    // 작업 목록 조회
    const [jobs, totalCount] = await Promise.all([
      db.collection('regen_queue')
        .find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .toArray(),
      db.collection('regen_queue').countDocuments(filter)
    ]);
    
    res.json({
      success: true,
      data: {
        jobs: jobs,
        pagination: {
          currentPage: pageNum,
          totalPages: Math.ceil(totalCount / limitNum),
          totalCount: totalCount,
          hasNext: pageNum * limitNum < totalCount,
          hasPrevious: pageNum > 1
        }
      }
    });
    
  } catch (error) {
    console.error('Pipeline jobs error:', error);
    res.status(500).json({
      success: false,
      message: '작업 목록 조회 실패',
      error: error.message
    });
  }
});

/**
 * GET /api/pipeline/jobs/:jobId
 * 특정 작업 상세 조회
 */
router.get('/jobs/:jobId', verifyFirebaseToken, async (req, res) => {
  try {
    const { getDB } = require('../config/database');
    const { ObjectId } = require('mongodb');
    const db = getDB();
    const { uid } = req.user;
    const { jobId } = req.params;
    
    if (!ObjectId.isValid(jobId)) {
      return res.status(400).json({
        success: false,
        message: '유효하지 않은 작업 ID입니다'
      });
    }
    
    const job = await db.collection('regen_queue').findOne({
      _id: new ObjectId(jobId),
      ownerUid: uid
    });
    
    if (!job) {
      return res.status(404).json({
        success: false,
        message: '작업을 찾을 수 없습니다'
      });
    }
    
    res.json({
      success: true,
      data: job
    });
    
  } catch (error) {
    console.error('Pipeline job detail error:', error);
    res.status(500).json({
      success: false,
      message: '작업 상세 조회 실패',
      error: error.message
    });
  }
});

/**
 * DELETE /api/pipeline/jobs/:jobId
 * 작업 취소/삭제 (pending 상태만)
 */
router.delete('/jobs/:jobId', verifyFirebaseToken, async (req, res) => {
  try {
    const { getDB } = require('../config/database');
    const { ObjectId } = require('mongodb');
    const db = getDB();
    const { uid } = req.user;
    const { jobId } = req.params;
    
    if (!ObjectId.isValid(jobId)) {
      return res.status(400).json({
        success: false,
        message: '유효하지 않은 작업 ID입니다'
      });
    }
    
    // pending 상태인 작업만 삭제 가능
    const deleteResult = await db.collection('regen_queue').deleteOne({
      _id: new ObjectId(jobId),
      ownerUid: uid,
      status: 'pending'
    });
    
    if (deleteResult.deletedCount === 0) {
      return res.status(404).json({
        success: false,
        message: '삭제할 수 있는 작업을 찾을 수 없습니다 (pending 상태만 삭제 가능)'
      });
    }
    
    res.json({
      success: true,
      message: '작업이 취소되었습니다'
    });
    
  } catch (error) {
    console.error('Pipeline job delete error:', error);
    res.status(500).json({
      success: false,
      message: '작업 삭제 실패',
      error: error.message
    });
  }
});

/**
 * POST /api/pipeline/test-generation
 * 테스트용 단일 문제 생성 (개발/디버그용)
 */
router.post('/test-generation', verifyFirebaseToken, async (req, res) => {
  try {
    const { uid } = req.user;
    const { concepts, difficulty = 'B1', type = 'MCQ' } = req.body;
    
    if (!concepts || !Array.isArray(concepts)) {
      return res.status(400).json({
        success: false,
        message: 'concepts 배열이 필요합니다'
      });
    }
    
    // 테스트 작업 객체 생성
    const testJob = {
      ownerUid: uid,
      weakConcepts: concepts,
      targetCount: 1,
      difficulty: difficulty,
      type: type,
      contextRefs: {}
    };
    
    // 단일 문제 생성 테스트
    const problem = await gptPipeline.generateSingleProblem(testJob);
    
    res.json({
      success: true,
      data: {
        problem: problem,
        message: '테스트 문제 생성 완료 (DB에 저장되지 않음)'
      }
    });
    
  } catch (error) {
    console.error('Test generation error:', error);
    res.status(500).json({
      success: false,
      message: '테스트 문제 생성 실패',
      error: error.message
    });
  }
});

module.exports = router;