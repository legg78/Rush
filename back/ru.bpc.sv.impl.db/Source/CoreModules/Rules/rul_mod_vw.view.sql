create or replace force view rul_mod_vw as
select
    a.id
  , a.scale_id
  , a.condition
  , a.priority
  , a.seqnum
from
    rul_mod a
/
