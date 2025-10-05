/*
SQL Data Cleaning: Nashville Housing Dataset
This script demonstrates cleaning and preprocessing raw housing data for analysis.
*/

-- Preview the raw data
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize the SaleDate column
-- Convert SaleDate to proper SQL Date type for consistency and analysis

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing;

-- Update SaleDate directly
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

-- If direct update fails, create a new column SaleDateConverted
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

--------------------------------------------------------------------------------------------------------------------------

-- Populate missing PropertyAddress values
-- Fill null PropertyAddress values by referencing other records with the same ParcelID

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
       ISNULL(a.PropertyAddress, b.PropertyAddress) AS PopulatedAddress
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

-- Update missing addresses
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------------------------------------------

-- Split PropertyAddress into separate columns (Street, City)
-- Allows easier analysis of individual components of addresses

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS PropertyStreet,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertyCity
FROM PortfolioProject.dbo.NashvilleHousing;

-- Create new columns for split address
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

--------------------------------------------------------------------------------------------------------------------------

-- Split OwnerAddress into separate columns (Street, City, State)
-- Standardize owner addresses for easier querying

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerStreet,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
    OwnerSplitCity NVARCHAR(255),
    OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

--------------------------------------------------------------------------------------------------------------------------

-- Standardize SoldAsVacant column
-- Convert 'Y'/'N' values to 'Yes'/'No' for consistency

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

--------------------------------------------------------------------------------------------------------------------------

-- Remove duplicate records
-- Use ROW_NUMBER to identify duplicates based on key columns

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Note: Delete duplicates as needed using row_num > 1

--------------------------------------------------------------------------------------------------------------------------

-- Remove unused or redundant columns
-- Simplify dataset for analysis by dropping unnecessary fields

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

