create or replace force view cmn_standard_vw as
select
    id
    , seqnum
    , application_plugin
    , standard_type
    , resp_code_lov_id
    , key_type_lov_id
from
    cmn_standard
/
