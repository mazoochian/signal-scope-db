-- ─────────────────────────────────────────────────────────────────────────────
-- Seed vendor_profiles + vendor_capability_defaults for the four vendors
-- implemented this phase (Cisco IOS/IOS-XE, Juniper Junos, Arista EOS,
-- MikroTik RouterOS). Facts below are transcribed directly from
-- signal-scope-docs/comparison/snmp-write-support-matrix.md and
-- cli-syntax-matrix.md — this migration does not introduce any new
-- research, it structures research that already exists in the docs tree.
-- confidence/source columns mirror that file's own confidence tiers.
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO vendor_profiles (id, display_name, cli_dialect, default_transport, supports_candidate_config) VALUES
  ('cisco-ios',      'Cisco IOS/IOS-XE',   'ios-like',        'ssh', false),
  ('juniper-junos',  'Juniper Junos',      'junos-candidate', 'ssh', true),
  ('arista-eos',     'Arista EOS',         'ios-like',        'ssh', false),
  ('mikrotik-routeros', 'MikroTik RouterOS', 'menu-path',     'ssh', false)
ON CONFLICT (id) DO NOTHING;

-- ── Cisco IOS/IOS-XE ────────────────────────────────────────────────────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('cisco-ios', 'snmp.write.port_admin_status', '{"supported": true, "oid": "IF-MIB::ifAdminStatus"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('cisco-ios', 'snmp.write.port_description',  '{"supported": true, "oid": "IF-MIB::ifAlias"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('cisco-ios', 'snmp.write.vlan_pvid',          '{"supported": true, "oid": "CISCO-VLAN-MEMBERSHIP-MIB::vmVlan"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('cisco-ios', 'snmp.write.vlan_trunk_allowed', '{"supported": false, "note": "no documented path even for theoretically-applicable Q-BRIDGE-MIB bitmask objects"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('cisco-ios', 'snmp.write.stp_edge_port',      '{"supported": false, "note": "no MIB object represents this concept"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('cisco-ios', 'snmp.write.lacp_membership',    '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('cisco-ios', 'snmp.write.port_security',      '{"supported": false, "note": "CISCO-PORT-SECURITY-MIB objects are read-write in MIB source but no documented SET workflow exists - do not trust MAX-ACCESS alone"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('cisco-ios', 'snmp.write.config_save',        '{"supported": true, "oid": "CISCO-CONFIG-COPY-MIB::ccCopyTable", "note": "RowStatus-driven"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('cisco-ios', 'snmp.write.snmp_self_config',   '{"supported": false, "note": "structurally impossible - configuring SNMP via SNMP is circular"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('cisco-ios', 'cli.candidate_config',    '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('cisco-ios', 'cli.enable_required',     '{"value": true}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('cisco-ios', 'cli.negation_keyword',    '{"value": "no"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('cisco-ios', 'cli.paging_disable_cmd',  '{"value": "terminal length 0"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('cisco-ios', 'cli.save_persist_cmd',    '{"kind": "persist", "commands": ["copy running-config startup-config"]}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('cisco-ios', 'cli.interface_naming_pattern', '{"pattern": "<Type><slot>/<port>", "example": "GigabitEthernet0/1"}', 'confirmed', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;

-- ── Arista EOS ───────────────────────────────────────────────────────────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('arista-eos', 'snmp.write.port_admin_status', '{"supported": true, "oid": "IF-MIB::ifAdminStatus"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('arista-eos', 'snmp.write.port_description',  '{"supported": true, "oid": "IF-MIB::ifAlias"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('arista-eos', 'snmp.write.vlan_pvid',          '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('arista-eos', 'snmp.write.vlan_trunk_allowed', '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('arista-eos', 'snmp.write.stp_edge_port',      '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('arista-eos', 'snmp.write.lacp_membership',    '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('arista-eos', 'snmp.write.port_security',      '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('arista-eos', 'snmp.write.config_save',        '{"supported": false, "note": "ARISTA-CONFIG-COPY-MIB exists by name, no confirmed SET trigger found"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('arista-eos', 'snmp.write.snmp_self_config',   '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('arista-eos', 'cli.candidate_config',    '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('arista-eos', 'cli.enable_required',     '{"value": true}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('arista-eos', 'cli.negation_keyword',    '{"value": "no"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('arista-eos', 'cli.paging_disable_cmd',  '{"value": "terminal length 0"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('arista-eos', 'cli.save_persist_cmd',    '{"kind": "persist", "commands": ["write memory"]}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('arista-eos', 'cli.interface_naming_pattern', '{"pattern": "Ethernet<n>", "example": "Ethernet1"}', 'confirmed', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;

-- ── Juniper Junos ────────────────────────────────────────────────────────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('juniper-junos', 'snmp.write.port_admin_status', '{"supported": false, "note": "explicitly documented as not SET-able"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('juniper-junos', 'snmp.write.port_description',  '{"supported": false, "note": "unconfirmed"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('juniper-junos', 'snmp.write.vlan_pvid',          '{"supported": false, "note": "field reports describe unreliable NMS support"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('juniper-junos', 'snmp.write.vlan_trunk_allowed', '{"supported": false, "note": "unconfirmed"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('juniper-junos', 'snmp.write.stp_edge_port',      '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('juniper-junos', 'snmp.write.lacp_membership',    '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('juniper-junos', 'snmp.write.port_security',      '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('juniper-junos', 'snmp.write.config_save',        '{"supported": false, "note": "commit is not an SNMP concept - JUNIPER-CFGMGMT-MIB only emits read-only notifications about a CLI/NETCONF commit that already happened"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('juniper-junos', 'snmp.write.snmp_self_config',   '{"supported": true, "oid": "SNMP-COMMUNITY-MIB::snmpCommunityTable", "note": "rare exception; bootstrapping still requires already having write access"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('juniper-junos', 'cli.candidate_config',    '{"value": true, "note": "configure opens an edit buffer; set/delete mutate the candidate; nothing takes effect until commit"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('juniper-junos', 'cli.enable_required',     '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('juniper-junos', 'cli.negation_keyword',    '{"value": "delete", "note": "delete removes a candidate statement vs set which adds/changes one - not a per-line negation particle"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('juniper-junos', 'cli.paging_disable_cmd',  '{"value": "set cli screen-length 0", "note": "operational mode, not config mode"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('juniper-junos', 'cli.save_persist_cmd',    '{"kind": "commit", "commands": ["commit"], "note": "commit confirmed <n> / commit check variants also exist"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('juniper-junos', 'cli.interface_naming_pattern', '{"pattern": "<media>-<fpc>/<pic>/<port> unit <n>", "example": "ge-0/0/1 unit 0"}', 'confirmed', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;

-- ── MikroTik RouterOS ────────────────────────────────────────────────────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('mikrotik-routeros', 'snmp.write.port_admin_status', '{"supported": false, "note": "no confirmed SNMP write path documented by MikroTik for this"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('mikrotik-routeros', 'snmp.write.port_description',  '{"supported": false, "note": "sysName/sysContact/sysLocation confirmed writable; ifAlias specifically not separately confirmed"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('mikrotik-routeros', 'snmp.write.vlan_pvid',          '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('mikrotik-routeros', 'snmp.write.vlan_trunk_allowed', '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('mikrotik-routeros', 'snmp.write.stp_edge_port',      '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('mikrotik-routeros', 'snmp.write.lacp_membership',    '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('mikrotik-routeros', 'snmp.write.port_security',      '{"supported": false, "note": "no single equivalent feature"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('mikrotik-routeros', 'snmp.write.config_save',        '{"supported": false, "note": "no save concept exists on this platform"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('mikrotik-routeros', 'snmp.write.snmp_self_config',   '{"supported": false, "note": "not investigated"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('mikrotik-routeros', 'cli.candidate_config',    '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('mikrotik-routeros', 'cli.enable_required',     '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('mikrotik-routeros', 'cli.negation_keyword',    '{"value": null, "note": "disable/enable/remove are the verbs themselves, not a particle prepended to another verb"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('mikrotik-routeros', 'cli.paging_disable_cmd',  '{"value": null, "note": "RouterOS console output is not paginated the way EXEC-style CLIs are"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('mikrotik-routeros', 'cli.save_persist_cmd',    '{"kind": "none", "commands": [], "note": "no running/startup-config split and no save step at all - every command is durably persisted the instant it runs"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('mikrotik-routeros', 'cli.interface_naming_pattern', '{"pattern": "free-text name", "example": "ether1"}', 'confirmed', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;
