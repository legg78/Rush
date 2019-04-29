create or replace force view nbc_ui_file_vw as
select
    a.id              
  , a.file_type       
  , a.is_incoming     
  , a.inst_id         
  , a.network_id      
  , a.bin_number      
  , a.sttl_date       
  , a.proc_date       
  , a.file_number     
  , a.participant_type
  , a.session_file_id 
  , a.records_total
  , a.md5
from nbc_file a
/
