"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Calendar, MapPin, Users } from "lucide-react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser-client";
import { useCurrentUser } from "@/features/auth/hooks/useCurrentUser";
import type { Database } from "@/lib/supabase/types";

type Campaign = Database["public"]["Tables"]["campaigns"]["Row"];
type AdvertiserProfile = Database["public"]["Tables"]["advertiser_profiles"]["Row"];

type CampaignDetail = Campaign & {
  advertiser: AdvertiserProfile;
};

type CampaignDetailPageProps = {
  params: Promise<{ id: string }>;
};

export default function CampaignDetailPage({ params }: CampaignDetailPageProps) {
  void params;
  const routerParams = useParams();
  const router = useRouter();
  const { user, isAuthenticated } = useCurrentUser();
  const [campaign, setCampaign] = useState<CampaignDetail | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [hasProfile, setHasProfile] = useState(false);
  const [checkingProfile, setCheckingProfile] = useState(true);

  const campaignId = routerParams.id as string;

  useEffect(() => {
    const checkInfluencerProfile = async () => {
      if (!user?.id) {
        setCheckingProfile(false);
        return;
      }

      const supabase = getSupabaseBrowserClient();
      const { data } = await supabase
        .from("influencer_profiles")
        .select("id")
        .eq("user_id", user.id)
        .single();

      setHasProfile(!!data);
      setCheckingProfile(false);
    };

    void checkInfluencerProfile();
  }, [user]);

  useEffect(() => {
    const loadCampaign = async () => {
      const supabase = getSupabaseBrowserClient();

      const { data, error } = await supabase
        .from("campaigns")
        .select(`
          *,
          advertiser:advertiser_profiles!inner(*)
        `)
        .eq("id", campaignId)
        .single();

      if (error) {
        console.error("Failed to load campaign:", error);
        setIsLoading(false);
        return;
      }

      setCampaign(data as CampaignDetail);
      setIsLoading(false);
    };

    void loadCampaign();
  }, [campaignId]);

  const handleApplyClick = useCallback(() => {
    if (!isAuthenticated) {
      router.push(`/login?redirectedFrom=/campaigns/${campaignId}`);
      return;
    }

    if (!hasProfile) {
      alert("인플루언서 정보 등록 후 지원할 수 있습니다.");
      router.push("/onboarding/influencer");
      return;
    }

    router.push(`/campaigns/${campaignId}/apply`);
  }, [isAuthenticated, hasProfile, campaignId, router]);

  if (isLoading || checkingProfile) {
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
            href="/"
            className="flex items-center gap-2 text-sm text-slate-700 hover:text-slate-900"
          >
            <ArrowLeft className="h-4 w-4" />
            목록으로
          </Link>
        </div>
      </header>

      <div className="mx-auto max-w-4xl px-6 py-10">
        {/* Campaign Hero */}
        <div className="mb-8 overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
          <div className="h-64 bg-gradient-to-br from-slate-100 to-slate-200" />

          <div className="p-8">
            {/* Status */}
            <div className="mb-4">
              <span className="rounded-full bg-emerald-50 px-3 py-1 text-sm font-medium text-emerald-700">
                모집 중
              </span>
            </div>

            {/* Title */}
            <h1 className="mb-4 text-3xl font-bold text-slate-900">
              {campaign.title}
            </h1>

            {/* Advertiser Info */}
            <div className="mb-6 flex items-center gap-2 text-sm text-slate-600">
              <span>{campaign.advertiser.business_name}</span>
              <span>•</span>
              <span className="flex items-center gap-1">
                <MapPin className="h-4 w-4" />
                {campaign.advertiser.business_location}
              </span>
            </div>

            {/* Key Info Grid */}
            <div className="mb-6 grid gap-4 rounded-lg border border-slate-200 bg-slate-50 p-6 md:grid-cols-3">
              <div className="flex items-center gap-3">
                <Users className="h-5 w-5 text-slate-500" />
                <div>
                  <p className="text-xs text-slate-500">모집 인원</p>
                  <p className="font-semibold text-slate-900">
                    {campaign.max_participants}명
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <Calendar className="h-5 w-5 text-slate-500" />
                <div>
                  <p className="text-xs text-slate-500">모집 마감</p>
                  <p className="font-semibold text-slate-900">
                    {new Date(campaign.recruitment_end).toLocaleDateString("ko-KR")}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <Calendar className="h-5 w-5 text-slate-500" />
                <div>
                  <p className="text-xs text-slate-500">체험 기간</p>
                  <p className="font-semibold text-slate-900">
                    {new Date(campaign.experience_start_date).toLocaleDateString("ko-KR")} ~{" "}
                    {new Date(campaign.experience_end_date).toLocaleDateString("ko-KR")}
                  </p>
                </div>
              </div>
            </div>

            {/* Description */}
            <div className="mb-8">
              <h2 className="mb-3 text-lg font-semibold text-slate-900">
                체험단 소개
              </h2>
              <p className="whitespace-pre-wrap text-slate-700">
                {campaign.description || "소개가 없습니다"}
              </p>
            </div>

            {/* Benefits */}
            {campaign.benefits && (
              <div className="mb-8">
                <h2 className="mb-3 text-lg font-semibold text-slate-900">
                  제공 혜택
                </h2>
                <p className="whitespace-pre-wrap text-slate-700">
                  {campaign.benefits}
                </p>
              </div>
            )}

            {/* Mission */}
            {campaign.mission_requirements && (
              <div className="mb-8">
                <h2 className="mb-3 text-lg font-semibold text-slate-900">
                  미션 안내
                </h2>
                <p className="whitespace-pre-wrap text-slate-700">
                  {campaign.mission_requirements}
                </p>
              </div>
            )}

            {/* Apply Button */}
            <button
              type="button"
              onClick={handleApplyClick}
              className="w-full rounded-md bg-slate-900 px-6 py-3 font-medium text-white transition hover:bg-slate-700"
            >
              {!isAuthenticated
                ? "로그인하고 지원하기"
                : !hasProfile
                ? "인플루언서 등록 후 지원하기"
                : "지원하기"}
            </button>
          </div>
        </div>
      </div>
    </main>
  );
}
