create table prc_task (
    id                   number(8) not null
    , process_id         number(8)
    , crontab_value      varchar2(200)
    , is_active          number(1)
    , repeat_period      number(4)
    , repeat_interval    number(4)
)
/

comment on table prc_task is 'Launch schedule processes'
/
comment on column prc_task.id is 'Record identifier'
/
comment on column prc_task.process_id is 'Process identifier'
/
comment on column prc_task.crontab_value  is 'Task schedule in unix cron format'
/
comment on column prc_task.is_active is 'Flag if task is active'
/
comment on column prc_task.repeat_period is 'Time period when system trying to run process (in minutes).'
/
comment on column prc_task.repeat_interval is 'Interval between attempts to run process (in minutes).'
/
alter table prc_task add (is_holiday_skipped number(1)) 
/
comment on column prc_task.is_holiday_skipped is 'Flag if holiday skipped in schedule.'
/
alter table prc_task add stop_on_fatal number(1)
/
comment on column prc_task.stop_on_fatal is 'Flag if stop on fatal error.'
/

