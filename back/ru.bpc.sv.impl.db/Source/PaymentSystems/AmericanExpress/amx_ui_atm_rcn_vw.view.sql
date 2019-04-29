create or replace force view amx_ui_atm_rcn_vw as
select n.id
     , n.status
     , get_article_text(
            i_article => n.status
          , i_lang    => l.lang
       ) as status_desc
     , n.is_invalid
     , n.file_id
     , n.inst_id
     , get_text(
            i_table_name  => 'ost_institution'
          , i_column_name => 'name'
          , i_object_id   => n.inst_id
          , i_lang        => l.lang
        ) as inst_name
     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
     , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number) as card_mask
     , n.record_type
     , n.msg_seq_number
     , n.trans_date
     , n.system_date
     , n.sttl_date
     , n.terminal_number
     , n.system_trace_audit_number
     , n.dispensed_currency
     , n.amount_requested
     , n.amount_ind
     , n.sttl_rate
     , n.sttl_currency
     , n.sttl_amount_requested
     , n.sttl_amount_approved
     , n.sttl_amount_dispensed
     , n.sttl_network_fee
     , n.sttl_other_fee
     , n.terminal_country_code
     , n.merchant_country_code
     , n.card_billing_country_code
     , n.terminal_location
     , n.auth_status
     , n.trans_indicator
     , n.orig_action_code
     , n.approval_code
     , n.add_ref_number
     , n.trans_id
     , l.lang
  from amx_atm_rcn_fin n
     , amx_card c
     , com_language_vw l
 where n.id = c.id(+)
/
