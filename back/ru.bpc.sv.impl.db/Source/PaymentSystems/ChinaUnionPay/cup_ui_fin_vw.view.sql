create or replace force view cup_ui_fin_vw as
select a.id
     , a.status
     , get_article_text ( i_article => a.status
                        , i_lang    => l.lang
       ) status_desc
     , a.file_id
     --, a.batch_id
     , a.msg_number
     , a.is_reversal
     , a.is_incoming
     , a.is_rejected
     , a.is_invalid
     , a.rrn
     , a.inst_id
     , get_text ( i_table_name  => 'ost_institution'
                , i_column_name => 'name'
                , i_object_id   => a.inst_id
                , i_lang        => l.lang
       ) inst_name
     , a.network_id
     , get_text ( i_table_name  => 'net_network'
                , i_column_name => 'name'
                , i_object_id   => a.network_id
                , i_lang        => l.lang
       ) network_name
     , a.host_inst_id
     , get_text ( i_table_name  => 'ost_institution'
                , i_column_name => 'name'
                , i_object_id   => a.inst_id
                , i_lang        => l.lang
       ) host_inst_name
     , a.collect_only_flag
     , a.merchant_number   as acceptor_id_code
     , a.acquirer_iin      as agency_id
     , a.trans_amount      as amt_tran
     , a.app_version_no
     , a.appl_charact
     , a.appl_crypt
     , a.auth_amount
     , a.auth_method
     , a.auth_resp_code    as auth_resp_id
     , a.terminal_capab    as cap_of_term
     , a.card_serial_num
     , a.cipher_text_inf_data
     , a.auth_currency     as code_of_trans_currency
     , a.terminal_country  as country_code_of_term
     , a.dedic_doc_name
     , a.ic_card_cond_code
     , a.interface_serial
     , a.iss_bank_app_data
     , a.local
     , a.mcc
     , a.merchant_name     as mrc_name
     , a.other_amount
     , a.point
     , a.proc_func_code
     , a.terminal_entry_capab  as read_cap_of_term
     , a.terminal_verif_result as result_term_verif
     , a.script_result_of_card_issuer
     , a.forwarding_iin        as sending_inst_id
     , a.pos_entry_mode        as serv_input_mode_code
     , a.sys_trace_num
     , a.terminal_category     as term_cat
     , a.terminal_number       as term_id
     , a.trans_currency        as tran_curr_code
     , a.trans_init_channel    as tran_init_channel
     , a.trans_category        as trans_cat
     , a.trans_counter         as trans_cnt
     , a.trans_date
     , a.trans_resp_code
     , a.trans_serial_counter  as trans_serial_cnt
     , a.trans_code
     , a.transmission_date_time
     , a.unpred_num
     , substr(a.cardholder_exch_rate, 2, 7) / power(10, substr(a.cardholder_exch_rate, 1, 1))  as bill_exch_rate
     , a.cardholder_acc_currency
     , a.cardholder_bill_amount
     , a.cups_notice
     , a.cups_ref_num
     , a.double_message_id
     , a.int_org
     , a.issue
     , a.issuer_iin            as issue_code
     , to_char(null)           as orig_trans_data
     , a.payment_service_type
     , a.pos_input_mode
     , a.reason_code
     , a.receiving_iin         as receive_inst_id
     , a.service_fee_amount
     , a.service_fee_currency
     , a.service_fee_exch_rate
     , substr(a.settlement_exch_rate, 2, 7) / power(10, substr(a.settlement_exch_rate, 1, 1)) settlement_exch_rate
     , a.terminal_auth_date
     , a.trans_features_id
     , a.transferred
     , a.ic_trans_currency_code
     , a.ic_pos_input_mode
     , a.original_id
     , a.merchant_country
     , a.pos_cond_code
     , l.lang
     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
     , a.sttl_amount
     , a.sttl_currency
     , a.message_type
     , a.receivable_fee
     , a.payable_fee
     , a.b2b_business_type
     , a.b2b_payment_medium
     , a.payment_facilitator_id
  from cup_fin_message a
     , cup_card c
     , com_language_vw l
 where a.id = c.id(+)
/
