/**
 * 애플리케이션 환경 변수 설정
 *
 * 개발 환경에서는 .env.local 사용
 * 프로덕션 환경에서는 Vercel 환경 변수 사용
 */

function getEnv(key: string, fallback: string = ''): string {
  const value = process.env[key];

  // 개발 환경: 환경 변수 없으면 경고만 출력
  if (process.env.NODE_ENV === 'development' && !value) {
    console.warn(`⚠️ 환경 변수 누락: ${key} - .env.local 파일을 확인하세요.`);
    return fallback;
  }

  // 프로덕션: 환경 변수 없으면 에러
  if (process.env.NODE_ENV === 'production' && !value) {
    console.error(`❌ 필수 환경 변수 누락: ${key}`);
    return fallback;
  }

  return value || fallback;
}

// Supabase 설정 - 환경 변수에서 가져오거나 빈 문자열
export const config = {
  supabase: {
    url: getEnv('NEXT_PUBLIC_SUPABASE_URL'),
    anonKey: getEnv('NEXT_PUBLIC_SUPABASE_ANON_KEY'),
  },
} as const;
