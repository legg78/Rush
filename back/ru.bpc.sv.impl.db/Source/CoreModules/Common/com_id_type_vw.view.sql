create or replace force view com_id_type_vw as 
select a.id
     , a.seqnum
     , a.entity_type
     , a.inst_id
     , a.id_type
from com_id_type a
/
