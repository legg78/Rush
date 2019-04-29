create or replace force view acm_ui_widget_param_vw as
select 
    n.id
    , n.seqnum
    , n.param_name
    , n.data_type
    , n.lov_id
    , n.widget_id
    , get_text (
        i_table_name    => 'acm_widget_param'
        , i_column_name => 'label'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) label
    , l.lang
from 
    acm_widget_param n
    , com_language_vw l
/
