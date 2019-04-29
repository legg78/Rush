create or replace force view com_appearance_vw as
select
    id
    , seqnum
    , entity_type
    , object_id
    , css_class
    , object_reference
from
    com_appearance
/