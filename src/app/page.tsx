"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { LogOut, Search } from "lucide-react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser-client";
import { useCurrentUser } from "@/features/auth/hooks/useCurrentUser";
import type { Database } from "@/lib/supabase/types";

type Campaign = Database["public"]["Tables"]["campaigns"]["Row"];
type Profile = Database["public"]["Tables"]["profiles"]["Row"];

type CampaignWithAdvertiser = Campaign & {
  advertiser: {
    business_name: string;
  };
};

export default function Home() {
  const { user, isAuthenticated, isLoading, refresh } = useCurrentUser();
  const router = useRouter();
  const [campaigns, setCampaigns] = useState<CampaignWithAdvertiser[]>([]);
  const [isLoadingCampaigns, setIsLoadingCampaigns] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [categoryFilter, setCategoryFilter] = useState<string>("");

  useEffect(() => {
    const loadCampaigns = async () => {
      const supabase = getSupabaseBrowserClient();

      const { data, error } = await supabase
        .from("campaigns")
        .select(`
          *,
          advertiser:advertiser_profiles!inner(business_name)
        `)
        .eq("status", "recruiting")
        .order("created_at", { ascending: false });

      if (error) {
        console.error("Failed to load campaigns:", error);
        setIsLoadingCampaigns(false);
        return;
      }

      setCampaigns(data as CampaignWithAdvertiser[]);
      setIsLoadingCampaigns(false);
    };

    void loadCampaigns();
  }, []);

  const handleSignOut = useCallback(async () => {
    const supabase = getSupabaseBrowserClient();
    await supabase.auth.signOut();
    await refresh();
    router.replace("/");
  }, [refresh, router]);

  const filteredCampaigns = useMemo(() => {
    return campaigns.filter((campaign) => {
      const matchesSearch =
        searchQuery === "" ||
        campaign.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        campaign.description?.toLowerCase().includes(searchQuery.toLowerCase());

      const matchesCategory =
        categoryFilter === "" || campaign.category === categoryFilter;

      return matchesSearch && matchesCategory;
    });
  }, [campaigns, searchQuery, categoryFilter]);

  const categories = useMemo(() => {
    const uniqueCategories = new Set(campaigns.map((c) => c.category));
    return Array.from(uniqueCategories).sort();
  }, [campaigns]);

  const authActions = useMemo(() => {
    if (isLoading) {
      return <span className="text-sm text-slate-500">로딩 중...</span>;
    }

    if (isAuthenticated && user) {
      return (
        <div className="flex items-center gap-3 text-sm">
          <span className="text-slate-700">{user.email}</span>
          <Link
            href="/dashboard"
            className="rounded-md border border-slate-300 px-3 py-1.5 transition hover:bg-slate-50"
          >
            대시보드
          </Link>
          <button
            type="button"
            onClick={handleSignOut}
            className="flex items-center gap-1 rounded-md bg-slate-900 px-3 py-1.5 text-white transition hover:bg-slate-700"
          >
            <LogOut className="h-4 w-4" />
            로그아웃
          </button>
        </div>
      );
    }

    return (
      <div className="flex items-center gap-3 text-sm">
        <Link
          href="/login"
          className="rounded-md border border-slate-300 px-3 py-1.5 transition hover:bg-slate-50"
        >
          로그인
        </Link>
        <Link
          href="/signup"
          className="rounded-md bg-slate-900 px-3 py-1.5 text-white transition hover:bg-slate-700"
        >
          회원가입
        </Link>
      </div>
    );
  }, [handleSignOut, isAuthenticated, isLoading, user]);

  return (
    <main className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className="border-b border-slate-200 bg-white">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
          <Link href="/" className="text-xl font-bold text-slate-900">
            체험단
          </Link>
          {authActions}
        </div>
      </header>

      <div className="mx-auto max-w-7xl px-6 py-10">
        {/* Hero Section */}
        <section className="mb-10">
          <h1 className="mb-3 text-4xl font-bold text-slate-900">
            모집 중인 체험단
          </h1>
          <p className="text-lg text-slate-600">
            다양한 체험단에 지원하고 리뷰를 작성해보세요
          </p>
        </section>

        {/* Search and Filter */}
        <section className="mb-8 flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              placeholder="체험단 검색..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full rounded-md border border-slate-300 py-2 pl-10 pr-4 focus:border-slate-500 focus:outline-none"
            />
          </div>

          <select
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
            className="rounded-md border border-slate-300 px-4 py-2 focus:border-slate-500 focus:outline-none"
          >
            <option value="">전체 카테고리</option>
            {categories.map((category) => (
              <option key={category} value={category}>
                {category}
              </option>
            ))}
          </select>
        </section>

        {/* Campaigns Grid */}
        <section>
          {isLoadingCampaigns ? (
            <div className="py-20 text-center text-slate-500">
              체험단을 불러오는 중...
            </div>
          ) : filteredCampaigns.length === 0 ? (
            <div className="py-20 text-center text-slate-500">
              모집 중인 체험단이 없습니다
            </div>
          ) : (
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
              {filteredCampaigns.map((campaign) => (
                <Link
                  key={campaign.id}
                  href={`/campaigns/${campaign.id}`}
                  className="group flex flex-col overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm transition hover:shadow-md"
                >
                  {/* Campaign Image Placeholder */}
                  <div className="h-48 bg-gradient-to-br from-slate-100 to-slate-200" />

                  <div className="flex flex-1 flex-col gap-3 p-6">
                    {/* Category Badge */}
                    <div className="flex items-center justify-between">
                      <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-700">
                        {campaign.category}
                      </span>
                      <span className="text-xs text-slate-500">
                        {campaign.advertiser.business_name}
                      </span>
                    </div>

                    {/* Title */}
                    <h3 className="text-lg font-semibold text-slate-900 group-hover:text-slate-700">
                      {campaign.title}
                    </h3>

                    {/* Description */}
                    <p className="line-clamp-2 text-sm text-slate-600">
                      {campaign.description || "설명이 없습니다"}
                    </p>

                    {/* Info */}
                    <div className="mt-auto flex items-center justify-between border-t border-slate-100 pt-4 text-xs text-slate-500">
                      <span>모집 {campaign.target_participants}명</span>
                      <span>
                        {new Date(campaign.recruitment_end_date).toLocaleDateString("ko-KR")}까지
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
