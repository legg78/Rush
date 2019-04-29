create or replace force view dsp_list_condition_vw as
select 
    n.id
    , n.init_rule
    , n.gen_rule
    , n.func_order
    , n.mod_id
    , n.is_online
from 
    dsp_list_condition n
/
