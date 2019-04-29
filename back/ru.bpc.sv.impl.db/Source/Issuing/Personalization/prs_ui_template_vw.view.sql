create or replace force view prs_ui_template_vw as
select 
    n.id
    , n.seqnum
    , n.method_id
    , n.entity_type
    , n.format_id
    , n.mod_id
from 
    prs_template n
/
