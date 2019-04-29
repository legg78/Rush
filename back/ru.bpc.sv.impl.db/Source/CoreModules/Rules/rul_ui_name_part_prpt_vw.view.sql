create or replace force view rul_ui_name_part_prpt_vw as
select
    n.id
    , n.entity_type
    , n.property_name
from rul_name_part_prpt n
/

