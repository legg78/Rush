create or replace force view prc_ui_container_vw as
select
    n.id
  , nvl(n.procedure_name, 'CONTAINER') as procedure_name
  , n.is_parallel
  , n.inst_id
  , n.is_external
  , n.is_container
  , get_text(
        i_table_name  => 'prc_process'
      , i_column_name => 'name'
      , i_object_id   => n.id
      , i_lang        => l.lang
    ) as name
  , get_text(
        i_table_name  => 'prc_process'
      , i_column_name => 'description'
      , i_object_id   => n.id
      , i_lang        => l.lang
    ) as description
  , l.lang
from
    prc_process n
  , com_language_vw l
where
    n.is_container = 1
and
    n.inst_id in (select inst_id from acm_cu_inst_vw)
/