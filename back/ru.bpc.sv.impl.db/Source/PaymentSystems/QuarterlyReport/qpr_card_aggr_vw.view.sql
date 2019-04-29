create or replace force view qpr_card_aggr_vw as
select distinct
       trunc (oper_date, 'Q') report_date
     , card.card_type_id
     , card.id as card_id
  from opr_operation o
     , opr_participant op
     , iss_card card
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
   and op.card_id = card.id
/

