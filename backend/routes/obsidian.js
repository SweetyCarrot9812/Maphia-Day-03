/**
 * Clintest Desktop 학습 루프 v1 - Obsidian 브리지 API
 * 
 * 역할: Obsidian Vault 설정 및 파일 감시 관리
 * 원칙: 사용자별 개별 Vault 경로 지원
 */

const express = require('express');
const router = express.Router();
const { verifyFirebaseToken } = require('../middleware/auth');
const obsidianBridge = require('../services/obsidian-bridge');

/**
 * POST /api/obsidian/setup-vault
 * 사용자별 Obsidian Vault 경로 설정
 */
router.post('/setup-vault', verifyFirebaseToken, async (req, res) => {
  try {
    const { uid } = req.user;
    const { vaultPath } = req.body;
    
    if (!vaultPath) {
      return res.status(400).json({
        success: false,
        message: 'Vault 경로가 필요합니다'
      });
    }
    
    // Obsidian Bridge에 Vault 설정
    const setupResult = await obsidianBridge.setupUserVault(uid, vaultPath);
    
    res.json({
      success: true,
      data: setupResult,
      message: 'Obsidian Vault 연결이 설정되었습니다'
    });
    
  } catch (error) {
    console.error('Obsidian vault setup error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Vault 설정 실패'
    });
  }
});

/**
 * GET /api/obsidian/status
 * Obsidian 브리지 상태 조회
 */
router.get('/status', verifyFirebaseToken, async (req, res) => {
  try {
    const { uid } = req.user;
    const status = obsidianBridge.getStatus();
    
    // 현재 사용자의 설정만 필터링
    const userStatus = status.activeUsers.find(u => u.uid === uid);
    
    res.json({
      success: true,
      data: {
        isWatching: status.isWatching,
        userVault: userStatus || null,
        totalActiveUsers: status.activeUsers.length
      }
    });
    
  } catch (error) {
    console.error('Obsidian status error:', error);
    res.status(500).json({
      success: false,
      message: '상태 조회 실패'
    });
  }
});

/**
 * POST /api/obsidian/manual-scan
 * 수동 스캔 실행 (개발/디버그용)
 */
router.post('/manual-scan', verifyFirebaseToken, async (req, res) => {
  try {
    const { uid } = req.user;
    
    // 사용자의 현재 Vault 설정 확인
    const status = obsidianBridge.getStatus();
    const userVault = status.activeUsers.find(u => u.uid === uid);
    
    if (!userVault) {
      return res.status(400).json({
        success: false,
        message: '설정된 Vault가 없습니다. 먼저 Vault를 설정해주세요.'
      });
    }
    
    // 수동 스캔 실행
    await obsidianBridge.performInitialScan(uid, userVault.vaultPath);
    
    res.json({
      success: true,
      message: '수동 스캔이 완료되었습니다',
      data: {
        vaultPath: userVault.vaultPath,
        scanTime: new Date()
      }
    });
    
  } catch (error) {
    console.error('Manual scan error:', error);
    res.status(500).json({
      success: false,
      message: '수동 스캔 실패',
      error: error.message
    });
  }
});

/**
 * DELETE /api/obsidian/stop-watching
 * 파일 감시 중지 (전체 중지 - 관리자만)
 */
router.delete('/stop-watching', verifyFirebaseToken, async (req, res) => {
  try {
    const { uid } = req.user;
    
    // 관리자 권한 확인 (실제 구현에서는 더 세밀한 권한 체크 필요)
    if (uid !== 'dev-user-123' && !req.user.isAdmin) {
      return res.status(403).json({
        success: false,
        message: '관리자 권한이 필요합니다'
      });
    }
    
    await obsidianBridge.stopWatching();
    
    res.json({
      success: true,
      message: 'Obsidian 파일 감시가 중지되었습니다'
    });
    
  } catch (error) {
    console.error('Stop watching error:', error);
    res.status(500).json({
      success: false,
      message: '감시 중지 실패',
      error: error.message
    });
  }
});

/**
 * GET /api/obsidian/vault-info
 * Vault 정보 및 파일 통계 조회
 */
router.get('/vault-info', verifyFirebaseToken, async (req, res) => {
  try {
    const { uid } = req.user;
    const { getDB } = require('../config/database');
    const db = getDB();
    
    // 사용자의 개념 노트 통계 조회
    const conceptStats = await db.collection('concept_notes').aggregate([
      { $match: { ownerUid: uid } },
      {
        $group: {
          _id: null,
          totalNotes: { $sum: 1 },
          tagCount: { $addToSet: '$tags' },
          lastSync: { $max: '$lastSyncAt' }
        }
      }
    ]).toArray();
    
    // 태그별 통계
    const tagStats = await db.collection('concept_notes').aggregate([
      { $match: { ownerUid: uid } },
      { $unwind: '$tags' },
      { $group: { _id: '$tags', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 10 }
    ]).toArray();
    
    const stats = conceptStats[0] || { totalNotes: 0, tagCount: [], lastSync: null };
    
    res.json({
      success: true,
      data: {
        totalNotes: stats.totalNotes,
        uniqueTags: stats.tagCount.flat().length,
        lastSync: stats.lastSync,
        topTags: tagStats.map(t => ({ tag: t._id, count: t.count }))
      }
    });
    
  } catch (error) {
    console.error('Vault info error:', error);
    res.status(500).json({
      success: false,
      message: 'Vault 정보 조회 실패',
      error: error.message
    });
  }
});

module.exports = router;