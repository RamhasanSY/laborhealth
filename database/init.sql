-- Initialize database roles and extensions for lab_results
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Ensure application user exists with least privileges
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'labuser') THEN
    CREATE ROLE labuser WITH LOGIN PASSWORD current_setting('app.db_password', true);
  END IF;
END$$;

-- Create database if not exists (handled by container env typically)
-- CREATE DATABASE lab_results OWNER labuser;

-- Grant privileges
GRANT CONNECT ON DATABASE lab_results TO labuser;
GRANT USAGE ON SCHEMA public TO labuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO labuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO labuser;

-- Security hardening
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON DATABASE lab_results FROM PUBLIC;

