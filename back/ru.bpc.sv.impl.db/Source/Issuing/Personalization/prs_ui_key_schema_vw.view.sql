create or replace force view prs_ui_key_schema_vw as
select 
    n.id
    , n.inst_id
    , n.seqnum
    , get_text (
        i_table_name    => 'prs_key_schema'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) name
    , get_text (
        i_table_name    => 'prs_key_schema'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from 
    prs_key_schema n
    , com_language_vw l
where n.inst_id in (select inst_id from acm_cu_inst_vw)
/
