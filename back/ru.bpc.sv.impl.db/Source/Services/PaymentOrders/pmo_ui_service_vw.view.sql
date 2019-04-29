create or replace force view pmo_ui_service_vw as
select
    a.id
  , a.seqnum
  , a.direction
  , get_text(
        i_table_name  => 'pmo_service'
      , i_column_name => 'label'
      , i_object_id   => a.id
      , i_lang        => b.lang
    ) as label
  , get_text(
        i_table_name  => 'pmo_service'
      , i_column_name => 'description'
      , i_object_id   => a.id
      , i_lang        => b.lang
    ) as description
  , get_text(
        i_table_name  => 'pmo_service'
      , i_column_name => 'short_name'
      , i_object_id   => a.id
      , i_lang        => b.lang
    ) as short_name
  , b.lang
  , a.inst_id
from
    pmo_service_vw a
  , com_language_vw b
where a.inst_id in (select inst_id from acm_cu_inst_vw)
/
