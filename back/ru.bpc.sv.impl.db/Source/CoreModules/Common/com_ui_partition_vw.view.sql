create or replace force view com_ui_partition_vw (
    id
    , table_name
    , partition_name
    , start_date
    , end_date
    , drop_date
) as
select
    id
    , table_name
    , partition_name
    , start_date
    , end_date
    , drop_date
from com_partition
with read only
/
