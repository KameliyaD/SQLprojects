--===============================================
--Standardize Data Format

SELECT 
	SaleDateConverted, 
	CONVERT(Date,SaleDate)
FROM SQLProject1.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--================================================
--Populate Property Address Data

SELECT PropertyAddress
FROM SQLProject1.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL;

SELECT *
FROM SQLProject1.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;

SELECT 
	a.ParcelID, 
	a.PropertyAddress, 
	b.parcelID, 
	b.PropertyAddress, 
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQLProject1.dbo.NashvilleHousing a
	JOIN SQLProject1.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQLProject1.dbo.NashvilleHousing a
	JOIN SQLProject1.dbo.NashvilleHousing b 
ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL; 

--====================================================================
--Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM SQLProject1.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL;
--ORDER BY ParcelID;

/*	
	Looking at PropertyAddress, starting at the very first value 
	and it's going untill the ','
*/

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM SQLProject1.dbo.NashvilleHousing 

ALTER TABLE SQLProject1.dbo.NashvilleHousing  
ADD PropertySplitAddress Nvarchar(255);

ALTER TABLE SQLProject1.dbo.NashvilleHousing 
ADD PropertySplitCity Nvarchar(255);

UPDATE SQLProject1.dbo.NashvilleHousing  
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE SQLProject1.dbo.NashvilleHousing  
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--select * from SQLProject1.dbo.NashvilleHousing;

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM SQLProject1.dbo.NashvilleHousing


ALTER TABLE SQLProject1.dbo.NashvilleHousing  
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE SQLProject1.dbo.NashvilleHousing 
ADD OwnerSplitCity Nvarchar(255);

ALTER TABLE SQLProject1.dbo.NashvilleHousing 
ADD OwnerSplitState Nvarchar(255);

UPDATE SQLProject1.dbo.NashvilleHousing  
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE SQLProject1.dbo.NashvilleHousing  
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE SQLProject1.dbo.NashvilleHousing  
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
	
--======================================================================
--Change Y and N to Yes and No in 'Sold in Vacant' field

SELECT DISTINCT(SoldAsVacant), count(SoldAsVacant)
FROM SQLProject1.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		END
FROM SQLProject1.dbo.NashvilleHousing

UPDATE SQLProject1.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

--==================================================================
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
FROM SQLProject1.dbo.NashvilleHousing
--ORDER BY ParcelID;
)
--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

--Delete unused columns

SELECT * 
FROM SQLProject1.dbo.NashvilleHousing;

ALTER TABLE SQLProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE SQLProject1.dbo.NashvilleHousing
DROP COLUMN SaleDate;