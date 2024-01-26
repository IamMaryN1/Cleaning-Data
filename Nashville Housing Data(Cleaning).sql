/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM Portfolio_Project..NashvilleHousing
----------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM Portfolio_Project..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted  Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

alter table NashvilleHousing
drop column SaleDateConvirted;

----------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM Portfolio_Project..NashvilleHousing
WHERE PropertyAddress IS NULL
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project..NashvilleHousing a
JOIN Portfolio_Project..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress =  isnull(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project..NashvilleHousing a
JOIN Portfolio_Project..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


----------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) with SUBSTRING or PARSENAME

SELECT PropertyAddress
FROM Portfolio_Project..NashvilleHousing
--WHERE PropertyAddress IS NULL
--order by ParcelID

SELECT 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
FROM Portfolio_Project..NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress  nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity  nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

Select *
FROM Portfolio_Project..NashvilleHousing




Select OwnerAddress
FROM Portfolio_Project..NashvilleHousing
-- We changed colon on dot with REPLACE in PARSENAME function
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio_Project..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress  nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity  nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState  nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



----------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct SoldAsVacant, Count(SoldAsVacant)
FROM Portfolio_Project..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   end
FROM Portfolio_Project..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   end




----------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE as(
SELECT *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) as row_num
FROM Portfolio_Project..NashvilleHousing
--ORDER BY [UniqueID ]
)
--Delete (deleted 104 duplicated rows)
--From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


----------------------------------------------------------------

-- Deleted Unused columns


select *
FROM Portfolio_Project..NashvilleHousing

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN OwnerAddress,
			TaxDistrict,
			PropertyAddress

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN SaleDate