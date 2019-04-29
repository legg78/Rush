create or replace force view rul_name_transform_vw as
select
    a.id
  , a.seqnum
  , a.function_name
  , a.inst_id
from
    rul_name_transform a
/

