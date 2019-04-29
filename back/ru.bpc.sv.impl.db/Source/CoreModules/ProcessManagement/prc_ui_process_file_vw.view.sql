create or replace force view prc_ui_process_file_vw as
select
    b.id as file_id
    , b.process_id
    , b.file_purpose
    , s.source saver_class
    , b.saver_id
    , b.file_nature
    , b.xsd_source
    , get_text (
        i_table_name    => 'prc_file'
        , i_column_name => 'name'
        , i_object_id   => b.id
        , i_lang        => c.lang
      ) short_desc
    , get_text (
        i_table_name    => 'prc_file'
        , i_column_name => 'description'
        , i_object_id   => b.id
        , i_lang        => c.lang
      ) full_desc
    , c.lang
    , b.file_type
    , get_text (
        i_table_name     => 'prc_file_saver'
        , i_column_name  => 'name'
        , i_object_id    => s.id
        , i_lang         => c.lang
    ) saver_name
from
    prc_process_vw a
  , prc_file_vw b
  , prc_file_saver s
  , com_language_vw c
where
    a.id = b.process_id
    and s.id(+) = b.saver_id
/
