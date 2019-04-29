create or replace force view atm_status_log_vw as
select
    a.terminal_id
    , a.change_date
    , a.status
    , a.atm_part_type
from
    atm_status_log a
/

