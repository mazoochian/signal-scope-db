-- ─────────────────────────────────────────────────────────────────────────────
-- RBAC for the device-control module.
--
-- Two resources, deliberately separate:
--   'device-control'      — guided/structured actions (the DeviceAction
--                            union: port admin state, VLAN membership,
--                            config save, etc.) built and sanitized by a
--                            vendor adapter's buildCliPlan/buildSnmpPlan.
--   'device-control-raw'  — raw CLI passthrough (a human's literal typed
--                            command, forwarded as-is after sanitization).
--                            Kept separate so an operator can be granted
--                            "click GUI buttons" without "type arbitrary
--                            CLI", mirroring the self-access-bypass care
--                            already present elsewhere in this schema's
--                            permission model.
--
-- superadmin is covered by the existing ('superadmin','*','manage') row.
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO role_permissions (role, resource, action) VALUES
  ('admin', 'device-control',     'manage'),
  ('admin', 'device-control-raw', 'manage')
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role, resource, action) VALUES
  ('operator', 'device-control',     'execute'),
  ('operator', 'device-control-raw', 'read')
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role, resource, action) VALUES
  ('troubleshooter', 'device-control',     'read'),
  ('troubleshooter', 'device-control-raw', 'read')
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role, resource, action) VALUES
  ('viewer', 'device-control',     'read'),
  ('viewer', 'device-control-raw', 'read')
ON CONFLICT DO NOTHING;
