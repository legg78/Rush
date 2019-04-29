create or replace force view cup_ui_fee_vw as
select f.id
     , f.fee_type
     , f.acquirer_iin
     , f.forwarding_iin
     , f.sys_trace_num
     , f.transmission_date_time
     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
     , f.merchant_number
     , f.auth_resp_code
     , f.is_reversal
     , f.trans_type_id
     , f.receiving_iin
     , f.issuer_iin
     , f.sttl_currency
     , f.sttl_sign
     , f.sttl_amount
     , f.interchange_fee_sign
     , f.interchange_fee_amount
     , f.reimbursement_fee_sign
     , f.reimbursement_fee_amount
     , f.service_fee_sign
     , f.service_fee_amount
     , f.file_id
     , f.fin_msg_id
     , f.match_status
     , get_article_text ( i_article => f.match_status
                        , i_lang    => l.lang
       ) match_status_desc
     , f.inst_id
     , get_text ( i_table_name  => 'ost_institution'
                , i_column_name => 'name'
                , i_object_id   => f.inst_id
                , i_lang        => l.lang
       ) inst_name
     , f.reason_code
  from cup_fee f
     , cup_card c
     , com_language_vw l
 where f.id = c.id(+)
/
