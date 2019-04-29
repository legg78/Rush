create or replace force view prc_ui_group_process_vw as
select
    a.id as group_id
    , c.id group_process_id
    , a.semaphore_name
    , get_text (
        i_table_name    => 'prc_group'
        , i_column_name => 'name'
        , i_object_id   => a.id
        , i_lang        => l.lang
      ) group_desc_short
    , b.id as process_id
    , get_text (
        i_table_name    => 'prc_process'
        , i_column_name => 'name'
        , i_object_id   => b.id
        , i_lang        => l.lang
      ) process_desc_short    
    , nvl(b.procedure_name, 'CONTAINER') as procedure_name
    , b.is_parallel
    , l.lang
from
    prc_group a
    , prc_process b
    , prc_group_process c
    , com_language_vw l
where
    a.id = c.group_id
    and b.id = c.process_id
order by
    a.id
    , b.id
/
