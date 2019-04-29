create or replace force view com_ui_appearance_vw as
select
    a.id
    , a.seqnum
    , a.entity_type
    , a.object_id
    , a.css_class
    , a.object_reference
from
    com_appearance a
/ 
