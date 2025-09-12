const mongoose = require('mongoose');

const sessionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  audioReferenceId: {
    type: String,
    required: false // 실시간 튜너 세션의 경우 레퍼런스가 없을 수 있음
  },
  sessionType: {
    type: String,
    enum: ['scale_practice', 'realtime_tuner', 'vocal_coach'],
    required: true
  },
  // 정확도 관련 데이터
  accuracyMean: {
    type: Number,
    required: true,
    min: 0
  },
  accuracyMedian: {
    type: Number,
    required: true,
    min: 0
  },
  stabilitySd: {
    type: Number,
    required: true,
    min: 0
  },
  // 추가 메트릭
  totalNotes: {
    type: Number,
    required: true,
    min: 1
  },
  correctNotes: {
    type: Number,
    required: true,
    min: 0
  },
  // 세션 지속시간 (초)
  duration: {
    type: Number,
    required: true,
    min: 1
  },
  // 오디오 분석 데이터 (선택사항)
  analysisData: {
    pitchData: [Number], // 피치 데이터 배열
    timeStamps: [Number], // 타임스탬프 배열
    noteEvents: [{
      note: String,
      startTime: Number,
      endTime: Number,
      accuracy: Number
    }]
  },
  // AI 코치 피드백 (보컬 코치 세션의 경우)
  coachFeedback: {
    overallScore: Number,
    strengths: [String],
    improvements: [String],
    exercises: [String]
  },
  // 메타데이터
  metadata: {
    deviceInfo: String,
    appVersion: String,
    audioSampleRate: Number,
    notes: String
  }
}, {
  timestamps: true
});

// 복합 인덱스 (사용자별 최신 세션 조회 최적화)
sessionSchema.index({ userId: 1, createdAt: -1 });
sessionSchema.index({ sessionType: 1, createdAt: -1 });

// 가상 필드: 정확도 퍼센테이지
sessionSchema.virtual('accuracyPercentage').get(function() {
  return this.totalNotes > 0 ? (this.correctNotes / this.totalNotes) * 100 : 0;
});

// JSON 변환시 가상 필드 포함
sessionSchema.set('toJSON', { virtuals: true });

const Session = mongoose.model('Session', sessionSchema);

module.exports = Session;