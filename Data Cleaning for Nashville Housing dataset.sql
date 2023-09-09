Select * FROM  nashville_housing

----Standardizing Sale dateFormat

Select SaleDate, Str_to_date(SaleDate, '%M %d, %Y')
FROM portfolio_project.nashville_housing

update nashvile_housing
Set SaleDate = Str_to_date(SaleDate, '%M %d, %Y');

Alter table portfolio_project.nashville_housing
Add SaleDateConverted Date;


Update portfolio_project.nashville_housing
SET SaleDateConverted = Str_to_date(SaleDate, '%M %d, %Y');


Select SaleDateConverted, Str_to_date(SaleDate, '%M %d, %Y')
FROM portfolio_project.nashville_housing
where SaleDateConverted is not NULL
---------------------------------------------------------------------

------Populate property address data with correct addresses
 ----checking all columns for null values
Select *
FROM portfolio_project.nashville_housing
where PropertyAddress is NULL

-------updating PropertyAddress column blank rows to NULL
UPDATE portfolio_project.nashville_housing
SET PropertyAddress = NULL
WHERE PropertyAddress = '';

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM portfolio_project.nashville_housing as a
JOIN portfolio_project.nashville_housing as b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL;

UPDATE `portfolio_project`.`nashville_housing` AS `a`
JOIN `portfolio_project`.`nashville_housing` AS `b`
ON `a`.`ParcelID` = `b`.`ParcelID`
AND `a`.`UniqueID` <> `b`.`UniqueID`
SET `a`.`PropertyAddress` = COALESCE(`a`.`PropertyAddress`, `b`.`PropertyAddress`)
WHERE `a`.`PropertyAddress` IS NULL;

---------------------------------------------------------------------
---Breaking PropertyAddress into Individual columns(address, city, state)

Select propertyaddress
FROM portfolio_project.nashville_housing
  
SELECT SUBSTRING_INDEX(PropertyAddress, ',', 1) AS address,
SUBSTRING_INDEX(PropertyAddress, ',', -1) AS city
FROM portfolio_project.nashville_housing;

------Adding new columns to the table
Alter table portfolio_project.nashville_housing
Add PropertyAddressNEW nvarchar(255);

update portfolio_project.nashville_housing
Set PropertyAddressNEW = SUBSTRING_INDEX(PropertyAddress, ',', 1);

Alter table portfolio_project.nashville_housing
Add PropertycityNEW nvarchar(255);

update portfolio_project.nashville_housing
Set PropertycityNEW = SUBSTRING_INDEX(PropertyAddress, ',', -1);

Select PropertyAddress
, Address, city
FROM portfolio_project.nashville_housing

---------seperating owneraddress into columns
Select ownerAddress
FROM portfolio_project.nashville_housing

Select  ownerAddress,
SUBSTRING_INDEX(OwnerAddress, ',', 1) AS address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2),', ', 1) AS city,
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS state
FROM portfolio_project.nashville_housing

Alter table portfolio_project.nashville_housing
Add OwnerAddressNEW nvarchar(255);

update portfolio_project.nashville_housing
Set OwnerAddressNEW = SUBSTRING_INDEX(OwnerAddress, ',', 1);

Alter table portfolio_project.nashville_housing
Add OwnerCityNEW nvarchar(255);

update portfolio_project.nashville_housing
Set OwnerCityNEW = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2),', ', 1);


Alter table portfolio_project.nashville_housing
Add OwnerStateNEW nvarchar(255);

update portfolio_project.nashville_housing
Set OwnerStateNEW = SUBSTRING_INDEX(OwnerAddress, ',', -1);

Select ownerAddress, OwnerAddressNEW, OwnerCityNEW, OwnerStateNEW
FROM portfolio_project.nashville_housing


---------------------------------------------------------
---Change Y AND N tp YES and No in soldASvancant column

Select Distinct(SoldAsVacant)
FROM portfolio_project.nashville_housing

Select SoldAsVacant, 
Case when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No' else SoldAsVacant end
FROM portfolio_project.nashville_housing
where SoldAsVacant in ('Y', 'N')

update portfolio_project.nashville_housing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No' else SoldAsVacant end

--------------------------------------------------------------------------
-----Removing Duplicate data

DELETE FROM portfolio_project.nashville_housing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY UniqueID
        ) AS row_num
        FROM portfolio_project.nashville_housing
    ) AS RownumCTE
    WHERE row_num > 1
);

---------------------------------------------------------
------Delete unused columns

Select *
FROM portfolio_project.nashville_housing

Alter table portfolio_project.nashville_housing
DROP Column OwnerAddress

Alter table portfolio_project.nashville_housing
DROP Column  TaxDistrict

Alter table portfolio_project.nashville_housing
DROP Column PropertyAddress

---------------------------------------
Select * 
FROM 
portfolio_project.nashville_housing

-----------Now our table is much more easier to use with accurate formats and free from any duplicate data 