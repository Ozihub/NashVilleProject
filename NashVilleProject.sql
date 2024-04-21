SELECT *
FROM dbo.NashVilleHousingproject

--TO STANDARDIZE DATE FORMAT
Select saleDate, CONVERT(Date,SaleDate)
From dbo.NashVilleHousingproject
UPDATE dbo.NashvilleHousingproject
SET SaleDate = Convert(Date,SaleDate)
--OR
ALTER TABLE NashvilleHousingproject
ALTER COLUMN SaleDATE Date
--OR
ALTER TABLE NashvilleHousingproject
Add SaleDateConverted Date;
Update NashvilleHousingproject
SET SaleDateConverted = CONVERT(Date,SaleDate)

----TO POPULATE PROPERTY ADDRESS DATA
Select *
From dbo.NashvilleHousingproject
Where PropertyAddress is null

Select *
From dbo.NashvilleHousingproject
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From dbo.NashvilleHousingproject a
JOIN dbo.NashvilleHousingproject b
on a.ParcelID =b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
   --then
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousingproject a
JOIN dbo.NashvilleHousingproject b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--SPLITTING ADDRESS INTO INDIVIDUAL COLUMNS(Address, City, State) using substring
Select PropertyAddress
From dbo.NashvilleHousingproject

select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From dbo.NashvilleHousingproject
Select *
From dbo.NashvilleHousingproject
--then create two columns
ALTER TABLE NashvilleHousingproject
ADD PropertySplitAddress Nvarchar(255);
Update NashvilleHousingproject
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousingproject
Add PropertySplitCity Nvarchar(255);
Update NashvilleHousingproject
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--Splitting owner address using parsename
Select OwnerAddress
From dbo.NashvilleHousingproject

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From dbo.NashvilleHousingproject

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);
Update NashVilleHousingproject
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousingproject
Add OwnerSplitCity Nvarchar(255);
Update NashVilleHousingproject
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousingproject
Add OwnerSplitState Nvarchar(255);
Update NashVilleHousingproject
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From dbo.NashvilleHousingproject

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select SoldAsVacant
From dbo.NashvilleHousingproject

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.NashvilleHousingproject
group by SoldAsVacant
order by 2


Select SoldAsVacant,
CASE When SoldAsVacant ='Y' THEN 'Yes'
     When SoldAsVacant ='N' THEN 'No'
     else SoldAsVacant
     END
From dbo.NashvilleHousingproject

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--REMOVING DUPLICATES
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
From dbo.NashvilleHousingproject
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--to delete unused column
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
From dbo.NashvilleHousingproject
--order by ParcelID
)
delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

Select *
From dbo.NashvilleHousingproject

--to delete unused columns
ALTER TABLE dbo.NashvilleHousingproject
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate