/*
=========================================
Create Data Base and Schemas
=========================================
Script Purpose:

  This script creates a new database named "DataWarehouse" after checking if it already exists.
  If the database exists, it's dropped and recreated. Additionally, the script sets up three
  schemas within the database: "bronze", "silver" & "gold".

WARNING:

  Running this script will drop the entire "DataWarehouse" database if it exists.
  All data in the database will be permanently deleted. Proceed with caution and ensure proper
  backups before running the script.
*/



-- Drop database if it exists
DROP DATABASE IF EXISTS datawarehouse;

-- Create a fresh data warehouse;
CREATE DATABASE datawarehouse;

\c datawarehouse

-- Create schemas (bronze, silver, gold)
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
