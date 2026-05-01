CREATE TABLE users (
  id UUID PRIMARY KEY,
  telegram_chat_id BIGINT UNIQUE NOT NULL,
  first_name VARCHAR(120),
  username VARCHAR(120),
  language_code VARCHAR(10) NOT NULL DEFAULT 'en',
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE TABLE daily_messages (
  id UUID PRIMARY KEY,
  message_date DATE UNIQUE NOT NULL,
  topic VARCHAR(160),
  bible_reference VARCHAR(120) NOT NULL,
  bible_text TEXT NOT NULL,
  reflection_text TEXT NOT NULL,
  llm_model VARCHAR(80),
  created_at TIMESTAMP NOT NULL
);

CREATE TABLE deliveries (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  daily_message_id UUID NOT NULL REFERENCES daily_messages(id),
  status VARCHAR(20) NOT NULL,
  error_message TEXT,
  sent_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL
);
