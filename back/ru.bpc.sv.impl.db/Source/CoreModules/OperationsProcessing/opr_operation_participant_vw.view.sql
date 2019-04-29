create or replace force view opr_operation_participant_vw as
select ci.card_number
     , o.id
     , null split_hash
     , o.session_id
     , o.is_reversal
     , o.original_id
     , o.oper_type
     , o.oper_reason
     , o.msg_type
     , o.status
     , o.status_reason
     , o.sttl_type
     , a.inst_id acq_inst_id
     , a.network_id acq_network_id
     , a.split_hash split_hash_acq
     , o.terminal_type
     , o.acq_inst_bin
     , o.forw_inst_bin
     , a.merchant_id
     , o.merchant_number
     , a.terminal_id
     , o.terminal_number
     , o.merchant_name
     , o.merchant_street
     , o.merchant_city
     , o.merchant_region
     , o.merchant_country
     , o.merchant_postcode
     , o.mcc
     , o.originator_refnum
     , o.network_refnum
     , i.auth_code
     , o.oper_count
     , o.oper_request_amount
     , o.oper_amount_algorithm
     , o.oper_amount
     , o.oper_currency
     , o.oper_cashback_amount
     , o.oper_replacement_amount
     , o.oper_surcharge_amount
     , o.oper_date
     , o.host_date
     , o.unhold_date
     , i.client_id_type
     , i.client_id_value
     , i.inst_id iss_inst_id
     , i.network_id iss_network_id
     , i.split_hash split_hash_iss
     , i.card_inst_id
     , i.card_network_id
     , i.card_id
     , i.card_instance_id
     , i.card_type_id
     , coalesce(i.card_mask, iss_api_card_pkg.get_card_mask(ci.card_number)) card_mask
     , i.card_hash
     , i.card_seq_number
     , i.card_expir_date
     , i.card_country
     , i.customer_id
     , i.account_id
     , i.account_type
     , i.account_number
     , i.account_amount
     , i.account_currency
     , o.match_status
     , o.id auth_id
     , o.sttl_amount
     , o.sttl_currency
     , o.dispute_id
     , d.client_id_type dst_client_id_type
     , d.client_id_value dst_client_id_value
     , d.inst_id dst_inst_id
     , d.network_id dst_network_id
     , d.card_inst_id dst_card_inst_id
     , d.card_network_id dst_card_network_id
     , d.card_id dst_card_id
     , d.card_instance_id dst_card_instance_id
     , d.card_type_id dst_card_type_id
     , d.card_mask dst_card_mask
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
     , o.payment_order_id
     , o.payment_host_id
     , o.forced_processing
     , o.match_id
     , a.customer_id acq_customer_id
     , a.account_id acq_account_id
     , a.account_type acq_account_type
     , a.account_number acq_account_number
     , a.account_amount acq_account_amount
     , a.account_currency acq_account_currency
     , o.proc_mode
     , o.clearing_sequence_num
     , o.clearing_sequence_count
     , o.incom_sess_file_id
     , o.sttl_date
     , o.acq_sttl_date
  from opr_operation o
     , opr_participant a
     , opr_participant i
     , opr_card ci
     , opr_participant d
     , opr_card cd
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
/
