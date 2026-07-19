/*
===============================================================================
Script: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This script performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' tables from the 'bronze' tables.
    Actions Performed:
       - Truncates Silver tables.
       - Inserts transformed and cleansed data from Bronze into Silver tables.
       - Logs the load duration of each table and the total batch duration.

Tables Loaded:
    - silver.crm_cust_info
    - silver.crm_prd_info
    - silver.crm_sales_details
    - silver.erp_cust_az12
    - silver.erp_loc_a101
    - silver.erp_px_cat_g1v2

Parameters:
    None.
      This script does not accept any parameters or return any values.
===============================================================================
*/

SET @batch_start_time = NOW(6);

SET @t1 = NOW(6);
-- Truncating Table: silver.crm_cust_info
TRUNCATE TABLE silver.crm_cust_info;

-- Loading silver.crm_cust_info
INSERT INTO silver.crm_cust_info (
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname),
TRIM(cst_lastname),
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		 ELSE 'n/a'
END	cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		 ELSE 'n/a'
END	cst_gndr,
cst_create_date
FROM (
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL) AS t
WHERE flag_last = 1;
SET @t2 = NOW(6);
SELECT CONCAT('>> Load Duration of crm_cust_info: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @t1, @t2) / 1000000, 2), ' seconds') AS log;


SET @t1 = NOW(6);
-- Truncating Table: silver.crm_prd_info
TRUNCATE TABLE silver.crm_prd_info;

-- Loading silver.crm_prd_info
INSERT INTO silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT
prd_id,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
prd_nm,
IFNULL(prd_cost, 0) AS prd_cost,
CASE UPPER(TRIM(prd_line))
		 WHEN 'M' THEN 'Mountain'
		 WHEN 'R' THEN 'Road'
		 WHEN 'S' THEN 'Other Sales'
		 WHEN 'T' THEN 'Touring'
		 ELSE 'n/a'
END prd_line,
CAST(prd_start_dt AS DATE) AS prd_start_dt,
CAST(LEAD (prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL 1 DAY AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info;
SET @t2 = NOW(6);
SELECT CONCAT('>> Load Duration of crm_prd_info: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @t1, @t2) / 1000000, 2), ' seconds') AS log;


SET @t1 = NOW(6);
-- Truncating Table: silver.crm_sales_details
TRUNCATE TABLE silver.crm_sales_details;

-- Loading crm_sales_details
INSERT INTO silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
)
SELECT
sls_prd_key,
sls_ord_num,
sls_cust_id,
CASE WHEN sls_order_dt = 0 or LENGTH(sls_order_dt) != 8 THEN NULL
		 ELSE	STR_TO_DATE(sls_order_dt, '%Y%m%d')
END AS sls_order_dt,
CASE WHEN sls_ship_dt = 0 or LENGTH(sls_ship_dt) != 8 THEN NULL
		 ELSE	STR_TO_DATE(sls_ship_dt, '%Y%m%d')
END AS sls_ship_dt,
CASE WHEN sls_due_dt = 0 or LENGTH(sls_due_dt) != 8 THEN NULL
		 ELSE	STR_TO_DATE(sls_due_dt, '%Y%m%d')
END AS sls_due_dt,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		 THEN sls_quantity * ABS(sls_price)
		 ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price <= 0
		 THEN sls_sales / NULLIF(sls_quantity, 0)
		 ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details;
SET @t2 = NOW(6);
SELECT CONCAT('>> Load Duration of crm_sales_details: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @t1, @t2) / 1000000, 2), ' seconds') AS log;


SET @t1 = NOW(6);
-- Truncating Table: silver.erp_cust_az12
TRUNCATE TABLE silver.erp_cust_az12;
-- Loading erp_cust_az12
INSERT INTO silver.erp_cust_az12(
	cid,
	bdate,
	gen
)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		 ELSE cid
END AS cid,
CASE WHEN bdate > now() THEN NULL
		 ELSE bdate
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		 ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12;
SET @t2 = NOW(6);
SELECT CONCAT('>> Load Duration of erp_cust_az12: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @t1, @t2) / 1000000, 2), ' seconds') AS log;


SET @t1 = NOW(6);
-- Truncating Table: silver.erp_loc_a101
TRUNCATE TABLE silver.erp_loc_a101;
-- Loading erp_loc_a101
INSERT INTO silver.erp_loc_a101(cid, cntry)
SELECT
REPLACE(cid, '-', '') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101;
SET @t2 = NOW(6);
SELECT CONCAT('>> Load Duration of erp_loc_a101: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @t1, @t2) / 1000000, 2), ' seconds') AS log;


SET @t1 = NOW(6);
-- Truncating Table: silver.erp_px_cat_g1v2
TRUNCATE TABLE silver.erp_px_cat_g1v2;
-- Loading erp_px_cat_g1v2
INSERT INTO silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;


SET @batch_end_time = NOW(6);
SELECT CONCAT('   - Total Load Duration: ', ROUND(TIMESTAMPDIFF(MICROSECOND, @batch_start_time, @batch_end_time) / 1000000, 2), ' seconds') AS log;
