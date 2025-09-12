/**
 * Clintest Desktop 학습 루프 v1 - 이중 중복검사 시스템
 * 
 * 역할: 임베딩 유사도 + 키해시 기반 문제 중복 검사
 * 원칙: 의미적 중복 방지, 품질 관리 자동화
 */

const { getDB } = require('../config/database');
const crypto = require('crypto');

class DuplicateDetector {
  constructor() {
    this.similarityThreshold = 0.08; // 코사인 거리 임계값
    this.keyHashStrict = true; // 키해시 엄격 모드
  }

  /**
   * 종합 중복 검사 (키해시 + 임베딩 유사도)
   */
  async checkDuplicate(ownerUid, candidateProblem) {
    try {
      const db = getDB();
      
      // 1단계: 키해시 기반 완전 중복 검사
      const keyHashResult = await this.checkKeyHashDuplicate(ownerUid, candidateProblem);
      
      if (keyHashResult.isDuplicate) {
        return {
          isDuplicate: true,
          reason: 'identical_key_hash',
          similarity: 1.0,
          existingProblem: keyHashResult.existingProblem,
          method: 'key_hash'
        };
      }
      
      // 2단계: 임베딩 유사도 검사
      const embeddingResult = await this.checkEmbeddingSimilarity(ownerUid, candidateProblem);
      
      if (embeddingResult.isDuplicate) {
        return {
          isDuplicate: true,
          reason: 'semantic_similarity',
          similarity: embeddingResult.similarity,
          existingProblem: embeddingResult.nearestProblem,
          method: 'embedding',
          threshold: this.similarityThreshold
        };
      }
      
      // 중복 아님 - 캐시에 결과 저장
      await this.cacheResult(ownerUid, candidateProblem, {
        isDup: false,
        checkedAt: new Date(),
        methods: ['key_hash', 'embedding']
      });
      
      return {
        isDuplicate: false,
        reason: 'no_duplicate_found',
        similarity: embeddingResult.similarity,
        method: 'both'
      };
      
    } catch (error) {
      console.error('Duplicate check error:', error);
      
      // 에러 시 보수적으로 중복 아님으로 처리
      return {
        isDuplicate: false,
        reason: 'check_error',
        error: error.message,
        method: 'error_fallback'
      };
    }
  }

  /**
   * 키해시 기반 완전 중복 검사
   */
  async checkKeyHashDuplicate(ownerUid, candidateProblem) {
    try {
      const db = getDB();
      
      // 키해시 생성
      const keyHash = this.generateKeyHash(candidateProblem);
      
      // DB에서 동일한 키해시 검색
      const existingProblem = await db.collection('problems').findOne({
        ownerUid: ownerUid,
        keyHash: keyHash
      });
      
      return {
        isDuplicate: !!existingProblem,
        existingProblem: existingProblem,
        keyHash: keyHash
      };
      
    } catch (error) {
      console.error('Key hash duplicate check error:', error);
      return { isDuplicate: false };
    }
  }

  /**
   * 임베딩 유사도 기반 검사
   */
  async checkEmbeddingSimilarity(ownerUid, candidateProblem) {
    try {
      const db = getDB();
      
      // 후보 문제 임베딩 준비
      const candidateEmbedding = candidateProblem.embedding;
      
      if (!candidateEmbedding || !Array.isArray(candidateEmbedding)) {
        console.log('⚠️ 후보 문제에 유효한 임베딩이 없습니다');
        return { isDuplicate: false, similarity: 0 };
      }
      
      // 캐시에서 기존 결과 확인
      const candidateKeyHash = this.generateKeyHash(candidateProblem);
      const cachedResult = await this.getCachedResult(ownerUid, candidateKeyHash);
      
      if (cachedResult && cachedResult.decided) {
        return {
          isDuplicate: cachedResult.decided.isDup,
          similarity: cachedResult.nearest?.similarity || 0,
          nearestProblem: cachedResult.nearest?.problem,
          fromCache: true
        };
      }
      
      // MongoDB Atlas Vector Search를 사용할 수 있다면 사용
      // 현재는 단순한 전수조사 방식으로 구현
      const similarProblems = await this.findSimilarProblems(
        ownerUid, 
        candidateEmbedding,
        this.similarityThreshold
      );
      
      if (similarProblems.length > 0) {
        const mostSimilar = similarProblems[0];
        
        // 캐시에 결과 저장
        await this.cacheResult(ownerUid, candidateProblem, {
          isDup: true,
          nearest: {
            problemId: mostSimilar._id,
            similarity: mostSimilar.similarity,
            problem: mostSimilar
          },
          checkedAt: new Date()
        });
        
        return {
          isDuplicate: true,
          similarity: mostSimilar.similarity,
          nearestProblem: mostSimilar
        };
      }
      
      return { isDuplicate: false, similarity: 0 };
      
    } catch (error) {
      console.error('Embedding similarity check error:', error);
      return { isDuplicate: false, similarity: 0 };
    }
  }

  /**
   * 유사한 문제 찾기 (전수조사 방식 - 향후 벡터 인덱스로 최적화 필요)
   */
  async findSimilarProblems(ownerUid, candidateEmbedding, threshold) {
    try {
      const db = getDB();
      
      // 기존 문제들 조회 (최근 1000개만 - 성능 고려)
      const existingProblems = await db.collection('problems')
        .find({ 
          ownerUid: ownerUid,
          embedding: { $exists: true, $ne: null }
        })
        .sort({ createdAt: -1 })
        .limit(1000)
        .toArray();
      
      const similarProblems = [];
      
      for (const problem of existingProblems) {
        if (!problem.embedding || !Array.isArray(problem.embedding)) {
          continue;
        }
        
        // 코사인 유사도 계산
        const similarity = this.calculateCosineSimilarity(
          candidateEmbedding, 
          problem.embedding
        );
        
        // 코사인 거리로 변환 (1 - similarity)
        const distance = 1 - similarity;
        
        // 임계값보다 작으면 (즉, 유사도가 높으면) 중복으로 판정
        if (distance < threshold) {
          similarProblems.push({
            ...problem,
            similarity: similarity,
            distance: distance
          });
        }
      }
      
      // 유사도 순으로 정렬
      similarProblems.sort((a, b) => b.similarity - a.similarity);
      
      return similarProblems;
      
    } catch (error) {
      console.error('Find similar problems error:', error);
      return [];
    }
  }

  /**
   * 코사인 유사도 계산
   */
  calculateCosineSimilarity(vectorA, vectorB) {
    try {
      if (vectorA.length !== vectorB.length) {
        throw new Error('Vector dimensions do not match');
      }
      
      let dotProduct = 0;
      let normA = 0;
      let normB = 0;
      
      for (let i = 0; i < vectorA.length; i++) {
        dotProduct += vectorA[i] * vectorB[i];
        normA += vectorA[i] * vectorA[i];
        normB += vectorB[i] * vectorB[i];
      }
      
      normA = Math.sqrt(normA);
      normB = Math.sqrt(normB);
      
      if (normA === 0 || normB === 0) {
        return 0;
      }
      
      return dotProduct / (normA * normB);
      
    } catch (error) {
      console.error('Cosine similarity calculation error:', error);
      return 0;
    }
  }

  /**
   * 키해시 생성
   */
  generateKeyHash(problem) {
    try {
      // 정규화된 키 요소들
      const normalizedConcepts = (problem.concepts || [])
        .map(c => c.toLowerCase().trim())
        .sort()
        .join('|');
      
      const normalizedRationale = (problem.rationale || '')
        .toLowerCase()
        .replace(/\s+/g, ' ')
        .trim();
      
      const normalizedType = (problem.type || 'MCQ').toUpperCase();
      
      // 키 문자열 생성
      const keyString = `${normalizedConcepts}||${normalizedRationale}||${normalizedType}`;
      
      // SHA-256 해시 생성
      return crypto.createHash('sha256').update(keyString).digest('hex');
      
    } catch (error) {
      console.error('Key hash generation error:', error);
      return '';
    }
  }

  /**
   * 캐시된 결과 조회
   */
  async getCachedResult(ownerUid, candidateKeyHash) {
    try {
      const db = getDB();
      
      const cachedResult = await db.collection('dup_cache').findOne({
        ownerUid: ownerUid,
        candidateKeyHash: candidateKeyHash
      });
      
      return cachedResult;
      
    } catch (error) {
      console.error('Get cached result error:', error);
      return null;
    }
  }

  /**
   * 중복검사 결과를 캐시에 저장
   */
  async cacheResult(ownerUid, candidateProblem, result) {
    try {
      const db = getDB();
      
      const candidateKeyHash = this.generateKeyHash(candidateProblem);
      
      await db.collection('dup_cache').updateOne(
        {
          ownerUid: ownerUid,
          candidateKeyHash: candidateKeyHash
        },
        {
          $set: {
            ownerUid: ownerUid,
            candidateKeyHash: candidateKeyHash,
            nearest: result.nearest || null,
            decided: {
              isDup: result.isDup,
              checkedAt: result.checkedAt || new Date(),
              methods: result.methods || ['unknown']
            },
            createdAt: new Date()
          }
        },
        { upsert: true }
      );
      
    } catch (error) {
      console.error('Cache result error:', error);
    }
  }

  /**
   * 설정 업데이트
   */
  updateSettings(settings) {
    if (typeof settings.similarityThreshold === 'number' && 
        settings.similarityThreshold >= 0 && 
        settings.similarityThreshold <= 1) {
      this.similarityThreshold = settings.similarityThreshold;
    }
    
    if (typeof settings.keyHashStrict === 'boolean') {
      this.keyHashStrict = settings.keyHashStrict;
    }
    
    console.log('✅ 중복검사 설정 업데이트:', {
      similarityThreshold: this.similarityThreshold,
      keyHashStrict: this.keyHashStrict
    });
  }

  /**
   * 캐시 정리 (오래된 항목 삭제)
   */
  async cleanupCache(maxAge = 30) { // 30일
    try {
      const db = getDB();
      
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - maxAge);
      
      const deleteResult = await db.collection('dup_cache').deleteMany({
        createdAt: { $lt: cutoffDate }
      });
      
      console.log(`🧹 중복검사 캐시 정리 완료: ${deleteResult.deletedCount}개 삭제`);
      
      return deleteResult.deletedCount;
      
    } catch (error) {
      console.error('Cache cleanup error:', error);
      return 0;
    }
  }

  /**
   * 통계 조회
   */
  async getStats(ownerUid) {
    try {
      const db = getDB();
      
      const [cacheStats, recentDuplicates] = await Promise.all([
        // 캐시 통계
        db.collection('dup_cache').aggregate([
          { $match: ownerUid ? { ownerUid } : {} },
          {
            $group: {
              _id: '$decided.isDup',
              count: { $sum: 1 }
            }
          }
        ]).toArray(),
        
        // 최근 중복 발견 사례
        db.collection('dup_cache').find(
          Object.assign(
            { 'decided.isDup': true },
            ownerUid ? { ownerUid } : {}
          )
        )
        .sort({ createdAt: -1 })
        .limit(10)
        .toArray()
      ]);
      
      const stats = {
        duplicatesFound: 0,
        uniqueProblems: 0
      };
      
      cacheStats.forEach(stat => {
        if (stat._id === true) {
          stats.duplicatesFound = stat.count;
        } else if (stat._id === false) {
          stats.uniqueProblems = stat.count;
        }
      });
      
      return {
        ...stats,
        totalChecks: stats.duplicatesFound + stats.uniqueProblems,
        duplicateRate: stats.duplicatesFound / (stats.duplicatesFound + stats.uniqueProblems) || 0,
        recentDuplicates: recentDuplicates.length,
        settings: {
          similarityThreshold: this.similarityThreshold,
          keyHashStrict: this.keyHashStrict
        }
      };
      
    } catch (error) {
      console.error('Get stats error:', error);
      return {
        duplicatesFound: 0,
        uniqueProblems: 0,
        totalChecks: 0,
        duplicateRate: 0,
        recentDuplicates: 0,
        error: error.message
      };
    }
  }
}

// 싱글톤 인스턴스
const duplicateDetector = new DuplicateDetector();

module.exports = duplicateDetector;