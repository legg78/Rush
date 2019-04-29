create or replace force view adt_trail_vw as
select id
     , entity_type
     , object_id
     , action_type
     , action_time
     , user_id
     , priv_id
     , session_id
     , status
from adt_trail
/
