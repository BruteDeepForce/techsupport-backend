-- Create pgvector extension if not exists. This runs only on initial DB init
-- when the container's data directory is empty.
CREATE EXTENSION IF NOT EXISTS vector;

-- Optional: ensure extension is available in the current database privileges
-- (adjust as needed for your security model).
GRANT USAGE ON SCHEMA public TO PUBLIC;
