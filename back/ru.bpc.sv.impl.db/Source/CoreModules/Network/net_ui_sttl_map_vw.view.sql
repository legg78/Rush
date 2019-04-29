create or replace force view net_ui_sttl_map_vw as
select a.id
     , a.seqnum
     , a.iss_inst_id
     , a.iss_network_id
     , a.acq_inst_id
     , a.acq_network_id
     , a.card_inst_id
     , a.card_network_id
     , a.mod_id
     , a.priority
     , a.sttl_type
     , a.match_status
     , a.oper_type
from net_sttl_map a
/
