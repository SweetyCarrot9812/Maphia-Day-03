"use client";

import { useCallback, useState } from "react";
import { useRouter } from "next/navigation";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser-client";
import { useCurrentUser } from "@/features/auth/hooks/useCurrentUser";

export default function AdvertiserOnboardingPage() {
  const router = useRouter();
  const { user } = useCurrentUser();
  const [formState, setFormState] = useState({
    businessName: "",
    businessLocation: "",
    businessCategory: "",
    businessRegistrationNumber: "",
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
      const { name, value } = event.target;
      setFormState((prev) => ({ ...prev, [name]: value }));
    },
    []
  );

  const handleSubmit = useCallback(
    async (event: React.FormEvent<HTMLFormElement>) => {
      event.preventDefault();
      setIsSubmitting(true);
      setErrorMessage(null);

      if (!user?.id) {
        setErrorMessage("로그인 정보를 찾을 수 없습니다.");
        setIsSubmitting(false);
        return;
      }

      const supabase = getSupabaseBrowserClient();

      try {
        const { error } = await supabase.from("advertiser_profiles").insert({
          user_id: user.id,
          business_name: formState.businessName,
          business_location: formState.businessLocation,
          business_category: formState.businessCategory,
          business_registration_number: formState.businessRegistrationNumber,
        });

        if (error) {
          console.error("Advertiser profile creation error:", error);

          if (error.code === '23505') { // Unique constraint violation
            setErrorMessage("이미 등록된 사업자등록번호입니다.");
          } else {
            setErrorMessage("광고주 프로필 생성에 실패했습니다.");
          }
          setIsSubmitting(false);
          return;
        }

        // 홈으로 리디렉션
        router.replace("/");
      } catch (error) {
        console.error("Onboarding error:", error);
        setErrorMessage("정보 등록 중 문제가 발생했습니다.");
      } finally {
        setIsSubmitting(false);
      }
    },
    [formState, user, router]
  );

  return (
    <div className="mx-auto flex min-h-screen w-full max-w-2xl flex-col items-center justify-center gap-10 px-6 py-16">
      <header className="flex flex-col items-center gap-3 text-center">
        <h1 className="text-3xl font-semibold">광고주 정보 등록</h1>
        <p className="text-slate-500">
          체험단을 등록하기 위해 사업자 정보를 입력해주세요
        </p>
      </header>

      <form
        onSubmit={handleSubmit}
        className="w-full flex flex-col gap-6 rounded-xl border border-slate-200 p-8 shadow-sm"
      >
        {/* 업체명 */}
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          업체명 <span className="text-rose-500">*</span>
          <input
            type="text"
            name="businessName"
            required
            value={formState.businessName}
            onChange={handleChange}
            placeholder="예) 맛있는 카페"
            className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
          />
        </label>

        {/* 위치 */}
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          매장 위치 <span className="text-rose-500">*</span>
          <input
            type="text"
            name="businessLocation"
            required
            value={formState.businessLocation}
            onChange={handleChange}
            placeholder="예) 서울시 강남구 역삼동 123-45"
            className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
          />
        </label>

        {/* 카테고리 */}
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          업종 카테고리 <span className="text-rose-500">*</span>
          <select
            name="businessCategory"
            required
            value={formState.businessCategory}
            onChange={handleChange}
            className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
          >
            <option value="">선택해주세요</option>
            <option value="음식점">음식점</option>
            <option value="카페">카페</option>
            <option value="뷰티/미용">뷰티/미용</option>
            <option value="패션">패션</option>
            <option value="건강/피트니스">건강/피트니스</option>
            <option value="문화/여가">문화/여가</option>
            <option value="교육">교육</option>
            <option value="기타">기타</option>
          </select>
        </label>

        {/* 사업자등록번호 */}
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          사업자등록번호 <span className="text-rose-500">*</span>
          <input
            type="text"
            name="businessRegistrationNumber"
            required
            value={formState.businessRegistrationNumber}
            onChange={handleChange}
            placeholder="123-45-67890 (10자리)"
            maxLength={12}
            className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
          />
          <span className="text-xs text-slate-500">
            사업자등록번호는 검증 후 체험단 등록이 가능합니다.
          </span>
        </label>

        {/* 에러 메시지 */}
        {errorMessage && (
          <p className="text-sm text-rose-500">{errorMessage}</p>
        )}

        {/* 제출 버튼 */}
        <button
          type="submit"
          disabled={isSubmitting}
          className="rounded-md bg-slate-900 px-4 py-3 text-sm font-medium text-white transition hover:bg-slate-700 disabled:cursor-not-allowed disabled:bg-slate-400"
        >
          {isSubmitting ? "등록 중..." : "정보 등록 완료"}
        </button>
      </form>
    </div>
  );
}
