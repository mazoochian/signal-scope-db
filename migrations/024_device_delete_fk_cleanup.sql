-- Fix ON DELETE behavior for every FK that points at devices(id)/interfaces(id)
-- but was never given one (defaults to NO ACTION, i.e. blocks the delete).
--
-- Confirmed via pg_constraint: device_metrics, interface_metrics,
-- syslog_messages, alerts, inventory_assets, telemetry_subscriptions,
-- topology_nodes, and wireless_access_points all had confdeltype = 'a'
-- (NO ACTION) — meaning DELETE FROM devices WHERE id = ... has always
-- thrown a foreign key violation for any of the 10 simulated seed
-- devices, since simulation.service.ts writes device_metrics for them
-- within seconds of boot. The signal-scope-be DELETE /devices/:id
-- endpoint existed but had no frontend button — this is what made adding
-- one (AUDIT-REPORT.md gap analysis, Tier 1) surface the problem instead
-- of it being silently unreachable.
--
-- Two different fixes depending on what the table already models:
--   - device_metrics / interface_metrics: pure derived telemetry with no
--     identity of its own once its device/interface is gone → CASCADE.
--   - alerts / syslog_messages / inventory_assets / telemetry_subscriptions
--     / topology_nodes / wireless_access_points: each already carries its
--     own denormalized identity (device_name text, host_name, label, or
--     its own name) specifically so the record still means something
--     without a live device row → SET NULL, preserving history instead of
--     cascading a delete through it.

ALTER TABLE device_metrics
  DROP CONSTRAINT device_metrics_device_id_fkey,
  ADD CONSTRAINT device_metrics_device_id_fkey
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE;

ALTER TABLE interface_metrics
  DROP CONSTRAINT interface_metrics_interface_id_fkey,
  ADD CONSTRAINT interface_metrics_interface_id_fkey
    FOREIGN KEY (interface_id) REFERENCES interfaces(id) ON DELETE CASCADE;

ALTER TABLE alerts
  DROP CONSTRAINT alerts_device_id_fkey,
  ADD CONSTRAINT alerts_device_id_fkey
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL;

ALTER TABLE syslog_messages
  DROP CONSTRAINT syslog_messages_device_id_fkey,
  ADD CONSTRAINT syslog_messages_device_id_fkey
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL;

ALTER TABLE inventory_assets
  DROP CONSTRAINT inventory_assets_device_id_fkey,
  ADD CONSTRAINT inventory_assets_device_id_fkey
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL;

ALTER TABLE telemetry_subscriptions
  DROP CONSTRAINT telemetry_subscriptions_device_id_fkey,
  ADD CONSTRAINT telemetry_subscriptions_device_id_fkey
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL;

ALTER TABLE topology_nodes
  DROP CONSTRAINT topology_nodes_device_id_fkey,
  ADD CONSTRAINT topology_nodes_device_id_fkey
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL;

ALTER TABLE wireless_access_points
  DROP CONSTRAINT wireless_access_points_device_id_fkey,
  ADD CONSTRAINT wireless_access_points_device_id_fkey
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL;
