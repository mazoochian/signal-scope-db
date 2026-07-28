-- ─────────────────────────────────────────────────────────────────────────────
-- Seed vendor_profiles + vendor_capability_defaults for the nine vendors
-- implemented this phase (Extreme EXOS, Huawei VRP, HPE Aruba AOS-CX, Dell
-- PowerSwitch OS10, D-Link, Fortinet FortiSwitch standalone-CLI, Ubiquiti
-- UniFi, Netgear M-series, Zyxel). Facts below are transcribed directly from
-- the corresponding signal-scope-be/src/device-control/adapters/*.adapter.ts
-- class doc comments, which are themselves transcribed from
-- signal-scope-docs/vendors/<vendor>/*.md and
-- comparison/{snmp-write-support-matrix.md,cli-syntax-matrix.md} — this
-- migration does not introduce any new research. confidence/source columns
-- mirror the same confidence tiers used in 022, and use the DB's actual
-- confidence enum ('confirmed' | 'assumed' | 'unknown' — see
-- 017_device_control_core.sql), not the docs tree's own prose labels.
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO vendor_profiles (id, display_name, cli_dialect, default_transport, supports_candidate_config) VALUES
  ('extreme-exos', 'Extreme Networks ExtremeXOS (EXOS)', 'exos-flat', 'ssh', false),
  ('huawei-vrp',   'Huawei VRP (S-series switches)',     'vrp-system-view', 'ssh', false),
  ('aruba-aoscx',  'HPE Aruba Networking AOS-CX',         'ios-like', 'ssh', false),
  ('dell-os10',    'Dell PowerSwitch (SmartFabric OS10)', 'ios-like', 'ssh', false),
  ('dlink',        'D-Link (Cisco-like CLI family: DGS-1210/1510/3130/3620/6600)', 'ios-like', 'ssh', false),
  ('fortinet',     'Fortinet FortiSwitch (standalone CLI)', 'fortios-block', 'ssh', false),
  ('ubiquiti',     'Ubiquiti UniFi switches (direct CLI — controller-first, see note)', 'fastpath-menu', 'ssh', false),
  ('netgear',      'Netgear ProSAFE M-series / Intelligent Edge', 'ios-like', 'ssh', false),
  ('zyxel',        'Zyxel (standalone-managed line: XGS4600/GS19x0/GS2210/GS3700 — NOT GS1900)', 'ios-like', 'ssh', false)
ON CONFLICT (id) DO NOTHING;

-- ── Extreme EXOS ─────────────────────────────────────────────────────────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('extreme-exos', 'snmp.write.port_admin_status', '{"supported": true, "oid": "IF-MIB::ifAdminStatus"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('extreme-exos', 'snmp.write.port_description',  '{"supported": false, "note": "no confirmed-safe SNMP write path per overview.md write-scope table"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('extreme-exos', 'snmp.write.vlan_pvid',          '{"supported": true, "oid": "Q-BRIDGE-MIB::dot1qPvid", "note": "first-hand from EXOS 30.6 User Guide"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('extreme-exos', 'snmp.write.vlan_trunk_allowed', '{"supported": false, "note": "dot1qVlanStaticEgressPorts is Read-Create but is a per-VLAN bitmask requiring read-modify-write, not a safe single SET — deliberately treated as unsupported for this action shape; also no separate egress/ingress state on EXOS"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('extreme-exos', 'snmp.write.stp_edge_port',      '{"supported": false, "note": "no MIB object represents this concept"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('extreme-exos', 'snmp.write.lacp_membership',    '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('extreme-exos', 'snmp.write.port_security',      '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('extreme-exos', 'snmp.write.config_save',        '{"supported": true, "oid": "EXTREME-SYSTEM-MIB::extremeSaveConfiguration", "note": "provisional OID, third-party-mirror-sourced — not independently confirmed against Extreme''s own MIB text"}', 'assumed', 'comparison/snmp-write-support-matrix.md'),
  ('extreme-exos', 'snmp.write.snmp_self_config',   '{"supported": false, "note": "structurally impossible - configuring SNMP via SNMP is circular"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('extreme-exos', 'cli.candidate_config',    '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('extreme-exos', 'cli.enable_required',     '{"value": false, "note": "no separate privileged-mode step"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('extreme-exos', 'cli.negation_keyword',    '{"value": null, "note": "enable/disable are paired verbs, not a single negation particle"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('extreme-exos', 'cli.paging_disable_cmd',  '{"value": "disable clipaging", "note": "session-scoped only, not persisted"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('extreme-exos', 'cli.save_persist_cmd',    '{"kind": "persist", "commands": ["save configuration"]}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('extreme-exos', 'cli.interface_naming_pattern', '{"pattern": "<slot>:<port>", "example": "1:3"}', 'confirmed', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;

-- ── Huawei VRP ───────────────────────────────────────────────────────────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('huawei-vrp', 'snmp.write.port_admin_status', '{"supported": true, "oid": "IF-MIB::ifAdminStatus", "note": "Supported baseline per mib-reference.md"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('huawei-vrp', 'snmp.write.port_description',  '{"supported": true, "oid": "IF-MIB::ifAlias"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('huawei-vrp', 'snmp.write.vlan_pvid',          '{"supported": true, "oid": "Q-BRIDGE-MIB::dot1qPvid", "note": "Huawei''s own MIB reference page: only dot1qPvid can be modified"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('huawei-vrp', 'snmp.write.vlan_trunk_allowed', '{"supported": false, "note": "not independently confirmed"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('huawei-vrp', 'snmp.write.stp_edge_port',      '{"supported": false, "note": "not independently confirmed"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('huawei-vrp', 'snmp.write.lacp_membership',    '{"supported": false, "note": "not independently confirmed"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('huawei-vrp', 'snmp.write.port_security',      '{"supported": false, "note": "not independently confirmed"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('huawei-vrp', 'snmp.write.config_save',        '{"supported": false, "note": "not independently confirmed — weakest-evidenced vendor in this project after Dell''s verified-absence finding"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('huawei-vrp', 'snmp.write.snmp_self_config',   '{"supported": false, "note": "structurally impossible - configuring SNMP via SNMP is circular"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('huawei-vrp', 'cli.candidate_config',    '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('huawei-vrp', 'cli.enable_required',     '{"value": false, "note": "no separate unprivileged/privileged EXEC split by default"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('huawei-vrp', 'cli.negation_keyword',    '{"value": "undo"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('huawei-vrp', 'cli.paging_disable_cmd',  '{"value": "screen-length 0 temporary", "note": "session-scoped only, not persisted"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('huawei-vrp', 'cli.save_persist_cmd',    '{"kind": "persist", "commands": ["save"]}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('huawei-vrp', 'cli.interface_naming_pattern', '{"pattern": "<Type><stack/chassis>/<slot>/<port>", "example": "GigabitEthernet0/0/1"}', 'confirmed', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;

-- ── HPE Aruba AOS-CX ─────────────────────────────────────────────────────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('aruba-aoscx', 'snmp.write.port_admin_status', '{"supported": true, "oid": "IF-MIB::ifAdminStatus"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('aruba-aoscx', 'snmp.write.port_description',  '{"supported": true, "oid": "IF-MIB::ifAlias"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('aruba-aoscx', 'snmp.write.vlan_pvid',          '{"supported": true, "oid": "Q-BRIDGE-MIB::dot1qPvid", "note": "search-summary-sourced, official HPE page 403''d to direct fetch"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('aruba-aoscx', 'snmp.write.vlan_trunk_allowed', '{"supported": true, "oid": "Q-BRIDGE-MIB::dot1qVlanStaticEgressPorts", "note": "per-VLAN PortList bitmask requiring GET-then-modify-then-SET — only vendor in this project with a confirmed SNMP path for trunk-allowed-list specifically"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('aruba-aoscx', 'snmp.write.stp_edge_port',      '{"supported": true, "oid": "ARUBAWIRED-MSTP-MIB::arubaWiredMstpPortAdminEdge", "note": "the only confirmed SNMP write path for the STP edge-port/PortFast-equivalent concept across every vendor in this project — no corresponding DeviceAction kind exists this phase, so it is not represented in buildSnmpPlan"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('aruba-aoscx', 'snmp.write.lacp_membership',    '{"supported": false, "note": "not confirmed"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('aruba-aoscx', 'snmp.write.port_security',      '{"supported": true, "oid": "ARUBAWIRED-PORTSECURITY-MIB", "note": "no corresponding DeviceAction kind exists this phase, so it is not represented in buildSnmpPlan"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('aruba-aoscx', 'snmp.write.config_save',        '{"supported": true, "oid": "ARUBAWIRED-CONFIG-MIB::arubaWiredConfigurationCopyTable", "note": "table root OID confirmed; exact per-column numeric suffixes not enumerated this session"}', 'assumed', 'comparison/snmp-write-support-matrix.md'),
  ('aruba-aoscx', 'snmp.write.snmp_self_config',   '{"supported": false, "note": "structurally impossible - configuring SNMP via SNMP is circular"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('aruba-aoscx', 'cli.candidate_config',    '{"value": false, "note": "an opt-in checkpoint/checkpoint auto <n> guarded-apply safety net exists on top of immediate-apply but is a distinct concept from plain Save"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('aruba-aoscx', 'cli.enable_required',     '{"value": true}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('aruba-aoscx', 'cli.negation_keyword',    '{"value": "no"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('aruba-aoscx', 'cli.paging_disable_cmd',  '{"value": "no page", "note": "confirmed session-only, not persistent across reboot (Phase 2 reversal of an earlier community-sourced claim)"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('aruba-aoscx', 'cli.save_persist_cmd',    '{"kind": "persist", "commands": ["copy running-config startup-config"]}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('aruba-aoscx', 'cli.interface_naming_pattern', '{"pattern": "<member>/<slot>/<port>", "example": "1/1/1"}', 'confirmed', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;

-- ── Dell PowerSwitch (SmartFabric OS10) ──────────────────────────────────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('dell-os10', 'snmp.write.port_admin_status', '{"supported": false, "note": "verified absence — none of OS10''s 5 enterprise MIBs is a configuration-action module"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('dell-os10', 'snmp.write.port_description',  '{"supported": false, "note": "verified absence"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('dell-os10', 'snmp.write.vlan_pvid',          '{"supported": false, "note": "verified absence"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('dell-os10', 'snmp.write.vlan_trunk_allowed', '{"supported": false, "note": "verified absence"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('dell-os10', 'snmp.write.stp_edge_port',      '{"supported": false, "note": "verified absence"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('dell-os10', 'snmp.write.lacp_membership',    '{"supported": false, "note": "verified absence"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('dell-os10', 'snmp.write.port_security',      '{"supported": false, "note": "verified absence"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('dell-os10', 'snmp.write.config_save',        '{"supported": false, "note": "verified absence — no Dell equivalent of CISCO-CONFIG-COPY-MIB exists at all"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('dell-os10', 'snmp.write.snmp_self_config',   '{"supported": false, "note": "structurally impossible - configuring SNMP via SNMP is circular"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('dell-os10', 'cli.candidate_config',    '{"value": false, "note": "default immediate-apply mode; an opt-in start transaction candidate mode also exists but is deliberately not modeled by this adapter (same worker-model session-scoping risk as Junos, see adapter class doc comment)"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('dell-os10', 'cli.enable_required',     '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('dell-os10', 'cli.negation_keyword',    '{"value": "no"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('dell-os10', 'cli.paging_disable_cmd',  '{"value": null, "note": "session-wide paging-disable not confirmed; only a per-command | no-more pipe filter is documented"}', 'unknown', 'comparison/cli-syntax-matrix.md'),
  ('dell-os10', 'cli.save_persist_cmd',    '{"kind": "persist", "commands": ["write memory"]}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('dell-os10', 'cli.interface_naming_pattern', '{"pattern": "ethernet <node>/<slot>/<port>", "example": "ethernet 1/1/2"}', 'confirmed', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;

-- ── D-Link (Cisco-like dialect only) ─────────────────────────────────────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('dlink', 'snmp.write.port_admin_status', '{"supported": false, "note": "SNMP write not independently confirmed for either D-Link dialect — treat as read/monitoring surface pending device-specific confirmation"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('dlink', 'snmp.write.port_description',  '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('dlink', 'snmp.write.vlan_pvid',          '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('dlink', 'snmp.write.vlan_trunk_allowed', '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('dlink', 'snmp.write.stp_edge_port',      '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('dlink', 'snmp.write.lacp_membership',    '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('dlink', 'snmp.write.port_security',      '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('dlink', 'snmp.write.config_save',        '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('dlink', 'snmp.write.snmp_self_config',   '{"supported": false, "note": "structurally impossible - configuring SNMP via SNMP is circular"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('dlink', 'cli.candidate_config',    '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('dlink', 'cli.enable_required',     '{"value": true, "note": "inferred from the Cisco-like family characterization, not separately confirmed"}', 'assumed', 'comparison/cli-syntax-matrix.md'),
  ('dlink', 'cli.negation_keyword',    '{"value": "no"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('dlink', 'cli.paging_disable_cmd',  '{"value": null, "note": "not documented for the Cisco-like family"}', 'unknown', 'comparison/cli-syntax-matrix.md'),
  ('dlink', 'cli.save_persist_cmd',    '{"kind": "persist", "commands": ["copy running-config startup-config"]}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('dlink', 'cli.interface_naming_pattern', '{"pattern": "<unit>/<module>/<port>", "example": "1/0/5"}', 'confirmed', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;

-- ── Fortinet FortiSwitch (standalone CLI only) ───────────────────────────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('fortinet', 'snmp.write.port_admin_status', '{"supported": false, "note": "overview.md: assume CLI-only for config changes unless a specific object is separately confirmed live"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('fortinet', 'snmp.write.port_description',  '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('fortinet', 'snmp.write.vlan_pvid',          '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('fortinet', 'snmp.write.vlan_trunk_allowed', '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('fortinet', 'snmp.write.stp_edge_port',      '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('fortinet', 'snmp.write.lacp_membership',    '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('fortinet', 'snmp.write.port_security',      '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('fortinet', 'snmp.write.config_save',        '{"supported": false, "note": "FortiOS persists on the config block''s end — the concept of a separate SNMP-triggered save doesn''t apply"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('fortinet', 'snmp.write.snmp_self_config',   '{"supported": false, "note": "structurally impossible - configuring SNMP via SNMP is circular"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('fortinet', 'cli.candidate_config',    '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('fortinet', 'cli.enable_required',     '{"value": false, "note": "single admin CLI level from login, no separate privileged-mode step"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('fortinet', 'cli.negation_keyword',    '{"value": "unset", "note": "not a true single-particle negation — unset resets a field, delete <entry> removes a whole edit-entry"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('fortinet', 'cli.paging_disable_cmd',  '{"value": null, "note": "not documented for FortiSwitch"}', 'unknown', 'comparison/cli-syntax-matrix.md'),
  ('fortinet', 'cli.save_persist_cmd',    '{"kind": "none", "commands": [], "note": "end (already the close of every action''s config block) persists immediately — no separate save command exists"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('fortinet', 'cli.interface_naming_pattern', '{"pattern": "port<n>", "example": "port5"}', 'confirmed', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;

-- ── Ubiquiti UniFi switches (direct CLI — controller-first, see note) ────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('ubiquiti', 'snmp.write.port_admin_status', '{"supported": false, "note": "UBNT-MIB.txt read in full (2301 lines): zero MAX-ACCESS read-write objects — confirmed negative finding"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('ubiquiti', 'snmp.write.port_description',  '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('ubiquiti', 'snmp.write.vlan_pvid',          '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('ubiquiti', 'snmp.write.vlan_trunk_allowed', '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('ubiquiti', 'snmp.write.stp_edge_port',      '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('ubiquiti', 'snmp.write.lacp_membership',    '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('ubiquiti', 'snmp.write.port_security',      '{"supported": false}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('ubiquiti', 'snmp.write.config_save',        '{"supported": false, "note": "the controller, not the device, is the only durable save target"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('ubiquiti', 'snmp.write.snmp_self_config',   '{"supported": false, "note": "structurally impossible - configuring SNMP via SNMP is circular"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('ubiquiti', 'cli.candidate_config',    '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('ubiquiti', 'cli.enable_required',     '{"value": true, "note": "SSH lands in a Linux shell first; the switch CLI is reached via telnet 127.0.0.1 then enable — not a plain SSH-session enable"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('ubiquiti', 'cli.negation_keyword',    '{"value": null, "note": "distinct verbs (vlan participation include/exclude vs. vlan tagging) rather than a negation particle"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('ubiquiti', 'cli.paging_disable_cmd',  '{"value": null, "note": "no pagination command documented for this vendor"}', 'unknown', 'comparison/cli-syntax-matrix.md'),
  ('ubiquiti', 'cli.save_persist_cmd',    '{"kind": "none", "commands": [], "note": "no device-side persist command exists — CLI changes are NOT durable, the UniFi Network Controller overwrites them on next reboot/reprovision; the Controller API is the durable integration point for this vendor"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('ubiquiti', 'cli.interface_naming_pattern', '{"pattern": "<unit>/<port>", "example": "0/1"}', 'confirmed', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;

-- ── Netgear ProSAFE M-series / Intelligent Edge ──────────────────────────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('netgear', 'snmp.write.port_admin_status', '{"supported": false, "note": "not independently confirmed beyond the standard cross-vendor baseline"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('netgear', 'snmp.write.port_description',  '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('netgear', 'snmp.write.vlan_pvid',          '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('netgear', 'snmp.write.vlan_trunk_allowed', '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('netgear', 'snmp.write.stp_edge_port',      '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('netgear', 'snmp.write.lacp_membership',    '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('netgear', 'snmp.write.port_security',      '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('netgear', 'snmp.write.config_save',        '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('netgear', 'snmp.write.snmp_self_config',   '{"supported": false, "note": "structurally impossible - configuring SNMP via SNMP is circular"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('netgear', 'cli.candidate_config',    '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('netgear', 'cli.enable_required',     '{"value": true, "note": "assumed by convention from the IOS-adjacent shape, Medium confidence per cli-syntax-matrix.md, not independently re-confirmed"}', 'assumed', 'comparison/cli-syntax-matrix.md'),
  ('netgear', 'cli.negation_keyword',    '{"value": "no", "note": "assumed by convention, same tier as enable_required"}', 'assumed', 'comparison/cli-syntax-matrix.md'),
  ('netgear', 'cli.paging_disable_cmd',  '{"value": null, "note": "not independently confirmed for Netgear"}', 'unknown', 'comparison/cli-syntax-matrix.md'),
  ('netgear', 'cli.save_persist_cmd',    '{"kind": "persist", "commands": ["copy system:running-config nvram:startup-config"], "note": "the one fully confirmed command for this vendor"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('netgear', 'cli.interface_naming_pattern', '{"pattern": "<unit>/<slot>/<port>", "example": "1/0/1"}', 'confirmed', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;

-- ── Zyxel (standalone-managed line — NOT GS1900) ─────────────────────────────
INSERT INTO vendor_capability_defaults (vendor_profile_id, capability_key, capability_value, confidence, source) VALUES
  ('zyxel', 'snmp.write.port_admin_status', '{"supported": false, "note": "unresolved for both Zyxel product tiers — every cell in the appendix comparison table is unconfirmed"}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('zyxel', 'snmp.write.port_description',  '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('zyxel', 'snmp.write.vlan_pvid',          '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('zyxel', 'snmp.write.vlan_trunk_allowed', '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('zyxel', 'snmp.write.stp_edge_port',      '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('zyxel', 'snmp.write.lacp_membership',    '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('zyxel', 'snmp.write.port_security',      '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('zyxel', 'snmp.write.config_save',        '{"supported": false}', 'unknown', 'comparison/snmp-write-support-matrix.md'),
  ('zyxel', 'snmp.write.snmp_self_config',   '{"supported": false, "note": "structurally impossible - configuring SNMP via SNMP is circular"}', 'confirmed', 'comparison/snmp-write-support-matrix.md'),
  ('zyxel', 'cli.candidate_config',    '{"value": false}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('zyxel', 'cli.enable_required',     '{"value": false, "note": "no separate privileged step documented; configure reached directly"}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('zyxel', 'cli.negation_keyword',    '{"value": null, "note": "not independently confirmed this session"}', 'unknown', 'comparison/cli-syntax-matrix.md'),
  ('zyxel', 'cli.paging_disable_cmd',  '{"value": null, "note": "not independently confirmed this session"}', 'unknown', 'comparison/cli-syntax-matrix.md'),
  ('zyxel', 'cli.save_persist_cmd',    '{"kind": "persist", "commands": ["write memory"]}', 'confirmed', 'comparison/cli-syntax-matrix.md'),
  ('zyxel', 'cli.interface_naming_pattern', '{"pattern": "unconfirmed", "note": "interface naming convention not independently confirmed this session — GS1900 (no config-write CLI at all) is a separate, unimplemented product tier"}', 'unknown', 'comparison/cli-syntax-matrix.md')
ON CONFLICT (vendor_profile_id, capability_key) DO NOTHING;
