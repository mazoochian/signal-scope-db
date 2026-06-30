-- ─────────────────────────────────────────────────────────────────────────────
-- SLA PARAMETERS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sla_parameters (
  id            SERIAL PRIMARY KEY,
  name          TEXT    NOT NULL,
  metric        TEXT    NOT NULL,        -- availability|latency|packet_loss|cpu|memory|interface_util
  target_value  NUMERIC NOT NULL,        -- e.g. 99.9 (%) or 50 (ms)
  operator      TEXT    NOT NULL DEFAULT '>='
                CHECK (operator IN ('>=', '<=', '=')),
  scope_type    TEXT    NOT NULL DEFAULT 'all',  -- all|site|device|role
  scope_value   TEXT,                            -- site/device/role name; NULL = all
  enabled       BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO sla_parameters (name, metric, target_value, operator, scope_type) VALUES
  ('Network Availability',     'availability',   99.9, '>=', 'all'),
  ('WAN Latency',              'latency',        50,   '<=', 'all'),
  ('Packet Loss',              'packet_loss',    0.1,  '<=', 'all'),
  ('Core CPU Utilization',     'cpu',            80,   '<=', 'all'),
  ('Core Memory Utilization',  'memory',         85,   '<=', 'all'),
  ('Interface Utilization',    'interface_util', 80,   '<=', 'all')
ON CONFLICT DO NOTHING;
