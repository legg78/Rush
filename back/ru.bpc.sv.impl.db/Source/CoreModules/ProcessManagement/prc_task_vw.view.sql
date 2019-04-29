create or replace force view prc_task_vw as
select a.id
     , a.process_id
     , a.crontab_value
     , a.is_active
     , a.repeat_period
     , a.repeat_interval
     , a.is_holiday_skipped
     , a.stop_on_fatal
  from prc_task a
/
