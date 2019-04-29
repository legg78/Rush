create or replace force view aup_ui_tag_vw as
select 
    n.id
    , n.tag
    , n.tag_type
    , n.seqnum
    , n.reference
    , n.db_stored
    , get_text (
        i_table_name    => 'aup_tag'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) name
    , get_text (
        i_table_name    => 'aup_tag'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from 
    aup_tag n
    , com_language_vw l
/
