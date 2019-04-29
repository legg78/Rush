create or replace force view qpr_visa_iss_vw as
    select o.id
         , o.oper_date
         , o.card_type_id
         , o.group_name
         , o.param_name
         , o.inst_id
      from (
            select o.id
                 , trunc(vf.sttl_date) as oper_date
                 , com_api_array_pkg.conv_array_elem_v(
                         i_lov_id            => 130
                       , i_array_type_id     => 1030
                       , i_array_id          => 10000034
                       , i_inst_id           => 9999
                       , i_elem_value        => ic.card_type_id
                   ) as card_type_id
                 , nvl(com_api_array_pkg.conv_array_elem_v(
                           i_lov_id            => 49
                         , i_array_type_id     => 1030
                         , i_array_id          => 10000032
                         , i_inst_id           => 9999
                         , i_elem_value        => o.oper_type
                   ), 'AFT') as param_name
                 , case
                        when o.sttl_type = 'STTT0010' then '215.On-Us'
                        when o.merchant_country = opi.card_country then '216.National'
                        else '217.International'
                   end as group_name
                 , opi.card_inst_id as inst_id
              from opr_operation o
                 , opr_participant opi
                 , opr_participant opa
                 , opr_card oc
                 , iss_card ic
                 , prd_contract ctr
                 , vis_file vf
                 , (select cf.card_type_id
                         , cf.card_feature
                      from net_card_type ct
                         , net_card_type_feature cf
                     where ct.network_id = 1003 -- VISA
                       and ct.id = cf.card_type_id
                       and cf.card_feature in ('CFCHSTDR','CFCHELEC')
                   ) ct
                 , (select element_value from com_array_element where array_id = 10000012) iss_sttl
                 , (select element_value from com_array_element where array_id = 10000014) oper_type
                 , (select element_value from com_array_element where array_id = 10000020) oper_status
             where o.is_reversal = 0
               and o.oper_type = oper_type.element_value
               and o.status = oper_status.element_value
               and o.sttl_type = iss_sttl.element_value
               and o.sttl_type = 'STTT0100' and o.msg_type in ('MSGTPRES')
               and o.id = opi.oper_id
               and opi.participant_type = 'PRTYISS'
               and o.id = opa.oper_id
               and opa.participant_type = 'PRTYACQ'
               and oc.oper_id = opi.oper_id
               and oc.participant_type = opi.participant_type
               and opi.card_id = ic.id
               and ic.contract_id = ctr.id
               and opi.card_type_id = ct.card_type_id
               and o.incom_sess_file_id = vf.id
               and vf.is_incoming =1
               and vf.sttl_date is not null
               and com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 49
                           , i_array_type_id     => 1030
                           , i_array_id          => 10000032
                           , i_inst_id           => 9999--ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.oper_type
                     ) is not null
            union all
            select o.id
                 , trunc(o.oper_date) as oper_date
                 , com_api_array_pkg.conv_array_elem_v(
                         i_lov_id            => 130
                       , i_array_type_id     => 1030
                       , i_array_id          => 10000034
                       , i_inst_id           => 9999
                       , i_elem_value        => ic.card_type_id
                   ) as card_type_id
                 , nvl(com_api_array_pkg.conv_array_elem_v(
                           i_lov_id            => 49
                         , i_array_type_id     => 1030
                         , i_array_id          => 10000032
                         , i_inst_id           => 9999
                         , i_elem_value        => o.oper_type
                   ), 'AFT') as param_name
                 , case
                        when o.sttl_type = 'STTT0010' then '215.On-Us'
                        when o.merchant_country = opi.card_country then '216.National'
                        else '217.International'
                   end as group_name
                 , opi.card_inst_id as inst_id
              from opr_operation o
                 , opr_participant opi
                 , opr_participant opa
                 , opr_card oc
                 , iss_card ic
                 , prd_contract ctr
                 , (select cf.card_type_id
                         , cf.card_feature
                      from net_card_type ct
                         , net_card_type_feature cf
                     where ct.network_id = 1003 -- VISA
                       and ct.id = cf.card_type_id
                       and cf.card_feature in ('CFCHSTDR','CFCHELEC')
                   ) ct
                 , (select element_value from com_array_element where array_id = 10000012) iss_sttl
                 , (select element_value from com_array_element where array_id = 10000014) oper_type
                 , (select element_value from com_array_element where array_id = 10000020) oper_status
             where o.is_reversal = 0
               and o.oper_type = oper_type.element_value
               and o.status = oper_status.element_value
               and o.sttl_type = iss_sttl.element_value
               and o.sttl_type = 'STTT0010' and o.msg_type in ('MSGTAUTH', 'MSGTCMPL')
               and o.id = opi.oper_id
               and opi.participant_type = 'PRTYISS'
               and o.id = opa.oper_id
               and opa.participant_type = 'PRTYACQ'
               and oc.oper_id = opi.oper_id
               and oc.participant_type = opi.participant_type
               and opi.card_id = ic.id
               and ic.contract_id = ctr.id
               and opi.card_type_id = ct.card_type_id
               and o.incom_sess_file_id is null
               and com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 49
                           , i_array_type_id     => 1030
                           , i_array_id          => 10000032
                           , i_inst_id           => 9999--ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.oper_type
                     ) is not null
            union all
            select o.id
                 , trunc(o.oper_date) as oper_date
                 , com_api_array_pkg.conv_array_elem_v(
                         i_lov_id            => 130
                       , i_array_type_id     => 1030
                       , i_array_id          => 10000034
                       , i_inst_id           => 9999
                       , i_elem_value        => ic.card_type_id
                   ) as card_type_id
                 , 'OC' as param_name
                 , case
                        when o.sttl_type = 'STTT0010' then '215.On-Us'
                        when o.merchant_country = opi.card_country then '216.National'
                        else '217.International'
                   end as group_name
                 , opi.card_inst_id as inst_id
              from opr_operation o
                 , opr_participant opi
                 , opr_participant opa
                 , opr_card oc
                 , iss_card ic
                 , prd_contract ctr
                 , (select cf.card_type_id
                         , cf.card_feature
                      from net_card_type ct
                         , net_card_type_feature cf
                     where ct.network_id = 1003 -- VISA
                       and ct.id = cf.card_type_id
                       and cf.card_feature in ('CFCHSTDR','CFCHELEC')
                   ) ct
                 , (select element_value from com_array_element where array_id = 10000012) iss_sttl
                 , (select element_value from com_array_element where array_id = 10000014) oper_type
                 , (select element_value from com_array_element where array_id = 10000020) oper_status
             where o.is_reversal = 0
               and o.oper_type = oper_type.element_value
               and o.status = oper_status.element_value
               and o.sttl_type = iss_sttl.element_value
               and o.sttl_type = 'STTT0010' and o.oper_type = 'OPTP0011' and o.msg_type in ('MSGTAUTH', 'MSGTCMPL')
               and o.id = opi.oper_id
               and opi.participant_type = 'PRTYISS'
               and o.id = opa.oper_id
               and opa.participant_type = 'PRTYACQ'
               and oc.oper_id = opi.oper_id
               and oc.participant_type = opi.participant_type
               and opi.card_id = ic.id
               and ic.contract_id = ctr.id
               and opi.card_type_id = ct.card_type_id
               and com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 49
                           , i_array_type_id     => 1030
                           , i_array_id          => 10000032
                           , i_inst_id           => 9999--ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.oper_type
                     ) is not null
         ) o
/
