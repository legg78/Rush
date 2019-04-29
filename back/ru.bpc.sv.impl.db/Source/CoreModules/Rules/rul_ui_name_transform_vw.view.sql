create or replace force view rul_ui_name_transform_vw as
select
    a.id
  , a.seqnum
  , a.function_name
  , b.lang
  , a.inst_id
  , get_text(
        i_table_name  => 'rul_name_transform'
      , i_column_name => 'description'
      , i_object_id   => a.id
      , i_lang        => b.lang) as description
from
    rul_name_transform a
  , com_language_vw    b
where
    a.inst_id in (select inst_id from acm_cu_inst_vw)
/
