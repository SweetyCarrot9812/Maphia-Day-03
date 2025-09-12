/**
 * Clintest Desktop 학습 루프 v1 - 문제 관리 API
 * 
 * 역할: GPT-5 생성 문제 관리 및 중복 검사
 * 원칙: 문제는 AI가 생성/태깅/품질관리 자동화
 */

const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');
const { getDB } = require('../config/database');
const { verifyFirebaseToken } = require('../middleware/auth');

/**
 * POST /api/problems/generate
 * GPT-5 기반 문제 생성 (관리자/워커 전용)
 */
router.post('/generate', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    
    // 관리자 권한 확인 (실제 구현 시 role 체크 추가)
    // if (!req.user.isAdmin) { ... }
    
    const { 
      concepts, 
      difficulty = 'B1', 
      type = 'MCQ', 
      count = 1,
      contextRefs = {} 
    } = req.body;
    
    // 필수 필드 검증
    if (!concepts || !Array.isArray(concepts) || concepts.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'concepts 배열은 필수입니다'
      });
    }
    
    // 문제 생성 작업을 regen_queue에 추가
    const regenJob = {
      ownerUid: uid,
      weakConcepts: concepts,
      targetCount: count,
      contextRefs: contextRefs,
      difficulty: difficulty,
      type: type,
      status: 'pending',
      createdAt: new Date(),
      error: null
    };
    
    const insertResult = await db.collection('regen_queue').insertOne(regenJob);
    
    res.json({
      success: true,
      data: {
        jobId: insertResult.insertedId,
        status: 'pending',
        concepts: concepts,
        targetCount: count,
        message: '문제 생성 작업이 큐에 추가되었습니다'
      }
    });
    
  } catch (error) {
    console.error('Problem generation error:', error);
    res.status(500).json({
      success: false,
      message: '문제 생성 요청 실패',
      error: error.message
    });
  }
});

/**
 * POST /api/problems/duplicate-check
 * 문제 중복 검사 (임베딩 + 키해시)
 */
router.post('/duplicate-check', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { stem, concepts, rationale, type = 'MCQ' } = req.body;
    
    // 필수 필드 검증
    if (!stem || !concepts || !rationale) {
      return res.status(400).json({
        success: false,
        message: 'stem, concepts, rationale은 필수입니다'
      });
    }
    
    // 키 해시 생성 (실제 구현 시 crypto 사용)
    const keyContent = `${concepts.sort().join('|')}|${rationale}|${type}`;
    const keyHash = require('crypto')
      .createHash('sha256')
      .update(keyContent)
      .digest('hex');
    
    // 키 해시 기반 중복 검사
    const existingProblem = await db.collection('problems').findOne({
      ownerUid: uid,
      keyHash: keyHash
    });
    
    if (existingProblem) {
      return res.json({
        success: true,
        data: {
          isDuplicate: true,
          reason: 'identical_key_hash',
          existingProblemId: existingProblem._id,
          similarity: 1.0
        }
      });
    }
    
    // TODO: 임베딩 기반 유사도 검사 (향후 구현)
    // const embedding = await generateEmbedding(stem + rationale);
    // const similarProblems = await vectorSearch(embedding);
    
    // 중복 검사 결과 캐시 저장
    await db.collection('dup_cache').updateOne(
      {
        ownerUid: uid,
        candidateKeyHash: keyHash
      },
      {
        $set: {
          ownerUid: uid,
          candidateKeyHash: keyHash,
          nearest: null,
          decided: {
            isDup: false
          },
          createdAt: new Date()
        }
      },
      { upsert: true }
    );
    
    res.json({
      success: true,
      data: {
        isDuplicate: false,
        keyHash: keyHash,
        message: '중복되지 않은 문제입니다'
      }
    });
    
  } catch (error) {
    console.error('Duplicate check error:', error);
    res.status(500).json({
      success: false,
      message: '중복 검사 실패',
      error: error.message
    });
  }
});

/**
 * GET /api/problems
 * 문제 목록 조회 (필터링 및 페이지네이션)
 */
router.get('/', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { 
      page = 1, 
      limit = 20, 
      difficulty, 
      concepts,
      type,
      source 
    } = req.query;
    
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);
    const skip = (pageNum - 1) * limitNum;
    
    // 필터 조건 구성
    let filter = { ownerUid: uid };
    
    if (difficulty) {
      filter.difficulty = difficulty;
    }
    
    if (concepts) {
      const conceptsArray = Array.isArray(concepts) ? concepts : [concepts];
      filter.concepts = { $in: conceptsArray };
    }
    
    if (type) {
      filter.type = type;
    }
    
    if (source) {
      filter.source = source;
    }
    
    // 문제 목록 조회
    const [problems, totalCount] = await Promise.all([
      db.collection('problems')
        .find(filter, { 
          projection: { 
            embedding: 0 // 임베딩은 제외 (용량 절약)
          } 
        })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .toArray(),
      db.collection('problems').countDocuments(filter)
    ]);
    
    res.json({
      success: true,
      data: {
        problems: problems,
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
    console.error('Problems list error:', error);
    res.status(500).json({
      success: false,
      message: '문제 목록 조회 실패',
      error: error.message
    });
  }
});

/**
 * GET /api/problems/:problemId
 * 특정 문제 상세 조회
 */
router.get('/:problemId', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { problemId } = req.params;
    
    if (!ObjectId.isValid(problemId)) {
      return res.status(400).json({
        success: false,
        message: '유효하지 않은 문제 ID입니다'
      });
    }
    
    const problem = await db.collection('problems').findOne({
      _id: new ObjectId(problemId),
      ownerUid: uid
    }, {
      projection: { embedding: 0 } // 임베딩 제외
    });
    
    if (!problem) {
      return res.status(404).json({
        success: false,
        message: '문제를 찾을 수 없습니다'
      });
    }
    
    res.json({
      success: true,
      data: problem
    });
    
  } catch (error) {
    console.error('Problem fetch error:', error);
    res.status(500).json({
      success: false,
      message: '문제 조회 실패',
      error: error.message
    });
  }
});

/**
 * PUT /api/problems/:problemId
 * 문제 수정 (수동 편집)
 */
router.put('/:problemId', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { problemId } = req.params;
    const { stem, choices, concepts, difficulty, explanation } = req.body;
    
    if (!ObjectId.isValid(problemId)) {
      return res.status(400).json({
        success: false,
        message: '유효하지 않은 문제 ID입니다'
      });
    }
    
    // 업데이트할 필드 구성
    const updateFields = {
      updatedAt: new Date()
    };
    
    if (stem) updateFields.stem = stem;
    if (choices) updateFields.choices = choices;
    if (concepts) updateFields.concepts = concepts;
    if (difficulty) updateFields.difficulty = difficulty;
    if (explanation) updateFields['meta.explanation'] = explanation;
    
    const updateResult = await db.collection('problems').updateOne(
      {
        _id: new ObjectId(problemId),
        ownerUid: uid
      },
      { $set: updateFields }
    );
    
    if (updateResult.matchedCount === 0) {
      return res.status(404).json({
        success: false,
        message: '수정할 문제를 찾을 수 없습니다'
      });
    }
    
    res.json({
      success: true,
      message: '문제가 수정되었습니다'
    });
    
  } catch (error) {
    console.error('Problem update error:', error);
    res.status(500).json({
      success: false,
      message: '문제 수정 실패',
      error: error.message
    });
  }
});

/**
 * DELETE /api/problems/:problemId
 * 문제 삭제
 */
router.delete('/:problemId', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { problemId } = req.params;
    
    if (!ObjectId.isValid(problemId)) {
      return res.status(400).json({
        success: false,
        message: '유효하지 않은 문제 ID입니다'
      });
    }
    
    const deleteResult = await db.collection('problems').deleteOne({
      _id: new ObjectId(problemId),
      ownerUid: uid
    });
    
    if (deleteResult.deletedCount === 0) {
      return res.status(404).json({
        success: false,
        message: '삭제할 문제를 찾을 수 없습니다'
      });
    }
    
    // 관련 세션에서도 제거 (TODO: 별도 함수로 분리)
    await db.collection('sessions').updateMany(
      { ownerUid: uid },
      { $pull: { items: { problemId: problemId } } }
    );
    
    res.json({
      success: true,
      message: '문제가 삭제되었습니다'
    });
    
  } catch (error) {
    console.error('Problem delete error:', error);
    res.status(500).json({
      success: false,
      message: '문제 삭제 실패',
      error: error.message
    });
  }
});

module.exports = router;