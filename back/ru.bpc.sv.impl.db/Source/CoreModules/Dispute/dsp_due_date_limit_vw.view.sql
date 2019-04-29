create or replace force view dsp_due_date_limit_vw as
select id
     , seqnum      
     , standard_id
     , message_type     
     , is_incoming      
     , reason_code      
     , respond_due_date 
     , resolve_due_date 
     , usage_code
  from dsp_due_date_limit
/
