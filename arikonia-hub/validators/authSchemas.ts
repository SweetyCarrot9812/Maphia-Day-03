import { z } from 'zod'

export const signUpSchema = z.object({
  email: z
    .string()
    .min(1, '이메일은 필수입니다')
    .email('올바른 이메일 주소를 입력하세요'),

  password: z
    .string()
    .min(6, '비밀번호는 최소 6자 이상이어야 합니다')
    .max(100, '비밀번호는 최대 100자까지 가능합니다'),

  nickname: z
    .string()
    .min(2, '닉네임은 최소 2자 이상이어야 합니다')
    .max(20, '닉네임은 최대 20자까지 가능합니다')
    .regex(
      /^[가-힣a-zA-Z0-9_]+$/,
      '닉네임은 한글, 영문, 숫자, 언더스코어만 가능합니다'
    ),
})

export const signInSchema = z.object({
  email: z
    .string()
    .min(1, '이메일은 필수입니다')
    .email('올바른 이메일 주소를 입력하세요'),

  password: z
    .string()
    .min(1, '비밀번호는 필수입니다')
    .min(6, '비밀번호는 최소 6자 이상이어야 합니다'),
})

export type SignUpInput = z.infer<typeof signUpSchema>
export type SignInInput = z.infer<typeof signInSchema>
