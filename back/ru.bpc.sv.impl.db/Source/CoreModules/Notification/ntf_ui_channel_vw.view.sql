create or replace force view ntf_ui_channel_vw as
select 
    n.id
    , n.address_pattern
    , n.mess_max_length
    , n.address_source
    , get_text (
        i_table_name    => 'ntf_channel'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) name
    , get_text (
        i_table_name    => 'ntf_channel'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from 
    ntf_channel n
    , com_language_vw l
/
