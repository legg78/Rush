create or replace force view csm_ui_case_vw as
select c.id
     , a.seqnum
     , c.inst_id
     , get_text('ost_institution', 'name', c.inst_id, l.lang) as inst_name
     , c.merchant_name
     , c.customer_number
     , c.dispute_reason
     , c.oper_date
     , c.oper_amount
     , c.oper_currency
     , c.dispute_id
     , c.dispute_progress
     , c.write_off_amount
     , c.write_off_currency
     , c.due_date
     , c.reason_code
     , c.disputed_amount
     , c.disputed_currency
     , c.created_date
     , c.created_by_user_id
     , c.arn
     , c.claim_id
     , c.auth_code
     , c.case_progress
     , c.acquirer_inst_bin
     , c.transaction_code
     , c.case_source
     , c.sttl_amount
     , c.sttl_currency
     , c.base_amount
     , c.base_currency
     , c.hide_date
     , c.unhide_date
     , c.team_id
     , iss_api_card_pkg.get_card_mask(i_card_number => card.card_number) as card_mask
     , iss_api_token_pkg.decode_card_number(i_card_number => card.card_number) as card_number
     , l.lang
     , c.original_id
     , c.network_id
     , get_text(
           i_table_name  => 'NET_NETWORK'
         , i_column_name => 'NAME'
         , i_object_id   => c.network_id
         , i_lang        => l.lang
       ) as network_name
     , c.ext_claim_id
     , c.ext_clearing_trans_id
     , c.ext_auth_trans_id
  from csm_case c
     , csm_card card
     , app_application a
     , com_language_vw l
 where card.id(+) = c.id
   and c.id = a.id
/
