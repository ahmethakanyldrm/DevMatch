-- Add gender and preferred_gender columns to developer_profiles
ALTER TABLE developer_profiles ADD COLUMN IF NOT EXISTS gender VARCHAR(20) NOT NULL DEFAULT 'MALE';
ALTER TABLE developer_profiles ADD COLUMN IF NOT EXISTS preferred_gender VARCHAR(20) NOT NULL DEFAULT 'EVERYONE';
