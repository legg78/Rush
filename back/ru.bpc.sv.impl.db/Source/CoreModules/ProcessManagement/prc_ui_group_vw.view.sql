create or replace force view prc_ui_group_vw as
select
    n.id
    , n.semaphore_name
    , get_text (
        i_table_name    => 'prc_group'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) name
    , get_text (
        i_table_name    => 'prc_group'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from
    prc_group n
    , com_language_vw l
/       
