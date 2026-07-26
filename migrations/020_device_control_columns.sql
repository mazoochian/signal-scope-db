-- ─────────────────────────────────────────────────────────────────────────────
-- Additive columns on existing tables — no change to existing meaning.
-- ─────────────────────────────────────────────────────────────────────────────

-- devices.role stays the free-text topology role ('core-switch', 'edge-router', ...).
-- device_class is the new, actual "what kind of device is this" field the
-- device-control module keys off of.
ALTER TABLE devices ADD COLUMN IF NOT EXISTS device_class TEXT
  CHECK (device_class IN ('switch', 'router', 'ap', 'firewall', 'other'));

ALTER TABLE devices ADD COLUMN IF NOT EXISTS vendor_profile_id TEXT
  REFERENCES vendor_profiles(id);

-- Mirrors device_connection_targets.kind for fast filtering/display without
-- a join; device_connection_targets remains the source of truth for actual
-- host/port. 'planned' devices are legitimate ghost/preconfiguration
-- profiles — never flagged down by the reachability poller.
ALTER TABLE devices ADD COLUMN IF NOT EXISTS connection_kind TEXT NOT NULL DEFAULT 'planned'
  CHECK (connection_kind IN ('real', 'eve-ng', 'docker-simulator', 'planned'));

ALTER TABLE devices ADD COLUMN IF NOT EXISTS last_reachability_check_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_devices_connection_kind ON devices(connection_kind);

-- interfaces: SNMP ifIndex (resolved from ifName at session start per
-- standard-mibs.md's note that it isn't guaranteed stable across reboots
-- on every vendor — not cached long-term as a foreign identity, just
-- recorded from the most recent poll) and provenance of the row's data.
ALTER TABLE interfaces ADD COLUMN IF NOT EXISTS ifindex INTEGER;
ALTER TABLE interfaces ADD COLUMN IF NOT EXISTS last_polled_at TIMESTAMPTZ;
ALTER TABLE interfaces ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT 'manual'
  CHECK (source IN ('snmp', 'cli', 'manual'));
