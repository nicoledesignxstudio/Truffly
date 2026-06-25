-- Run in the Supabase Cloud SQL editor to diagnose order lifecycle issues.
-- This script does not expose secrets.

-- 1) Paid orders older than 48h that should be auto-cancelled.
select
  o.id,
  o.status,
  o.created_at,
  o.paid_at,
  o.truffle_id,
  t.status as truffle_status,
  t.expires_at,
  now() as checked_at
from public.orders o
join public.truffles t on t.id = o.truffle_id
where o.status = 'paid'
  and o.created_at <= now() - interval '48 hours'
order by o.created_at asc;

-- 2) Cron job definitions. Verify cancel_unshipped_orders URL is the real
-- project ref and the Authorization header is not the literal placeholder.
select
  jobid,
  jobname,
  schedule,
  active,
  command
from cron.job
where jobname in (
  'truffly-auto-complete-orders',
  'truffly-cancel-unshipped-orders',
  'truffly-retry-financial-operations',
  'truffly-auto-create-missing-reviews',
  'truffly-cleanup-unverified-accounts'
)
order by jobname;

-- 3) Recent pg_net responses for scheduled HTTP calls.
-- Status 401 means the CRON_SECRET/header is wrong.
-- Status 404 usually means URL/project-ref/function name is wrong.
select
  id,
  status_code,
  timed_out,
  error_msg,
  created
from net._http_response
order by created desc
limit 50;

-- 4) Installed RPC definitions. The cancel_order_after_refund function should
-- contain order_auto_cancelled_unshipped_48h_* and auto review logic.
select
  p.proname,
  pg_get_functiondef(p.oid) as definition
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'cancel_order_after_refund',
    'update_order_status_atomic'
  )
order by p.proname;

-- 5) Compare one failed old order and one working new order.
-- Replace the two UUIDs below with your real order ids.
with target_orders as (
  select 'old_failed'::text as label, '00000000-0000-0000-0000-000000000000'::uuid as order_id
  union all
  select 'new_working'::text as label, '11111111-1111-1111-1111-111111111111'::uuid as order_id
)
select
  t.label,
  o.id as order_id,
  o.status as order_status,
  o.created_at,
  o.paid_at,
  o.shipped_at,
  o.completed_at,
  o.cancelled_at,
  o.tracking_code,
  o.truffle_id,
  tr.status as truffle_status,
  tr.expires_at as truffle_expires_at,
  (
    select jsonb_agg(
      jsonb_build_object(
        'id', fo.id,
        'kind', fo.kind,
        'status', fo.status,
        'logical_key', fo.logical_key,
        'failure_code', fo.failure_code,
        'failure_message', fo.failure_message,
        'trigger_source', fo.trigger_source,
        'request_id', fo.request_id,
        'created_at', fo.created_at,
        'processed_at', fo.processed_at
      )
      order by fo.created_at asc
    )
    from public.order_financial_operations fo
    where fo.order_id = o.id
  ) as order_financial_operations,
  (
    select jsonb_agg(
      jsonb_build_object(
        'id', pa.id,
        'status', pa.status,
        'failure_code', pa.failure_code,
        'failure_message', pa.failure_message,
        'stripe_payment_intent_id', pa.stripe_payment_intent_id,
        'created_at', pa.created_at,
        'updated_at', pa.updated_at
      )
      order by pa.created_at asc
    )
    from public.payment_attempts pa
    where pa.order_id = o.id
  ) as payment_attempts,
  (
    select jsonb_agg(
      jsonb_build_object(
        'id', a.id,
        'action', a.action,
        'performed_by', a.performed_by,
        'metadata', a.metadata,
        'created_at', a.created_at
      )
      order by a.created_at asc
    )
    from public.audit_logs a
    where a.entity_type = 'order'
      and a.entity_id = o.id
  ) as audit_logs,
  (
    select jsonb_agg(
      jsonb_build_object(
        'id', r.id,
        'rating', r.rating,
        'is_auto', r.is_auto,
        'auto_created_at', r.auto_created_at,
        'comment', r.comment,
        'created_at', r.created_at
      )
      order by r.created_at asc
    )
    from public.reviews r
    where r.order_id = o.id
  ) as reviews,
  (
    select jsonb_agg(
      jsonb_build_object(
        'id', n.id,
        'type', n.type,
        'user_id', n.user_id,
        'message', n.message,
        'created_at', n.created_at
      )
      order by n.created_at asc
    )
    from public.notifications n
    where n.metadata ->> 'order_id' = o.id::text
       or n.message ilike '%' || o.id::text || '%'
  ) as notifications
from target_orders t
left join public.orders o on o.id = t.order_id
left join public.truffles tr on tr.id = o.truffle_id
order by t.label;
