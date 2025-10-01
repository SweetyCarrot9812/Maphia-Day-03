"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft } from "lucide-react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser-client";
import { useCurrentUser } from "@/features/auth/hooks/useCurrentUser";
import type { Database } from "@/lib/supabase/types";

type Campaign = Database["public"]["Tables"]["campaigns"]["Row"];

type CampaignApplyPageProps = {
  params: Promise<{ id: string }>;
};

export default function CampaignApplyPage({ params }: CampaignApplyPageProps) {
  void params;
  const routerParams = useParams();
  const router = useRouter();
  const { user } = useCurrentUser();
  const [campaign, setCampaign] = useState<Campaign | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [formState, setFormState] = useState({
    motivation: "",
    planned_visit_date: "",
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const campaignId = routerParams.id as string;

  useEffect(() => {
    const loadCampaign = async () => {
      const supabase = getSupabaseBrowserClient();

      const { data, error } = await supabase
        .from("campaigns")
        .select("*")
        .eq("id", campaignId)
        .single();

      if (error) {
        console.error("Failed to load campaign:", error);
        setIsLoading(false);
        return;
      }

      setCampaign(data);
      setIsLoading(false);
    };

    void loadCampaign();
  }, [campaignId]);

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
        // Get influencer profile ID
        const { data: profile, error: profileError } = await supabase
          .from("influencer_profiles")
          .select("id")
          .eq("user_id", user.id)
          .single<{ id: string }>();

        if (profileError || !profile) {
          setErrorMessage("인플루언서 프로필을 찾을 수 없습니다.");
          setIsSubmitting(false);
          return;
        }

        // Check if already applied
        const { data: existingApplication } = await supabase
          .from("applications")
          .select("id")
          .eq("campaign_id", campaignId)
          .eq("influencer_id", profile.id)
          .single();

        if (existingApplication) {
          setErrorMessage("이미 지원한 체험단입니다.");
          setIsSubmitting(false);
          return;
        }

        // Create application
        const { error: applicationError } = await supabase
          .from("applications")
          .insert<{
            campaign_id: string;
            influencer_id: string;
            motivation: string;
            visit_date: string;
          }>({
            campaign_id: campaignId,
            influencer_id: profile.id,
            motivation: formState.motivation,
            visit_date: formState.planned_visit_date,
          });

        if (applicationError) {
          console.error("Application error:", applicationError);
          setErrorMessage("지원 중 문제가 발생했습니다.");
          setIsSubmitting(false);
          return;
        }

        // Success - redirect to my applications page
        alert("지원이 완료되었습니다!");
        router.push("/dashboard/applications");
      } catch (error) {
        console.error("Submit error:", error);
        setErrorMessage("지원 처리 중 문제가 발생했습니다.");
      } finally {
        setIsSubmitting(false);
      }
    },
    [campaignId, formState, user, router]
  );

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <p className="text-slate-500">로딩 중...</p>
      </div>
    );
  }

  if (!campaign) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-center">
          <p className="mb-4 text-slate-500">체험단을 찾을 수 없습니다</p>
          <Link
            href="/"
            className="text-sm text-slate-700 underline hover:text-slate-900"
          >
            홈으로 돌아가기
          </Link>
        </div>
      </div>
    );
  }

  return (
    <main className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className="border-b border-slate-200 bg-white">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
          <Link
            href={`/campaigns/${campaignId}`}
            className="flex items-center gap-2 text-sm text-slate-700 hover:text-slate-900"
          >
            <ArrowLeft className="h-4 w-4" />
            체험단 상세로
          </Link>
        </div>
      </header>

      <div className="mx-auto max-w-2xl px-6 py-10">
        <header className="mb-8">
          <h1 className="mb-2 text-3xl font-bold text-slate-900">
            체험단 지원
          </h1>
          <p className="text-slate-600">{campaign.title}</p>
        </header>

        <form
          onSubmit={handleSubmit}
          className="flex flex-col gap-6 rounded-xl border border-slate-200 bg-white p-8 shadow-sm"
        >
          {/* Motivation */}
          <label className="flex flex-col gap-2 text-sm text-slate-700">
            각오 한마디 <span className="text-rose-500">*</span>
            <textarea
              name="motivation"
              required
              value={formState.motivation}
              onChange={handleChange}
              rows={5}
              placeholder="체험단에 지원하는 이유와 각오를 작성해주세요"
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
          </label>

          {/* Planned Visit Date */}
          <label className="flex flex-col gap-2 text-sm text-slate-700">
            방문 예정일자 <span className="text-rose-500">*</span>
            <input
              type="date"
              name="planned_visit_date"
              required
              value={formState.planned_visit_date}
              onChange={handleChange}
              min={campaign.experience_start_date}
              max={campaign.experience_end_date}
              className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
            />
            <span className="text-xs text-slate-500">
              체험 기간: {new Date(campaign.experience_start_date).toLocaleDateString("ko-KR")} ~{" "}
              {new Date(campaign.experience_end_date).toLocaleDateString("ko-KR")}
            </span>
          </label>

          {/* Error Message */}
          {errorMessage && (
            <p className="text-sm text-rose-500">{errorMessage}</p>
          )}

          {/* Submit Button */}
          <button
            type="submit"
            disabled={isSubmitting}
            className="rounded-md bg-slate-900 px-4 py-3 text-sm font-medium text-white transition hover:bg-slate-700 disabled:cursor-not-allowed disabled:bg-slate-400"
          >
            {isSubmitting ? "제출 중..." : "지원하기"}
          </button>
        </form>
      </div>
    </main>
  );
}
