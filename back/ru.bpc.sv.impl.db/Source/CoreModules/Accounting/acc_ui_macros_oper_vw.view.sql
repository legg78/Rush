create or replace force view acc_ui_macros_oper_vw as
select m.id
     , m.entity_type
     , m.object_id
     , m.macros_type_id
     , m.posting_date
     , m.account_id
     , m.amount_purpose
     , m.amount
     , m.currency
     , m.fee_id
     , m.fee_tier_id
     , m.fee_mod_id
     , m.details_data
     , o.oper_type
     , o.oper_reason
     , o.msg_type
     , o.status
     , o.status_reason
     , o.sttl_type
     , p2.inst_id acq_inst_id
     , p2.network_id acq_network_id
     , o.terminal_type
     , o.acq_inst_bin
     , o.forw_inst_bin
     , p2.merchant_id
     , o.merchant_number
     , p2.terminal_id
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
     , p.auth_code
     , o.oper_count
     , o.oper_request_amount
     , o.oper_amount
     , o.oper_currency
     , o.oper_date
     , o.host_date
     , p.inst_id iss_inst_id
     , p.network_id iss_network_id
     , p.card_inst_id
     , p.card_network_id
     , p.card_id
     , p.card_instance_id
     , p.card_type_id
     , p.card_mask
     , p.card_hash
     , p.card_seq_number
     , p.card_expir_date
     , p.card_country
     , p.customer_id
     , p.account_type
     , p.account_number
     , p.account_amount
     , p.account_currency
  from acc_macros m
     , opr_operation o
     , opr_participant p
     , opr_participant p2
 where m.entity_type = 'ENTTOPER'
   and m.object_id = o.id
   and p.oper_id(+) = o.id
   and p.participant_type(+) = 'PRTYISS' 
   and p2.oper_id(+) = o.id
   and p2.participant_type(+) = 'PRTYACQ' 
/