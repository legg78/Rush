create or replace force view rul_name_index_range_vw as
select a.id
     , a.inst_id
     , a.entity_type
     , a.algorithm
     , a.low_value
     , a.high_value
     , a.current_value
from rul_name_index_range a
/
