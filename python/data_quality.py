from pathlib import Path
import pandas as pd


# ---------------------------------------------------------
# PROJECT PATH
# ---------------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = PROJECT_ROOT / "data" / "raw" / "olist"


# ---------------------------------------------------------
# DATA QUALITY CHECK
# ---------------------------------------------------------

print("=" * 80)
print("E-COMMERCE DATA QUALITY ASSESSMENT")
print("=" * 80)


csv_files = sorted(DATA_PATH.glob("*.csv"))

if not csv_files:
    print("ERROR: No CSV files found.")
    raise SystemExit(1)


quality_results = []


# ---------------------------------------------------------
# CHECK EACH TABLE
# ---------------------------------------------------------

for file_path in csv_files:

    df = pd.read_csv(file_path)

    total_rows = len(df)
    total_columns = len(df.columns)

    duplicate_rows = df.duplicated().sum()

    missing_cells = df.isnull().sum().sum()

    missing_percentage = (
        missing_cells / (total_rows * total_columns)
    ) * 100

    quality_results.append({
        "table_name": file_path.stem,
        "rows": total_rows,
        "columns": total_columns,
        "duplicate_rows": duplicate_rows,
        "missing_cells": missing_cells,
        "missing_percentage": round(missing_percentage, 2)
    })


# ---------------------------------------------------------
# CREATE QUALITY REPORT
# ---------------------------------------------------------

quality_df = pd.DataFrame(quality_results)


print("\nDATA QUALITY SUMMARY")
print("=" * 80)

print(
    quality_df.to_string(index=False)
)


# ---------------------------------------------------------
# SAVE REPORT
# ---------------------------------------------------------

output_path = PROJECT_ROOT / "data" / "processed" / "data_quality_summary.csv"

quality_df.to_csv(output_path, index=False)


print("\n" + "=" * 80)
print("DATA QUALITY REPORT SAVED")
print("=" * 80)

print(f"\nFile:")
print(output_path)