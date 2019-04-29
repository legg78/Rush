create or replace force view aup_api_tag_vw as
select
    a.id
  , a.tag
  , a.tag_type
  , a.seqnum
  , a.reference
  , a.db_stored
from
    aup_tag_vw a
/

