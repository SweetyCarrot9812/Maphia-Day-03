/**
 * Clintest Desktop 학습 루프 v1 - MongoDB 스키마 초기화 스크립트
 * 
 * 사양: Clintest.md (라인 13-56)
 * 목적: Obsidian + GPT-5 통합 학습 시스템을 위한 데이터베이스 구조 생성
 */

require('dotenv').config();
const { MongoClient } = require('mongodb');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017';
const DATABASE_NAME = process.env.DB_NAME || 'hanoa_clintest_learning';

async function initClintestSchema() {
  const client = new MongoClient(MONGODB_URI);
  
  try {
    await client.connect();
    console.log('✅ MongoDB 연결 성공');
    
    const db = client.db(DATABASE_NAME);
    
    // 1. users 컬렉션 생성 및 인덱스
    await createUsersCollection(db);
    
    // 2. concept_notes 컬렉션 생성 및 인덱스 (Obsidian 미러링 메타 전용)
    await createConceptNotesCollection(db);
    
    // 3. problems 컬렉션 생성 및 인덱스 (GPT-5 생성 문제)
    await createProblemsCollection(db);
    
    // 4. sessions 컬렉션 생성 및 인덱스 (SRS 시스템)
    await createSessionsCollection(db);
    
    // 5. attempts 컬렉션 생성 및 인덱스 (학습 기록)
    await createAttemptsCollection(db);
    
    // 6. regen_queue 컬렉션 생성 및 인덱스 (재출제 작업)
    await createRegenQueueCollection(db);
    
    // 7. dup_cache 컬렉션 생성 및 인덱스 (중복 검사 캐시)
    await createDupCacheCollection(db);
    
    console.log('🎉 Clintest Learning Loop v1 스키마 초기화 완료!');
    
  } catch (error) {
    console.error('❌ 스키마 초기화 실패:', error);
    throw error;
  } finally {
    await client.close();
  }
}

async function createUsersCollection(db) {
  const collection = db.collection('users');
  
  // 인덱스 생성
  await collection.createIndex({ uid: 1 }, { unique: true });
  await collection.createIndex({ email: 1 });
  await collection.createIndex({ createdAt: 1 });
  
  console.log('📄 users 컬렉션 생성 완료');
  
  // 샘플 문서 구조 (실제 삽입하지 않음)
  const sampleUser = {
    // _id: ObjectId (자동 생성)
    uid: "firebase_uid_here", // Firebase UID
    email: "user@example.com",
    prefs: {
      uiLang: "ko", // 사용자 인터페이스 언어
      srsSpeed: "normal" // SRS 속도 (slow, normal, fast)
    },
    createdAt: new Date()
  };
  
  console.log('  └── 샘플 구조:', JSON.stringify(sampleUser, null, 2));
}

async function createConceptNotesCollection(db) {
  const collection = db.collection('concept_notes');
  
  // 인덱스 생성 (Obsidian 경로 기반 조회 최적화)
  await collection.createIndex({ ownerUid: 1, obsidianPath: 1 }, { unique: true });
  await collection.createIndex({ ownerUid: 1 });
  await collection.createIndex({ tags: 1 });
  await collection.createIndex({ lastSyncAt: 1 });
  
  console.log('📄 concept_notes 컬렉션 생성 완료 (Obsidian 미러링 메타 전용)');
  
  // 샘플 문서 구조
  const sampleConceptNote = {
    // _id: ObjectId (자동 생성)
    ownerUid: "firebase_uid_here",
    obsidianPath: "의학/신경과/뇌신경_기능.md", // Obsidian 파일 경로
    title: "뇌신경 기능",
    tags: ["neuro", "fundamentals", "anatomy"],
    lastSyncAt: new Date(),
    hash: "abc123def456" // 파일 내용 해시 (변경 감지용)
  };
  
  console.log('  └── 샘플 구조:', JSON.stringify(sampleConceptNote, null, 2));
}

async function createProblemsCollection(db) {
  const collection = db.collection('problems');
  
  // 인덱스 생성
  await collection.createIndex({ ownerUid: 1 });
  await collection.createIndex({ concepts: 1 });
  await collection.createIndex({ difficulty: 1 });
  await collection.createIndex({ keyHash: 1 }, { unique: true }); // 중복 방지
  await collection.createIndex({ source: 1 });
  await collection.createIndex({ createdAt: 1 });
  
  // 벡터 인덱스 (임베딩 유사도 검색용)
  try {
    await collection.createIndex(
      { embedding: "2dsphere" },
      { 
        name: "embedding_vector_index",
        background: true 
      }
    );
  } catch (error) {
    console.log('  ⚠️ 벡터 인덱스 생성 실패 (MongoDB Atlas Vector Search 필요):', error.message);
  }
  
  console.log('📄 problems 컬렉션 생성 완료 (GPT-5 생성 문제)');
  
  // 샘플 문제 구조
  const sampleProblem = {
    // _id: ObjectId (자동 생성)
    ownerUid: "firebase_uid_here",
    stem: "다음 중 고혈압의 1차 치료제로 가장 적절한 것은?", // 문제 본문
    choices: [
      { text: "ACE 억제제", isCorrect: true },
      { text: "베타 차단제", isCorrect: false },
      { text: "칼슘 채널 차단제", isCorrect: false },
      { text: "이뇨제", isCorrect: false },
      { text: "안지오텐신 수용체 차단제", isCorrect: false }
    ],
    concepts: ["cardiovascular", "hypertension", "pharmacology"], // 관련 개념
    difficulty: "B1", // A1(쉬움) - C3(어려움)
    type: "MCQ", // MCQ, Essay, Simulation, ImageMCQ
    embedding: new Array(1536).fill(0), // text-embedding-004 벡터 (1536차원)
    keyHash: "hash_of_concepts_rationale_format", // 중복 검사용 해시
    source: "gpt5", // gpt5 | manual
    createdAt: new Date(),
    meta: {
      version: "1.0",
      generationModel: "gpt-5-standard",
      rationale: "ACE 억제제는 고혈압 1차 치료제로 널리 사용됨"
    }
  };
  
  console.log('  └── 샘플 구조 (일부):', {
    stem: sampleProblem.stem,
    choicesCount: sampleProblem.choices.length,
    concepts: sampleProblem.concepts,
    difficulty: sampleProblem.difficulty
  });
}

async function createSessionsCollection(db) {
  const collection = db.collection('sessions');
  
  // 인덱스 생성 (SRS 시스템 최적화)
  await collection.createIndex({ ownerUid: 1 });
  await collection.createIndex({ "items.dueAt": 1 }); // SRS 스케줄링용
  await collection.createIndex({ "items.problemId": 1 });
  await collection.createIndex({ updatedAt: 1 });
  
  console.log('📄 sessions 컬렉션 생성 완료 (SRS 시스템)');
  
  // 샘플 세션 구조
  const sampleSession = {
    // _id: ObjectId (자동 생성)
    ownerUid: "firebase_uid_here",
    items: [
      {
        problemId: "problem_object_id_here",
        dueAt: new Date(), // 다음 출제 예정 시간
        srsState: {
          interval: 1, // 현재 간격 (일)
          ef: 2.5, // 용이도 계수
          streak: 0 // 연속 정답 횟수
        },
        lastResult: "Again" // "Again" | "Good"
      }
    ],
    createdAt: new Date(),
    updatedAt: new Date()
  };
  
  console.log('  └── 샘플 구조:', JSON.stringify(sampleSession.items[0], null, 2));
}

async function createAttemptsCollection(db) {
  const collection = db.collection('attempts');
  
  // 인덱스 생성 (학습 분석용)
  await collection.createIndex({ ownerUid: 1 });
  await collection.createIndex({ problemId: 1 });
  await collection.createIndex({ ownerUid: 1, problemId: 1 });
  await collection.createIndex({ at: 1 }); // 시간순 정렬
  await collection.createIndex({ isCorrect: 1 });
  
  console.log('📄 attempts 컬렉션 생성 완료 (학습 기록)');
  
  // 샘플 시도 기록
  const sampleAttempt = {
    // _id: ObjectId (자동 생성)
    ownerUid: "firebase_uid_here",
    problemId: "problem_object_id_here",
    chosenIndex: 0, // 선택한 보기 인덱스
    isCorrect: true, // 정답 여부
    latencyMs: 15000, // 응답 시간 (밀리초)
    at: new Date(), // 시도 시각
    explainSeen: false, // 해설 확인 여부
    weakConcepts: ["pharmacology"] // 이 문제에서 드러난 취약 개념
  };
  
  console.log('  └── 샘플 구조:', JSON.stringify(sampleAttempt, null, 2));
}

async function createRegenQueueCollection(db) {
  const collection = db.collection('regen_queue');
  
  // 인덱스 생성 (재출제 작업 관리)
  await collection.createIndex({ ownerUid: 1 });
  await collection.createIndex({ status: 1 });
  await collection.createIndex({ createdAt: 1 });
  await collection.createIndex({ weakConcepts: 1 });
  
  console.log('📄 regen_queue 컬렉션 생성 완료 (재출제 작업)');
  
  // 샘플 재출제 작업
  const sampleRegenJob = {
    // _id: ObjectId (자동 생성)
    ownerUid: "firebase_uid_here",
    weakConcepts: ["cardiovascular", "pharmacology"], // 취약 개념들
    targetCount: 5, // 생성할 문제 수
    contextRefs: {
      obsidianNoteIds: ["concept_note_id_1", "concept_note_id_2"] // 참고할 개념 노트
    },
    status: "pending", // pending | running | done | error
    createdAt: new Date(),
    error: null // 오류 발생시 오류 메시지
  };
  
  console.log('  └── 샘플 구조:', JSON.stringify(sampleRegenJob, null, 2));
}

async function createDupCacheCollection(db) {
  const collection = db.collection('dup_cache');
  
  // 인덱스 생성 (중복 검사 캐시)
  await collection.createIndex({ ownerUid: 1, candidateKeyHash: 1 }, { unique: true });
  await collection.createIndex({ createdAt: 1 });
  
  console.log('📄 dup_cache 컬렉션 생성 완료 (중복 검사 캐시)');
  
  // 샘플 중복 검사 캐시
  const sampleDupCache = {
    // _id: ObjectId (자동 생성)
    ownerUid: "firebase_uid_here",
    candidateKeyHash: "hash_of_new_problem", // 새 문제의 키 해시
    nearest: {
      problemId: "existing_problem_id",
      dist: 0.05 // 코사인 거리 (0-1, 낮을수록 유사)
    },
    decided: {
      isDup: false // 중복 판정 결과
    },
    createdAt: new Date()
  };
  
  console.log('  └── 샘플 구조:', JSON.stringify(sampleDupCache, null, 2));
}

// 스크립트 실행
if (require.main === module) {
  initClintestSchema()
    .then(() => {
      console.log('🚀 Clintest Learning Loop v1 데이터베이스 준비 완료!');
      console.log('');
      console.log('다음 단계:');
      console.log('1. Obsidian 브리지 구현');
      console.log('2. GPT-5 문제 생성 파이프라인');
      console.log('3. 이중 중복검사 시스템');
      console.log('4. SRS 알고리즘 구현');
      process.exit(0);
    })
    .catch(error => {
      console.error('💥 초기화 실패:', error);
      process.exit(1);
    });
}

module.exports = {
  initClintestSchema
};