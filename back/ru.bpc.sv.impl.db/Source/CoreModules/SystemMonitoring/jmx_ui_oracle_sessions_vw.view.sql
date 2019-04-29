create or replace force view jmx_ui_oracle_sessions_vw as
select count(1) as session_count
     , sum(decode(type, 'BACKGROUND', 0, decode(status, 'ACTIVE', 1, 0))) as session_active
     , sum(decode(type, 'BACKGROUND', 0, decode(status, 'ACTIVE', 0, 1))) as session_inactive
     , sum(decode(type, 'BACKGROUND', 1, 0)) as session_system
     , sum(decode(username, null, 0, 1)) as session_user_connected
  from v$session
/
