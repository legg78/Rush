create or replace force view acc_ui_account_type_entity_vw as
select
    id
  , seqnum
  , account_type
  , inst_id
  , entity_type
from
    acc_account_type_entity_vw
where
    inst_id in (select inst_id from acm_cu_inst_vw)
/
