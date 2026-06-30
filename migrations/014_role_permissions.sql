-- Flexible RBAC: roles × resources × actions, stored in DB so admins can
-- adjust the default permission matrix at runtime without a deployment.
CREATE TABLE IF NOT EXISTS role_permissions (
  id       SERIAL PRIMARY KEY,
  role     TEXT NOT NULL
             CHECK (role IN ('superadmin','admin','operator','troubleshooter','viewer')),
  resource TEXT NOT NULL,
  action   TEXT NOT NULL
             CHECK (action IN ('read','write','execute','delete','manage')),
  UNIQUE (role, resource, action)
);

-- Superadmin: wildcard — never blocked by resource checks
INSERT INTO role_permissions (role, resource, action) VALUES
  ('superadmin', '*', 'manage')
ON CONFLICT DO NOTHING;

-- Admin
INSERT INTO role_permissions (role, resource, action) VALUES
  ('admin', 'dashboard',     'read'),
  ('admin', 'devices',       'manage'),
  ('admin', 'interfaces',    'read'),
  ('admin', 'topology',      'read'),
  ('admin', 'alerts',        'manage'),
  ('admin', 'configuration', 'manage'),
  ('admin', 'reports',       'read'),
  ('admin', 'discovery',     'manage'),
  ('admin', 'wireless',      'read'),
  ('admin', 'services',      'read'),
  ('admin', 'telemetry',     'read'),
  ('admin', 'sla',           'manage'),
  ('admin', 'inventory',     'read'),
  ('admin', 'integrations',  'manage'),
  ('admin', 'notifications', 'manage'),
  ('admin', 'users',         'manage'),
  ('admin', 'groups',        'manage'),
  ('admin', 'oidc',          'read'),
  ('admin', 'simulation',    'read')
ON CONFLICT DO NOTHING;

-- Operator
INSERT INTO role_permissions (role, resource, action) VALUES
  ('operator', 'dashboard',     'read'),
  ('operator', 'devices',       'read'),
  ('operator', 'interfaces',    'read'),
  ('operator', 'topology',      'read'),
  ('operator', 'alerts',        'execute'),
  ('operator', 'configuration', 'execute'),
  ('operator', 'reports',       'read'),
  ('operator', 'discovery',     'execute'),
  ('operator', 'wireless',      'read'),
  ('operator', 'services',      'read'),
  ('operator', 'telemetry',     'read'),
  ('operator', 'sla',           'read'),
  ('operator', 'inventory',     'read'),
  ('operator', 'notifications', 'execute'),
  ('operator', 'simulation',    'read')
ON CONFLICT DO NOTHING;

-- Troubleshooter
INSERT INTO role_permissions (role, resource, action) VALUES
  ('troubleshooter', 'dashboard',     'read'),
  ('troubleshooter', 'devices',       'read'),
  ('troubleshooter', 'interfaces',    'read'),
  ('troubleshooter', 'topology',      'read'),
  ('troubleshooter', 'alerts',        'execute'),
  ('troubleshooter', 'configuration', 'read'),
  ('troubleshooter', 'reports',       'read'),
  ('troubleshooter', 'discovery',     'read'),
  ('troubleshooter', 'wireless',      'read'),
  ('troubleshooter', 'services',      'read'),
  ('troubleshooter', 'telemetry',     'read'),
  ('troubleshooter', 'sla',           'read'),
  ('troubleshooter', 'inventory',     'read'),
  ('troubleshooter', 'notifications', 'execute'),
  ('troubleshooter', 'simulation',    'read')
ON CONFLICT DO NOTHING;

-- Viewer
INSERT INTO role_permissions (role, resource, action) VALUES
  ('viewer', 'dashboard',     'read'),
  ('viewer', 'devices',       'read'),
  ('viewer', 'interfaces',    'read'),
  ('viewer', 'topology',      'read'),
  ('viewer', 'alerts',        'read'),
  ('viewer', 'configuration', 'read'),
  ('viewer', 'reports',       'read'),
  ('viewer', 'wireless',      'read'),
  ('viewer', 'services',      'read'),
  ('viewer', 'telemetry',     'read'),
  ('viewer', 'sla',           'read'),
  ('viewer', 'inventory',     'read'),
  ('viewer', 'notifications', 'execute'),
  ('viewer', 'simulation',    'read')
ON CONFLICT DO NOTHING;
