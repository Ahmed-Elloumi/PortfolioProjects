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
    
    

---- Extracting all the informations from OWNERADDRESS column ( owner_adress, owner_city, owner_state ):
    -- Example : " 1808  FOX CHASE DR, GOODLETTSVILLE, TN " --> Extract TN wich is always after the second comma
select OWNERADDRESS, 
trim(substr(OWNERADDRESS,1, instr(OWNERADDRESS,',',1)-1)) as owner_Adresse,
substr(OWNERADDRESS,instr(OWNERADDRESS,',',1,1)+1 /*start from the position of first comma*/, instr(substr(OWNERADDRESS,instr(OWNERADDRESS,',',1,1)+1, length(OWNERADDRESS)),',')-1 /*go from 1st comma pos until the second one*/ ) as owner_city, 
substr(OWNERADDRESS,instr(OWNERADDRESS,',',1,2)+1, length(OWNERADDRESS)) as owner_state
from nashvillehousing;


--- Create 3 new  columns ( owner_adress, owner_city, owner_state )
-- Add owner_adress Column
Alter table nashvillehousing
add owner_adress VARCHAR2(100);

-- Add owner_city Column
Alter table nashvillehousing
add owner_city VARCHAR2(50);

-- Add owner_state Column
Alter table nashvillehousing
add owner_state VARCHAR2(25);

commit;

--- Update te 3 new created columns 
update nashvillehousing
set owner_adress =  Trim(substr(OWNERADDRESS,1, instr(OWNERADDRESS,',',1)-1)) ,
    owner_city    =  Trim(substr(OWNERADDRESS,instr(OWNERADDRESS,',',1,1)+1 , instr(substr(OWNERADDRESS,instr(OWNERADDRESS,',',1,1)+1, length(OWNERADDRESS)),',')-1 )),
    owner_state    =  Trim(substr(OWNERADDRESS,instr(OWNERADDRESS,',',1,2)+1, length(OWNERADDRESS)));
    
    
    