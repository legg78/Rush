create or replace force view fcl_cycle_type_vw as
select
    a.id
    , a.cycle_type
    , a.is_repeating
    , a.is_standard
    , a.cycle_calc_start_date
    , a.cycle_calc_date_type
from
    fcl_cycle_type a
/
