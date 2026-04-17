update public.users
set
  stripe_account_id = null,
  stripe_details_submitted = false,
  stripe_charges_enabled = false,
  stripe_payouts_enabled = false,
  stripe_requirements_pending = true,
  stripe_onboarding_completed_at = null,
  stripe_ready_at = null
where id = '33333333-3333-3333-3333-333333333333';
