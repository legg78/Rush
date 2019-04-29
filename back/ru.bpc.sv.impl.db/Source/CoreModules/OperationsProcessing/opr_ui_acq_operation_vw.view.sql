create or replace force view opr_ui_acq_operation_vw as
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
     , o.proc_mode
  from opr_operation o
     , opr_participant a
     , opr_participant i
     , opr_card ci
     , opr_participant d
     --, opr_card cd
 where a.oper_id(+) = o.id
   and a.participant_type(+) = 'PRTYACQ'
   and i.oper_id(+) = o.id 
   and i.participant_type(+) = 'PRTYISS'
   and ci.oper_id(+) = o.id 
   and ci.participant_type(+) = 'PRTYISS'
   and d.oper_id(+) = o.id 
   and d.participant_type(+) = 'PRTYDST'
   --and cd.oper_id(+) = o.id 
   --and cd.participant_type(+) = 'PRTYDST'
   and a.inst_id in (select inst_id from acm_cu_inst_vw)
/