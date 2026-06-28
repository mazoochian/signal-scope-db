-- Integration configs: one row per kind (email, telegram, slack)
CREATE TABLE IF NOT EXISTS integration_configs (
  id         SERIAL PRIMARY KEY,
  kind       TEXT NOT NULL UNIQUE CHECK (kind IN ('email', 'telegram', 'slack')),
  config     JSONB NOT NULL DEFAULT '{}',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
