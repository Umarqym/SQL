-- The following queries are to demonstrate SQL data cleaning/preparation skills.
-- First, we have identidied null values in the 'PropertyAddress' Column.
Select * from nash
where PropertyAddress is null
order by parcelid;


-- To replce the null values, we have joined the same table based on parcelid being while uniqueid not being the same. 
-- The result we get is the replacing of the null values in propertyadress column by values of propertyaddress column 
-- in the second table, as propertyaddresses are the same for the parcelids.
select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ifnull(a.propertyaddress,b.propertyaddress) as dd 
from nash a
join nash b on a.parcelid = b.parcelid
and
a.UniqueID <> b.UniqueID
where a.propertyaddress is null;

-- Updating the table to make the change.
update nash a
join nash b on a.parcelid = b.parcelid
and
a.UniqueID <> b.UniqueID
set a.propertyaddress = ifnull(a.propertyaddress,b.propertyaddress) 
where a.propertyaddress is null;


-- Updating the propertyaddress column to create 2 columns i.e. street_address and city_address. 
-- These columns are filled with values split in the propertyaddress column based on ',' charachter.
-- For example propertyaddress = '32 Brown street, New York' equals street_address = '32 Brown Street' and city_address = 'New York'.
select SUBSTRING_INDEX(propertyaddress,',', 1) as address from nash;
select SUBSTRING_INDEX(propertyaddress,',', -1) as address from nash;

ALTER TABLE nash
ADD column street_address varchar(50) AFTER propertyaddress;

ALTER TABLE nash
ADD column city_address varchar(30) AFTER street_address;

update nash
set street_address = SUBSTRING_INDEX(propertyaddress,',', 1);

update nash
set city_address = SUBSTRING_INDEX(propertyaddress,',', -1);


-- The same process is done for the owneraddress column. Here there is an additional column for state address as 
-- owneraddress includes street,city and state details.
ALTER TABLE nash
ADD column owner_street_address varchar(50) AFTER owneraddress;

ALTER TABLE nash
ADD column owner_city_address varchar(50) AFTER owner_street_address;

ALTER TABLE nash
ADD column owner_state_address varchar(50) AFTER owner_city_address;

update nash
set owner_street_address = SUBSTRING_INDEX(owneraddress,',', 1);

update nash
set owner_city_address = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress,',', 2), ',', -1);

update nash
set owner_state_address = SUBSTRING_INDEX(owneraddress,',', -1);

-- Replacing the 'N' and 'Y' values in soldasvacant column to 'No' and 'Yes' for standardisation purposes.
update nash
set soldasvacant =  (case
					when soldasvacant ='N' then 'No'
					when soldasvacant = 'Y' then 'Yes'
					else
					soldasvacant
					end)

-- Removing duplicate values in the dataset.

with repeated as 
(select *,row_number() over (partition by parcelid,propertyaddress,saleprice,saledate,legalreference order by uniqueid)
 as identify from nash)
 select * from repeated
 where identify > 1;
 
with repeated as (
select UniqueID ,row_number() over (partition by ParcelID, PropertyAddress, 
SalePrice,saledate,LegalReference  order by UniqueID) as identify
from nash)
delete hd
from nash hd INNER JOIN repeated r ON hd.UniqueID = r.UniqueID
where identify>1;