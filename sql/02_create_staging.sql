-- ============================================
-- STAGING LAYER
-- ============================================

CREATE SCHEMA IF NOT EXISTS staging;

-- Customers
CREATE OR REPLACE TABLE staging.customers AS
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    LOWER(TRIM(customer_city)) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM raw.customers;

-- Orders
CREATE OR REPLACE TABLE staging.orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    CAST(order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp,
    CAST(order_approved_at AS TIMESTAMP) AS order_approved_at,
    CAST(order_delivered_carrier_date AS TIMESTAMP) AS order_delivered_carrier_date,
    CAST(order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_date,
    CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_date
FROM raw.orders;

-- Order Items
CREATE OR REPLACE TABLE staging.order_items AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date,
    price,
    freight_value
FROM raw.order_items;

-- Payments
CREATE OR REPLACE TABLE staging.payments AS
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM raw.payments;

-- Reviews
CREATE OR REPLACE TABLE staging.reviews AS
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    CAST(review_creation_date AS TIMESTAMP) AS review_creation_date,
    CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp
FROM raw.reviews;

-- Products
CREATE OR REPLACE TABLE staging.products AS
SELECT
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM raw.products;

-- Sellers
CREATE OR REPLACE TABLE staging.sellers AS
SELECT
    seller_id,
    seller_zip_code_prefix,
    LOWER(TRIM(seller_city)) AS seller_city,
    UPPER(TRIM(seller_state)) AS seller_state
FROM raw.sellers;

-- Category Translation
CREATE OR REPLACE TABLE staging.category_translation AS
SELECT
    product_category_name,
    product_category_name_english
FROM raw.category_translation;

-- Geolocation
CREATE OR REPLACE TABLE staging.geolocation AS
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    LOWER(TRIM(geolocation_city)) AS geolocation_city,
    UPPER(TRIM(geolocation_state)) AS geolocation_state
FROM raw.geolocation;