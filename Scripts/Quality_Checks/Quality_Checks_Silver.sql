/* ============================================================================
   Data Quality Checks for Silver Layer Tables
   ----------------------------------------------------------------------------
   This script performs basic data validation and quality assurance checks
   on all Silver Layer tables in the CRM and ERP domains.

   Checks include:
   - Primary key uniqueness and presence
   - Trimming and whitespace removal
   - Value standardization (e.g. gender, marital status)
   - Date consistency and validity
   - Basic business rule checks (e.g. sales = price * quantity)

   Expected Outcome:
   - All queries should return either zero rows or standardized values
   - Any deviations indicate potential data quality issues
============================================================================ */


-- ====================================================================
-- Quality Checks: silver.crm_cust_info
-- ====================================================================
-- Check 1: NULLs or Duplicate cst_id (should not exist)
SELECT cst_id,
       COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;

-- Check 2: Unwanted whitespace in cst_key
SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Check 3: Expected values in marital_status
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;


-- ====================================================================
-- Quality Checks: silver.crm_prd_info
-- ====================================================================
-- Check 1: NULLs or Duplicate prd_id (should not exist)
SELECT prd_id,
       COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;

-- Check 2: Unwanted whitespace in product name
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check 3: prd_cost must not be NULL or negative
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;

-- Check 4: Expected values in prd_line
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check 5: Date logic (start date must be before end date)
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ====================================================================
-- Quality Checks: silver.crm_sales_details
-- ====================================================================
-- Check 1: Invalid raw date values in original bronze data
SELECT NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR length(sls_due_dt::text) != 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;

-- Check 2: Logical date order (order date must be before ship/due date)
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- Check 3: Sales amount consistency (sales = quantity * price)
SELECT DISTINCT sls_sales,
                sls_quantity,
                sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ====================================================================
-- Quality Checks: silver.erp_cust_az12
-- ====================================================================
-- Check 1: Out-of-range birthdates
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > current_date;

-- Check 2: Expected values in gender field
SELECT DISTINCT gen
FROM silver.erp_cust_az12;


-- ====================================================================
-- Quality Checks: silver.erp_loc_a101
-- ====================================================================
-- Check 1: Country value consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ====================================================================
-- Quality Checks: silver.erp_px_cat_g1v2
-- ====================================================================
-- Check 1: Unwanted whitespace in category fields
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Check 2: Expected values in maintenance column
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;