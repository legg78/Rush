create or replace force view mcw_cab_program_ird_vw as
select 
    n.arrangement_type
    , n.arrangement_code
    , n.cab_program
    , n.brand
    , n.ird
from 
    mcw_cab_program_ird n
/
