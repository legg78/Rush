create or replace force view rcn_ui_cbs_msg_vw as
select m.id
     , m.recon_type
     , m.msg_source
     , m.msg_date
     , m.oper_id
     , m.recon_msg_id
     , m.recon_status
     , m.recon_date
     , m.recon_inst_id
     , m.oper_type
     , m.msg_type
     , m.sttl_type
     , m.oper_date
     , m.oper_amount
     , m.oper_currency
     , m.oper_request_amount
     , m.oper_request_currency
     , m.oper_surcharge_amount
     , m.oper_surcharge_currency
     , m.originator_refnum
     , m.network_refnum
     , m.acq_inst_bin
     , m.status
     , m.is_reversal
     , m.merchant_number
     , m.mcc
     , m.merchant_name
     , m.merchant_street
     , m.merchant_city
     , m.merchant_region
     , m.merchant_country
     , m.merchant_postcode
     , m.terminal_type
     , m.terminal_number
     , m.acq_inst_id
     , iss_api_token_pkg.decode_card_number(
           i_card_number => c.card_number
       ) as card_number
     , coalesce(m.card_mask, iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)) card_mask
     , m.card_seq_number
     , m.card_expir_date
     , m.card_country
     , m.iss_inst_id
     , m.auth_code
     , l.lang
  from rcn_cbs_msg m
     , rcn_card c 
     , com_language_vw l
 where m.id = c.id
/
