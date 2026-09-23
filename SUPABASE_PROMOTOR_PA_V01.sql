-- Promotor PA V01
-- Execute no SQL Editor do projeto Supabase utilizado pelo Vencimento PA.
create table if not exists public.promotor_products (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  ean text,
  brand text,
  status text not null default 'pendente' check (status in ('pendente','concluido')),
  created_at timestamptz not null default now()
);

alter table public.promotor_products enable row level security;

drop policy if exists "promotor products select own" on public.promotor_products;
drop policy if exists "promotor products insert own" on public.promotor_products;
drop policy if exists "promotor products update own" on public.promotor_products;
drop policy if exists "promotor products delete own" on public.promotor_products;

create policy "promotor products select own" on public.promotor_products for select using (auth.uid() = user_id);
create policy "promotor products insert own" on public.promotor_products for insert with check (auth.uid() = user_id);
create policy "promotor products update own" on public.promotor_products for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "promotor products delete own" on public.promotor_products for delete using (auth.uid() = user_id);
