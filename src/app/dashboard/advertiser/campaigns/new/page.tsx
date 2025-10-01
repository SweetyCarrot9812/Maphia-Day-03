"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft } from "lucide-react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser-client";
import { useCurrentUser } from "@/features/auth/hooks/useCurrentUser";

export default function NewCampaignPage() {
  const { user } = useCurrentUser();
  const router = useRouter();
  const [formState, setFormState] = useState({
    title: "",
    description: "",
    category: "",
    target_participants: "10",
    recruitment_end_date: "",
    experience_start_date: "",
    experience_end_date: "",
    benefits: "",
    mission_requirements: "",
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [hasAdvertiserProfile, setHasAdvertiserProfile] = useState(false);
  const [checkingProfile, setCheckingProfile] = useState(true);

  useEffect(() => {
    const checkProfile = async () => {
      if (!user?.id) {
        router.replace("/login");
        return;
      }

      const supabase = getSupabaseBrowserClient();

      // Check advertiser profile
      const { data: advertiserProfile } = await supabase
        .from("advertiser_profiles")
        .select("id")
        .eq("user_id", user.id)
        .single();

      if (!advertiserProfile) {
        alert("광고주 정보를 먼저 등록해주세요.");
        router.replace("/onboarding/advertiser");
        return;
      }

      setHasAdvertiserProfile(true);
      setCheckingProfile(false);
    };

    void checkProfile();
  }, [user, router]);

  const handleChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
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
        // Get advertiser profile ID
        const { data: profile, error: profileError } = await supabase
          .from("advertiser_profiles")
          .select("id")
          .eq("user_id", user.id)
          .single();

        if (profileError || !profile) {
          setErrorMessage("광고주 프로필을 찾을 수 없습니다.");
          setIsSubmitting(false);
          return;
        }

        // Validate dates
        const recruitmentEnd = new Date(formState.recruitment_end_date);
        const experienceStart = new Date(formState.experience_start_date);
        const experienceEnd = new Date(formState.experience_end_date);
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        if (recruitmentEnd < today) {
          setErrorMessage("모집 마감일은 오늘 이후여야 합니다.");
          setIsSubmitting(false);
          return;
        }

        if (experienceStart <= recruitmentEnd) {
          setErrorMessage("체험 시작일은 모집 마감일 이후여야 합니다.");
          setIsSubmitting(false);
          return;
        }

        if (experienceEnd <= experienceStart) {
          setErrorMessage("체험 종료일은 시작일 이후여야 합니다.");
          setIsSubmitting(false);
          return;
        }

        // Create campaign
        const { data: campaign, error: campaignError } = await supabase
          .from("campaigns")
          .insert({
            advertiser_id: profile.id,
            title: formState.title,
            description: formState.description,
            category: formState.category,
            target_participants: parseInt(formState.target_participants),
            recruitment_end_date: formState.recruitment_end_date,
            experience_start_date: formState.experience_start_date,
            experience_end_date: formState.experience_end_date,
            benefits: formState.benefits || null,
            mission_requirements: formState.mission_requirements || null,
            status: "recruiting",
          })
          .select()
          .single();

        if (campaignError) {
          console.error("Campaign creation error:", campaignError);
          setErrorMessage("캠페인 등록 중 문제가 발생했습니다.");
          setIsSubmitting(false);
          return;
        }

        // Success - redirect to campaign detail
        alert("캠페인이 등록되었습니다!");
        router.push(`/dashboard/advertiser/campaigns/${campaign.id}`);
      } catch (error) {
        console.error("Submit error:", error);
        setErrorMessage("캠페인 등록 처리 중 문제가 발생했습니다.");
      } finally {
        setIsSubmitting(false);
      }
    },
    [formState, user, router]
  );

  if (checkingProfile) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <p className="text-slate-500">로딩 중...</p>
      </div>
    );
  }

  if (!hasAdvertiserProfile) {
    return null;
  }

  return (
    <main className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className="border-b border-slate-200 bg-white">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
          <Link
            href="/dashboard/advertiser"
            className="flex items-center gap-2 text-sm text-slate-700 hover:text-slate-900"
          >
            <ArrowLeft className="h-4 w-4" />
            대시보드로
          </Link>
        </div>
      </header>

      <div className="mx-auto max-w-3xl px-6 py-10">
        <header className="mb-8">
          <h1 className="mb-2 text-3xl font-bold text-slate-900">새 캠페인 등록</h1>
          <p className="text-slate-600">체험단 캠페인 정보를 입력해주세요</p>
        </header>

        <form
          onSubmit={handleSubmit}
          className="flex flex-col gap-6 rounded-xl border border-slate-200 bg-white p-8 shadow-sm"
        >
          {/* Title */}
          <label className="flex flex-col gap-2 text-sm text-slate-700">
            캠페인 제목 <span className="text-rose-500">*</span>
            <input
              type="text"
              name="title"
              required
              value={formState.title}
              onChange={handleChange}
              placeholder="예: 신제품 블로그 체험단 모집"
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
          </label>

          {/* Category */}
          <label className="flex flex-col gap-2 text-sm text-slate-700">
            카테고리 <span className="text-rose-500">*</span>
            <select
              name="category"
              required
              value={formState.category}
              onChange={handleChange}
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            >
              <option value="">선택해주세요</option>
              <option value="식품">식품</option>
              <option value="뷰티">뷰티</option>
              <option value="패션">패션</option>
              <option value="생활용품">생활용품</option>
              <option value="가전">가전</option>
              <option value="IT/전자">IT/전자</option>
              <option value="여행">여행</option>
              <option value="레저/스포츠">레저/스포츠</option>
              <option value="교육">교육</option>
              <option value="기타">기타</option>
            </select>
          </label>

          {/* Description */}
          <label className="flex flex-col gap-2 text-sm text-slate-700">
            캠페인 설명 <span className="text-rose-500">*</span>
            <textarea
              name="description"
              required
              value={formState.description}
              onChange={handleChange}
              rows={5}
              placeholder="캠페인에 대한 상세한 설명을 작성해주세요"
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
          </label>

          {/* Target Participants */}
          <label className="flex flex-col gap-2 text-sm text-slate-700">
            모집 인원 <span className="text-rose-500">*</span>
            <input
              type="number"
              name="target_participants"
              required
              min="1"
              max="100"
              value={formState.target_participants}
              onChange={handleChange}
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
          </label>

          {/* Recruitment End Date */}
          <label className="flex flex-col gap-2 text-sm text-slate-700">
            모집 마감일 <span className="text-rose-500">*</span>
            <input
              type="date"
              name="recruitment_end_date"
              required
              value={formState.recruitment_end_date}
              onChange={handleChange}
              min={new Date().toISOString().split("T")[0]}
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
          </label>

          {/* Experience Dates */}
          <div className="grid gap-4 md:grid-cols-2">
            <label className="flex flex-col gap-2 text-sm text-slate-700">
              체험 시작일 <span className="text-rose-500">*</span>
              <input
                type="date"
                name="experience_start_date"
                required
                value={formState.experience_start_date}
                onChange={handleChange}
                min={formState.recruitment_end_date || new Date().toISOString().split("T")[0]}
                className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
              />
            </label>

            <label className="flex flex-col gap-2 text-sm text-slate-700">
              체험 종료일 <span className="text-rose-500">*</span>
              <input
                type="date"
                name="experience_end_date"
                required
                value={formState.experience_end_date}
                onChange={handleChange}
                min={formState.experience_start_date || new Date().toISOString().split("T")[0]}
                className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
              />
            </label>
          </div>

          {/* Benefits */}
          <label className="flex flex-col gap-2 text-sm text-slate-700">
            제공 혜택
            <textarea
              name="benefits"
              value={formState.benefits}
              onChange={handleChange}
              rows={3}
              placeholder="체험단에게 제공되는 혜택을 작성해주세요 (선택사항)"
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
          </label>

          {/* Mission Requirements */}
          <label className="flex flex-col gap-2 text-sm text-slate-700">
            미션 안내
            <textarea
              name="mission_requirements"
              value={formState.mission_requirements}
              onChange={handleChange}
              rows={3}
              placeholder="체험단이 수행해야 할 미션을 작성해주세요 (선택사항)"
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
          </label>

          {/* Error Message */}
          {errorMessage && <p className="text-sm text-rose-500">{errorMessage}</p>}

          {/* Submit Button */}
          <button
            type="submit"
            disabled={isSubmitting}
            className="rounded-md bg-slate-900 px-4 py-3 text-sm font-medium text-white transition hover:bg-slate-700 disabled:cursor-not-allowed disabled:bg-slate-400"
          >
            {isSubmitting ? "등록 중..." : "캠페인 등록"}
          </button>
        </form>
      </div>
    </main>
  );
}
