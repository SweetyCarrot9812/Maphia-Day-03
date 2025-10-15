export interface Concert {
  id: string;
  title: string;
  artist: string;
  date: string;
  venue: string;
  description: string | null;
  image_url: string | null;
  running_time: number;
  created_at: string;
  updated_at: string;
}
