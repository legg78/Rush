create or replace force view amx_rejected_detail_vw as
select 
    d.reject_message_id  
    , d.order_code          
    , d.reject_reason_code    
from 
  amx_rejected_detail d
/
