create or replace force view evt_status_log_vw
as
select id
     , entity_type
     , object_id
     , event_type
     , initiator
     , reason
     , status
     , change_date
     , user_id
     , session_id
     , event_date
  from evt_status_log
/
