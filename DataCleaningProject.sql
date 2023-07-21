--Cleaning Data in SQL Queries

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousingData

--Coverting SaleDate data type into DATE for query
SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousingData

UPDATE NashvilleHousingData
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER Table NashvilleHousingData
ADD SaleDateConverted DATE;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(DATE, SaleDate)

--Populate property NULL address data if ParcelID is shared

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousingData
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID]<> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--Separating column propertyaddress into separate columns (address, city, state)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousingData

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))  AS city
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER Table NashvilleHousingData
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER Table NashvilleHousingData
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousingData

--Separating owner address into separate columns (address, city, state), but through parsename function
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousingData

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER Table NashvilleHousingData
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER Table NashvilleHousingData
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER Table NashvilleHousingData
ADD PropertySplitState nvarchar(255);

--EXEC sp_rename 'NashvilleHousingData.PropertySplitState', 'OwnerSplitState', 'COLUMN';

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHousingData


--Changing 0's and 1's to No and Yes within SoldAsVacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS count
FROM PortfolioProject.dbo.NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

ALTER TABLE NashvilleHousingData
ALTER COLUMN SoldAsVacant NVARCHAR(3);

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 1 THEN 'Yes'
WHEN SoldAsVacant = 0 THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 1 THEN 'Yes'
WHEN SoldAsVacant = 0 THEN 'No'
ELSE SoldAsVacant
END


--Remove Duplicates
WITH cte AS
(
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousingData
)
SELECT *
FROM CTE
WHERE row_num > 1

--Delete unused data

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
