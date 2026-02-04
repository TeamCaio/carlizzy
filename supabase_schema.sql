-- Wardrobe App Database Schema

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Users table (extends Supabase auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text,
  credits integer default 100,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Saved outfits (AI-generated results)
create table public.outfits (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles on delete cascade not null,
  image_path text not null,
  description text,
  items_count integer default 1,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Saved articles (individual clothing items)
create table public.articles (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles on delete cascade not null,
  image_path text not null,
  category text not null check (category in ('tops', 'bottoms', 'dresses')),
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Recent selfies
create table public.recent_selfies (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles on delete cascade not null,
  image_path text not null,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Row Level Security (RLS)
alter table public.profiles enable row level security;
alter table public.outfits enable row level security;
alter table public.articles enable row level security;
alter table public.recent_selfies enable row level security;

-- Policies: Users can only access their own data
create policy "Users can view own profile" on public.profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

create policy "Users can view own outfits" on public.outfits for select using (auth.uid() = user_id);
create policy "Users can insert own outfits" on public.outfits for insert with check (auth.uid() = user_id);
create policy "Users can delete own outfits" on public.outfits for delete using (auth.uid() = user_id);

create policy "Users can view own articles" on public.articles for select using (auth.uid() = user_id);
create policy "Users can insert own articles" on public.articles for insert with check (auth.uid() = user_id);
create policy "Users can delete own articles" on public.articles for delete using (auth.uid() = user_id);

create policy "Users can view own selfies" on public.recent_selfies for select using (auth.uid() = user_id);
create policy "Users can insert own selfies" on public.recent_selfies for insert with check (auth.uid() = user_id);
create policy "Users can delete own selfies" on public.recent_selfies for delete using (auth.uid() = user_id);

-- Function to create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, credits)
  values (new.id, new.email, 100);
  return new;
end;
$$ language plpgsql security definer;

-- Trigger to auto-create profile
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Storage buckets (run these separately in Storage settings or use SQL)
-- Go to Storage > Create bucket:
--   1. "outfits" (public: false)
--   2. "articles" (public: false)
--   3. "selfies" (public: false)
