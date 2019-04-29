create or replace force view rcn_ui_atm_msg_vw as
select m.id
     , m.msg_source
     , m.msg_date
     , m.operation_id
     , m.recon_msg_ref
     , m.recon_status
     , get_article_text(i_article =>  m.recon_status,i_lang => l.lang) as recon_status_name
     , m.recon_last_date
     , m.recon_inst_id
     , m.oper_type
     , m.oper_date
     , m.oper_amount
     , m.oper_currency
     , m.trace_number
     , m.acq_inst_id
     , m.card_mask
     , iss_api_token_pkg.decode_card_number(
           i_card_number => c.card_number
       ) as card_number
     , m.auth_code
     , m.is_reversal
     , m.terminal_type
     , m.terminal_number
     , m.iss_fee
     , m.acc_from
     , m.acc_to
     , l.lang
  from rcn_atm_msg m
     , rcn_card c 
     , com_language_vw l
 where m.id = c.id
/
