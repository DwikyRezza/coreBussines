-- ============================================================
-- CoreBusiness schema upgrade
-- Date: 2026-05-14
-- Purpose:
--   - Harden multi-business access with business_members based RLS.
--   - Separate product catalog from inventory stock rows.
--   - Add wallets, categories, goals, transaction line items, triggers,
--     and dashboard RPCs for scalable Flutter reads.
-- ============================================================

create extension if not exists "uuid-ossp";

create schema if not exists app_private;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_role' and typnamespace = 'public'::regnamespace) then
    create type public.user_role as enum ('owner', 'admin', 'staff');
  end if;
end $$;

-- ------------------------------------------------------------
-- Core tables
-- ------------------------------------------------------------

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text not null,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create table if not exists public.businesses (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  description text,
  address text,
  logo_url text,
  owner_id uuid references public.profiles(id) on delete set null,
  currency_code text not null default 'IDR',
  timezone text not null default 'Asia/Jakarta',
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.businesses
  add column if not exists currency_code text not null default 'IDR',
  add column if not exists timezone text not null default 'Asia/Jakarta',
  add column if not exists is_archived boolean not null default false,
  add column if not exists updated_at timestamptz not null default now();

create table if not exists public.business_members (
  id uuid primary key default uuid_generate_v4(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.user_role not null default 'staff',
  invited_by uuid references public.profiles(id) on delete set null,
  joined_at timestamptz not null default now(),
  unique (business_id, user_id)
);

alter table public.business_members
  add column if not exists invited_by uuid references public.profiles(id) on delete set null;

create table if not exists public.wallets (
  id uuid primary key default uuid_generate_v4(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null,
  type text not null default 'cash' check (type in ('cash', 'bank', 'ewallet', 'credit', 'other')),
  balance numeric(15,2) not null default 0,
  opening_balance numeric(15,2) not null default 0,
  currency_code text not null default 'IDR',
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, name)
);

alter table public.wallets
  add column if not exists type text not null default 'cash',
  add column if not exists opening_balance numeric(15,2) not null default 0,
  add column if not exists currency_code text not null default 'IDR',
  add column if not exists is_archived boolean not null default false,
  add column if not exists updated_at timestamptz not null default now();

create table if not exists public.categories (
  id uuid primary key default uuid_generate_v4(),
  business_id uuid references public.businesses(id) on delete cascade,
  name text not null,
  icon text,
  type text not null check (type in ('income', 'expense')),
  is_system boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, name, type)
);

alter table public.categories
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create table if not exists public.goals (
  id uuid primary key default uuid_generate_v4(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null,
  target_amount numeric(15,2) not null check (target_amount >= 0),
  current_amount numeric(15,2) not null default 0 check (current_amount >= 0),
  target_date date,
  status text not null default 'active' check (status in ('active', 'completed', 'paused', 'cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default uuid_generate_v4(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  sku text,
  name text not null,
  description text,
  base_price numeric(15,2) not null default 0 check (base_price >= 0),
  selling_price numeric(15,2) not null default 0 check (selling_price >= 0),
  image_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, sku)
);

alter table public.products
  add column if not exists is_active boolean not null default true,
  add column if not exists updated_at timestamptz not null default now();

create table if not exists public.inventory_items (
  id uuid primary key default uuid_generate_v4(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  stock_quantity integer not null default 0 check (stock_quantity >= 0),
  min_stock_level integer not null default 5 check (min_stock_level >= 0),
  last_restocked timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, product_id)
);

alter table public.inventory_items
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create table if not exists public.transactions (
  id uuid primary key default uuid_generate_v4(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  wallet_id uuid references public.wallets(id) on delete set null,
  category_id uuid references public.categories(id) on delete set null,
  creator_id uuid references public.profiles(id) on delete set null,
  type text not null check (type in ('income', 'expense')),
  amount numeric(15,2) not null check (amount >= 0),
  title text,
  note text,
  receipt_image_url text,
  transaction_date timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.transactions
  add column if not exists category_id uuid references public.categories(id) on delete set null,
  add column if not exists title text,
  add column if not exists receipt_image_url text,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create table if not exists public.transaction_items (
  id uuid primary key default uuid_generate_v4(),
  transaction_id uuid not null references public.transactions(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  quantity integer not null check (quantity > 0),
  unit_price numeric(15,2) not null check (unit_price >= 0),
  total_price numeric(15,2) generated always as (quantity * unit_price) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.transaction_items
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

-- ------------------------------------------------------------
-- Integrity and indexes
-- ------------------------------------------------------------

create unique index if not exists wallets_business_id_id_idx on public.wallets (business_id, id);
create unique index if not exists categories_business_id_id_idx on public.categories (business_id, id);
create unique index if not exists products_business_id_id_idx on public.products (business_id, id);

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'wallets_type_check') then
    alter table public.wallets add constraint wallets_type_check check (type in ('cash', 'bank', 'ewallet', 'credit', 'other'));
  end if;

  if not exists (select 1 from pg_constraint where conname = 'transactions_wallet_business_fk') then
    alter table public.transactions
      add constraint transactions_wallet_business_fk
      foreign key (business_id, wallet_id)
      references public.wallets(business_id, id)
      deferrable initially immediate;
  end if;

  if not exists (select 1 from pg_constraint where conname = 'transactions_category_business_fk') then
    alter table public.transactions
      add constraint transactions_category_business_fk
      foreign key (business_id, category_id)
      references public.categories(business_id, id)
      deferrable initially immediate;
  end if;

  if not exists (select 1 from pg_constraint where conname = 'inventory_product_business_fk') then
    alter table public.inventory_items
      add constraint inventory_product_business_fk
      foreign key (business_id, product_id)
      references public.products(business_id, id)
      deferrable initially immediate;
  end if;
end $$;

create index if not exists business_members_user_id_idx on public.business_members (user_id);
create index if not exists business_members_business_id_idx on public.business_members (business_id);
create index if not exists transactions_business_date_idx on public.transactions (business_id, transaction_date desc);
create index if not exists transactions_wallet_id_idx on public.transactions (wallet_id);
create index if not exists transaction_items_transaction_id_idx on public.transaction_items (transaction_id);
create index if not exists inventory_items_low_stock_idx on public.inventory_items (business_id, stock_quantity, min_stock_level);

-- ------------------------------------------------------------
-- Shared functions
-- ------------------------------------------------------------

create or replace function app_private.touch_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function app_private.is_business_member(target_business_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.business_members bm
    where bm.business_id = target_business_id
      and bm.user_id = auth.uid()
  );
$$;

create or replace function app_private.has_business_role(
  target_business_id uuid,
  allowed_roles public.user_role[]
)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.business_members bm
    where bm.business_id = target_business_id
      and bm.user_id = auth.uid()
      and bm.role = any(allowed_roles)
  );
$$;

create or replace function public.is_business_member(biz_id uuid)
returns boolean
language sql
stable
set search_path = public
as $$
  select app_private.is_business_member(biz_id);
$$;

create or replace function app_private.ensure_user_workspace(
  p_user_id uuid,
  p_full_name text,
  p_email text,
  p_avatar_url text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_business_id uuid;
  v_wallet_id uuid;
begin
  if p_user_id is null or p_user_id <> auth.uid() then
    raise exception 'Cannot bootstrap a workspace for another user.';
  end if;

  insert into public.profiles (id, full_name, email, avatar_url, updated_at)
  values (p_user_id, p_full_name, p_email, p_avatar_url, now())
  on conflict (id) do update set
    full_name = excluded.full_name,
    email = excluded.email,
    avatar_url = excluded.avatar_url,
    updated_at = now();

  select bm.business_id
  into v_business_id
  from public.business_members bm
  where bm.user_id = p_user_id
  order by bm.joined_at asc
  limit 1;

  if v_business_id is null then
    insert into public.businesses (name, owner_id)
    values (coalesce(nullif(p_full_name, ''), split_part(p_email, '@', 1), 'My Business') || '''s Business', p_user_id)
    returning id into v_business_id;

    insert into public.business_members (business_id, user_id, role)
    values (v_business_id, p_user_id, 'owner');

    insert into public.wallets (business_id, name, type, balance, opening_balance)
    values (v_business_id, 'Cash', 'cash', 0, 0)
    returning id into v_wallet_id;

    insert into public.categories (business_id, name, icon, type, is_system)
    values
      (v_business_id, 'Sales', 'sell', 'income', true),
      (v_business_id, 'Service Income', 'work', 'income', true),
      (v_business_id, 'Inventory Purchase', 'inventory', 'expense', true),
      (v_business_id, 'Operations', 'receipt', 'expense', true)
    on conflict (business_id, name, type) do nothing;
  end if;

  return v_business_id;
end;
$$;

create or replace function public.ensure_current_user_workspace(
  p_full_name text default null,
  p_email text default null,
  p_avatar_url text default null
)
returns uuid
language sql
set search_path = public
as $$
  select app_private.ensure_user_workspace(
    auth.uid(),
    p_full_name,
    coalesce(p_email, auth.jwt() ->> 'email'),
    p_avatar_url
  );
$$;

-- ------------------------------------------------------------
-- Automation triggers
-- ------------------------------------------------------------

drop trigger if exists touch_profiles_updated_at on public.profiles;
create trigger touch_profiles_updated_at
before update on public.profiles
for each row execute function app_private.touch_updated_at();

drop trigger if exists touch_businesses_updated_at on public.businesses;
create trigger touch_businesses_updated_at
before update on public.businesses
for each row execute function app_private.touch_updated_at();

drop trigger if exists touch_wallets_updated_at on public.wallets;
create trigger touch_wallets_updated_at
before update on public.wallets
for each row execute function app_private.touch_updated_at();

drop trigger if exists touch_categories_updated_at on public.categories;
create trigger touch_categories_updated_at
before update on public.categories
for each row execute function app_private.touch_updated_at();

drop trigger if exists touch_goals_updated_at on public.goals;
create trigger touch_goals_updated_at
before update on public.goals
for each row execute function app_private.touch_updated_at();

drop trigger if exists touch_products_updated_at on public.products;
create trigger touch_products_updated_at
before update on public.products
for each row execute function app_private.touch_updated_at();

drop trigger if exists touch_inventory_items_updated_at on public.inventory_items;
create trigger touch_inventory_items_updated_at
before update on public.inventory_items
for each row execute function app_private.touch_updated_at();

drop trigger if exists touch_transactions_updated_at on public.transactions;
create trigger touch_transactions_updated_at
before update on public.transactions
for each row execute function app_private.touch_updated_at();

drop trigger if exists touch_transaction_items_updated_at on public.transaction_items;
create trigger touch_transaction_items_updated_at
before update on public.transaction_items
for each row execute function app_private.touch_updated_at();

create or replace function app_private.apply_wallet_delta(
  target_wallet_id uuid,
  transaction_type text,
  transaction_amount numeric
)
returns void
language plpgsql
set search_path = public
as $$
begin
  if target_wallet_id is null or transaction_amount is null then
    return;
  end if;

  update public.wallets
  set balance = balance +
    case when transaction_type = 'income' then transaction_amount else -transaction_amount end
  where id = target_wallet_id;
end;
$$;

create or replace function app_private.sync_wallet_balance()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    perform app_private.apply_wallet_delta(new.wallet_id, new.type, new.amount);
    return new;
  elsif tg_op = 'UPDATE' then
    perform app_private.apply_wallet_delta(old.wallet_id, old.type, -old.amount);
    perform app_private.apply_wallet_delta(new.wallet_id, new.type, new.amount);
    return new;
  elsif tg_op = 'DELETE' then
    perform app_private.apply_wallet_delta(old.wallet_id, old.type, -old.amount);
    return old;
  end if;

  return null;
end;
$$;

drop trigger if exists on_transaction_added on public.transactions;
drop trigger if exists sync_wallet_balance_on_transactions on public.transactions;
create trigger sync_wallet_balance_on_transactions
after insert or update of wallet_id, type, amount or delete on public.transactions
for each row execute function app_private.sync_wallet_balance();

create or replace function app_private.apply_inventory_delta(
  target_transaction_id uuid,
  target_product_id uuid,
  transaction_type text,
  item_quantity integer
)
returns void
language plpgsql
set search_path = public
as $$
declare
  v_business_id uuid;
  v_delta integer;
begin
  if target_product_id is null or item_quantity is null then
    return;
  end if;

  select t.business_id into v_business_id
  from public.transactions t
  where t.id = target_transaction_id;

  if v_business_id is null then
    return;
  end if;

  v_delta := case when transaction_type = 'income' then -item_quantity else item_quantity end;

  insert into public.inventory_items (business_id, product_id, stock_quantity, last_restocked)
  values (v_business_id, target_product_id, greatest(v_delta, 0), case when v_delta > 0 then now() else null end)
  on conflict (business_id, product_id) do update set
    stock_quantity = greatest(public.inventory_items.stock_quantity + v_delta, 0),
    last_restocked = case when v_delta > 0 then now() else public.inventory_items.last_restocked end;
end;
$$;

create or replace function app_private.sync_inventory_from_transaction_item()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_old_type text;
  v_new_type text;
begin
  if tg_op in ('UPDATE', 'DELETE') then
    select type into v_old_type from public.transactions where id = old.transaction_id;
    perform app_private.apply_inventory_delta(old.transaction_id, old.product_id, v_old_type, -old.quantity);
  end if;

  if tg_op in ('INSERT', 'UPDATE') then
    select type into v_new_type from public.transactions where id = new.transaction_id;
    perform app_private.apply_inventory_delta(new.transaction_id, new.product_id, v_new_type, new.quantity);
    return new;
  end if;

  return old;
end;
$$;

drop trigger if exists sync_inventory_from_transaction_item on public.transaction_items;
create trigger sync_inventory_from_transaction_item
after insert or update of transaction_id, product_id, quantity or delete on public.transaction_items
for each row execute function app_private.sync_inventory_from_transaction_item();

create or replace function app_private.recalculate_transaction_amount()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_transaction_id uuid;
begin
  if tg_op = 'UPDATE' and old.transaction_id <> new.transaction_id then
    update public.transactions t
    set amount = coalesce((
      select sum(ti.total_price)
      from public.transaction_items ti
      where ti.transaction_id = old.transaction_id
    ), 0)
    where t.id = old.transaction_id;
  end if;

  if tg_op = 'DELETE' then
    v_transaction_id := old.transaction_id;
  else
    v_transaction_id := new.transaction_id;
  end if;

  update public.transactions t
  set amount = coalesce((
    select sum(ti.total_price)
    from public.transaction_items ti
    where ti.transaction_id = v_transaction_id
  ), 0)
  where t.id = v_transaction_id;

  if tg_op = 'DELETE' then
    return old;
  end if;

  return new;
end;
$$;

drop trigger if exists recalculate_transaction_amount_from_items on public.transaction_items;
create trigger recalculate_transaction_amount_from_items
after insert or update of transaction_id, quantity, unit_price or delete on public.transaction_items
for each row execute function app_private.recalculate_transaction_amount();

-- ------------------------------------------------------------
-- RLS
-- ------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.businesses enable row level security;
alter table public.business_members enable row level security;
alter table public.wallets enable row level security;
alter table public.categories enable row level security;
alter table public.goals enable row level security;
alter table public.products enable row level security;
alter table public.inventory_items enable row level security;
alter table public.transactions enable row level security;
alter table public.transaction_items enable row level security;

drop policy if exists "Users can see own profile" on public.profiles;
drop policy if exists "Users can view own profile" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can view own profile"
on public.profiles for select
to authenticated
using (id = auth.uid());

create policy "Users can update own profile"
on public.profiles for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

drop policy if exists "Members can view business" on public.businesses;
drop policy if exists "Members can manage business" on public.businesses;
create policy "Members can view business"
on public.businesses for select
to authenticated
using (app_private.is_business_member(id));

create policy "Owners and admins can manage business"
on public.businesses for update
to authenticated
using (app_private.has_business_role(id, array['owner', 'admin']::public.user_role[]))
with check (app_private.has_business_role(id, array['owner', 'admin']::public.user_role[]));

drop policy if exists "Members can view business members" on public.business_members;
drop policy if exists "Owners and admins can manage members" on public.business_members;
create policy "Members can view business members"
on public.business_members for select
to authenticated
using (app_private.is_business_member(business_id));

create policy "Owners and admins can manage members"
on public.business_members for all
to authenticated
using (app_private.has_business_role(business_id, array['owner', 'admin']::public.user_role[]))
with check (app_private.has_business_role(business_id, array['owner', 'admin']::public.user_role[]));

drop policy if exists "Wallet Access" on public.wallets;
drop policy if exists "Product Access" on public.products;
drop policy if exists "Inventory Access" on public.inventory_items;
drop policy if exists "Transaction Access" on public.transactions;

drop policy if exists "Members can manage wallets" on public.wallets;
create policy "Members can manage wallets"
on public.wallets for all
to authenticated
using (app_private.is_business_member(business_id))
with check (app_private.is_business_member(business_id));

drop policy if exists "Members can manage categories" on public.categories;
create policy "Members can manage categories"
on public.categories for all
to authenticated
using (app_private.is_business_member(business_id))
with check (app_private.is_business_member(business_id));

drop policy if exists "Members can manage goals" on public.goals;
create policy "Members can manage goals"
on public.goals for all
to authenticated
using (app_private.is_business_member(business_id))
with check (app_private.is_business_member(business_id));

drop policy if exists "Members can manage products" on public.products;
create policy "Members can manage products"
on public.products for all
to authenticated
using (app_private.is_business_member(business_id))
with check (app_private.is_business_member(business_id));

drop policy if exists "Members can manage inventory" on public.inventory_items;
create policy "Members can manage inventory"
on public.inventory_items for all
to authenticated
using (app_private.is_business_member(business_id))
with check (app_private.is_business_member(business_id));

drop policy if exists "Members can manage transactions" on public.transactions;
create policy "Members can manage transactions"
on public.transactions for all
to authenticated
using (app_private.is_business_member(business_id))
with check (app_private.is_business_member(business_id));

drop policy if exists "Members can manage transaction items" on public.transaction_items;
create policy "Members can manage transaction items"
on public.transaction_items for all
to authenticated
using (
  exists (
    select 1
    from public.transactions t
    where t.id = transaction_items.transaction_id
      and app_private.is_business_member(t.business_id)
  )
)
with check (
  exists (
    select 1
    from public.transactions t
    where t.id = transaction_items.transaction_id
      and app_private.is_business_member(t.business_id)
  )
);

-- ------------------------------------------------------------
-- Dashboard RPCs
-- ------------------------------------------------------------

create or replace function public.get_dashboard_summary(
  p_business_id uuid,
  p_start_date timestamptz default date_trunc('month', now()),
  p_end_date timestamptz default now()
)
returns table (
  total_income numeric,
  total_expense numeric,
  net_profit numeric,
  wallet_balance numeric,
  transaction_count bigint,
  low_stock_count bigint
)
language sql
stable
set search_path = public
as $$
  with tx as (
    select
      coalesce(sum(amount) filter (where type = 'income'), 0) as total_income,
      coalesce(sum(amount) filter (where type = 'expense'), 0) as total_expense,
      count(*) as transaction_count
    from public.transactions
    where business_id = p_business_id
      and transaction_date >= p_start_date
      and transaction_date <= p_end_date
  ),
  wallet as (
    select coalesce(sum(balance), 0) as wallet_balance
    from public.wallets
    where business_id = p_business_id
      and is_archived = false
  ),
  stock as (
    select count(*) as low_stock_count
    from public.inventory_items
    where business_id = p_business_id
      and stock_quantity <= min_stock_level
  )
  select
    tx.total_income,
    tx.total_expense,
    tx.total_income - tx.total_expense as net_profit,
    wallet.wallet_balance,
    tx.transaction_count,
    stock.low_stock_count
  from tx, wallet, stock
  where app_private.is_business_member(p_business_id);
$$;

create or replace function public.get_monthly_cashflow(
  p_business_id uuid,
  p_months integer default 6
)
returns table (
  month date,
  income numeric,
  expense numeric,
  net numeric
)
language sql
stable
set search_path = public
as $$
  with months as (
    select date_trunc('month', now())::date - (make_interval(months => gs)) as month
    from generate_series(greatest(p_months, 1) - 1, 0, -1) gs
  ),
  tx as (
    select
      date_trunc('month', transaction_date)::date as month,
      coalesce(sum(amount) filter (where type = 'income'), 0) as income,
      coalesce(sum(amount) filter (where type = 'expense'), 0) as expense
    from public.transactions
    where business_id = p_business_id
      and transaction_date >= (select min(month) from months)
    group by 1
  )
  select
    m.month,
    coalesce(tx.income, 0) as income,
    coalesce(tx.expense, 0) as expense,
    coalesce(tx.income, 0) - coalesce(tx.expense, 0) as net
  from months m
  left join tx on tx.month = m.month
  where app_private.is_business_member(p_business_id)
  order by m.month;
$$;

grant usage on schema public to anon, authenticated;
grant usage on schema app_private to authenticated;
grant select, insert, update, delete on
  public.profiles,
  public.businesses,
  public.business_members,
  public.wallets,
  public.categories,
  public.goals,
  public.products,
  public.inventory_items,
  public.transactions,
  public.transaction_items
to authenticated;
grant execute on function public.ensure_current_user_workspace(text, text, text) to authenticated;
grant execute on function public.get_dashboard_summary(uuid, timestamptz, timestamptz) to authenticated;
grant execute on function public.get_monthly_cashflow(uuid, integer) to authenticated;
grant execute on function app_private.ensure_user_workspace(uuid, text, text, text) to authenticated;
grant execute on function app_private.is_business_member(uuid) to authenticated;
grant execute on function app_private.has_business_role(uuid, public.user_role[]) to authenticated;
