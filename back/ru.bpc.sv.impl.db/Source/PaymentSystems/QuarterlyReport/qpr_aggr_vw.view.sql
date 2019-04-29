create or replace force view qpr_aggr_vw as
select count (o.id) as cnt
     , sum (case
                 when o.sttl_amount is null then o.oper_amount
                 else o.sttl_amount
            end)
       as amount
     , case
            when o.sttl_amount is null then o.oper_currency
            else o.sttl_currency
       end
       as currency
     , trunc (o.oper_date) as oper_date
     , o.oper_type
     , o.sttl_type
     , o.msg_type
     , o.status
     , o.oper_reason
     , o.is_reversal
     , o.mcc
     , nvl (o.merchant_country, c.code) as merchant_country
     , case
            when acq_sttl.element_value is not null then o.acq_inst_bin
            else null
       end
       as acq_inst_bin
     , op.card_type_id
     , case
            when iss_sttl.element_value is not null then op.card_inst_id
            when acq_sttl.element_value is not null then op2.inst_id
            else op.card_inst_id
       end
       as card_inst_id
     , ct.network_id as card_network_id
     , op.card_country
     , ic.product_id as card_product_id
     , pls.perso_method_id as card_perso_method_id
     , case
            when iss_sttl.element_value is not null then substr (oc.card_number, 1, 6)
            else null
       end
       as card_bin
     , op2.inst_id
       as acq_inst_id
     , case
            when o.msg_type in ('MSGTAUTH', 'MSGTCMPL') then aa.card_data_input_mode
            when vf.cryptogram is not null then 'F227000C'
            else mf.de022_7
       end
       as card_data_input_mode
     , case
            when acq_sttl.element_value is not null then o.terminal_number
            else null
       end
       as terminal_number
     , case when iss_sttl.element_value is not null then 1
            else 0
       end
       as is_iss
     , case when acq_sttl.element_value is not null then 1
            else 0
       end
       as is_acq
  from opr_operation o
     , opr_participant op
     , opr_participant op2
     , opr_card oc
     , aut_auth aa
     , mcw_fin mf
     , vis_fin_message vf
     , com_country c
     , iss_card card
     , prd_contract ic
     , net_card_type ct
     , (select card_id
             , max (perso_method_id) keep (dense_rank first order by seq_number desc) as perso_method_id
          from iss_card_instance
      group by card_id) pls
     , (select element_value from com_array_element where array_id = 10000012) iss_sttl
     , (select element_value from com_array_element where array_id = 10000013) acq_sttl
     , (select element_value from com_array_element where array_id = 10000014) oper_type
     , (select element_value from com_array_element where array_id = 10000020) oper_status
 where 1 = 1
   and o.oper_type = oper_type.element_value
   and o.sttl_type = iss_sttl.element_value(+)
   and o.sttl_type = acq_sttl.element_value(+)
   and ((iss_sttl.element_value is not null and msg_type in ('MSGTPRES'))
        or (acq_sttl.element_value is not null and msg_type in ('MSGTAUTH', 'MSGTCMPL')))
   and o.status = oper_status.element_value
   and o.id = op.oper_id
   and op.participant_type = 'PRTYISS'
   and o.id = op2.oper_id
   and op2.participant_type = 'PRTYACQ'
   and op.oper_id = oc.oper_id
   and oc.participant_type = 'PRTYISS'
   and o.id = aa.id(+)
   and o.id = mf.id(+)
   and o.id = vf.id(+)
   and c.name(+) = mf.de043_6
   and op.card_id = card.id(+)
   and card.contract_id = ic.id(+)
   and card.id = pls.card_id(+)
   and op.card_type_id = ct.id
 group by
       case
            when o.sttl_amount is null then o.oper_currency
            else o.sttl_currency
       end
     , trunc (o.oper_date)
     , o.oper_type
     , o.sttl_type
     , o.msg_type
     , o.status
     , o.oper_reason
     , o.is_reversal
     , o.mcc
     , nvl (o.merchant_country, c.code)
     , case
            when acq_sttl.element_value is not null then o.acq_inst_bin
            else null
       end
     , op.card_type_id
     , case
            when iss_sttl.element_value is not null then op.card_inst_id
            when acq_sttl.element_value is not null then op2.inst_id
            else op.card_inst_id
       end
     , ct.network_id
     , op.card_country
     , ic.product_id
     , pls.perso_method_id
     , case
            when iss_sttl.element_value is not null then substr (oc.card_number, 1, 6)
            else null
       end
     , op2.inst_id
     , case
            when msg_type in ('MSGTAUTH', 'MSGTCMPL') then aa.card_data_input_mode
            when vf.cryptogram is not null then 'F227000C'
            else mf.de022_7
       end
     , case
            when acq_sttl.element_value is not null then o.terminal_number
            else null
       end
     , iss_sttl.element_value
     , acq_sttl.element_value
/

