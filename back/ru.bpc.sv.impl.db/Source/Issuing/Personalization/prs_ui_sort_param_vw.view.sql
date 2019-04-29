create or replace force view prs_ui_sort_param_vw as
select 
    n.id
    , n.name
    , get_text (
        i_table_name    => 'prs_sort_param'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from 
    prs_sort_param n
    , com_language_vw l
/
