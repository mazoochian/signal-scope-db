-- Add suppressed state to alerts
ALTER TABLE alerts ADD COLUMN suppressed    BOOLEAN     NOT NULL DEFAULT false;
ALTER TABLE alerts ADD COLUMN suppressed_at TIMESTAMPTZ;

-- Suppress the two existing children of the BGP root-cause alert so the
-- feature is immediately visible in the UI on first load.
UPDATE alerts
SET suppressed = true, suppressed_at = now() - INTERVAL '1 minute'
WHERE id IN ('ALR-90212', 'ALR-90211');

INSERT INTO alert_history (time, alert_id, severity, state, device_name) VALUES
  (now() - INTERVAL '1 minute', 'ALR-90212', 'Critical', 'suppressed', 'edge-rtr-nyc-01'),
  (now() - INTERVAL '4 minutes', 'ALR-90211', 'Critical', 'suppressed', 'core-sw-dca-02');

-- Additional seed alerts
INSERT INTO alerts (id, severity, kind, title, device_name, device_id, iface, rule, acknowledged, suppressed, suppressed_at, root_cause, child_count, fired_at)
VALUES
  ('ALR-90215', 'Critical', 'down', 'Tunnel VPN-Site-A down',
   'fw-edge-sea-01', (SELECT id FROM devices WHERE name='fw-edge-sea-01'),
   'tunnel0', 'VPN::TunnelDown', false, true, now() - INTERVAL '30 seconds', 'CHILD', 0,
   now() - INTERVAL '2 minutes 30 seconds'),
  ('ALR-90210', 'Major', 'warn', 'Memory utilization > 90% for 5m',
   'wlc-hq-01', (SELECT id FROM devices WHERE name='wlc-hq-01'),
   '—', 'MEM::High', false, false, NULL, '—', 0,
   now() - INTERVAL '8 minutes 20 seconds'),
  ('ALR-90204', 'Major', 'warn', 'Interface utilization > 95%',
   'core-sw-01', (SELECT id FROM devices WHERE name='core-sw-01'),
   'Te1/1/49', 'IF::Util', false, false, NULL, '—', 0,
   now() - INTERVAL '23 minutes'),
  ('ALR-90196', 'Minor', 'info', 'NTP sync failure',
   'edge-rtr-nyc-02', (SELECT id FROM devices WHERE name='edge-rtr-nyc-02'),
   '—', 'NTP::SyncFail', false, false, NULL, '—', 0,
   now() - INTERVAL '1 hour 15 minutes'),
  ('ALR-90193', 'Warning', 'warn', 'STP topology change detected',
   'acc-sw-hq-09', (SELECT id FROM devices WHERE name='acc-sw-hq-09'),
   'Gi1/0/48', 'STP::TCN', false, false, NULL, '—', 0,
   now() - INTERVAL '3 hours 5 minutes');

INSERT INTO alert_history (time, alert_id, severity, state, device_name) VALUES
  (now() - INTERVAL '2 minutes 30 seconds', 'ALR-90215', 'Critical', 'fired',      'fw-edge-sea-01'),
  (now() - INTERVAL '30 seconds',           'ALR-90215', 'Critical', 'suppressed', 'fw-edge-sea-01'),
  (now() - INTERVAL '8 minutes 20 seconds', 'ALR-90210', 'Major',    'fired',      'wlc-hq-01'),
  (now() - INTERVAL '23 minutes',           'ALR-90204', 'Major',    'fired',      'core-sw-01'),
  (now() - INTERVAL '75 minutes',           'ALR-90196', 'Minor',    'fired',      'edge-rtr-nyc-02'),
  (now() - INTERVAL '185 minutes',          'ALR-90193', 'Warning',  'fired',      'acc-sw-hq-09');
