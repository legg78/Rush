create or replace force view hsm_ui_selection_vw as
select 
    n.id
    , n.seqnum
    , n.hsm_device_id
    , n.action
    , n.inst_id
    , n.mod_id
    , n.max_connection
    , n.firmware
    , get_text (
        i_table_name    => 'hsm_selection'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from 
    hsm_selection n
    , com_language_vw l
where
    n.inst_id in (select inst_id from acm_cu_inst_vw)
/
