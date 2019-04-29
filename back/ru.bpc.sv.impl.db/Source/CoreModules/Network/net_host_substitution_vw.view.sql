create or replace force view net_host_substitution_vw as
select id                   
     , seqnum
     , oper_type
     , terminal_type
     , pan_low
     , pan_high
     , acq_inst_id
     , acq_network_id
     , card_inst_id
     , card_network_id  
     , iss_inst_id  
     , iss_network_id      
     , priority       
     , substitution_inst_id     
     , substitution_network_id 
     , msg_type
     , oper_reason
     , oper_currency
     , merchant_array_id
     , terminal_array_id  
     , card_country
  from net_host_substitution
/
