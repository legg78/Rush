create or replace force view qpr_visa_acq_vw as
select o.id
     , trunc(o.oper_date) as oper_date
     , com_api_array_pkg.conv_array_elem_v(
               i_lov_id            => 49
             , i_array_type_id     => 1030
             , i_array_id          => 10000031
             , i_inst_id           => 9999
             , i_elem_value        => o.oper_type
       ) as param_name
     , case
            when ct.card_feature = 'CFCHELEC'
            then 'of which on Electron Cards'
            else ''
       end as subparam_name
     , case
            when o.oper_type in ('OPTP0001','OPTP0012')
            then
                case
                    when o.sttl_type = 'STTT0010' then '208.On-Us'
                    when o.merchant_country = opi.card_country then '209.National'
                    else '210.International'
                end
            else
                case
                    when o.sttl_type = 'STTT0010' then '201.On-Us'
                    when o.merchant_country = opi.card_country then '202.National'
                    else '203.International'
                end
       end as group_name
     , opa.inst_id
  from opr_operation o
     , opr_participant opi
     , opr_participant opa
     , opr_card oc
     , (select cf.card_type_id
             , cf.card_feature
          from net_card_type ct
             , net_card_type_feature cf
         where ct.network_id = 1003 -- VISA
           and ct.id = cf.card_type_id
           and cf.card_feature in ('CFCHSTDR','CFCHELEC')
       ) ct
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
   and opi.card_type_id = ct.card_type_id
   and com_api_array_pkg.conv_array_elem_v(
                 i_lov_id            => 49
               , i_array_type_id     => 1030
               , i_array_id          => 10000031
               , i_inst_id           => 9999--ost_api_const_pkg.DEFAULT_INST
               , i_elem_value        => o.oper_type
         ) is not null
/
