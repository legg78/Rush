create or replace force view com_ui_partition_table_vw (
    id
  , seqnum
  , table_name
  , partition_cycle_id
  , storage_cycle_id
  , next_partition_date
) as
select
    id
  , seqnum
  , table_name
  , partition_cycle_id
  , storage_cycle_id
  , next_partition_date
from com_partition_table
with read only
/
