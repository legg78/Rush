create table qrz_simple_triggers(
    sched_name          varchar2(120)
  , trigger_name        varchar2(200)
  , trigger_group       varchar2(200)
  , repeat_count        number(7)
  , repeat_interval     number(12)
  , times_triggered     number(10)
)
/
