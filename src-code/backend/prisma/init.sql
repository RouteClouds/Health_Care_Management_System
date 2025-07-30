-- Health Care Management System Database Initialization
-- This file is used by Docker to initialize the PostgreSQL database

-- Create database if it doesn't exist (handled by Docker environment variables)
-- The database 'healthcare_db' is created automatically by Docker

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON DATABASE healthcare_db TO healthcare_user;

-- Connect to the healthcare database
\c healthcare_db;

-- Grant schema permissions
GRANT ALL ON SCHEMA public TO healthcare_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO healthcare_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO healthcare_user;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- The actual tables will be created by Prisma migrations
-- This file just ensures the database is properly set up for Prisma
