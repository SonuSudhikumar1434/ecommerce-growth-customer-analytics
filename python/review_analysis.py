from pathlib import Path
import pandas as pd


# ---------------------------------------------------------
# PROJECT PATH
# ---------------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = PROJECT_ROOT / "data" / "raw" / "olist"


# ---------------------------------------------------------
# LOAD REVIEWS
# ---------------------------------------------------------

reviews = pd.read_csv(
    DATA_PATH / "olist_order_reviews_dataset.csv"
)


print("=" * 80)
print("REVIEW STRUCTURE ANALYSIS")
print("=" * 80)


# ---------------------------------------------------------
# 1. REVIEW ID DUPLICATES
# ---------------------------------------------------------

print("\n1. REVIEW ID DUPLICATES")
print("=" * 80)

review_id_counts = reviews["review_id"].value_counts()

duplicate_review_ids = review_id_counts[
    review_id_counts > 1
]

print(
    f"Unique review IDs: "
    f"{reviews['review_id'].nunique():,}"
)

print(
    f"Review IDs appearing more than once: "
    f"{len(duplicate_review_ids):,}"
)

print(
    f"Rows belonging to duplicated review IDs: "
    f"{duplicate_review_ids.sum():,}"
)


# ---------------------------------------------------------
# 2. ORDER ID DUPLICATES
# ---------------------------------------------------------

print("\n2. ORDER ID DUPLICATES")
print("=" * 80)

order_id_counts = reviews["order_id"].value_counts()

multiple_review_orders = order_id_counts[
    order_id_counts > 1
]

print(
    f"Unique orders with reviews: "
    f"{reviews['order_id'].nunique():,}"
)

print(
    f"Orders with multiple review rows: "
    f"{len(multiple_review_orders):,}"
)


# ---------------------------------------------------------
# 3. SHOW EXAMPLES
# ---------------------------------------------------------

print("\n3. EXAMPLES OF DUPLICATE REVIEW IDs")
print("=" * 80)

duplicate_ids = duplicate_review_ids.head(10).index

examples = reviews[
    reviews["review_id"].isin(duplicate_ids)
].sort_values("review_id")

print(
    examples[
        [
            "review_id",
            "order_id",
            "review_score",
            "review_creation_date"
        ]
    ].to_string(index=False)
)


# ---------------------------------------------------------
# 4. REVIEW SCORE DISTRIBUTION
# ---------------------------------------------------------

print("\n4. REVIEW SCORE DISTRIBUTION")
print("=" * 80)

score_distribution = (
    reviews["review_score"]
    .value_counts()
    .sort_index()
)

print(score_distribution)


print("\n" + "=" * 80)
print("REVIEW ANALYSIS COMPLETE")
print("=" * 80)