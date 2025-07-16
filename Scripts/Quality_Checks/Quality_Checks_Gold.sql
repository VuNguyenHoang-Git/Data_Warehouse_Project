/*
===============================================================================
Quality Checks – Gold Layer
===============================================================================

Script Purpose:
    This script performs essential quality checks to validate the integrity,
    consistency, and reliability of the Gold Layer. These checks are designed to:
    - Ensure uniqueness of surrogate keys in dimension tables.
    - Validate referential integrity between fact and dimension tables.
    - Detect disconnected records that may impact analytical accuracy.

Usage Notes:
    - This script is read-only and should not modify any data.
    - Review and resolve any unexpected results before proceeding with analysis.
    - These checks should be rerun after significant data loads or model changes.

===============================================================================
*/

-- ============================================================================
-- Check 1: Uniqueness of surrogate keys in gold.dim_customers
-- Expectation: No rows returned (all customer_key values must be unique)
-- ============================================================================
SELECT customer_key,
       COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- Check 2: Uniqueness of surrogate keys in gold.dim_products
-- Expectation: No rows returned (all product_key values must be unique)
-- ============================================================================
SELECT product_key,
       COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- Check 3: Referential integrity in gold.fact_sales
-- Expectation: No rows returned (every foreign key must have a valid match)
-- ============================================================================
SELECT *
FROM gold.fact_sales f
         LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
         LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;
