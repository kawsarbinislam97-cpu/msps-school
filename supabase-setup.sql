-- Supabase SQL Editor-এ একবার চালান

create table if not exists site_settings (
  key text primary key,
  value text
);

create table if not exists notices (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text,
  date date not null default current_date,
  created_at timestamptz default now()
);

create table if not exists events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  event_date text,
  created_at timestamptz default now()
);

create table if not exists gallery (
  id uuid primary key default gen_random_uuid(),
  url text not null,
  caption text,
  created_at timestamptz default now()
);

alter table site_settings enable row level security;
alter table notices enable row level security;
alter table events enable row level security;
alter table gallery enable row level security;

-- সবাই পড়তে পারবে
create policy "public read settings" on site_settings for select using (true);
create policy "public read notices" on notices for select using (true);
create policy "public read events" on events for select using (true);
create policy "public read gallery" on gallery for select using (true);

-- শুধু লগইন করা অ্যাডমিন লিখতে ও মুছতে পারবে
create policy "admin write settings" on site_settings for all to authenticated using (true) with check (true);
create policy "admin write notices" on notices for all to authenticated using (true) with check (true);
create policy "admin write events" on events for all to authenticated using (true) with check (true);
create policy "admin write gallery" on gallery for all to authenticated using (true) with check (true);

-- ছবি রাখার বাকেট (পাবলিক পড়া, শুধু অ্যাডমিন লেখা/মোছা)
insert into storage.buckets (id, name, public) values ('public-assets', 'public-assets', true)
on conflict (id) do nothing;

create policy "public read assets" on storage.objects for select using (bucket_id = 'public-assets');
create policy "admin write assets" on storage.objects for insert to authenticated with check (bucket_id = 'public-assets');
create policy "admin update assets" on storage.objects for update to authenticated using (bucket_id = 'public-assets');
create policy "admin delete assets" on storage.objects for delete to authenticated using (bucket_id = 'public-assets');

-- প্রাথমিক লেখা (অ্যাডমিন পরে বদলাতে পারবে)
insert into site_settings (key, value) values
  ('school_name', 'এম এস পাবলিক স্কুল'),
  ('top_tagline', 'এম এস ওয়েলফেয়ার অ্যাসোসিয়েশন কর্তৃক পরিচালিত'),
  ('hero_sub', 'শিলখালী (সাঁকোর পাড়), পেকুয়া, কক্সবাজার'),
  ('hero_badge', 'স্থাপিত ২০০৮ খ্রি.'),
  ('slogan', 'পড় তোমার প্রভুর নামে যিনি সৃষ্টি করেছেন'),
  ('stat1_num', '২৫০+'), ('stat1_label', 'মোট শিক্ষার্থী'),
  ('stat2_num', '১০+'), ('stat2_label', 'অভিজ্ঞ শিক্ষক'),
  ('stat3_num', '৭'), ('stat3_label', 'শ্রেণি (নার্সারি–ফাইভ)'),
  ('stat4_num', '২০০৮'), ('stat4_label', 'স্থাপিত'),
  ('footer_address', 'সাঁকোর পাড় স্টেশন, শিলখালী, পেকুয়া, কক্সবাজার')
on conflict (key) do nothing;
