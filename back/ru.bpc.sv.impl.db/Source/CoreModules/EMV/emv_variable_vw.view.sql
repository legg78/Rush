create or replace force view emv_variable_vw as
select 
    n.id
    , n.seqnum
    , n.application_id
    , n.variable_type
    , n.profile
from 
    emv_variable n
/
