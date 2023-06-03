SELECT
	*
FROM
	PortfolioProject..NashvilleHousing

-- Deleting time stamp

SELECT
	SaleDateConverted, CONVERT(Date,SaleDate)
FROM
	PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDAteConverted = CONVERT(Date,SaleDate)

--Populating Property Address data
			--Finding nulls
SELECT
	*
FROM
	PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
Order by ParcelID

--Join tables to match parcel ID

SELECT
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM
	PortfolioProject.dbo.NashvilleHousing a
	JOIN PortfolioProject.dbo.NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress is null

UPDATE a 
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	PortfolioProject.dbo.NashvilleHousing a
	JOIN PortfolioProject.dbo.NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress is null


-- breaking apart address column into individual comlums (adress, city, state)

SELECT
	PropertyAddress
FROM
	PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--Order by ParcelID

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
FROM
	PortfolioProject.dbo.NashvilleHousing


SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as Address
FROM
	PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

-- Another way to seperate columns
SELECT
	OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
	PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)
	,PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)
	,PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAdress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAdress= PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)

SELECT 
	*
FROM
	PortfolioProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT
	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM
	PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2
	

SELECT 
	SoldAsVacant
	, CASE When SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'YES'
	ELSE SoldAsVacant
	END
FROM
	PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'YES'
	ELSE SoldAsVacant
	END


-- Remove duplicates

WITH row_numCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID
		) row_num
FROM
	PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
FROM row_numCTE
WHERE row_num > 1
Order by PropertyAddress

-- Delete unused columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE 
	PortfolioProject.dbo.NashvilleHousing
DROP COLUMN
	OwnerAddress, TaxDistrict, PropertyAddress,SaleDate
