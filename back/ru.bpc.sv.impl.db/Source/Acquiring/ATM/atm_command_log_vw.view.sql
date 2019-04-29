create or replace force view atm_command_log_vw as
select terminal_id
     , user_id
     , command_date
     , command
     , command_result
  from atm_command_log a
/ 