-- Grant read access to the new audit_log (migration 025) to admin and
-- superadmin. superadmin already has the '*'/'manage' wildcard row from
-- migration 014, so this only adds a row for admin.
INSERT INTO role_permissions (role, resource, action) VALUES
  ('admin', 'audit', 'read')
ON CONFLICT DO NOTHING;
