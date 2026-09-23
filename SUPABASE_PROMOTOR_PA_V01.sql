-- Promotor PA V02 - cadastro profissional de produtos
-- Execute no SQL Editor do projeto Supabase.
create table if not exists public.promotor_products (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  ean text,
  brand text,
  location text not null default 'Sessão' check (location in ('Sessão','Deposito')),
  expiration_date date,
  quantity numeric not null default 1 check (quantity >= 0),
  status text not null default 'pendente' check (status in ('pendente','concluido')),
  created_at timestamptz not null default now()
);

alter table public.promotor_products add column if not exists location text;
alter table public.promotor_products add column if not exists expiration_date date;
alter table public.promotor_products add column if not exists quantity numeric;
update public.promotor_products set location='Sessão' where location is null;
update public.promotor_products set quantity=1 where quantity is null;
alter table public.promotor_products alter column location set default 'Sessão';
alter table public.promotor_products alter column location set not null;
alter table public.promotor_products alter column quantity set default 1;
alter table public.promotor_products alter column quantity set not null;

alter table public.promotor_products drop constraint if exists promotor_products_location_check;
alter table public.promotor_products add constraint promotor_products_location_check check (location in ('Sessão','Deposito'));

alter table public.promotor_products enable row level security;
drop policy if exists "promotor products select own" on public.promotor_products;
drop policy if exists "promotor products insert own" on public.promotor_products;
drop policy if exists "promotor products update own" on public.promotor_products;
drop policy if exists "promotor products delete own" on public.promotor_products;
create policy "promotor products select own" on public.promotor_products for select using (auth.uid() = user_id);
create policy "promotor products insert own" on public.promotor_products for insert with check (auth.uid() = user_id);
create policy "promotor products update own" on public.promotor_products for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "promotor products delete own" on public.promotor_products for delete using (auth.uid() = user_id);
