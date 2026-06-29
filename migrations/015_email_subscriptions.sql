-- Global alert email notification settings (one row, upserted)
CREATE TABLE IF NOT EXISTS alert_email_settings (
  id           SERIAL PRIMARY KEY,
  min_severity TEXT      NOT NULL DEFAULT 'Critical',
  recipients   JSONB     NOT NULL DEFAULT '[]',
  user_ids     INTEGER[] NOT NULL DEFAULT '{}',
  enabled      BOOLEAN   NOT NULL DEFAULT FALSE,
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Per-user alert email opt-in
CREATE TABLE IF NOT EXISTS user_alert_email_prefs (
  user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  min_severity TEXT    NOT NULL DEFAULT 'Critical',
  enabled      BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY  (user_id)
);

-- Scheduled report email subscriptions
CREATE TABLE IF NOT EXISTS report_email_subscriptions (
  id            SERIAL PRIMARY KEY,
  label         TEXT      NOT NULL DEFAULT '',
  report_type   TEXT      NOT NULL,
  range         TEXT      NOT NULL DEFAULT '24h',
  cron_schedule TEXT      NOT NULL,
  recipients    JSONB     NOT NULL DEFAULT '[]',
  user_ids      INTEGER[] NOT NULL DEFAULT '{}',
  enabled       BOOLEAN   NOT NULL DEFAULT TRUE,
  last_sent_at  TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Track which alerts have already triggered an email (dedup)
-- Requires superuser or table ownership. Applied manually if migrate.sh runs as signalscope.
-- sudo -u postgres psql -d signalscope -c "ALTER TABLE alerts ADD COLUMN IF NOT EXISTS email_notified_at TIMESTAMPTZ;"
ALTER TABLE alerts ADD COLUMN IF NOT EXISTS email_notified_at TIMESTAMPTZ;
