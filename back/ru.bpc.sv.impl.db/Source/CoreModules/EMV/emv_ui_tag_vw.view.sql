create or replace force view emv_ui_tag_vw as
select 
    n.id
    , n.tag
    , n.min_length
    , n.max_length
    , n.data_type
    , n.data_format
    , n.default_value
    , n.tag_type
    , get_text (
        i_table_name    => 'emv_tag'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from 
    emv_tag n
    , com_language_vw l
/
