-- Auth: users, OIDC providers, IDP links, access grants

CREATE TABLE IF NOT EXISTS users (
  id            SERIAL PRIMARY KEY,
  email         TEXT NOT NULL UNIQUE,
  password_hash TEXT,                       -- null for pure OIDC users
  first_name    TEXT,
  last_name     TEXT,
  age           INTEGER,
  role          TEXT NOT NULL DEFAULT 'viewer'
                  CHECK (role IN ('superadmin','admin','operator','troubleshooter','viewer')),
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS oidc_providers (
  id             SERIAL PRIMARY KEY,
  name           TEXT NOT NULL,
  provider_type  TEXT NOT NULL
                   CHECK (provider_type IN ('google','telegram','keycloak','authentik','authelia','custom')),
  is_enabled     BOOLEAN NOT NULL DEFAULT TRUE,
  client_id      TEXT,
  client_secret  TEXT,
  discovery_url  TEXT,
  -- manual endpoint overrides (used when discovery_url is not provided)
  authorization_endpoint TEXT,
  token_endpoint         TEXT,
  userinfo_endpoint      TEXT,
  scopes         TEXT NOT NULL DEFAULT 'openid email profile',
  -- Telegram-specific
  bot_token      TEXT,
  bot_username   TEXT,
  button_text    TEXT NOT NULL DEFAULT 'Sign in',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_idp_links (
  id          SERIAL PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider_id INTEGER NOT NULL REFERENCES oidc_providers(id) ON DELETE CASCADE,
  subject     TEXT NOT NULL,               -- OIDC "sub" claim
  UNIQUE (provider_id, subject)
);

CREATE TABLE IF NOT EXISTS user_access_grants (
  id            SERIAL PRIMARY KEY,
  user_id       INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  resource_type TEXT NOT NULL
                  CHECK (resource_type IN ('site','device','device_role','interface','all')),
  resource_id   TEXT,                      -- null means "all of that type"
  permission    TEXT NOT NULL DEFAULT 'read'
                  CHECK (permission IN ('read','write','admin')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed: default superadmin  (password: admin)
-- Hash generated with bcrypt rounds=10
INSERT INTO users (email, password_hash, first_name, last_name, role)
VALUES (
  'admin@localhost',
  '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  'Admin',
  'User',
  'superadmin'
)
ON CONFLICT (email) DO NOTHING;
