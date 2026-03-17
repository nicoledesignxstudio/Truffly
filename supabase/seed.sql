insert into auth.users (id, email)
values
('44444444-4444-4444-4444-444444444444', 'seller3@test.com'),
('55555555-5555-5555-5555-555555555555', 'seller4@test.com'),
('66666666-6666-6666-6666-666666666666', 'seller5@test.com'),
('77777777-7777-7777-7777-777777777777', 'seller6@test.com'),
('88888888-8888-8888-8888-888888888888', 'seller7@test.com');

update public.users set
role='seller',
seller_status='approved',
stripe_account_id='acct_test_3',
first_name='Andrea',
last_name='Neri',
country_code='IT',
region='UMBRIA',
is_active=true
where id='44444444-4444-4444-4444-444444444444';

update public.users set
role='seller',
seller_status='approved',
stripe_account_id='acct_test_4',
first_name='Paolo',
last_name='Conti',
country_code='IT',
region='MARCHE',
is_active=true
where id='55555555-5555-5555-5555-555555555555';

update public.users set
role='seller',
seller_status='approved',
stripe_account_id='acct_test_5',
first_name='Francesca',
last_name='Moretti',
country_code='IT',
region='LAZIO',
is_active=true
where id='66666666-6666-6666-6666-666666666666';

update public.users set
role='seller',
seller_status='approved',
stripe_account_id='acct_test_6',
first_name='Luca',
last_name='Ferrari',
country_code='IT',
region='LOMBARDIA',
is_active=true
where id='77777777-7777-7777-7777-777777777777';

update public.users set
role='seller',
seller_status='approved',
stripe_account_id='acct_test_7',
first_name='Sara',
last_name='Romano',
country_code='IT',
region='VENETO',
is_active=true
where id='88888888-8888-8888-8888-888888888888';

insert into public.truffles (
id, seller_id, truffle_type, quality,
weight_grams, price_total,
shipping_price_italy, shipping_price_abroad,
region, harvest_date, status, expires_at
)
values

-- BIANCO (premium)
(gen_random_uuid(),'44444444-4444-4444-4444-444444444444','TUBER_MAGNATUM','FIRST',40,280,10,25,'UMBRIA',current_date-1,'active',now()+interval '5 days'),
(gen_random_uuid(),'55555555-5555-5555-5555-555555555555','TUBER_MAGNATUM','SECOND',30,190,10,25,'MARCHE',current_date-2,'active',now()+interval '5 days'),

-- NERO PREGIATO
(gen_random_uuid(),'66666666-6666-6666-6666-666666666666','TUBER_MELANOSPORUM','FIRST',50,140,8,20,'LAZIO',current_date-1,'active',now()+interval '5 days'),
(gen_random_uuid(),'77777777-7777-7777-7777-777777777777','TUBER_MELANOSPORUM','SECOND',60,120,8,20,'LOMBARDIA',current_date-2,'active',now()+interval '5 days'),

-- SCORZONE
(gen_random_uuid(),'88888888-8888-8888-8888-888888888888','TUBER_AESTIVUM','FIRST',80,70,6,15,'VENETO',current_date-1,'active',now()+interval '5 days'),
(gen_random_uuid(),'22222222-2222-2222-2222-222222222222','TUBER_AESTIVUM','THIRD',100,50,6,15,'PIEMONTE',current_date-3,'active',now()+interval '5 days'),

-- UNCINATO
(gen_random_uuid(),'33333333-3333-3333-3333-333333333333','TUBER_UNCINATUM','FIRST',70,90,7,18,'TOSCANA',current_date-1,'active',now()+interval '5 days'),

-- BRUMALE
(gen_random_uuid(),'44444444-4444-4444-4444-444444444444','TUBER_BRUMALE','SECOND',60,75,7,18,'UMBRIA',current_date-2,'active',now()+interval '5 days'),

-- BIANCHETTO
(gen_random_uuid(),'55555555-5555-5555-5555-555555555555','TUBER_BORCHII','FIRST',40,110,7,18,'MARCHE',current_date-1,'active',now()+interval '5 days'),

-- EXTRA per scroll
(gen_random_uuid(),'66666666-6666-6666-6666-666666666666','TUBER_MELANOSPORUM','THIRD',90,80,8,20,'LAZIO',current_date-3,'active',now()+interval '5 days'),
(gen_random_uuid(),'77777777-7777-7777-7777-777777777777','TUBER_AESTIVUM','SECOND',120,65,6,15,'LOMBARDIA',current_date-2,'active',now()+interval '5 days');

insert into public.truffle_images (id, truffle_id, image_url, order_index)
select gen_random_uuid(), t.id, 'https://picsum.photos/400?random=' || random(), 0
from public.truffles t;