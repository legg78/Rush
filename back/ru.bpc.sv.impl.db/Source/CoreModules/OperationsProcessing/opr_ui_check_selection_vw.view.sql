create or replace force view opr_ui_check_selection_vw as
select 
    n.id
    , n.seqnum
    , n.oper_type
    , n.msg_type
    , n.party_type
    , n.inst_id
    , n.network_id
    , n.check_group_id
    , n.exec_order
    , l.lang
from 
    opr_check_selection n
  , com_language_vw l
/
