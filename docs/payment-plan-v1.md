# Payment Plan v1: $1 One-Time Subscription via Telegram Payments API

## Context
Users currently subscribe for free with `/start`. We want to charge a one-time $1 fee before activating access to daily devotionals. Telegram's native Payments API handles this entirely inside the chat — no external redirect needed. After a successful payment, the user is activated and can use `#word`, `#grace`, and `#daily`.

---

## Payment Flow

1. User sends `/start`
2. Bot saves user as `UNPAID` and sends a $1 invoice
3. User taps "Pay $1.00" inside Telegram
4. Telegram sends `PreCheckoutQuery` → bot approves it
5. Telegram charges the user and sends `SuccessfulPayment` → bot sets user to `PAID` + `active=true`
6. If user was already paid (e.g., after `/stop` + `/start`), bot re-activates for free

---

## Files to Change

### 1. `src/main/resources/application.yml`
Add the payment provider token property under `telegram.bot`:
```yaml
telegram:
  bot:
    payment-provider-token: ${TELEGRAM_PAYMENT_PROVIDER_TOKEN:}
```

### 2. `src/main/java/com/dailyjesus/domain/UserEntity.java`
Add two fields:
```java
@Column(name = "subscription_status", nullable = false)
private String subscriptionStatus = "UNPAID"; // UNPAID | PAID

@Column(name = "paid_at")
private Instant paidAt;
```
Add getters and setters for both fields.

### 3. `src/main/java/com/dailyjesus/bot/TelegramDevotionalBot.java`
This is the main change. Key updates:

**Inject provider token:**
```java
@Value("${telegram.bot.payment-provider-token}") String paymentProviderToken
```

**Rewrite `consume()` to handle 3 branches:**
- `update.hasPreCheckoutQuery()` → `handlePreCheckoutQuery()`
- `msg.hasSuccessfulPayment()` → `handleSuccessfulPayment()`
- Text commands → existing dispatching (with extracted private methods)

**New private methods to add:**
- `handleStart()` — if PAID: re-activate; if UNPAID: save user + call `sendInvoice()`
- `sendInvoice()` — builds `SendInvoice` (100 cents = $1, USD, payload = `"DEVOTIONAL_SUBSCRIPTION_<chatId>"`)
- `handlePreCheckoutQuery()` — always approve with `AnswerPreCheckoutQuery(ok=true)`
- `handleSuccessfulPayment()` — set `subscriptionStatus=PAID`, `paidAt=now()`, `active=true`, save, send welcome message
- `handleStop()`, `handleDevotionalRequest()`, `handleUnknown()` — extracted from existing code, no logic changes

**New imports needed:**
```java
import org.telegram.telegrambots.meta.api.methods.AnswerPreCheckoutQuery;
import org.telegram.telegrambots.meta.api.methods.invoices.SendInvoice;
import org.telegram.telegrambots.meta.api.objects.payments.LabeledPrice;
import org.telegram.telegrambots.meta.api.objects.payments.PreCheckoutQuery;
import org.telegram.telegrambots.meta.api.objects.payments.SuccessfulPayment;
import java.time.Instant;
```

### 4. `src/main/resources/db/migration/V2__add_payment_fields.sql` (new file)
```sql
ALTER TABLE users
  ADD COLUMN subscription_status VARCHAR(20) NOT NULL DEFAULT 'UNPAID',
  ADD COLUMN paid_at TIMESTAMP;
```
Note: since `ddl-auto: create-drop` is in use for dev, Hibernate will pick up the new fields automatically. This migration is ready for when Flyway is enabled in production.

---

## Operational Step (done once, outside code)
1. Open `@BotFather` → `/mybots` → your bot → Payments
2. Connect Stripe (use "Stripe TEST" for dev)
3. Copy the provider token (format: `STRIPE_TEST:...`)
4. Set env var `TELEGRAM_PAYMENT_PROVIDER_TOKEN` in your environment or `docker-compose.yml`

---

## Key Design Decisions
- **`subscriptionStatus` is a String (`UNPAID`/`PAID`)** — keeps `active` field independent; a paid user can still `/stop` and `/start` without re-paying
- **No invoice storage needed** — for a simple $1 one-time payment, `paidAt` is sufficient; `telegram_payment_charge_id` can be added later if refunds are needed
- **No new Maven dependencies** — `SendInvoice`, `AnswerPreCheckoutQuery`, `LabeledPrice`, `PreCheckoutQuery`, and `SuccessfulPayment` are all already in `telegrambots-meta:7.9.1`

---

## Verification
1. Set `TELEGRAM_PAYMENT_PROVIDER_TOKEN` to a Stripe TEST token
2. Start the app and send `/start` → bot should send a $1 invoice
3. Complete payment using Stripe's test card (`4242 4242 4242 4242`)
4. Confirm the welcome message is received and user is active in DB
5. Send `#word` → devotional should be delivered
6. Send `/stop` then `/start` → should re-activate without re-charging
