create or replace force view opr_api_operation_vw as
select 'ENTTOPER' entity_type
     , o.id
     , o.status
     , o.status_reason
     , o.sttl_type
     , o.msg_type
     , o.oper_type
     , o.oper_reason
     , o.is_reversal
     , i.inst_id src_inst_id
     , d.inst_id dst_inst_id
     , t.id auth_id
     , i.inst_id iss_inst_id
     , i.network_id iss_network_id
     , i.card_inst_id
     , i.card_network_id
     , i.card_id
     , i.card_type_id
     , i.card_country
     , iss_api_token_pkg.decode_card_number(i_card_number => ci.card_number) as card_number
     , iss_api_card_pkg.get_card_mask(i_card_number => ci.card_number) as card_mask
     , i.card_seq_number
     , i.card_expir_date
     , a.inst_id acq_inst_id
     , a.network_id acq_network_id
     , a.merchant_id
     , a.terminal_id
     , o.oper_amount
     , o.oper_currency
     , i.account_amount
     , i.account_currency
     , o.sttl_amount
     , o.sttl_currency
     , o.oper_date
     , o.host_date
     , o.terminal_type
     , i.account_number
     , o.mcc
     , o.originator_refnum
     , i.auth_code
     , o.acq_inst_bin
     , o.merchant_number
     , o.terminal_number
     , o.merchant_name
     , o.merchant_street
     , o.merchant_city
     , o.merchant_region
     , o.merchant_country
     , o.merchant_postcode
     , i.client_id_type
     , i.client_id_value
     , d.client_id_type dst_client_id_type
     , d.client_id_value dst_client_id_value
     , d.network_id dst_network_id
     , d.card_inst_id dst_card_inst_id
     , d.card_network_id dst_card_network_id
     , d.card_id dst_card_id
     , d.card_instance_id dst_card_instance_id
     , d.card_type_id dst_card_type_id
     , iss_api_card_pkg.get_card_mask(i_card_number => cd.card_number) as dst_card_mask
     , d.card_hash dst_card_hash
     , d.card_seq_number dst_card_seq_number
     , d.card_expir_date dst_card_expir_date
     , d.card_service_code dst_card_service_code
     , d.card_country dst_card_country
     , d.customer_id dst_customer_id
     , d.account_id dst_account_id
     , d.account_type dst_account_type
     , d.account_number dst_account_number
     , d.account_amount dst_account_amount
     , d.account_currency dst_account_currency
     , d.auth_code dst_auth_code
     , t.resp_code
     , o.oper_amount_algorithm
     , null oper_id
     , o.payment_order_id
     , o.proc_mode
     , o.incom_sess_file_id
     , o.sttl_date
     , o.acq_sttl_date
  from opr_operation o
     , opr_participant a
     , opr_participant i
     , opr_card ci
     , opr_participant d
     , opr_card cd
     , aut_auth t
 where a.oper_id(+) = o.id
   and a.participant_type(+) = 'PRTYACQ'
   and i.oper_id(+) = o.id 
   and i.participant_type(+) = 'PRTYISS'
   and ci.oper_id(+) = o.id 
   and ci.participant_type(+) = 'PRTYISS'
   and d.oper_id(+) = o.id 
   and d.participant_type(+) = 'PRTYDST'
   and cd.oper_id(+) = o.id 
   and cd.participant_type(+) = 'PRTYDST'
   and t.id(+) = o.id
/
