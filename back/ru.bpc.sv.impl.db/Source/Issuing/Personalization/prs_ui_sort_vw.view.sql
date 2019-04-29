create or replace force view prs_ui_sort_vw as
select 
    n.id
    , n.seqnum
    , n.inst_id
    , n.condition
    , get_text (
          i_table_name  => 'prs_sort'
        , i_column_name => 'label'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) as label
    , get_text (
          i_table_name  => 'prs_sort'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) as description
    , l.lang
from 
    prs_sort n
    , com_language_vw l
where
    n.inst_id in (select inst_id from acm_cu_inst_vw)
/
