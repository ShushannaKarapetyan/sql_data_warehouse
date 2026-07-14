/*
=============================================================
Create Databases (Bronze, Silver, Gold Layers)
=============================================================
Script Purpose:
    This script creates three databases: 'bronze', 'silver', and 'gold',
    representing the three layers of the data warehouse.
    If any of these databases already exist, they are dropped and recreated.
	
WARNING:
    Running this script will drop the 'bronze', 'silver', and 'gold' databases
    if they exist. All data in these databases will be permanently deleted.
    Proceed with caution and ensure you have proper backups before running this script.
*/

-- Drop and recreate the 'bronze' database
DROP DATABASE IF EXISTS bronze;
CREATE DATABASE bronze;

-- Drop and recreate the 'silver' database
DROP DATABASE IF EXISTS silver;
CREATE DATABASE silver;

-- Drop and recreate the 'gold' database
DROP DATABASE IF EXISTS gold;
CREATE DATABASE gold;
