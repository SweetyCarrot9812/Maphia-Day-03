const mongoose = require('mongoose');

const voiceTypeEnum = ['soprano', 'mezzo', 'alto', 'tenor', 'baritone', 'bass', 'unknown'];
const difficultyLevelEnum = ['beginner', 'intermediate', 'advanced', 'expert'];

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/, 'Please enter a valid email']
  },
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: [3, 'Username must be at least 3 characters'],
    match: [/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers and underscores']
  },
  displayName: {
    type: String,
    required: true,
    trim: true,
    minlength: [2, 'Display name must be at least 2 characters']
  },
  password: {
    type: String,
    required: true,
    minlength: [8, 'Password must be at least 8 characters']
  },
  profileImage: {
    type: String,
    default: null
  },
  voiceType: {
    type: String,
    enum: voiceTypeEnum,
    default: 'unknown'
  },
  skillLevel: {
    type: String,
    enum: difficultyLevelEnum,
    default: 'beginner'
  },
  isEmailVerified: {
    type: Boolean,
    default: false
  },
  preferences: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
    default: {}
  },
  lastLoginAt: {
    type: Date,
    default: null
  }
}, {
  timestamps: true, // createdAt, updatedAt 자동 생성
  toJSON: {
    transform: function(doc, ret) {
      // 비밀번호는 응답에서 제외
      delete ret.password;
      return ret;
    }
  }
});

// 이메일과 사용자명 인덱스는 unique: true로 자동 생성됨

// 비밀번호 해싱 미들웨어
const bcrypt = require('bcryptjs');

userSchema.pre('save', async function(next) {
  // 비밀번호가 변경되지 않았으면 건너뛰기
  if (!this.isModified('password')) return next();
  
  try {
    // 비밀번호 해싱 (salt rounds: 12)
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// 비밀번호 검증 메서드
userSchema.methods.comparePassword = async function(candidatePassword) {
  try {
    return await bcrypt.compare(candidatePassword, this.password);
  } catch (error) {
    throw error;
  }
};

// 마지막 로그인 시간 업데이트 메서드
userSchema.methods.updateLastLogin = function() {
  this.lastLoginAt = new Date();
  return this.save();
};

const User = mongoose.model('User', userSchema);

module.exports = User;