create or replace force view com_partition_table_vw as
select
  p.id
  , p.seqnum              
  , p.table_name          
  , p.partition_cycle_id  
  , p.storage_cycle_id    
  , p.next_partition_date
from com_partition_table p
/