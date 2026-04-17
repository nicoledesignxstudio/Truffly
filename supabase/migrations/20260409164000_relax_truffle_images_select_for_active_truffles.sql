drop policy if exists truffle_images_select_authenticated on public.truffle_images;

create policy truffle_images_select_authenticated
  on public.truffle_images
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.truffles t
      where t.id = truffle_images.truffle_id
        and t.status = 'active'
    )
  );
