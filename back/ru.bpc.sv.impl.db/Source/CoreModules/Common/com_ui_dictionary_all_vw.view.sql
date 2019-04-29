create or replace force view com_ui_dictionary_all_vw as
select 
    a.id
    , a.dict
    , a.code
    , a.is_numeric
    , a.is_editable
    , get_text (
        i_table_name    => 'com_dictionary'
        , i_column_name => 'name'
        , i_object_id   => a.id
        , i_lang        => l.lang
      ) name
    , get_text (
        i_table_name    => 'com_dictionary'
        , i_column_name => 'description'
        , i_object_id   => a.id
        , i_lang        => l.lang
      ) description
    , a.inst_id
    , a.module_code
    , l.lang
from
    com_dictionary a
    , com_language_vw l
/
