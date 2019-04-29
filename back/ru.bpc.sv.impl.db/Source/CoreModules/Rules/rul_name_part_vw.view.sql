create or replace force view rul_name_part_vw as
select
    a.id
  , a.format_id
  , a.part_order
  , a.base_value_type
  , a.base_value
  , a.transformation_type
  , a.transformation_mask
  , a.part_length
  , a.pad_type
  , a.pad_string
  , a.check_part
from
    rul_name_part a
/
