-- ============================================
-- ANALYTICAL / GOLD LAYER
-- ============================================

CREATE SCHEMA IF NOT EXISTS analytics;

-- ============================================
-- 1. ORDER-LEVEL FACT TABLE
-- One row = one order
-- ============================================

CREATE OR REPLACE TABLE analytics.fact_orders AS

WITH item_summary AS (
    SELECT
        order_id,
        SUM(price) AS product_revenue,
        SUM(freight_value) AS freight_revenue,
        COUNT(*) AS item_count
    FROM staging.order_items
    GROUP BY order_id
),

payment_summary AS (
    SELECT
        order_id,
        SUM(payment_value) AS payment_value,
        COUNT(*) AS payment_count
    FROM staging.payments
    GROUP BY order_id
),

review_summary AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score,
        COUNT(*) AS review_count
    FROM staging.reviews
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,

    o.order_status,

    CAST(o.order_purchase_timestamp AS DATE) AS order_date,
    o.order_purchase_timestamp,

    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    DATE_DIFF(
        'day',
        CAST(o.order_purchase_timestamp AS DATE),
        CAST(o.order_delivered_customer_date AS DATE)
    ) AS delivery_days,

   
    DATE_DIFF(
        'day',
        CAST(o.order_estimated_delivery_date AS DATE),
        CAST(o.order_delivered_customer_date AS DATE)
    ) AS delivery_vs_estimated_days,


    COALESCE(i.product_revenue, 0) AS product_revenue,
    COALESCE(i.freight_revenue, 0) AS freight_revenue,

    COALESCE(i.product_revenue, 0)
        + COALESCE(i.freight_revenue, 0) AS order_revenue,

    COALESCE(i.item_count, 0) AS item_count,

    COALESCE(p.payment_value, 0) AS payment_value,
    COALESCE(p.payment_count, 0) AS payment_count,

    COALESCE(r.avg_review_score, 0) AS avg_review_score,
    COALESCE(r.review_count, 0) AS review_count,

    c.customer_city,
    c.customer_state

FROM staging.orders o

LEFT JOIN staging.customers c
    ON o.customer_id = c.customer_id

LEFT JOIN item_summary i
    ON o.order_id = i.order_id

LEFT JOIN payment_summary p
    ON o.order_id = p.order_id

LEFT JOIN review_summary r
    ON o.order_id = r.order_id;

-- ============================================
-- 2. CUSTOMER-LEVEL MART
-- One row = one unique customer
-- ============================================

CREATE OR REPLACE TABLE analytics.dim_customers AS

SELECT
    customer_unique_id,

    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(order_revenue) AS total_revenue,

    AVG(order_revenue) AS average_order_value,

    DATE_DIFF(
        'day',
        MIN(order_date),
        MAX(order_date)
    ) AS customer_lifetime_days,

    CASE
        WHEN COUNT(DISTINCT order_id) > 1
        THEN 'Repeat'
        ELSE 'One-time'
    END AS customer_type,

    ANY_VALUE(customer_city) AS customer_city,
    ANY_VALUE(customer_state) AS customer_state

FROM analytics.fact_orders

GROUP BY customer_unique_id;

-- ============================================
-- 3. RFM CUSTOMER ANALYSIS
-- One row = one unique customer
-- ============================================

CREATE OR REPLACE TABLE analytics.customer_rfm AS

WITH customer_metrics AS (
    SELECT
        customer_unique_id,

        MAX(order_date) AS last_order_date,

        COUNT(DISTINCT order_id) AS frequency,

        SUM(order_revenue) AS monetary

    FROM analytics.fact_orders

    WHERE order_revenue > 0

    GROUP BY customer_unique_id
),

reference_date AS (
    SELECT MAX(order_date) AS max_order_date
    FROM analytics.fact_orders
)

SELECT
    c.customer_unique_id,

    DATE_DIFF(
        'day',
        c.last_order_date,
        r.max_order_date
    ) AS recency,

    c.frequency,

    c.monetary

FROM customer_metrics c
CROSS JOIN reference_date r;

-- ============================================
-- 4. CUSTOMER SEGMENTATION
-- ============================================

CREATE OR REPLACE TABLE analytics.customer_rfm_segments AS

SELECT
    *,

    CASE
        WHEN recency <= 180
             AND frequency >= 2
             AND monetary >= 250
            THEN 'Champions'

        WHEN recency <= 180
             AND frequency >= 3
            THEN 'Loyal Customers'

        WHEN recency <= 180
             AND frequency = 2
            THEN 'Potential Loyalists'

        WHEN recency <= 180
             AND frequency = 1
            THEN 'Recent Customers'

        WHEN recency > 180
             AND frequency >= 2
            THEN 'At Risk'

        ELSE 'Hibernating'
    END AS customer_segment

FROM analytics.customer_rfm;

-- ============================================
-- 5. PRODUCT CATEGORY ANALYTICS
-- ============================================

CREATE OR REPLACE TABLE analytics.product_category_summary AS

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,

    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS total_items_sold,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(AVG(oi.price), 2) AS avg_item_price

FROM staging.order_items AS oi

LEFT JOIN staging.products AS p
    ON oi.product_id = p.product_id

LEFT JOIN staging.category_translation AS ct
    ON p.product_category_name = ct.product_category_name

GROUP BY 1;
