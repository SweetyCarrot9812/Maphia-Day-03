"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Calendar, Users, CheckCircle, XCircle, Clock } from "lucide-react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser-client";
import { useCurrentUser } from "@/features/auth/hooks/useCurrentUser";
import type { Database } from "@/lib/supabase/types";

type Campaign = Database["public"]["Tables"]["campaigns"]["Row"];
type Application = Database["public"]["Tables"]["applications"]["Row"];
type InfluencerProfile = Database["public"]["Tables"]["influencer_profiles"]["Row"];
type Profile = Database["public"]["Tables"]["profiles"]["Row"];

type ApplicationWithInfluencer = Application & {
  influencer: InfluencerProfile & {
    profile: Profile;
  };
};

type CampaignDetailPageProps = {
  params: Promise<{ id: string }>;
};

export default function AdvertiserCampaignDetailPage({ params }: CampaignDetailPageProps) {
  void params;
  const routerParams = useParams();
  const router = useRouter();
  const { user } = useCurrentUser();
  const [campaign, setCampaign] = useState<Campaign | null>(null);
  const [applications, setApplications] = useState<ApplicationWithInfluencer[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isClosing, setIsClosing] = useState(false);

  const campaignId = routerParams.id as string;

  useEffect(() => {
    const loadCampaignData = async () => {
      if (!user?.id) return;

      const supabase = getSupabaseBrowserClient();

      // Get advertiser profile
      const { data: advertiserProfile } = await supabase
        .from("advertiser_profiles")
        .select("id")
        .eq("user_id", user.id)
        .single();

      if (!advertiserProfile) {
        alert("광고주 정보를 찾을 수 없습니다.");
        router.replace("/dashboard/advertiser");
        return;
      }

      // Get campaign
      const { data: campaignData, error: campaignError } = await supabase
        .from("campaigns")
        .select("*")
        .eq("id", campaignId)
        .eq("advertiser_id", advertiserProfile.id)
        .single();

      if (campaignError || !campaignData) {
        alert("캠페인을 찾을 수 없습니다.");
        router.replace("/dashboard/advertiser");
        return;
      }

      setCampaign(campaignData);

      // Get applications
      const { data: applicationsData, error: applicationsError } = await supabase
        .from("applications")
        .select(`
          *,
          influencer:influencer_profiles!inner(
            *,
            profile:profiles!inner(*)
          )
        `)
        .eq("campaign_id", campaignId)
        .order("created_at", { ascending: false });

      if (applicationsError) {
        console.error("Failed to load applications:", applicationsError);
      } else {
        setApplications(applicationsData as ApplicationWithInfluencer[]);
      }

      setIsLoading(false);
    };

    void loadCampaignData();
  }, [campaignId, user, router]);

  const handleCloseCampaign = useCallback(async () => {
    if (!confirm("모집을 마감하시겠습니까? 마감 후에는 지원자를 선정할 수 있습니다.")) {
      return;
    }

    setIsClosing(true);
    const supabase = getSupabaseBrowserClient();

    const { error } = await supabase
      .from("campaigns")
      .update({ status: "closed" })
      .eq("id", campaignId);

    if (error) {
      alert("모집 마감에 실패했습니다.");
      console.error(error);
    } else {
      setCampaign((prev) => (prev ? { ...prev, status: "closed" } : null));
      alert("모집이 마감되었습니다.");
    }

    setIsClosing(false);
  }, [campaignId]);

  const handleApplicationStatus = useCallback(
    async (applicationId: string, newStatus: "selected" | "rejected") => {
      const supabase = getSupabaseBrowserClient();

      const { error } = await supabase
        .from("applications")
        .update({ status: newStatus })
        .eq("id", applicationId);

      if (error) {
        alert("상태 변경에 실패했습니다.");
        console.error(error);
        return;
      }

      setApplications((prev) =>
        prev.map((app) =>
          app.id === applicationId ? { ...app, status: newStatus } : app
        )
      );

      // Check if we should update campaign status to "selected"
      const updatedApplications = applications.map((app) =>
        app.id === applicationId ? { ...app, status: newStatus } : app
      );
      const selectedCount = updatedApplications.filter(
        (app) => app.status === "selected"
      ).length;

      if (
        selectedCount > 0 &&
        campaign?.status === "closed" &&
        selectedCount <= (campaign?.target_participants || 0)
      ) {
        const { error: campaignError } = await supabase
          .from("campaigns")
          .update({ status: "selected" })
          .eq("id", campaignId);

        if (!campaignError) {
          setCampaign((prev) => (prev ? { ...prev, status: "selected" } : null));
        }
      }
    },
    [campaignId, campaign, applications]
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
          <p className="mb-4 text-slate-500">캠페인을 찾을 수 없습니다</p>
          <Link
            href="/dashboard/advertiser"
            className="text-sm text-slate-700 underline hover:text-slate-900"
          >
            대시보드로 돌아가기
          </Link>
        </div>
      </div>
    );
  }

  const pendingApplications = applications.filter((app) => app.status === "pending");
  const selectedApplications = applications.filter((app) => app.status === "selected");
  const rejectedApplications = applications.filter((app) => app.status === "rejected");

  const getStatusBadge = (status: string) => {
    const badges = {
      recruiting: { text: "모집 중", className: "bg-emerald-50 text-emerald-700" },
      closed: { text: "모집 마감", className: "bg-slate-100 text-slate-700" },
      selected: { text: "선정 완료", className: "bg-blue-50 text-blue-700" },
      completed: { text: "체험 완료", className: "bg-purple-50 text-purple-700" },
    };
    const badge = badges[status as keyof typeof badges] || badges.recruiting;
    return (
      <span className={`rounded-full px-3 py-1 text-xs font-medium ${badge.className}`}>
        {badge.text}
      </span>
    );
  };

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

      <div className="mx-auto max-w-7xl px-6 py-10">
        {/* Campaign Info */}
        <section className="mb-8 rounded-xl border border-slate-200 bg-white p-8">
          <div className="mb-6 flex items-start justify-between">
            <div>
              <div className="mb-3 flex items-center gap-3">
                {getStatusBadge(campaign.status)}
                <span className="text-sm text-slate-500">{campaign.category}</span>
              </div>
              <h1 className="mb-2 text-3xl font-bold text-slate-900">{campaign.title}</h1>
              <p className="text-slate-600">{campaign.description}</p>
            </div>
            {campaign.status === "recruiting" && (
              <button
                type="button"
                onClick={handleCloseCampaign}
                disabled={isClosing}
                className="rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-white transition hover:bg-slate-700 disabled:cursor-not-allowed disabled:bg-slate-400"
              >
                {isClosing ? "마감 중..." : "모집 마감"}
              </button>
            )}
          </div>

          <div className="grid gap-4 md:grid-cols-4">
            <div className="flex items-center gap-3 rounded-lg border border-slate-100 bg-slate-50 p-4">
              <Users className="h-5 w-5 text-slate-500" />
              <div>
                <p className="text-xs text-slate-500">목표 인원</p>
                <p className="font-semibold text-slate-900">{campaign.target_participants}명</p>
              </div>
            </div>
            <div className="flex items-center gap-3 rounded-lg border border-slate-100 bg-slate-50 p-4">
              <Clock className="h-5 w-5 text-slate-500" />
              <div>
                <p className="text-xs text-slate-500">총 지원</p>
                <p className="font-semibold text-slate-900">{applications.length}건</p>
              </div>
            </div>
            <div className="flex items-center gap-3 rounded-lg border border-slate-100 bg-emerald-50 p-4">
              <CheckCircle className="h-5 w-5 text-emerald-600" />
              <div>
                <p className="text-xs text-emerald-700">선정</p>
                <p className="font-semibold text-emerald-900">{selectedApplications.length}명</p>
              </div>
            </div>
            <div className="flex items-center gap-3 rounded-lg border border-slate-100 bg-rose-50 p-4">
              <XCircle className="h-5 w-5 text-rose-600" />
              <div>
                <p className="text-xs text-rose-700">거절</p>
                <p className="font-semibold text-rose-900">{rejectedApplications.length}명</p>
              </div>
            </div>
          </div>
        </section>

        {/* Applications */}
        <section>
          <h2 className="mb-6 text-2xl font-bold text-slate-900">
            지원자 관리 ({applications.length}명)
          </h2>

          {applications.length === 0 ? (
            <div className="rounded-xl border border-slate-200 bg-white p-12 text-center">
              <p className="text-slate-500">아직 지원자가 없습니다</p>
            </div>
          ) : (
            <div className="space-y-4">
              {/* Pending Applications */}
              {pendingApplications.length > 0 && (
                <div>
                  <h3 className="mb-3 text-lg font-semibold text-slate-900">
                    대기 중 ({pendingApplications.length})
                  </h3>
                  {pendingApplications.map((application) => (
                    <ApplicationCard
                      key={application.id}
                      application={application}
                      onStatusChange={handleApplicationStatus}
                      canManage={campaign.status !== "recruiting"}
                    />
                  ))}
                </div>
              )}

              {/* Selected Applications */}
              {selectedApplications.length > 0 && (
                <div>
                  <h3 className="mb-3 text-lg font-semibold text-emerald-900">
                    선정됨 ({selectedApplications.length})
                  </h3>
                  {selectedApplications.map((application) => (
                    <ApplicationCard
                      key={application.id}
                      application={application}
                      onStatusChange={handleApplicationStatus}
                      canManage={campaign.status !== "recruiting"}
                    />
                  ))}
                </div>
              )}

              {/* Rejected Applications */}
              {rejectedApplications.length > 0 && (
                <div>
                  <h3 className="mb-3 text-lg font-semibold text-slate-600">
                    거절됨 ({rejectedApplications.length})
                  </h3>
                  {rejectedApplications.map((application) => (
                    <ApplicationCard
                      key={application.id}
                      application={application}
                      onStatusChange={handleApplicationStatus}
                      canManage={campaign.status !== "recruiting"}
                    />
                  ))}
                </div>
              )}
            </div>
          )}
        </section>
      </div>
    </main>
  );
}

function ApplicationCard({
  application,
  onStatusChange,
  canManage,
}: {
  application: ApplicationWithInfluencer;
  onStatusChange: (id: string, status: "selected" | "rejected") => void;
  canManage: boolean;
}) {
  const getStatusColor = (status: string) => {
    switch (status) {
      case "pending":
        return "bg-yellow-50 border-yellow-200 text-yellow-700";
      case "selected":
        return "bg-emerald-50 border-emerald-200 text-emerald-700";
      case "rejected":
        return "bg-rose-50 border-rose-200 text-rose-700";
      default:
        return "bg-slate-50 border-slate-200 text-slate-700";
    }
  };

  return (
    <div className={`mb-3 rounded-xl border p-6 ${getStatusColor(application.status)}`}>
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <div className="mb-3 flex items-center gap-3">
            <h4 className="font-semibold text-slate-900">
              {application.influencer.profile.name}
            </h4>
            <span className="text-sm text-slate-600">
              {application.influencer.profile.email}
            </span>
          </div>

          <div className="mb-3 space-y-2 text-sm">
            <div>
              <span className="font-medium text-slate-700">각오: </span>
              <span className="text-slate-600">{application.motivation}</span>
            </div>
            <div>
              <span className="font-medium text-slate-700">방문 예정일: </span>
              <span className="text-slate-600">
                {new Date(application.planned_visit_date).toLocaleDateString("ko-KR")}
              </span>
            </div>
            <div>
              <span className="font-medium text-slate-700">지원일: </span>
              <span className="text-slate-600">
                {new Date(application.created_at).toLocaleDateString("ko-KR")}
              </span>
            </div>
          </div>
        </div>

        {canManage && application.status === "pending" && (
          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => onStatusChange(application.id, "selected")}
              className="rounded-md bg-emerald-600 px-4 py-2 text-sm font-medium text-white transition hover:bg-emerald-700"
            >
              선정
            </button>
            <button
              type="button"
              onClick={() => onStatusChange(application.id, "rejected")}
              className="rounded-md bg-rose-600 px-4 py-2 text-sm font-medium text-white transition hover:bg-rose-700"
            >
              거절
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
