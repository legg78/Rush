create or replace force view emv_linked_script_vw as
select 
    n.auth_id
    , n.script_id
from 
    emv_linked_script n
/
