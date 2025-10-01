"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft, Plus, Calendar, Users, CheckCircle, XCircle } from "lucide-react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser-client";
import { useCurrentUser } from "@/features/auth/hooks/useCurrentUser";
import type { Database } from "@/lib/supabase/types";

type Campaign = Database["public"]["Tables"]["campaigns"]["Row"];
type Application = Database["public"]["Tables"]["applications"]["Row"];

type CampaignWithStats = Campaign & {
  application_count: number;
  selected_count: number;
  rejected_count: number;
};

export default function AdvertiserDashboardPage() {
  const { user } = useCurrentUser();
  const router = useRouter();
  const [campaigns, setCampaigns] = useState<CampaignWithStats[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [hasAdvertiserProfile, setHasAdvertiserProfile] = useState(false);
  const [checkingProfile, setCheckingProfile] = useState(true);

  useEffect(() => {
    const checkProfile = async () => {
      if (!user?.id) {
        setCheckingProfile(false);
        router.replace("/login");
        return;
      }

      const supabase = getSupabaseBrowserClient();

      // Check user role
      const { data: profile } = await supabase
        .from("profiles")
        .select("role")
        .eq("id", user.id)
        .single();

      if (profile?.role !== "advertiser") {
        alert("광고주만 접근할 수 있습니다.");
        router.replace("/");
        return;
      }

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

  useEffect(() => {
    const loadCampaigns = async () => {
      if (!user?.id || !hasAdvertiserProfile) return;

      const supabase = getSupabaseBrowserClient();

      // Get advertiser profile
      const { data: advertiserProfile } = await supabase
        .from("advertiser_profiles")
        .select("id")
        .eq("user_id", user.id)
        .single();

      if (!advertiserProfile) {
        setIsLoading(false);
        return;
      }

      // Get campaigns with application counts
      const { data: campaignsData, error } = await supabase
        .from("campaigns")
        .select(`
          *,
          applications(id, status)
        `)
        .eq("advertiser_id", advertiserProfile.id)
        .order("created_at", { ascending: false });

      if (error) {
        console.error("Failed to load campaigns:", error);
        setIsLoading(false);
        return;
      }

      // Process campaigns to add stats
      const campaignsWithStats = campaignsData.map((campaign) => {
        const applications = campaign.applications as Application[];
        return {
          ...campaign,
          applications: undefined, // Remove nested applications
          application_count: applications.length,
          selected_count: applications.filter((app) => app.status === "selected").length,
          rejected_count: applications.filter((app) => app.status === "rejected").length,
        } as CampaignWithStats;
      });

      setCampaigns(campaignsWithStats);
      setIsLoading(false);
    };

    void loadCampaigns();
  }, [user, hasAdvertiserProfile]);

  const getStatusBadge = (status: string) => {
    const badges = {
      recruiting: {
        text: "모집 중",
        className: "bg-emerald-50 text-emerald-700",
      },
      closed: {
        text: "모집 마감",
        className: "bg-slate-100 text-slate-700",
      },
      selected: {
        text: "선정 완료",
        className: "bg-blue-50 text-blue-700",
      },
      completed: {
        text: "체험 완료",
        className: "bg-purple-50 text-purple-700",
      },
    };

    const badge = badges[status as keyof typeof badges] || badges.recruiting;
    return (
      <span className={`rounded-full px-3 py-1 text-xs font-medium ${badge.className}`}>
        {badge.text}
      </span>
    );
  };

  if (checkingProfile || isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <p className="text-slate-500">로딩 중...</p>
      </div>
    );
  }

  return (
    <main className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className="border-b border-slate-200 bg-white">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
          <div className="flex items-center gap-4">
            <Link
              href="/"
              className="flex items-center gap-2 text-sm text-slate-700 hover:text-slate-900"
            >
              <ArrowLeft className="h-4 w-4" />
              홈으로
            </Link>
            <h1 className="text-xl font-bold text-slate-900">광고주 대시보드</h1>
          </div>
          <Link
            href="/dashboard/advertiser/campaigns/new"
            className="flex items-center gap-2 rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-white transition hover:bg-slate-700"
          >
            <Plus className="h-4 w-4" />
            새 캠페인 등록
          </Link>
        </div>
      </header>

      <div className="mx-auto max-w-7xl px-6 py-10">
        {/* Stats Overview */}
        <section className="mb-8 grid gap-6 md:grid-cols-4">
          <div className="rounded-xl border border-slate-200 bg-white p-6">
            <p className="mb-2 text-sm text-slate-600">전체 캠페인</p>
            <p className="text-3xl font-bold text-slate-900">{campaigns.length}</p>
          </div>
          <div className="rounded-xl border border-slate-200 bg-white p-6">
            <p className="mb-2 text-sm text-slate-600">모집 중</p>
            <p className="text-3xl font-bold text-emerald-600">
              {campaigns.filter((c) => c.status === "recruiting").length}
            </p>
          </div>
          <div className="rounded-xl border border-slate-200 bg-white p-6">
            <p className="mb-2 text-sm text-slate-600">선정 대기</p>
            <p className="text-3xl font-bold text-blue-600">
              {campaigns.filter((c) => c.status === "closed").length}
            </p>
          </div>
          <div className="rounded-xl border border-slate-200 bg-white p-6">
            <p className="mb-2 text-sm text-slate-600">진행 중</p>
            <p className="text-3xl font-bold text-purple-600">
              {campaigns.filter((c) => c.status === "selected").length}
            </p>
          </div>
        </section>

        {/* Campaigns List */}
        <section>
          <h2 className="mb-6 text-2xl font-bold text-slate-900">내 캠페인</h2>

          {campaigns.length === 0 ? (
            <div className="rounded-xl border border-slate-200 bg-white p-12 text-center">
              <p className="mb-4 text-slate-500">등록된 캠페인이 없습니다</p>
              <Link
                href="/dashboard/advertiser/campaigns/new"
                className="inline-flex items-center gap-2 text-sm text-slate-700 underline hover:text-slate-900"
              >
                <Plus className="h-4 w-4" />
                첫 캠페인 등록하기
              </Link>
            </div>
          ) : (
            <div className="space-y-4">
              {campaigns.map((campaign) => (
                <Link
                  key={campaign.id}
                  href={`/dashboard/advertiser/campaigns/${campaign.id}`}
                  className="block rounded-xl border border-slate-200 bg-white p-6 transition hover:shadow-md"
                >
                  <div className="mb-4 flex items-start justify-between">
                    <div className="flex-1">
                      <div className="mb-2 flex items-center gap-3">
                        {getStatusBadge(campaign.status)}
                        <span className="text-sm text-slate-500">{campaign.store_location}</span>
                      </div>
                      <h3 className="mb-2 text-xl font-semibold text-slate-900">
                        {campaign.title}
                      </h3>
                      <p className="line-clamp-2 text-sm text-slate-600">
                        {campaign.description || "설명이 없습니다"}
                      </p>
                    </div>
                  </div>

                  <div className="grid gap-4 border-t border-slate-100 pt-4 md:grid-cols-4">
                    <div className="flex items-center gap-2 text-sm">
                      <Users className="h-4 w-4 text-slate-400" />
                      <span className="text-slate-600">
                        목표: {campaign.max_participants}명
                      </span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <Calendar className="h-4 w-4 text-slate-400" />
                      <span className="text-slate-600">
                        지원: {campaign.application_count}건
                      </span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <CheckCircle className="h-4 w-4 text-emerald-500" />
                      <span className="text-slate-600">
                        선정: {campaign.selected_count}명
                      </span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <XCircle className="h-4 w-4 text-rose-500" />
                      <span className="text-slate-600">
                        거절: {campaign.rejected_count}명
                      </span>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          )}
        </section>
      </div>
    </main>
  );
}
