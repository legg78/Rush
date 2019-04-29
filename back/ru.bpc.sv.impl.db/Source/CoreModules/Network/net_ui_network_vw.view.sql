create or replace force view net_ui_network_vw as
select
    n.id
  , n.seqnum
  , n.inst_id
  , n.bin_table_scan_priority
  , get_text (
      i_table_name    => 'net_network'
    , i_column_name => 'name'
    , i_object_id   => n.id
    , i_lang        => l.lang
    ) as name
  , get_text (
      i_table_name    => 'net_network'
    , i_column_name => 'description'
    , i_object_id   => n.id
    , i_lang        => l.lang
    ) as full_desc
  , l.lang
from
    net_network n
  , com_language_vw l
where n.inst_id in (select inst_id from acm_cu_inst_vw)
/

