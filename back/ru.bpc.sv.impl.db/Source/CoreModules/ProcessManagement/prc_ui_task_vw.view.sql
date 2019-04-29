create or replace force view prc_ui_task_vw as
select a.id
     , a.process_id
     , a.crontab_value
     , a.is_active
     , a.repeat_period
     , a.repeat_interval
     , get_text (
           i_table_name  => 'prc_task'
         , i_column_name => 'name'
         , i_object_id   => a.id
         , i_lang        => b.lang
       ) as name
     , get_text (
           i_table_name  => 'prc_task'
         , i_column_name => 'description'
         , i_object_id   => a.id
         , i_lang        => b.lang
       ) as description
     , b.lang
     , a.is_holiday_skipped
     , a.stop_on_fatal
  from prc_task_vw a
     , com_language_vw b
/
