/*
 =================================================================================
 Stored Procedure: Load Bronze Layer (Source -> Bronze)
 =================================================================================
 Purpose:
    This stored procedure loads data from external CSV files into the 'bronze' schema.
    It performs the following actions:
    - Truncates all relevant bronze tables before each load.
    - Uses the 'COPY' command to import data from local CSV files.

 Notes:
    - No parameters are required.
    - No values are returned.
    - File paths are currently absolute and may need adjustment for other environments.

 Usage:
    CALL bronze.load_bronze();
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
BEGIN

    -- Empty the table if data already exist
    TRUNCATE TABLE
        bronze.crm_cust_info,
        bronze.crm_prd_info,
        bronze.crm_sales_details,
        bronze.erp_cust_az12,
        bronze.erp_loc_a101,
        bronze.erp_px_cat_g1v2
    CASCADE;

    -- Load data
    COPY bronze.crm_cust_info
    FROM '/Users/vunguyenhoang/DataGripProjects/Data Warehouse Project/Datasets/Source_CRM/cust_info.csv'
    DELIMITER ','
    CSV HEADER;

    COPY bronze.crm_prd_info
    FROM '/Users/vunguyenhoang/DataGripProjects/Data Warehouse Project/Datasets/Source_CRM/prd_info.csv'
    DELIMITER ','
    CSV HEADER;

    COPY bronze.crm_sales_details
    FROM '/Users/vunguyenhoang/DataGripProjects/Data Warehouse Project/Datasets/Source_CRM/sales_details.csv'
    DELIMITER ','
    CSV HEADER ;

    COPY bronze.erp_cust_az12
    FROM '/Users/vunguyenhoang/DataGripProjects/Data Warehouse Project/Datasets/Source_ERP/CUST_AZ12.csv'
    DELIMITER ','
    CSV HEADER ;

    COPY bronze.erp_loc_a101
    FROM '/Users/vunguyenhoang/DataGripProjects/Data Warehouse Project/Datasets/Source_ERP/LOC_A101.csv'
    DELIMITER ','
    CSV HEADER ;

    COPY bronze.erp_px_cat_g1v2
    FROM '/Users/vunguyenhoang/DataGripProjects/Data Warehouse Project/Datasets/Source_ERP/PX_CAT_G1V2.csv'
    DELIMITER  ','
    CSV HEADER ;

END;
$$;