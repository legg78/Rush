create or replace force view prc_group_process_vw as
select
    a.id
    , a.group_id
    , a.process_id
from
    prc_group_process a
/
