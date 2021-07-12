--- These are the table and values we will be working with :

select UNIQUEID_ , PARCELID , LANDUSE , PROPERTYADDRESS , SALEDATE , SALEPRICE , LEGALREFERENCE , SOLDASVACANT , OWNERNAME , OWNERADDRESS ,ACREAGE ,
        TAXDISTRICT , LANDVALUE , BUILDINGVALUE , TOTALVALUE , YEARBUILT , BEDROOMS , FULLBATH , HALFBATH  
from nashvillehousing;

------ Populate proprety adress data
--- Check the null values on PROPERTYADDRESS column which have another value with the same PARCELID ( using self join )
SELECT  distinct nvh1.PARCELID, nvh1.PROPERTYADDRESS,
         nvh2.uniqueid_, nvh2.PARCELID, nvh2.PROPERTYADDRESS, 
         nvl( nvh1.PROPERTYADDRESS, nvh2.PROPERTYADDRESS ) -- Get the first non null value
FROM nashvillehousing  nvh1 join nashvillehousing  nvh2 on  nvh1.PARCELID = nvh2.PARCELID 

where nvh1.PROPERTYADDRESS is null
and nvh2.PROPERTYADDRESS is not null
and   nvh1.UNIQUEID_ <> nvh2.UNIQUEID_
order by 2;


--- Update the proprety adress column
update nashvillehousing nvh1
set PROPERTYADDRESS = (SELECT distinct max( nvh2.PROPERTYADDRESS )
                        FROM  nashvillehousing  nvh2                        
                        where nvh1.PARCELID = nvh2.PARCELID 
                         and  nvh1.PROPERTYADDRESS is null
                         and  nvh2.PROPERTYADDRESS is not null
                         and  nvh1.UNIQUEID_ <> nvh2.UNIQUEID_
                        )
where nvh1.PROPERTYADDRESS is null;




--- We will be trying to Break te PROPERTYADDRESS column into 2 columns ( adress, city )

-- Verify that comma is a delimiter to all the PROPERTYADDRESS values
select * 
from nashvillehousing
where PROPERTYADDRESS not like '%,%'; -- return no result


--- selecting the new columns
select PROPERTYADDRESS as full_adresse,
Trim(substr(PROPERTYADDRESS, 1                           , instr(PROPERTYADDRESS,',')-1)) as adresse, -- sub string from ( column, first letter, until (the first occurence of ',') -1 )
Trim(substr(PROPERTYADDRESS, instr(PROPERTYADDRESS,',')+1, length(PROPERTYADDRESS)))      as city     -- sub string from ( column, first (the occurence of ',')+1, lenght of column )
from nashvillehousing; -- Trim to eliminate any excess spaces before and after;

--- Create adress and city columns
-- Add Adresse Column
Alter table nashvillehousing
add Adresse VARCHAR2(100);
commit;
-- Add City Column
Alter table nashvillehousing
add City VARCHAR2(50);
commit;


--- Update te 2 new created columns 
update nashvillehousing
set Adresse =  Trim(substr(PROPERTYADDRESS, 1 , instr(PROPERTYADDRESS,',')-1)) ,
    City    =  Trim(substr(PROPERTYADDRESS, instr(PROPERTYADDRESS,',')+1, length(PROPERTYADDRESS)));
    
    
    