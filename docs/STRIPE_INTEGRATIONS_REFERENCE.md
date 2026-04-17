# Stripe Integration Reference — Truffly

## Obiettivo

Questo documento definisce il modello di integrazione Stripe per Truffly.

Serve come riferimento unico per:
- architettura pagamenti
- onboarding seller
- webhook
- sicurezza
- confini tra app, backend e Stripe

---

## 1. Principi base

Truffly è un marketplace.

Ci sono tre soggetti:
- buyer
- seller
- Truffly

Il buyer paga Truffly.
Truffly trattiene il controllo del denaro.
Il seller riceve i fondi solo quando l’ordine è completato.

Il client mobile non è trusted per:
- calcolo prezzi
- calcolo commissioni
- creazione ordini
- rilascio fondi
- refund
- cambi stato ordine

Tutte le operazioni sensibili devono avvenire server-side.

---

## 2. Buyer vs Seller

### Buyer
Il buyer non ha bisogno di un account Stripe.
Paga dentro l’app usando l’interfaccia di pagamento Stripe.

### Seller
Il seller deve avere un account Stripe collegato (connected account).
Questo account viene creato da Truffly solo dopo approvazione seller.
Nel modello attuale Truffly richiede al connected account la capability minima per ricevere fondi/payout, non la capability per incassare carte direttamente.

---

## 3. Seller onboarding Stripe

Il seller onboarding Stripe parte solo dopo:
- seller_status = approved

Flusso:
1. Truffly crea un connected account Stripe per il seller
2. Truffly salva `stripe_account_id`
3. Truffly crea un Account Link
4. Il seller viene mandato al flusso di onboarding Stripe-hosted
5. Il seller completa i dati su Stripe
6. Stripe rimanda il seller a Truffly
7. Truffly controlla lo stato reale dell’account e delle capability

Nota:
- usare browser esterno / browser di sistema
- non usare webview embedded per hosted onboarding
- il semplice ritorno dal browser non sblocca nulla da solo
- la readiness seller viene verificata solo server-side contro Stripe
- publish consentito solo se l'account risulta davvero ready

---

## 4. Buyer payment flow

Il buyer paga tramite PaymentIntent.

Flusso:
1. Buyer seleziona il tartufo e l’indirizzo
2. App chiama Edge Function server-side
3. Il server valida:
   - utente autenticato e attivo
   - truffle acquistabile
   - no self-purchase
   - importi letti dal DB
4. Il server crea il PaymentIntent
5. Il server restituisce al client solo ciò che serve per completare il pagamento
6. Il buyer completa il pagamento nell’app

Il client non crea ordini.

---

## 5. Ordine e webhook

L’ordine deve essere creato solo lato server dopo conferma Stripe.

Webhook usati come fonte di verità per:
- pagamento riuscito
- pagamento fallito
- aggiornamenti seller onboarding
- altri eventi critici

Il webhook deve:
- verificare la firma
- essere idempotente
- loggare audit
- non fidarsi mai del client

---

## 6. Money flow

Modello desiderato:
- buyer paga ora
- piattaforma mantiene il controllo dei fondi
- seller riceve i fondi solo a ordine completato

Conseguenza per Connect:
- il connected account seller non e' il soggetto che processa il pagamento carta nel flow attuale
- il connected account serve soprattutto per ricevere fondi/payout in un secondo momento

Conseguenze:
- nessun trasferimento immediato al seller al momento del pagamento
- trasferimento solo dopo:
  - conferma buyer
  - oppure auto-complete del sistema

Refund:
- gestito server-side
- usato per ordini non spediti nei tempi previsti

---

## 7. Sicurezza obbligatoria

### Secret keys
Le secret key Stripe:
- non devono mai stare nel frontend
- non devono mai essere loggate
- devono stare solo nei secrets del backend

### Webhook verification
Ogni webhook deve verificare:
- payload
- header Stripe-Signature
- endpoint secret

### Idempotenza
Ogni operazione critica deve evitare effetti duplicati:
- ordine creato una sola volta
- refund eseguito una sola volta
- transfer eseguito una sola volta

Nel codice MVP questo avviene tramite:
- `payment_attempts` + `stripe_webhook_events` per il payment flow
- `order_financial_operations.logical_key` / `idempotency_key` per refund e transfer

### Audit
Loggare almeno:
- connected account creato
- onboarding avviato
- onboarding completato / incompleto
- payment intent creato
- pagamento riuscito / fallito
- ordine creato
- refund
- transfer al seller

---

## 8. Cose da non fare

- non usare chiavi secret nel client
- non creare ordini dal client
- non fidarsi del risultato solo lato app
- non usare hosted checkout come flow principale mobile
- non fare trasferimento seller immediato al pagamento
- non aprire hosted onboarding in webview

---

## 9. Modalità iniziale

Fase iniziale:
- solo sandbox / test mode

Prima del live servono:
- webhook verificati
- idempotenza
- test end-to-end
- reconciliation minima
- runbook incidenti base

---

## 10. Configurazione minima necessaria

### Stripe Dashboard
- test publishable key
- test secret key
- webhook endpoint secret
- branding base piattaforma
- payment methods di base attivi

### Backend
- secrets configurati
- endpoint seller onboarding
- endpoint create payment intent
- endpoint webhook
- endpoint transfer / payout flow
- endpoint / job refund flow
- audit logging
