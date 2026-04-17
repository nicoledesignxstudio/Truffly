create index if not exists audit_logs_request_id_idx
  on public.audit_logs ((metadata->>'request_id'))
  where metadata ? 'request_id';

create index if not exists audit_logs_action_created_at_idx
  on public.audit_logs (action, created_at desc);
