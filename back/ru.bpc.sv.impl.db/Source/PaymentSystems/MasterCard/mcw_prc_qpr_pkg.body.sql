create or replace package body mcw_prc_qpr_pkg is

    BULK_LIMIT                   constant integer := 500;

    BLOCKED_CARD_STATUSES        constant com_api_type_pkg.t_short_id := 10000071;
    ACTIVE_CARD_STATUSES         constant com_api_type_pkg.t_short_id := 10000073;
    NON_ACTIVATED_CARD_STATUSES  constant com_api_type_pkg.t_short_id := 10000074;
    
    type t_sepa_country_tab is table of com_api_type_pkg.t_boolean index by com_api_type_pkg.t_country_code;
    g_sepa_country          t_sepa_country_tab;

    -- MasterCard Acquiring
    cursor cu_data_group_1(
        i_dest_curr     com_api_type_pkg.t_curr_code
      , i_del_value     com_api_type_pkg.t_short_id
      , i_start_date    date
      , i_end_date      date
      , i_standard_id   com_api_type_pkg.t_tiny_id
      , i_host_id       com_api_type_pkg.t_tiny_id
      , i_rate_type     com_api_type_pkg.t_dict_value
      , i_network_id    com_api_type_pkg.t_short_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
    with cmid as (
        select
            distinct
            m.inst_id inst_id
            , v.param_value cmid
        from
            cmn_parameter p
            , net_api_interface_param_val_vw v
            , net_member m
        where
            p.name = mcw_api_const_pkg.CMID
            and p.standard_id = i_standard_id
            and p.id = v.param_id
            and m.id = v.consumer_member_id
            and v.host_member_id = i_host_id
            and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.month_number
         , t.group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) as value_1
         , sum(t.amount) as value_2
         , t.account_funding_source as value_3
      from (
            select cmid as cmid
                 , case group_name
                        when 'Sales'   then '123.RETAIL_SALES_PURCHASES'
                        when 'ATM'     then '125.ATM_CASH_ADVANCES'
                        when 'Manual'  then '126.MANUAL_CASH_ADVANCES'
                        when 'Refunds' then '127.REFUNDS_RETURNS_CREDITS'
                        else group_name
                   end
                   as group_name
                 , to_number(to_char(trunc(o.oper_date,'Q'), 'mm')) month_number
                 , param_name
                 , inst_id
                 , nn_trans
                 , decode(
                       o.currency
                     , i_dest_curr
                     , o.amount
                     , com_api_rate_pkg.convert_amount(
                           i_src_amount   => o.amount
                         , i_src_currency => o.currency
                         , i_dst_currency => i_dest_curr
                         , i_rate_type    => i_rate_type
                         , i_inst_id      => o.acq_inst_id
                         , i_eff_date     => o.oper_date
                         , i_mask_exception => 1
                         , i_exception_value => null
                       )
                   ) / i_del_value 
                   as amount
                   , o.account_funding_source as account_funding_source
              from (
                    select m.cmid
                         , case when o.is_iss = 1 then '1063.Domestic On-us'
                                when o.merchant_country = nvl(o.card_country, o.merchant_country) then '1065.Domestic Interchange'
                                when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then '1066.International Within Region'
                                else '1067.International Outside of Region'
--                                when o.merchant_country is not null and nvl(o.card_country, o.merchant_country) is not null then '1067.International Outside of Region'
--                                else 'Unknown'
                           end 
                           as param_name
                         , nvl(
                               com_api_array_pkg.conv_array_elem_v(
                                     i_lov_id            => 49 
                                   , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                   , i_array_id          => mcw_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                                   , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                   , i_elem_value        => o.oper_type
                              )
                              , 'Unknown'
                           )
                           as group_name
                         , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
                         , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) amount
                         , o.currency
                         , o.oper_date
                         , o.acq_inst_id
                         , m.inst_id
                         , case 
                             when o.account_funding_source = 'DEBIT'
                             then 0
                             when o.account_funding_source = 'CREDIT'
                             then 1
                             else 0
                          end as account_funding_source
                      from qpr_aggr o 
                         , cmid m
                         , com_country c
                     where o.is_acq = 1
                       and o.card_inst_id = m.inst_id
                       and o.card_network_id = i_network_id
                       and o.status in (select element_value
                                          from com_array_element
                                         where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                       and c.code = nvl(o.card_country, o.merchant_country)
                       and o.oper_date between i_start_date and i_end_date
                       and com_api_array_pkg.conv_array_elem_v(
                               i_lov_id            => 130 
                             , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                             , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                             , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                             , i_elem_value        => o.card_type_id
                           ) not in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                                   , mcw_api_const_pkg.QR_CIRRUS_CARD_TYPE)
                  group by m.cmid
                         , case when o.is_iss = 1 then '1063.Domestic On-us'
                                when o.merchant_country = nvl(o.card_country, o.merchant_country) then '1065.Domestic Interchange'
                                when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then '1066.International Within Region'
                                else '1067.International Outside of Region'
--                                when o.merchant_country is not null and nvl(o.card_country, o.merchant_country) is not null then '1067.International Outside of Region'
--                                else 'Unknown'
                           end 
                         , nvl(
                               com_api_array_pkg.conv_array_elem_v(
                                   i_lov_id            => 49 
                                 , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                 , i_array_id          => mcw_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                 , i_elem_value        => o.oper_type
                              )
                              , 'Unknown'
                           )
                         , o.currency
                         , o.oper_date
                         , o.acq_inst_id
                         , m.inst_id
                         , o.account_funding_source
                     union
                    select m.cmid
                         , case when o.is_iss = 1 then '1063.Domestic On-us'
                                when o.merchant_country = nvl(o.card_country, o.merchant_country) then '1065.Domestic Interchange'
                                when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then '1066.International Within Region'
                                else '1067.International Outside of Region'
--                                when o.merchant_country is not null and nvl(o.card_country, o.merchant_country) is not null then '1067.International Outside of Region'
--                                else 'Unknown'
                           end 
                           as param_name
                         , '124.TOTAL_CASH_ADVANCES'
                           as group_name
                         , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
                         , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) amount
                         , o.currency
                         , o.oper_date
                         , o.acq_inst_id
                         , m.inst_id
                         , case 
                             when o.account_funding_source = 'DEBIT'
                             then 0
                             when o.account_funding_source = 'CREDIT'
                             then 1
                             else 0
                          end as account_funding_source
                      from qpr_aggr o 
                         , cmid m
                         , com_country c
                     where o.is_acq = 1
                       and o.card_inst_id = m.inst_id
                       and o.card_network_id = i_network_id
                       and o.status in (select element_value
                                          from com_array_element
                                         where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                       and c.code = nvl(o.card_country, o.merchant_country)
                       and o.oper_date between i_start_date and i_end_date
                       and o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
                       and com_api_array_pkg.conv_array_elem_v(
                               i_lov_id            => 130 
                             , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                             , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                             , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                             , i_elem_value        => o.card_type_id
                           ) not in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE, mcw_api_const_pkg.QR_CIRRUS_CARD_TYPE)
                  group by m.cmid
                         , case when o.is_iss = 1 then '1063.Domestic On-us'
                                when o.merchant_country = nvl(o.card_country, o.merchant_country) then '1065.Domestic Interchange'
                                when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then '1066.International Within Region'
                                else '1067.International Outside of Region'
--                                when o.merchant_country is not null and nvl(o.card_country, o.merchant_country) is not null then '1067.International Outside of Region'
--                                else 'Unknown'
                           end 
                         , o.currency
                         , o.oper_date
                         , o.acq_inst_id
                         , m.inst_id
                         , o.account_funding_source
                   ) o
             where o.param_name <> 'Unknown'
               and o.group_name <> 'Unknown'
           ) t
  group by t.cmid
         , t.month_number
         , t.group_name
         , t.param_name
         , t.inst_id
         , t.account_funding_source;

    -- Maestro Acquiring
    cursor cu_data_group_1_1(
        i_dest_curr     com_api_type_pkg.t_curr_code
      , i_del_value     com_api_type_pkg.t_short_id
      , i_start_date    date
      , i_end_date      date
      , i_standard_id   com_api_type_pkg.t_tiny_id
      , i_host_id       com_api_type_pkg.t_tiny_id
      , i_rate_type     com_api_type_pkg.t_dict_value
      , i_network_id    com_api_type_pkg.t_short_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
    with cmid as (
        select
            distinct
            m.inst_id inst_id
            , v.param_value cmid
        from
            cmn_parameter p
            , net_api_interface_param_val_vw v
            , net_member m
        where
            p.name = mcw_api_const_pkg.CMID_MAESTRO
            and p.standard_id = i_standard_id
            and p.id = v.param_id
            and m.id = v.consumer_member_id
            and v.host_member_id = i_host_id
            and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.month_number
         , t.group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) as value_1
         , sum(t.amount) as value_2
      from (
            select cmid as cmid
                 , case group_name
                        when 'Sales'   then '131.MAESTRO_ACQUIRING_PURCHASE_ACTIVITY'
                        when 'ATM'     then '132.MAESTRO_ACQ_CASH_DISB_ACTIVITY'
                   end
                   as group_name
                 , to_number(to_char(trunc(o.oper_date,'Q'), 'mm')) month_number
                 , param_name
                 , inst_id
                 , nn_trans
                 , decode(
                       o.currency
                     , i_dest_curr
                     , o.amount
                     , com_api_rate_pkg.convert_amount(
                           i_src_amount   => o.amount
                         , i_src_currency => o.currency
                         , i_dst_currency => i_dest_curr
                         , i_rate_type    => i_rate_type
                         , i_inst_id      => o.acq_inst_id
                         , i_eff_date     => o.oper_date
                         , i_mask_exception => 1
                         , i_exception_value => null
                       )
                   ) / i_del_value 
                   as amount
              from (
                    select m.cmid
                         , case when o.is_iss = 1 then '1063.Domestic On-us'
                                when o.merchant_country = nvl(o.card_country, o.merchant_country) then '1065.Domestic Interchange'
                                when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then '1066.International Within Region'
                                else '1067.International Outside of Region'
--                                when o.merchant_country is not null and nvl(o.card_country, o.merchant_country) is not null then '1067.International Outside of Region'
--                                else 'Unknown'
                           end 
                           as param_name
                         , nvl(
                               com_api_array_pkg.conv_array_elem_v(
                                     i_lov_id            => 49 
                                   , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                   , i_array_id          => mcw_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                                   , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                   , i_elem_value        => o.oper_type
                              )
                              , 'Unknown'
                           )
                           as group_name
                         , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
                         , sum (decode(o.is_reversal, 1, -1, 1) * o.amount) amount
                         , o.currency
                         , o.oper_date
                         , o.acq_inst_id
                         , m.inst_id
                      from qpr_aggr o 
                         , cmid m
                         , com_country c
                     where o.is_acq = 1
                       and o.card_inst_id = m.inst_id
                       and o.card_network_id = i_network_id
                       and o.status in (select element_value
                                          from com_array_element
                                         where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                       and c.code = nvl(o.card_country, o.merchant_country)
                       and o.oper_date between i_start_date and i_end_date
                       and com_api_array_pkg.conv_array_elem_v(
                               i_lov_id            => 130 
                             , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                             , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                             , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                             , i_elem_value        => o.card_type_id
                           ) in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE)
                  group by m.cmid
                         , case when o.is_iss = 1 then '1063.Domestic On-us'
                                when o.merchant_country = nvl(o.card_country, o.merchant_country) then '1065.Domestic Interchange'
                                when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then '1066.International Within Region'
                                else '1067.International Outside of Region'
--                                when o.merchant_country is not null and nvl(o.card_country, o.merchant_country) is not null then '1067.International Outside of Region'
--                                else 'Unknown'
                           end 
                         , nvl(
                               com_api_array_pkg.conv_array_elem_v(
                                   i_lov_id            => 49 
                                 , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                 , i_array_id          => mcw_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                 , i_elem_value        => o.oper_type
                              )
                              , 'Unknown'
                           )
                         , o.currency
                         , o.oper_date
                         , o.acq_inst_id
                         , m.inst_id
                   ) o
             where o.param_name <> 'Unknown'
               and o.group_name in ('Sales', 'ATM')
           ) t
  group by t.cmid
         , t.month_number
         , t.group_name
         , t.param_name
         , t.inst_id;

--Acquiring MasterCard IV. Acceptance
    cursor cu_data_group_2(
      i_start_date      date
      , i_end_date      date
      , i_standard_id   com_api_type_pkg.t_tiny_id
      , i_host_id       com_api_type_pkg.t_tiny_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
       with cmid as (
              select distinct m.inst_id as inst_id, v.param_value as cmid
                from cmn_parameter p
                   , net_api_interface_param_val_vw v
                   , net_member m
               where p.name = mcw_api_const_pkg.CMID
                 and p.standard_id = i_standard_id
                 and p.id = v.param_id
                 and m.id = v.consumer_member_id
                 and v.host_member_id = i_host_id
                 and (m.inst_id = i_inst_id or i_inst_id is null)
        )
        select t.cmid
             , t.param_name
             , t.group_name
             , t.inst_id
             , null      as value_1
             , sum(t.nn) as value_2
          from (
                select cmid
                     , param_name
                     , group_name
                     , inst_id
                     , nn
                  from (
                    select distinct cmid.cmid as cmid
                         , '1069.Cash_obtained' as param_name
                         , '129.CASH_DISBURSEMENT_LOCATIONS' as group_name
                         , cmid.inst_id
                         , 1 as nn
                         , acq.id
                      from acq_terminal trm
                         , acq_merchant acq
                         , cmid
                     where trm.merchant_id    = acq.id
                       and trm.is_template    = 0
                       and trm.inst_id        = acq.inst_id
                       and acq.inst_id        = cmid.inst_id
                       and acq.mcc            = mcw_api_const_pkg.MCC_CASH
                       and nvl(trm.mcc, acq.mcc) = mcw_api_const_pkg.MCC_CASH
                       and trm.status         = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                       and (select min(pso.start_date)
                              from prd_service_object pso
                             where pso.object_id = acq.id
                               and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                           ) <= i_end_date
                  )
                union all
                select cmid.cmid as cmid
                     , '1070.Number_of_ATM' as param_name
                     , '129.CASH_DISBURSEMENT_LOCATIONS' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid
                 where trm.merchant_id    = acq.id
                   and trm.is_template    = 0
                   and trm.inst_id        = acq.inst_id
                   and acq.inst_id        = cmid.inst_id
                   and acq.mcc            in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and nvl(trm.mcc, acq.mcc) = mcw_api_const_pkg.MCC_ATM
                   and trm.status         = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                union all   
                select cmid.cmid as cmid
                     , '1071.Non_MasterCard_approved_EMV_chip' as param_name
                     , '129.CASH_DISBURSEMENT_LOCATIONS' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid
                 where trm.merchant_id    = acq.id
                   and trm.is_template    = 0
                   and trm.inst_id        = acq.inst_id
                   and acq.inst_id        = cmid.inst_id
                   and acq.mcc            in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and nvl(trm.mcc, acq.mcc) = mcw_api_const_pkg.MCC_ATM
                   and trm.status         = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                union all   
                select cmid.cmid as cmid
                     , '1072.Number_MasterCard_merchants' as param_name
                     , '130.MERCHANTS' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_merchant acq
                     , cmid
                 where acq.inst_id    = cmid.inst_id
                   and acq.parent_id  is null
                   and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and exists (select 1 from acq_terminal trm
                                where trm.merchant_id = acq.id
                                  and trm.inst_id     = acq.inst_id
                                  and trm.status      = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE)
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date 
                union all   
                select cmid.cmid as cmid
                     , '1073.Number_new_merchants' as param_name
                     , '130.MERCHANTS' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_merchant acq
                     , cmid
                 where acq.inst_id    = cmid.inst_id
                   and acq.parent_id  is null
                   and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and acq.status     = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
                   and exists (select 1 from acq_terminal trm
                                where trm.merchant_id = acq.id
                                  and trm.inst_id     = acq.inst_id
                                  and trm.status      = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE)
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) between i_start_date and i_end_date                   
                union all   
                select cmid.cmid as cmid
                     , '1074.Number_lost_merchants' as param_name
                     , '130.MERCHANTS' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_merchant acq
                     , cmid
                 where acq.inst_id    = cmid.inst_id
                   and acq.parent_id  is null
                   and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and acq.status     != acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
                   and exists (select 1 from acq_terminal trm
                                where trm.merchant_id = acq.id
                                  and trm.inst_id     = acq.inst_id
                                  and trm.status     != acq_api_const_pkg.TERMINAL_STATUS_ACTIVE)
                   and (select max(pso.end_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) between i_start_date and i_end_date
                union all
                select cmid
                     , param_name
                     , group_name
                     , inst_id
                     , nn    
                  from (
                    select distinct cmid.cmid as cmid
                         , '1075.Total_merchant_locations' as param_name
                         , '130.MERCHANTS' as group_name
                         , com_api_address_pkg.get_address_string(o.address_id)
                         , acq.id
                         , cmid.inst_id
                         , 1 as nn
                      from acq_terminal trm
                         , acq_merchant acq
                         , com_address_object o
                         , cmid
                     where trm.merchant_id = acq.id
                       and trm.inst_id    = acq.inst_id
                       and acq.inst_id    = cmid.inst_id
                       and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                       and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and o.object_id    = trm.id
                       and trm.status      = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                       and (select min(pso.start_date)
                              from prd_service_object pso
                             where pso.object_id = acq.id
                               and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                           ) <= i_end_date
                 ) m
                union all
                select cmid
                     , param_name
                     , group_name
                     , inst_id
                     , nn    
                  from (
                    select distinct cmid.cmid as cmid
                         , '1076.New_merchant_locations' as param_name
                         , '130.MERCHANTS' as group_name
                         , com_api_address_pkg.get_address_string(o.address_id)
                         , acq.id
                         , cmid.inst_id
                         , 1 as nn
                      from acq_terminal trm
                         , acq_merchant acq
                         , cmid
                         , com_address_object o
                     where trm.merchant_id = acq.id
                       and trm.inst_id    = acq.inst_id
                       and acq.inst_id    = cmid.inst_id
                       and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                       and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and o.object_id    = trm.id
                       and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                       and (select min(pso.start_date)
                              from prd_service_object pso
                             where pso.object_id = acq.id
                               and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                           ) between i_start_date and i_end_date                   
                ) m
                union all
                select cmid
                     , param_name
                     , group_name
                     , inst_id
                     , nn    
                  from (
                    select distinct cmid.cmid as cmid
                         , '1077.Merchant_lost_locations' as param_name
                         , '130.MERCHANTS' as group_name
                         , com_api_address_pkg.get_address_string(o.address_id)
                         , acq.id
                         , cmid.inst_id
                         , 1 as nn
                      from acq_terminal trm
                         , acq_merchant acq
                         , cmid
                         , com_address_object o
                     where trm.merchant_id = acq.id
                       and trm.inst_id    = acq.inst_id
                       and acq.inst_id    = cmid.inst_id
                       and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                       and acq.status     != acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
                       and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and o.object_id    = trm.id
                       and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                       and (select min(pso.end_date)
                              from prd_service_object pso
                             where pso.object_id = acq.id
                               and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                           ) between i_start_date and i_end_date                   
                ) m
                union all
                select cmid.cmid as cmid
                     , '1078.Number_of_POS' as param_name
                     , '130.MERCHANTS' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid
                 where trm.merchant_id = acq.id
                   and trm.inst_id    = acq.inst_id
                   and acq.inst_id    = cmid.inst_id
                   and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                union all
                select cmid.cmid as cmid
                     , '1079.Number_of_EMV_chip' as param_name
                     , '130.MERCHANTS' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid
                 where trm.merchant_id = acq.id
                   and trm.inst_id    = acq.inst_id
                   and acq.inst_id    = cmid.inst_id
                   and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and trm.card_data_input_cap in ('F2210005', 'F221000C', 'F221000D', 'F221000E')
                   and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                union all
                select cmid.cmid as cmid
                     , '1080.Number_of_PIN_PAD_EMV_chip' as param_name
                     , '130.MERCHANTS' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid
                 where trm.merchant_id = acq.id
                   and trm.inst_id    = acq.inst_id
                   and acq.inst_id    = cmid.inst_id
                   and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and trm.crdh_auth_method = 'F2280001'
                   and trm.crdh_auth_cap    = 'F2220008'
                   and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                union all                
                 select cmid
                     , param_name
                     , group_name
                     , inst_id
                     , nn    
                  from (
                    select distinct cmid.cmid as cmid
                         , '1081.Number_of_PayPass' as param_name
                         , '130.MERCHANTS' as group_name
                         , com_api_address_pkg.get_address_string(o.address_id)
                         , acq.id
                         , cmid.inst_id
                         , 1 as nn
                      from acq_terminal trm
                         , acq_merchant acq
                         , cmid
                         , com_address_object o
                     where trm.merchant_id = acq.id
                       and trm.inst_id    = acq.inst_id
                       and acq.inst_id    = cmid.inst_id
                       and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                       and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and o.object_id    = trm.id
                       and trm.card_data_input_cap in ('F221000A','F221000M','F221000P')
                       and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                       and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                ) m
                union all                
                select cmid.cmid as cmid
                     , '1082.Number_PayPass_terminal' as param_name
                     , '130.MERCHANTS' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid
                 where trm.merchant_id = acq.id
                   and trm.inst_id    = acq.inst_id
                   and acq.inst_id    = cmid.inst_id
                   and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and trm.card_data_input_cap in ('F221000A','F221000M','F221000P')
                   and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
               ) t
      group by t.cmid
             , t.param_name
             , t.group_name
             , t.inst_id;

--Acquiring Maestro Acceptance
    cursor cu_data_group_3(
      i_start_date      date
      , i_end_date      date
      , i_standard_id   com_api_type_pkg.t_tiny_id
      , i_host_id       com_api_type_pkg.t_tiny_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
       with cmid as (
              select distinct m.inst_id as inst_id, v.param_value as cmid
                from cmn_parameter p
                   , net_api_interface_param_val_vw v
                   , net_member m
               where p.name = mcw_api_const_pkg.CMID_MAESTRO
                 and p.standard_id = i_standard_id
                 and p.id = v.param_id
                 and m.id = v.consumer_member_id
                 and v.host_member_id = i_host_id
                 and (m.inst_id = i_inst_id or i_inst_id is null)
        )
        select t.cmid
             , t.param_name
             , t.group_name
             , t.inst_id
             , null      as value_1
             , sum(t.nn) as value_2
          from (
                select cmid.cmid as cmid
                     , '1083.Number_ATM_Maestro' as param_name
                     , '133.MAESTRO_ACCEPTANCE' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid
                 where trm.merchant_id    = acq.id
                   and trm.is_template    = 0
                   and trm.inst_id        = acq.inst_id
                   and acq.inst_id        = cmid.inst_id
                   and acq.mcc            in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and nvl(trm.mcc, acq.mcc) = mcw_api_const_pkg.MCC_ATM
                   and trm.status         = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                union all
                select cmid.cmid as cmid
                     , '1084.Number_EMV_chip_Maestro' as param_name
                     , '133.MAESTRO_ACCEPTANCE' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid
                 where trm.merchant_id    = acq.id
                   and trm.is_template    = 0
                   and trm.inst_id        = acq.inst_id
                   and acq.inst_id        = cmid.inst_id
                   and acq.mcc            in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and nvl(trm.mcc, acq.mcc) = mcw_api_const_pkg.MCC_ATM
                   and trm.status         = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                union all   
                select cmid.cmid as cmid
                     , '1085.Number_merchants_Maestro' as param_name
                     , '133.MAESTRO_ACCEPTANCE' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_merchant acq
                     , cmid
                 where acq.inst_id    = cmid.inst_id
                   and acq.parent_id  is null
                   and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and exists (select 1 from acq_terminal trm
                                where trm.merchant_id = acq.id
                                  and trm.inst_id     = acq.inst_id
                                  and trm.status      = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE)
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                union all   
                select cmid
                     , param_name
                     , group_name
                     , inst_id
                     , nn    
                  from (
                    select distinct cmid.cmid as cmid
                         , '1086.Number_merchant_locations_Maestro' as param_name
                         , '133.MAESTRO_ACCEPTANCE' as group_name
                         , com_api_address_pkg.get_address_string(o.address_id)
                         , acq.id
                         , cmid.inst_id
                         , 1 as nn
                      from acq_terminal trm
                         , acq_merchant acq
                         , com_address_object o
                         , cmid
                     where trm.merchant_id = acq.id
                       and trm.inst_id    = acq.inst_id
                       and acq.inst_id    = cmid.inst_id
                       and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                       and acq.status     = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
                       and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and o.object_id    = trm.id
                       and (select min(pso.start_date)
                              from prd_service_object pso
                             where pso.object_id = acq.id
                               and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                           ) <= i_end_date
                 ) m
                union all
                select cmid.cmid as cmid
                     , '1087.Number_POS_Maestro' as param_name
                     , '133.MAESTRO_ACCEPTANCE' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid
                 where trm.merchant_id = acq.id
                   and trm.inst_id    = acq.inst_id
                   and acq.inst_id    = cmid.inst_id
                   and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                union all
                select cmid.cmid as cmid
                     , '1088.Number_EMV_chip_Maestro' as param_name
                     , '133.MAESTRO_ACCEPTANCE' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid
                 where trm.merchant_id = acq.id
                   and trm.inst_id    = acq.inst_id
                   and acq.inst_id    = cmid.inst_id
                   and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and trm.card_data_input_cap in ('F2210005', 'F221000C', 'F221000D', 'F221000E')
                   and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                union all
                select cmid.cmid as cmid
                     , '1089.Number_terminal_PIN_PAD' as param_name
                     , '133.MAESTRO_ACCEPTANCE' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid
                 where trm.merchant_id = acq.id
                   and trm.inst_id    = acq.inst_id
                   and acq.inst_id    = cmid.inst_id
                   and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and trm.crdh_auth_method = 'F2280001'
                   and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                union all
                 select cmid
                     , param_name
                     , group_name
                     , inst_id
                     , nn
                  from (
                    select distinct cmid.cmid as cmid
                         , '1090.Number_locations_PayPass_Maestro' as param_name
                         , '133.MAESTRO_ACCEPTANCE' as group_name
                         , com_api_address_pkg.get_address_string(o.address_id)
                         , acq.id
                         , cmid.inst_id
                         , 1 as nn
                      from acq_terminal trm
                         , acq_merchant acq
                         , cmid
                         , com_address_object o
                     where trm.merchant_id = acq.id
                       and trm.inst_id    = acq.inst_id
                       and acq.inst_id    = cmid.inst_id
                       and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                       and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and o.object_id    = trm.id
                       and trm.card_data_input_cap in ('F221000A','F221000M','F221000P')
                       and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                       and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                ) m
                union all
                select cmid.cmid as cmid
                     , '1091.Number_terminals_PayPass_Maestro' as param_name
                     , '133.MAESTRO_ACCEPTANCE' as group_name
                     , cmid.inst_id
                     , 1 as nn
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid
                 where trm.merchant_id = acq.id
                   and trm.inst_id    = acq.inst_id
                   and acq.inst_id    = cmid.inst_id
                   and acq.mcc        not in (mcw_api_const_pkg.MCC_CASH, mcw_api_const_pkg.MCC_ATM)
                   and trm.card_data_input_cap in ('F221000A','F221000M','F221000P')
                   and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
               ) t
      group by t.cmid
             , t.param_name
             , t.group_name
             , t.inst_id;

    -- MasterCard Issuing
    cursor cu_data_group_4(
        i_dest_curr     com_api_type_pkg.t_curr_code
      , i_del_value     com_api_type_pkg.t_short_id
      , i_start_date    date
      , i_end_date      date
      , i_standard_id   com_api_type_pkg.t_tiny_id
      , i_host_id       com_api_type_pkg.t_tiny_id
      , i_rate_type     com_api_type_pkg.t_dict_value
      , i_network_id    com_api_type_pkg.t_short_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
    with cmid as (
        select
            distinct
            m.inst_id inst_id
            , v.param_value cmid
        from
            cmn_parameter p
            , net_api_interface_param_val_vw v
            , net_member m
        where
            p.name = mcw_api_const_pkg.CMID
            and p.standard_id = i_standard_id
            and p.id = v.param_id
            and m.id = v.consumer_member_id
            and v.host_member_id = i_host_id
            and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    , trx_data as (
        select m.cmid
             , case when o.is_acq = 1 then '1000.Domestic On-us'
                    when o.card_country = nvl(o.merchant_country, o.card_country) then '1002.Domestic Interchange'
                    when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then '1003.International Within Region'
                    else '1004.International Outside of Region'
--                    when o.card_country is not null and nvl(o.merchant_country, o.card_country) is not null then '1004.International Outside of Region'
--                    else 'Unknown'
               end 
               as param_name
             , nvl(
                   com_api_array_pkg.conv_array_elem_v(
                         i_lov_id            => 49 
                       , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                       , i_array_id          => mcw_api_const_pkg.QR_ISS_OPER_TYPE_ARRAY
                       , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                       , i_elem_value        => o.oper_type
                  )
                  , 'Unknown'
               )
               as group_name
             , com_api_array_pkg.conv_array_elem_v(
                     i_lov_id            => 130 
                   , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                   , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                   , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                   , i_elem_value        => o.card_type_id
               ) 
               as card_type_id
             , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
             , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) amount
             , o.currency
             , o.oper_date
             , o.card_inst_id
             , m.inst_id
             , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end as card_feature 
             , o.mcc
             , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
          from qpr_aggr o 
             , (select cf.card_type_id
                     , cf.card_feature
                  from net_card_type ct
                     , net_card_type_feature cf
                 where ct.network_id = i_network_id
                   and ct.id = cf.card_type_id
                   and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
               ) ctd
             , cmid m
             , com_country c
         where o.is_iss = 1
           and o.card_inst_id = m.inst_id
           and o.card_network_id = i_network_id
           and o.status in (select element_value
                              from com_array_element
                             where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
           and c.code = nvl(o.merchant_country, o.card_country)
           and o.oper_date between i_start_date and i_end_date
           and o.card_type_id = ctd.card_type_id(+)
           and com_api_array_pkg.conv_array_elem_v(
                   i_lov_id            => 130 
                 , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                 , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                 , i_elem_value        => o.card_type_id
               ) not in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                       , mcw_api_const_pkg.QR_CIRRUS_CARD_TYPE)
      group by m.cmid
             , case when o.is_acq = 1 then '1000.Domestic On-us'
                    when o.card_country = nvl(o.merchant_country, o.card_country) then '1002.Domestic Interchange'
                    when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then '1003.International Within Region'
                    else '1004.International Outside of Region'
--                    when o.card_country is not null and nvl(o.merchant_country, o.card_country) is not null then '1004.International Outside of Region'
--                    else 'Unknown'
               end 
             , nvl(
                   com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49 
                     , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => mcw_api_const_pkg.QR_ISS_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                  )
                  , 'Unknown'
               )
             , com_api_array_pkg.conv_array_elem_v(
                   i_lov_id            => 130 
                 , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                 , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                 , i_elem_value        => o.card_type_id
               ) 
             , o.currency
             , o.oper_date
             , o.card_inst_id
             , m.inst_id
             , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end
             , o.mcc
             , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end
         union
        select m.cmid
             , case when o.is_acq = 1 then '1000.Domestic On-us'
                    when o.card_country = nvl(o.merchant_country, o.card_country) then '1002.Domestic Interchange'
                    when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then '1003.International Within Region'
                    else '1004.International Outside of Region'
--                    when o.card_country is not null and nvl(o.merchant_country, o.card_country) is not null then '1004.International Outside of Region'
--                    else 'Unknown'
               end 
               as param_name
             , '102.TOTAL_CASH_ADVANCES'
               as group_name
             , com_api_array_pkg.conv_array_elem_v(
                     i_lov_id            => 130 
                   , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                   , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                   , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                   , i_elem_value        => o.card_type_id
               ) 
               as card_type_id
             , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
             , sum (decode(o.is_reversal, 1, -1, 1) * o.amount) amount
             , o.currency
             , o.oper_date
             , o.card_inst_id
             , m.inst_id
             , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end as card_feature
             , o.mcc
             , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
          from qpr_aggr o 
             , (select cf.card_type_id
                     , cf.card_feature
                  from net_card_type ct
                     , net_card_type_feature cf
                 where ct.network_id = i_network_id
                   and ct.id = cf.card_type_id
                   and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
               ) ctd
             , cmid m
             , com_country c
         where o.is_iss = 1
           and o.card_inst_id = m.inst_id
           and o.card_network_id = i_network_id
           and o.status in (select element_value
                              from com_array_element
                             where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
           and c.code = nvl(o.merchant_country, o.card_country)
           and o.oper_date between i_start_date and i_end_date
           and o.card_type_id = ctd.card_type_id(+)
           and com_api_array_pkg.conv_array_elem_v(
                   i_lov_id            => 130 
                 , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                 , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                 , i_elem_value        => o.card_type_id
               ) not in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                       , mcw_api_const_pkg.QR_CIRRUS_CARD_TYPE)
           and com_api_array_pkg.conv_array_elem_v(
                         i_lov_id            => 49 
                       , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                       , i_array_id          => mcw_api_const_pkg.QR_ISS_OPER_TYPE_ARRAY
                       , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                       , i_elem_value        => o.oper_type
                  ) in ('ATM', 'Manual')
      group by m.cmid
             , case when o.is_acq = 1 then '1000.Domestic On-us'
                    when o.card_country = nvl(o.merchant_country, o.card_country) then '1002.Domestic Interchange'
                    when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then '1003.International Within Region'
                    else '1004.International Outside of Region'
--                    when o.card_country is not null and nvl(o.merchant_country, o.card_country) is not null then '1004.International Outside of Region'
--                    else 'Unknown'
               end 
             , com_api_array_pkg.conv_array_elem_v(
                   i_lov_id            => 130 
                 , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                 , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                 , i_elem_value        => o.card_type_id
               ) 
             , o.currency
             , o.oper_date
             , o.card_inst_id
             , m.inst_id
             , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end
             , o.mcc
             , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end
    )
    select t.cmid
         , t.card_type
         , t.month_number
         , t.group_name
         , t.param_name
         , t.inst_id
         , null            as value_1
         , sum(t.nn_trans) as value_2
         , sum(t.amount)   as value_3
         , t.card_type_id
         , t.card_type_feature
      from (
            select cmid as cmid
                 , case group_name
                        when 'Sales'   then '101.PURCHASES'
                        when 'ATM'     then '103.ATM_CASH_ADVANCES'
                        when 'Manual'  then '104.MANUAL_CASH_ADVANCES'
                        when 'Refunds' then '105.REFUNDS_RETURNS_CREDITS'
                        else group_name
                   end
                   as group_name
                 , get_text (
                         i_table_name  => 'net_card_type'
                       , i_column_name => 'name'
                       , i_object_id   => o.card_type_id
                   ) || ' - '|| o.card_feature
                   as card_type
                 , to_number(to_char(trunc(o.oper_date,'Q'), 'mm')) month_number
                 , param_name
                 , inst_id
                 , nn_trans
                 , decode(
                       o.currency
                     , i_dest_curr
                     , o.amount
                     , com_api_rate_pkg.convert_amount(
                           i_src_amount   => o.amount
                         , i_src_currency => o.currency
                         , i_dst_currency => i_dest_curr
                         , i_rate_type    => i_rate_type
                         , i_inst_id      => o.card_inst_id
                         , i_eff_date     => o.oper_date
                         , i_mask_exception => 1
                         , i_exception_value => null
                       )
                   ) / i_del_value 
                   as amount
                 , o.card_type_id
                 , o.card_type_feature
              from trx_data o
             where o.param_name <> 'Unknown'
               and o.group_name <> 'Unknown'
            union all
            select cmid as cmid
                 , '223.Breakdown of Cash Disbursements' as group_name
                 , get_text (
                         i_table_name  => 'net_card_type'
                       , i_column_name => 'name'
                       , i_object_id   => o.card_type_id
                   ) || ' - '|| o.card_feature
                   as card_type
                 , to_number(to_char(trunc(o.oper_date,'Q'), 'mm')) month_number
                 , case 
                       when o.group_name = 'ATM' 
                       then
                           '2054.ATM Cash Disbursements'
                       when o.group_name = 'Manual' then
                           '2055.Teller Cash Disbursements'
                       else
                           null
                   end as param_name
                 , inst_id
                 , nn_trans
                 , decode(
                       o.currency
                     , i_dest_curr
                     , o.amount
                     , com_api_rate_pkg.convert_amount(
                           i_src_amount   => o.amount
                         , i_src_currency => o.currency
                         , i_dst_currency => i_dest_curr
                         , i_rate_type    => i_rate_type
                         , i_inst_id      => o.card_inst_id
                         , i_eff_date     => o.oper_date
                         , i_mask_exception => 1
                         , i_exception_value => null
                       )
                   ) / i_del_value 
                   as amount
                 , o.card_type_id
                 , o.card_type_feature
              from trx_data o
             where o.group_name in ('ATM', 'Manual')
           ) t
  group by t.cmid
         , t.card_type
         , t.month_number
         , t.group_name
         , t.param_name
         , t.inst_id
         , t.card_type_id
         , t.card_type_feature;

    -- MasterCard Issuing Accounts at beginning of quarter
    cursor cu_data_group_4_1(
        i_quarter      com_api_type_pkg.t_tiny_id
      , i_start_date   date
      , i_end_date     date
      , i_standard_id  com_api_type_pkg.t_tiny_id
      , i_host_id      com_api_type_pkg.t_tiny_id
      , i_network_id   com_api_type_pkg.t_short_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
    with cmid as (
        select
            distinct
            m.inst_id inst_id
            , v.param_value cmid
        from
            cmn_parameter p
            , net_api_interface_param_val_vw v
            , net_member m
        where
            p.name = mcw_api_const_pkg.CMID
            and p.standard_id = i_standard_id
            and p.id = v.param_id
            and m.id = v.consumer_member_id
            and v.host_member_id = i_host_id
            and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select cmid
         , card_type
         , month_num
         , '106.ACCOUNTS_CARDS' as group_name
         , '1007.Accounts at beginning of quarter' as param_name
         , inst_id
         , count(distinct case when status  = 'ACSTACTV' then acct_id else null end ) as value_1  -- open
         , count(distinct case when status != 'ACSTACTV' then acct_id else null end ) as value_2  -- blocked
         , count(distinct case when status  = 'ACSTACTV' then acct_id else null end ) +
           count(distinct case when status != 'ACSTACTV' then acct_id else null end ) as value_3  -- Total as sum of open and blocked
         , card_type_id
         , card_type_feature
      from (
            select cmid as cmid
                 , i_quarter * 3 - 2 as month_num
                 , det.card_type || ' - '|| det.card_feature as card_type
                 , det.acct_id as acct_id
                 , inst_id
                 , status
                 , card_type_id
                 , card_type_feature
            from (select cmid.cmid   
                       , get_text (
                              i_table_name     => 'net_card_type'
                              , i_column_name  => 'name'
                              , i_object_id    => main_card_type_id
                         )
                         as card_type
                       , aa.id as acct_id
                       , cmid.inst_id
                       , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end as card_feature
                       , aa.status
                       , main_card_type_id as card_type_id
                       , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
                    from iss_card ic
                       , (select nct.id as card_type_id
                               , com_api_array_pkg.conv_array_elem_v(
                                          i_lov_id            => 130 
                                        , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                        , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                        , i_elem_value        => nct.id
                                 ) as main_card_type_id
                            from net_card_type nct
                           where nct.network_id = i_network_id
                         ) card_type
                       , (select cf.card_type_id
                               , cf.card_feature
                            from net_card_type ct
                               , net_card_type_feature cf
                           where ct.network_id   = i_network_id
                             and ct.id           = cf.card_type_id
                             and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
                         ) ctd
                       , acc_account_object aao
                       , acc_account aa
                       , acc_balance_vw abv
                       , cmid                          
                       , iss_card_instance ci
                   where ic.id              = aao.object_id
                     and ic.inst_id         = cmid.inst_id
                     and aao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                     and aa.id              = aao.account_id
                     and ic.card_type_id    = card_type.card_type_id
                     and ic.card_type_id    = ctd.card_type_id(+)
                     and abv.account_id     = aa.id
                     and abv.balance_type   = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                     and abv.open_date      < i_start_date
                     and ci.card_id         = ic.id
                     and ci.expir_date      > i_end_date
                     and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date + 1
                     and card_type.main_card_type_id not in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                                                           , mcw_api_const_pkg.QR_CIRRUS_CARD_TYPE)
                 ) det
        ) det2
        group by cmid, month_num, card_type, inst_id, card_type_id, card_type_feature;

    -- MasterCard Issuing New accounts obtained during quarter
    cursor cu_data_group_4_2(
        i_quarter      com_api_type_pkg.t_tiny_id
      , i_start_date   date
      , i_end_date     date
      , i_standard_id  com_api_type_pkg.t_tiny_id
      , i_host_id      com_api_type_pkg.t_tiny_id
      , i_network_id   com_api_type_pkg.t_short_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select
            distinct
            m.inst_id inst_id
            , v.param_value cmid
        from
            cmn_parameter p
            , net_api_interface_param_val_vw v
            , net_member m
        where
            p.name = mcw_api_const_pkg.CMID
            and p.standard_id = i_standard_id
            and p.id = v.param_id
            and m.id = v.consumer_member_id
            and v.host_member_id = i_host_id
            and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select cmid
         , card_type
         , month_num
         , '106.ACCOUNTS_CARDS' as group_name
         , '1008.New accounts obtained during quarter' as param_name
         , inst_id
         , null /*count(distinct case when status  = 'ACSTACTV' then acct_id else null end )*/  as value_1  -- open
         , null /*count(distinct case when status != 'ACSTACTV' then acct_id else null end )*/  as value_2  -- blocked
         , count(distinct acct_id) as value_3  -- Total
         , card_type_id
         , card_type_feature
      from (
            select det1.cmid as cmid
                 , i_quarter * 3 - 2 as month_num
                 , det1.card_type || ' - '|| det1.card_feature as card_type
                 , det.acct_id as acct_id
                 , det1.inst_id
                 , det1.status
                 , det1.card_type_id
                 , det1.card_type_feature
            from (select cmid.cmid   
                       , get_text (
                              i_table_name     => 'net_card_type'
                              , i_column_name  => 'name'
                              , i_object_id    => main_card_type_id
                         ) as card_type
                       , aa.id as acct_id
                       , cmid.inst_id
                       , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end as card_feature
                       , aa.status
                       , main_card_type_id as card_type_id
                       , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
                    from iss_card ic
                       , (select nct.id as card_type_id
                               , com_api_array_pkg.conv_array_elem_v(
                                          i_lov_id            => 130 
                                        , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                        , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                        , i_elem_value        => nct.id
                                 ) as main_card_type_id
                            from net_card_type nct
                           where nct.network_id = i_network_id
                         ) card_type
                       , (select cf.card_type_id
                               , cf.card_feature
                            from net_card_type ct
                               , net_card_type_feature cf
                           where ct.network_id   = i_network_id
                             and ct.id           = cf.card_type_id
                             and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
                         ) ctd
                       , acc_account_object aao
                       , acc_account aa
                       , acc_balance_vw abv
                       , cmid 
                       , iss_card_instance ci                         
                   where ic.id              = aao.object_id
                     and ic.inst_id         = cmid.inst_id
                     and aao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                     and aa.id              = aao.account_id
                     and ic.card_type_id    = card_type.card_type_id
                     and ic.card_type_id    = ctd.card_type_id(+)
                     and abv.account_id     = aa.id
                     and abv.balance_type   = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                     and abv.open_date      between i_start_date and i_end_date
                     and ci.card_id         = ic.id
                     and ci.expir_date      > i_end_date
                     and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date + 1
                     and card_type.main_card_type_id not in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                                                           , mcw_api_const_pkg.QR_CIRRUS_CARD_TYPE)
                 ) det
               , (select cmid.cmid   
                       , get_text (
                              i_table_name     => 'net_card_type'
                              , i_column_name  => 'name'
                              , i_object_id    => main_card_type_id
                         ) as card_type
                       , aa.id as acct_id
                       , cmid.inst_id
                       , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end as card_feature
                       , aa.status
                       , main_card_type_id as card_type_id
                       , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
                    from iss_card ic
                       , (select nct.id as card_type_id
                               , com_api_array_pkg.conv_array_elem_v(
                                          i_lov_id            => 130 
                                        , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                        , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                        , i_elem_value        => nct.id
                                 ) as main_card_type_id
                            from net_card_type nct
                           where nct.network_id = i_network_id
                         ) card_type
                       , (select cf.card_type_id
                               , cf.card_feature
                            from net_card_type ct
                               , net_card_type_feature cf
                           where ct.network_id   = i_network_id
                             and ct.id           = cf.card_type_id
                             and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
                         ) ctd
                       , acc_account_object aao
                       , acc_account aa
                       , acc_balance_vw abv
                       , cmid    
                       , iss_card_instance ci                      
                   where ic.id              = aao.object_id
                     and ic.inst_id         = cmid.inst_id
                     and aao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                     and aa.id              = aao.account_id
                     and ic.card_type_id    = card_type.card_type_id
                     and ic.card_type_id    = ctd.card_type_id(+)
                     and abv.account_id     = aa.id
                     and abv.balance_type   = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                     and abv.open_date      <= i_end_date
                     and ci.card_id         = ic.id
                     and ci.expir_date      > i_end_date
                     and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date + 1
                     and card_type.main_card_type_id not in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                                                           , mcw_api_const_pkg.QR_CIRRUS_CARD_TYPE)
                 ) det1
           where det1.cmid = det.cmid(+)
             and det1.card_type_id = det.card_type_id(+)
             and det1.inst_id = det.inst_id(+)
        ) det2
        group by cmid, month_num, card_type, inst_id, card_type_id, card_type_feature;

    -- MasterCard Issuing Accounts at end of quarter
    cursor cu_data_group_4_3(
        i_quarter      com_api_type_pkg.t_tiny_id
      , i_start_date   date
      , i_end_date     date
      , i_standard_id  com_api_type_pkg.t_tiny_id
      , i_host_id      com_api_type_pkg.t_tiny_id
      , i_network_id   com_api_type_pkg.t_short_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
    with cmid as (
        select
            distinct
            m.inst_id inst_id
            , v.param_value cmid
        from
            cmn_parameter p
            , net_api_interface_param_val_vw v
            , net_member m
        where
            p.name = mcw_api_const_pkg.CMID
            and p.standard_id = i_standard_id
            and p.id = v.param_id
            and m.id = v.consumer_member_id
            and v.host_member_id = i_host_id
            and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select cmid
         , card_type
         , month_num
         , '106.ACCOUNTS_CARDS' as group_name
         , '1010.Accounts at end of quarter' as param_name
         , inst_id
         , count(distinct case when status  = 'ACSTACTV' then acct_id else null end ) as value_1  -- open
         , count(distinct case when status != 'ACSTACTV' then acct_id else null end ) as value_2  -- blocked
         , count(distinct case when status  = 'ACSTACTV' then acct_id else null end ) +
           count(distinct case when status != 'ACSTACTV' then acct_id else null end ) as value_3  -- Total as sum of open and blocked
         , card_type_id
         , card_type_feature
      from (
            select cmid as cmid
                 , i_quarter * 3 - 2 as month_num
                 , det.card_type || ' - '|| det.card_feature as card_type
                 , det.acct_id as acct_id
                 , inst_id
                 , status
                 , card_type_id
                 , card_type_feature
            from (select cmid.cmid   
                       , get_text (
                              i_table_name     => 'net_card_type'
                              , i_column_name  => 'name'
                              , i_object_id    => main_card_type_id
                         ) as card_type
                       , aa.id as acct_id
                       , cmid.inst_id
                       , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end as card_feature
                       , aa.status
                       , main_card_type_id as card_type_id
                       , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
                    from iss_card ic
                       , (select nct.id as card_type_id
                               , com_api_array_pkg.conv_array_elem_v(
                                          i_lov_id            => 130 
                                        , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                        , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                        , i_elem_value        => nct.id
                                 ) as main_card_type_id
                            from net_card_type nct
                           where nct.network_id = i_network_id
                         ) card_type
                       , (select cf.card_type_id
                               , cf.card_feature
                            from net_card_type ct
                               , net_card_type_feature cf
                           where ct.network_id   = i_network_id
                             and ct.id           = cf.card_type_id
                             and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
                         ) ctd
                       , acc_account_object aao
                       , acc_account aa
                       , acc_balance_vw abv
                       , cmid    
                       , iss_card_instance ci                      
                   where ic.id              = aao.object_id
                     and ic.inst_id         = cmid.inst_id
                     and aao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                     and aa.id              = aao.account_id
                     and ic.card_type_id    = card_type.card_type_id
                     and ic.card_type_id    = ctd.card_type_id(+)
                     and abv.account_id     = aa.id
                     and abv.balance_type   = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                     and abv.open_date      <= i_end_date
                     and ci.card_id         = ic.id
                     and ci.expir_date      > i_end_date
                     and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date + 1
                     and card_type.main_card_type_id not in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                                                           , mcw_api_const_pkg.QR_CIRRUS_CARD_TYPE)
                 ) det
        ) det2
        group by cmid, month_num, card_type, inst_id, card_type_id, card_type_feature;

    -- MasterCard Issuing Accounts with at least one transaction
    cursor cu_data_group_4_4(
        i_quarter      com_api_type_pkg.t_tiny_id
      , i_end_date     date
      , i_standard_id  com_api_type_pkg.t_tiny_id
      , i_host_id      com_api_type_pkg.t_tiny_id
      , i_network_id   com_api_type_pkg.t_short_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = mcw_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select m.cmid
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => ct.main_card_type_id
           ) || ' - ' ||
           case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end
           as card_type
         , i_quarter * 3 - 2 as month_num
         , '106.ACCOUNTS_CARDS' as group_name 
         , '1011.Accounts with at least one transaction' as param_name
         , m.inst_id 
         , null /*count(distinct case when aa.status = 'ACSTACTV' then ao.account_id else null end ) */   as value_1  -- open
         , null /*count(distinct case when aa.status != 'ACSTACTV' then ao.account_id else null end ) */  as value_2  -- blocked
         , count(distinct ao.account_id) as value_3  -- Total
         , ct.main_card_type_id as card_type_id
         , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
      from iss_card           oc
         , iss_card_instance  ci
         , iss_bin            ib
         , acc_account_object ao
         , acc_account        aa
         , (select ct.id card_type_id
                 , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 130 
                            , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => ct.id
                   ) as main_card_type_id
              from net_card_type ct
            where ct.network_id = i_network_id
           ) ct
         , (select cf.card_type_id
                 , cf.card_feature
              from net_card_type ct
                 , net_card_type_feature cf
             where ct.network_id   = i_network_id
               and ct.id           = cf.card_type_id
               and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
           ) ctd
         , cmid m
     where oc.inst_id       = m.inst_id
       and ci.card_id       = oc.id
       and oc.card_type_id  = ct.card_type_id
       and oc.card_type_id  = ctd.card_type_id(+)
       and ci.start_date   <= i_end_date
       and ci.expir_date   >= i_end_date
       and ib.id            = ci.bin_id
       and ao.object_id     = oc.id
       and ao.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
       and aa.id            = ao.account_id
       and exists (select 1
                     from acc_entry e
                    where e.account_id   = ao.account_id
                      and e.balance_type = 'BLTP0001'
                      and e.sttl_date between trunc(i_end_date,'Q') and i_end_date
                  )
       and ct.main_card_type_id not in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                                      , mcw_api_const_pkg.QR_CIRRUS_CARD_TYPE)
     group by
           m.cmid
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => ct.main_card_type_id
           ) || ' - ' ||
           case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end
         , m.inst_id
         , ct.main_card_type_id
         , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end;

    -- MasterCard Issuing Cards at beginning of quarter
    -- MasterCard Issuing New Cards
    -- MasterCard Issuing Cards at end of quarter
    -- MasterCard Issuing Cards with at least one transaction during quarter
    cursor cu_data_group_4_5(
        i_quarter      com_api_type_pkg.t_tiny_id
      , i_start_date   date
      , i_end_date     date
      , i_standard_id  com_api_type_pkg.t_tiny_id
      , i_host_id      com_api_type_pkg.t_tiny_id
      , i_network_id   com_api_type_pkg.t_short_id
      , i_inst_id      com_api_type_pkg.t_inst_id
    )
    is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = mcw_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    , params_tab as (
        select '1012.Cards at beginning of quarter' param_name
             , 'boq' as id
        from dual
        union all
        select '2056.New Cards' param_name
             , 'new' as id
        from dual
        union all
        select '2057.Cards at end of quarter' param_name
             , 'eoq' as id
        from dual
        union all
        select '2058.Cards with at least one transaction during quarter' param_name
             , 'trx'
        from dual
        
    )
    select t.cmid
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => card_type_id
           ) || ' - ' || t.card_feature
           as card_type
         , i_quarter * 3 - 2 month_num
         , '106.ACCOUNTS_CARDS' as group_name 
         , t.param_name
         , t.inst_id
         , case when t.param_id in ('boq', 'eoq') then count(distinct case when t.is_active = 1 then t.card_id else null end ) else null end as value_1  -- open
         , case when t.param_id in ('boq', 'eoq') then count(distinct case when t.is_active = 0 then t.card_id else null end ) else null end as value_2  -- blocked
         , count(distinct case when t.is_active = 1 then t.card_id else null end ) +
           count(distinct case when t.is_active = 0 then t.card_id else null end ) as value_3  -- Total as sum of open and blocked (t.is_active can has values: 1, 0, null)
         , t.card_type_id
         , t.card_type_feature
    from (select m.cmid cmid
               , c.id as card_id
               , p.id as param_id
               , com_api_array_pkg.conv_array_elem_v(
                          i_lov_id            => 130 
                        , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                        , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                        , i_elem_value        => c.card_type_id
                 ) as card_type_id
               , m.inst_id
               , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end as card_feature
               , ci.eff_status as status
               , p.param_name
               , case 
                     when ci.eff_status in (select element_value from com_array_element e where e.array_id = ACTIVE_CARD_STATUSES)
                     then 1
                     when ci.eff_status in (select element_value from com_array_element e where e.array_id = BLOCKED_CARD_STATUSES)
                     then 0
                     else null
                 end as is_active
               , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
            from params_tab   p
               , iss_card c
               , (select cf.card_type_id
                       , cf.card_feature
                    from net_card_type ct
                       , net_card_type_feature cf
                   where ct.network_id = i_network_id
                     and ct.id = cf.card_type_id
                     and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
                 ) ctd
               , cmid m
               , (
                     -- effective status at begin and end of quarter for every card_instance_id
                     -- first date when status has changed to from inactive status
                     select i.card_id
                          , i.seq_number
                          , i.iss_date
                          , i.reg_date
                          , i.expir_date
                          , r.range_type
                          , coalesce(
                                (
                                    select min(l.status) keep (dense_rank first order by l.change_date desc)
                                      from evt_status_log l
                                     where l.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                       and l.object_id      = i.id
                                       and l.status      like 'CSTS%'
                                       and l.change_date    < r.range_date
                                )
                              , i.status) as eff_status
                       from iss_card_instance i
                          , (
                                select 'eoq' as range_type, i_end_date   as range_date from dual
                                union all
                                select 'boq' as range_type, i_start_date as range_date from dual
                            ) r
                 ) ci
               , acc_account_object ao
           where c.inst_id           = m.inst_id
             and ctd.card_type_id(+) = c.card_type_id
             and ci.card_id          = c.id
             and ci.seq_number       = (select max(s.seq_number) from iss_card_instance s where s.card_id = c.id)
             and ( (     p.id = 'boq'
                     and nvl(ci.iss_date, ci.reg_date) < i_start_date
                     and ci.expir_date > i_start_date
                     and ci.eff_status not in (select element_value from com_array_element e where e.array_id = NON_ACTIVATED_CARD_STATUSES)
                     and ci.range_type = 'boq'
                   )
                   or
                   (     p.id = 'new'
                     and nvl(ci.iss_date, ci.reg_date)  between i_start_date and i_end_date  -- card issued or activated in quarter
                     and ci.eff_status not in (select element_value from com_array_element e where e.array_id = NON_ACTIVATED_CARD_STATUSES)
                     and ci.range_type = 'eoq'
                   ) 
                   or
                   (     p.id = 'eoq'
                     and ci.expir_date > i_end_date
                     and nvl(ci.iss_date, ci.reg_date) < i_end_date
                     and ci.eff_status not in (select element_value from com_array_element e where e.array_id = NON_ACTIVATED_CARD_STATUSES)
                     and ci.range_type = 'eoq'
                   ) 
                   or
                   (     p.id = 'trx'
                     and ci.range_type = 'eoq'
                     and exists (select 1
                                   from acc_account_object ao
                                      , acc_entry e
                                  where ao.object_id = ci.card_id
                                    and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                    and e.account_id = ao.account_id
                                    and e.balance_type = 'BLTP0001'
                                    and e.sttl_date between i_start_date and i_end_date
                                )
                   ) 
                 )
             and ao.object_id = c.id
             and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
             and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130 
                     , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => c.card_type_id
                   ) not in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                           , mcw_api_const_pkg.QR_CIRRUS_CARD_TYPE)
        ) t
    group by
        t.cmid
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => card_type_id
           ) || ' - ' || t.card_feature
        , t.param_name
        , t.param_id
        , t.inst_id
        , t.card_type_id
        , t.card_type_feature;

    -- MasterCard Issuing Card Feature Details
    cursor cu_data_group_4_7(
        i_quarter      com_api_type_pkg.t_tiny_id
      , i_start_date   date
      , i_end_date     date
      , i_network_id   com_api_type_pkg.t_short_id
      , i_standard_id  com_api_type_pkg.t_tiny_id
      , i_host_id      com_api_type_pkg.t_tiny_id      
      , i_inst_id      com_api_type_pkg.t_inst_id
      , i_dest_curr    com_api_type_pkg.t_curr_code
      , i_rate_type     com_api_type_pkg.t_dict_value
      , i_del_value    com_api_type_pkg.t_short_id 
    )
    is
    with card as (
        select distinct
                  m.cmid cmid
                , c.id as card_id
                , get_text (
                       i_table_name     => 'net_card_type'
                       , i_column_name  => 'name'
                       , i_object_id    => main_card_type_id
                  ) || ' - ' ||
                  case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end
                  as card_type
                , (select 1 from net_card_type_feature 
                    where card_type_id = c.card_type_id 
                      and card_feature = mcw_api_const_pkg.CONTACTLESS_FTCH) cntl_card
                , (select 1 from net_card_type_feature 
                    where card_type_id = c.card_type_id 
                      and card_feature = 'TODO'/*mcw_api_const_pkg.CONTACTLESS_FTCH*/) hce_card -- TODO Check HCE
                , m.inst_id
                , main_card_type_id as card_type_id
                , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
             from iss_card c
                , (select ct.id card_type_id
                         , com_api_array_pkg.conv_array_elem_v(
                                      i_lov_id            => 130 
                                    , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                    , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                                    , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                    , i_elem_value        => ct.id
                           ) as main_card_type_id
                      from net_card_type ct
                    where ct.network_id = i_network_id
                  ) ct
                , (select cf.card_type_id
                        , cf.card_feature
                     from net_card_type ct
                        , net_card_type_feature cf
                    where ct.network_id = i_network_id
                      and ct.id = cf.card_type_id
                      and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
                  ) ctd
                , iss_card_instance ci
                , acc_account_object ao
                , (select distinct 
                          m.inst_id inst_id
                        , v.param_value cmid
                     from cmn_parameter p
                        , net_api_interface_param_val_vw v
                        , net_member m
                    where p.name = mcw_api_const_pkg.CMID
                      and p.standard_id = i_standard_id
                      and p.id = v.param_id
                      and m.id = v.consumer_member_id
                      and v.host_member_id = i_host_id
                      and (m.inst_id = i_inst_id or i_inst_id is null)
                  ) m
            where c.inst_id = m.inst_id
              and c.card_type_id = ct.card_type_id
              and c.card_type_id = ctd.card_type_id(+)
              and ci.card_id = c.id
              and ci.expir_date > i_end_date
              and nvl(ci.iss_date, ci.reg_date) < i_end_date
              and coalesce(
                           (
                               -- effective status of card at the end of quarter
                               select min(l.status) keep (dense_rank first order by l.change_date desc)
                                 from evt_status_log l 
                                 where l.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                   and l.object_id   = ci.id
                                   and l.status   like 'CSTS%'
                                   and l.change_date < i_end_date
                           )
                         , ci.status) in (iss_api_const_pkg.CARD_STATUS_VALID_CARD
                                        , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE)
              and ao.object_id = c.id
              and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
              and exists (select 1
                            from iss_card_instance ici
                               , prs_method pm
                           where ici.card_id = c.id 
                             --and ici.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
                             and ici.perso_method_id = pm.id
                             and substr(pm.service_code,1,1) = '2'
                         )
              and ct.main_card_type_id not in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                                             , mcw_api_const_pkg.QR_CIRRUS_CARD_TYPE)
    )
    , cards_trx_curr as (
        select c.card_id
             , d.currency
             , d.oper_date
             , c.inst_id                                                as iss_inst_id
             , count(*)                                                 as trx_count
             , sum(d.amount)                                            as amount
        from card c
           , qpr_detail d
        where d.card_id            = c.card_id
          and d.is_reversal        = com_api_const_pkg.FALSE
          and d.oper_date    between i_start_date and i_end_date
          and com_api_array_pkg.conv_array_elem_v(
                  i_lov_id        => 49 
                , i_array_type_id => mcw_api_const_pkg.QR_ARRAY_TYPE
                , i_array_id      => mcw_api_const_pkg.QR_ISS_OPER_TYPE_ARRAY
                , i_inst_id       => ost_api_const_pkg.DEFAULT_INST
                , i_elem_value    => d.oper_type
              ) in ('Sales', 'ATM', 'Manual', 'Refunds')
        group by c.card_id
               , d.currency
               , d.oper_date
               , c.inst_id
    )
    , cards_trx as (
        select o.card_id
             , sum(trx_count) as trx_count      
             , sum(
                   decode(
                       o.currency
                     , i_dest_curr
                     , o.amount
                     , com_api_rate_pkg.convert_amount(
                           i_src_amount   => o.amount
                         , i_src_currency => o.currency
                         , i_dst_currency => i_dest_curr
                         , i_rate_type    => i_rate_type
                         , i_inst_id      => o.iss_inst_id
                         , i_eff_date     => o.oper_date
                         , i_mask_exception => 1
                         , i_exception_value => null
                       )
                   ) / i_del_value 
               ) as trx_amount
          from cards_trx_curr o
      group by o.card_id
    )
    , card_and_trx as (
        select c.cmid
             , c.card_type
             , c.card_id
             , c.inst_id
             , c.cntl_card
             , c.hce_card
             , t.trx_count
             , t.trx_amount
             , c.card_type_id
             , c.card_type_feature
        from card             c
           , cards_trx        t
        where t.card_id(+) = c.card_id
    )
    select card.cmid
         , i_quarter * 3 - 2 month_num
         , '115.CARD_FEATURE_DETAILS' group_name
         , '1030.Breakout of EMV-compliant Chip-enabled Cards' param_name
         , card_type
         , card.inst_id
         , count(card.card_id) value_1
         , sum(trx_count)      value_2
         , sum(trx_amount)     value_3
         , card.card_type_id
         , card.card_type_feature
      from card_and_trx  card
  group by card.cmid
         , card.card_type
         , card.inst_id
         , card.card_type_id
         , card.card_type_feature
     union
    select card.cmid
         , i_quarter * 3 - 2 month_num
         , '115.CARD_FEATURE_DETAILS' group_name
         , '1031.Of which are MasterCard contactless enabled' param_name
         , card_type
         , card.inst_id
         , sum(nvl(card.cntl_card,0)) value_1
         , sum(trx_count)      value_2
         , sum(trx_amount)     value_3
         , card.card_type_id
         , card.card_type_feature
      from card_and_trx  card
     where card.cntl_card = 1
  group by card.cmid
         , card.card_type
         , card.inst_id
         , card.card_type_id
         , card.card_type_feature
     union
    select card.cmid
         , i_quarter * 3 - 2 month_num
         , '115.CARD_FEATURE_DETAILS' group_name
         , '1034.Total MasterCard contactless Cards issued' param_name
         , card_type
         , card.inst_id
         , count(card.card_id) value_1
         , sum(trx_count)      value_2
         , sum(trx_amount)     value_3
         , card.card_type_id
         , card.card_type_feature
      from card_and_trx  card
     where card.cntl_card = 1
       and card.hce_card is null
  group by card.cmid
         , card.card_type
         , card.inst_id
         , card.card_type_id
         , card.card_type_feature
  ;

    -- MasterCard Issuing Card Feature Details PayPass
    cursor cu_data_group_4_8(
        i_quarter      com_api_type_pkg.t_tiny_id
      , i_start_date   date
      , i_end_date     date
      , i_network_id   com_api_type_pkg.t_short_id
      , i_standard_id  com_api_type_pkg.t_tiny_id
      , i_host_id      com_api_type_pkg.t_tiny_id      
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
    with card as (
        select distinct
                  m.cmid cmid
                , c.id as card_id
                , get_text (
                       i_table_name     => 'net_card_type'
                       , i_column_name  => 'name'
                       , i_object_id    => main_card_type_id
                  ) || ' - ' ||
                  case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end
                  as card_type
                , m.inst_id
                , main_card_type_id as card_type_id
                , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
             from iss_card c
                , (select ct.id card_type_id
                        , com_api_array_pkg.conv_array_elem_v(
                                     i_lov_id            => 130 
                                   , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                   , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                                   , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                   , i_elem_value        => ct.id
                          ) as main_card_type_id
                     from net_card_type ct
                        , net_card_type_feature ctf
                    where ct.network_id = i_network_id
                      and ct.id = ctf.card_type_id
                      and ctf.card_feature = mcw_api_const_pkg.CONTACTLESS_FTCH
                  ) ct
                , (select cf.card_type_id
                        , cf.card_feature
                     from net_card_type ct
                        , net_card_type_feature cf
                    where ct.network_id = i_network_id
                      and ct.id = cf.card_type_id
                      and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
                  ) ctd
                , iss_card_instance ci
                , acc_account_object ao
                , (select distinct
                          m.inst_id inst_id
                        , v.param_value cmid
                     from cmn_parameter p
                        , net_api_interface_param_val_vw v
                        , net_member m
                    where p.name = mcw_api_const_pkg.CMID
                      and p.standard_id = i_standard_id
                      and p.id = v.param_id
                      and m.id = v.consumer_member_id
                      and v.host_member_id = i_host_id
                      and (m.inst_id = i_inst_id or i_inst_id is null)
                  ) m
            where c.inst_id = m.inst_id
              and c.card_type_id = ct.card_type_id
              and c.card_type_id = ctd.card_type_id(+)
              and ci.card_id = c.id
              and ci.expir_date > i_end_date
              and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date
              and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
              and ao.object_id = c.id
              and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
              and ct.main_card_type_id not in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                                             , mcw_api_const_pkg.QR_CIRRUS_CARD_TYPE)
    )
    select card.cmid
         , i_quarter * 3 - 2 month_num
         , '115.CARD_FEATURE_DETAILS' group_name
         , '1034.Total PayPass-enabled Cards issued' param_name
         , card_type
         , card.inst_id
         , count(card.card_id) value_1
         , card.card_type_id
         , card.card_type_feature
      from card
  group by card.cmid
         , card.card_type
         , card.inst_id
         , card.card_type_id
         , card.card_type_feature
     union
    select card.cmid
         , i_quarter * 3 - 2 month_num
         , '115.CARD_FEATURE_DETAILS' group_name
         , '1035.Total PayPass-enabled cards initiating a Swipe' param_name
         , card_type
         , card.inst_id
         , count(card.card_id) value_1
         , card.card_type_id
         , card.card_type_feature
      from card
     where exists (
               select 1 
                 from qpr_detail d
                where d.card_id = card.card_id
                  and d.card_data_input_mode in ('F227000C', 'F227000F', 'F227000P', 'F227000B', 'F227000A', 'F2270002')
           )
  group by card.cmid
         , card.card_type
         , card.inst_id
         , card.card_type_id
         , card.card_type_feature
     union
    select card.cmid
         , i_quarter * 3 - 2 month_num
         , '115.CARD_FEATURE_DETAILS' group_name
         , '1036.Of which are PayPass-enabled' param_name
         , card_type
         , card.inst_id
         , count(card.card_id) value_1
         , card.card_type_id
         , card.card_type_feature
      from card
     where exists (
               select 1 
                 from qpr_detail d
                where d.card_id = card.card_id
                  and d.card_data_input_mode in ('F227000N','F227000M')
           )
  group by card.cmid
         , card.card_type
         , card.inst_id
         , card.card_type_id
         , card.card_type_feature;

    -- Maestro Issuing
    cursor cu_data_group_5(
        i_dest_curr     com_api_type_pkg.t_curr_code
      , i_del_value     com_api_type_pkg.t_short_id
      , i_start_date    date
      , i_end_date      date
      , i_standard_id   com_api_type_pkg.t_tiny_id
      , i_host_id       com_api_type_pkg.t_tiny_id
      , i_rate_type     com_api_type_pkg.t_dict_value
      , i_network_id    com_api_type_pkg.t_short_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
    with cmid as (
        select
            distinct
            m.inst_id inst_id
            , v.param_value cmid
        from
            cmn_parameter p
            , net_api_interface_param_val_vw v
            , net_member m
        where
            p.name = mcw_api_const_pkg.CMID_MAESTRO
            and p.standard_id = i_standard_id
            and p.id = v.param_id
            and m.id = v.consumer_member_id
            and v.host_member_id = i_host_id
            and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    , trx_data as (
        select m.cmid
             , case when o.is_acq = 1 then '1039.Domestic On-us'
                    when o.card_country = nvl(o.merchant_country, o.card_country) then '1041.Domestic Interchange'
                    when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then '1042.International Within Region'
                    else '1043.International Outside of Region'
--                    when o.card_country is not null and nvl(o.merchant_country, o.card_country) is not null then '1043.International Outside of Region'
--                    else 'Unknown'
               end 
               as param_name
             , case when o.is_acq = 1 then 1039
                    when o.card_country = nvl(o.merchant_country, o.card_country) then 1041
                    when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then 1042
                    else 1043
               end 
               as param_id
             , nvl(
                   com_api_array_pkg.conv_array_elem_v(
                         i_lov_id            => 49 
                       , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                       , i_array_id          => mcw_api_const_pkg.QR_ISS_OPER_TYPE_ARRAY
                       , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                       , i_elem_value        => o.oper_type
                  )
                  , 'Unknown'
               )
               as group_name
             , com_api_array_pkg.conv_array_elem_v(
                     i_lov_id            => 130 
                   , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                   , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                   , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                   , i_elem_value        => o.card_type_id
               ) 
               as card_type_id
             , sum (decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
             , sum (decode(o.is_reversal, 1, -1, 1) * o.amount) amount
             , o.currency
             , o.oper_date
             , o.card_inst_id
             , m.inst_id
             , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end as card_feature
             , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature 
          from qpr_aggr o 
             , (select cf.card_type_id
                     , cf.card_feature
                  from net_card_type ct
                     , net_card_type_feature cf
                 where ct.network_id = i_network_id
                   and ct.id = cf.card_type_id
                   and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
               ) ctd
             , cmid m
             , com_country c
         where o.is_iss = 1
           and o.card_inst_id = m.inst_id
           and o.card_network_id = i_network_id
           and o.status in (select element_value
                              from com_array_element
                             where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
           and c.code = nvl(o.merchant_country, o.card_country)
           and o.oper_date between i_start_date and i_end_date
           and o.card_type_id = ctd.card_type_id(+)
           and com_api_array_pkg.conv_array_elem_v(
                   i_lov_id            => 130 
                 , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                 , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                 , i_elem_value        => o.card_type_id
               ) in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE)
      group by m.cmid
             , case when o.is_acq = 1 then '1039.Domestic On-us'
                    when o.card_country = nvl(o.merchant_country, o.card_country) then '1041.Domestic Interchange'
                    when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then '1042.International Within Region'
                    else '1043.International Outside of Region'
--                    when o.card_country is not null and nvl(o.merchant_country, o.card_country) is not null then '1043.International Outside of Region'
--                    else 'Unknown'
               end 
             , case when o.is_acq = 1 then 1039
                    when o.card_country = nvl(o.merchant_country, o.card_country) then 1041
                    when mcw_prc_qpr_pkg.is_international_within_region(o.card_country, o.merchant_country) = com_api_const_pkg.TRUE then 1042
                    else 1043
               end 
             , nvl(
                   com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49 
                     , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => mcw_api_const_pkg.QR_ISS_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                  )
                  , 'Unknown'
               )
             , com_api_array_pkg.conv_array_elem_v(
                   i_lov_id            => 130 
                 , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                 , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                 , i_elem_value        => o.card_type_id
               ) 
             , o.currency
             , o.oper_date
             , o.card_inst_id
             , m.inst_id
             , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end
             , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end
    )
    select t.cmid
         , t.card_type
         , t.month_number
         , t.group_name
         , t.param_name
         , t.inst_id
         , null            as value_1
         , sum(t.nn_trans) as value_2
         , sum(t.amount)   as value_3
         , t.card_type_id
         , t.card_type_feature
      from (
        select cmid as cmid
             , case group_name
                    when 'Sales'   then '116.MAESTRO_PURCHASE_RETAIL_SALES_ACTIVITY'
                    when 'ATM'     then '117.MAESTRO_CASH_DISBURSEMENTS_ATM_ACTIVITY'
               end
               as group_name
             , get_text (
                     i_table_name  => 'net_card_type'
                   , i_column_name => 'name'
                   , i_object_id   => o.card_type_id
               ) || ' - '|| o.card_feature
               as card_type
             , to_number(to_char(trunc(o.oper_date,'Q'), 'mm')) month_number
             , param_name
             , inst_id
             , nn_trans
             , decode(
                   o.currency
                 , i_dest_curr
                 , o.amount
                 , com_api_rate_pkg.convert_amount(
                       i_src_amount   => o.amount
                     , i_src_currency => o.currency
                     , i_dst_currency => i_dest_curr
                     , i_rate_type    => i_rate_type
                     , i_inst_id      => o.card_inst_id
                     , i_eff_date     => o.oper_date
                     , i_mask_exception => 1
                     , i_exception_value => null
                   )
               ) / i_del_value 
               as amount
             , o.card_type_id
             , o.card_type_feature
          from trx_data o
         where o.param_name <> 'Unknown'
           and o.group_name in ('Sales', 'ATM')
         union all
        select cmid as cmid
             , '121.Detail Activity Breakout' as group_name
             , get_text (
                     i_table_name  => 'net_card_type'
                   , i_column_name => 'name'
                   , i_object_id   => o.card_type_id
               ) || ' - '|| o.card_feature
               as card_type
             , to_number(to_char(trunc(o.oper_date,'Q'), 'mm')) month_number
             , '1051.Total Domestic Activity (I.1+I.2+I.3+II.1+II.2+II.3)' as param_name
             , inst_id
             , nn_trans
             , decode(
                   o.currency
                 , i_dest_curr
                 , o.amount
                 , com_api_rate_pkg.convert_amount(
                       i_src_amount   => o.amount
                     , i_src_currency => o.currency
                     , i_dst_currency => i_dest_curr
                     , i_rate_type    => i_rate_type
                     , i_inst_id      => o.card_inst_id
                     , i_eff_date     => o.oper_date
                     , i_mask_exception => 1
                     , i_exception_value => null
                   )
               ) / i_del_value 
               as amount
             , o.card_type_id
             , o.card_type_feature
          from trx_data o
         where o.param_id in ( 168, 169, 170 )
           and o.group_name in ('Sales', 'ATM')
         union all
        select cmid as cmid
             , '121.Detail Activity Breakout' as group_name
             , get_text (
                     i_table_name  => 'net_card_type'
                   , i_column_name => 'name'
                   , i_object_id   => o.card_type_id
               ) || ' - '|| o.card_feature
               as card_type
             , to_number(to_char(trunc(o.oper_date,'Q'), 'mm')) month_number
             , '1053.Domestic Activity on Cards Bearing Maestro (or Maestro+Cirrus) Logo Only' as param_name
             , inst_id
             , nn_trans
             , decode(
                   o.currency
                 , i_dest_curr
                 , o.amount
                 , com_api_rate_pkg.convert_amount(
                       i_src_amount   => o.amount
                     , i_src_currency => o.currency
                     , i_dst_currency => i_dest_curr
                     , i_rate_type    => i_rate_type
                     , i_inst_id      => o.card_inst_id
                     , i_eff_date     => o.oper_date
                     , i_mask_exception => 1
                     , i_exception_value => null
                   )
               ) / i_del_value 
               as amount
             , o.card_type_id
             , o.card_type_feature
          from trx_data o
         where o.param_id in ( 168, 169, 170 )
           and o.group_name in ('Sales', 'ATM')
      ) t
  group by t.cmid
         , t.card_type
         , t.month_number
         , t.group_name
         , t.param_name
         , t.inst_id
         , t.card_type_id
         , t.card_type_feature;


    -- Maestro Issuing Cards
    cursor cu_data_group_5_1(
        i_quarter      com_api_type_pkg.t_tiny_id
      , i_end_date     date
      , i_standard_id  com_api_type_pkg.t_tiny_id
      , i_host_id      com_api_type_pkg.t_tiny_id
      , i_network_id   com_api_type_pkg.t_short_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = mcw_api_const_pkg.CMID_MAESTRO
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => t.card_type_id
           ) || ' - '|| t.card_feature
           card_type
         , i_quarter * 3 - 2 month_num
         , '119.MAESTRO_CARDS' as group_name 
         , '1045.Cards bearing the Maestro logo only' param_name
         , t.inst_id
         , null                      as value_1
         , null                      as value_2
         , count(distinct t.card_id) as value_3
         , t.card_type_id
         , t.card_type_feature
    from (select m.cmid cmid
               , c.id as card_id
               , com_api_array_pkg.conv_array_elem_v(
                          i_lov_id            => 130 
                        , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                        , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                        , i_elem_value        => c.card_type_id
                 ) as card_type_id
               , m.inst_id
               , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end as card_feature
               , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
            from iss_card c
               , (select cf.card_type_id
                       , cf.card_feature
                    from net_card_type ct
                       , net_card_type_feature cf
                   where ct.network_id = i_network_id
                     and ct.id = cf.card_type_id
                     and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
                 ) ctd
               , cmid m
               , iss_card_instance ci
               , acc_account_object ao
           where c.inst_id = m.inst_id
             and c.card_type_id = ctd.card_type_id(+)
             and ci.card_id = c.id
             and ci.expir_date > i_end_date
             and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date + 1
             and ao.object_id = c.id
             and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
             and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130 
                     , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => c.card_type_id
                   ) in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE)
        ) t
   group by
           t.cmid
         , get_text (
                i_table_name     => 'net_card_type'
                , i_column_name  => 'name'
                , i_object_id    => t.card_type_id
            ) || ' - '|| t.card_feature
         , t.inst_id
         , t.card_type_id
         , t.card_type_feature;

    -- Maestro Issuing Accounts
    cursor cu_data_group_5_2(
        i_quarter      com_api_type_pkg.t_tiny_id
      , i_start_date   date
      , i_end_date     date
      , i_standard_id  com_api_type_pkg.t_tiny_id
      , i_host_id      com_api_type_pkg.t_tiny_id
      , i_network_id   com_api_type_pkg.t_short_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
    with cmid as (
        select
            distinct
            m.inst_id inst_id
            , v.param_value cmid
        from
            cmn_parameter p
            , net_api_interface_param_val_vw v
            , net_member m
        where
            p.name = mcw_api_const_pkg.CMID_MAESTRO
            and p.standard_id = i_standard_id
            and p.id = v.param_id
            and m.id = v.consumer_member_id
            and v.host_member_id = i_host_id
            and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select cmid
         , card_type
         , month_num
         , '120.MAESTRO_ACCOUNTS' as group_name
         , '1050.Number of accounts with a card bearing a Maestr' as param_name
         , inst_id
         , null                    as value_1
         , null                    as value_2
         , count(distinct acct_id) as value_3
         , card_type_id
         , card_type_feature
      from (
            select cmid as cmid
                 , i_quarter * 3 - 2 as month_num
                 , det.card_type || ' - '|| det.card_feature as card_type
                 , det.acct_id as acct_id
                 , inst_id
                 , det.card_type_id
                 , det.card_type_feature
            from (select cmid.cmid   
                       , get_text (
                              i_table_name     => 'net_card_type'
                              , i_column_name  => 'name'
                              , i_object_id    => main_card_type_id
                         ) as card_type
                       , aa.id as acct_id
                       , cmid.inst_id
                       , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end as card_feature
                       , main_card_type_id as card_type_id
                       , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
                    from iss_card ic
                       , (select nct.id as card_type_id
                               , com_api_array_pkg.conv_array_elem_v(
                                          i_lov_id            => 130 
                                        , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                        , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                        , i_elem_value        => nct.id
                                 ) as main_card_type_id
                            from net_card_type nct
                           where nct.network_id = i_network_id
                         ) card_type
                       , (select cf.card_type_id
                               , cf.card_feature
                            from net_card_type ct
                               , net_card_type_feature cf
                           where ct.network_id = i_network_id
                             and ct.id = cf.card_type_id
                             and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
                         ) ctd
                       , acc_account_object aao
                       , acc_account aa
                       , iss_card_instance ci
                       , acc_balance_vw abv
                       , cmid                          
                   where ic.id              = aao.object_id
                     and ic.inst_id         = cmid.inst_id
                     and aao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                     and aa.id              = aao.account_id
                     and ic.card_type_id    = card_type.card_type_id
                     and ic.card_type_id    = ctd.card_type_id(+)
                     and abv.account_id     = aa.id
                     and abv.balance_type   = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                     and abv.open_date      <= i_end_date
                     and ci.card_id         = ic.id
                     and ci.expir_date      > i_end_date
                     and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date + 1
                     and card_type.main_card_type_id in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE)
                 ) det
        ) det2
        group by cmid, month_num, card_type, inst_id, card_type_id, card_type_feature;
   
    -- Maestro Issuing Card Feature Details
    cursor cu_data_group_5_3(
        i_quarter      com_api_type_pkg.t_tiny_id
      , i_start_date   date
      , i_end_date     date
      , i_network_id   com_api_type_pkg.t_short_id
      , i_standard_id  com_api_type_pkg.t_tiny_id
      , i_host_id      com_api_type_pkg.t_tiny_id      
      , i_inst_id       com_api_type_pkg.t_inst_id
      , i_dest_curr    com_api_type_pkg.t_curr_code
      , i_rate_type     com_api_type_pkg.t_dict_value
      , i_del_value    com_api_type_pkg.t_short_id 
    )
    is
    with card as (
        select distinct
                  m.cmid cmid
                , c.id as card_id
                , get_text (
                       i_table_name     => 'net_card_type'
                       , i_column_name  => 'name'
                       , i_object_id    => main_card_type_id
                  ) || ' - ' ||
                  case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end
                  as card_type
                , (select 1 from net_card_type_feature 
                    where card_type_id = c.card_type_id 
                      and card_feature = mcw_api_const_pkg.CONTACTLESS_FTCH) cntl_card
                , (select 1 from net_card_type_feature 
                    where card_type_id = c.card_type_id 
                      and card_feature = 'TODO'/*mcw_api_const_pkg.CONTACTLESS_FTCH*/) hce_card -- TODO Check HCE
                , m.inst_id
                , main_card_type_id as card_type_id
                , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
             from iss_card c
                , (select ct.id card_type_id
                         , com_api_array_pkg.conv_array_elem_v(
                                      i_lov_id            => 130 
                                    , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                    , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                                    , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                    , i_elem_value        => ct.id
                           ) as main_card_type_id
                      from net_card_type ct
                    where ct.network_id = i_network_id
                  ) ct
                , (select cf.card_type_id
                        , cf.card_feature
                     from net_card_type ct
                        , net_card_type_feature cf
                    where ct.network_id = i_network_id
                      and ct.id = cf.card_type_id
                      and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
                  ) ctd
                , iss_card_instance ci
                , acc_account_object ao
                , (select distinct
                          m.inst_id inst_id
                        , v.param_value cmid
                     from cmn_parameter p
                        , net_api_interface_param_val_vw v
                        , net_member m
                    where p.name = mcw_api_const_pkg.CMID_MAESTRO
                      and p.standard_id = i_standard_id
                      and p.id = v.param_id
                      and m.id = v.consumer_member_id
                      and v.host_member_id = i_host_id
                      and (m.inst_id = i_inst_id or i_inst_id is null)
                  ) m
            where c.inst_id = m.inst_id
              and c.card_type_id = ct.card_type_id
              and c.card_type_id = ctd.card_type_id(+)
              and ci.card_id = c.id
              and ci.expir_date > i_end_date
              and nvl(ci.iss_date, ci.reg_date) < i_end_date
              and coalesce(
                           (
                               -- effective status of card at the end of quarter
                               select min(l.status) keep (dense_rank first order by l.change_date desc)
                                 from evt_status_log l 
                                 where l.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                   and l.object_id   = ci.id
                                   and l.status   like 'CSTS%'
                                   and l.change_date < i_end_date
                           )
                         , ci.status) in (iss_api_const_pkg.CARD_STATUS_VALID_CARD
                                        , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE)
              and ct.main_card_type_id in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE)
              and ao.object_id = c.id
              and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
              and exists (select 1
                            from iss_card_instance ici
                               , prs_method pm
                           where ici.card_id = c.id 
                             --and ici.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
                             and ici.perso_method_id = pm.id
                             and substr(pm.service_code,1,1) = '2'
                         )
    )
    , cards_trx_curr as (
        select c.card_id
             , d.currency
             , d.oper_date
             , c.inst_id                                                as iss_inst_id
             , count(*)                                                 as trx_count
             , sum(d.amount)                                            as amount
        from card c
           , qpr_detail d
        where d.card_id            = c.card_id
          and d.is_reversal        = com_api_const_pkg.FALSE
          and d.oper_date    between i_start_date and i_end_date
          and com_api_array_pkg.conv_array_elem_v(
                  i_lov_id        => 49 
                , i_array_type_id => mcw_api_const_pkg.QR_ARRAY_TYPE
                , i_array_id      => mcw_api_const_pkg.QR_ISS_OPER_TYPE_ARRAY
                , i_inst_id       => ost_api_const_pkg.DEFAULT_INST
                , i_elem_value    => d.oper_type
              ) in ('Sales', 'ATM', 'Manual', 'Refunds')
        group by c.card_id
               , d.currency
               , d.oper_date
               , c.inst_id
    )
    , cards_trx as (
        select o.card_id
             , sum(trx_count) as trx_count      
             , sum( decode(
                        o.currency
                      , i_dest_curr
                      , o.amount
                      , com_api_rate_pkg.convert_amount(
                            i_src_amount   => o.amount
                          , i_src_currency => o.currency
                          , i_dst_currency => i_dest_curr
                          , i_rate_type    => i_rate_type
                          , i_inst_id      => o.iss_inst_id
                          , i_eff_date     => o.oper_date
                          , i_mask_exception => 1
                          , i_exception_value => null
                        )
                    ) / i_del_value 
               ) as trx_amount
        from cards_trx_curr o
        group by o.card_id
    )
    , card_and_trx as (
        select c.cmid
             , c.card_type
             , c.card_id
             , c.inst_id
             , c.cntl_card
             , c.hce_card
             , t.trx_count
             , t.trx_amount
             , c.card_type_id
             , c.card_type_feature
        from card             c
           , cards_trx        t
        where t.card_id(+) = c.card_id
    )
    select card.cmid
         , i_quarter * 3 - 2 month_num
         , '122.CARD_FEATURE_DETAILS' group_name
         , '1054.Breakout of EMV-compliant Chip-enabled Cards' param_name
         , card.card_type
         , card.inst_id
         , count(card.card_id) value_1
         , sum(trx_count)      value_2
         , sum(trx_amount)     value_3
         , card.card_type_id
         , card.card_type_feature
      from card_and_trx card
  group by card.cmid
         , card.card_type
         , card.inst_id
         , card.card_type_id
         , card.card_type_feature
     union
    select card.cmid
         , i_quarter * 3 - 2 month_num
         , '122.CARD_FEATURE_DETAILS' group_name
         , '1055.Of which are Maestro contactless enabled' param_name
         , card.card_type
         , card.inst_id
         , sum(nvl(card.cntl_card,0)) value_1
         , sum(trx_count)      value_2
         , sum(trx_amount)     value_3
         , card.card_type_id
         , card.card_type_feature
      from card_and_trx card
     where card.cntl_card = 1
  group by card.cmid
         , card.card_type
         , card.inst_id
         , card.card_type_id
         , card.card_type_feature
  union all
    select card.cmid
         , i_quarter * 3 - 2 month_num
         , '122.CARD_FEATURE_DETAILS' group_name
         , '1058.Total Maestro contactless Cards issued (physical plastic cards only)' param_name
         , card.card_type
         , card.inst_id
         , count(card.card_id) value_1
         , sum(trx_count)      value_2
         , sum(trx_amount)     value_3
         , card.card_type_id
         , card.card_type_feature
      from card_and_trx card
     where card.cntl_card = 1
  group by card.cmid
         , card.card_type
         , card.inst_id
         , card.card_type_id
         , card.card_type_feature
  ;
         
    -- Maestro Issuing Card Feature Details PayPass
    cursor cu_data_group_5_4(
        i_quarter      com_api_type_pkg.t_tiny_id
      , i_start_date   date
      , i_end_date     date
      , i_network_id   com_api_type_pkg.t_short_id
      , i_standard_id  com_api_type_pkg.t_tiny_id
      , i_host_id      com_api_type_pkg.t_tiny_id      
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
    with card as (
        select distinct
                  m.cmid cmid
                , c.id as card_id
                , get_text (
                       i_table_name     => 'net_card_type'
                       , i_column_name  => 'name'
                       , i_object_id    => main_card_type_id
                  ) || ' - ' ||
                  case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end
                  as card_type
                , m.inst_id
                , main_card_type_id as card_type_id
                , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature
             from iss_card c
                , (select ct.id card_type_id
                         , com_api_array_pkg.conv_array_elem_v(
                                      i_lov_id            => 130 
                                    , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                                    , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                                    , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                    , i_elem_value        => ct.id
                           ) as main_card_type_id
                      from net_card_type ct
                         , net_card_type_feature ctf
                    where ct.network_id = i_network_id
                      and ct.id = ctf.card_type_id
                      and ctf.card_feature = mcw_api_const_pkg.CONTACTLESS_FTCH
                  ) ct
                , (select cf.card_type_id
                        , cf.card_feature
                     from net_card_type ct
                        , net_card_type_feature cf
                    where ct.network_id = i_network_id
                      and ct.id = cf.card_type_id
                      and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
                  ) ctd
                , iss_card_instance ci
                , acc_account_object ao
                , (select distinct
                          m.inst_id inst_id
                        , v.param_value cmid
                     from cmn_parameter p
                        , net_api_interface_param_val_vw v
                        , net_member m
                    where p.name = mcw_api_const_pkg.CMID_MAESTRO
                      and p.standard_id = i_standard_id
                      and p.id = v.param_id
                      and m.id = v.consumer_member_id
                      and v.host_member_id = i_host_id
                      and (m.inst_id = i_inst_id or i_inst_id is null)
                  ) m
            where c.inst_id = m.inst_id
              and c.card_type_id = ct.card_type_id
              and c.card_type_id = ctd.card_type_id(+)
              and ci.card_id = c.id
              and ci.expir_date > i_end_date
              and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date
              and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
              and ci.state <> 'CSTE0100'
              and ct.main_card_type_id in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE)
              and ao.object_id = c.id
              and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
              and exists (select 1 from net_card_type_feature 
                           where card_type_id = c.card_type_id 
                             and card_feature = mcw_api_const_pkg.CIRRUS_FTCH)
    )
    select card.cmid
         , i_quarter * 3 - 2 month_num
         , '122.CARD_FEATURE_DETAILS' group_name
         , '1058.Total PayPass-enabled Cards issued' param_name
         , card_type
         , card.inst_id
         , count(card.card_id) value_1
         , card.card_type_id
         , card.card_type_feature
      from card
  group by card.cmid
         , card.card_type
         , card.inst_id
         , card.card_type_id
         , card.card_type_feature
     union
    select card.cmid
         , i_quarter * 3 - 2 month_num
         , '122.CARD_FEATURE_DETAILS' group_name
         , '1059.Total PayPass-enabled cards initiating a Swipe' param_name
         , card_type
         , card.inst_id
         , count(card.card_id) value_1
         , card.card_type_id
         , card.card_type_feature
      from card
     where exists (
               select 1 
                 from qpr_detail d
                where d.card_id = card.card_id
                  and d.card_data_input_mode in ('F227000C', 'F227000F', 'F227000P', 'F227000B', 'F227000A', 'F2270002')
           )
  group by card.cmid
         , card.card_type
         , card.inst_id
         , card.card_type_id
         , card.card_type_feature
     union
    select card.cmid
         , i_quarter * 3 - 2 month_num
         , '122.CARD_FEATURE_DETAILS' group_name
         , '1060.Of which are PayPass-enabled' param_name
         , card_type
         , card.inst_id
         , count(card.card_id) value_1
         , card.card_type_id
         , card.card_type_feature
      from card
     where exists (
               select 1 
                 from qpr_detail d
                where d.card_id = card.card_id
                  and d.card_data_input_mode in ('F227000N','F227000M')
           )
  group by card.cmid
         , card.card_type
         , card.inst_id
         , card.card_type_id
         , card.card_type_feature;

    cursor cu_data_group_5_dipped(
        i_dest_curr     com_api_type_pkg.t_curr_code
      , i_del_value     com_api_type_pkg.t_short_id
      , i_start_date    date
      , i_end_date      date
      , i_standard_id   com_api_type_pkg.t_tiny_id
      , i_host_id       com_api_type_pkg.t_tiny_id
      , i_rate_type     com_api_type_pkg.t_dict_value
      , i_network_id    com_api_type_pkg.t_short_id
      , i_inst_id       com_api_type_pkg.t_inst_id
    )
    is
    with cmid as (
        select
            distinct
            m.inst_id inst_id
            , v.param_value cmid
        from
            cmn_parameter p
            , net_api_interface_param_val_vw v
            , net_member m
        where
            p.name = mcw_api_const_pkg.CMID_MAESTRO
            and p.standard_id = i_standard_id
            and p.id = v.param_id
            and m.id = v.consumer_member_id
            and v.host_member_id = i_host_id
            and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.card_type
         , t.month_number
         , t.group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) as value_1
         , sum(t.amount) as value_2
         , t.card_type_id
         , t.card_type_feature
      from (
            select cmid as cmid
                 , group_name
                 , get_text (
                         i_table_name  => 'net_card_type'
                       , i_column_name => 'name'
                       , i_object_id   => o.card_type_id
                   ) || ' - '|| o.card_feature
                   as card_type
                 , to_number(to_char(trunc(o.oper_date,'Q'), 'mm')) month_number
                 , param_name
                 , inst_id
                 , nn_trans
                 , decode(
                       o.currency
                     , i_dest_curr
                     , o.amount
                     , com_api_rate_pkg.convert_amount(
                           i_src_amount   => o.amount
                         , i_src_currency => o.currency
                         , i_dst_currency => i_dest_curr
                         , i_rate_type    => i_rate_type
                         , i_inst_id      => o.card_inst_id
                         , i_eff_date     => o.oper_date
                         , i_mask_exception => 1
                         , i_exception_value => null
                       )
                   ) / i_del_value 
                   as amount
                 , card_type_id
                 , card_type_feature
              from (
                    select m.cmid
                         , '1057.DIPPED Transactions' as param_name
                         , '115.CARD_FEATURE_DETAILS' as group_name
                         , com_api_array_pkg.conv_array_elem_v(
                                 i_lov_id            => 130 
                               , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                               , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                               , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                               , i_elem_value        => o.card_type_id
                           ) 
                           as card_type_id
                         , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
                         , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) amount
                         , o.currency
                         , o.oper_date
                         , o.card_inst_id
                         , m.inst_id
                         , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end as card_feature
                         , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end as card_type_feature 
                      from qpr_aggr o 
                         , (select cf.card_type_id
                                 , cf.card_feature
                              from net_card_type ct
                                 , net_card_type_feature cf
                             where ct.network_id = i_network_id
                               and ct.id = cf.card_type_id
                               and cf.card_feature = mcw_api_const_pkg.DEBIT_CARD
                           ) ctd
                         , cmid m
                         , com_country c
                     where o.is_iss = 1
                       and o.card_inst_id = m.inst_id
                       and o.card_network_id = i_network_id
                       and o.status in (select element_value
                                          from com_array_element
                                         where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                       and c.code = nvl(o.merchant_country, o.card_country)
                       and o.oper_date between i_start_date and i_end_date
                       and o.card_type_id = ctd.card_type_id(+)
                       and o.card_data_input_mode in ('F227000C', 'F227000F', 'F227000N', 'F227000M')
                       and com_api_array_pkg.conv_array_elem_v(
                               i_lov_id            => 130 
                             , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                             , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                             , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                             , i_elem_value        => o.card_type_id
                           ) in (mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE)
                  group by m.cmid
                         , com_api_array_pkg.conv_array_elem_v(
                                 i_lov_id            => 130 
                               , i_array_type_id     => mcw_api_const_pkg.QR_ARRAY_TYPE
                               , i_array_id          => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY
                               , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                               , i_elem_value        => o.card_type_id
                           ) 
                         , o.currency
                         , o.oper_date
                         , o.card_inst_id
                         , m.inst_id
                         , case when ctd.card_feature is null then 'Credit Card' else 'Debit Card' end
                         , case when ctd.card_feature is null then mcw_api_const_pkg.DEBIT_CARD else ctd.card_feature end 
                   ) o
             where o.param_name <> 'Unknown'
           ) t
  group by t.cmid
         , t.card_type
         , t.month_number
         , t.group_name
         , t.param_name
         , t.inst_id
         , t.card_type_id
         , t.card_type_feature;

    function is_sepa_country(
        i_country    in com_api_type_pkg.t_country_code
    ) return com_api_type_pkg.t_boolean is
    begin
        if     g_sepa_country.exists(i_country) then
           return g_sepa_country(i_country);
        else
           return com_api_const_pkg.FALSE;
        end if;
    end;

    function is_same_region(
        i_iss_country    in com_api_type_pkg.t_country_code
      , i_acq_country    in com_api_type_pkg.t_country_code
    ) return com_api_type_pkg.t_boolean is
        l_count             com_api_type_pkg.t_count := 0;
    begin
        select count(1)
          into l_count
          from com_country iss
             , com_country acq
         where iss.code = i_iss_country
           and acq.code = i_acq_country
           and iss.mastercard_region = acq.mastercard_region;
        if l_count = 0 then
            return com_api_const_pkg.FALSE;
        else
            return com_api_const_pkg.TRUE;
        end if;
    end;

    function is_international_within_region(
        i_iss_country    in com_api_type_pkg.t_country_code
      , i_acq_country    in com_api_type_pkg.t_country_code
    ) return com_api_type_pkg.t_boolean is
    begin
        if     is_sepa_country(i_iss_country) = com_api_const_pkg.TRUE
           and is_sepa_country(i_acq_country) = com_api_const_pkg.TRUE
        then
           return com_api_const_pkg.TRUE;
        elsif  is_sepa_country(i_iss_country) = com_api_const_pkg.FALSE
           and is_sepa_country(i_acq_country) = com_api_const_pkg.FALSE
           and is_same_region(i_iss_country, i_acq_country) = com_api_const_pkg.TRUE
        then
           return com_api_const_pkg.TRUE;
        else
           return com_api_const_pkg.FALSE;
        end if;
    end;

    function estimate_messages_for_mc (
        i_report_name in com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_long_id is
    begin
        return
            case i_report_name
                when 'PS_MC_ACQUIRING' then 1
                when 'PS_MC_ACQ_MAESTRO' then 2
                when 'PS_MC_ISSUING' then 1
                when 'PS_MC_MAESTRO' then 1
                else 5
            end;
    end;
   
    procedure clear_table(i_year         in    com_api_type_pkg.t_tiny_id
                        , i_start_date   in    date
                        , i_end_date     in    date
                        , i_report_name  in    com_api_type_pkg.t_name
                        , i_inst_id      in    com_api_type_pkg.t_inst_id default NULL)
    is
    begin
        if i_report_name is not null then
            qpr_api_util_pkg.clear_table(
                i_year        => i_year
              , i_start_date  => i_start_date
              , i_end_date    => i_end_date
              , i_report_type => 1
              , i_report_name => i_report_name
              , i_inst_id     => i_inst_id
            );
        else
                qpr_api_util_pkg.clear_table(
                    i_year        => i_year
                  , i_start_date  => i_start_date
                  , i_end_date    => i_end_date
                  , i_report_type => 1
                  , i_inst_id     => i_inst_id
                );

        end if;
        
    end; 

    procedure qpr_mastercard_data(
        i_dest_curr        in     com_api_type_pkg.t_curr_code
      , i_year             in     com_api_type_pkg.t_tiny_id
      , i_quarter          in     com_api_type_pkg.t_tiny_id
      , i_network_id       in     com_api_type_pkg.t_tiny_id
      , i_cmid_network_id  in     com_api_type_pkg.t_tiny_id    default null
      , i_report_name      in     com_api_type_pkg.t_dict_value default null
      , i_rate_type        in     com_api_type_pkg.t_dict_value default mcw_api_const_pkg.MC_RATE_TYPE
      , i_inst_id          in     com_api_type_pkg.t_inst_id    default null
    )
    is
        l_del_value          com_api_type_pkg.t_tiny_id;
        l_start_date         date;
        l_end_date           date;
        l_host_id            com_api_type_pkg.t_tiny_id;
        l_standard_id        com_api_type_pkg.t_tiny_id;
        l_excepted_count     com_api_type_pkg.t_long_id := 0;
        l_processed_count    com_api_type_pkg.t_long_id := 0;
        l_count              com_api_type_pkg.t_long_id := 0;

        l_group_name              com_api_type_pkg.t_name_tab;
        l_param_name              com_api_type_pkg.t_name_tab;
        l_month_number            com_api_type_pkg.t_integer_tab;
        l_cmid                    com_api_type_pkg.t_cmid_tab;
        l_inst_id                 com_api_type_pkg.t_inst_id_tab;
        l_card_type               com_api_type_pkg.t_name_tab;
        l_card_type_id            com_api_type_pkg.t_tiny_tab;
        l_card_type_feature       com_api_type_pkg.t_dict_tab;
        
        l_value_1                 com_api_type_pkg.t_money_tab;
        l_value_2                 com_api_type_pkg.t_money_tab;
        l_value_3                 com_api_type_pkg.t_money_tab;
        l_value                   com_api_type_pkg.t_money;
        l_value_begin             com_api_type_pkg.t_money;
        l_value_end               com_api_type_pkg.t_money;

        l_report_name  com_api_type_pkg.t_name;
    begin
        savepoint qpr_start_prepare_mc;

        prc_api_stat_pkg.log_start;
        
        if (i_report_name is not null) then
           l_report_name := case when i_report_name = 'MCQR0001' then 'PS_MC_ACQUIRING' 
                                 when i_report_name = 'MCQR0002' then 'PS_MC_ISSUING' 
                                 when i_report_name = 'MCQR0003' then 'PS_MC_ACQ_MAESTRO'  
                                 when i_report_name = 'MCQR0004' then 'PS_MC_MAESTRO'  
                         end;
        end if;

        if i_inst_id is null then
            l_host_id  := net_api_network_pkg.get_default_host(i_network_id);
        else
            l_host_id  := net_api_network_pkg.get_host_id(i_inst_id, nvl(i_cmid_network_id, i_network_id));
        end if;

        l_standard_id  := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

        l_start_date   := add_months( to_date( '01' || lpad(i_quarter * 3, 2, '0') || to_char(i_year), 'ddmmyyyy' )
                                   , -2
                                   );
        l_end_date     := add_months(l_start_date, 3) - 0.00001;
        
        l_del_value    := power( 10, nvl( com_api_currency_pkg.get_currency_exponent(i_dest_curr), 0 ) );

        clear_table(
            i_year        => i_year
          , i_start_date  => l_start_date
          , i_end_date    => l_end_date
          , i_report_name => l_report_name
          , i_inst_id     => i_inst_id
        );

        qpr_api_util_pkg.clear_values;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => estimate_messages_for_mc(i_report_name => l_report_name)
        );
        
        if (nvl(l_report_name,'PS_MC_ACQUIRING')='PS_MC_ACQUIRING') then

            open cu_data_group_1(
                           i_dest_curr     => i_dest_curr
                         , i_del_value     => l_del_value
                         , i_start_date    => l_start_date
                         , i_end_date      => l_end_date
                         , i_standard_id   => l_standard_id
                         , i_host_id       => l_host_id
                         , i_rate_type     => i_rate_type
                         , i_network_id    => i_network_id
                         , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_1
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop

                    l_count := 1;
                    qpr_api_util_pkg.insert_param(
                        i_param_name    => l_param_name(i)
                      , i_group_name    => l_group_name(i)
                      , i_year          => i_year
                      , i_month_num     => l_month_number(i)
                      , i_cmid          => l_cmid(i)
                      , i_value_1       => l_value_1(i)
                      , i_value_2       => l_value_2(i)
                      , i_value_3       => l_value_3(i)
                      , i_curr_code     => i_dest_curr
                      , i_inst_id       => l_inst_id(i)
                      , i_report_name   => 'PS_MC_ACQUIRING'
                      , i_card_type_id  => mcw_api_const_pkg.QR_MASTER_CARD_TYPE
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_1%notfound;
            end loop;
            close cu_data_group_1;
            qpr_api_util_pkg.clear_values;

            open cu_data_group_2(
                         i_start_date      => l_start_date
                         , i_end_date      => l_end_date
                         , i_standard_id   => l_standard_id
                         , i_host_id       => l_host_id
                         , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_2
                bulk collect into
                l_cmid
                , l_param_name
                , l_group_name
                , l_inst_id
                , l_value_1
                , l_value_2
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop

                    qpr_api_util_pkg.insert_param(
                        i_param_name    => l_param_name(i)
                      , i_group_name    => l_group_name(i)
                      , i_year          => i_year
                      , i_month_num     => i_quarter * 3 - 2
                      , i_cmid          => l_cmid(i)
                      , i_value_1       => l_value_1(i)
                      , i_value_2       => l_value_2(i)
                      , i_curr_code     => i_dest_curr
                      , i_inst_id       => l_inst_id(i)
                      , i_report_name   => 'PS_MC_ACQUIRING'
                      , i_card_type_id  => mcw_api_const_pkg.QR_MASTER_CARD_TYPE
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_2%notfound;
            end loop;
            close cu_data_group_2;
            qpr_api_util_pkg.clear_values;

            l_processed_count   := l_processed_count + l_count;
            prc_api_stat_pkg.log_current(
                i_current_count     => l_processed_count
              , i_excepted_count    => l_excepted_count
            );
        end if;
        
        if (nvl(l_report_name,'PS_MC_ACQ_MAESTRO')='PS_MC_ACQ_MAESTRO') then

            l_count := 0;
            open cu_data_group_1_1(
                           i_dest_curr     => i_dest_curr
                         , i_del_value     => l_del_value
                         , i_start_date    => l_start_date
                         , i_end_date      => l_end_date
                         , i_standard_id   => l_standard_id
                         , i_host_id       => l_host_id
                         , i_rate_type     => i_rate_type
                         , i_network_id    => i_network_id
                         , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_1_1
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop

                    l_count := 1;
                    qpr_api_util_pkg.insert_param(
                        i_param_name    => l_param_name(i)
                      , i_group_name    => l_group_name(i)
                      , i_year          => i_year
                      , i_month_num     => l_month_number(i)
                      , i_cmid          => l_cmid(i)
                      , i_value_1       => l_value_1(i)
                      , i_value_2       => l_value_2(i)
                      , i_curr_code     => i_dest_curr
                      , i_inst_id       => l_inst_id(i)
                      , i_report_name   => 'PS_MC_ACQ_MAESTRO'
                      , i_card_type_id  => mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_1_1%notfound;
            end loop;
            close cu_data_group_1_1;
            qpr_api_util_pkg.clear_values;

            open cu_data_group_3(
                i_start_date      => l_start_date
                , i_end_date      => l_end_date
                , i_standard_id   => l_standard_id
                , i_host_id       => l_host_id
                , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_3
                bulk collect into
                l_cmid
                , l_param_name
                , l_group_name
                , l_inst_id
                , l_value_1
                , l_value_2
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop

                    qpr_api_util_pkg.insert_param(
                        i_param_name    => l_param_name(i)
                      , i_group_name    => l_group_name(i)
                      , i_year          => i_year
                      , i_month_num     => i_quarter * 3 - 2
                      , i_cmid          => l_cmid(i)
                      , i_value_1       => l_value_1(i)
                      , i_value_2       => l_value_2(i)
                      , i_curr_code     => i_dest_curr
                      , i_inst_id       => l_inst_id(i)
                      , i_report_name   => 'PS_MC_ACQ_MAESTRO'
                      , i_card_type_id  => mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_3%notfound;
            end loop;
            close cu_data_group_3;
            qpr_api_util_pkg.clear_values;

            l_processed_count   := l_processed_count + l_count;
            prc_api_stat_pkg.log_current(
                i_current_count     => l_processed_count
              , i_excepted_count    => l_excepted_count
            );
        end if;        
        
        if (nvl(l_report_name,'PS_MC_ISSUING')='PS_MC_ISSUING') then

            l_count := 0;
            open cu_data_group_4(
                           i_dest_curr     => i_dest_curr
                         , i_del_value     => l_del_value
                         , i_start_date    => l_start_date
                         , i_end_date      => l_end_date
                         , i_standard_id   => l_standard_id
                         , i_host_id       => l_host_id
                         , i_rate_type     => i_rate_type
                         , i_network_id    => i_network_id
                         , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_4
                bulk collect into
                l_cmid
                , l_card_type
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                , l_card_type_id
                , l_card_type_feature
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop

                    l_count := 1;
                    qpr_api_util_pkg.insert_param(
                        i_param_name         => l_param_name(i)
                      , i_group_name         => l_group_name(i)
                      , i_year               => i_year
                      , i_month_num          => l_month_number(i)
                      , i_cmid               => l_cmid(i)
                      , i_value_1            => l_value_1(i)
                      , i_value_2            => l_value_2(i)
                      , i_value_3            => l_value_3(i)
                      , i_curr_code          => i_dest_curr
                      , i_card_type          => l_card_type(i)
                      , i_inst_id            => l_inst_id(i)
                      , i_report_name        => 'PS_MC_ISSUING'
                      , i_card_type_id       => l_card_type_id(i)
                      , i_card_type_feature  => l_card_type_feature(i)
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_4%notfound;
            end loop;
            close cu_data_group_4;
            qpr_api_util_pkg.clear_values;

            open cu_data_group_4_1(
                           i_quarter       => i_quarter
                         , i_start_date    => l_start_date
                         , i_end_date      => l_end_date
                         , i_standard_id   => l_standard_id
                         , i_host_id       => l_host_id
                         , i_network_id    => i_network_id
                         , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_4_1
                bulk collect into
                l_cmid
                , l_card_type
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                , l_card_type_id
                , l_card_type_feature
                limit BULK_LIMIT;
                         
                for i in 1..l_cmid.count loop
                    l_value := null;
                    begin
                        select value_3
                          into l_value
                          from qpr_param_value v
                         where v.inst_id         = l_inst_id(i)
                           and v.card_type_id    = l_card_type_id(i)
                           and v.year            = case
                                                       when l_month_number(i) < 4
                                                       then i_year - 1
                                                       else i_year
                                                   end
                           and v.month_num       = case
                                                       when l_month_number(i) < 4
                                                       then 9 + l_month_number(i)
                                                       else l_month_number(i) - 3
                                                   end
                           and v.param_group_id  = 1038
                           and v.id_param_value  = 1010;
                    exception
                        when no_data_found then
                            l_value := null;
                    end;

                    l_value_3(i) := nvl(l_value, l_value_3(i));
                    l_value_1(i) := l_value_3(i) - l_value_2(i);

                    qpr_api_util_pkg.insert_param(
                        i_param_name         => l_param_name(i)
                      , i_group_name         => l_group_name(i)
                      , i_year               => i_year
                      , i_month_num          => l_month_number(i)
                      , i_cmid               => l_cmid(i)
                      , i_curr_code          => i_dest_curr
                      , i_card_type          => l_card_type(i)
                      , i_value_1            => l_value_1(i)
                      , i_value_2            => l_value_2(i)
                      , i_value_3            => l_value_3(i)
                      , i_inst_id            => l_inst_id(i)
                      , i_report_name        => 'PS_MC_ISSUING'
                      , i_card_type_id       => l_card_type_id(i)
                      , i_card_type_feature  => l_card_type_feature(i)
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_4_1%notfound;
            end loop;
            close cu_data_group_4_1;   
            qpr_api_util_pkg.clear_values;

            open cu_data_group_4_3(
                           i_quarter       => i_quarter
                         , i_start_date    => l_start_date
                         , i_end_date      => l_end_date
                         , i_standard_id   => l_standard_id
                         , i_host_id       => l_host_id
                         , i_network_id    => i_network_id
                         , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_4_3
                bulk collect into
                l_cmid
                , l_card_type
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                , l_card_type_id
                , l_card_type_feature
                limit BULK_LIMIT;
                         
                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name         => l_param_name(i)
                      , i_group_name         => l_group_name(i)
                      , i_year               => i_year
                      , i_month_num          => l_month_number(i)
                      , i_cmid               => l_cmid(i)
                      , i_curr_code          => i_dest_curr
                      , i_card_type          => l_card_type(i)
                      , i_value_1            => l_value_1(i)
                      , i_value_2            => l_value_2(i)
                      , i_value_3            => l_value_3(i)
                      , i_inst_id            => l_inst_id(i)
                      , i_report_name        => 'PS_MC_ISSUING'
                      , i_card_type_id       => l_card_type_id(i)
                      , i_card_type_feature  => l_card_type_feature(i)
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_4_3%notfound;
            end loop;
            close cu_data_group_4_3;  
            qpr_api_util_pkg.clear_values;

            open cu_data_group_4_2(
                           i_quarter       => i_quarter
                         , i_start_date    => l_start_date
                         , i_end_date      => l_end_date
                         , i_standard_id   => l_standard_id
                         , i_host_id       => l_host_id
                         , i_network_id    => i_network_id
                         , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_4_2
                bulk collect into
                l_cmid
                , l_card_type
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                , l_card_type_id
                , l_card_type_feature
                limit BULK_LIMIT;
                         
                for i in 1..l_cmid.count loop
                    l_value := 0;
                    begin
                        select nvl(ve.value_3, 0), nvl(vb.value_3, 0)
                          into l_value_end, l_value_begin
                          from qpr_param_value vb
                             , qpr_param_value ve
                         where vb.month_num      = l_month_number(i)
                           and vb.year           = i_year
                           and vb.param_group_id = 1035
                           and vb.id_param_value = 1007
                           and vb.inst_id        = l_inst_id(i)
                           and vb.card_type_id   = l_card_type_id(i)
                           and vb.card_type_id   = ve.card_type_id
                           and vb.inst_id        = ve.inst_id
                           and vb.month_num      = ve.month_num
                           and vb.year           = ve.year
                           and ve.param_group_id = 1038
                           and ve.id_param_value = 1010;
                    exception
                        when no_data_found then
                            l_value_end   := 0;
                            l_value_begin := 0;
                    end;

                    l_value := l_value_begin + l_value_3(i) - l_value_end;
                    if l_value < 0 then
                        l_value_3(i) := l_value_end - l_value_begin;
                        l_value := 0;
                    end if;

                    qpr_api_util_pkg.insert_param(
                        i_param_name         => l_param_name(i)
                      , i_group_name         => l_group_name(i)
                      , i_year               => i_year
                      , i_month_num          => l_month_number(i)
                      , i_cmid               => l_cmid(i)
                      , i_curr_code          => i_dest_curr
                      , i_card_type          => l_card_type(i)
                      , i_value_1            => l_value_1(i)
                      , i_value_2            => l_value_2(i)
                      , i_value_3            => l_value_3(i)
                      , i_inst_id            => l_inst_id(i)
                      , i_report_name        => 'PS_MC_ISSUING'
                      , i_card_type_id       => l_card_type_id(i)
                      , i_card_type_feature  => l_card_type_feature(i)
                    );
                    
                    if l_value > 0 then
                        qpr_api_util_pkg.insert_param(
                            i_param_name         => '1009.Accounts lost during quarter'
                          , i_group_name         => l_group_name(i)
                          , i_year               => i_year
                          , i_month_num          => l_month_number(i)
                          , i_cmid               => l_cmid(i)
                          , i_curr_code          => i_dest_curr
                          , i_card_type          => l_card_type(i)
                          , i_value_1            => l_value_1(i)
                          , i_value_2            => l_value_2(i)
                          , i_value_3            => l_value
                          , i_inst_id            => l_inst_id(i)
                          , i_report_name        => 'PS_MC_ISSUING'
                          , i_card_type_id       => l_card_type_id(i)
                          , i_card_type_feature  => l_card_type_feature(i)
                        );
                    end if;
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_4_2%notfound;
            end loop;
            close cu_data_group_4_2;   
            qpr_api_util_pkg.clear_values;
            
            open cu_data_group_4_4(
                       i_quarter       => i_quarter
                     , i_end_date      => l_end_date
                     , i_standard_id   => l_standard_id
                     , i_host_id       => l_host_id
                     , i_network_id    => i_network_id
                     , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_4_4
                bulk collect into
                l_cmid
                , l_card_type
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                , l_card_type_id
                , l_card_type_feature
                limit BULK_LIMIT;
                         
                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name         => l_param_name(i)
                      , i_group_name         => l_group_name(i)
                      , i_year               => i_year
                      , i_month_num          => l_month_number(i)
                      , i_cmid               => l_cmid(i)
                      , i_curr_code          => i_dest_curr
                      , i_card_type          => l_card_type(i)
                      , i_value_1            => l_value_1(i)
                      , i_value_2            => l_value_2(i)
                      , i_value_3            => l_value_3(i)
                      , i_inst_id            => l_inst_id(i)
                      , i_report_name        => 'PS_MC_ISSUING'
                      , i_card_type_id       => l_card_type_id(i)
                      , i_card_type_feature  => l_card_type_feature(i)
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_4_4%notfound;
            end loop;
            close cu_data_group_4_4; 
            qpr_api_util_pkg.clear_values;

            open cu_data_group_4_5(
                       i_quarter       => i_quarter
                     , i_start_date    => l_start_date
                     , i_end_date      => l_end_date
                     , i_standard_id   => l_standard_id
                     , i_host_id       => l_host_id
                     , i_network_id    => i_network_id
                     , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_4_5
                bulk collect into
                l_cmid
                , l_card_type
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                , l_card_type_id
                , l_card_type_feature
                limit BULK_LIMIT;
                         
                for i in 1..l_cmid.count loop
                    l_value := null;
                    begin
                        select value_3
                          into l_value
                          from qpr_param_value v
                         where v.inst_id         = l_inst_id(i)
                           and v.card_type_id    = l_card_type_id(i)
                           and v.year            = case
                                                       when l_month_number(i) < 4
                                                       then i_year - 1
                                                       else i_year
                                                   end
                           and v.month_num       = case
                                                       when l_month_number(i) < 4
                                                       then 9 + l_month_number(i)
                                                       else l_month_number(i) - 3
                                                   end
                           and v.param_group_id  = 2095
                           and v.id_param_value  = 2057;
                    exception
                        when no_data_found then
                            l_value := null;
                    end;
                    if substr(l_param_name(i), 1, instr(l_param_name(i), '.') - 1) = '1012'
                       and substr(l_group_name(i), 1, instr(l_group_name(i), '.') - 1) = '106' then 
                        l_value_3(i) := nvl(l_value, l_value_3(i));
                        l_value_1(i) := l_value_3(i) - l_value_2(i);
                    end if;
                    qpr_api_util_pkg.insert_param(
                        i_param_name         => l_param_name(i)
                      , i_group_name         => l_group_name(i)
                      , i_year               => i_year
                      , i_month_num          => l_month_number(i)
                      , i_cmid               => l_cmid(i)
                      , i_curr_code          => i_dest_curr
                      , i_card_type          => l_card_type(i)
                      , i_value_1            => l_value_1(i)
                      , i_value_2            => l_value_2(i)
                      , i_value_3            => l_value_3(i)
                      , i_inst_id            => l_inst_id(i)
                      , i_report_name        => 'PS_MC_ISSUING'
                      , i_card_type_id       => l_card_type_id(i)
                      , i_card_type_feature  => l_card_type_feature(i)
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_4_5%notfound;
            end loop;
            close cu_data_group_4_5; 
            qpr_api_util_pkg.clear_values;
            
            open cu_data_group_4_7(
                       i_quarter       => i_quarter
                     , i_start_date    => l_start_date
                     , i_end_date      => l_end_date
                     , i_standard_id   => l_standard_id
                     , i_host_id       => l_host_id
                     , i_network_id    => i_network_id
                     , i_inst_id       => i_inst_id
                     , i_dest_curr     => i_dest_curr
                     , i_rate_type     => i_rate_type
                     , i_del_value     => l_del_value
            );
            loop
                fetch cu_data_group_4_7
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_card_type
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                , l_card_type_id
                , l_card_type_feature
                limit BULK_LIMIT;
                         
                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name         => l_param_name(i)
                      , i_group_name         => l_group_name(i)
                      , i_year               => i_year
                      , i_month_num          => l_month_number(i)
                      , i_cmid               => l_cmid(i)
                      , i_curr_code          => i_dest_curr
                      , i_card_type          => l_card_type(i)
                      , i_value_1            => l_value_1(i)
                      , i_value_2            => l_value_2(i)
                      , i_value_3            => l_value_3(i)
                      , i_inst_id            => l_inst_id(i)
                      , i_report_name        => 'PS_MC_ISSUING'
                      , i_card_type_id       => l_card_type_id(i)
                      , i_card_type_feature  => l_card_type_feature(i)
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_4_7%notfound;
            end loop;
            close cu_data_group_4_7; 
            qpr_api_util_pkg.clear_values;

            l_processed_count   := l_processed_count + l_count;
            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count
              , i_excepted_count => l_excepted_count
            );
        end if;
    
        if (nvl(l_report_name,'PS_MC_MAESTRO')='PS_MC_MAESTRO') then

            l_count := 0;
            open cu_data_group_5(
                           i_dest_curr     => i_dest_curr
                         , i_del_value     => l_del_value
                         , i_start_date    => l_start_date
                         , i_end_date      => l_end_date
                         , i_standard_id   => l_standard_id
                         , i_host_id       => l_host_id
                         , i_rate_type     => i_rate_type
                         , i_network_id    => i_network_id
                         , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_5
                bulk collect into
                l_cmid
                , l_card_type
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                , l_card_type_id
                , l_card_type_feature
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop

                    l_count := 1;
                    qpr_api_util_pkg.insert_param(
                        i_param_name         => l_param_name(i)
                      , i_group_name         => l_group_name(i)
                      , i_year               => i_year
                      , i_month_num          => l_month_number(i)
                      , i_cmid               => l_cmid(i)
                      , i_value_1            => l_value_1(i)
                      , i_value_2            => l_value_2(i)
                      , i_value_3            => l_value_3(i)
                      , i_curr_code          => i_dest_curr
                      , i_card_type          => l_card_type(i)
                      , i_inst_id            => l_inst_id(i)
                      , i_report_name        => 'PS_MC_MAESTRO'
                      , i_card_type_id       => l_card_type_id(i)
                      , i_card_type_feature  => l_card_type_feature(i)
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_5%notfound;
            end loop;
            close cu_data_group_5;
            qpr_api_util_pkg.clear_values;

            open cu_data_group_5_1(
                       i_quarter       => i_quarter
                     , i_end_date      => l_end_date
                     , i_standard_id   => l_standard_id
                     , i_host_id       => l_host_id
                     , i_network_id    => i_network_id
                     , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_5_1
                bulk collect into
                l_cmid
                , l_card_type
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                , l_card_type_id
                , l_card_type_feature
                limit BULK_LIMIT;
                         
                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name         => l_param_name(i)
                      , i_group_name         => l_group_name(i)
                      , i_year               => i_year
                      , i_month_num          => l_month_number(i)
                      , i_cmid               => l_cmid(i)
                      , i_curr_code          => i_dest_curr
                      , i_card_type          => l_card_type(i)
                      , i_value_1            => l_value_1(i)
                      , i_value_2            => l_value_2(i)
                      , i_value_3            => l_value_3(i)
                      , i_inst_id            => l_inst_id(i)
                      , i_report_name        => 'PS_MC_MAESTRO'
                      , i_card_type_id       => l_card_type_id(i)
                      , i_card_type_feature  => l_card_type_feature(i)
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_5_1%notfound;
            end loop;
            close cu_data_group_5_1; 
            qpr_api_util_pkg.clear_values;
            
            open cu_data_group_5_2(
                       i_quarter       => i_quarter
                     , i_start_date    => l_start_date
                     , i_end_date      => l_end_date
                     , i_standard_id   => l_standard_id
                     , i_host_id       => l_host_id
                     , i_network_id    => i_network_id
                     , i_inst_id       => i_inst_id
            );
            loop
                fetch cu_data_group_5_2
                bulk collect into
                l_cmid
                , l_card_type
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                , l_card_type_id
                , l_card_type_feature
                limit BULK_LIMIT;
                         
                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name         => l_param_name(i)
                      , i_group_name         => l_group_name(i)
                      , i_year               => i_year
                      , i_month_num          => l_month_number(i)
                      , i_cmid               => l_cmid(i)
                      , i_curr_code          => i_dest_curr
                      , i_card_type          => l_card_type(i)
                      , i_value_1            => l_value_1(i)
                      , i_value_2            => l_value_2(i)
                      , i_value_3            => l_value_3(i)
                      , i_inst_id            => l_inst_id(i)
                      , i_report_name        => 'PS_MC_MAESTRO'
                      , i_card_type_id       => l_card_type_id(i)
                      , i_card_type_feature  => l_card_type_feature(i)
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_5_2%notfound;
            end loop;
            close cu_data_group_5_2;
            qpr_api_util_pkg.clear_values;

            open cu_data_group_5_3(
                       i_quarter       => i_quarter
                     , i_start_date    => l_start_date 
                     , i_end_date      => l_end_date
                     , i_standard_id   => l_standard_id
                     , i_host_id       => l_host_id
                     , i_network_id    => i_network_id
                     , i_inst_id       => i_inst_id
                     , i_dest_curr     => i_dest_curr
                     , i_rate_type     => i_rate_type
                     , i_del_value     => l_del_value
            );
            loop
                fetch cu_data_group_5_3
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_card_type
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                , l_card_type_id
                , l_card_type_feature
                limit BULK_LIMIT;
                         
                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name         => l_param_name(i)
                      , i_group_name         => l_group_name(i)
                      , i_year               => i_year
                      , i_month_num          => l_month_number(i)
                      , i_cmid               => l_cmid(i)
                      , i_curr_code          => i_dest_curr
                      , i_card_type          => l_card_type(i)
                      , i_value_1            => l_value_1(i)
                      , i_value_2            => l_value_2(i)
                      , i_value_3            => l_value_3(i)
                      , i_inst_id            => l_inst_id(i)
                      , i_report_name        => 'PS_MC_MAESTRO'
                      , i_card_type_id       => l_card_type_id(i)
                      , i_card_type_feature  => l_card_type_feature(i)
                    );
                end loop;
                qpr_api_util_pkg.save_values;
                
                exit when cu_data_group_5_3%notfound;
            end loop;
            close cu_data_group_5_3; 
            qpr_api_util_pkg.clear_values;

            l_processed_count   := l_processed_count + l_count;
            prc_api_stat_pkg.log_current(
                i_current_count => l_processed_count
              , i_excepted_count => l_excepted_count
            );
        
        end if;

    exception
        when others then
            rollback to savepoint qpr_start_prepare_mc;

        if cu_data_group_1%isopen then
            close cu_data_group_1;
        end if;
         
        if cu_data_group_1_1%isopen then
            close cu_data_group_1_1;
        end if;
         
        if cu_data_group_2%isopen then
            close cu_data_group_2;
        end if;
         
        if cu_data_group_3%isopen then
            close cu_data_group_3;
        end if;
         
        if cu_data_group_4%isopen then
            close cu_data_group_4;
        end if;
         
        if cu_data_group_4_1%isopen then
            close cu_data_group_4_1;
        end if;          
         
        if cu_data_group_4_2%isopen then
            close cu_data_group_4_2;
        end if;
         
        if cu_data_group_4_3%isopen then
            close cu_data_group_4_3;
        end if;
         
        if cu_data_group_4_4%isopen then
            close cu_data_group_4_4;
        end if;
         
        if cu_data_group_4_5%isopen then
            close cu_data_group_4_5;
        end if;
         
        if cu_data_group_4_7%isopen then
            close cu_data_group_4_7;
        end if;
         
        if cu_data_group_4_8%isopen then
            close cu_data_group_4_8;
        end if;
         
        if cu_data_group_5%isopen then
            close cu_data_group_5;
        end if;
         
        if cu_data_group_5_dipped%isopen then
            close cu_data_group_5_dipped;
        end if;
         
        if cu_data_group_5_1%isopen then
            close cu_data_group_5_1;
        end if;          
         
        if cu_data_group_5_2%isopen then
            close cu_data_group_5_2;
        end if;
         
        if cu_data_group_5_3%isopen then
            close cu_data_group_5_3;
        end if;
         
        if cu_data_group_5_4%isopen then
            close cu_data_group_5_4;
        end if;
         
        prc_api_stat_pkg.log_end(
            i_result_code => prc_api_const_pkg.process_result_failed
        );

        trc_log_pkg.error(i_text => sqlerrm);

        raise;
    end;

begin
    -- TODO "Replace with array definition"
    g_sepa_country('248'):= com_api_const_pkg.TRUE;  -- ALAND ISLANDS
    g_sepa_country('008'):= com_api_const_pkg.FALSE; -- ALBANIA
    g_sepa_country('020'):= com_api_const_pkg.TRUE;  -- ANDORRA
    g_sepa_country('010'):= com_api_const_pkg.TRUE;  -- ANTARCTICA
    g_sepa_country('051'):= com_api_const_pkg.FALSE; -- ARMENIA
    g_sepa_country('040'):= com_api_const_pkg.TRUE;  -- AUSTRIA
    g_sepa_country('031'):= com_api_const_pkg.FALSE; -- AZERBAIJAN
    g_sepa_country('112'):= com_api_const_pkg.FALSE; -- BELARUS
    g_sepa_country('056'):= com_api_const_pkg.TRUE;  -- BELGIUM
    g_sepa_country('070'):= com_api_const_pkg.FALSE; -- BOSNIA AND HERZEGOVINA
    g_sepa_country('100'):= com_api_const_pkg.TRUE;  -- BULGARIA
    g_sepa_country('191'):= com_api_const_pkg.TRUE;  -- CROATIA
    g_sepa_country('196'):= com_api_const_pkg.TRUE;  -- CYPRUS
    g_sepa_country('203'):= com_api_const_pkg.TRUE;  -- CZECH REPUBLIC
    g_sepa_country('208'):= com_api_const_pkg.TRUE;  -- DENMARK
    g_sepa_country('233'):= com_api_const_pkg.TRUE;  -- ESTONIA
    g_sepa_country('238'):= com_api_const_pkg.TRUE;  -- FALKLAND ISLANDS (MALVINAS)
    g_sepa_country('234'):= com_api_const_pkg.TRUE;  -- FAROE ISLANDS
    g_sepa_country('246'):= com_api_const_pkg.TRUE;  -- FINLAND
    g_sepa_country('250'):= com_api_const_pkg.TRUE;  -- FRANCE
    g_sepa_country('254'):= com_api_const_pkg.TRUE;  -- FRENCH GUIANA
    g_sepa_country('268'):= com_api_const_pkg.FALSE; -- GEORGIA
    g_sepa_country('280'):= com_api_const_pkg.TRUE;  -- GERMANY
    g_sepa_country('292'):= com_api_const_pkg.TRUE;  -- GIBRALTAR
    g_sepa_country('300'):= com_api_const_pkg.TRUE;  -- GREECE
    g_sepa_country('304'):= com_api_const_pkg.TRUE;  -- GREENLAND
    g_sepa_country('312'):= com_api_const_pkg.TRUE;  -- GUADELOUPE
    g_sepa_country('831'):= com_api_const_pkg.TRUE;  -- GUERNSEY
    g_sepa_country('336'):= com_api_const_pkg.TRUE;  -- HOLY SEE (VATICAN CITY STATE)
    g_sepa_country('348'):= com_api_const_pkg.TRUE;  -- HUNGARY
    g_sepa_country('352'):= com_api_const_pkg.TRUE;  -- ICELAND
    g_sepa_country('372'):= com_api_const_pkg.TRUE;  -- IRELAND
    g_sepa_country('833'):= com_api_const_pkg.TRUE;  -- ISLE OF MAN
    g_sepa_country('376'):= com_api_const_pkg.FALSE; -- ISRAEL
    g_sepa_country('380'):= com_api_const_pkg.TRUE;  -- ITALY
    g_sepa_country('832'):= com_api_const_pkg.TRUE;  -- JERSEY
    g_sepa_country('398'):= com_api_const_pkg.FALSE; -- KAZAKHSTAN
    g_sepa_country('900'):= com_api_const_pkg.FALSE; -- KOSOVO
    g_sepa_country('417'):= com_api_const_pkg.FALSE; -- KYRGYZSTAN
    g_sepa_country('428'):= com_api_const_pkg.TRUE;  -- LATVIA
    g_sepa_country('438'):= com_api_const_pkg.TRUE;  -- LIECHTENSTEIN
    g_sepa_country('440'):= com_api_const_pkg.TRUE;  -- LITHUANIA
    g_sepa_country('442'):= com_api_const_pkg.TRUE;  -- LUXEMBOURG
    g_sepa_country('807'):= com_api_const_pkg.FALSE; -- MACEDONIA
    g_sepa_country('470'):= com_api_const_pkg.TRUE;  -- MALTA
    g_sepa_country('474'):= com_api_const_pkg.TRUE;  -- MARTINIQUE
    g_sepa_country('175'):= com_api_const_pkg.TRUE;  -- MAYOTTE
    g_sepa_country('498'):= com_api_const_pkg.FALSE; -- MOLDOVA, REPUBLIC OF
    g_sepa_country('492'):= com_api_const_pkg.TRUE;  -- MONACO
    g_sepa_country('499'):= com_api_const_pkg.FALSE; -- MONTENEGRO
    g_sepa_country('528'):= com_api_const_pkg.TRUE;  -- NETHERLANDS
    g_sepa_country('578'):= com_api_const_pkg.TRUE;  -- NORWAY
    g_sepa_country('616'):= com_api_const_pkg.TRUE;  -- POLAND
    g_sepa_country('620'):= com_api_const_pkg.TRUE;  -- PORTUGAL
    g_sepa_country('638'):= com_api_const_pkg.TRUE;  -- REUNION
    g_sepa_country('642'):= com_api_const_pkg.TRUE;  -- ROMANIA
    g_sepa_country('643'):= com_api_const_pkg.FALSE; -- RUSSIAN FEDERATION
    g_sepa_country('239'):= com_api_const_pkg.TRUE;  -- S GEORGIA S SANDWICH ISLANDS
    g_sepa_country('652'):= com_api_const_pkg.TRUE;  -- SAINT BARTHELEMY
    g_sepa_country('654'):= com_api_const_pkg.TRUE;  -- SAINT HELENA
    g_sepa_country('663'):= com_api_const_pkg.TRUE;  -- SAINT MARTIN FRENCH PART
    g_sepa_country('674'):= com_api_const_pkg.TRUE;  -- SAN MARINO
    g_sepa_country('688'):= com_api_const_pkg.FALSE; -- SERBIA
    g_sepa_country('703'):= com_api_const_pkg.TRUE;  -- SLOVAKIA
    g_sepa_country('705'):= com_api_const_pkg.TRUE;  -- SLOVENIA
    g_sepa_country('724'):= com_api_const_pkg.TRUE;  -- SPAIN
    g_sepa_country('744'):= com_api_const_pkg.TRUE;  -- SVALBARD AND JAN MAYEN
    g_sepa_country('752'):= com_api_const_pkg.TRUE;  -- SWEDEN
    g_sepa_country('756'):= com_api_const_pkg.TRUE;  -- SWITZERLAND
    g_sepa_country('762'):= com_api_const_pkg.FALSE; -- TAJIKISTAN
    g_sepa_country('792'):= com_api_const_pkg.FALSE; -- TURKEY
    g_sepa_country('795'):= com_api_const_pkg.FALSE; -- TURKMENISTAN
    g_sepa_country('804'):= com_api_const_pkg.FALSE; -- UKRAINE
    g_sepa_country('826'):= com_api_const_pkg.TRUE;  -- UNITED KINGDOM
    g_sepa_country('860'):= com_api_const_pkg.FALSE; -- UZBEKISTAN

end mcw_prc_qpr_pkg;
/
