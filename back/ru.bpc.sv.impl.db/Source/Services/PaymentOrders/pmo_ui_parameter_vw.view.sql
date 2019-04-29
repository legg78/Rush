create or replace force view pmo_ui_parameter_vw as
select
    a.id
  , a.seqnum
  , a.param_name
  , get_text(
        i_table_name  => 'pmo_parameter'
      , i_column_name => 'label'
      , i_object_id   => a.id
      , i_lang        => b.lang
    ) as label
  , get_text(
        i_table_name  => 'pmo_parameter'
      , i_column_name => 'description'
      , i_object_id   => a.id
      , i_lang        => b.lang
    ) as description
  , a.data_type
  , a.lov_id
  , a.pattern
  , a.tag_id
  , a.param_function
  , b.lang
from
    pmo_parameter_vw a
  , com_language_vw b
/
