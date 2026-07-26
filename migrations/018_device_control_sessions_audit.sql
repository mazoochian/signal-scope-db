-- ─────────────────────────────────────────────────────────────────────────────
-- DEVICE CONTROL — sessions, command audit, and the offline sync queue.
-- ─────────────────────────────────────────────────────────────────────────────

-- DEVICE SESSIONS
-- One row per dial — i.e. per BullMQ device-action job's transport
-- lifecycle (connect -> login -> paging-disable -> run plan -> close), not
-- a long-lived shared session. This is a durable audit of connection
-- attempts, not just live in-memory state, so a restarted worker fleet can
-- be reasoned about from Postgres alone.
CREATE TABLE IF NOT EXISTS device_sessions (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  device_id      INTEGER NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  transport      TEXT NOT NULL CHECK (transport IN ('ssh', 'telnet', 'snmp')),
  worker_job_id  TEXT,                                    -- BullMQ job id that owned this dial
  opened_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  closed_at      TIMESTAMPTZ,
  final_mode     TEXT,                                    -- last known CLI mode/context at close, e.g. 'config-if:Gi0/1'
  status         TEXT NOT NULL DEFAULT 'connecting'
                    CHECK (status IN ('connecting', 'open', 'closed', 'error')),
  last_error     TEXT
);

CREATE INDEX IF NOT EXISTS idx_device_sessions_device ON device_sessions(device_id);
CREATE INDEX IF NOT EXISTS idx_device_sessions_status  ON device_sessions(status);

-- DEVICE COMMAND AUDIT
-- The durable, literal command/SNMP-operation audit log — per
-- gui-cli-snmp-unification.md's audit requirement, distinct from and more
-- granular than device_config_snapshots (which records config *state*,
-- this records *actions taken*). command_text is always the literal text a
-- human would see (a real CLI line, or a synthetic
-- "# SNMP SET IF-MIB::ifAdminStatus.24 = up(1)" representation for
-- SNMP-driven actions), never a templated description.
CREATE TABLE IF NOT EXISTS device_command_audit (
  id            BIGSERIAL PRIMARY KEY,
  device_id     INTEGER NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  session_id    UUID REFERENCES device_sessions(id) ON DELETE SET NULL,
  actor_kind    TEXT NOT NULL CHECK (actor_kind IN ('human-gui', 'human-cli', 'agent', 'system')),
  actor_id      TEXT,                                     -- user id, or 'reachability-poller', etc.
  transport     TEXT NOT NULL CHECK (transport IN ('ssh', 'telnet', 'snmp')),
  command_text  TEXT NOT NULL,
  raw_response  TEXT,
  result        TEXT NOT NULL DEFAULT 'ok' CHECK (result IN ('ok', 'error', 'timeout')),
  issued_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_device_command_audit_device ON device_command_audit(device_id, issued_at DESC);
CREATE INDEX IF NOT EXISTS idx_device_command_audit_session ON device_command_audit(session_id);

-- PENDING CHANGES
-- The offline cache/sync queue. A GUI/API action against an unreachable
-- device (including a 'planned' ghost device, which is permanently
-- unreachable until it's given a real connection target) lands here
-- instead of dialing. The reachability poller drains this FIFO per device
-- on a down->up transition, re-validating expected_prior_state before
-- replay (optimistic-concurrency check) to avoid clobbering a state that
-- changed out from under a queued change while offline.
CREATE TABLE IF NOT EXISTS pending_changes (
  id                       BIGSERIAL PRIMARY KEY,
  device_id                INTEGER NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  requested_by             TEXT NOT NULL,                 -- user id
  requested_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
  change_type              TEXT NOT NULL CHECK (change_type IN ('cli_action', 'snmp_set')),
  action_key               TEXT NOT NULL,                 -- matches the DeviceAction union, e.g. 'port.setAdminStatus'
  payload                  JSONB NOT NULL,
  expected_prior_state     JSONB,
  target_state_description TEXT,
  status                   TEXT NOT NULL DEFAULT 'queued'
                              CHECK (status IN ('queued', 'in_flight', 'applied', 'failed', 'conflict', 'cancelled')),
  attempts                 INTEGER NOT NULL DEFAULT 0,
  last_attempt_at          TIMESTAMPTZ,
  last_error               TEXT,
  applied_audit_id         BIGINT REFERENCES device_command_audit(id) ON DELETE SET NULL,
  supersedes_id            BIGINT REFERENCES pending_changes(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_pending_changes_device_status ON pending_changes(device_id, status);
