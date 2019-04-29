create table qrz_fired_triggers (
    sched_name          varchar2(120)
  , entry_id            varchar2(95)
  , trigger_name        varchar2(200)
  , trigger_group       varchar2(200)
  , instance_name       varchar2(200)
  , fired_time          number(13)
  , priority            number(13)
  , state               varchar2(16)
  , job_name            varchar2(200)
  , job_group           varchar2(200)
  , is_nonconcurrent    varchar2(1)
  , requests_recovery   varchar2(1)
)
/