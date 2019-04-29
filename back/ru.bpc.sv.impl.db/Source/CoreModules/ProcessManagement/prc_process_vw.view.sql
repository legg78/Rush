create or replace force view prc_process_vw as
select
    a.id
    , a.procedure_name
    , a.is_parallel
    , a.inst_id
    , a.is_external
    , a.is_container
    , a.interrupt_threads
from
    prc_process a
/
