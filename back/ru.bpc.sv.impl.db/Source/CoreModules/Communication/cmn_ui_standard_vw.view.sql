create or replace force view cmn_ui_standard_vw as
select
    a.id
    , a.seqnum
    , a.application_plugin
    , a.standard_type
    , a.resp_code_lov_id
    , a.key_type_lov_id
    , get_text('cmn_standard', 'label', a.id, b.lang) label
    , get_text('cmn_standard', 'description', a.id, b.lang) description
    , b.lang
from
    cmn_standard a
    , com_language_vw b
/
