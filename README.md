# Nashville Housing Data Cleaning with SQL

This project demonstrates cleaning and preprocessing raw housing data using SQL to produce an analysis-ready dataset. The focus is on standardizing data formats, filling missing values, splitting complex address fields, removing duplicates, and preparing the data for further analysis.

## Dataset

**Source:** `PortfolioProject.dbo.NashvilleHousing` (SQL Server)  
**Key Fields:** ParcelID, UniqueID, PropertyAddress, OwnerAddress, SaleDate, SalePrice, SoldAsVacant, LegalReference, TaxDistrict  

## Skills & Tools

- SQL (T-SQL)  
- Data Cleaning & Preprocessing  
- String Parsing & Address Standardization  
- Handling Missing Values  
- Removing Duplicates  
- Conditional Updates  
- Temporary Columns & ALTER TABLE  

## Analyses Performed

- **Initial Data Review:** Inspect raw dataset and identify missing or inconsistent values.  
- **Date Standardization:** Convert `SaleDate` to proper SQL `Date` type.  
- **Populate Missing Addresses:** Fill null `PropertyAddress` values using other records with the same `ParcelID`.  
- **Split Addresses:** Break `PropertyAddress` into Street and City; break `OwnerAddress` into Street, City, and State.  
- **Standardize Categorical Values:** Convert `SoldAsVacant` from `Y/N` to `Yes/No`.  
- **Remove Duplicates:** Identify and remove duplicate records using `ROW_NUMBER()` and CTE.  
- **Drop Unused Columns:** Remove redundant columns (`OwnerAddress`, `TaxDistrict`, `PropertyAddress`, `SaleDate`) after cleaning.  

## Key Insights

- Data inconsistencies in addresses and dates were common in the raw dataset.  
- Null `PropertyAddress` values could be reliably populated using `ParcelID` matches.  
- Splitting complex address fields into separate columns facilitates analysis at street, city, and state levels.  
- Standardizing categorical fields like `SoldAsVacant` improves clarity and consistency for downstream queries.  
- Removing duplicates and redundant columns resulted in a cleaner, analysis-ready dataset suitable for further analytics or visualization.  
