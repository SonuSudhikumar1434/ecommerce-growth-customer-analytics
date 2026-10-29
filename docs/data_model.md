# Data Model

## Overview

The Olist dataset contains multiple related tables covering customers,
orders, order items, payments, reviews, products, sellers and
geographic information.

The analytical model will use the order as the central business
transaction and connect related entities through their available keys.

---

## Table Grain

### Customers

One row represents one customer-order relationship identified by
`customer_id`.

`customer_unique_id` represents the underlying unique customer and
will be used for customer-level analysis such as repeat purchases
and RFM segmentation.

### Orders

One row represents one order.

Primary business key:

`order_id`

### Order Items

One row represents one product item within an order.

An order can contain multiple order-item records.

### Payments

One row represents one payment record associated with an order.

An order can contain multiple payment records.

### Reviews

One row represents a review record associated with an order.

The source analysis identified duplicate `review_id` values and
multiple review records for some orders. Therefore, `review_id`
will not be assumed to be a unique primary key without additional
transformation.

### Products

One row represents one product.

Business key:

`product_id`

### Sellers

One row represents one seller.

Business key:

`seller_id`

### Product Category Translation

One row represents one product-category translation.

The table will be used to provide English product category names.

### Geolocation

The source contains multiple geographic records for ZIP-code
prefixes. The table will not be used directly as a one-to-one
dimension until its appropriate grain is established.

---

## Key Relationships

### Customers → Orders

`customers.customer_id`

↓

`orders.customer_id`

Relationship:

One customer record can be associated with orders.

---

### Orders → Order Items

`orders.order_id`

↓

`order_items.order_id`

Relationship:

One order can contain multiple order items.

---

### Orders → Payments

`orders.order_id`

↓

`order_payments.order_id`

Relationship:

One order can have multiple payment records.

---

### Orders → Reviews

`orders.order_id`

↓

`order_reviews.order_id`

Relationship:

One order can have one or more review records in the source data.

---

### Order Items → Products

`order_items.product_id`

↓

`products.product_id`

Relationship:

Many order-item records can reference one product.

---

### Order Items → Sellers

`order_items.seller_id`

↓

`sellers.seller_id`

Relationship:

Many order-item records can reference one seller.

---

## Data Quality Considerations

- Customer IDs match between customers and orders.
- Order IDs match between orders and order items.
- Product IDs match between order items and products.
- Seller IDs match between order items and sellers.
- Payment order IDs match orders.
- Review order IDs match orders.
- Duplicate review IDs exist in the source.
- Multiple payment records can exist for an order.
- Multiple order items can exist for an order.
- Multiple review records can exist for an order.
- Geolocation contains duplicate records and requires separate grain analysis.