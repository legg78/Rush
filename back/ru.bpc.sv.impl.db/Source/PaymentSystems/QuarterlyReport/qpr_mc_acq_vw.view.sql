create or replace force view qpr_mc_acq_vw as
select o.id
     , o.oper_date
     , o.group_name
     , o.param_name
     , o.inst_id
  from ( 
        select o.id
             , trunc(o.oper_date) as oper_date
             , case nvl(com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 49 
                           , i_array_type_id     => 1022
                           , i_array_id          => 10000029
                           , i_inst_id           => 9999
                           , i_elem_value        => o.oper_type
                      ), 'Unknown')
                    when 'Sales'   then '123.PURCHASES'
                    when 'ATM'     then '125.ATM_CASH_ADVANCES'
                    when 'Manual'  then '126.MANUAL_CASH_ADVANCES'
                    when 'Refunds' then '127.REFUNDS_RETURNS_CREDITS'
                    else 'Unknown'
               end
               as group_name
             , case
                    when o.sttl_type = 'STTT0010' then '1063.Domestic On-us'
                    when o.merchant_country = nvl(opi.card_country, o.merchant_country) then '1065.Domestic Interchange'
                    when c.mastercard_region = 'D' then '1066.International Within Europe'
                    when o.merchant_country is not null and nvl(opi.card_country, o.merchant_country) is not null then '1067.International Outside of Europe'
                    else 'Unknown'
               end as param_name
             , opa.inst_id
          from opr_operation o
             , opr_participant opi
             , opr_participant opa
             , opr_card oc
             , com_country c
             , (select element_value from com_array_element where array_id = 10000013) acq_sttl
             , (select element_value from com_array_element where array_id = 10000014) oper_type
             , (select element_value from com_array_element where array_id = 10000020) oper_status
         where o.is_reversal = 0
           and o.oper_type = oper_type.element_value
           and o.status = oper_status.element_value
           and o.sttl_type = acq_sttl.element_value
           and o.msg_type in ('MSGTAUTH', 'MSGTCMPL')
           and o.id = opi.oper_id
           and opi.participant_type = 'PRTYISS'
           and o.id = opa.oper_id
           and opa.participant_type = 'PRTYACQ'
           and oc.oper_id = opi.oper_id
           and oc.participant_type = opi.participant_type
           and c.code = nvl(opi.card_country, o.merchant_country)
           and com_api_array_pkg.conv_array_elem_v(
                   i_lov_id            => 130 
                 , i_array_type_id     => 1022
                 , i_array_id          => 10000033
                 , i_inst_id           => 9999
                 , i_elem_value        => opi.card_type_id
               ) not in (1005)
        union
        select o.id
             , trunc(o.oper_date) as oper_date
             , case nvl(com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 49 
                           , i_array_type_id     => 1022
                           , i_array_id          => 10000029
                           , i_inst_id           => 9999
                           , i_elem_value        => o.oper_type
                      ), 'Unknown')
                    when 'Sales'   then '131.MAESTRO_ACQUIRING_PURCHASE_ACTIVITY'
                    when 'ATM'     then '132.MAESTRO_ACQ_CASH_DISB_ACTIVITY'
                    else 'Unknown'
               end
               as group_name
             , case
                    when o.sttl_type = 'STTT0010' then '1063.Domestic On-us'
                    when o.merchant_country = nvl(opi.card_country, o.merchant_country) then '1065.Domestic Interchange'
                    when c.mastercard_region = 'D' then '1066.International Within Europe'
                    when o.merchant_country is not null and nvl(opi.card_country, o.merchant_country) is not null then '1067.International Outside of Europe'
                    else 'Unknown'
               end as param_name
             , opa.inst_id
          from opr_operation o
             , opr_participant opi
             , opr_participant opa
             , opr_card oc
             , com_country c
             , (select element_value from com_array_element where array_id = 10000013) acq_sttl
             , (select element_value from com_array_element where array_id = 10000014) oper_type
             , (select element_value from com_array_element where array_id = 10000020) oper_status
         where o.is_reversal = 0
           and o.oper_type = oper_type.element_value
           and o.status = oper_status.element_value
           and o.sttl_type = acq_sttl.element_value
           and o.msg_type in ('MSGTAUTH', 'MSGTCMPL')
           and o.id = opi.oper_id
           and opi.participant_type = 'PRTYISS'
           and o.id = opa.oper_id
           and opa.participant_type = 'PRTYACQ'
           and oc.oper_id = opi.oper_id
           and oc.participant_type = opi.participant_type
           and c.code = nvl(opi.card_country, o.merchant_country)
           and com_api_array_pkg.conv_array_elem_v(
                   i_lov_id            => 130 
                 , i_array_type_id     => 1022
                 , i_array_id          => 10000033
                 , i_inst_id           => 9999
                 , i_elem_value        => opi.card_type_id
               ) in (1005)
       ) o
 where o.group_name != 'Unknown'
   and o.param_name != 'Unknown'
/
