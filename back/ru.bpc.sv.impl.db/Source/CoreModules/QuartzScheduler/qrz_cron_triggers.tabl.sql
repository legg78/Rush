create table qrz_cron_triggers(
    sched_name          varchar2(120)
  , trigger_name        varchar2(200)
  , trigger_group       varchar2(200)
  , cron_expression     varchar2(120)
  , time_zone_id        varchar2(80)
)
/