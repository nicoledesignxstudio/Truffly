comment on column public.users.deleted_at is
  'Soft-delete marker only. Historical references in orders, truffles, reviews and audit_logs require anonymization workflows instead of hard deleting users.';

comment on table public.orders is
  'Contains historical commercial records and shipping snapshots. Future account deletion should use anonymization of personal data rather than hard delete.';

comment on table public.audit_logs is
  'Operational audit trail. Retention and future anonymization must preserve incident investigation value while minimizing direct identifiers.';
