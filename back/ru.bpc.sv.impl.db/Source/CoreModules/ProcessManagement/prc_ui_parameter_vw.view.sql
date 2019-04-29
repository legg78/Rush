create or replace force view prc_ui_parameter_vw as
select 
    n.id
  , n.param_name
  , n.data_type
  , n.lov_id
  , n.parent_id
  , (select p.param_name from prc_parameter p where p.id = n.parent_id) as parent_name
  , get_text(
        i_table_name  => 'prc_parameter'
      , i_column_name => 'label'
      , i_object_id   => n.id
      , i_lang        => l.lang
    ) as label
  , get_text(
        i_table_name  => 'prc_parameter'
      , i_column_name => 'description'
      , i_object_id   => n.id
      , i_lang        => l.lang
    ) as description
  , get_text(
        i_table_name  => 'prc_parameter'
      , i_column_name => 'label'
      , i_object_id   => n.parent_id
      , i_lang        => l.lang
    ) as parent_label
  , get_text(
        i_table_name  => 'prc_parameter'
      , i_column_name => 'description'
      , i_object_id   => n.parent_id
      , i_lang        => l.lang
    ) as parent_description
  , l.lang
from
    prc_parameter n
  , com_language_vw l
/
