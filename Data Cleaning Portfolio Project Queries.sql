/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing]
	
----------------------------------------------------------------------------------------------------------------
-- Standard Date Format

SELECT SaleDate, convert(date, SaleDate), SaleDateConverted
FROM [PortfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)
	
-----------------------------------------------------------------------------------------------------------------

--Populate Property Address data
SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress is null
Order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
		ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
	
-------------------------------------------------------------------------------------------------------
--Breaking out Address into individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing

Select PropertyAddress, 
       SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
       SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From NashvilleHousing;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255),
    PropertySpliCtity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1),
    PropertySpliCtity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));


SELECT OwnerAddress
FROM NashvilleHousing

SELECT OwnerAddress,
	   PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnersSplitAddress Nvarchar(255),
    OwnersSplitCity Nvarchar(255),
	OwnersSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnersSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
    OwnersSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnersSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

----------------------------------------------------------------------------------------------------------------
	
-- Change Y and N to Yes and No in "Sold as Vacant" field.
Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant ='Y' then 'Yes'
		 WHEN SoldAsVacant = 'N' then 'No'
		 ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' then 'Yes'
						WHEN SoldAsVacant = 'N' then 'No'
						ELSE SoldAsVacant
					END


---------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER ( PARTITION BY ParcelID, 
					 PropertyAddress, 
					 SalePrice, 
					 SaleDate, 
					 LegalReference
					 ORDER BY UniqueID) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
--DELETE 
SELECT * 
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
SELECT * 
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
