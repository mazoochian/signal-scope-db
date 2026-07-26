-- ─────────────────────────────────────────────────────────────────────────────
-- DEVICE VLANS
--
-- Generalizes every vendor's differently-named/differently-shaped VLAN
-- membership concept (Cisco CISCO-VLAN-MEMBERSHIP-MIB::vmVlan, Q-BRIDGE-MIB
-- dot1qPvid/dot1qVlanStaticEgressPorts, Fortinet FortiLink's separate
-- vlan/allowed-vlans/untagged-vlans fields, Dell OS10's trunk-mode
-- `switchport access vlan` quirk, Ubiquiti's separate
-- participation/tagging steps — see signal-scope-docs/comparison/ and
-- vendors/*/mib-reference.md) into one vendor-agnostic row shape. The
-- vendor adapter layer, not this schema, is responsible for translating
-- "which interface_vlan_membership rows changed" into that vendor's
-- literal CLI/SNMP commands.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS device_vlans (
  id         SERIAL PRIMARY KEY,
  device_id  INTEGER NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  vlan_id    INTEGER NOT NULL CHECK (vlan_id BETWEEN 1 AND 4094),
  name       TEXT,
  source     TEXT NOT NULL DEFAULT 'manual' CHECK (source IN ('snmp', 'cli', 'manual')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (device_id, vlan_id)
);

CREATE INDEX IF NOT EXISTS idx_device_vlans_device ON device_vlans(device_id);

CREATE TABLE IF NOT EXISTS interface_vlan_membership (
  id             SERIAL PRIMARY KEY,
  interface_id   INTEGER NOT NULL REFERENCES interfaces(id) ON DELETE CASCADE,
  device_vlan_id INTEGER NOT NULL REFERENCES device_vlans(id) ON DELETE CASCADE,
  tagging        TEXT NOT NULL CHECK (tagging IN ('untagged', 'tagged', 'native')),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (interface_id, device_vlan_id)
);

CREATE INDEX IF NOT EXISTS idx_interface_vlan_membership_interface ON interface_vlan_membership(interface_id);
CREATE INDEX IF NOT EXISTS idx_interface_vlan_membership_vlan ON interface_vlan_membership(device_vlan_id);
