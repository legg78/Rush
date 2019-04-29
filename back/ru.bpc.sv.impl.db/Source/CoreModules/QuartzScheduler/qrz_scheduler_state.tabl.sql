create table qrz_scheduler_state(
    sched_name          varchar(120)
  , instance_name       varchar2(200)
  , last_checkin_time   number(13)
  , checkin_interval    number(13)
)
/