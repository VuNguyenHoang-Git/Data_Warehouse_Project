/*
 =================================================================================
 Stored Procedure: Load Silver Layer (Bronze -> Silver)
 =================================================================================
 Purpose:
    This stored procedure transforms and loads data from the 'bronze' schema
    into the cleaned and standardized 'silver' schema of the data warehouse.
    It performs the following actions:
    - Truncates all relevant Silver tables before each load.
    - Cleans, formats, and standardizes raw data from the Bronze Layer.
    - Handles nulls, invalid formats, and basic data inconsistencies.

 Notes:
    - No parameters are required.
    - No values are returned.
    - Table structures and mappings must remain consistent with the SELECT logic.

 Usage:
    CALL silver.load_silver();
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
    LANGUAGE plpgsql
AS
$$
BEGIN

    /* ------------------------------------------------
        Step 1: Truncate all Silver tables
        (Ensures no duplicate or outdated records remain)
    -------------------------------------------------- */
    TRUNCATE TABLE
        silver.crm_cust_info,
        silver.crm_prd_info,
        silver.crm_sales_details,
        silver.erp_cust_az12,
        silver.erp_loc_a101,
        silver.erp_px_cat_g1v2
        CASCADE;


    /* ---------------------------------------------
       Step 2: Load CRM Customer Information (Cleaned)
    ---------------------------------------------- */
    INSERT INTO silver.crm_cust_info (cst_id,
                                      cst_key,
                                      cst_firstname,
                                      cst_lastname,
                                      cst_marital_status,
                                      cst_gndr,
                                      cst_create_date)

    -- Assigns ranking to each cst_id group, newest entry first
    SELECT cst_id              AS customer_id,
           cst_key             AS customer_key,
           TRIM(cst_firstname) AS first_name,
           TRIM(cst_lastname)  AS last_name,

           CASE
               WHEN upper(TRIM(cst_marital_status)) = 'S' THEN 'Single'
               WHEN upper(TRIM(cst_marital_status)) = 'M' THEN 'Married'
               WHEN TRIM(cst_marital_status) IS NULL OR TRIM(cst_marital_status) = '' THEN 'n/a'
               ELSE 'n/a'
               END             AS marital_status,

           CASE
               WHEN upper(TRIM(cst_gndr)) = 'F' THEN 'Female'
               WHEN upper(TRIM(cst_gndr)) = 'M' THEN 'Male'
               WHEN TRIM(cst_gndr) IS NULL OR TRIM(cst_gndr) = '' THEN 'n/a'
               ELSE 'n/a'
               END             AS gender,

           cst_create_date     AS create_date

    FROM (SELECT *,
                 ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
          FROM bronze.crm_cust_info) AS cleaned_data
    WHERE flag_last = 1
    ;


    /* ---------------------------------------------
       Step 3: Load CRM Product Information (Cleaned)
    ---------------------------------------------- */
    INSERT INTO silver.crm_prd_info(prd_id,
                                    cat_id,
                                    prd_key,
                                    prd_nm,
                                    prd_cost,
                                    prd_line,
                                    prd_start_dt,
                                    prd_end_dt)
    SELECT prd_id,
           replace(substr(prd_key, 1, 5), '-', '_')                                               AS cat_id,
           substr(prd_key, 7)                                                                     AS prd_key,
           prd_nm,
           COALESCE(prd_cost, 0)                                                                  AS prd_cost,
           CASE
               WHEN upper(trim(prd_line)) = 'M' THEN 'Mountain'
               WHEN upper(trim(prd_line)) = 'R' THEN 'Road'
               WHEN upper(trim(prd_line)) = 'S' THEN 'Other Sales'
               WHEN upper(trim(prd_line)) = 'T' THEN 'Touring'
               ELSE 'n/a'
               END                                                                                AS prd_line,
           CAST(prd_start_dt AS DATE)                                                             AS prd_start_dt,
           CAST(lead(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
    FROM bronze.crm_prd_info;


    /* ---------------------------------------------
       Step 4: Load CRM Sales Details (Validated)
    ---------------------------------------------- */
    INSERT INTO silver.crm_sales_details(sls_ord_num,
                                         sls_prd_key,
                                         sls_cust_id,
                                         sls_order_dt,
                                         sls_ship_dt,
                                         sls_due_dt,
                                         sls_sales,
                                         sls_quantity,
                                         sls_price)

    SELECT sls_ord_num,
           sls_prd_key,
           sls_cust_id,

           CASE
               WHEN sls_order_dt IS NULL
                   OR sls_order_dt = 0
                   OR length(sls_order_dt::text) != 8
                   THEN NULL
               ELSE to_date(sls_order_dt::text, 'YYYYMMDD')
               END AS sls_ship_dt,

           CASE
               WHEN sls_ship_dt IS NULL
                   OR sls_ship_dt = 0
                   OR length(sls_ship_dt::text) != 8
                   THEN NULL
               ELSE to_date(sls_ship_dt::text, 'YYYYMMDD')
               END AS sls_ship_dt,

           CASE
               WHEN sls_due_dt IS NULL
                   OR sls_due_dt = 0
                   OR length(sls_due_dt::text) != 8
                   THEN NULL
               ELSE to_date(sls_due_dt::text, 'YYYYMMDD')
               END AS sls_due_dt,

           CASE
               WHEN sls_sales IS NULL
                   OR sls_sales <= 0
                   OR sls_sales != sls_quantity * abs(sls_price)
                   THEN sls_quantity * abs(sls_price)
               ELSE sls_sales
               END AS sls_sales,

           sls_quantity,

           CASE
               WHEN sls_price IS NULL
                   OR sls_price <= 0
                   THEN sls_sales / NULLIF(sls_quantity, 0)
               ELSE sls_price
               END AS sls_price

    FROM bronze.crm_sales_details;


    /* ---------------------------------------------
       Step 5: Load ERP Customer Data (Cleaned)
    ---------------------------------------------- */
    INSERT INTO silver.erp_cust_az12(cid,
                                     bdate,
                                     gen)

    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN substring(cid, 4)
            ELSE cid
        END as cid,

        CASE
            WHEN bdate > CURRENT_DATE
            THEN NULL
            ELSE bdate
        END AS bdate,

        CASE
            WHEN upper(TRIM(gen)) IN ('F', 'FEMALE')
            THEN 'Female'
            WHEN upper(TRIM(gen)) IN ('M', 'MALE')
            THEN 'Male'
            ELSE 'n/a'
        END AS gen

    FROM bronze.erp_cust_az12;


    /* ---------------------------------------------
       Step 6: Load ERP Location Data (Standardized)
    ---------------------------------------------- */
    INSERT INTO silver.erp_loc_a101(cid,
                                    cntry)

    SELECT
        replace(cid, '-', '') AS cid,

        CASE
            WHEN TRIM(cntry) = 'DE'
            THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA')
            THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL
            THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry

    FROM bronze.erp_loc_a101;


    /* ---------------------------------------------
       Step 7: Load ERP Product Categories (As-Is)
    ---------------------------------------------- */
    INSERT INTO silver.erp_px_cat_g1v2(id,
                                       cat,
                                       subcat,
                                       maintenance)

    SELECT id,
           cat,
           subcat,
           maintenance
    FROM bronze.erp_px_cat_g1v2;

END;
$$;