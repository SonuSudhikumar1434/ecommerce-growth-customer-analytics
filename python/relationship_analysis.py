from pathlib import Path
import pandas as pd


# ---------------------------------------------------------
# PROJECT PATH
# ---------------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = PROJECT_ROOT / "data" / "raw" / "olist"


# ---------------------------------------------------------
# LOAD DATA
# ---------------------------------------------------------

customers = pd.read_csv(
    DATA_PATH / "olist_customers_dataset.csv"
)

orders = pd.read_csv(
    DATA_PATH / "olist_orders_dataset.csv"
)

order_items = pd.read_csv(
    DATA_PATH / "olist_order_items_dataset.csv"
)

payments = pd.read_csv(
    DATA_PATH / "olist_order_payments_dataset.csv"
)

reviews = pd.read_csv(
    DATA_PATH / "olist_order_reviews_dataset.csv"
)

products = pd.read_csv(
    DATA_PATH / "olist_products_dataset.csv"
)

sellers = pd.read_csv(
    DATA_PATH / "olist_sellers_dataset.csv"
)


print("=" * 80)
print("E-COMMERCE TABLE RELATIONSHIP ANALYSIS")
print("=" * 80)


# ---------------------------------------------------------
# 1. PRIMARY KEY UNIQUENESS
# ---------------------------------------------------------

print("\n1. PRIMARY KEY UNIQUENESS")
print("=" * 80)


key_checks = {
    "customers.customer_id": customers["customer_id"],
    "customers.customer_unique_id": customers["customer_unique_id"],
    "orders.order_id": orders["order_id"],
    "order_items.order_id": order_items["order_id"],
    "products.product_id": products["product_id"],
    "sellers.seller_id": sellers["seller_id"],
    "reviews.review_id": reviews["review_id"],
}


for key_name, series in key_checks.items():

    total = len(series)
    unique = series.nunique()
    duplicates = total - unique

    print(
        f"{key_name:<40} "
        f"Rows: {total:,} | "
        f"Unique: {unique:,} | "
        f"Duplicate values: {duplicates:,}"
    )


# ---------------------------------------------------------
# 2. FOREIGN KEY MATCHING
# ---------------------------------------------------------

print("\n2. FOREIGN KEY MATCHING")
print("=" * 80)


def check_relationship(
    child_df,
    child_column,
    parent_df,
    parent_column,
    relationship_name
):

    child_values = set(child_df[child_column].dropna().unique())
    parent_values = set(parent_df[parent_column].dropna().unique())

    unmatched = child_values - parent_values

    print(f"\n{relationship_name}")
    print(f"Child table: {child_column}")
    print(f"Parent table: {parent_column}")
    print(f"Unique child values: {len(child_values):,}")
    print(f"Matching parent values: {len(child_values & parent_values):,}")
    print(f"Unmatched values: {len(unmatched):,}")


check_relationship(
    orders,
    "customer_id",
    customers,
    "customer_id",
    "Orders → Customers"
)


check_relationship(
    order_items,
    "order_id",
    orders,
    "order_id",
    "Order Items → Orders"
)


check_relationship(
    order_items,
    "product_id",
    products,
    "product_id",
    "Order Items → Products"
)


check_relationship(
    order_items,
    "seller_id",
    sellers,
    "seller_id",
    "Order Items → Sellers"
)


check_relationship(
    payments,
    "order_id",
    orders,
    "order_id",
    "Payments → Orders"
)


check_relationship(
    reviews,
    "order_id",
    orders,
    "order_id",
    "Reviews → Orders"
)


# ---------------------------------------------------------
# 3. ORDER MULTIPLICITY
# ---------------------------------------------------------

print("\n3. ORDER MULTIPLICITY")
print("=" * 80)


items_per_order = (
    order_items
    .groupby("order_id")
    .size()
)


payments_per_order = (
    payments
    .groupby("order_id")
    .size()
)


reviews_per_order = (
    reviews
    .groupby("order_id")
    .size()
)


print(
    f"Orders with multiple items: "
    f"{(items_per_order > 1).sum():,}"
)

print(
    f"Orders with multiple payment records: "
    f"{(payments_per_order > 1).sum():,}"
)

print(
    f"Orders with multiple reviews: "
    f"{(reviews_per_order > 1).sum():,}"
)


# ---------------------------------------------------------
# 4. SUMMARY
# ---------------------------------------------------------

print("\n" + "=" * 80)
print("RELATIONSHIP ANALYSIS COMPLETE")
print("=" * 80)