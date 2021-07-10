/*
CLEANING DATA
*/

SELECT *
FROM NashvilleHousing.dbo.NashvilleHousingData



-----Standardize date format ---------------
SELECT SaleDateConverted
FROM NashvilleHousing.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD SaleDateConverted Date;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)



----Populate Property Address data -------------------
SELECT *
FROM NashvilleHousing.dbo.NashvilleHousingData
WHERE PropertyAddress is null

SELECT *
FROM NashvilleHousing.dbo.NashvilleHousingData
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleHousingData a
JOIN NashvilleHousing.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleHousingData a
JOIN NashvilleHousing.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null



----Breaking out address in individual columns (Address, City, State)------------------------
SELECT PropertyAddress
FROM NashvilleHousing.dbo.NashvilleHousingData

SELECT 
SUBSTRING(PropertyAddress,  1,  CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS CITY
FROM NashvilleHousing.dbo.NashvilleHousingData


ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress,  1,  CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing.dbo.NashvilleHousingData



------Splitting of Owner Address-----------

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing.dbo.NashvilleHousingData


ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing.dbo.NashvilleHousingData




-------Replacing Y and N to Yes and No in SoldAsVacant feild
SELECT SoldAsVacant, UniqueID
FROM NashvilleHousing.dbo.NashvilleHousingData

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing.dbo.NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y'THEN 'Yes'
	 WHEN SoldAsVacant = 'N'THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing.dbo.NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y'THEN 'Yes'
						WHEN SoldAsVacant = 'N'THEN 'No'
						ELSE SoldAsVacant
						END

 


 -----------------Remove Duplicates---------------------------------------

 WITH RowNumCTE AS(
 SELECT *,
  ROW_NUMBER() OVER( PARTITION BY ParcelID,
								  PropertyAddress,
								  SalePrice,
								  Saledate,
								  LegalReference
								  ORDER BY UniqueID) row_num

FROM NashvilleHousing.dbo.NashvilleHousingData
--ORDER BY ParcelID
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress
