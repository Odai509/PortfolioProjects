/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

-- Method 1 (Edit exiest column USING UPDATE)

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

-----------------------------------------
-- Method 2 (Add new column)

SELECT SaleDate_2, CONVERT(DATE, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD SaleDate_2 DATE;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate_2 = CONVERT(DATE, SaleDate)

-----------------------------------------
-- Method 3 (Edit exiest column USING ALTER COLUMN)

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;

-- DROP COLUMN
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate_2;



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data 

--USING JOIN


Select *
From PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER By ParcelID


SELECT temp1.ParcelID, temp2.ParcelID, temp1.PropertyAddress, temp2.PropertyAddress
	, ISNULL(temp1.PropertyAddress,temp2.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS temp1
JOIN PortfolioProject.dbo.NashvilleHousing AS temp2
	ON temp1.ParcelID = temp2.ParcelID
	AND temp1.[UniqueID ] <> temp2.[UniqueID ]
WHERE temp1.PropertyAddress IS NULL


UPDATE temp1
SET PropertyAddress = ISNULL(temp1.PropertyAddress,temp2.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS temp1
JOIN PortfolioProject.dbo.NashvilleHousing AS temp2
	ON temp1.ParcelID = temp2.ParcelID
	AND temp1.[UniqueID ] <> temp2.[UniqueID ]
WHERE temp1.PropertyAddress IS NULL



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out PropertyAddress Column into Individual Columns (Address, City)

-- Using SUBSTRING (String_Name, Start location, End location) 
-- And   CHARINDEX(substring to search for, String_Name)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


Select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
	ADD Property_Address nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET Property_Address = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
	ADD Property_City nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET Property_City = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out OwnerAddress Column into Individual Columns (Address, City, State)

-- Using PARSENAME Returns the specified part of an object name, It start from END , Until it found period (.) 
-- And   REPLACE(original_string, old_string, new_string)

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
	ADD Owner_Address nvarchar(255),
		Owner_City nvarchar(255),
		Owner_State nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

--USING CASE

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant 
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = (CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END)

----------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

--USING ROW_NUMBER() is a window function that assigns a sequential integer number to each row in the query’s result set.

-----------------------------------------

---- Method 1 (USING the subquery)

SELECT * FROM (
SELECT *
, ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
						PropertyAddress,
						SaleDate,
						SalePrice,
						LegalReference
			ORDER BY UniqueID DESC) row_num 
From PortfolioProject.dbo.NashvilleHousing
) t    
WHERE
    row_num > 1 ;


-----------------------------------------

---- Method 2 (USING the common table expression (CTE) instead of the subquery)

WITH RowNumCTE AS(
SELECT *
, ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
						PropertyAddress,
						SaleDate,
						SalePrice,
						LegalReference
			ORDER BY UniqueID DESC) row_num 
From PortfolioProject.dbo.NashvilleHousing  
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

