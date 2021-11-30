'''
data cleaning -
1- standardize data
2- deal with null addresses 
3- city, country etc from addresses
4- change y to yes n to no 
5- remove duplicate rows 
6- drop columns 
'''




use DataAnalytics;
-- creating table
--Create Table houses (UniqueID  int,ParcelID varchar(5000),LandUse varchar(5000),PropertyAddress varchar(5000),SaleDate Date,SalePrice varchar(5000),LegalReference varchar(5000),SoldAsVacant varchar(5000),OwnerName varchar(5000),OwnerAddress varchar(5000),Acreage float,TaxDistrict varchar(5000),LandValue float,BuildingValue float,TotalValue float,YearBuilt float,Bedrooms float,FullBath float,HalfBath float);

-- select all
select top 1000 * from Houses;

-- standardize data : saledate to date format and get rid of time, although here we already have date.
select top 100 SaleDate,convert(Date,SaleDate) from Houses; 

alter table Houses
add SaleDateConverted Date;

update Houses set SaleDateConverted=Convert(Date,SaleDate);
--update Houses set SaleDate=Convert(Date,SaleDate); -- storing new formatted date in the same column.
select top 1000 * from Houses;
-- 

-- property address; nased on parcedid 
--UPDATE Houses SET PropertyAddress=NULL where PropertyAddress='NULL'


select a.uniqueID,a.ParcelID,a.PropertyAddress,b.uniqueId,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress) 
from Houses a
join Houses b 
	on a.ParcelID=b.ParcelID
	and a.UniqueID != b.UniqueID
where a.PropertyAddress is NULL;


UPDATE a
SET a.PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Houses a
join Houses b 
	on a.ParcelID=b.ParcelID
	and a.UniqueID != b.UniqueID
where a.PropertyAddress is NULL;


select * from houses;

----
-- splitting property address

select substring(propertyAddress,1,CHARINDEX(',',propertyaddress)-1) as b,substring (propertyAddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress)) as a  from Houses;

-- or use parsename - this looks only for periods, so replace ur desired delimiter with .
-- also the second argument works in reverse, so 1 returns the last element after split . 

select PropertyAddress,PARSENAME(replace(PropertyAddress,',','.'),3),
PARSENAME(replace(PropertyAddress,',','.'),2),
PARSENAME(replace(PropertyAddress,',','.'),1)
from Houses;



-- sold as vacant 

select SoldAsVacant,
case 
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end as editted
from Houses
where SoldAsVacant in ('Y','N');


update Houses set SoldAsVacant=case 
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end 

--
-- remove duplicates -- but we dont do this sql databases , as deleting data is never recommended 
 -- we can identify duplicate rows, using row_num and using partition by - store in cte, then delete 

 WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing
---



--drop unused columns 


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

