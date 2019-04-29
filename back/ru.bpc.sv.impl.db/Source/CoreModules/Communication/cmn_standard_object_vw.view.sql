create or replace force view cmn_standard_object_vw as
select id
     , entity_type
     , object_id
     , standard_id
     , standard_type
from cmn_standard_object
/
