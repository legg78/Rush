create or replace force view jmx_ui_oracle_session_limit_vw as
select p.value as session_max
  from v$parameter p
 where p.name ='sessions'
/
