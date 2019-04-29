create or replace force view nbc_ui_fin_vw as
select
    a.id          
    , a.split_hash
    , a.status  
    , get_article_text(
        i_article => a.status
      , i_lang    => l.lang
    ) as status_desc
    , a.inst_id   
    , get_text(
        i_table_name  => 'ost_institution'
      , i_column_name => 'name'
      , i_object_id   => a.inst_id
      , i_lang        => l.lang
    ) as inst_name
    , a.network_id
    , get_text(
        i_table_name  => 'net_network'
      , i_column_name => 'name'
      , i_object_id   => a.network_id
      , i_lang        => l.lang
    ) as network_name
    , a.file_id
    , a.is_incoming
    , a.is_invalid
--    , a.is_reversal
    , a.original_id
    , a.dispute_id
    , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
    , a.mti         
    , a.record_number
    , a.msg_file_type     
    , a.participant_type    
    , a.record_type       
    , a.card_mask         
    , a.card_hash         
    , a.proc_code         
    , a.nbc_resp_code     
    , a.acq_resp_code     
    , a.iss_resp_code     
    , a.bnb_resp_code     
    , a.dispute_trans_result        
    , a.trans_amount        
    , a.sttl_amount         
    , a.crdh_bill_amount    
    , a.crdh_bill_fee       
    , a.settl_rate          
    , a.crdh_bill_rate      
    , a.system_trace_number 
    , a.local_trans_time    
    , a.local_trans_date    
    , a.settlement_date     
    , a.merchant_type       
    , a.trans_fee_amount    
    , a.acq_inst_code       
    , a.iss_inst_code       
    , a.bnb_inst_code       
    , a.rrn                 
    , a.auth_number         
    , a.resp_code           
    , a.terminal_id         
    , a.trans_currency      
    , a.settl_currency      
    , a.crdh_bill_currency  
    , a.from_account_id     
    , a.to_account_id       
    , a.nbc_fee             
    , a.acq_fee             
    , a.iss_fee             
    , a.bnb_fee             
    , l.lang
from
    nbc_fin_message a
  , nbc_card c
  , com_language_vw l
where a.id    = c.id(+)
/
