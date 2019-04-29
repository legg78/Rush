create or replace force view vis_ui_session_vw 
as 
  select f.id
       , s.id as session_id
       , f.file_date       as created
       , f.file_name       as filename
       , s.process_id      as process  
       , case when s.result_code = 'PRSR0002' then 1 else 0 end as result
       , s.processed       as succeed
       , s.estimated_count as total
    from vis_file v
       , prc_session_file f 
       , prc_session s
   where v.session_file_id = f.id
     and s.id              = f.session_id 
order by s.id    
/