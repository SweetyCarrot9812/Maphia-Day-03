/**
 * 애플리케이션 환경 변수 설정
 *
 * 필수 환경 변수가 누락된 경우 빌드 시점에 에러를 발생시켜
 * 운영 환경에서의 문제를 사전에 방지합니다.
 */

function getRequiredEnv(key: string): string {
  const value = process.env[key];

  if (!value) {
    throw new Error(
      `❌ 필수 환경 변수가 설정되지 않았습니다: ${key}\n` +
      `📝 .env.local 파일에 다음을 추가해주세요:\n` +
      `   ${key}=your_value_here\n`
    );
  }

  if (value.includes('placeholder')) {
    throw new Error(
      `❌ 환경 변수가 플레이스홀더 값으로 설정되어 있습니다: ${key}\n` +
      `📝 실제 값으로 변경해주세요.`
    );
  }

  return value;
}

export const config = {
  supabase: {
    url: getRequiredEnv('NEXT_PUBLIC_SUPABASE_URL'),
    anonKey: getRequiredEnv('NEXT_PUBLIC_SUPABASE_ANON_KEY'),
  },
} as const;
