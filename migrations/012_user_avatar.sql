-- Add avatar_url column to users for profile picture storage (base64 data URL)
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url TEXT;
