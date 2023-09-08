--Looking at the data
select * from Portfolio_Project..Housing_Data

--Removing Time from the Date to make a standard format

select SaleDateConverted, convert(date, SaleDate) from Portfolio_Project..Housing_Data

ALTER TABLE Portfolio_Project..Housing_Data
Add SaleDateConverted date
update Portfolio_Project..Housing_Data
set SaleDateConverted = convert(date,SaleDate)

--Looking at property address
select * from Portfolio_Project..Housing_Data where PropertyAddress is null

--Found Null Property address with same parcel ID so copying the property address to fill the Null
select a.ParcelID as parcelidA, a.PropertyAddress as propertyaddressA, b.ParcelID as parcelidB, b.PropertyAddress as propertyaddressB, isnull(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project..Housing_Data as a join Portfolio_Project..Housing_Data b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project..Housing_Data as a join Portfolio_Project..Housing_Data b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking Address into Address, City, State Columns
select PropertyAddress from Portfolio_Project..Housing_Data

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from Portfolio_Project..Housing_Data

Alter Table Portfolio_Project..Housing_Data
Add Property_Address nvarchar(255)

update Portfolio_Project..Housing_Data
set Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter Table Portfolio_Project..Housing_Data
Add Property_City nvarchar(255)

update Portfolio_Project..Housing_Data
set Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select * from Portfolio_Project..Housing_Data

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from Portfolio_Project..Housing_Data

Alter Table Portfolio_Project..Housing_Data
Add Owner_Address nvarchar(255), Owner_City nvarchar(255), Owner_State nvarchar(255)

Update Portfolio_Project..Housing_Data
set Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3), Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2), Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

--Changing Y and N to Yes and No
select Distinct(SoldAsVacant), count(SoldAsVacant) from Portfolio_Project..Housing_Data Group By SoldAsVacant order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from Portfolio_Project..Housing_Data

update Portfolio_Project..Housing_Data
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end


--Removing Duplicate data 

select * from Portfolio_Project..Housing_Data

With RowNumCTE as (
select *,
ROW_NUMBER() over (
	PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) row_num
from Portfolio_Project..Housing_Data)

select * from RowNumCTE where row_num > 1

--Removing Unnecessary columns

select * from Portfolio_Project..Housing_Data

Alter Table Portfolio_Project..Housing_Data
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
