create or replace force view aup_tag_value_vw as
select
    v.auth_id
  , v.tag_id
  , v.tag_value
  , v.seq_number
from
    aup_tag_value v
/
