insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
)
values
(
  '00000000-0000-0000-0000-000000000000',
  '11111111-1111-1111-1111-111111111111',
  'authenticated',
  'authenticated',
  'buyer@test.com',
  crypt('DevPass123!', gen_salt('bf')),
  timezone('utc', now()),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()),
  timezone('utc', now()),
  '',
  '',
  '',
  ''
),
(
  '00000000-0000-0000-0000-000000000000',
  '22222222-2222-2222-2222-222222222222',
  'authenticated',
  'authenticated',
  'seller1@test.com',
  crypt('DevPass123!', gen_salt('bf')),
  timezone('utc', now()),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()),
  timezone('utc', now()),
  '',
  '',
  '',
  ''
),
(
  '00000000-0000-0000-0000-000000000000',
  '33333333-3333-3333-3333-333333333333',
  'authenticated',
  'authenticated',
  'seller2@test.com',
  crypt('DevPass123!', gen_salt('bf')),
  timezone('utc', now()),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()),
  timezone('utc', now()),
  '',
  '',
  '',
  ''
),
(
  '00000000-0000-0000-0000-000000000000',
  '44444444-4444-4444-4444-444444444444',
  'authenticated',
  'authenticated',
  'seller3@test.com',
  crypt('DevPass123!', gen_salt('bf')),
  timezone('utc', now()),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()),
  timezone('utc', now()),
  '',
  '',
  '',
  ''
),
(
  '00000000-0000-0000-0000-000000000000',
  '55555555-5555-5555-5555-555555555555',
  'authenticated',
  'authenticated',
  'seller4@test.com',
  crypt('DevPass123!', gen_salt('bf')),
  timezone('utc', now()),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()),
  timezone('utc', now()),
  '',
  '',
  '',
  ''
),
(
  '00000000-0000-0000-0000-000000000000',
  '66666666-6666-6666-6666-666666666666',
  'authenticated',
  'authenticated',
  'seller5@test.com',
  crypt('DevPass123!', gen_salt('bf')),
  timezone('utc', now()),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()),
  timezone('utc', now()),
  '',
  '',
  '',
  ''
),
(
  '00000000-0000-0000-0000-000000000000',
  '77777777-7777-7777-7777-777777777777',
  'authenticated',
  'authenticated',
  'seller6@test.com',
  crypt('DevPass123!', gen_salt('bf')),
  timezone('utc', now()),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()),
  timezone('utc', now()),
  '',
  '',
  '',
  ''
),
(
  '00000000-0000-0000-0000-000000000000',
  '88888888-8888-8888-8888-888888888888',
  'authenticated',
  'authenticated',
  'seller7@test.com',
  crypt('DevPass123!', gen_salt('bf')),
  timezone('utc', now()),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()),
  timezone('utc', now()),
  '',
  '',
  '',
  ''
)
on conflict (id) do update
set
  instance_id = excluded.instance_id,
  aud = excluded.aud,
  role = excluded.role,
  email = excluded.email,
  encrypted_password = excluded.encrypted_password,
  email_confirmed_at = excluded.email_confirmed_at,
  raw_app_meta_data = excluded.raw_app_meta_data,
  raw_user_meta_data = excluded.raw_user_meta_data,
  updated_at = excluded.updated_at,
  confirmation_token = excluded.confirmation_token,
  email_change = excluded.email_change,
  email_change_token_new = excluded.email_change_token_new,
  recovery_token = excluded.recovery_token;

insert into auth.identities (
  id,
  user_id,
  identity_data,
  provider,
  provider_id,
  last_sign_in_at,
  created_at,
  updated_at
)
values
(
  gen_random_uuid(),
  '11111111-1111-1111-1111-111111111111',
  format(
    '{"sub":"%s","email":"%s","email_verified":true,"phone_verified":false}',
    '11111111-1111-1111-1111-111111111111',
    'buyer@test.com'
  )::jsonb,
  'email',
  'buyer@test.com',
  timezone('utc', now()),
  timezone('utc', now()),
  timezone('utc', now())
),
(
  gen_random_uuid(),
  '22222222-2222-2222-2222-222222222222',
  format(
    '{"sub":"%s","email":"%s","email_verified":true,"phone_verified":false}',
    '22222222-2222-2222-2222-222222222222',
    'seller1@test.com'
  )::jsonb,
  'email',
  'seller1@test.com',
  timezone('utc', now()),
  timezone('utc', now()),
  timezone('utc', now())
),
(
  gen_random_uuid(),
  '33333333-3333-3333-3333-333333333333',
  format(
    '{"sub":"%s","email":"%s","email_verified":true,"phone_verified":false}',
    '33333333-3333-3333-3333-333333333333',
    'seller2@test.com'
  )::jsonb,
  'email',
  'seller2@test.com',
  timezone('utc', now()),
  timezone('utc', now()),
  timezone('utc', now())
),
(
  gen_random_uuid(),
  '44444444-4444-4444-4444-444444444444',
  format(
    '{"sub":"%s","email":"%s","email_verified":true,"phone_verified":false}',
    '44444444-4444-4444-4444-444444444444',
    'seller3@test.com'
  )::jsonb,
  'email',
  'seller3@test.com',
  timezone('utc', now()),
  timezone('utc', now()),
  timezone('utc', now())
),
(
  gen_random_uuid(),
  '55555555-5555-5555-5555-555555555555',
  format(
    '{"sub":"%s","email":"%s","email_verified":true,"phone_verified":false}',
    '55555555-5555-5555-5555-555555555555',
    'seller4@test.com'
  )::jsonb,
  'email',
  'seller4@test.com',
  timezone('utc', now()),
  timezone('utc', now()),
  timezone('utc', now())
),
(
  gen_random_uuid(),
  '66666666-6666-6666-6666-666666666666',
  format(
    '{"sub":"%s","email":"%s","email_verified":true,"phone_verified":false}',
    '66666666-6666-6666-6666-666666666666',
    'seller5@test.com'
  )::jsonb,
  'email',
  'seller5@test.com',
  timezone('utc', now()),
  timezone('utc', now()),
  timezone('utc', now())
),
(
  gen_random_uuid(),
  '77777777-7777-7777-7777-777777777777',
  format(
    '{"sub":"%s","email":"%s","email_verified":true,"phone_verified":false}',
    '77777777-7777-7777-7777-777777777777',
    'seller6@test.com'
  )::jsonb,
  'email',
  'seller6@test.com',
  timezone('utc', now()),
  timezone('utc', now()),
  timezone('utc', now())
),
(
  gen_random_uuid(),
  '88888888-8888-8888-8888-888888888888',
  format(
    '{"sub":"%s","email":"%s","email_verified":true,"phone_verified":false}',
    '88888888-8888-8888-8888-888888888888',
    'seller7@test.com'
  )::jsonb,
  'email',
  'seller7@test.com',
  timezone('utc', now()),
  timezone('utc', now()),
  timezone('utc', now())
)
on conflict (provider, provider_id) do update
set
  user_id = excluded.user_id,
  identity_data = excluded.identity_data,
  last_sign_in_at = excluded.last_sign_in_at,
  updated_at = excluded.updated_at;
  
-- EXTRA BUYERS FOR RICHER TEST DATA

insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
)
values
(
  '00000000-0000-0000-0000-000000000000',
  '99999999-9999-9999-9999-999999999991',
  'authenticated',
  'authenticated',
  'buyer2@test.com',
  crypt('DevPass123!', gen_salt('bf')),
  timezone('utc', now()),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()) - interval '30 days',
  timezone('utc', now()) - interval '2 days',
  '',
  '',
  '',
  ''
),
(
  '00000000-0000-0000-0000-000000000000',
  '99999999-9999-9999-9999-999999999992',
  'authenticated',
  'authenticated',
  'buyer3@test.com',
  crypt('DevPass123!', gen_salt('bf')),
  timezone('utc', now()),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()) - interval '18 days',
  timezone('utc', now()) - interval '1 day',
  '',
  '',
  '',
  ''
),
(
  '00000000-0000-0000-0000-000000000000',
  '99999999-9999-9999-9999-999999999993',
  'authenticated',
  'authenticated',
  'buyer4@test.com',
  crypt('DevPass123!', gen_salt('bf')),
  timezone('utc', now()),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()) - interval '8 days',
  timezone('utc', now()) - interval '8 hours',
  '',
  '',
  '',
  ''
)
on conflict (id) do update
set
  email = excluded.email,
  encrypted_password = excluded.encrypted_password,
  email_confirmed_at = excluded.email_confirmed_at,
  updated_at = excluded.updated_at;

insert into auth.identities (
  id,
  user_id,
  identity_data,
  provider,
  provider_id,
  last_sign_in_at,
  created_at,
  updated_at
)
values
(
  gen_random_uuid(),
  '99999999-9999-9999-9999-999999999991',
  format(
    '{"sub":"%s","email":"%s","email_verified":true,"phone_verified":false}',
    '99999999-9999-9999-9999-999999999991',
    'buyer2@test.com'
  )::jsonb,
  'email',
  'buyer2@test.com',
  timezone('utc', now()),
  timezone('utc', now()),
  timezone('utc', now())
),
(
  gen_random_uuid(),
  '99999999-9999-9999-9999-999999999992',
  format(
    '{"sub":"%s","email":"%s","email_verified":true,"phone_verified":false}',
    '99999999-9999-9999-9999-999999999992',
    'buyer3@test.com'
  )::jsonb,
  'email',
  'buyer3@test.com',
  timezone('utc', now()),
  timezone('utc', now()),
  timezone('utc', now())
),
(
  gen_random_uuid(),
  '99999999-9999-9999-9999-999999999993',
  format(
    '{"sub":"%s","email":"%s","email_verified":true,"phone_verified":false}',
    '99999999-9999-9999-9999-999999999993',
    'buyer4@test.com'
  )::jsonb,
  'email',
  'buyer4@test.com',
  timezone('utc', now()),
  timezone('utc', now()),
  timezone('utc', now())
)
on conflict (provider, provider_id) do update
set
  user_id = excluded.user_id,
  identity_data = excluded.identity_data,
  last_sign_in_at = excluded.last_sign_in_at,
  updated_at = excluded.updated_at;

update public.users set
  role = 'buyer',
  seller_status = 'not_requested',
  first_name = 'Elena',
  last_name = 'Marini',
  profile_image_url = 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=800&q=80',
  country_code = 'IT',
  region = 'LAZIO',
  is_active = true,
  onboarding_completed = true,
  created_at = timezone('utc', now()) - interval '30 days'
where id = '99999999-9999-9999-9999-999999999991';

update public.users set
  role = 'buyer',
  seller_status = 'not_requested',
  first_name = 'Davide',
  last_name = 'Greco',
  profile_image_url = null,
  country_code = 'IT',
  region = 'LOMBARDIA',
  is_active = true,
  onboarding_completed = true,
  created_at = timezone('utc', now()) - interval '18 days'
where id = '99999999-9999-9999-9999-999999999992';

update public.users set
  role = 'buyer',
  seller_status = 'not_requested',
  first_name = 'Chiara',
  last_name = 'Villa',
  profile_image_url = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=800&q=80',
  country_code = 'FR',
  region = null,
  is_active = true,
  onboarding_completed = true,
  created_at = timezone('utc', now()) - interval '8 days'
where id = '99999999-9999-9999-9999-999999999993';

update public.users set
role='buyer',
seller_status='not_requested',
first_name='Buyer',
last_name='Test',
country_code='IT',
region='TOSCANA',
is_active=true,
onboarding_completed=true
where id='11111111-1111-1111-1111-111111111111';

-- ENRICH MAIN TEST ACCOUNTS

update public.users set
  first_name = 'Nicole',
  last_name = 'Test',
  profile_image_url = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
  country_code = 'IT',
  region = 'TOSCANA',
  is_active = true,
  onboarding_completed = true,
  created_at = timezone('utc', now()) - interval '45 days'
where id = '11111111-1111-1111-1111-111111111111';

update public.users set
  role = 'seller',
  seller_status = 'approved',
  stripe_account_id = 'acct_test_1',
  first_name = 'Marco',
  last_name = 'Bianchi',
  bio = 'Tartufaio in Piemonte, specializzato in scorzone e nero pregiato. Raccolta selezionata e spedizione rapida.',
  profile_image_url = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
  country_code = 'IT',
  region = 'PIEMONTE',
  is_active = true,
  onboarding_completed = true,
  created_at = timezone('utc', now()) - interval '120 days'
where id = '22222222-2222-2222-2222-222222222222';

update public.users set
  role = 'seller',
  seller_status = 'approved',
  stripe_account_id = 'acct_test_2',
  first_name = 'Giulia',
  last_name = 'Rossi',
  profile_image_url = null,
  country_code = 'IT',
  region = 'TOSCANA',
  is_active = true,
  onboarding_completed = true
where id = '33333333-3333-3333-3333-333333333333';

update public.users set
role='seller',
seller_status='approved',
stripe_account_id='acct_test_3',
first_name='Andrea',
last_name='Neri',
profile_image_url='https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
country_code='IT',
region='UMBRIA',
is_active=true,
onboarding_completed=true
where id='44444444-4444-4444-4444-444444444444';

update public.users set
role='seller',
seller_status='approved',
stripe_account_id='acct_test_4',
first_name='Paolo',
last_name='Conti',
profile_image_url=null,
country_code='IT',
region='MARCHE',
is_active=true,
onboarding_completed=true
where id='55555555-5555-5555-5555-555555555555';

update public.users set
role='seller',
seller_status='approved',
stripe_account_id='acct_test_5',
first_name='Francesca',
last_name='Moretti',
profile_image_url='https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
country_code='IT',
region='LAZIO',
is_active=true,
onboarding_completed=true
where id='66666666-6666-6666-6666-666666666666';

update public.users set
role='seller',
seller_status='approved',
stripe_account_id='acct_test_6',
first_name='Luca',
last_name='Ferrari',
profile_image_url=null,
country_code='IT',
region='LOMBARDIA',
is_active=true,
onboarding_completed=true
where id='77777777-7777-7777-7777-777777777777';

update public.users set
role='seller',
seller_status='approved',
stripe_account_id='acct_test_7',
first_name='Sara',
last_name='Romano',
profile_image_url='https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=800&q=80',
country_code='IT',
region='VENETO',
is_active=true,
onboarding_completed=true
where id='88888888-8888-8888-8888-888888888888';

-- =====================================================
-- TRUFFLES (REPLACE YOUR CURRENT TRUFFLES INSERT BLOCK)
-- =====================================================

insert into public.truffles (
  id,
  seller_id,
  truffle_type,
  quality,
  weight_grams,
  price_total,
  shipping_price_italy,
  shipping_price_abroad,
  region,
  harvest_date,
  status,
  expires_at,
  created_at
)
values
-- seller1 Marco Bianchi -> strong seller, mixed inventory
('a1111111-1111-1111-1111-111111111111','22222222-2222-2222-2222-222222222222','TUBER_MELANOSPORUM','FIRST',55,145,8,20,'PIEMONTE',current_date-1,'active',now()+interval '4 days', now()-interval '1 day'),
('a1111111-1111-1111-1111-111111111112','22222222-2222-2222-2222-222222222222','TUBER_AESTIVUM','SECOND',95,68,6,15,'PIEMONTE',current_date-4,'active',now()+interval '2 days', now()-interval '3 days'),
('a1111111-1111-1111-1111-111111111113','22222222-2222-2222-2222-222222222222','TUBER_BRUMALE','SECOND',70,79,7,18,'PIEMONTE',current_date-10,'sold',now()+interval '1 day', now()-interval '9 days'),
('a1111111-1111-1111-1111-111111111114','22222222-2222-2222-2222-222222222222','TUBER_UNCINATUM','FIRST',80,118,7,18,'PIEMONTE',current_date-14,'expired',now()-interval '2 days', now()-interval '10 days'),

-- seller2 Giulia Rossi -> new seller, no reviews yet
('a2222222-2222-2222-2222-222222222221','33333333-3333-3333-3333-333333333333','TUBER_UNCINATUM','FIRST',72,92,7,18,'TOSCANA',current_date-1,'active',now()+interval '5 days', now()-interval '12 hours'),
('a2222222-2222-2222-2222-222222222222','33333333-3333-3333-3333-333333333333','TUBER_BORCHII','FIRST',38,112,7,18,'TOSCANA',current_date-2,'active',now()+interval '4 days', now()-interval '1 day'),

-- seller3 Andrea Neri -> reviewed and premium
('a3333333-3333-3333-3333-333333333331','44444444-4444-4444-4444-444444444444','TUBER_MAGNATUM','FIRST',42,290,10,25,'UMBRIA',current_date-1,'active',now()+interval '5 days', now()-interval '8 hours'),
('a3333333-3333-3333-3333-333333333332','44444444-4444-4444-4444-444444444444','TUBER_BRUMALE','SECOND',60,74,7,18,'UMBRIA',current_date-6,'sold',now()+interval '1 day', now()-interval '5 days'),
('a3333333-3333-3333-3333-333333333333','44444444-4444-4444-4444-444444444444','TUBER_MELANOSPORUM','FIRST',50,152,8,20,'UMBRIA',current_date-3,'active',now()+interval '3 days', now()-interval '2 days'),

-- seller4 Paolo Conti -> average rating, some cancelled history
('a4444444-4444-4444-4444-444444444441','55555555-5555-5555-5555-555555555555','TUBER_MAGNATUM','SECOND',30,195,10,25,'MARCHE',current_date-2,'active',now()+interval '5 days', now()-interval '1 day'),
('a4444444-4444-4444-4444-444444444442','55555555-5555-5555-5555-555555555555','TUBER_BORCHII','FIRST',45,118,7,18,'MARCHE',current_date-8,'sold',now()+interval '1 day', now()-interval '7 days'),
('a4444444-4444-4444-4444-444444444443','55555555-5555-5555-5555-555555555555','TUBER_AESTIVUM','THIRD',110,52,6,15,'MARCHE',current_date-12,'expired',now()-interval '1 day', now()-interval '8 days'),

-- seller5 Francesca Moretti -> excellent seller
('a5555555-5555-5555-5555-555555555551','66666666-6666-6666-6666-666666666666','TUBER_MELANOSPORUM','FIRST',48,142,8,20,'LAZIO',current_date-1,'active',now()+interval '5 days', now()-interval '5 hours'),
('a5555555-5555-5555-5555-555555555552','66666666-6666-6666-6666-666666666666','TUBER_MELANOSPORUM','THIRD',88,82,8,20,'LAZIO',current_date-9,'sold',now()+interval '1 day', now()-interval '8 days'),
('a5555555-5555-5555-5555-555555555553','66666666-6666-6666-6666-666666666666','TUBER_AESTIVUM','SECOND',120,66,6,15,'LAZIO',current_date-2,'active',now()+interval '5 days', now()-interval '1 day'),

-- seller6 Luca Ferrari -> active order in progress
('a6666666-6666-6666-6666-666666666661','77777777-7777-7777-7777-777777777777','TUBER_MELANOSPORUM','SECOND',62,124,8,20,'LOMBARDIA',current_date-2,'sold',now()+interval '2 days', now()-interval '2 days'),
('a6666666-6666-6666-6666-666666666662','77777777-7777-7777-7777-777777777777','TUBER_AESTIVUM','SECOND',125,64,6,15,'LOMBARDIA',current_date-2,'active',now()+interval '4 days', now()-interval '1 day'),

-- seller7 Sara Romano -> very polished profile, few but strong sales
('a7777777-7777-7777-7777-777777777771','88888888-8888-8888-8888-888888888888','TUBER_AESTIVUM','FIRST',82,72,6,15,'VENETO',current_date-1,'active',now()+interval '5 days', now()-interval '6 hours'),
('a7777777-7777-7777-7777-777777777772','88888888-8888-8888-8888-888888888888','TUBER_MAGNATUM','SECOND',34,210,10,25,'VENETO',current_date-5,'sold',now()+interval '2 days', now()-interval '4 days'),
('a7777777-7777-7777-7777-777777777773','88888888-8888-8888-8888-888888888888','TUBER_BRUMALE','SECOND',66,78,7,18,'VENETO',current_date-11,'expired',now()-interval '2 days', now()-interval '9 days');

-- =====================================================
-- TRUFFLE IMAGES (REPLACE YOUR CURRENT IMAGES BLOCK)
-- =====================================================

insert into public.truffle_images (id, truffle_id, image_url, order_index)
values
(gen_random_uuid(),'a1111111-1111-1111-1111-111111111111','https://images.unsplash.com/photo-1603048297172-c92544798d5a?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a1111111-1111-1111-1111-111111111111','https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=1200&q=80',2),

(gen_random_uuid(),'a1111111-1111-1111-1111-111111111112','https://images.unsplash.com/photo-1471193945509-9ad0617afabf?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a1111111-1111-1111-1111-111111111113','https://images.unsplash.com/photo-1471193945509-9ad0617afabf?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a1111111-1111-1111-1111-111111111114','https://images.unsplash.com/photo-1603048297172-c92544798d5a?auto=format&fit=crop&w=1200&q=80',1),

(gen_random_uuid(),'a2222222-2222-2222-2222-222222222221','https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a2222222-2222-2222-2222-222222222222','https://images.unsplash.com/photo-1603048297172-c92544798d5a?auto=format&fit=crop&w=1200&q=80',1),

(gen_random_uuid(),'a3333333-3333-3333-3333-333333333331','https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a3333333-3333-3333-3333-333333333331','https://images.unsplash.com/photo-1603048297172-c92544798d5a?auto=format&fit=crop&w=1200&q=80',2),
(gen_random_uuid(),'a3333333-3333-3333-3333-333333333332','https://images.unsplash.com/photo-1471193945509-9ad0617afabf?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a3333333-3333-3333-3333-333333333333','https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=1200&q=80',1),

(gen_random_uuid(),'a4444444-4444-4444-4444-444444444441','https://images.unsplash.com/photo-1603048297172-c92544798d5a?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a4444444-4444-4444-4444-444444444442','https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a4444444-4444-4444-4444-444444444443','https://images.unsplash.com/photo-1471193945509-9ad0617afabf?auto=format&fit=crop&w=1200&q=80',1),

(gen_random_uuid(),'a5555555-5555-5555-5555-555555555551','https://images.unsplash.com/photo-1603048297172-c92544798d5a?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a5555555-5555-5555-5555-555555555552','https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a5555555-5555-5555-5555-555555555553','https://images.unsplash.com/photo-1471193945509-9ad0617afabf?auto=format&fit=crop&w=1200&q=80',1),

(gen_random_uuid(),'a6666666-6666-6666-6666-666666666661','https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a6666666-6666-6666-6666-666666666662','https://images.unsplash.com/photo-1471193945509-9ad0617afabf?auto=format&fit=crop&w=1200&q=80',1),

(gen_random_uuid(),'a7777777-7777-7777-7777-777777777771','https://images.unsplash.com/photo-1471193945509-9ad0617afabf?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a7777777-7777-7777-7777-777777777772','https://images.unsplash.com/photo-1603048297172-c92544798d5a?auto=format&fit=crop&w=1200&q=80',1),
(gen_random_uuid(),'a7777777-7777-7777-7777-777777777773','https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=1200&q=80',1);

insert into public.shipping_addresses (
  id, user_id, full_name, street, city, postal_code, country_code, phone, is_default, created_at
)
values
(gen_random_uuid(),'11111111-1111-1111-1111-111111111111','Nicole Test','Via delle Colline 12','Firenze','50121','IT','3331111111',true, now()-interval '40 days'),
(gen_random_uuid(),'11111111-1111-1111-1111-111111111111','Nicole Test','Via del Centro 9','Siena','53100','IT','3331111111',false, now()-interval '10 days'),
(gen_random_uuid(),'99999999-9999-9999-9999-999999999991','Elena Marini','Via Appia 41','Roma','00183','IT','3332222222',true, now()-interval '20 days'),
(gen_random_uuid(),'99999999-9999-9999-9999-999999999992','Davide Greco','Via Torino 8','Milano','20123','IT','3333333333',true, now()-interval '12 days'),
(gen_random_uuid(),'99999999-9999-9999-9999-999999999993','Chiara Villa','10 Rue Victor Hugo','Lyon','69002','FR','+33612345678',true, now()-interval '5 days');

insert into public.orders (
  id,
  truffle_id,
  buyer_id,
  seller_id,
  status,
  tracking_code,
  shipping_full_name,
  shipping_street,
  shipping_city,
  shipping_postal_code,
  shipping_country_code,
  shipping_phone,
  total_price,
  commission_amount,
  seller_amount,
  stripe_payment_intent_id,
  created_at
)
values
-- buyer main test account: one completed, one in progress (paid)
('b1111111-1111-1111-1111-111111111111','a1111111-1111-1111-1111-111111111113','11111111-1111-1111-1111-111111111111','22222222-2222-2222-2222-222222222222','completed','TRK-PIE-001','Nicole Test','Via delle Colline 12','Firenze','50121','IT','3331111111',79,7.90,71.10,'pi_test_completed_1', now()-interval '7 days'),
('b1111111-1111-1111-1111-111111111112','a6666666-6666-6666-6666-666666666661','11111111-1111-1111-1111-111111111111','77777777-7777-7777-7777-777777777777','paid',null,'Nicole Test','Via delle Colline 12','Firenze','50121','IT','3331111111',124,12.40,111.60,'pi_test_paid_1', now()-interval '8 hours'),

-- buyer2: one completed, one cancelled
('b2222222-2222-2222-2222-222222222221','a3333333-3333-3333-3333-333333333332','99999999-9999-9999-9999-999999999991','44444444-4444-4444-4444-444444444444','completed','TRK-UMB-002','Elena Marini','Via Appia 41','Roma','00183','IT','3332222222',74,7.40,66.60,'pi_test_completed_2', now()-interval '5 days'),
('b2222222-2222-2222-2222-222222222222','a4444444-4444-4444-4444-444444444442','99999999-9999-9999-9999-999999999991','55555555-5555-5555-5555-555555555555','cancelled',null,'Elena Marini','Via Appia 41','Roma','00183','IT','3332222222',118,11.80,106.20,'pi_test_cancelled_1', now()-interval '3 days'),

-- buyer3: one shipped in progress
('b3333333-3333-3333-3333-333333333331','a7777777-7777-7777-7777-777777777772','99999999-9999-9999-9999-999999999992','88888888-8888-8888-8888-888888888888','shipped','TRK-VEN-003','Davide Greco','Via Torino 8','Milano','20123','IT','3333333333',210,21.00,189.00,'pi_test_shipped_1', now()-interval '2 days'),

-- buyer4 international: one completed, useful for abroad shipping scenarios
('b4444444-4444-4444-4444-444444444441','a5555555-5555-5555-5555-555555555552','99999999-9999-9999-9999-999999999993','66666666-6666-6666-6666-666666666666','completed','TRK-LAZ-004','Chiara Villa','10 Rue Victor Hugo','Lyon','69002','FR','+33612345678',82,8.20,73.80,'pi_test_completed_3', now()-interval '6 days');

insert into public.reviews (
  id,
  order_id,
  rating,
  comment,
  created_at
)
values
(gen_random_uuid(),'b1111111-1111-1111-1111-111111111111',5,'Tartufo molto profumato e spedizione perfetta. Venditore super affidabile.', now()-interval '6 days'),
(gen_random_uuid(),'b2222222-2222-2222-2222-222222222221',4,'Prodotto ottimo, arrivato fresco. Esperienza positiva.', now()-interval '4 days'),
(gen_random_uuid(),'b4444444-4444-4444-4444-444444444441',5,'Qualità eccellente e ottimo packaging per spedizione all’estero.', now()-interval '5 days');

insert into public.notifications (id, user_id, type, message, read, created_at)
values
(gen_random_uuid(),'11111111-1111-1111-1111-111111111111','order_completed','Il tuo ordine è stato completato con successo.',false, now()-interval '6 days'),
(gen_random_uuid(),'11111111-1111-1111-1111-111111111111','order_paid','Il tuo ordine è stato confermato ed è in attesa di spedizione.',false, now()-interval '8 hours'),
(gen_random_uuid(),'22222222-2222-2222-2222-222222222222','order_completed','Hai completato una vendita su Truffly.',true, now()-interval '6 days'),
(gen_random_uuid(),'77777777-7777-7777-7777-777777777777','order_paid','Hai ricevuto un nuovo ordine da spedire entro 48 ore.',false, now()-interval '8 hours'),
(gen_random_uuid(),'88888888-8888-8888-8888-888888888888','order_shipped','Il tuo ordine risulta spedito.',true, now()-interval '1 day');

update public.users
set
  seller_review_count = 1,
  seller_rating_avg = 5.0
where id = '22222222-2222-2222-2222-222222222222';

update public.users
set
  seller_review_count = 0,
  seller_rating_avg = 0.0
where id = '33333333-3333-3333-3333-333333333333';

update public.users
set
  seller_review_count = 1,
  seller_rating_avg = 4.0
where id = '44444444-4444-4444-4444-444444444444';

update public.users
set
  seller_review_count = 0,
  seller_rating_avg = 0.0
where id = '55555555-5555-5555-5555-555555555555';

update public.users
set
  seller_review_count = 1,
  seller_rating_avg = 5.0
where id = '66666666-6666-6666-6666-666666666666';

update public.users
set
  seller_review_count = 0,
  seller_rating_avg = 0.0
where id = '77777777-7777-7777-7777-777777777777';

update public.users
set
  seller_review_count = 0,
  seller_rating_avg = 0.0
where id = '88888888-8888-8888-8888-888888888888';

insert into public.truffle_season_windows (
  season_year,
  truffle_type,
  start_date,
  end_date,
  priority,
  title_it,
  subtitle_it,
  title_en,
  subtitle_en,
  image_key,
  is_enabled
)
values
(
  2026,
  'TUBER_MAGNATUM',
  '2026-10-01',
  '2027-01-31',
  1,
  'È il momento del Tartufo Bianco',
  'Il più pregiato della stagione è finalmente disponibile: scopri i tartufi freschi pubblicati dai venditori.',
  'White Truffle Season',
  'The most prized truffle of the season is finally here. Discover fresh listings from verified sellers.',
  'seasonal/tuber_magnatum',
  true
),
(
  2026,
  'TUBER_MELANOSPORUM',
  '2026-11-01',
  '2027-03-31',
  2,
  'Stagione del Nero Pregiato',
  'Intenso, elegante e ricercato: esplora uno dei tartufi più amati della cucina italiana.',
  'Black Winter Truffle Season',
  'Intense, elegant and highly prized. Explore one of Italy’s most loved truffles.',
  'seasonal/tuber_melanosporum',
  true
),
(
  2026,
  'TUBER_BORCHII',
  '2026-01-15',
  '2026-04-30',
  3,
  'È arrivato il Bianchetto',
  'Il tartufo che annuncia la primavera, con profumo deciso e carattere unico.',
  'Bianchetto Season',
  'The truffle that announces spring, with a bold aroma and distinctive character.',
  'seasonal/tuber_borchii',
  true
),
(
  2026,
  'TUBER_BRUMALE',
  '2026-01-01',
  '2026-04-15',
  4,
  'Stagione del Brumale',
  'Scuro, aromatico e invernale: una scelta perfetta per chi ama sapori profondi.',
  'Brumale Season',
  'Dark, aromatic and wintry, perfect for those who love deeper flavors.',
  'seasonal/tuber_brumale',
  true
),
(
  2026,
  'TUBER_UNCINATUM',
  '2026-09-15',
  '2027-01-31',
  5,
  'È tempo di Uncinato',
  'Un tartufo aromatico e autunnale, ideale per chi cerca profumi più persistenti.',
  'Uncinato Season',
  'An aromatic autumn truffle, ideal for those who enjoy more persistent earthy notes.',
  'seasonal/tuber_uncinatum',
  true
),
(
  2026,
  'TUBER_AESTIVUM',
  '2026-05-01',
  '2026-12-31',
  6,
  'Arriva lo Scorzone',
  'Il tartufo dell’estate e dell’inizio autunno: versatile, fresco e perfetto da scoprire.',
  'Scorzone Season',
  'The truffle of summer and early autumn: versatile, fresh and easy to enjoy.',
  'seasonal/tuber_aestivum',
  true
),
(
  2026,
  'TUBER_MACROSPORUM',
  '2026-09-01',
  '2026-12-31',
  7,
  'Stagione del Nero Liscio',
  'Un nero aromatico e raffinato, con note persistenti ideali per preparazioni intense.',
  'Smooth Black Truffle Season',
  'A refined aromatic black truffle with persistent notes, perfect for deeper preparations.',
  'seasonal/tuber_macrosporum',
  true
),
(
  2026,
  'TUBER_BRUMALE_MOSCHATUM',
  '2026-12-01',
  '2027-03-15',
  8,
  'Stagione del Brumale Moscato',
  'Profumo deciso e speziato: scopri il lato più muschiato della stagione invernale.',
  'Musky Brumal Truffle Season',
  'Bold and spicy aroma: discover the musky side of the winter season.',
  'seasonal/tuber_brumale_moschatum',
  true
),
(
  2026,
  'TUBER_MESENTERICUM',
  '2026-09-15',
  '2027-01-31',
  9,
  'Stagione del Mesenterico',
  'Un tartufo dal profilo aromatico complesso, perfetto per chi cerca carattere.',
  'Mesenteric Truffle Season',
  'A truffle with a complex aromatic profile, ideal for those seeking character.',
  'seasonal/tuber_mesentericum',
  true
)
on conflict (season_year, truffle_type) do update
set
  start_date = excluded.start_date,
  end_date = excluded.end_date,
  priority = excluded.priority,
  title_it = excluded.title_it,
  subtitle_it = excluded.subtitle_it,
  title_en = excluded.title_en,
  subtitle_en = excluded.subtitle_en,
  image_key = excluded.image_key,
  is_enabled = excluded.is_enabled;

insert into public.truffle_guides (
  truffle_type,
  latin_name,
  title_it,
  title_en,
  short_description_it,
  short_description_en,
  description_it,
  description_en,
  aroma_it,
  aroma_en,
  price_min_eur,
  price_max_eur,
  rarity,
  symbiotic_plants_it,
  symbiotic_plants_en,
  soil_composition_it,
  soil_composition_en,
  soil_structure_it,
  soil_structure_en,
  soil_ph_it,
  soil_ph_en,
  soil_altitude_it,
  soil_altitude_en,
  soil_humidity_it,
  soil_humidity_en,
  harvest_start_month,
  harvest_end_month,
  is_published,
  sort_order
)
values
(
  'TUBER_MAGNATUM',
  'Tuber magnatum Pico',
  'Tartufo Bianco Pregiato',
  'Precious White Truffle',
  'Il piu raro e prezioso, dal profumo intenso e inconfondibile.',
  'The rarest and most prized, with an intense unmistakable aroma.',
  'Tartufo spontaneo molto pregiato, apprezzato per rarita, intensita aromatica e forte valore gastronomico.',
  'A highly prized wild truffle appreciated for its rarity, aromatic intensity, and outstanding culinary value.',
  'Intenso e complesso, con note di aglio, miele e formaggio stagionato.',
  'Intense and complex, with notes of garlic, honey, and aged cheese.',
  1000,
  5000,
  5,
  ARRAY['Quercia','Pioppo','Salice','Tiglio'],
  ARRAY['Oak','Poplar','Willow','Linden'],
  'Calcareo e ricco di minerali',
  'Calcareous and mineral-rich',
  'Soffice e ben drenato',
  'Soft and well-drained',
  'Subalcalino (7.5-8.0)',
  'Slightly alkaline (7.5-8.0)',
  '0-600 m',
  '0-600 m',
  'Moderata, con buona freschezza del suolo',
  'Moderate, with good soil freshness',
  9,
  12,
  true,
  1
),
(
  'TUBER_MELANOSPORUM',
  'Tuber melanosporum',
  'Tartufo Nero Pregiato',
  'Black Winter Truffle',
  'Elegante e persistente, e il nero piu ricercato dopo il bianco.',
  'Elegant and persistent, it is the most sought-after black truffle after the white.',
  'Tartufo nero di alta qualita, molto apprezzato in cucina per equilibrio aromatico e ampia versatilita.',
  'A high-quality black truffle prized in fine dining for its balanced aroma and versatility.',
  'Elegante e persistente, con note di cacao, sottobosco e terra umida.',
  'Elegant and persistent, with notes of cocoa, undergrowth, and moist earth.',
  300,
  1200,
  4,
  ARRAY['Quercia','Nocciolo'],
  ARRAY['Oak','Hazel'],
  'Calcareo',
  'Calcareous',
  'Compatto ma drenante',
  'Compact but well-draining',
  'Alcalino (7.5-8.5)',
  'Alkaline (7.5-8.5)',
  '200-1000 m',
  '200-1000 m',
  'Moderata',
  'Moderate',
  11,
  3,
  true,
  2
),
(
  'TUBER_AESTIVUM',
  'Tuber aestivum',
  'Tartufo Nero Estivo',
  'Summer Truffle',
  'Diffuso e versatile, ha un profumo piu delicato e un prezzo accessibile.',
  'Widely available and versatile, with a milder aroma and more accessible price.',
  'Tartufo estivo molto diffuso, apprezzato per la sua versatilita e per il profilo aromatico delicato.',
  'A common summer truffle appreciated for its versatility and gentle aromatic profile.',
  'Delicato, con note di nocciola e sottobosco leggero.',
  'Delicate, with notes of hazelnut and light undergrowth.',
  50,
  200,
  2,
  ARRAY['Quercia','Nocciolo','Carpino'],
  ARRAY['Oak','Hazel','Hornbeam'],
  'Calcareo o argilloso',
  'Calcareous or clayey',
  'Soffice',
  'Soft',
  'Neutro-alcalino',
  'Neutral to alkaline',
  '0-800 m',
  '0-800 m',
  'Media',
  'Moderate',
  5,
  8,
  true,
  3
),
(
  'TUBER_UNCINATUM',
  'Tuber uncinatum',
  'Tartufo Nero Uncinato',
  'Burgundy Truffle',
  'Piu intenso dell''estivo, con profilo aromatico autunnale.',
  'More intense than the summer truffle, with a richer autumn aroma.',
  'Variante autunnale piu profumata dell''aestivum, apprezzata per maggiore intensita e profondita aromatica.',
  'An autumn form with stronger aroma than aestivum, appreciated for its deeper flavor.',
  'Intenso, con note di nocciola, sottobosco e funghi secchi.',
  'Rich, with notes of hazelnut, forest floor, and dried mushrooms.',
  100,
  400,
  3,
  ARRAY['Quercia','Faggio'],
  ARRAY['Oak','Beech'],
  'Calcareo',
  'Calcareous',
  'Soffice e drenante',
  'Soft and well-drained',
  'Neutro-alcalino',
  'Neutral to alkaline',
  '200-900 m',
  '200-900 m',
  'Moderata',
  'Moderate',
  9,
  12,
  true,
  4
),
(
  'TUBER_BORCHII',
  'Tuber borchii',
  'Bianchetto',
  'Whitish Truffle',
  'Simile al bianco per famiglia aromatica, ma piu diretto e meno raffinato.',
  'Similar to white truffle in aroma family, but more direct and less refined.',
  'Tartufo chiaro di fine inverno e inizio primavera, apprezzato per il profumo deciso e il buon rapporto qualita-prezzo.',
  'A pale truffle harvested in late winter and early spring, valued for its bold aroma and accessible price.',
  'Forte, con note di aglio, terra e spezie leggere.',
  'Strong, with notes of garlic, earth, and light spice.',
  100,
  400,
  3,
  ARRAY['Pino','Quercia'],
  ARRAY['Pine','Oak'],
  'Sabbioso',
  'Sandy',
  'Sciolto',
  'Loose',
  'Leggermente alcalino',
  'Slightly alkaline',
  '0-500 m',
  '0-500 m',
  'Media',
  'Moderate',
  1,
  4,
  true,
  5
),
(
  'TUBER_BRUMALE',
  'Tuber brumale',
  'Tartufo Nero Invernale',
  'Winter Truffle',
  'Nero invernale dal profilo piu rustico e meno complesso del melanosporum.',
  'A winter black truffle with a more rustic and less complex profile than melanosporum.',
  'Tartufo nero invernale meno pregiato del melanosporum ma interessante per cucina e trasformazione.',
  'A winter black truffle less prized than melanosporum, but still valuable in cooking and processing.',
  'Terroso e deciso, meno complesso ma riconoscibile.',
  'Earthy and assertive, less complex but distinctive.',
  100,
  300,
  2,
  ARRAY['Quercia'],
  ARRAY['Oak'],
  'Calcareo',
  'Calcareous',
  'Compatto',
  'Compact',
  'Alcalino',
  'Alkaline',
  '200-800 m',
  '200-800 m',
  'Moderata',
  'Moderate',
  11,
  3,
  true,
  6
),
(
  'TUBER_MESENTERICUM',
  'Tuber mesentericum',
  'Tartufo Mesenterico',
  'Mesenteric Truffle',
  'Poco comune, si distingue per il profumo molto caratteristico.',
  'Less common and known for its very distinctive aroma.',
  'Tartufo nero poco diffuso, riconoscibile per il suo profilo aromatico intenso e divisivo.',
  'A less common black truffle recognizable for its intense and polarizing aromatic profile.',
  'Intenso e pungente, con note amare e sfumature catramose.',
  'Intense and pungent, with bitter and tar-like notes.',
  50,
  150,
  2,
  ARRAY['Faggio','Quercia'],
  ARRAY['Beech','Oak'],
  'Calcareo',
  'Calcareous',
  'Compatto',
  'Compact',
  'Alcalino',
  'Alkaline',
  '200-800 m',
  '200-800 m',
  'Media',
  'Moderate',
  9,
  1,
  true,
  7
),
(
  'TUBER_BRUMALE_MOSCHATUM',
  'Tuber brumale var. moschatum',
  'Tartufo Brumale Moscato',
  'Musky Brumal Truffle',
  'Variante del brumale dal profumo piu intenso e muschiato.',
  'A brumale variant with a stronger, musky aroma.',
  'Variante aromatica del brumale, interessante per intensita olfattiva e personalita marcata.',
  'An aromatic form of brumale valued for its stronger scent and marked character.',
  'Forte e muschiato, con tono animale e persistente.',
  'Strong and musky, with an animalic and persistent tone.',
  80,
  250,
  2,
  ARRAY['Quercia'],
  ARRAY['Oak'],
  'Calcareo',
  'Calcareous',
  'Compatto',
  'Compact',
  'Alcalino',
  'Alkaline',
  '200-800 m',
  '200-800 m',
  'Moderata',
  'Moderate',
  12,
  3,
  true,
  8
),
(
  'TUBER_MACROSPORUM',
  'Tuber macrosporum',
  'Tartufo Nero Liscio',
  'Smooth Black Truffle',
  'Raro e profumato, con scorza relativamente liscia e carattere deciso.',
  'Rare and aromatic, with a relatively smooth surface and strong character.',
  'Tartufo nero raro e apprezzato per il profumo intenso e la buona eleganza aromatica.',
  'A rare black truffle appreciated for its strong aroma and refined character.',
  'Intenso, con note di aglio, terra e sottobosco.',
  'Intense, with notes of garlic, earth, and undergrowth.',
  200,
  600,
  3,
  ARRAY['Quercia','Nocciolo'],
  ARRAY['Oak','Hazel'],
  'Calcareo',
  'Calcareous',
  'Soffice',
  'Soft',
  'Alcalino',
  'Alkaline',
  '100-700 m',
  '100-700 m',
  'Moderata',
  'Moderate',
  9,
  12,
  true,
  9
)
on conflict (truffle_type) do update
set
  latin_name = excluded.latin_name,
  title_it = excluded.title_it,
  title_en = excluded.title_en,
  short_description_it = excluded.short_description_it,
  short_description_en = excluded.short_description_en,
  description_it = excluded.description_it,
  description_en = excluded.description_en,
  aroma_it = excluded.aroma_it,
  aroma_en = excluded.aroma_en,
  price_min_eur = excluded.price_min_eur,
  price_max_eur = excluded.price_max_eur,
  rarity = excluded.rarity,
  symbiotic_plants_it = excluded.symbiotic_plants_it,
  symbiotic_plants_en = excluded.symbiotic_plants_en,
  soil_composition_it = excluded.soil_composition_it,
  soil_composition_en = excluded.soil_composition_en,
  soil_structure_it = excluded.soil_structure_it,
  soil_structure_en = excluded.soil_structure_en,
  soil_ph_it = excluded.soil_ph_it,
  soil_ph_en = excluded.soil_ph_en,
  soil_altitude_it = excluded.soil_altitude_it,
  soil_altitude_en = excluded.soil_altitude_en,
  soil_humidity_it = excluded.soil_humidity_it,
  soil_humidity_en = excluded.soil_humidity_en,
  harvest_start_month = excluded.harvest_start_month,
  harvest_end_month = excluded.harvest_end_month,
  is_published = excluded.is_published,
  sort_order = excluded.sort_order;
