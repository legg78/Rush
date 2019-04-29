create or replace force view mcw_mcc_vw as
select 
    n.mcc
    , n.cab_type
    , n.cab_program
from 
    mcw_mcc n
/
