create or replace force view net_ui_bin_range_vw as
select
    r.pan_low
  , r.pan_high
  , r.priority
  , r.card_type_id
  , r.country
  , r.pan_length
  , r.card_network_id
  , r.card_inst_id
  , r.iss_network_id
  , r.iss_inst_id  
from
    net_bin_range r
where r.card_inst_id in (select inst_id from acm_cu_inst_vw)
  and r.iss_inst_id in (select inst_id from acm_cu_inst_vw)
/
