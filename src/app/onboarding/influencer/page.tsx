"use client";

import { useCallback, useState } from "react";
import { useRouter } from "next/navigation";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser-client";
import { useCurrentUser } from "@/features/auth/hooks/useCurrentUser";

type Channel = {
  id: string;
  type: string;
  name: string;
  url: string;
};

export default function InfluencerOnboardingPage() {
  const router = useRouter();
  const { user } = useCurrentUser();
  const [birthDate, setBirthDate] = useState("");
  const [channels, setChannels] = useState<Channel[]>([]);
  const [newChannel, setNewChannel] = useState({
    type: "",
    name: "",
    url: "",
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const addChannel = useCallback(() => {
    if (!newChannel.type || !newChannel.name || !newChannel.url) {
      setErrorMessage("모든 채널 정보를 입력해주세요.");
      return;
    }

    setChannels((prev) => [
      ...prev,
      {
        id: Date.now().toString(),
        type: newChannel.type,
        name: newChannel.name,
        url: newChannel.url,
      },
    ]);

    setNewChannel({ type: "", name: "", url: "" });
    setErrorMessage(null);
  }, [newChannel]);

  const removeChannel = useCallback((id: string) => {
    setChannels((prev) => prev.filter((ch) => ch.id !== id));
  }, []);

  const handleSubmit = useCallback(
    async (event: React.FormEvent<HTMLFormElement>) => {
      event.preventDefault();
      setIsSubmitting(true);
      setErrorMessage(null);

      if (!birthDate) {
        setErrorMessage("생년월일을 입력해주세요.");
        setIsSubmitting(false);
        return;
      }

      if (channels.length === 0) {
        setErrorMessage("최소 1개 이상의 채널을 등록해주세요.");
        setIsSubmitting(false);
        return;
      }

      if (!user?.id) {
        setErrorMessage("로그인 정보를 찾을 수 없습니다.");
        setIsSubmitting(false);
        return;
      }

      const supabase = getSupabaseBrowserClient();

      try {
        // 1. influencer_profiles 생성
        const { data: profileData, error: profileError } = await supabase
          .from("influencer_profiles")
          .insert({
            user_id: user.id,
            birth_date: birthDate,
          })
          .select()
          .single();

        if (profileError) {
          console.error("Profile creation error:", profileError);
          setErrorMessage("인플루언서 프로필 생성에 실패했습니다.");
          setIsSubmitting(false);
          return;
        }

        // 2. influencer_channels 생성
        const channelsToInsert = channels.map((ch) => ({
          influencer_id: profileData.id,
          channel_type: ch.type,
          channel_name: ch.name,
          channel_url: ch.url,
        }));

        const { error: channelsError } = await supabase
          .from("influencer_channels")
          .insert(channelsToInsert);

        if (channelsError) {
          console.error("Channels creation error:", channelsError);
          setErrorMessage("채널 정보 저장에 실패했습니다.");
          setIsSubmitting(false);
          return;
        }

        // 3. 홈으로 리디렉션
        router.replace("/");
      } catch (error) {
        console.error("Onboarding error:", error);
        setErrorMessage("정보 등록 중 문제가 발생했습니다.");
      } finally {
        setIsSubmitting(false);
      }
    },
    [birthDate, channels, user, router]
  );

  return (
    <div className="mx-auto flex min-h-screen w-full max-w-2xl flex-col items-center justify-center gap-10 px-6 py-16">
      <header className="flex flex-col items-center gap-3 text-center">
        <h1 className="text-3xl font-semibold">인플루언서 정보 등록</h1>
        <p className="text-slate-500">
          체험단에 지원하기 위해 정보를 입력해주세요
        </p>
      </header>

      <form
        onSubmit={handleSubmit}
        className="w-full flex flex-col gap-6 rounded-xl border border-slate-200 p-8 shadow-sm"
      >
        {/* 생년월일 */}
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          생년월일 <span className="text-rose-500">*</span>
          <input
            type="date"
            value={birthDate}
            onChange={(e) => setBirthDate(e.target.value)}
            required
            className="rounded-md border border-slate-300 px-3 py-2 focus:border-slate-500 focus:outline-none"
          />
        </label>

        {/* 채널 추가 섹션 */}
        <div className="flex flex-col gap-4 border-t pt-6">
          <h3 className="font-medium text-slate-900">
            SNS 채널 정보 <span className="text-rose-500">*</span>
          </h3>

          <div className="grid gap-3 md:grid-cols-3">
            <select
              value={newChannel.type}
              onChange={(e) =>
                setNewChannel((prev) => ({ ...prev, type: e.target.value }))
              }
              className="rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-slate-500 focus:outline-none"
            >
              <option value="">채널 유형</option>
              <option value="instagram">Instagram</option>
              <option value="youtube">YouTube</option>
              <option value="blog">Blog</option>
              <option value="tiktok">TikTok</option>
            </select>

            <input
              type="text"
              placeholder="채널명"
              value={newChannel.name}
              onChange={(e) =>
                setNewChannel((prev) => ({ ...prev, name: e.target.value }))
              }
              className="rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-slate-500 focus:outline-none"
            />

            <input
              type="url"
              placeholder="채널 URL"
              value={newChannel.url}
              onChange={(e) =>
                setNewChannel((prev) => ({ ...prev, url: e.target.value }))
              }
              className="rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-slate-500 focus:outline-none"
            />
          </div>

          <button
            type="button"
            onClick={addChannel}
            className="w-full rounded-md border border-slate-300 px-4 py-2 text-sm font-medium text-slate-700 transition hover:bg-slate-50"
          >
            채널 추가
          </button>

          {/* 등록된 채널 목록 */}
          {channels.length > 0 && (
            <div className="flex flex-col gap-2">
              <p className="text-sm font-medium text-slate-700">
                등록된 채널 ({channels.length}개)
              </p>
              {channels.map((channel) => (
                <div
                  key={channel.id}
                  className="flex items-center justify-between rounded-md border border-slate-200 px-4 py-2 text-sm"
                >
                  <div className="flex flex-col">
                    <span className="font-medium text-slate-900">
                      {channel.type} - {channel.name}
                    </span>
                    <span className="text-xs text-slate-500 truncate">
                      {channel.url}
                    </span>
                  </div>
                  <button
                    type="button"
                    onClick={() => removeChannel(channel.id)}
                    className="text-rose-500 hover:text-rose-700"
                  >
                    삭제
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

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
