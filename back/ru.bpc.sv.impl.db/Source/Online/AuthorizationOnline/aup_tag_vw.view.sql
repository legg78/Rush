create or replace force view aup_tag_vw as
select 
    n.id
    , n.tag
    , n.tag_type
    , n.seqnum
    , n.reference
    , n.db_stored
from 
    aup_tag n
/
