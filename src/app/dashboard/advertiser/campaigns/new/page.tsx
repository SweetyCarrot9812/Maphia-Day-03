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
    max_participants: "10",
    recruitment_end: "",
    store_location: "",
    benefits: "",
    mission: "",
    image_url: "",
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
    (event: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
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

        const recruitmentEnd = new Date(formState.recruitment_end);
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        if (recruitmentEnd < today) {
          setErrorMessage("모집 마감일은 오늘 이후여야 합니다.");
          setIsSubmitting(false);
          return;
        }

        const { data: campaign, error: campaignError } = await supabase
          .from("campaigns")
          .insert({
            advertiser_id: profile.id,
            title: formState.title,
            description: formState.description,
            max_participants: parseInt(formState.max_participants),
            recruitment_start: new Date().toISOString(),
            recruitment_end: new Date(formState.recruitment_end).toISOString(),
            store_location: formState.store_location,
            benefits: formState.benefits,
            mission: formState.mission,
            image_url: formState.image_url || null,
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

          <label className="flex flex-col gap-2 text-sm text-slate-700">
            매장 위치 <span className="text-rose-500">*</span>
            <input
              type="text"
              name="store_location"
              required
              value={formState.store_location}
              onChange={handleChange}
              placeholder="예: 서울시 강남구 테헤란로 123"
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
          </label>

          <label className="flex flex-col gap-2 text-sm text-slate-700">
            이미지 URL
            <input
              type="url"
              name="image_url"
              value={formState.image_url}
              onChange={handleChange}
              placeholder="https://i.imgur.com/xxxxx.png"
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
            <span className="text-xs text-slate-500">
              imgur.com 등에 업로드한 이미지 URL을 입력하세요
            </span>
          </label>

          <label className="flex flex-col gap-2 text-sm text-slate-700">
            모집 인원 <span className="text-rose-500">*</span>
            <input
              type="number"
              name="max_participants"
              required
              min="1"
              max="100"
              value={formState.max_participants}
              onChange={handleChange}
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
          </label>

          <label className="flex flex-col gap-2 text-sm text-slate-700">
            모집 마감일 <span className="text-rose-500">*</span>
            <input
              type="date"
              name="recruitment_end"
              required
              value={formState.recruitment_end}
              onChange={handleChange}
              min={new Date().toISOString().split("T")[0]}
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
          </label>

          <label className="flex flex-col gap-2 text-sm text-slate-700">
            제공 혜택 <span className="text-rose-500">*</span>
            <textarea
              name="benefits"
              required
              value={formState.benefits}
              onChange={handleChange}
              rows={3}
              placeholder="체험단에게 제공되는 혜택을 작성해주세요"
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
          </label>

          <label className="flex flex-col gap-2 text-sm text-slate-700">
            미션 안내 <span className="text-rose-500">*</span>
            <textarea
              name="mission"
              required
              value={formState.mission}
              onChange={handleChange}
              rows={3}
              placeholder="체험단이 수행해야 할 미션을 작성해주세요"
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
          </label>

          {errorMessage && <p className="text-sm text-rose-500">{errorMessage}</p>}

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
