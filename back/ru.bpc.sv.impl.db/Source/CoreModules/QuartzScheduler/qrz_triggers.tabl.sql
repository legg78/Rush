create table qrz_triggers(
    sched_name          varchar2(120)
  , trigger_name        varchar2(200)
  , trigger_group       varchar2(200)
  , job_name            varchar2(200) 
  , job_group           varchar2(200)
  , description         varchar2(250)
  , next_fire_time      number(13)
  , prev_fire_time      number(13)
  , priority            number(13)
  , trigger_state       varchar2(16)
  , trigger_type        varchar2(8)
  , start_time          number(13)
  , end_time            number(13)
  , calendar_name       varchar2(200)
  , misfire_instr       number(2)
  , job_data            blob
)
/
