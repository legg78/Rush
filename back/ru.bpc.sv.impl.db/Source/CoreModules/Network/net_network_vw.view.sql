create or replace force view net_network_vw as
select 
    n.id
  , n.bin_table_scan_priority
  , n.inst_id
  , n.seqnum
from net_network n
/
