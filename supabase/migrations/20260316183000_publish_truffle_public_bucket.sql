create or replace function public.set_truffle_expiration()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.created_at is null then
    new.created_at := timezone('utc', now());
  end if;

  new.expires_at := new.created_at + interval '5 days';
  return new;
end;
$$;

drop trigger if exists truffles_set_expiration on public.truffles;

create trigger truffles_set_expiration
before insert on public.truffles
for each row
execute function public.set_truffle_expiration();

insert into storage.buckets (id, name, public)
values ('truffle_images', 'truffle_images', true)
on conflict (id) do update
set name = excluded.name,
    public = excluded.public;
