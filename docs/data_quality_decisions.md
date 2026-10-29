# Data Quality Decisions

## 1. Customers

- No duplicate rows detected.
- No missing values detected.
- No cleaning required at this stage.

## 2. Geolocation

- 261,831 duplicate rows detected.
- Duplicate records will not be removed blindly.
- The table will be investigated to determine whether multiple coordinates exist for the same ZIP code.
- The appropriate grain of the table will be established before analytical use.

## 3. Order Items

- No duplicate rows detected.
- No missing values detected.
- No immediate cleaning required.

## 4. Payments

- No duplicate rows detected.
- No missing values detected.
- Multiple payment records per order are expected because an order may contain multiple payment entries.
- Payment data will therefore be analyzed at the appropriate order/payment grain.

## 5. Reviews

- No duplicate rows detected.
- Missing values are primarily present in review comment title and review comment message.
- Missing comments will not be treated as erroneous data.
- For analysis, missing comments may be represented as "No customer comment" where appropriate.

## 6. Orders

- No duplicate rows detected.
- Missing values exist in order approval and delivery milestone timestamps.
- Missing dates will not be automatically imputed.
- Order status will be used to determine whether a missing milestone is expected or represents a potential data-quality issue.

## 7. Products

- Missing values exist in product category and product attribute fields.
- Missing values will be investigated before deciding whether to use "Unknown" or another treatment.
- Product records will not be removed solely because of missing attributes.

## 8. Sellers

- No duplicate rows detected.
- No missing values detected.
- No immediate cleaning required.

## 9. Product Category Translation

- No duplicate rows detected.
- No missing values detected.
- This table will be used to provide English product category names where available.