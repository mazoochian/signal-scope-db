-- Application-level audit log — AUDIT-REPORT.md M6: "Nothing records who
-- logged in, who changed a role, who added an access grant, or who edited
-- an integration's credentials." For a five-tier RBAC NMS, that absence
-- undercut the access-control model that's otherwise carefully built —
-- notably, the Settings UI's overview subtitle already advertised "audit"
-- as a feature before this table existed.
--
-- actor_user_id is nullable and ON DELETE SET NULL (not CASCADE, matching
-- migration 024's reasoning for alerts/syslog_messages/etc): a log entry
-- must survive the actor's own account being deleted later, with
-- actor_email as the denormalized fallback identity.
CREATE TABLE audit_log (
  id             SERIAL PRIMARY KEY,
  time           TIMESTAMPTZ NOT NULL DEFAULT now(),
  actor_user_id  INTEGER REFERENCES users(id) ON DELETE SET NULL,
  actor_email    TEXT,
  action         TEXT NOT NULL,        -- 'login.success', 'login.failure', 'user.role_changed', 'user.created', 'user.deleted', 'access_grant.created', 'access_grant.deleted', 'integration.credentials_changed', ...
  target_type    TEXT,                 -- 'user', 'access_grant', 'integration', ...
  target_id      TEXT,
  details        JSONB,
  ip_address     TEXT
);

CREATE INDEX idx_audit_log_time   ON audit_log(time DESC);
CREATE INDEX idx_audit_log_actor  ON audit_log(actor_user_id, time DESC);
CREATE INDEX idx_audit_log_action ON audit_log(action, time DESC);
