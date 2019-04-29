create or replace force view rul_ui_name_index_pool_vw as
select
    a.id
  , a.index_range_id
  , a.value
  , a.is_used
  , a.partition_key
from
    rul_name_index_pool a
/
