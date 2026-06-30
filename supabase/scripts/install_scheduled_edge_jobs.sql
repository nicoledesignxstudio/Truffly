-- Run this in the production Supabase SQL editor after replacing placeholders.
-- It schedules protected Edge Functions through pg_cron + pg_net.
--
-- Important: do not leave <PROD_PROJECT_REF> or <PROD_CRON_SECRET> placeholders in this file.
-- The jobs will be installed successfully with placeholder text, but every
-- protected Edge Function call will return 401 and nothing will be processed.

create extension if not exists pg_cron with schema extensions;
create extension if not exists pg_net with schema extensions;

select cron.unschedule(jobname)
from cron.job
where jobname in (
  'truffly-auto-complete-orders',
  'truffly-cancel-unshipped-orders',
  'truffly-retry-financial-operations',
  'truffly-auto-create-missing-reviews',
  'truffly-cleanup-unverified-accounts',
  'truffly-dispatch-notification-pushes'
);

select cron.schedule(
  'truffly-dispatch-notification-pushes',
  '* * * * *',
  $$
  select net.http_post(
    url := 'https://<PROD_PROJECT_REF>.supabase.co/functions/v1/dispatch_notification_pushes',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer <PROD_CRON_SECRET>'
    ),
    body := '{}'::jsonb
  );
  $$
);

select cron.schedule(
  'truffly-auto-complete-orders',
  '*/30 * * * *',
  $$
  select net.http_post(
    url := 'https://<PROD_PROJECT_REF>.supabase.co/functions/v1/auto_complete_orders',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer <PROD_CRON_SECRET>'
    ),
    body := '{}'::jsonb
  );
  $$
);

select cron.schedule(
  'truffly-cancel-unshipped-orders',
  '*/30 * * * *',
  $$
  select net.http_post(
    url := 'https://<PROD_PROJECT_REF>.supabase.co/functions/v1/cancel_unshipped_orders',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer <PROD_CRON_SECRET>'
    ),
    body := '{}'::jsonb
  );
  $$
);

select cron.schedule(
  'truffly-retry-financial-operations',
  '*/15 * * * *',
  $$
  select net.http_post(
    url := 'https://<PROD_PROJECT_REF>.supabase.co/functions/v1/retry_financial_operations',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer <PROD_CRON_SECRET>'
    ),
    body := '{"limit":10}'::jsonb
  );
  $$
);

select cron.schedule(
  'truffly-auto-create-missing-reviews',
  '0 3 * * *',
  $$
  select net.http_post(
    url := 'https://<PROD_PROJECT_REF>.supabase.co/functions/v1/auto_create_missing_reviews',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer <PROD_CRON_SECRET>'
    ),
    body := '{}'::jsonb
  );
  $$
);

select cron.schedule(
  'truffly-cleanup-unverified-accounts',
  '30 3 * * *',
  $$
  select net.http_post(
    url := 'https://<PROD_PROJECT_REF>.supabase.co/functions/v1/cleanup_unverified_accounts',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer <PROD_CRON_SECRET>'
    ),
    body := '{}'::jsonb
  );
  $$
);
