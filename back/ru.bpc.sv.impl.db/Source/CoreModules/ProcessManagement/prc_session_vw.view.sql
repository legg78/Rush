create or replace force view prc_session_vw as
select
    a.id
    , a.process_id
    , a.parent_id
    , a.start_time
    , a.end_time
    , a.processed
    , a.rejected
    , a.excepted
    , a.user_id
    , a.result_code
    , a.inst_id
    , a.sttl_day
    , a.sttl_date
    , a.thread_count   
    , a.estimated_count
    , a.ip_address
    , a.container_id
    , a.measure
from
    prc_session a
/
