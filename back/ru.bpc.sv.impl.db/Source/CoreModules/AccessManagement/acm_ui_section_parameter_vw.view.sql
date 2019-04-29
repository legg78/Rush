create or replace force view acm_ui_section_parameter_vw as
select
    a.id
  , a.seqnum
  , a.section_id
  , a.name
  , get_text(
        i_table_name  => 'acm_section_parameter'
      , i_column_name => 'label'
      , i_object_id   => a.id
      , i_lang        => b.lang
    ) as label
  , get_text(
        i_table_name  => 'acm_section_parameter'
      , i_column_name => 'description'
      , i_object_id   => a.id
      , i_lang        => b.lang
    ) as description
  , a.data_type
  , a.lov_id
  , b.lang
from acm_section_parameter_vw a
   , com_language_vw b
/

