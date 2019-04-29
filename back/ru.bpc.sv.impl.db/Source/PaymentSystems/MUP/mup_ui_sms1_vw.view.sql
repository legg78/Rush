create or replace force view mup_ui_sms1_vw as
select s.id
     , s.file_id
     , s.record_number
     , s.status
     , get_article_text(i_article => s.status, i_lang => l.lang) status_desc 
     , s.record_type
     , s.iss_acq
     , s.isa_ind
     , s.giv_flag
     , s.affiliate_bin
     , s.sttl_date
     , s.val_code
     , s.refnum
     , s.trace_num
     , s.req_msg_type
     , s.resp_code
     , s.proc_code
     , s.msg_reason_code
     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) card_number
     , s.trxn_ind
     , s.sttl_curr_code
     , s.sttl_amount
     , s.sttl_sign
     , s.reserved
     , s.spend_qualified_ind
     , s.surcharge_amount
     , s.surcharge_sign
     , s.inst_id
     , get_text ( 
           i_table_name  => 'ost_institution'
         , i_column_name => 'name'
         , i_object_id   => s.inst_id
         , i_lang        => l.lang) inst_name
     , l.lang 
  from mup_sms1 s
     , mup_card c
     , com_language_vw l  
 where s.id = c.id
/
drop view mup_ui_sms1_vw
/
