--Data Cleaning in SQL

SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing

--Standardize Date Format
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
From [Portfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing	
SET SaleDateConverted = CONVERT(date,SaleDate)

--Populate Property Address

SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing A
JOIN [Portfolio Project].dbo.NashvilleHousing B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing A
JOIN [Portfolio Project].dbo.NashvilleHousing B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

--Breaking Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM [Portfolio Project].dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(225);

UPDATE NashvilleHousing	
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCIty Nvarchar(225);

UPDATE NashvilleHousing	
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) 

SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing

--
SELECT OwnerAddress
FROM [Portfolio Project].dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Project].dbo.NashvilleHousing;



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(225);

UPDATE NashvilleHousing	
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(225);

UPDATE NashvilleHousing	
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(225);

UPDATE NashvilleHousing	
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [Portfolio Project].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

--Remove Duplicates

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
FROM [Portfolio Project].dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

--DELETE Unused Columns

SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN SaleDate