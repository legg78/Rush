create or replace force view rul_name_format_vw as
select
    a.id
  , a.inst_id
  , a.seqnum
  , a.entity_type
  , a.name_length
  , a.pad_type
  , a.pad_string
  , a.check_algorithm
  , a.check_base_position
  , a.check_base_length
  , a.check_position
  , a.index_range_id
  , a.check_name
from
    rul_name_format a
/
