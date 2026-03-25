-- Safely extend truffle_type_enum with new supported truffle types.
-- Non-destructive: existing rows/constraints remain valid.
-- Historical init migration remains intentionally untouched.
-- Full migration chain application is the source of truth.

alter type public.truffle_type_enum add value if not exists 'TUBER_MACROSPORUM';
alter type public.truffle_type_enum add value if not exists 'TUBER_BRUMALE_MOSCHATUM';
alter type public.truffle_type_enum add value if not exists 'TUBER_MESENTERICUM';
