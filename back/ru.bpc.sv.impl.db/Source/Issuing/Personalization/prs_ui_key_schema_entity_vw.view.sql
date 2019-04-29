create or replace force view prs_ui_key_schema_entity_vw as
select 
    n.id
    , n.seqnum
    , n.key_schema_id
    , n.key_type
    , n.entity_type
from 
    prs_key_schema_entity n
/
