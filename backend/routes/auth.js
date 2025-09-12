const express = require('express');
const User = require('../models/User');
const { generateToken } = require('../middleware/auth');
const { authenticateToken } = require('../middleware/auth');
const { registerValidation, loginValidation, changePasswordValidation } = require('../middleware/validation');

const router = express.Router();

// 회원가입
router.post('/register', registerValidation, async (req, res) => {
  try {
    const { email, username, displayName, password } = req.body;

    // 이메일 중복 확인
    const existingUserByEmail = await User.findOne({ email });
    if (existingUserByEmail) {
      return res.status(409).json({
        success: false,
        message: '이미 사용 중인 이메일입니다',
        field: 'email'
      });
    }

    // 사용자명 중복 확인
    const existingUserByUsername = await User.findOne({ username });
    if (existingUserByUsername) {
      return res.status(409).json({
        success: false,
        message: '이미 사용 중인 사용자명입니다',
        field: 'username'
      });
    }

    // 새 사용자 생성
    const newUser = new User({
      email,
      username,
      displayName,
      password // 비밀번호는 User 모델의 pre-save 훅에서 자동으로 해싱됨
    });

    await newUser.save();

    // JWT 토큰 생성
    const token = generateToken(newUser._id);

    // 응답 (비밀번호 제외)
    const userResponse = newUser.toJSON();
    
    res.status(201).json({
      success: true,
      message: '회원가입이 완료되었습니다',
      user: userResponse,
      token
    });

  } catch (error) {
    console.error('Registration error:', error);
    
    // MongoDB 중복 키 에러 처리
    if (error.code === 11000) {
      const field = Object.keys(error.keyValue)[0];
      return res.status(409).json({
        success: false,
        message: `이미 사용 중인 ${field === 'email' ? '이메일' : '사용자명'}입니다`,
        field
      });
    }

    res.status(500).json({
      success: false,
      message: '회원가입 중 오류가 발생했습니다'
    });
  }
});

// 로그인
router.post('/login', loginValidation, async (req, res) => {
  try {
    const { email, password } = req.body;

    // 사용자 찾기 (비밀번호 포함)
    const user = await User.findOne({ email }).select('+password');
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: '이메일 또는 비밀번호가 올바르지 않습니다'
      });
    }

    // 비밀번호 검증
    const isPasswordValid = await user.comparePassword(password);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: '이메일 또는 비밀번호가 올바르지 않습니다'
      });
    }

    // 마지막 로그인 시간 업데이트
    await user.updateLastLogin();

    // JWT 토큰 생성
    const token = generateToken(user._id);

    // 응답 (비밀번호 제외)
    const userResponse = user.toJSON();

    res.json({
      success: true,
      message: '로그인 성공',
      user: userResponse,
      token
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: '로그인 중 오류가 발생했습니다'
    });
  }
});

// 비밀번호 변경
router.put('/change-password', authenticateToken, changePasswordValidation, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = req.user._id;

    // 현재 사용자 조회 (비밀번호 포함)
    const user = await User.findById(userId).select('+password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: '사용자를 찾을 수 없습니다'
      });
    }

    // 현재 비밀번호 검증
    const isCurrentPasswordValid = await user.comparePassword(currentPassword);
    
    if (!isCurrentPasswordValid) {
      return res.status(400).json({
        success: false,
        message: '현재 비밀번호가 올바르지 않습니다'
      });
    }

    // 새 비밀번호 저장 (pre-save 훅에서 자동 해싱)
    user.password = newPassword;
    await user.save();

    res.json({
      success: true,
      message: '비밀번호가 성공적으로 변경되었습니다'
    });

  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      message: '비밀번호 변경 중 오류가 발생했습니다'
    });
  }
});

// 토큰 검증 (프론트엔드에서 토큰 유효성 확인용)
router.get('/verify', authenticateToken, (req, res) => {
  res.json({
    success: true,
    message: '토큰이 유효합니다',
    user: req.user
  });
});

module.exports = router;