create or replace force view pmo_service_vw as
select
    a.id
  , a.seqnum
  , a.direction
  , a.inst_id
from
    pmo_service a
/
