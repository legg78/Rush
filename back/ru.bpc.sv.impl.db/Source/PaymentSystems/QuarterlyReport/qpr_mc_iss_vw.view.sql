create or replace force view qpr_mc_iss_vw as
    select o.id
         , o.oper_date
         , o.card_type_id
         , o.group_name
         , o.param_name
         , o.inst_id
      from (
            select o.id
                 , trunc(vf.sttl_date) as oper_date
                 , com_api_array_pkg.conv_array_elem_v (
                        i_lov_id          => 130
                      , i_array_type_id   => 1022
                      , i_array_id        => 10000033
                      , i_inst_id         => 9999
                      , i_elem_value      => ic.card_type_id) as card_type_id
                 , case nvl (com_api_array_pkg.conv_array_elem_v (
                                   i_lov_id          => 49
                                 , i_array_type_id   => 1022
                                 , i_array_id        => 10000030
                                 , i_inst_id         => 9999
                                 , i_elem_value      => o.oper_type)
                           , 'Unknown')
                        when 'Sales'   then decode (ct.card_feature, 'CFCHSTDR', '101.PURCHASES', 'CFCHELEC', '116.MAESTRO_PURCHASE_RETAIL_SALES_ACTIVITY', 'Unknown')
                        when 'ATM'     then decode (ct.card_feature, 'CFCHSTDR', '103.ATM_CASH_ADVANCES', 'CFCHELEC', '117.MAESTRO_CASH_DISBURSEMENTS_ATM_ACTIVITY', 'Unknown')
                        when 'Manual'  then decode (ct.card_feature, 'CFCHSTDR', '104.MANUAL_CASH_ADVANCES', 'Unknown')
                        when 'Refunds' then decode (ct.card_feature, 'CFCHSTDR', '105.REFUNDS_RETURNS_CREDITS', 'Unknown')
                        else 'Unknown'
                   end as group_name
                 , case
                        when o.sttl_type = 'STTT0010' and ct.card_feature = 'CFCHSTDR'
                        then '1000.Domestic On-Us'
                        when opi.card_country = nvl(o.merchant_country, opi.card_country) and ct.card_feature = 'CFCHSTDR'
                        then '1002.Domestic Interchange'
                        when c.mastercard_region = 'D' and ct.card_feature = 'CFCHSTDR'
                        then '1003.International Within Europe'
                        when opi.card_country is not null and nvl (o.merchant_country, opi.card_country) is not null and ct.card_feature = 'CFCHSTDR'
                        then '1004.International Outside of Europe'
                        when o.sttl_type = 'STTT0010' and ct.card_feature = 'CFCHELEC'
                        then '1039.Domestic On-Us'
                        when opi.card_country = nvl(o.merchant_country, opi.card_country) and ct.card_feature = 'CFCHELEC'
                        then '1041.Domestic Interchange'
                        when c.mastercard_region = 'D' and ct.card_feature = 'CFCHELEC'
                        then '1042.International Within Europe'
                        when opi.card_country is not null and nvl (o.merchant_country, opi.card_country) is not null and ct.card_feature = 'CFCHELEC'
                        then '1043.International Outside of Europe'
                        else 'Unknown'
                   end as param_name
                 , opi.card_inst_id as inst_id
              from opr_operation o
                 , opr_participant opi
                 , opr_participant opa
                 , opr_card oc
                 , iss_card ic
                 , com_country c
                 , prd_contract ctr
                 , vis_file vf
                 , (select ct.id as card_type_id
                         , case when com_api_array_pkg.conv_array_elem_v(
                                           i_lov_id            => 130
                                         , i_array_type_id     => 1022
                                         , i_array_id          => 10000033
                                         , i_inst_id           => 9999
                                         , i_elem_value        => ct.id
                                       ) not in (1005)
                                then 'CFCHELEC'
                                else 'CFCHSTDR'
                           end
                           as card_feature
                      from net_card_type ct
                     where ct.network_id = 1002               -- MasterCard
                   ) ct
                 , (select element_value
                      from com_array_element
                     where array_id = 10000012) iss_sttl
                 , (select element_value
                      from com_array_element
                     where array_id = 10000014) oper_type
                 , (select element_value
                      from com_array_element
                     where array_id = 10000020) oper_status
             where o.incom_sess_file_id = vf.id
               and vf.is_incoming = 1
               and vf.sttl_date is not null
               and o.is_reversal = 0
               and o.oper_type = oper_type.element_value
               and o.status = oper_status.element_value
               and o.sttl_type = iss_sttl.element_value
               and o.sttl_type = 'STTT0100'
               and o.msg_type = 'MSGTPRES'
               and o.id = opi.oper_id
               and opi.participant_type = 'PRTYISS'
               and o.id = opa.oper_id
               and opa.participant_type = 'PRTYACQ'
               and oc.oper_id = opi.oper_id
               and oc.participant_type = opi.participant_type
               and opi.card_id = ic.id
               and ic.contract_id = ctr.id
               and opi.card_type_id = ct.card_type_id
               and c.code = nvl (o.merchant_country, opi.card_country)
           union
            select o.id
                 , trunc(mfn.p0159_8) as oper_date
                 , com_api_array_pkg.conv_array_elem_v (
                        i_lov_id          => 130
                      , i_array_type_id   => 1022
                      , i_array_id        => 10000033
                      , i_inst_id         => 9999
                      , i_elem_value      => ic.card_type_id) as card_type_id
                 , case nvl (com_api_array_pkg.conv_array_elem_v (
                                   i_lov_id          => 49
                                 , i_array_type_id   => 1022
                                 , i_array_id        => 10000030
                                 , i_inst_id         => 9999
                                 , i_elem_value      => o.oper_type)
                           , 'Unknown')
                        when 'Sales'   then decode (ct.card_feature, 'CFCHSTDR', '101.PURCHASES', 'CFCHELEC', '116.MAESTRO_PURCHASE_RETAIL_SALES_ACTIVITY', 'Unknown')
                        when 'ATM'     then decode (ct.card_feature, 'CFCHSTDR', '103.ATM_CASH_ADVANCES', 'CFCHELEC', '117.MAESTRO_CASH_DISBURSEMENTS_ATM_ACTIVITY', 'Unknown')
                        when 'Manual'  then decode (ct.card_feature, 'CFCHSTDR', '104.MANUAL_CASH_ADVANCES', 'Unknown')
                        when 'Refunds' then decode (ct.card_feature, 'CFCHSTDR', '105.REFUNDS_RETURNS_CREDITS', 'Unknown')
                        else 'Unknown'
                   end as group_name
                 , case
                        when o.sttl_type = 'STTT0010' and ct.card_feature = 'CFCHSTDR'
                        then '1000.Domestic On-Us'
                        when opi.card_country = nvl(o.merchant_country, opi.card_country) and ct.card_feature = 'CFCHSTDR'
                        then '1002.Domestic Interchange'
                        when c.mastercard_region = 'D' and ct.card_feature = 'CFCHSTDR'
                        then '1003.International Within Europe'
                        when opi.card_country is not null and nvl (o.merchant_country, opi.card_country) is not null and ct.card_feature = 'CFCHSTDR'
                        then '1004.International Outside of Europe'
                        when o.sttl_type = 'STTT0010' and ct.card_feature = 'CFCHELEC'
                        then '1039.Domestic On-Us'
                        when opi.card_country = nvl(o.merchant_country, opi.card_country) and ct.card_feature = 'CFCHELEC'
                        then '1041.Domestic Interchange'
                        when c.mastercard_region = 'D' and ct.card_feature = 'CFCHELEC'
                        then '1042.International Within Europe'
                        when opi.card_country is not null and nvl (o.merchant_country, opi.card_country) is not null and ct.card_feature = 'CFCHELEC'
                        then '1043.International Outside of Europe'
                        else 'Unknown'
                   end as param_name
                 , opi.card_inst_id as inst_id
              from opr_operation o
                 , opr_participant opi
                 , opr_participant opa
                 , opr_card oc
                 , iss_card ic
                 , com_country c
                 , prd_contract ctr
                 , mcw_fin mfn
                 , (select ct.id as card_type_id
                         , case when com_api_array_pkg.conv_array_elem_v(
                                           i_lov_id            => 130
                                         , i_array_type_id     => 1022
                                         , i_array_id          => 10000033
                                         , i_inst_id           => 9999
                                         , i_elem_value        => ct.id
                                       ) not in (1005)
                                then 'CFCHELEC'
                                else 'CFCHSTDR'
                           end
                           as card_feature
                      from net_card_type ct
                     where ct.network_id = 1002               -- MasterCard
                   ) ct
                 , (select element_value
                      from com_array_element
                     where array_id = 10000012) iss_sttl
                 , (select element_value
                      from com_array_element
                     where array_id = 10000014) oper_type
                 , (select element_value
                      from com_array_element
                     where array_id = 10000020) oper_status
             where o.incom_sess_file_id = mfn.file_id
               and mfn.is_incoming = 1
               and mfn.id = o.id
               and mfn.p0159_8 is not null
               and o.is_reversal = 0
               and o.oper_type = oper_type.element_value
               and o.status = oper_status.element_value
               and o.sttl_type = iss_sttl.element_value
               and o.sttl_type = 'STTT0100'
               and o.msg_type = 'MSGTPRES'
               and o.id = opi.oper_id
               and opi.participant_type = 'PRTYISS'
               and o.id = opa.oper_id
               and opa.participant_type = 'PRTYACQ'
               and oc.oper_id = opi.oper_id
               and oc.participant_type = opi.participant_type
               and opi.card_id = ic.id
               and ic.contract_id = ctr.id
               and opi.card_type_id = ct.card_type_id
               and c.code = nvl (o.merchant_country, opi.card_country)
           union
            select o.id
                 , trunc(o.oper_date) as oper_date
                 , com_api_array_pkg.conv_array_elem_v (
                        i_lov_id          => 130
                      , i_array_type_id   => 1022
                      , i_array_id        => 10000033
                      , i_inst_id         => 9999
                      , i_elem_value      => ic.card_type_id) as card_type_id
                 , case nvl (com_api_array_pkg.conv_array_elem_v (
                                   i_lov_id          => 49
                                 , i_array_type_id   => 1022
                                 , i_array_id        => 10000030
                                 , i_inst_id         => 9999
                                 , i_elem_value      => o.oper_type)
                           , 'Unknown')
                        when 'Sales'   then decode (ct.card_feature, 'CFCHSTDR', '101.PURCHASES', 'CFCHELEC', '116.MAESTRO_PURCHASE_RETAIL_SALES_ACTIVITY', 'Unknown')
                        when 'ATM'     then decode (ct.card_feature, 'CFCHSTDR', '103.ATM_CASH_ADVANCES', 'CFCHELEC', '117.MAESTRO_CASH_DISBURSEMENTS_ATM_ACTIVITY', 'Unknown')
                        when 'Manual'  then decode (ct.card_feature, 'CFCHSTDR', '104.MANUAL_CASH_ADVANCES', 'Unknown')
                        when 'Refunds' then decode (ct.card_feature, 'CFCHSTDR', '105.REFUNDS_RETURNS_CREDITS', 'Unknown')
                        else 'Unknown'
                   end as group_name
                 , case
                        when o.sttl_type = 'STTT0010' and ct.card_feature = 'CFCHSTDR'
                        then '1000.Domestic On-Us'
                        when opi.card_country = nvl(o.merchant_country, opi.card_country) and ct.card_feature = 'CFCHSTDR'
                        then '1002.Domestic Interchange'
                        when c.mastercard_region = 'D' and ct.card_feature = 'CFCHSTDR'
                        then '1003.International Within Europe'
                        when opi.card_country is not null and nvl (o.merchant_country, opi.card_country) is not null and ct.card_feature = 'CFCHSTDR'
                        then '1004.International Outside of Europe'
                        when o.sttl_type = 'STTT0010' and ct.card_feature = 'CFCHELEC'
                        then '1039.Domestic On-Us'
                        when opi.card_country = nvl(o.merchant_country, opi.card_country) and ct.card_feature = 'CFCHELEC'
                        then '1041.Domestic Interchange'
                        when c.mastercard_region = 'D' and ct.card_feature = 'CFCHELEC'
                        then '1042.International Within Europe'
                        when opi.card_country is not null and nvl (o.merchant_country, opi.card_country) is not null and ct.card_feature = 'CFCHELEC'
                        then '1043.International Outside of Europe'
                        else 'Unknown'
                   end as param_name
                 , opi.card_inst_id as inst_id
              from opr_operation o
                 , opr_participant opi
                 , opr_participant opa
                 , opr_card oc
                 , iss_card ic
                 , com_country c
                 , prd_contract ctr
                 , (select ct.id as card_type_id
                         , case when com_api_array_pkg.conv_array_elem_v(
                                           i_lov_id            => 130
                                         , i_array_type_id     => 1022
                                         , i_array_id          => 10000033
                                         , i_inst_id           => 9999
                                         , i_elem_value        => ct.id
                                       ) not in (1005)
                                then 'CFCHELEC'
                                else 'CFCHSTDR'
                           end
                           as card_feature
                      from net_card_type ct
                     where ct.network_id = 1002               -- MasterCard
                   ) ct
                 , (select element_value
                      from com_array_element
                     where array_id = 10000012) iss_sttl
                 , (select element_value
                      from com_array_element
                     where array_id = 10000014) oper_type
                 , (select element_value
                      from com_array_element
                     where array_id = 10000020) oper_status
             where o.is_reversal = 0
               and o.oper_type = oper_type.element_value
               and o.status = oper_status.element_value
               and o.sttl_type = iss_sttl.element_value
               and o.sttl_type = 'STTT0010'
               and o.msg_type in ('MSGTAUTH', 'MSGTCMPL')
               and o.id = opi.oper_id
               and opi.participant_type = 'PRTYISS'
               and o.id = opa.oper_id
               and opa.participant_type = 'PRTYACQ'
               and oc.oper_id = opi.oper_id
               and oc.participant_type = opi.participant_type
               and opi.card_id = ic.id
               and ic.contract_id = ctr.id
               and opi.card_type_id = ct.card_type_id
               and c.code = nvl (o.merchant_country, opi.card_country)
         ) o
     where o.group_name != 'Unknown' and o.param_name != 'Unknown'
/
