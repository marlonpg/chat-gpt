# Daily Devotional Bot — Implementation Plan

## Goal
Build a local POC that sends one daily Christian devotional message through Telegram, using Java + Spring Boot + PostgreSQL, with reflection text generated through `gh models run`.

## Success Criteria (POC)
- User can subscribe/unsubscribe via Telegram commands.
- App stores users in PostgreSQL.
- App generates one devotional for the day via GitHub CLI models.
- App sends the devotional once per day to active users.
- Delivery attempts are persisted and visible in logs/database.

## Scope
### In scope (now)
- Telegram long-polling bot (`/start`, `/stop`, `/test`).
- PostgreSQL schema + Flyway migrations.
- Daily scheduler.
- LLM generation via Java `ProcessBuilder` calling `gh models run`.
- Fallback devotional if LLM call fails.

### Out of scope (later)
- WhatsApp integration.
- Paid subscriptions/billing.
- Audio generation.
- Automated news ingestion.
- Multi-admin dashboard.

## Architecture
- **Framework:** Spring Boot 3.x (Java 21)
- **Bot Library:** telegrambots-springboot-longpolling-starter
- **DB:** PostgreSQL + Spring Data JPA + Flyway
- **Scheduling:** Spring `@Scheduled`
- **LLM Adapter:** local process invocation of `gh.exe` / `gh`

## Data Model
### users
- `id` UUID PK
- `telegram_chat_id` BIGINT UNIQUE NOT NULL
- `first_name` VARCHAR(120)
- `username` VARCHAR(120)
- `language_code` VARCHAR(10) DEFAULT 'en'
- `active` BOOLEAN DEFAULT TRUE
- `created_at` TIMESTAMP NOT NULL
- `updated_at` TIMESTAMP NOT NULL

### daily_messages
- `id` UUID PK
- `message_date` DATE UNIQUE NOT NULL
- `topic` VARCHAR(160)
- `bible_reference` VARCHAR(120) NOT NULL
- `bible_text` TEXT NOT NULL
- `reflection_text` TEXT NOT NULL
- `llm_model` VARCHAR(80)
- `created_at` TIMESTAMP NOT NULL

### deliveries
- `id` UUID PK
- `user_id` UUID FK -> users(id)
- `daily_message_id` UUID FK -> daily_messages(id)
- `status` VARCHAR(20) NOT NULL
- `error_message` TEXT
- `sent_at` TIMESTAMP
- `created_at` TIMESTAMP NOT NULL

## Milestones
1. **Bootstrap Project**
   - Spring Boot app, dependencies, configuration.
2. **Database Layer**
   - Flyway migration + JPA entities + repositories.
3. **Telegram Bot Commands**
   - `/start`, `/stop`, `/test` command handling.
4. **Devotional Generation**
   - Service calling `gh models run`, parse response, persist daily message.
5. **Daily Dispatch**
   - Scheduler to generate (if missing) and send to active users.
6. **Resilience & Logging**
   - Fallback text, delivery status, error logs.

## Risks & Mitigations
- **`gh` not installed / not authenticated:** startup check + clear log errors.
- **LLM non-structured output:** strict prompt + defensive parser + fallback.
- **Telegram delivery errors/rate limits:** catch exceptions and persist FAILED deliveries.
- **Timezone differences:** keep UTC for POC; add per-user timezone later.

## Progress Tracker
- [x] Plan file created
- [x] Project scaffolded
- [x] DB migrations added
- [x] Telegram bot commands implemented
- [x] LLM CLI adapter implemented
- [x] Daily scheduler implemented
- [ ] Local run instructions verified

## Runbook (Target)
1. Set env vars:
   - `TELEGRAM_BOT_TOKEN`
   - `TELEGRAM_BOT_USERNAME`
   - `SPRING_DATASOURCE_URL`
   - `SPRING_DATASOURCE_USERNAME`
   - `SPRING_DATASOURCE_PASSWORD`
2. Ensure GitHub CLI auth is active (`gh auth status`).
3. Run app (`./mvnw spring-boot:run` or `mvn spring-boot:run`).
4. In Telegram, send `/start` to bot.
5. Use `/test` to validate a generated devotional.
