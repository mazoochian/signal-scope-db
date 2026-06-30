-- Device configuration snapshot history

CREATE TABLE IF NOT EXISTS device_config_snapshots (
  id           SERIAL PRIMARY KEY,
  device_id    INTEGER NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  version      INTEGER NOT NULL,
  config_text  TEXT NOT NULL,
  committed_by TEXT,
  committed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  notes        TEXT,
  UNIQUE (device_id, version)
);

-- Index for fast latest-version lookups
CREATE INDEX IF NOT EXISTS idx_device_configs_device_version
  ON device_config_snapshots (device_id, version DESC);
