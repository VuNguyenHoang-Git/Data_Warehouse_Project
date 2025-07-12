-- Drop database if it exists
DROP DATABASE IF EXISTS datawarehouse;

-- Create a fresh data warehouse;
CREATE DATABASE datawarehouse;

\c datawarehouse

-- Create schemas (bronze, silver, gold)
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;