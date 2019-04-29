create or replace force view ecm_ui_3ds_message_vw as
select id
     , message_type  
     , message_date
     , message_body
     , session_uuid
     , message_uuid
     , substr(status, 5, 1) status
     , account_id
     , card_id
     , version
     , message_originator
  from ecm_3ds_message
/
     
