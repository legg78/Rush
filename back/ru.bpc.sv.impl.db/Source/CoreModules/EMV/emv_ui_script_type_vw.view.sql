create or replace force view emv_ui_script_type_vw as
select 
    n.id
    , n.seqnum
    , n.type
    , n.priority
    , n.mac
    , n.tag_71
    , n.tag_72
    , n.condition
    , n.retransmission
    , n.repeat_count
    , n.class_byte
    , n.instruction_byte
    , n.parameter1
    , n.parameter2
    , n.req_length_data
    , n.is_used_by_user
    , n.form_url
    , com_api_dictionary_pkg.get_article_text(i_article => n.type, i_lang => l.lang) script_type_name
    , l.lang
from 
    emv_script_type n
    , com_language_vw l
/
