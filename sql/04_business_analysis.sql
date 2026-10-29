
-- ============================================
-- 1. MONTHLY REVENUE AND MONTH-OVER-MONTH GROWTH
-- ============================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS order_month,
        SUM(order_revenue) AS total_revenue
    FROM analytics.fact_orders
    WHERE order_date IS NOT NULL
      AND order_revenue > 0
    GROUP BY 1
),

calendar AS (
    SELECT
        month_start::DATE AS order_month
    FROM generate_series(
        DATE '2016-09-01',
        DATE '2018-09-01',
        INTERVAL '1 month'
    ) AS t(month_start)
),

complete_months AS (
    SELECT
        c.order_month,
        COALESCE(m.total_revenue, 0) AS total_revenue
    FROM calendar c
    LEFT JOIN monthly_revenue m
        ON c.order_month = m.order_month
),

revenue_with_previous AS (
    SELECT
        order_month,
        total_revenue,
        LAG(total_revenue) OVER (
            ORDER BY order_month
        ) AS previous_month_revenue
    FROM complete_months
)

SELECT
    order_month,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(previous_month_revenue, 2)
        AS previous_month_revenue,
    ROUND(
        100.0 * (
            total_revenue - previous_month_revenue
        ) / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_pct
FROM revenue_with_previous
ORDER BY order_month;

-- ============================================
-- 2. CUSTOMER SEGMENT PERFORMANCE
-- ============================================

SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(recency), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_orders,
    ROUND(AVG(monetary), 2) AS avg_customer_spending,
    ROUND(SUM(monetary), 2) AS segment_revenue
FROM analytics.customer_rfm_segments
GROUP BY customer_segment
ORDER BY segment_revenue DESC;

-- ============================================
-- 3. PRODUCT CATEGORY PERFORMANCE
-- ============================================

SELECT
    product_category,
    SUM(total_orders) AS total_orders,
    SUM(total_items_sold) AS total_items_sold,
    ROUND(SUM(product_revenue), 2) AS product_revenue,
    ROUND(
        100.0 * SUM(product_revenue)
        / NULLIF(SUM(SUM(product_revenue)) OVER (), 0),
        2
    ) AS revenue_share_pct,
    ROUND(AVG(avg_item_price), 2) AS avg_item_price
FROM analytics.product_category_summary
GROUP BY product_category
ORDER BY product_revenue DESC
LIMIT 15;

-- ============================================
-- 4. MONTHLY REVENUE MART
-- ============================================

CREATE OR REPLACE TABLE analytics.monthly_revenue_summary AS

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS order_month,
        COUNT(*) AS total_orders,
        SUM(order_revenue) AS total_revenue
    FROM analytics.fact_orders
    WHERE order_date IS NOT NULL
      AND order_revenue > 0
    GROUP BY 1
),

calendar AS (
    SELECT
        month_start::DATE AS order_month
    FROM generate_series(
        DATE '2016-09-01',
        DATE '2018-09-01',
        INTERVAL '1 month'
    ) AS t(month_start)
),

complete_months AS (
    SELECT
        c.order_month,
        COALESCE(m.total_orders, 0) AS total_orders,
        COALESCE(m.total_revenue, 0) AS total_revenue
    FROM calendar c
    LEFT JOIN monthly_revenue m
        ON c.order_month = m.order_month
),

growth AS (
    SELECT
        *,
        LAG(total_revenue) OVER (
            ORDER BY order_month
        ) AS previous_month_revenue
    FROM complete_months
)

SELECT
    order_month,
    total_orders,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(
        total_revenue / NULLIF(total_orders, 0),
        2
    ) AS avg_order_value,
    ROUND(previous_month_revenue, 2)
        AS previous_month_revenue,
    ROUND(
        100.0 * (total_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_pct
FROM growth;

-- ============================================
-- 5. CUSTOMER SEGMENT SUMMARY MART
-- ============================================

CREATE OR REPLACE TABLE analytics.customer_segment_summary AS

SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(recency), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_orders_per_customer,
    ROUND(AVG(monetary), 2) AS avg_customer_spending,
    ROUND(SUM(monetary), 2) AS segment_revenue

FROM analytics.customer_rfm_segments

GROUP BY customer_segment;

-- ============================================
-- 6. PRODUCT CATEGORY SUMMARY MART
-- ============================================

CREATE OR REPLACE TABLE analytics.product_category_summary_mart AS

WITH category_totals AS (
    SELECT
        product_category,
        SUM(total_orders) AS total_orders,
        SUM(total_items_sold) AS total_items_sold,
        SUM(product_revenue) AS product_revenue,
        SUM(freight_revenue) AS freight_revenue,
        SUM(unique_products) AS category_product_count,
        AVG(avg_item_price) AS avg_item_price
    FROM analytics.product_category_summary
    GROUP BY product_category
)

SELECT
    product_category,
    total_orders,
    total_items_sold,
    category_product_count,
    ROUND(product_revenue, 2) AS product_revenue,
    ROUND(freight_revenue, 2) AS freight_revenue,
    ROUND(
        100.0 * product_revenue
        / NULLIF(SUM(product_revenue) OVER (), 0),
        2
    ) AS revenue_share_pct,
    ROUND(avg_item_price, 2) AS avg_item_price
FROM category_totals
ORDER BY product_revenue DESC;
