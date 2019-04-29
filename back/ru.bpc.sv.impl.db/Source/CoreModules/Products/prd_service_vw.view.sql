create or replace force view prd_service_vw as
select
    n.id
  , n.seqnum
  , n.service_type_id
  , n.template_appl_id
  , n.inst_id
  , n.status
  , n.service_number
  , n.split_hash
from
    prd_service n
/
