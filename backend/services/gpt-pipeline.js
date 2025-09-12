/**
 * Clintest Desktop 학습 루프 v1 - GPT-5 문제 생성 파이프라인
 * 
 * 역할: 문제 생성, 태깅, 중복 검사 자동화
 * 모델: text-embedding-004 (임베딩), gpt-5-standard (생성), gpt-5-mini (태깅)
 */

const OpenAI = require('openai');
const crypto = require('crypto');
const { getDB } = require('../config/database');

class GPTPipeline {
  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    });
    
    // 모델 설정
    this.models = {
      embedding: 'text-embedding-004',
      generation: 'gpt-5', // gpt-5-standard 대신 gpt-5 사용
      tagging: 'gpt-5-mini', // 경량 태깅용
      verification: 'gpt-5-mini' // 품질 검증용
    };
    
    this.isProcessing = false;
  }

  /**
   * 재출제 큐 처리 (메인 엔트리 포인트)
   */
  async processRegenQueue() {
    if (this.isProcessing) {
      console.log('⚠️ 이미 처리 중입니다. 스킵합니다.');
      return;
    }
    
    this.isProcessing = true;
    
    try {
      const db = getDB();
      
      // pending 상태의 작업들 조회
      const pendingJobs = await db.collection('regen_queue')
        .find({ status: 'pending' })
        .sort({ createdAt: 1 })
        .limit(5) // 한 번에 5개씩 처리
        .toArray();
      
      if (pendingJobs.length === 0) {
        console.log('📝 처리할 재출제 작업이 없습니다');
        return;
      }
      
      console.log(`🚀 재출제 작업 처리 시작: ${pendingJobs.length}개`);
      
      for (const job of pendingJobs) {
        await this.processRegenJob(job);
        
        // 작업 간 짧은 대기 (API 레이트 리밋 방지)
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
      
      console.log('✅ 재출제 작업 처리 완료');
      
    } catch (error) {
      console.error('Regen queue processing error:', error);
    } finally {
      this.isProcessing = false;
    }
  }

  /**
   * 개별 재출제 작업 처리
   */
  async processRegenJob(job) {
    const db = getDB();
    
    try {
      // 작업 상태를 running으로 변경
      await db.collection('regen_queue').updateOne(
        { _id: job._id },
        { 
          $set: { 
            status: 'running',
            startedAt: new Date()
          } 
        }
      );
      
      console.log(`📋 작업 처리 시작: ${job._id} (개념: ${job.weakConcepts.join(', ')})`);
      
      // 문제 생성
      const generatedProblems = [];
      
      for (let i = 0; i < job.targetCount; i++) {
        try {
          const problem = await this.generateSingleProblem(job);
          
          if (problem) {
            // 중복 검사
            const isDuplicate = await this.checkDuplicate(job.ownerUid, problem);
            
            if (!isDuplicate) {
              generatedProblems.push(problem);
            } else {
              console.log(`⚠️ 중복 문제 감지됨 (${i + 1}번째)`);
            }
          }
          
        } catch (error) {
          console.error(`문제 생성 실패 (${i + 1}번째):`, error);
        }
        
        // API 호출 간격 조절
        await new Promise(resolve => setTimeout(resolve, 500));
      }
      
      // 생성된 문제들을 DB에 저장
      if (generatedProblems.length > 0) {
        await this.saveGeneratedProblems(job.ownerUid, generatedProblems);
      }
      
      // 작업 완료 처리
      await db.collection('regen_queue').updateOne(
        { _id: job._id },
        {
          $set: {
            status: 'done',
            completedAt: new Date(),
            generatedCount: generatedProblems.length,
            results: generatedProblems.map(p => p._id)
          }
        }
      );
      
      console.log(`✅ 작업 완료: ${job._id} (생성됨: ${generatedProblems.length}개)`);
      
    } catch (error) {
      console.error('Regen job processing error:', error);
      
      // 에러 상태로 변경
      await db.collection('regen_queue').updateOne(
        { _id: job._id },
        {
          $set: {
            status: 'error',
            error: error.message,
            errorAt: new Date()
          }
        }
      );
    }
  }

  /**
   * 단일 문제 생성
   */
  async generateSingleProblem(job) {
    try {
      const prompt = this.buildProblemGenerationPrompt(job);
      
      // GPT-5로 문제 생성
      const response = await this.openai.chat.completions.create({
        model: this.models.generation,
        messages: [
          {
            role: 'system',
            content: '당신은 의학/간호학 전문 문제 출제자입니다. 한국의 의사 및 간호사 국가고시 스타일의 5지선다 문제를 출제합니다.'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        temperature: 0.7,
        max_tokens: 1000,
        response_format: { type: 'json_object' }
      });
      
      const generatedContent = response.choices[0].message.content;
      const problemData = JSON.parse(generatedContent);
      
      // 생성된 문제 검증
      if (!this.validateProblemData(problemData)) {
        throw new Error('생성된 문제 데이터가 유효하지 않습니다');
      }
      
      // 추가 메타데이터 설정
      const problem = {
        ...problemData,
        ownerUid: job.ownerUid,
        source: 'gpt5',
        createdAt: new Date(),
        meta: {
          version: '1.0',
          generationModel: this.models.generation,
          jobId: job._id,
          generatedAt: new Date()
        }
      };
      
      // 키 해시 생성
      problem.keyHash = this.generateKeyHash(problem);
      
      // 임베딩 생성
      problem.embedding = await this.generateEmbedding(
        `${problem.stem} ${problem.choices.map(c => c.text).join(' ')}`
      );
      
      return problem;
      
    } catch (error) {
      console.error('Single problem generation error:', error);
      throw error;
    }
  }

  /**
   * 문제 생성 프롬프트 구성
   */
  buildProblemGenerationPrompt(job) {
    const concepts = job.weakConcepts.join(', ');
    const difficulty = job.difficulty || 'B1';
    const type = job.type || 'MCQ';
    
    return `
다음 개념들과 관련된 ${type} 문제를 생성해주세요:

**개념**: ${concepts}
**난이도**: ${difficulty} (A1: 쉬움, B1-B3: 보통, C1-C3: 어려움)
**문제 유형**: ${type}

**요구사항**:
1. 5지선다 문제 (정답 1개, 오답 4개)
2. 보기들은 서로 명확히 구분되며 상호배타적이어야 함
3. 정답에 대한 간단한 근거 제시 (1-2줄)
4. 한국 의료 환경과 가이드라인에 적합해야 함
5. 실제 임상 상황을 반영해야 함

**출력 형식 (JSON)**:
\`\`\`json
{
  "stem": "문제 본문",
  "choices": [
    {"text": "선택지 1", "isCorrect": true},
    {"text": "선택지 2", "isCorrect": false},
    {"text": "선택지 3", "isCorrect": false},
    {"text": "선택지 4", "isCorrect": false},
    {"text": "선택지 5", "isCorrect": false}
  ],
  "concepts": ["관련 개념 1", "관련 개념 2"],
  "difficulty": "${difficulty}",
  "type": "${type}",
  "rationale": "정답 근거 설명"
}
\`\`\`

정확하고 교육적 가치가 높은 문제를 생성해주세요.
`;
  }

  /**
   * 문제 데이터 검증
   */
  validateProblemData(data) {
    // 필수 필드 확인
    const requiredFields = ['stem', 'choices', 'concepts', 'difficulty', 'type', 'rationale'];
    
    for (const field of requiredFields) {
      if (!data[field]) {
        console.error(`Missing required field: ${field}`);
        return false;
      }
    }
    
    // 선택지 검증
    if (!Array.isArray(data.choices) || data.choices.length !== 5) {
      console.error('Choices must be an array of 5 items');
      return false;
    }
    
    // 정답 검증 (정확히 1개)
    const correctCount = data.choices.filter(c => c.isCorrect).length;
    if (correctCount !== 1) {
      console.error(`Must have exactly 1 correct answer, found ${correctCount}`);
      return false;
    }
    
    return true;
  }

  /**
   * 키 해시 생성 (중복 검사용)
   */
  generateKeyHash(problem) {
    const keyContent = [
      problem.concepts.sort().join('|'),
      problem.rationale || '',
      problem.type
    ].join('||');
    
    return crypto.createHash('sha256').update(keyContent).digest('hex');
  }

  /**
   * 텍스트 임베딩 생성
   */
  async generateEmbedding(text) {
    try {
      const response = await this.openai.embeddings.create({
        model: this.models.embedding,
        input: text,
        encoding_format: 'float'
      });
      
      return response.data[0].embedding;
      
    } catch (error) {
      console.error('Embedding generation error:', error);
      // 임베딩 실패 시 빈 배열 반환 (1536차원)
      return new Array(1536).fill(0);
    }
  }

  /**
   * 중복 검사 (키 해시 + 임베딩 유사도)
   */
  async checkDuplicate(ownerUid, problem) {
    try {
      const db = getDB();
      
      // 1. 키 해시 기반 중복 검사 (완전 동일)
      const existingProblem = await db.collection('problems').findOne({
        ownerUid: ownerUid,
        keyHash: problem.keyHash
      });
      
      if (existingProblem) {
        console.log('🔍 키 해시 중복 감지');
        return true;
      }
      
      // 2. 임베딩 유사도 검사 (TODO: 벡터 검색 구현)
      // 현재는 단순 구현, 향후 MongoDB Atlas Vector Search 사용
      const similarityThreshold = 0.08;
      
      // 캐시에서 확인
      const cacheResult = await db.collection('dup_cache').findOne({
        ownerUid: ownerUid,
        candidateKeyHash: problem.keyHash
      });
      
      if (cacheResult && cacheResult.decided) {
        return cacheResult.decided.isDup;
      }
      
      // 캐시에 결과 저장 (일단 중복 아님으로 처리)
      await db.collection('dup_cache').updateOne(
        {
          ownerUid: ownerUid,
          candidateKeyHash: problem.keyHash
        },
        {
          $set: {
            ownerUid: ownerUid,
            candidateKeyHash: problem.keyHash,
            nearest: null,
            decided: { isDup: false },
            createdAt: new Date()
          }
        },
        { upsert: true }
      );
      
      return false;
      
    } catch (error) {
      console.error('Duplicate check error:', error);
      return false; // 에러 시 중복 아님으로 처리
    }
  }

  /**
   * 생성된 문제들을 DB에 저장
   */
  async saveGeneratedProblems(ownerUid, problems) {
    try {
      const db = getDB();
      
      // _id 생성
      const { ObjectId } = require('mongodb');
      const problemsWithIds = problems.map(problem => ({
        _id: new ObjectId(),
        ...problem
      }));
      
      const insertResult = await db.collection('problems').insertMany(problemsWithIds);
      
      console.log(`✅ 문제 저장 완료: ${insertResult.insertedCount}개`);
      
      // SRS 세션에 자동 추가
      await this.addProblemsToSRS(ownerUid, problemsWithIds);
      
      return problemsWithIds;
      
    } catch (error) {
      console.error('Save problems error:', error);
      throw error;
    }
  }

  /**
   * 생성된 문제를 SRS 세션에 추가
   */
  async addProblemsToSRS(ownerUid, problems) {
    try {
      const db = getDB();
      
      // 사용자의 메인 세션 찾기 또는 생성
      let session = await db.collection('sessions').findOne({ ownerUid: ownerUid });
      
      if (!session) {
        // 새 세션 생성
        session = {
          ownerUid: ownerUid,
          items: [],
          createdAt: new Date(),
          updatedAt: new Date()
        };
        
        const insertResult = await db.collection('sessions').insertOne(session);
        session._id = insertResult.insertedId;
      }
      
      // 새 문제들을 SRS 아이템으로 추가
      const newItems = problems.map(problem => ({
        problemId: problem._id.toString(),
        dueAt: new Date(), // 즉시 출제 가능
        srsState: {
          interval: 1,
          ef: 2.5,
          streak: 0
        },
        lastResult: null,
        addedAt: new Date()
      }));
      
      await db.collection('sessions').updateOne(
        { _id: session._id },
        {
          $push: { items: { $each: newItems } },
          $set: { updatedAt: new Date() }
        }
      );
      
      console.log(`✅ SRS 세션에 ${newItems.length}개 문제 추가됨`);
      
    } catch (error) {
      console.error('Add to SRS error:', error);
    }
  }

  /**
   * 파이프라인 상태 조회
   */
  async getStatus() {
    const db = getDB();
    
    try {
      const stats = await db.collection('regen_queue').aggregate([
        {
          $group: {
            _id: '$status',
            count: { $sum: 1 }
          }
        }
      ]).toArray();
      
      const statusMap = {};
      stats.forEach(stat => {
        statusMap[stat._id] = stat.count;
      });
      
      return {
        isProcessing: this.isProcessing,
        queueStats: {
          pending: statusMap.pending || 0,
          running: statusMap.running || 0,
          done: statusMap.done || 0,
          error: statusMap.error || 0
        },
        models: this.models
      };
      
    } catch (error) {
      console.error('Get status error:', error);
      return {
        isProcessing: this.isProcessing,
        queueStats: {},
        models: this.models,
        error: error.message
      };
    }
  }
}

// 싱글톤 인스턴스
const gptPipeline = new GPTPipeline();

// 주기적 처리 (30초마다)
setInterval(() => {
  gptPipeline.processRegenQueue().catch(console.error);
}, 30000);

module.exports = gptPipeline;