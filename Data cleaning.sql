--------------------------------------------------------------------------------------------------------------------------------------
Select * 
from Portfolio.dbo.Housing

-- Standardize Date Format

Alter Table Housing
Add Saledateconverted Date;


Update Housing
Set Saledateconverted = CONVERT(Date,SaleDate)

Select Saledateconverted
from Portfolio.dbo.Housing

--------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data

Select PropertyAddress
from Portfolio..Housing

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL (a.PropertyAddress,b.PropertyAddress)
from Portfolio..Housing a
Join Portfolio..Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is NULL

Update a
Set PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
from Portfolio..Housing a
Join Portfolio..Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is NULL

-----------------------------------------------------------------------------------------------------------------------------------
-- Breaking out address into individual Columns (Address,City,State)

SELECT PropertyAddress
from Portfolio..Housing


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1 ) as Address,
SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1 , LEN (PropertyAddress)) as Address

from Portfolio..Housing

Alter Table Portfolio..Housing
Add PropertyAddressSplit nvarchar(255);


Update Portfolio..Housing
Set PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1 ) 


Alter Table Housing
Add Propertycity nvarchar(255);

Update Portfolio..Housing
Set Propertycity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1 , LEN (PropertyAddress)) 

Select
Parsename(Replace(OwnerAddress, ',' , '.' ), 3),
Parsename(Replace(OwnerAddress, ',' , '.' ), 2),
Parsename(Replace(OwnerAddress, ',' , '.' ), 1)
from Portfolio..Housing

Select *
from Portfolio..Housing

Alter Table Housing
Add OwnersplitAddress nvarchar(255);

Update Portfolio..Housing
Set OwnersplitAddress = Parsename(Replace(OwnerAddress, ',' , '.' ), 3)

Alter Table Housing
Add OwnersplitCity nvarchar(255);

Update Portfolio..Housing
Set OwnersplitCity = Parsename(Replace(OwnerAddress, ',' , '.' ), 2)

Alter Table Housing
Add OwnersplitState nvarchar(255);

Update Portfolio..Housing
Set OwnersplitState = Parsename(Replace(OwnerAddress, ',' , '.' ), 1)

Select OwnersplitAddress,OwnersplitCity,OwnersplitState
from Housing

------------------------------------------------------------------------------------------------------------------------------------
--CHANGE Y AND N TO YES AND NO IN "Sold as Vacant field"

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
from Portfolio..Housing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then  'Yes'
	 When SoldAsVacant = 'N' Then  'No'
	Else SoldAsVacant
End
from Portfolio..Housing

Update Portfolio..Housing
Set SoldAsVacant =  Case When SoldAsVacant = 'Y' Then  'Yes'
	 When SoldAsVacant ='N' Then  'No'
	Else SoldAsVacant
End

--------------------------------------------------------------------------------------------------
----Remove Duplicates


With RownumCTE AS(
Select *,
	ROW_NUMBER() over (
	Partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by 
		UniqueID
		) row_num

from Portfolio..Housing
)

SELECT *
from RownumCTE
Where row_num > 1
--Order by PropertyAddress

-------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

SELECT *
from Portfolio..Housing

Alter Table Portfolio..Housing
Drop Column PropertyAddress,OwnerAddress,TaxDistrict