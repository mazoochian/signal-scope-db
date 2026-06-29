-- Extend the oidc_providers provider_type check constraint to include
-- 'oidc' (generic OIDC / Authentik / Authelia etc.) and 'slack' (Sign in with Slack),
-- which the frontend sends but were missing from the original constraint.
ALTER TABLE oidc_providers DROP CONSTRAINT IF EXISTS oidc_providers_provider_type_check;
ALTER TABLE oidc_providers ADD CONSTRAINT oidc_providers_provider_type_check
  CHECK (provider_type IN ('google','telegram','keycloak','authentik','authelia','custom','oidc','slack'));
