create or replace force view ost_inst_address_vw as
select a.id
     , a.lang
     , a.country
     , a.region
     , a.city
     , a.street
     , a.house
     , a.apartment
     , a.postal_code
     , a.region_code
     , a.seqnum  
     , b.address_type
     , b.object_id inst_id
from   com_address a
     , com_address_object b
where  b.entity_type = 'ENTTINST'
and    b.address_id = a.id
/
