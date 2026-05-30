-- Add password_hash and github_username columns to developer_profiles
ALTER TABLE developer_profiles ADD COLUMN password_hash VARCHAR(100);
ALTER TABLE developer_profiles ADD COLUMN github_username VARCHAR(100);
