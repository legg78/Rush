create or replace force view rul_ui_name_part_prpt_value_vw as
select
    n.id
    , n.part_id
    , n.property_id
    , n.property_value
from rul_name_part_prpt_value n
/
