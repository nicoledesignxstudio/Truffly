# Environment Configuration

Truffly uses `--dart-define` as the source of truth for Flutter runtime
configuration.

The Flutter app does not load `.env` files at runtime. Backend secrets live in
Supabase Edge Function secrets or CI secrets, not in the client app.

## Configuration Layers

- `Flutter dart-define`: client runtime configuration passed at launch/build
  time.
- `Supabase Edge Function secret`: backend-only secret used by Deno functions.
- `Codemagic / CI secret`: pipeline secret or environment variable used to
  generate build arguments or deploy backend secrets.
- `External dashboard`: value copied from Supabase, Stripe, Firebase, or Apple
  Developer.

## Client-Safe Defines

These are safe to pass to the Flutter client:

- `APP_ENV`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `STRIPE_PUBLISHABLE_KEY`
- `STRIPE_PUBLISHABLE_KEY_TEST`
- `STRIPE_MERCHANT_IDENTIFIER`
- `STRIPE_MERCHANT_COUNTRY_CODE`
- `STRIPE_GOOGLE_PAY_TEST_ENV`
- `ANDROID_DEVICE_HOST`
- `AUTH_REDIRECT_BASE_URL`

For auth callbacks, `AUTH_REDIRECT_BASE_URL=truffly://auth` generates the
final deep links:

- `truffly://auth/verify-email`
- `truffly://auth/reset-password`

## Backend-Only Secrets

Never put these in the Flutter client:

- `SUPABASE_SERVICE_ROLE_KEY`
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `CRON_SECRET`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_SERVICE_ACCOUNT_JSON`
- `STRIPE_CONNECT_RETURN_URL`
- `STRIPE_CONNECT_REFRESH_URL`

## Local Run

Use `APP_ENV=local` for development.

Before launching the app, start the local Supabase stack in another terminal:

```bash
npx supabase start --debug
```

Android emulator example:

```bash
flutter run \
  --dart-define=APP_ENV=local \
  --dart-define=AUTH_REDIRECT_BASE_URL=truffly://auth \
  --dart-define=SUPABASE_URL=http://10.0.2.2:54321 \
  --dart-define=SUPABASE_ANON_KEY=your-local-anon-key \
  --dart-define=STRIPE_PUBLISHABLE_KEY_TEST=pk_test_your_key
```

Real Android device over USB with `adb reverse`:

```bash
adb reverse tcp:54321 tcp:54321
flutter run \
  --dart-define=APP_ENV=local \
  --dart-define=AUTH_REDIRECT_BASE_URL=truffly://auth \
  --dart-define=SUPABASE_URL=http://127.0.0.1:54321 \
  --dart-define=SUPABASE_ANON_KEY=your-local-anon-key \
  --dart-define=STRIPE_PUBLISHABLE_KEY_TEST=pk_test_your_key \
  --dart-define=ANDROID_DEVICE_HOST=127.0.0.1
```

If you prefer Wi-Fi device testing, point `SUPABASE_URL` to your computer LAN
IP and keep `ANDROID_DEVICE_HOST` aligned with the host the app should reach.

## Staging Run

```bash
flutter run \
  --dart-define=APP_ENV=staging \
  --dart-define=AUTH_REDIRECT_BASE_URL=truffly://auth \
  --dart-define=SUPABASE_URL=https://your-staging-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-staging-anon-key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_or_pk_live_your_key
```

## Production Build

`AUTH_REDIRECT_BASE_URL` is mandatory for release builds. If it is missing,
the app throws during release startup because production auth callbacks must
use the definitive mobile deep link base.

APK:

```bash
flutter build apk \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_REDIRECT_BASE_URL=truffly://auth \
  --dart-define=SUPABASE_URL=https://your-production-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-production-anon-key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_your_key
```

AAB:

```bash
flutter build appbundle \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_REDIRECT_BASE_URL=truffly://auth \
  --dart-define=SUPABASE_URL=https://your-production-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-production-anon-key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_your_key
```

iOS:

```bash
flutter build ipa \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_REDIRECT_BASE_URL=truffly://auth \
  --dart-define=SUPABASE_URL=https://your-production-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-production-anon-key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_your_key
```

## VS Code

[`/.vscode/launch.json`](../.vscode/launch.json) uses `toolArgs` with
`--dart-define`. Set the matching environment variables before launching.

Recommended local shell variables:

- `TRUFFLY_LOCAL_SUPABASE_URL`
- `TRUFFLY_LOCAL_SUPABASE_ANON_KEY`
- `TRUFFLY_STAGING_SUPABASE_URL`
- `TRUFFLY_STAGING_SUPABASE_ANON_KEY`
- `TRUFFLY_STRIPE_PUBLISHABLE_KEY_TEST`
- `TRUFFLY_STRIPE_PUBLISHABLE_KEY`
- `TRUFFLY_ANDROID_DEVICE_HOST`

## Android Studio

Use `Run > Edit Configurations > Additional run args` and pass the same
`--dart-define` values directly.

Example for staging:

```text
--dart-define=APP_ENV=staging
--dart-define=AUTH_REDIRECT_BASE_URL=truffly://auth
--dart-define=SUPABASE_URL=https://your-staging-project-ref.supabase.co
--dart-define=SUPABASE_ANON_KEY=your-staging-anon-key
--dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_or_pk_live_your_key
```

## Codemagic / CI

Pass the values as Flutter arguments or environment-substituted arguments:

```text
--dart-define=APP_ENV=staging
--dart-define=SUPABASE_URL=$SUPABASE_URL
--dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
--dart-define=STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY
--dart-define=AUTH_REDIRECT_BASE_URL=$AUTH_REDIRECT_BASE_URL
```

Keep these values in CI secrets or environment variables. Do not commit them
to the repo.

## Security Rules

- `SUPABASE_SERVICE_ROLE_KEY` must never go into Flutter client code or the
  repo.
- `STRIPE_SECRET_KEY` must never go into Flutter client code.
- `STRIPE_WEBHOOK_SECRET` must never go into Flutter client code.
- `FIREBASE_SERVICE_ACCOUNT_JSON` must never go into Flutter client code.
- `SUPABASE_ANON_KEY` can live in the client app.
- `STRIPE_PUBLISHABLE_KEY` can live in the client app.

## Supabase Auth URL Configuration

In Supabase Dashboard, open Authentication -> URL Configuration and set:

- Site URL: `http://truffly.framer.website`
- Additional Redirect URLs: `http://truffly.framer.website/**`
- Additional Redirect URLs: `truffly://**`

The Framer site is the temporary web fallback. Mobile deep links should open
the app directly through `truffly://`.

Do not use localhost in staging or production auth redirects.

## Backend Docs

For the Supabase Edge Function side, see
[`docs/deploy-secrets.md`](deploy-secrets.md).
