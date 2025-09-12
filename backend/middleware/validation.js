const Joi = require('joi');

// 회원가입 데이터 검증
const registerValidation = (req, res, next) => {
  const schema = Joi.object({
    email: Joi.string()
      .email()
      .required()
      .messages({
        'string.email': '유효한 이메일 주소를 입력해주세요',
        'any.required': '이메일은 필수 항목입니다'
      }),
    username: Joi.string()
      .min(3)
      .max(30)
      .pattern(/^[a-zA-Z0-9_]+$/)
      .required()
      .messages({
        'string.min': '사용자명은 최소 3자 이상이어야 합니다',
        'string.max': '사용자명은 최대 30자까지 가능합니다',
        'string.pattern.base': '사용자명은 영문, 숫자, 밑줄(_)만 사용할 수 있습니다',
        'any.required': '사용자명은 필수 항목입니다'
      }),
    displayName: Joi.string()
      .min(2)
      .max(50)
      .required()
      .messages({
        'string.min': '표시 이름은 최소 2자 이상이어야 합니다',
        'string.max': '표시 이름은 최대 50자까지 가능합니다',
        'any.required': '표시 이름은 필수 항목입니다'
      }),
    password: Joi.string()
      .min(8)
      .max(128)
      .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      .required()
      .messages({
        'string.min': '비밀번호는 최소 8자 이상이어야 합니다',
        'string.max': '비밀번호는 최대 128자까지 가능합니다',
        'string.pattern.base': '비밀번호는 영문 대소문자와 숫자를 포함해야 합니다',
        'any.required': '비밀번호는 필수 항목입니다'
      })
  });

  const { error } = schema.validate(req.body);
  
  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message,
      field: error.details[0].path[0]
    });
  }
  
  next();
};

// 로그인 데이터 검증
const loginValidation = (req, res, next) => {
  const schema = Joi.object({
    email: Joi.string()
      .email()
      .required()
      .messages({
        'string.email': '유효한 이메일 주소를 입력해주세요',
        'any.required': '이메일은 필수 항목입니다'
      }),
    password: Joi.string()
      .required()
      .messages({
        'any.required': '비밀번호는 필수 항목입니다'
      })
  });

  const { error } = schema.validate(req.body);
  
  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message,
      field: error.details[0].path[0]
    });
  }
  
  next();
};

// 프로필 업데이트 검증
const updateProfileValidation = (req, res, next) => {
  const schema = Joi.object({
    displayName: Joi.string()
      .min(2)
      .max(50)
      .optional()
      .messages({
        'string.min': '표시 이름은 최소 2자 이상이어야 합니다',
        'string.max': '표시 이름은 최대 50자까지 가능합니다'
      }),
    voiceType: Joi.string()
      .valid('soprano', 'mezzo', 'alto', 'tenor', 'baritone', 'bass', 'unknown')
      .optional(),
    skillLevel: Joi.string()
      .valid('beginner', 'intermediate', 'advanced', 'expert')
      .optional(),
    preferences: Joi.object()
      .optional()
  });

  const { error } = schema.validate(req.body);
  
  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message,
      field: error.details[0].path[0]
    });
  }
  
  next();
};

// 비밀번호 변경 검증
const changePasswordValidation = (req, res, next) => {
  const schema = Joi.object({
    currentPassword: Joi.string()
      .required()
      .messages({
        'any.required': '현재 비밀번호는 필수 항목입니다'
      }),
    newPassword: Joi.string()
      .min(8)
      .max(128)
      .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      .required()
      .messages({
        'string.min': '새 비밀번호는 최소 8자 이상이어야 합니다',
        'string.max': '새 비밀번호는 최대 128자까지 가능합니다',
        'string.pattern.base': '새 비밀번호는 영문 대소문자와 숫자를 포함해야 합니다',
        'any.required': '새 비밀번호는 필수 항목입니다'
      })
  });

  const { error } = schema.validate(req.body);
  
  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message,
      field: error.details[0].path[0]
    });
  }
  
  next();
};

// 세션 저장 검증
const sessionValidation = (req, res, next) => {
  const schema = Joi.object({
    sessionType: Joi.string()
      .valid('scale_practice', 'realtime_tuner', 'vocal_coach')
      .required(),
    accuracyMean: Joi.number()
      .min(0)
      .required(),
    accuracyMedian: Joi.number()
      .min(0)
      .required(),
    stabilitySd: Joi.number()
      .min(0)
      .required(),
    totalNotes: Joi.number()
      .integer()
      .min(1)
      .required(),
    correctNotes: Joi.number()
      .integer()
      .min(0)
      .required(),
    duration: Joi.number()
      .min(1)
      .required(),
    audioReferenceId: Joi.string()
      .optional(),
    analysisData: Joi.object({
      pitchData: Joi.array().items(Joi.number()),
      timeStamps: Joi.array().items(Joi.number()),
      noteEvents: Joi.array().items(Joi.object({
        note: Joi.string(),
        startTime: Joi.number(),
        endTime: Joi.number(),
        accuracy: Joi.number()
      }))
    }).optional(),
    coachFeedback: Joi.object({
      overallScore: Joi.number(),
      strengths: Joi.array().items(Joi.string()),
      improvements: Joi.array().items(Joi.string()),
      exercises: Joi.array().items(Joi.string())
    }).optional(),
    metadata: Joi.object().optional()
  });

  const { error } = schema.validate(req.body);
  
  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message,
      field: error.details[0].path[0]
    });
  }
  
  next();
};

module.exports = {
  registerValidation,
  loginValidation,
  updateProfileValidation,
  changePasswordValidation,
  sessionValidation
};