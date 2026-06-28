-- Add admin_status to interfaces to distinguish administratively-disabled
-- ports from ports that are down due to a fault.
-- Values: 'up' (enabled) | 'down' (admin-disabled, e.g. shutdown/no shutdown)
ALTER TABLE interfaces ADD COLUMN admin_status TEXT NOT NULL DEFAULT 'up';

-- Ports described as unused or reserved are intentionally shut down by an
-- administrator, not failing — mark them admin-down.
UPDATE interfaces SET admin_status = 'down'
WHERE description IN ('unused', 'reserved');
