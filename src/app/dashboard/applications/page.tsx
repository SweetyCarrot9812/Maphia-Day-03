"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft, Calendar, Clock, CheckCircle, XCircle, AlertCircle } from "lucide-react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser-client";
import { useCurrentUser } from "@/features/auth/hooks/useCurrentUser";
import type { Database } from "@/lib/supabase/types";

type Application = Database["public"]["Tables"]["applications"]["Row"];
type Campaign = Database["public"]["Tables"]["campaigns"]["Row"];
type AdvertiserProfile = Database["public"]["Tables"]["advertiser_profiles"]["Row"];

type ApplicationWithDetails = Application & {
  campaign: Campaign & {
    advertiser: AdvertiserProfile;
  };
};

type StatusFilter = "all" | "pending" | "selected" | "rejected";

export default function MyApplicationsPage() {
  const { user } = useCurrentUser();
  const router = useRouter();
  const [applications, setApplications] = useState<ApplicationWithDetails[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("all");
  const [hasInfluencerProfile, setHasInfluencerProfile] = useState(false);
  const [checkingProfile, setCheckingProfile] = useState(true);

  useEffect(() => {
    const checkProfile = async () => {
      if (!user?.id) {
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

      if (profile?.role !== "influencer") {
        alert("인플루언서만 접근할 수 있습니다.");
        router.replace("/");
        return;
      }

      // Check influencer profile
      const { data: influencerProfile } = await supabase
        .from("influencer_profiles")
        .select("id")
        .eq("user_id", user.id)
        .single();

      if (!influencerProfile) {
        alert("인플루언서 정보를 먼저 등록해주세요.");
        router.replace("/onboarding/influencer");
        return;
      }

      setHasInfluencerProfile(true);
      setCheckingProfile(false);
    };

    void checkProfile();
  }, [user, router]);

  useEffect(() => {
    const loadApplications = async () => {
      if (!user?.id || !hasInfluencerProfile) return;

      const supabase = getSupabaseBrowserClient();

      // Get influencer profile
      const { data: influencerProfile } = await supabase
        .from("influencer_profiles")
        .select("id")
        .eq("user_id", user.id)
        .single();

      if (!influencerProfile) {
        setIsLoading(false);
        return;
      }

      // Get applications with campaign details
      const { data, error } = await supabase
        .from("applications")
        .select(`
          *,
          campaign:campaigns!inner(
            *,
            advertiser:advertiser_profiles!inner(*)
          )
        `)
        .eq("influencer_id", influencerProfile.id)
        .order("created_at", { ascending: false });

      if (error) {
        console.error("Failed to load applications:", error);
        setIsLoading(false);
        return;
      }

      setApplications(data as ApplicationWithDetails[]);
      setIsLoading(false);
    };

    void loadApplications();
  }, [user, hasInfluencerProfile]);

  const filteredApplications = useMemo(() => {
    if (statusFilter === "all") return applications;
    return applications.filter((app) => app.status === statusFilter);
  }, [applications, statusFilter]);

  const stats = useMemo(() => {
    return {
      total: applications.length,
      pending: applications.filter((app) => app.status === "pending").length,
      selected: applications.filter((app) => app.status === "selected").length,
      rejected: applications.filter((app) => app.status === "rejected").length,
    };
  }, [applications]);

  const getStatusBadge = (status: string) => {
    const badges = {
      pending: {
        text: "대기 중",
        className: "bg-yellow-50 border-yellow-200 text-yellow-700",
        icon: <Clock className="h-4 w-4" />,
      },
      selected: {
        text: "선정됨",
        className: "bg-emerald-50 border-emerald-200 text-emerald-700",
        icon: <CheckCircle className="h-4 w-4" />,
      },
      rejected: {
        text: "거절됨",
        className: "bg-rose-50 border-rose-200 text-rose-700",
        icon: <XCircle className="h-4 w-4" />,
      },
    };
    return badges[status as keyof typeof badges] || badges.pending;
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
            <h1 className="text-xl font-bold text-slate-900">내 지원 목록</h1>
          </div>
        </div>
      </header>

      <div className="mx-auto max-w-7xl px-6 py-10">
        {/* Stats Overview */}
        <section className="mb-8 grid gap-6 md:grid-cols-4">
          <div className="rounded-xl border border-slate-200 bg-white p-6">
            <p className="mb-2 text-sm text-slate-600">전체 지원</p>
            <p className="text-3xl font-bold text-slate-900">{stats.total}</p>
          </div>
          <div className="rounded-xl border border-slate-200 bg-white p-6">
            <p className="mb-2 text-sm text-slate-600">대기 중</p>
            <p className="text-3xl font-bold text-yellow-600">{stats.pending}</p>
          </div>
          <div className="rounded-xl border border-slate-200 bg-white p-6">
            <p className="mb-2 text-sm text-slate-600">선정됨</p>
            <p className="text-3xl font-bold text-emerald-600">{stats.selected}</p>
          </div>
          <div className="rounded-xl border border-slate-200 bg-white p-6">
            <p className="mb-2 text-sm text-slate-600">거절됨</p>
            <p className="text-3xl font-bold text-rose-600">{stats.rejected}</p>
          </div>
        </section>

        {/* Filter Tabs */}
        <section className="mb-6">
          <div className="flex gap-2 border-b border-slate-200">
            <button
              type="button"
              onClick={() => setStatusFilter("all")}
              className={`px-4 py-2 text-sm font-medium transition ${
                statusFilter === "all"
                  ? "border-b-2 border-slate-900 text-slate-900"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              전체 ({stats.total})
            </button>
            <button
              type="button"
              onClick={() => setStatusFilter("pending")}
              className={`px-4 py-2 text-sm font-medium transition ${
                statusFilter === "pending"
                  ? "border-b-2 border-yellow-600 text-yellow-600"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              대기 중 ({stats.pending})
            </button>
            <button
              type="button"
              onClick={() => setStatusFilter("selected")}
              className={`px-4 py-2 text-sm font-medium transition ${
                statusFilter === "selected"
                  ? "border-b-2 border-emerald-600 text-emerald-600"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              선정됨 ({stats.selected})
            </button>
            <button
              type="button"
              onClick={() => setStatusFilter("rejected")}
              className={`px-4 py-2 text-sm font-medium transition ${
                statusFilter === "rejected"
                  ? "border-b-2 border-rose-600 text-rose-600"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              거절됨 ({stats.rejected})
            </button>
          </div>
        </section>

        {/* Applications List */}
        <section>
          {filteredApplications.length === 0 ? (
            <div className="rounded-xl border border-slate-200 bg-white p-12 text-center">
              {statusFilter === "all" ? (
                <>
                  <AlertCircle className="mx-auto mb-4 h-12 w-12 text-slate-400" />
                  <p className="mb-4 text-slate-500">아직 지원한 체험단이 없습니다</p>
                  <Link
                    href="/"
                    className="inline-block rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-white transition hover:bg-slate-700"
                  >
                    체험단 둘러보기
                  </Link>
                </>
              ) : (
                <>
                  <p className="mb-4 text-slate-500">해당 상태의 지원 내역이 없습니다</p>
                  <button
                    type="button"
                    onClick={() => setStatusFilter("all")}
                    className="text-sm text-slate-700 underline hover:text-slate-900"
                  >
                    전체 보기
                  </button>
                </>
              )}
            </div>
          ) : (
            <div className="space-y-4">
              {filteredApplications.map((application) => {
                const badge = getStatusBadge(application.status);
                return (
                  <div
                    key={application.id}
                    className={`rounded-xl border p-6 ${badge.className}`}
                  >
                    <div className="mb-4 flex items-start justify-between">
                      <div className="flex-1">
                        <div className="mb-2 flex items-center gap-2">
                          {badge.icon}
                          <span className="text-sm font-medium">{badge.text}</span>
                        </div>
                        <Link
                          href={`/campaigns/${application.campaign.id}`}
                          className="mb-1 text-xl font-semibold text-slate-900 hover:underline"
                        >
                          {application.campaign.title}
                        </Link>
                        <p className="text-sm text-slate-600">
                          {application.campaign.advertiser.business_name} • {application.campaign.category}
                        </p>
                      </div>
                    </div>

                    <div className="mb-4 space-y-2 border-t border-current pt-4 text-sm opacity-70">
                      <div className="flex items-start gap-2">
                        <span className="font-medium">각오:</span>
                        <span className="flex-1">{application.motivation}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Calendar className="h-4 w-4" />
                        <span className="font-medium">방문 예정일:</span>
                        <span>
                          {new Date(application.planned_visit_date).toLocaleDateString("ko-KR")}
                        </span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Clock className="h-4 w-4" />
                        <span className="font-medium">지원일:</span>
                        <span>
                          {new Date(application.created_at).toLocaleDateString("ko-KR")}
                        </span>
                      </div>
                    </div>

                    <div className="flex items-center justify-between border-t border-current pt-4 text-xs opacity-60">
                      <span>
                        모집 마감: {new Date(application.campaign.recruitment_end_date).toLocaleDateString("ko-KR")}
                      </span>
                      <Link
                        href={`/campaigns/${application.campaign.id}`}
                        className="font-medium underline hover:opacity-100"
                      >
                        체험단 상세 보기
                      </Link>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </section>
      </div>
    </main>
  );
}
