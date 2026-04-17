alter table public.seller_documents
  alter column tesserino_number drop not null;

alter table public.seller_documents
  add column if not exists review_outcome public.seller_status_enum,
  add column if not exists reviewed_at timestamptz,
  add column if not exists documents_retention_expires_at timestamptz,
  add column if not exists documents_purged_at timestamptz;

alter table public.seller_documents
  drop constraint if exists seller_documents_review_outcome_chk;

alter table public.seller_documents
  add constraint seller_documents_review_outcome_chk
  check (
    review_outcome is null
    or review_outcome in ('pending', 'approved', 'rejected')
  );

create index if not exists seller_documents_retention_expires_at_idx
  on public.seller_documents (documents_retention_expires_at)
  where documents_purged_at is null
    and documents_retention_expires_at is not null;

create index if not exists notifications_read_created_at_idx
  on public.notifications (read, created_at asc);

update public.seller_documents sd
set
  review_outcome = case
    when u.seller_status in ('pending', 'approved', 'rejected')
      then u.seller_status
    else null
  end,
  reviewed_at = case
    when u.seller_status in ('approved', 'rejected')
      then coalesce(sd.reviewed_at, sd.uploaded_at)
    else null
  end,
  documents_retention_expires_at = case
    when u.seller_status = 'approved'
      then coalesce(sd.documents_retention_expires_at, sd.uploaded_at + interval '30 days')
    when u.seller_status = 'rejected'
      then coalesce(sd.documents_retention_expires_at, sd.uploaded_at + interval '180 days')
    else null
  end,
  tesserino_number = case
    when u.seller_status in ('approved', 'rejected') then null
    else sd.tesserino_number
  end
from public.users u
where u.id = sd.user_id;

create or replace function public.sync_seller_document_lifecycle_from_user_status()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.seller_status is not distinct from old.seller_status then
    return new;
  end if;

  update public.seller_documents sd
  set
    review_outcome = case
      when new.seller_status in ('pending', 'approved', 'rejected')
        then new.seller_status
      else null
    end,
    reviewed_at = case
      when new.seller_status in ('approved', 'rejected')
        then coalesce(sd.reviewed_at, timezone('utc', now()))
      else null
    end,
    documents_retention_expires_at = case
      when new.seller_status = 'approved'
        then timezone('utc', now()) + interval '30 days'
      when new.seller_status = 'rejected'
        then timezone('utc', now()) + interval '180 days'
      else null
    end,
    documents_purged_at = case
      when new.seller_status = 'pending' then null
      else sd.documents_purged_at
    end,
    tesserino_number = case
      when new.seller_status in ('approved', 'rejected') then null
      else sd.tesserino_number
    end
  where sd.user_id = new.id;

  return new;
end;
$$;

drop trigger if exists users_sync_seller_document_lifecycle on public.users;
create trigger users_sync_seller_document_lifecycle
after update of seller_status on public.users
for each row
execute function public.sync_seller_document_lifecycle_from_user_status();

create or replace function public.mark_seller_documents_purged(
  p_user_id uuid
)
returns void
language plpgsql
security invoker
set search_path = pg_catalog, public
as $$
begin
  if p_user_id is null then
    raise exception 'seller_document_user_id_required'
      using errcode = '22004';
  end if;

  update public.seller_documents
  set
    documents_purged_at = coalesce(documents_purged_at, timezone('utc', now())),
    tesserino_number = null
  where user_id = p_user_id;
end;
$$;

revoke all on function public.mark_seller_documents_purged(uuid) from public, anon, authenticated;
grant execute on function public.mark_seller_documents_purged(uuid) to service_role;

revoke all on function public.sync_seller_document_lifecycle_from_user_status() from public, anon, authenticated;

create or replace function public.purge_notifications(
  p_before timestamptz,
  p_include_unread boolean default false,
  p_limit integer default 500
)
returns integer
language plpgsql
security invoker
set search_path = pg_catalog, public
as $$
declare
  v_deleted_count integer := 0;
begin
  if p_before is null then
    raise exception 'notifications_purge_before_required'
      using errcode = '22004';
  end if;

  if p_limit is null or p_limit < 1 or p_limit > 5000 then
    raise exception 'notifications_purge_invalid_limit'
      using errcode = '22023';
  end if;

  with targets as (
    select n.id
    from public.notifications n
    where n.created_at < p_before
      and (p_include_unread or n.read = true)
    order by n.created_at asc
    limit p_limit
  )
  delete from public.notifications n
  using targets t
  where n.id = t.id;

  get diagnostics v_deleted_count = row_count;
  return v_deleted_count;
end;
$$;

revoke all on function public.purge_notifications(timestamptz, boolean, integer) from public, anon, authenticated;
grant execute on function public.purge_notifications(timestamptz, boolean, integer) to service_role;
