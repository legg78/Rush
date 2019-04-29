create or replace force view amx_ui_add_vw as
select 
    a.id           
    , a.fin_id     
    , a.file_id    
    , a.is_incoming
    , a.mtid       
    , a.addenda_type
    , a.format_code 
    , a.message_seq_number
    , a.transaction_id    
    , a.message_number    
    , a.reject_reason_code 
    , c.icc_version_name  
    , c.icc_version_number
    , c.emv_9f26  
    , c.emv_9f10  
    , c.emv_9f37  
    , c.emv_9f36  
    , c.emv_95    
    , c.emv_9a    
    , c.emv_9c    
    , c.emv_9f02  
    , c.emv_5f2a  
    , c.emv_9f1a  
    , c.emv_82    
    , c.emv_9f03  
    , c.emv_5f34  
    , c.emv_9f27  
 from amx_add a
    , amx_add_chip c
where a.id = c.id(+)    
/
