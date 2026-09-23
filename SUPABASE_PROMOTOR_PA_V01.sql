-- Promotor PA V02 - cadastro profissional de produtos
-- Execute no SQL Editor do projeto Supabase.
create table if not exists public.promotor_products (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  ean text,
  company text,
  photo_url text,
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


-- Perfil do promotor: empresa vinculada ao usuário autenticado
create table if not exists public.promotor_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  company text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.promotor_profiles enable row level security;
drop policy if exists "promotor profiles own select" on public.promotor_profiles;
drop policy if exists "promotor profiles own update" on public.promotor_profiles;
create policy "promotor profiles own select" on public.promotor_profiles for select using (auth.uid() = user_id);
create policy "promotor profiles own update" on public.promotor_profiles for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create or replace function public.handle_promotor_profile() returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.promotor_profiles(user_id, full_name, company)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email,'@',1)), coalesce(new.raw_user_meta_data->>'company','Empresa não informada'))
  on conflict (user_id) do update set full_name=excluded.full_name, company=excluded.company, updated_at=now();
  return new;
end;
$$;
drop trigger if exists on_auth_user_created_promotor_profile on auth.users;
create trigger on_auth_user_created_promotor_profile after insert on auth.users for each row execute procedure public.handle_promotor_profile();

alter table public.promotor_products add column if not exists company text;
alter table public.promotor_products add column if not exists photo_url text;

insert into storage.buckets (id, name, public) values ('promotor-product-photos','promotor-product-photos',true) on conflict (id) do nothing;
drop policy if exists "promotor photo public read" on storage.objects;
drop policy if exists "promotor photo own upload" on storage.objects;
create policy "promotor photo public read" on storage.objects for select using (bucket_id = 'promotor-product-photos');
create policy "promotor photo own upload" on storage.objects for insert with check (bucket_id = 'promotor-product-photos' and (storage.foldername(name))[1] = auth.uid()::text);

-- V05: Realtime compartilhado entre Promotor PA e Vencimento PA.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname='supabase_realtime' and schemaname='public' and tablename='promotor_products'
  ) then
    alter publication supabase_realtime add table public.promotor_products;
  end if;
end $$;
