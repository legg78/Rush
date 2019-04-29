create or replace force view acq_ui_mcc_selection_vw as
select
    a.id
    , a.oper_type
    , a.priority
    , a.mcc
    , a.mcc_template_id
    , a.purpose_id
    , a.oper_reason
    , a.merchant_name_spec
    , get_article_text (
        i_article  => a.oper_type
        , i_lang   => c.lang
    ) oper_type_desc
    , c.lang
    , t.terminal_number
from
    acq_mcc_selection_vw a
    , com_language_vw c
    , acq_terminal_vw t
where (a.terminal_id is null or a.terminal_id = t.id)  
/
