create or replace force view amx_ui_file_vw as
select
    a.id                   
    , a.is_incoming            
    , a.is_rejected                
    , a.network_id                  
    , a.transmittal_date       
    , a.inst_id                    
    , a.forw_inst_code             
    , a.receiv_inst_code           
    , a.action_code                
    , a.file_number            
    , a.reject_code            
    , a.msg_total              
    , a.credit_count           
    , a.debit_count            
    , a.credit_amount           
    , a.debit_amount            
    , a.total_amount                
    , a.receipt_file_id        
    , a.reject_message_id   
    , a.session_file_id
    , a.hash_total_amount
from amx_file a
/
