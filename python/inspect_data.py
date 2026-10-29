from pathlib import Path
import pandas as pd


# ---------------------------------------------------------
# PROJECT PATHS
# ---------------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = PROJECT_ROOT / "data" / "raw" / "olist"


# ---------------------------------------------------------
# DATASET FILES
# ---------------------------------------------------------

csv_files = sorted(DATA_PATH.glob("*.csv"))


# ---------------------------------------------------------
# CHECK DATASET DIRECTORY
# ---------------------------------------------------------

if not csv_files:
    print("ERROR: No CSV files found.")
    print(f"Checked: {DATA_PATH}")
    raise SystemExit(1)


print("=" * 80)
print("E-COMMERCE DATASET INSPECTION")
print("=" * 80)

print(f"\nDataset location:")
print(DATA_PATH)

print(f"\nNumber of CSV files found: {len(csv_files)}")


# ---------------------------------------------------------
# INSPECT EACH TABLE
# ---------------------------------------------------------

for file_path in csv_files:

    print("\n" + "=" * 80)
    print(f"TABLE: {file_path.name}")
    print("=" * 80)

    try:

        df = pd.read_csv(file_path)

        print(f"\nRows: {df.shape[0]:,}")
        print(f"Columns: {df.shape[1]:,}")

        print("\nColumn names:")
        for column in df.columns:
            print(f"  - {column}")

        print("\nData types:")
        print(df.dtypes.to_string())

        print("\nMissing values:")
        missing = df.isnull().sum()
        missing = missing[missing > 0]

        if missing.empty:
            print("  No missing values")
        else:
            print(missing.to_string())

        print("\nDuplicate rows:")
        print(f"  {df.duplicated().sum():,}")

        print("\nFirst 3 rows:")
        print(df.head(3).to_string(index=False))

    except Exception as error:

        print(f"ERROR reading {file_path.name}")
        print(error)


print("\n" + "=" * 80)
print("INSPECTION COMPLETE")
print("=" * 80)