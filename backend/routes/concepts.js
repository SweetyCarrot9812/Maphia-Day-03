/**
 * Clintest Desktop 학습 루프 v1 - Obsidian 개념 관리 API
 * 
 * 역할: Obsidian 개념 노트 동기화 (메타데이터만)
 * 원칙: 개념은 Obsidian에만 작성, DB는 메타만 미러링
 */

const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');
const { getDB } = require('../config/database');
const { verifyFirebaseToken } = require('../middleware/auth');

/**
 * GET /api/concepts/sync
 * Obsidian 변경분 스캔 → concept_notes 미러링
 */
router.get('/sync', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    
    // 사용자의 concept_notes 조회
    const conceptNotes = await db.collection('concept_notes')
      .find({ ownerUid: uid })
      .sort({ lastSyncAt: -1 })
      .toArray();
    
    res.json({
      success: true,
      data: {
        totalNotes: conceptNotes.length,
        notes: conceptNotes,
        lastSync: conceptNotes.length > 0 ? conceptNotes[0].lastSyncAt : null
      }
    });
    
  } catch (error) {
    console.error('Concept sync error:', error);
    res.status(500).json({
      success: false,
      message: '개념 동기화 실패',
      error: error.message
    });
  }
});

/**
 * POST /api/concepts/sync
 * Obsidian에서 변경된 개념 노트 메타데이터 업데이트
 */
router.post('/sync', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { obsidianPath, title, tags, hash } = req.body;
    
    // 필수 필드 검증
    if (!obsidianPath || !title || !hash) {
      return res.status(400).json({
        success: false,
        message: 'obsidianPath, title, hash는 필수입니다'
      });
    }
    
    // concept_notes 업데이트 또는 생성
    const updateResult = await db.collection('concept_notes').updateOne(
      { 
        ownerUid: uid,
        obsidianPath: obsidianPath 
      },
      {
        $set: {
          ownerUid: uid,
          obsidianPath: obsidianPath,
          title: title,
          tags: tags || [],
          hash: hash,
          lastSyncAt: new Date()
        }
      },
      { upsert: true }
    );
    
    res.json({
      success: true,
      data: {
        obsidianPath: obsidianPath,
        title: title,
        isNew: updateResult.upsertedCount > 0,
        lastSyncAt: new Date()
      }
    });
    
  } catch (error) {
    console.error('Concept update error:', error);
    res.status(500).json({
      success: false,
      message: '개념 노트 업데이트 실패',
      error: error.message
    });
  }
});

/**
 * GET /api/concepts/:conceptId
 * 특정 개념 노트 메타데이터 조회
 */
router.get('/:conceptId', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { conceptId } = req.params;
    
    if (!ObjectId.isValid(conceptId)) {
      return res.status(400).json({
        success: false,
        message: '유효하지 않은 개념 ID입니다'
      });
    }
    
    const conceptNote = await db.collection('concept_notes').findOne({
      _id: new ObjectId(conceptId),
      ownerUid: uid
    });
    
    if (!conceptNote) {
      return res.status(404).json({
        success: false,
        message: '개념 노트를 찾을 수 없습니다'
      });
    }
    
    res.json({
      success: true,
      data: conceptNote
    });
    
  } catch (error) {
    console.error('Concept fetch error:', error);
    res.status(500).json({
      success: false,
      message: '개념 노트 조회 실패',
      error: error.message
    });
  }
});

/**
 * DELETE /api/concepts/:conceptId
 * 개념 노트 메타데이터 삭제 (Obsidian 파일 삭제 시)
 */
router.delete('/:conceptId', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { conceptId } = req.params;
    
    if (!ObjectId.isValid(conceptId)) {
      return res.status(400).json({
        success: false,
        message: '유효하지 않은 개념 ID입니다'
      });
    }
    
    const deleteResult = await db.collection('concept_notes').deleteOne({
      _id: new ObjectId(conceptId),
      ownerUid: uid
    });
    
    if (deleteResult.deletedCount === 0) {
      return res.status(404).json({
        success: false,
        message: '삭제할 개념 노트를 찾을 수 없습니다'
      });
    }
    
    res.json({
      success: true,
      message: '개념 노트 메타데이터가 삭제되었습니다'
    });
    
  } catch (error) {
    console.error('Concept delete error:', error);
    res.status(500).json({
      success: false,
      message: '개념 노트 삭제 실패',
      error: error.message
    });
  }
});

/**
 * GET /api/concepts
 * 사용자의 모든 개념 노트 목록 조회 (페이지네이션)
 */
router.get('/', verifyFirebaseToken, async (req, res) => {
  try {
    const db = getDB();
    const { uid } = req.user;
    const { page = 1, limit = 50, tag, search } = req.query;
    
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);
    const skip = (pageNum - 1) * limitNum;
    
    // 필터 조건 구성
    let filter = { ownerUid: uid };
    
    if (tag) {
      filter.tags = tag;
    }
    
    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { obsidianPath: { $regex: search, $options: 'i' } }
      ];
    }
    
    // 개념 노트 목록 조회
    const [concepts, totalCount] = await Promise.all([
      db.collection('concept_notes')
        .find(filter)
        .sort({ lastSyncAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .toArray(),
      db.collection('concept_notes').countDocuments(filter)
    ]);
    
    res.json({
      success: true,
      data: {
        concepts: concepts,
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
    console.error('Concepts list error:', error);
    res.status(500).json({
      success: false,
      message: '개념 노트 목록 조회 실패',
      error: error.message
    });
  }
});

module.exports = router;