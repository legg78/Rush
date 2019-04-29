create or replace force view emv_ui_appl_scheme_vw as
select 
    n.id
    , n.seqnum
    , n.inst_id
    , n.type
    , get_text (
        i_table_name    => 'emv_appl_scheme'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) name
    , get_text (
        i_table_name    => 'emv_appl_scheme'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from 
    emv_appl_scheme n
    , com_language_vw l
where
    n.inst_id in (select inst_id from acm_cu_inst_vw)
/
