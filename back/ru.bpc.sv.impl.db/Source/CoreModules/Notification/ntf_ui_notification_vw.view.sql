create or replace force view ntf_ui_notification_vw as
select 
    n.id
    , n.seqnum
    , n.event_type
    , n.report_id
    , n.inst_id
    , get_text (
        i_table_name    => 'ntf_notification'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) name
    , get_text (
        i_table_name    => 'ntf_notification'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from 
    ntf_notification n
    , com_language_vw l
where
    n.inst_id in (select inst_id from acm_cu_inst_vw)
/
