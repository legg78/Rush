create or replace force view cup_ui_audit_trailer_vw as
select a.id
     , a.acquirer_iin
     , a.forwarding_iin
     , a.sys_trace_num
     , a.transmission_date_time
     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
     , a.trans_amount
     , a.message_type
     , a.proc_func_code
     , a.mcc
     , a.terminal_number
     , a.merchant_number
     , a.merchant_name
     , a.rrn
     , a.pos_cond_code
     , a.auth_resp_code
     , a.receiving_iin
     , a.orig_sys_trace_num
     , a.trans_resp_code
     , a.trans_currency
     , a.pos_entry_mode
     , a.sttl_currency
     , a.sttl_amount
     , a.sttl_exch_rate
     , a.sttl_date
     , a.exchange_date
     , a.cardholder_acc_currency
     , a.cardholder_bill_amount
     , a.cardholder_exch_rate
     , a.receivable_fee
     , a.payable_fee
     , a.billing_currency
     , a.billing_exch_rate
     , a.file_id
     , a.inst_id
     , get_text ( i_table_name  => 'ost_institution'
                , i_column_name => 'name'
                , i_object_id   => a.inst_id
                , i_lang        => l.lang
       ) inst_name
     , a.match_status
     , get_article_text ( i_article => a.match_status
                        , i_lang    => l.lang
       ) match_status_desc
     , a.fin_msg_id
  from cup_audit_trailer a
     , cup_card c
     , com_language_vw l
 where a.id = c.id(+)
/
