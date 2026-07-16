/*
===============================================================================
Script: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This script loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses `LOAD DATA LOCAL INFILE` to load data from CSV files into bronze tables.
    - Logs the duration of each table load and the total batch duration.

Note:
    MySQL does not allow LOAD DATA inside stored procedures (Error 1314),
    so this runs as a plain script rather than a CALL-able procedure.
    Run this with "Execute SQL Script" (not "Execute Statement").
===============================================================================
*/

SET @batch_start_time = NOW(6);

-- crm_cust_info
SET @t1 = NOW(6);
TRUNCATE TABLE bronze.crm_cust_info;
LOAD DATA LOCAL INFILE 'C:/Users/USER/PycharmProjects/sql-data-warehouse/datasets/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, @cst_create_date)
SET
    cst_id = NULLIF(@cst_id, ''),
    cst_create_date = NULLIF(@cst_create_date, '');
SET @t2 = NOW(6);
SELECT CONCAT('>> Load Duration of cust_info: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @t1, @t2) / 1000000, 2), ' seconds') AS log;


-- crm_prd_info
SET @t1 = NOW(6);
TRUNCATE TABLE bronze.crm_prd_info;
LOAD DATA LOCAL INFILE 'C:/Users/USER/PycharmProjects/sql-data-warehouse/datasets/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @t2 = NOW(6);
SELECT CONCAT('>> Load Duration of prd_info: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @t1, @t2) / 1000000, 2), ' seconds') AS log;


-- crm_sales_details
SET @t1 = NOW(6);
TRUNCATE TABLE bronze.crm_sales_details;
LOAD DATA LOCAL INFILE 'C:/Users/USER/PycharmProjects/sql-data-warehouse/datasets/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @t2 = NOW(6);
SELECT CONCAT('>> Load Duration of sales_details: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @t1, @t2) / 1000000, 2), ' seconds') AS log;

-- erp_loc_a101
SET @t1 = NOW(6);
TRUNCATE TABLE bronze.erp_loc_a101;
LOAD DATA LOCAL INFILE 'C:/Users/USER/PycharmProjects/sql-data-warehouse/datasets/source_erp/loc_a101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @t2 = NOW(6);
SELECT CONCAT('>> Load Duration of loc_a101: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @t1, @t2) / 1000000, 2), ' seconds') AS log;


-- erp_cust_az12
SET @t1 = NOW(6);
TRUNCATE TABLE bronze.erp_cust_az12;
LOAD DATA LOCAL INFILE 'C:/Users/USER/PycharmProjects/sql-data-warehouse/datasets/source_erp/cust_az12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @t2 = NOW(6);
SELECT CONCAT('>> Load Duration of cust_az12: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @t1, @t2) / 1000000, 2), ' seconds') AS log;

-- erp_px_cat_g1v2
SET @t1 = NOW(6);
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE 'C:/Users/USER/PycharmProjects/sql-data-warehouse/datasets/source_erp/px_cat_g1v2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @t2 = NOW(6);
SELECT CONCAT('>> Load Duration of px_cat_g1v2: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @t1, @t2) / 1000000, 2), ' seconds') AS log;


SET @batch_end_time = NOW(6);
SELECT CONCAT('   - Total Load Duration: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @batch_start_time, @batch_end_time) / 1000000, 2), ' seconds') AS log;
