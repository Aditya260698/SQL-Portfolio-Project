SELECT TOP (1000) [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]


/*

Cleaning Data in SQL Queries

*/

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,Saledate)


-- Populate Property Address

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
ORDER BY ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID <> b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID <> b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


-- Breakingout Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress
) - 1) as Address, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress
) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add ProjectSplitAddress Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET ProjectSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress
) - 1)

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add ProjectSplitCity Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET ProjectSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress
) + 1, LEN(PropertyAddress))

Select * FROM PortfolioProject.dbo.NashvilleHousing

Select OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress ,',', '.') ,3) as Address
,PARSENAME(REPLACE(OwnerAddress ,',', '.') ,2) as City
,PARSENAME(REPLACE(OwnerAddress ,',', '.') ,1) as State
from PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress ,',', '.') ,3)

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress ,',', '.') ,2)


ALTER Table PortfolioProject.dbo.NashvilleHousing
Add ProjectSplitState Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET ProjectSplitState = PARSENAME(REPLACE(OwnerAddress ,',', '.') ,1)

Select * From PortfolioProject.dbo.NashvilleHousing



-- Change Y and N to Yess and No in Sold as Vacant field

Select SoldAsVacant 
--CONVERT(bit,SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacant


Select SoldAsVacant, 
CASE WHEN SoldAsVacant = 1 THEN 'Yes' ELSE 'No'
	 END
FROM PortfolioProject.dbo.NashvilleHousing

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num

FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns

Select * From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate