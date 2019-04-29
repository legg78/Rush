create or replace force view mcw_reject_code_vw as
select 
   id
   , reject_data_id
   , de_number
   , severity_code
   , message_code
   , subfield_id
   , is_from_orig_msg
from mcw_reject_code
/
 