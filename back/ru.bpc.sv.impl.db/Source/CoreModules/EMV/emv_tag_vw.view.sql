create or replace force view emv_tag_vw as
select 
    n.id
    , n.tag
    , n.min_length
    , n.max_length
    , n.data_type
    , n.data_format
    , n.default_value
    , n.tag_type
from 
    emv_tag n
/
