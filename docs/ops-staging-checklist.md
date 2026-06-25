# Staging Ops Checklist

Use this checklist before promoting a staging build or after any backend deploy.

## Supabase And Edge Functions

- Verify the latest migrations are applied in the hosted project.
- Confirm required Edge Functions are deployed and healthy.
- Check Edge Function logs for auth failures, uncaught exceptions, timeouts and payload shape mismatches.
- Confirm no sensitive values appear in logs.
- Review `audit_logs` for recent account, order, publish and financial actions.

## Stripe

- Verify Stripe webhook delivery attempts in the Stripe dashboard.
- Confirm webhook signature verification is succeeding.
- Check for retries, 4xx responses and 5xx responses.
- Review failed financial operation retries in the app/backend tables.
- Confirm payout, refund and order-completion flows are still idempotent.

## Scheduled Jobs

- Check that `cron.job` contains the expected scheduled tasks.
- Confirm the auto-complete, auto-cancel and retry jobs are enabled.
- Verify the next run timestamps are sane for staging.
- Confirm each job has a recent successful execution or a clear reason why it has not run yet.

## Financial Retry Checks

- Review failed payment attempts.
- Review failed refunds.
- Review failed payout releases.
- Confirm retry status transitions are visible in the backend tables.
- Confirm a retry does not duplicate a completed financial action.

## Manual Smoke Test

- Sign in with a staging buyer account.
- Open the account screen and confirm the notifications inbox loads.
- Open settings and confirm the notifications toggle reflects the backend state.
- Upload a profile photo and confirm the avatar updates without restart.
- Open an order and confirm the buyer review flow still works for completed orders.
- Run an account deletion/deactivation flow on a test account.
- Confirm the session logs out after account deletion success.
- Confirm the expected audit trail appears in `audit_logs`.

## Release Gate

- No new feature work should be merged while staging checks are failing.
- Fix the backend first, then re-run the smoke test.
- Keep the staging checklist attached to the deploy request or release notes.
