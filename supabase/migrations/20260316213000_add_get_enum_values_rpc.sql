create or replace function public.get_enum_values(p_enum_name text)
returns text[]
language sql
stable
set search_path = pg_catalog, public
as $$
  select coalesce(
    array_agg(e.enumlabel order by e.enumsortorder),
    array[]::text[]
  )
  from pg_type t
  join pg_namespace n
    on n.oid = t.typnamespace
  join pg_enum e
    on e.enumtypid = t.oid
  where n.nspname = 'public'
    and t.typname = p_enum_name;
$$;
