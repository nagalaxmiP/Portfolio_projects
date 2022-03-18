/*
Cleaning Data in SQL Queries(NashvilleHousing Data used for cleaning)
*/
--top 10 rows


select top 10 *
from portfolio_project..NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------

--date format 

alter table portfolio_project.. NashvilleHousing
add CovertedSaleDate Date
update  portfolio_project..NashvilleHousing
set  CovertedSaleDate= convert(Date, SaleDate)
select  *
from portfolio_project..NashvilleHousing



------------------------------------------------------------------------------------
--populate preperty address data


select PropertyAddress,OwnerName,OwnerAddress
from portfolio_project..NashvilleHousing
where PropertyAddress is null


select N1.ParcelId,N1.PropertyAddress,  N2.ParcelId,N2.PropertyAddress,
ISNULL(N1.PropertyAddress,N2.PropertyAddress) as UpdatedAddress
from portfolio_project..NashvilleHousing N1 join
portfolio_project..NashvilleHousing N2
on N1.ParcelID=N2.ParcelID
and N1.[UniqueID]<>N2.[UniqueID]
where N1.PropertyAddress is null


UPDATE N1
set PropertyAddress=ISNULL(N1.PropertyAddress,N2.PropertyAddress)
from portfolio_project..NashvilleHousing N1 join
portfolio_project..NashvilleHousing N2
on N1.ParcelID=N2.ParcelID
and N1.[UniqueID]<>N2.[UniqueID]
where N1.PropertyAddress is null


select  PropertyAddress
from portfolio_project..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------
---spliting the address into three separate columns(address,city,state)

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,datalength(PropertyAddress)) as city
from portfolio_project..NashvilleHousing
--substring(string,startposition,length)
--substring is to get some charcters from a string


alter table portfolio_project..NashvilleHousing
add address varchar(255)


update portfolio_project..NashvilleHousing
set address=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 



update portfolio_project..NashvilleHousing
set city=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,datalength(PropertyAddress)) 

select  *
from portfolio_project..NashvilleHousing
-------------------------------------------------------------------------------------------------------------

--owner adress splitting into three invidual columns(address,city,state)


select parsename(replace(OwnerAddress,',','.'),3) as OwnerAddress,
parsename(replace(OwnerAddress,',','.'),2) as OwnerCity,
parsename(replace(OwnerAddress,',','.'),1) as OwnerState
from portfolio_project..NashvilleHousing



alter table portfolio_project..NashvilleHousing
add OwenerAddress varchar(255)


update portfolio_project..NashvilleHousing
set OwenerAddress=parsename(replace(OwnerAddress,',','.'),3) 


alter table portfolio_project..NashvilleHousing
add OwnerCity varchar(255)

update portfolio_project..NashvilleHousing
set OwnerCity=parsename(replace(OwnerAddress,',','.'),2) 


alter table portfolio_project..NashvilleHousing
add  OwnerState  varchar(255)


update portfolio_project..NashvilleHousing
set OwnerState=parsename(replace(OwnerAddress,',','.'),1) 


select  *
from portfolio_project..NashvilleHousing
--------------------------------------------------------------------------------------------------
---missing information
---Replacing Y with YES and N with NO in soldasvacant column

select distinct(UpdatedSoldAsVacant),COUNT(UpdatedSoldAsVacant)
from portfolio_project..NashvilleHousing

group by UpdatedSoldAsVacant
order by 2

select SoldAsVacant,
CASE when SoldAsVacant='Y' then 'YES'
     when SoldAsVacant='N' then 'NO'
	 else SoldAsVacant
END
from portfolio_project..NashvilleHousing

alter table portfolio_project..NashvilleHousing
add  UpdatedSoldAsVacant  varchar(255)

update portfolio_project..NashvilleHousing
set UpdatedSoldAsVacant= 
CASE when SoldAsVacant='Y' then 'YES'
     when SoldAsVacant='N' then 'NO'
	 else SoldAsVacant
END
select  *
from portfolio_project..NashvilleHousing
---------------------------------------------------------------------------------------------------------------------------
-----checking if there are any duplicates 
with DupliCTE as
(
select *,
row_number() over(partition by ParcelID,
                               PropertyAddress,
							   SaleDate,
							   SalePrice,
							   LegalReference
							   order by
							   UniqueID
							   ) as RowNum
from portfolio_project..NashvilleHousing
--order by ParcelID
)
--select *
--from DupliCTE
--where RowNum>1
--------deleating dulplicates
delete
from DupliCTE
where RowNum>1
--------------------------------------------------------------------------------------------------------------------------
--delete unused columns

alter table  portfolio_project..NashvilleHousing
drop column PropertyAddress,
            OwnerAddress,
			SaleDate
alter table  portfolio_project..NashvilleHousing
drop column SoldAsVacant

select *
from portfolio_project..NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------
--changing Updated Column Names

Use portfolio_project;
GO
EXEC sp_rename 'NashvilleHousing.[UpdatedSoldAsVacant]', 'SoldAsVacant', 'COLUMN';
GO

Use portfolio_project;
GO
EXEC sp_rename 'NashvilleHousing.[city]', 'PropertyCity', 'COLUMN';
GO

Use portfolio_project;
GO
EXEC sp_rename 'NashvilleHousing.[CovertedSaleDate]', 'SaleDate', 'COLUMN';
GO

select *
from portfolio_project..NashvilleHousing

