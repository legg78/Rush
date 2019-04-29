create or replace force view emv_application_vw as
select 
    n.id
    , n.seqnum
    , n.aid
    , n.mod_id
    , n.id_owner
    , n.appl_scheme_id
    , n.pix
from 
    emv_application n
/
