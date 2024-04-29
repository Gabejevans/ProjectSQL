-- Cleaning Data in SQL Queries 

select * 
from PortfolioProject..NashvilleHousing

-- Stadardize date format 
select SaleDate 
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing 
set SaleDateConverted = convert(date, SaleDate)

-- date was already standardised

select SaleDateConverted, convert(DATE,SaleDate)
from PortfolioProject..NashvilleHousing


-- populate property address data 

select * 
from PortfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is Null 
order by ParcelID

-- when the parcelID is the same it is for the same address 

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID] <> b.[UniqueID]

where a.PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID] <> b.[UniqueID]

where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID] <> b.[UniqueID]

where a PropertyAddress is null 

-- breaking out address into individual colums (address, city, state)

select PropertyAddress 
from PortfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is Null 
-- order by ParcelID

select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress)  +1, LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255)

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255)

update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)  +1, LEN(PropertyAddress)) 

select * 
from PortfolioProject..NashvilleHousing

-- makes the data a lot more usable when looking at locations


--  Owner addresses 

select OwnerAddress
from PortfolioProject..NashvilleHousing

select
parsename(replace(OwnerAddress, ',', '.') , 3)
,parsename(replace(OwnerAddress, ',', '.') , 2)
,parsename(replace(OwnerAddress, ',', '.') , 1)
from PortfolioProject..NashvilleHousing

-- a lot easier than a substring..

alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.') , 3)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.') , 2)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.') , 1)

select *
from PortfolioProject.dbo.NashvilleHousing



--Change Y and N to Yes and No

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
       end
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = 
case 
       when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
       end



-- Remove duplicates (not standard practice)
with RowNumCTE as(
select *,
     row_number() over( 
	 partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  order by 
				    UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
)
--delete 
select *
from RowNumCTE
where row_num > 1



-- Delete Unused Columns 

select * 
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate
order by PropertyAddress





