Select *
from PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Property Address data

Select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a .PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]



-- Breaking out Address into Individual Columns (Adress, City, State)

-- Property

Select PropertyAddress, PropertySplitAddress, PropertySplitCity
from PortfolioProject.dbo.NashvilleHousing


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City

from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select PropertyAddress, PropertySplitAddress, PropertySplitCity
from PortfolioProject.dbo.NashvilleHousing


-- Owner

Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) as Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) as City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) as State
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) 


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), count(SoldAsVacant) 
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y'THEN 'Yes'
		When SoldAsVacant = 'N'then 'No'
		else SoldAsVacant
		end
from PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y'THEN 'Yes'
		When SoldAsVacant = 'N'then 'No'
		else SoldAsVacant
		end

Select Distinct (SoldAsVacant), count(SoldAsVacant) 
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2



-- Remove the Duplicates

WITH RowNumCTE as (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num


from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE 
from RowNumCTE
where row_num > 1




-- Delete Unused Columns

Select *
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


