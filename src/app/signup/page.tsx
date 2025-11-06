"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser-client";
import { useCurrentUser } from "@/features/auth/hooks/useCurrentUser";

const defaultFormState = {
  email: "",
  password: "",
  confirmPassword: "",
  name: "",
  phone: "",
  role: "" as "influencer" | "advertiser" | "",
  termsAgreed: false,
};

type SignupPageProps = {
  params: Promise<Record<string, never>>;
};

export default function SignupPage({ params }: SignupPageProps) {
  void params;
  const router = useRouter();
  const searchParams = useSearchParams();
  const { isAuthenticated, refresh } = useCurrentUser();
  const [formState, setFormState] = useState(defaultFormState);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [infoMessage, setInfoMessage] = useState<string | null>(null);

  useEffect(() => {
    if (isAuthenticated) {
      const redirectedFrom = searchParams.get("redirectedFrom") ?? "/";
      router.replace(redirectedFrom);
    }
  }, [isAuthenticated, router, searchParams]);

  const isSubmitDisabled = useMemo(
    () =>
      !formState.email.trim() ||
      !formState.password.trim() ||
      !formState.name.trim() ||
      !formState.phone.trim() ||
      !formState.role ||
      !formState.termsAgreed ||
      formState.password !== formState.confirmPassword,
    [formState]
  );

  const handleChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
      const { name, value, type } = event.target;
      const checked = (event.target as HTMLInputElement).checked;
      setFormState((previous) => ({
        ...previous,
        [name]: type === 'checkbox' ? checked : value
      }));
    },
    []
  );

  const handleSubmit = useCallback(
    async (event: React.FormEvent<HTMLFormElement>) => {
      event.preventDefault();
      setIsSubmitting(true);
      setErrorMessage(null);
      setInfoMessage(null);

      if (formState.password !== formState.confirmPassword) {
        setErrorMessage("비밀번호가 일치하지 않습니다.");
        setIsSubmitting(false);
        return;
      }

      if (!formState.termsAgreed) {
        setErrorMessage("필수 약관에 동의해주세요.");
        setIsSubmitting(false);
        return;
      }

      const supabase = getSupabaseBrowserClient();

      try {
        // 1. Supabase Auth 회원가입
        const { data: authData, error: authError } = await supabase.auth.signUp({
          email: formState.email,
          password: formState.password,
        });

        if (authError) {
          setErrorMessage(authError.message ?? "회원가입에 실패했습니다.");
          setIsSubmitting(false);
          return;
        }

        if (!authData.user) {
          setErrorMessage("사용자 생성에 실패했습니다.");
          setIsSubmitting(false);
          return;
        }

        // 2. profiles 테이블에 프로필 저장
        const { error: profileError } = await supabase
          .from('profiles')
          .insert({
            id: authData.user.id,
            name: formState.name,
            phone: formState.phone,
            email: formState.email,
            role: formState.role as "influencer" | "advertiser",
          });

        if (profileError) {
          console.error('Profile creation error:', profileError);
          setErrorMessage("프로필 생성에 실패했습니다.");
          setIsSubmitting(false);
          return;
        }

        await refresh();

        if (authData.session) {
          // 역할별 페이지로 리디렉션
          if (formState.role === 'influencer') {
            router.replace('/onboarding/influencer');
          } else {
            router.replace('/onboarding/advertiser');
          }
          return;
        }

        setInfoMessage(
          "확인 이메일을 보냈습니다. 이메일 인증 후 로그인해 주세요."
        );
        router.prefetch("/login");
        setFormState(defaultFormState);
      } catch (error) {
        console.error('Signup error:', error);
        setErrorMessage("회원가입 처리 중 문제가 발생했습니다.");
      } finally {
        setIsSubmitting(false);
      }
    },
    [formState, refresh, router]
  );

  if (isAuthenticated) {
    return null;
  }

  return (
    <div className="mx-auto flex min-h-screen w-full max-w-2xl flex-col items-center justify-center gap-10 px-6 py-16">
      <header className="flex flex-col items-center gap-3 text-center">
        <h1 className="text-3xl font-semibold">회원가입</h1>
        <p className="text-slate-500">
          체험단 서비스에 가입하고 시작하세요
        </p>
      </header>

      <form
        onSubmit={handleSubmit}
        className="w-full flex flex-col gap-6 rounded-xl border border-slate-200 p-8 shadow-sm"
      >
        {/* 이름 */}
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          이름 <span className="text-rose-500">*</span>
          <input
            type="text"
            name="name"
            required
            value={formState.name}
            onChange={handleChange}
            placeholder="홍길동"
            className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
          />
        </label>

        {/* 휴대폰번호 */}
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          휴대폰번호 <span className="text-rose-500">*</span>
          <input
            type="tel"
            name="phone"
            required
            value={formState.phone}
            onChange={handleChange}
            placeholder="010-1234-5678"
            className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
          />
        </label>

        {/* 이메일 */}
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          이메일 <span className="text-rose-500">*</span>
          <input
            type="email"
            name="email"
            autoComplete="email"
            required
            value={formState.email}
            onChange={handleChange}
            placeholder="example@email.com"
            className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
          />
        </label>

        {/* 비밀번호 */}
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          비밀번호 <span className="text-rose-500">*</span>
          <input
            type="password"
            name="password"
            autoComplete="new-password"
            required
            value={formState.password}
            onChange={handleChange}
            placeholder="8자 이상"
            className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
          />
        </label>

        {/* 비밀번호 확인 */}
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          비밀번호 확인 <span className="text-rose-500">*</span>
          <input
            type="password"
            name="confirmPassword"
            autoComplete="new-password"
            required
            value={formState.confirmPassword}
            onChange={handleChange}
            placeholder="비밀번호 재입력"
            className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
          />
        </label>

        {/* 역할 선택 */}
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          역할 선택 <span className="text-rose-500">*</span>
          <select
            name="role"
            required
            value={formState.role}
            onChange={handleChange}
            className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
          >
            <option value="">선택해주세요</option>
            <option value="influencer">인플루언서 (체험단 지원)</option>
            <option value="advertiser">광고주 (체험단 등록)</option>
          </select>
        </label>

        {/* 약관 동의 */}
        <label className="flex items-start gap-2 text-sm text-slate-700">
          <input
            type="checkbox"
            name="termsAgreed"
            checked={formState.termsAgreed}
            onChange={handleChange}
            className="mt-1"
          />
          <span>
            <span className="text-rose-500">*</span> 서비스 이용약관 및 개인정보 처리방침에 동의합니다
          </span>
        </label>

        {/* 에러/성공 메시지 */}
        {errorMessage && (
          <p className="text-sm text-rose-500">{errorMessage}</p>
        )}
        {infoMessage && (
          <p className="text-sm text-emerald-600">{infoMessage}</p>
        )}

        {/* 제출 버튼 */}
        <button
          type="submit"
          disabled={isSubmitting || isSubmitDisabled}
          className="rounded-md bg-slate-900 px-4 py-3 text-sm font-medium text-white transition hover:bg-slate-700 disabled:cursor-not-allowed disabled:bg-slate-400"
        >
          {isSubmitting ? "등록 중..." : "회원가입"}
        </button>

        {/* 로그인 링크 */}
        <p className="text-center text-xs text-slate-500">
          이미 계정이 있으신가요?{" "}
          <Link
            href="/login"
            className="font-medium text-slate-700 underline hover:text-slate-900"
          >
            로그인으로 이동
          </Link>
        </p>
      </form>
    </div>
  );
}
