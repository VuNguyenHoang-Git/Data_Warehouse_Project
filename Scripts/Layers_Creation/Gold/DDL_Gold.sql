/*
 =============================================
 DDL Script: Create Gold Views
 =============================================

 Script Purpose:

    This script defines analytical views in the "gold" schema,
    which represent the business-facing data layer of the
    data warehouse.

    It drops existing views (if present) and recreates them
    using cleaned and transformed data from the "silver" layer.

    These views are optimized for reporting, visualization,
    and downstream analytical use cases by providing
    well-structured dimension and fact tables.

 Notes:

    - Views do not store data physically but act as virtual tables.
    - The surrogate keys (e.g., customer_key, product_key) are
      generated via ROW_NUMBER() to support dimensional modeling.
    - Foreign key relationships to dimension tables are maintained
      in the fact table (fact_sales).
    - Business logic such as default values, fallback rules,
      and filtering (e.g., current products only) are embedded.

 Usage:

    Run this script once the silver layer has been successfully
    populated. The views can be queried directly for analytics
    and reporting.
 =============================================
*/



/* ================================================================================
   View: gold.dim_customers
================================================================================ */
DROP TABLE IF EXISTS gold.dim_customers;
CREATE VIEW gold.dim_customers AS
SELECT row_number() OVER (ORDER BY cst_id) AS customer_key,    -- Surrogate key
       ci.cst_id                           AS customer_id,     -- CRM customer ID
       ci.cst_key                          AS customer_number, -- Customer reference key
       ci.cst_firstname                    AS first_name,
       ci.cst_lastname                     AS last_name,
       la.cntry                            AS country,         -- Country from ERP location data
       ci.cst_marital_status               AS marital_status,

       CASE
           WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is master for gender
           ELSE COALESCE(ca.gen, 'n/a')
           END                             AS gender,

       ca.bdate                            AS birthdate,       -- Date of birth from ERP
       ci.cst_create_date                  AS create_date      -- Creation date from CRM
FROM silver.crm_cust_info ci
         LEFT JOIN silver.erp_cust_az12 ca
                   ON ci.cst_key = ca.cid
         LEFT JOIN silver.erp_loc_a101 la
                   ON ci.cst_key = la.cid;


/* ================================================================================
   View: gold.dim_products
================================================================================ */
DROP TABLE IF EXISTS gold.dim_products;
CREATE VIEW gold.dim_products AS
SELECT row_number() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate key
       pn.prd_id                                                AS product_id,
       pn.prd_key                                               AS product_number,
       pn.prd_nm                                                AS product_name,
       pn.cat_id                                                AS category_id,
       pc.cat                                                   AS category,    -- High-level category (e.g., Bikes)
       pc.subcat                                                AS subcategory, -- Subcategory (e.g., Road Bikes)
       pc.maintenance,
       pn.prd_cost                                              AS product_cost,
       pn.prd_line                                              AS product_line,
       pn.prd_start_dt                                          AS start_date   -- Valid from
FROM silver.crm_prd_info pn
         LEFT JOIN silver.erp_px_cat_g1v2 pc
                   ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL; -- Exclude historical products


/* ================================================================================
   View: gold.fact_sales
================================================================================ */
DROP TABLE IF EXISTS gold.fact_sales;
CREATE VIEW gold.fact_sales AS
SELECT sd.sls_ord_num  AS order_number, -- Unique order reference
       pr.product_key,                  -- FK to dim_products
       cu.customer_key,                 -- FK to dim_customers
       sd.sls_order_dt AS order_date,
       sd.sls_ship_dt  AS shipping_date,
       sd.sls_due_dt   AS due_date,
       sd.sls_sales    AS sales_amount, -- Total sales value
       sd.sls_quantity AS quantity,     -- Units sold
       sd.sls_price    AS price         -- Price per unit
FROM silver.crm_sales_details sd
         LEFT JOIN gold.dim_products pr
                   ON sd.sls_prd_key = pr.product_number
         LEFT JOIN gold.dim_customers cu
                   ON sd.sls_cust_id = cu.customer_id;
