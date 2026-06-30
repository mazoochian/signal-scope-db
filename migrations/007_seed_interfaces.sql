-- Seed interfaces for all devices that don't yet have any

-- Device 2: core-sw-02 (Cisco C9500-48Y4C) — same role as core-sw-01
INSERT INTO interfaces (device_id, name, description, speed, duplex, vlan, status) VALUES
  (2, 'Gi0/3',    'mgmt OOB',          '1G',  'full', '99',    'up'),
  (2, 'Gi0/5',    'trunk vlan100-300', '1G',  'full', 'trunk', 'up'),
  (2, 'Te1/0/1',  'uplink agg-01',     '10G', 'full', 'trunk', 'up'),
  (2, 'Te1/0/2',  'uplink agg-02',     '10G', 'full', 'trunk', 'up'),
  (2, 'Te1/0/24', 'spine→leaf-09',     '10G', 'full', 'trunk', 'warn'),
  (2, 'Te1/1/49', 'ISP-B handoff',     '10G', 'full', 'wan-100','up'),
  (2, 'Te2/0/1',  'peer-link',         '10G', 'full', 'trunk', 'up'),
  (2, 'Te2/0/2',  'backup-cluster',    '10G', 'full', '30',    'up')
ON CONFLICT (device_id, name) DO NOTHING;

-- Device 3: edge-rtr-nyc-01 (Juniper MX204) — edge router, down
INSERT INTO interfaces (device_id, name, description, speed, duplex, vlan, status) VALUES
  (3, 'et-0/0/0',  'ISP-A WAN handoff',    '10G', 'full', 'wan-100', 'down'),
  (3, 'et-0/0/1',  'ISP-B WAN handoff',    '10G', 'full', 'wan-200', 'down'),
  (3, 'ge-0/0/0',  'management',           '1G',  'full', '99',      'down'),
  (3, 'ge-0/0/1',  'core-sw-01 uplink',    '1G',  'full', 'trunk',   'down'),
  (3, 'lo0',       'loopback',             '1G',  'full', null,      'down')
ON CONFLICT (device_id, name) DO NOTHING;

-- Device 4: edge-rtr-nyc-02 (Juniper MX204) — edge router, up
INSERT INTO interfaces (device_id, name, description, speed, duplex, vlan, status) VALUES
  (4, 'et-0/0/0',  'ISP-A WAN handoff',    '10G', 'full', 'wan-100', 'up'),
  (4, 'et-0/0/1',  'ISP-B WAN handoff',    '10G', 'full', 'wan-200', 'up'),
  (4, 'et-0/0/2',  'MPLS P2P to core',     '10G', 'full', 'trunk',   'up'),
  (4, 'ge-0/0/0',  'management',           '1G',  'full', '99',      'up'),
  (4, 'ge-0/0/1',  'core-sw-02 uplink',    '1G',  'full', 'trunk',   'up'),
  (4, 'lo0',       'loopback',             '1G',  'full', null,      'up')
ON CONFLICT (device_id, name) DO NOTHING;

-- Device 5: agg-rtr-lax-01 (Arista 7280SR3) — aggregation router, warn
INSERT INTO interfaces (device_id, name, description, speed, duplex, vlan, status) VALUES
  (5, 'Ethernet1',  'uplink to core',       '100G', 'full', 'trunk', 'up'),
  (5, 'Ethernet2',  'uplink to core redundant', '100G', 'full', 'trunk', 'warn'),
  (5, 'Ethernet3',  'to access sw 01',      '10G',  'full', 'trunk', 'up'),
  (5, 'Ethernet4',  'to access sw 02',      '10G',  'full', 'trunk', 'up'),
  (5, 'Ethernet5',  'WAN ISP-C',            '10G',  'full', 'wan-300','up'),
  (5, 'Management1','OOB management',       '1G',   'full', '99',    'up'),
  (5, 'Loopback0',  'loopback',             '1G',   'full', null,    'up')
ON CONFLICT (device_id, name) DO NOTHING;

-- Device 6: fw-edge-sea-01 (Palo Alto PA-5430) — firewall, warn
INSERT INTO interfaces (device_id, name, description, speed, duplex, vlan, status) VALUES
  (6, 'ethernet1/1', 'UNTRUST - ISP uplink',  '10G', 'full', 'wan-100', 'up'),
  (6, 'ethernet1/2', 'TRUST - LAN zone',      '10G', 'full', 'trunk',   'up'),
  (6, 'ethernet1/3', 'DMZ zone',              '10G', 'full', '50',      'warn'),
  (6, 'ethernet1/4', 'HA1 heartbeat',         '1G',  'full', '200',     'up'),
  (6, 'management',  'OOB management',        '1G',  'full', '99',      'up')
ON CONFLICT (device_id, name) DO NOTHING;

-- Device 7: acc-sw-hq-09 (Cisco C9300-48UXM) — access switch, warn
INSERT INTO interfaces (device_id, name, description, speed, duplex, vlan, status) VALUES
  (7, 'Gi1/0/1',   'uplink agg-sw',         '1G',  'full', 'trunk', 'up'),
  (7, 'Gi1/0/2',   'uplink redundant',      '1G',  'full', 'trunk', 'warn'),
  (7, 'Gi1/0/10',  'workstation-A39',       '1G',  'full', '10',    'up'),
  (7, 'Gi1/0/11',  'workstation-A40',       '1G',  'full', '10',    'up'),
  (7, 'Gi1/0/12',  'IP phone floor-1',      '1G',  'full', '20',    'warn'),
  (7, 'Gi1/0/13',  'printer-HQ-09',         '1G',  'full', '10',    'up'),
  (7, 'Gi1/0/48',  'WAP-HQ-09 AP',          '1G',  'full', '30',    'up'),
  (7, 'Te1/1/1',   'cross-connect to fw',   '10G', 'full', 'trunk', 'up')
ON CONFLICT (device_id, name) DO NOTHING;

-- Device 8: acc-sw-dc-10 (Arista 7050SX3) — access switch, up
INSERT INTO interfaces (device_id, name, description, speed, duplex, vlan, status) VALUES
  (8, 'Ethernet1',  'uplink to agg',         '25G', 'full', 'trunk', 'up'),
  (8, 'Ethernet2',  'uplink redundant',      '25G', 'full', 'trunk', 'up'),
  (8, 'Ethernet3',  'server-dc-01',          '10G', 'full', '100',   'up'),
  (8, 'Ethernet4',  'server-dc-02',          '10G', 'full', '100',   'up'),
  (8, 'Ethernet5',  'server-dc-03',          '10G', 'full', '101',   'up'),
  (8, 'Ethernet6',  'KVM console server',    '1G',  'full', '99',    'up'),
  (8, 'Management1','OOB management',        '1G',  'full', '99',    'up')
ON CONFLICT (device_id, name) DO NOTHING;

-- Device 9: wlc-hq-01 (Cisco C9800-CL) — WLC, up
INSERT INTO interfaces (device_id, name, description, speed, duplex, vlan, status) VALUES
  (9, 'Gi1',       'WAN/uplink to core',    '1G',  'full', 'trunk', 'up'),
  (9, 'Gi2',       'management',            '1G',  'full', '99',    'up'),
  (9, 'Gi3',       'AP management',         '1G',  'full', '30',    'up'),
  (9, 'Gi4',       'client data vlan 10',   '1G',  'full', '10',    'up'),
  (9, 'Gi5',       'guest wifi vlan 40',    '1G',  'full', '40',    'up')
ON CONFLICT (device_id, name) DO NOTHING;

-- Device 10: core-sw-fra-01 (Nokia 7750-SR-1) — core switch, up
INSERT INTO interfaces (device_id, name, description, speed, duplex, vlan, status) VALUES
  (10, '1/1/1',   'uplink ISP-DE',         '100G', 'full', 'wan-500', 'up'),
  (10, '1/1/2',   'uplink ISP-NL',         '100G', 'full', 'wan-501', 'up'),
  (10, '1/1/3',   'MPLS to HQ-NYC',        '100G', 'full', 'trunk',   'up'),
  (10, '1/1/4',   'to agg-fra-01',         '10G',  'full', 'trunk',   'up'),
  (10, '1/1/5',   'to agg-fra-02',         '10G',  'full', 'trunk',   'up'),
  (10, '1/1/6',   'OOB management',        '1G',   'full', '99',      'up'),
  (10, 'lo0',     'loopback system',       '1G',   'full', null,      'up')
ON CONFLICT (device_id, name) DO NOTHING;
