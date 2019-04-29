create or replace force view jcb_ui_common_operation_vw as 
select 
    o.id            
    , o.merchant_country acq_country   
    , o.acq_inst_bin  
    , o.acq_inst_id   
    , o.acq_network_id
    , o.merchant_region acq_region    
    , null calc_status   
    , o.host_date     
    , o.is_reversal   
    , o.card_country iss_card_country
    , o.card_mask iss_card_number 
    , o.iss_inst_id     
    , o.iss_network_id  
    , o.mcc             
    , o.merchant_city   
    , o.merchant_country
    , o.merchant_name   
    , o.merchant_number 
    , o.merchant_postcode
    , o.merchant_region  
    , o.merchant_street  
    , o.msg_type         
    , o.network_refnum   
    , o.oper_amount      
    , o.oper_currency    
    , o.oper_date        
    , o.oper_request_amount 
    , o.oper_surcharge_amount
    , o.oper_type            
    , o.session_id           
    , o.status               
    , o.sttl_amount          
    , o.sttl_currency        
    , o.sttl_type            
    , o.terminal_number      
    , o.terminal_type        
 from opr_operation_participant_vw o
    , jcb_fin_message f
where o.id = f.id
/
