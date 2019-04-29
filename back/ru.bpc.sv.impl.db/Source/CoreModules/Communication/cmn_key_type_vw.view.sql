create or replace force view cmn_key_type_vw as
select
    id
    , standard_id
    , seqnum
    , key_type
    , standard_key_type
from
    cmn_key_type
/
