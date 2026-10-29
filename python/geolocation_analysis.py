from pathlib import Path
import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = PROJECT_ROOT / "data" / "raw" / "olist"

geo = pd.read_csv(
    DATA_PATH / "olist_geolocation_dataset.csv"
)

print("=" * 70)
print("GEOLOCATION GRAIN ANALYSIS")
print("=" * 70)

# Basic information
print("\nBASIC INFORMATION")
print(f"Rows: {len(geo):,}")
print(f"Unique ZIP prefixes: {geo['geolocation_zip_code_prefix'].nunique():,}")
print(f"Unique cities: {geo['geolocation_city'].nunique():,}")
print(f"Unique states: {geo['geolocation_state'].nunique():,}")

# ZIP analysis
zip_counts = geo.groupby(
    "geolocation_zip_code_prefix"
).size()

print("\nZIP PREFIX ANALYSIS")
print(
    f"ZIP prefixes with multiple records: "
    f"{(zip_counts > 1).sum():,}"
)

print(
    f"Maximum records for one ZIP prefix: "
    f"{zip_counts.max():,}"
)

# City consistency
cities_per_zip = (
    geo.groupby("geolocation_zip_code_prefix")
    ["geolocation_city"]
    .nunique()
)

print("\nZIP → CITY")
print(
    f"ZIP prefixes mapped to multiple cities: "
    f"{(cities_per_zip > 1).sum():,}"
)

# State consistency
states_per_zip = (
    geo.groupby("geolocation_zip_code_prefix")
    ["geolocation_state"]
    .nunique()
)

print("\nZIP → STATE")
print(
    f"ZIP prefixes mapped to multiple states: "
    f"{(states_per_zip > 1).sum():,}"
)

# Duplicate analysis
duplicates = geo.duplicated().sum()

print("\nDUPLICATES")
print(f"Exact duplicate rows: {duplicates:,}")
print(
    f"Rows after removing exact duplicates: "
    f"{len(geo.drop_duplicates()):,}"
)

print("\n" + "=" * 70)
print("GEOLOCATION ANALYSIS COMPLETE")
print("=" * 70)