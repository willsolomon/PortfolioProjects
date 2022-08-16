--Standardizing Date Format
alter table nashvilleHousing
Add SaleDateConverted Date;

update nashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

--Replace Nulls in Property Address

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..nashvilleHousing a
join PortfolioProject..nashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..nashvilleHousing a
join PortfolioProject..nashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Separating Address Column
alter table nashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update nashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

alter table nashvilleHousing
Add PropertySplitCity nvarchar(255);

update nashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

--select PropertySplitAddress, PropertySplitCity
--from PortfolioProject..nashvilleHousing

--Split Ownder Address

alter table nashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update nashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.') ,3)

alter table nashvilleHousing
Add OwnerSplitCity nvarchar(255);

update nashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.') ,2)

alter table nashvilleHousing
Add OwnerSplitState nvarchar(255);

update nashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.') ,1)

--Change Y/N to Yes/No in Sold as Vacant

update nashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

--Remove Dupes
with rowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from PortfolioProject..nashvilleHousing
)
delete
from rowNumCTE
where row_num >1

--Delete Unused Columns

alter table PortfolioProject..nashvilleHousing
drop column SaleDate

select *
from PortfolioProject..nashvilleHousing