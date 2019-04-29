create or replace force view jcb_ui_session_vw as 
select f.id
     , s.id as session_id
     , f.file_date as created
     , f.file_name filename
     , s.process_id process  
     , case when s.result_code = 'PRSR0002' then 1 else 0 end result
     , s.processed succeed
     , s.estimated_count total
  from jcb_file l
     , prc_session_file f 
     , prc_session s
 where l.session_file_id = f.id
   and s.id = f.session_id 
 order by s.id    
/
