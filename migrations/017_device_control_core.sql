-- ─────────────────────────────────────────────────────────────────────────────
-- DEVICE CONTROL — core: vendor normalization, credentials, connection
-- targets, capability registry.
--
-- Design goal: one uniform schema across every vendor SignalScope will ever
-- implement (see signal-scope-docs/00-architecture/data-model-notes.md and
-- comparison/*.md), not a schema redesigned per vendor. Extending to a new
-- vendor is new rows in vendor_profiles/device_capabilities, not new tables.
-- ─────────────────────────────────────────────────────────────────────────────

-- VENDOR PROFILES
-- Normalizes devices.vendor (free text) into a profile id the backend
-- resolves to a concrete adapter implementation. See devices.vendor_profile_id
-- added in 020_device_control_columns.sql.
CREATE TABLE IF NOT EXISTS vendor_profiles (
  id                         TEXT PRIMARY KEY,           -- 'cisco-ios', 'juniper-junos', ...
  display_name               TEXT NOT NULL,
  cli_dialect                TEXT NOT NULL,               -- 'ios-like', 'junos-candidate', 'menu-path', ...
  default_transport          TEXT NOT NULL DEFAULT 'ssh'
                                CHECK (default_transport IN ('ssh', 'telnet', 'snmp')),
  supports_candidate_config  BOOLEAN NOT NULL DEFAULT false,
  created_at                 TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- DEVICE CREDENTIALS
-- One row per credential *kind* per device — never a single password field.
-- secret_encrypted is AES-256-GCM ciphertext (12-byte IV || ciphertext ||
-- 16-byte auth tag), encrypted/decrypted application-side using
-- CREDENTIAL_ENC_KEY (see signal-scope-be/src/device-control). The database
-- never sees plaintext secrets.
CREATE TABLE IF NOT EXISTS device_credentials (
  id                SERIAL PRIMARY KEY,
  device_id         INTEGER NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  kind              TEXT NOT NULL
                       CHECK (kind IN (
                         'ssh_password', 'ssh_key', 'telnet_password', 'enable_secret',
                         'snmp_v2c_community', 'snmpv3_auth', 'snmpv3_priv', 'api_token'
                       )),
  username          TEXT,
  secret_encrypted  BYTEA NOT NULL,
  extra             JSONB NOT NULL DEFAULT '{}',          -- e.g. {"authProtocol":"sha","privProtocol":"aes"}
  is_active         BOOLEAN NOT NULL DEFAULT true,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  rotated_at        TIMESTAMPTZ,
  UNIQUE (device_id, kind, is_active)
);

CREATE INDEX IF NOT EXISTS idx_device_credentials_device ON device_credentials(device_id);

-- VENDOR CAPABILITY DEFAULTS
-- Vendor-level baseline capability facts — the structured version of
-- signal-scope-docs/comparison/snmp-write-support-matrix.md and
-- cli-syntax-matrix.md, seeded once per vendor_profile in
-- 022_seed_vendor_profiles_capabilities.sql. When a device is assigned a
-- vendor_profile_id, the backend copies these rows into per-device
-- device_capabilities (below) as its starting point — device_capabilities
-- can then diverge per-device as live probes confirm or override specific
-- objects (firmware/license can change what a given device actually
-- supports, per data-model-notes.md gap #2), while this table stays the
-- reusable, vendor-level default.
CREATE TABLE IF NOT EXISTS vendor_capability_defaults (
  id                SERIAL PRIMARY KEY,
  vendor_profile_id TEXT NOT NULL REFERENCES vendor_profiles(id) ON DELETE CASCADE,
  capability_key    TEXT NOT NULL,
  capability_value  JSONB NOT NULL,
  confidence        TEXT NOT NULL DEFAULT 'unknown'
                       CHECK (confidence IN ('confirmed', 'assumed', 'unknown')),
  source            TEXT,
  UNIQUE (vendor_profile_id, capability_key)
);

-- DEVICE CONNECTION TARGETS
-- Where/how to reach a device, decoupled from device identity. A real,
-- eve-ng, docker-simulator, or planned/ghost device is the same `devices`
-- row with a different target row (or none, for 'planned') — this is what
-- lets real/emulated/simulated management feel identical to the rest of
-- the backend.
--
-- proxy_device_id/proxy_selector generalize the "session target differs
-- from the configuration target" shape documented for Ubiquiti's
-- controller-first management and Fortinet's FortiLink-mediated switches
-- (see signal-scope-docs/vendors/fortinet/fortilink-integration.md) —
-- unused by the four vendors implemented this phase, but the column exists
-- now so those vendors don't need a schema change later.
CREATE TABLE IF NOT EXISTS device_connection_targets (
  id               SERIAL PRIMARY KEY,
  device_id        INTEGER NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  transport        TEXT NOT NULL CHECK (transport IN ('ssh', 'telnet', 'snmp')),
  host             TEXT NOT NULL,
  port             INTEGER NOT NULL,
  kind             TEXT NOT NULL DEFAULT 'real'
                      CHECK (kind IN ('real', 'eve-ng', 'docker-simulator', 'planned')),
  is_primary       BOOLEAN NOT NULL DEFAULT true,
  proxy_device_id  INTEGER REFERENCES devices(id) ON DELETE SET NULL,
  proxy_selector   TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_device_connection_targets_device ON device_connection_targets(device_id);

-- DEVICE CAPABILITIES
-- Per-device (not just per-vendor — firmware/license can change it)
-- fine-grained capability flags. This is the structured, queryable version
-- of signal-scope-docs/comparison/snmp-write-support-matrix.md and
-- cli-syntax-matrix.md — seeded from that research in
-- 022_seed_vendor_profiles_capabilities.sql for the vendors implemented
-- this phase. The device-control module checks this table before
-- attempting an SNMP SET so it never assumes a write path exists without
-- documented support (per gui-cli-snmp-unification.md's standing rule).
CREATE TABLE IF NOT EXISTS device_capabilities (
  id                SERIAL PRIMARY KEY,
  device_id         INTEGER NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  capability_key    TEXT NOT NULL,                        -- 'snmp.write.vlan_pvid', 'cli.candidate_config', ...
  capability_value  JSONB NOT NULL,
  confidence        TEXT NOT NULL DEFAULT 'unknown'
                       CHECK (confidence IN ('confirmed', 'assumed', 'unknown')),
  source            TEXT,                                 -- 'vendor-doc', 'live-probe', 'user-override'
  checked_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (device_id, capability_key)
);

CREATE INDEX IF NOT EXISTS idx_device_capabilities_device ON device_capabilities(device_id);
