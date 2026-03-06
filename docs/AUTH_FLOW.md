# Auth Flow – Implementation Checklist

## Routing

- Aggiungere route:
  - `/login`
  - `/signup`
  - `/verify-email`
  - `/forgot-password`
  - `/onboarding`
  - `/home`

- Proteggere route auth / non-auth
- Impedire accesso a login/signup se già autenticato
- Impedire accesso a home se non autenticato

---

## Schermate

- `login_screen`
- `signup_screen`
- `verify_email_screen`
- `forgot_password_screen`
- `onboarding_screen`
- `home_screen`

Eventuali widget condivisi auth UI.

---

## Tema minimo progetto

- colori base
- text theme base
- input decoration theme
- button theme
- scaffold background
- radius / spacing costanti

---

## Architettura auth

- `auth_service`
- `auth_notifier`
- `auth_state`
- `auth_failure`
- `auth_validators`
- eventuale `profile/onboarding_service`

---

## Azioni auth da implementare

- sign up email/password
- login email/password
- logout
- invio reset password
- controllo stato email verificata
- redirect corretto dopo verifica email
- onboarding dopo sign up/verifica

---

## Onboarding

- definire quali dati raccogliere
- creare schermata onboarding
- salvataggio dati onboarding
- controllo se onboarding è completato

Redirect corretto:

- autenticato ma onboarding incompleto → `/onboarding`
- autenticato e onboarding completo → `/home`

---

## Verifica email obbligatoria

- attivare email confirmation in Supabase
- gestire stato **email non verificata**
- creare schermata dedicata con istruzioni
- bottone reinvio email verifica
- bloccare accesso completo finché email non è confermata

---

## Validazione campi

- email valida
- password minima e robusta
- confirm password uguale
- first name obbligatorio
- last name obbligatorio

Validazione ibrida:

- live dopo interazione
- completa al submit

---

## UX form

- `Form` + validazione
- campi con tastiera corretta
- focus tra campi
- password show/hide
- submit disabilitato durante loading
- loader visibile
- evitare doppio submit
- errori chiari
- layout che non va in overflow con tastiera

---

## Error handling

Modellare failure type-safe.

Distinguere:

- email già usata
- credenziali errate
- email non verificata
- rete assente
- timeout
- errore sconosciuto

- mappare errori in messaggi UX chiari
- non mostrare eccezioni raw all’utente

---

## Sicurezza / robustezza

- non loggare password o token
- trim / normalizzare input
- usare solo sessione Supabase
- gestire logout correttamente
- gestire sessione persistente
- usare backend per creare `public.users`

---

## Integrazione con backend

- trigger/backend logic per creare `public.users`
- verificare coerenza tra `auth.users` e `public.users`
- definire cosa viene creato subito e cosa in onboarding

---

## Componenti riutilizzabili utili

- campo testo auth
- campo password
- bottone primario auth
- messaggio errore auth
- layout/scaffold auth

---

## Casi da coprire

- utente già autenticato
- utente non autenticato
- email non verificata
- onboarding incompleto
- submit multipli
- rete lenta / offline
- refresh app dopo login
- reset password
- logout