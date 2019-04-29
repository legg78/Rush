create or replace force view acc_account_type_entity_vw as
select a.id
     , a.seqnum
     , a.account_type
     , a.inst_id
     , a.entity_type
from acc_account_type_entity a
/
