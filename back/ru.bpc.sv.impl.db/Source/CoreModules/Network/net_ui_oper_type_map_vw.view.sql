create or replace force view net_ui_oper_type_map_vw as
select
    n.id
    , n.seqnum
    , n.standard_id
    , n.network_oper_type
    , n.priority
    , n.oper_type
from net_oper_type_map n
/
