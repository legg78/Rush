create global temporary table prc_container_schedule_tmp
(
    container_id        number(8)
  , container_name      varchar2(64)
  , exec_time           date
  , is_holiday_skipped  number(1)
  , is_active           number(1)
  , start_time          date
  , end_time            date
  , status              varchar2(64)
)
on commit delete rows
/
comment on table prc_container_schedule_tmp is 'temporary date for process schedule'
/
comment on column prc_container_schedule_tmp.container_id is 'Container identifier'
/
comment on column prc_container_schedule_tmp.container_name is 'Container name'
/
comment on column prc_container_schedule_tmp.exec_time is 'Execution time'
/
comment on column prc_container_schedule_tmp.is_holiday_skipped is 'Skip holiday flag'
/
comment on column prc_container_schedule_tmp.is_active is 'Activity flag'
/
comment on column prc_container_schedule_tmp.start_time is 'Start date'
/
comment on column prc_container_schedule_tmp.end_time is 'End date'
/
comment on column prc_container_schedule_tmp.status is 'Status of execution'
/
drop table prc_container_schedule_tmp
/
