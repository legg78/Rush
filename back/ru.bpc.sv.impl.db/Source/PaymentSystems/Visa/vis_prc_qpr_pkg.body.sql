create or replace package body vis_prc_qpr_pkg is

    BULK_LIMIT      constant integer := 500;

    -- Acquiring atm/pos cash
    cursor cu_data_group_1 (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.month_number
         , group_name group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
      from (
            select m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                   as month_number
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                   as param_name
                 , case when o.is_iss = 1 then '208.On-Us'
                        when o.merchant_country = o.card_country then '209.National'
                        else '210.International'
                   end
                   as group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id in (select element_value
                                           from com_array_element
                                          where array_id = vis_api_const_pkg.QR_CARD_NETWORK_ARRAY)
               and o.card_type_id in (select element_value
                                        from com_array_element
                                       where array_id = vis_api_const_pkg.QR_CARD_TYPE_ARRAY)
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH , opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
          group by m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                 , case when o.is_iss = 1 then '208.On-Us'
                        when o.merchant_country = o.card_country then '209.National'
                        else '210.International'
                   end
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
         union all
            select m.cmid
                 , to_number(to_char(o.oper_date, 'mm')) month_number
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                   as param_name
                 , '211.Total Transactions' group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id in (select element_value
                                           from com_array_element
                                          where array_id = vis_api_const_pkg.QR_CARD_NETWORK_ARRAY)
               and o.card_type_id in (select element_value
                                        from com_array_element
                                       where array_id = vis_api_const_pkg.QR_CARD_TYPE_ARRAY)
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH , opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
          group by m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
           ) t
  group by t.cmid
         , t.month_number
         , t.param_name
         , t.group_name
         , t.inst_id
  order by t.cmid
         , t.month_number
         , t.param_name;


    cursor cu_data_group_1_1 (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid cmid
         , '212.ATM and Branches' group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn) value_1
      from (
            select cmid.cmid cmid
                 , 'ATMs Which Accept VISA' param_name
                 , cmid.inst_id
                 , 1 nn
              from acq_terminal trm
                 , acq_merchant acq
                 , cmid
             where trm.merchant_id    = acq.id
               and trm.is_template    = 0
               and trm.inst_id        = acq.inst_id
               and acq.inst_id        = cmid.inst_id
               and acq.mcc            in (vis_api_const_pkg.MCC_CASH, vis_api_const_pkg.MCC_ATM)
               and nvl(trm.mcc, acq.mcc) = vis_api_const_pkg.MCC_ATM
               and trm.status         = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
               and (select min(pso.start_date)
                      from prd_service_object pso
                     where pso.object_id = acq.id
                       and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   ) <= i_end_date

         union all

            select cmid.cmid cmid
                 , 'ATMs Which Accept VISA EMV' param_name
                 , cmid.inst_id
                 , 1 nn
              from acq_terminal trm
                 , acq_merchant acq
                 , cmid
             where trm.merchant_id    = acq.id
               and trm.is_template    = 0
               and trm.inst_id        = acq.inst_id
               and acq.inst_id        = cmid.inst_id
               and acq.mcc            in (vis_api_const_pkg.MCC_CASH, vis_api_const_pkg.MCC_ATM)
               and nvl(trm.mcc, acq.mcc) = vis_api_const_pkg.MCC_ATM
               and trm.status         = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
               and trm.card_data_input_cap in ('F2210001','F2210005','F221000C','F221000D','F221000E','F221000M')
               and (select min(pso.start_date)
                      from prd_service_object pso
                     where pso.object_id = acq.id
                       and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   ) <= i_end_date

         union all

            select distinct
                   cmid.cmid cmid
                 , 'Branches of Principal VISA' param_name
                 , cmid.inst_id
                 , 1 nn
              from acq_merchant acq
                 , acq_merchant acq2
                 , cmid
                 , acq_terminal trm
             where acq2.parent_id(+) = acq.id
               and acq2.id is null
               and trm.merchant_id   = acq.id
               and trm.is_template   = 0
               and trm.inst_id       = acq.inst_id
               and acq.inst_id       = cmid.inst_id
               and acq.mcc           = vis_api_const_pkg.MCC_CASH
               and nvl(trm.mcc, acq.mcc) = vis_api_const_pkg.MCC_CASH
               and trm.status        = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
               and (select min(pso.start_date)
                      from prd_service_object pso
                     where pso.object_id = acq.id
                       and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   ) <= i_end_date
         ) t
  group by t.cmid
         , t.param_name
         , t.inst_id;

-- Acquiring sales
    cursor cu_data_group_1_2 (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
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
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
      from (select m.cmid
                 , to_number(to_char(o.oper_date, 'mm')) month_number
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                   as param_name
                 , case when o.is_iss = 1 then '201.On-Us'
                        when o.merchant_country = o.card_country then '202.National'
                        else '203.International'
                   end
                   as group_name
                 , o.card_inst_id inst_id --p.inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and o.oper_type not in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH , opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
          group by m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                 , case when o.is_iss = 1 then '201.On-Us'
                        when o.merchant_country = o.card_country then '202.National'
                        else '203.International'
                   end
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
         union all
            select m.cmid
                 , to_number(to_char(o.oper_date, 'mm')) month_number
                 , 'of which on Electron Cards' param_name
                 , case when o.is_iss = 1 then '201.On-Us'
                        when o.merchant_country = o.card_country then '202.National'
                        else '203.International'
                   end
                   as group_name
                 , o.card_inst_id inst_id --p.inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , (select cf.card_type_id
                         , cf.card_feature
                      from net_card_type ct
                         , net_card_type_feature cf
                     where ct.network_id = i_network_id
                       and ct.id = cf.card_type_id
                       and card_feature in (vis_api_const_pkg.VISA_ELECTRON)
                   ) ct
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and o.card_type_id = ct.card_type_id
               and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   ) = 'Sales'
          group by m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                 , case when o.is_iss = 1 then '201.On-Us'
                        when o.merchant_country = o.card_country then '202.National'
                        else '203.International'
                   end
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
         union all
            select m.cmid
                 , to_number(to_char(o.oper_date, 'mm')) month_number
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                   as param_name
                 , '204.Total Transactions' group_name
                 , o.card_inst_id inst_id --p.inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and o.oper_type not in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH , opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
          group by m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
         union all
            select m.cmid
                 , to_number(to_char(o.oper_date, 'mm')) month_number
                 , 'of which on Electron Cards' param_name
                 , '204.Total Transactions' group_name
                 , o.card_inst_id inst_id --p.inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , (select cf.card_type_id
                         , cf.card_feature
                      from net_card_type ct
                         , net_card_type_feature cf
                     where ct.network_id = i_network_id
                       and ct.id = cf.card_type_id
                       and card_feature = vis_api_const_pkg.VISA_ELECTRON
                   ) ct
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and o.card_type_id = ct.card_type_id
               and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   ) = 'Sales'
          group by m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
           ) t
  group by t.cmid
         , t.month_number
         , t.param_name
         , t.group_name
         , t.inst_id
  order by t.cmid
         , t.month_number
         , t.param_name;

    -- Member and Merchant Data
    cursor cu_data_group_2_1 (
        i_start_date              in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid cmid
         , '205.Merchant Data' group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn) as value_1
      from (
        select cmid
             , param_name
             , to_char(null) as address_name
             , id
             , inst_id
             , nn
         from (
            select cmid.cmid cmid
                 , 'ATMs Which Accept VISA' param_name
                 , trm.id terminal_id
                 , acq.id
                 , cmid.inst_id
                 , 1 nn
              from acq_terminal trm
                 , acq_merchant acq
                 , cmid
             where trm.merchant_id    = acq.id
               and trm.is_template    = 0
               and trm.inst_id        = acq.inst_id
               and acq.inst_id        = cmid.inst_id
               and acq.mcc            in (vis_api_const_pkg.MCC_CASH, vis_api_const_pkg.MCC_ATM)
               and nvl(trm.mcc, acq.mcc) = vis_api_const_pkg.MCC_ATM
               and trm.status         = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
               and (select min(pso.start_date)
                              from prd_service_object pso
                             where pso.object_id = acq.id
                               and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                           ) <= i_end_date

         union all

            select cmid.cmid cmid
                 , 'ATMs Which Accept VISA EMV' param_name
                 , trm.id terminal_id
                 , acq.id
                 , cmid.inst_id
                 , 1 nn
              from acq_terminal trm
                 , acq_merchant acq
                 , cmid
             where trm.merchant_id    = acq.id
               and trm.is_template    = 0
               and trm.inst_id        = acq.inst_id
               and acq.inst_id        = cmid.inst_id
               and acq.mcc            in (vis_api_const_pkg.MCC_CASH, vis_api_const_pkg.MCC_ATM)
               and nvl(trm.mcc, acq.mcc) = vis_api_const_pkg.MCC_ATM
               and trm.status         = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
               and trm.card_data_input_cap in ('F2210005','F221000C','F221000D','F221000E')
               and (select min(pso.start_date)
                              from prd_service_object pso
                             where pso.object_id = acq.id
                               and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                           ) <= i_end_date

         union all

            select distinct
                   cmid.cmid cmid
                 , 'Branches of Principal VISA' param_name
                 , trm.id terminal_id
                 , acq.id
                 , cmid.inst_id
                 , 1 nn
              from acq_merchant acq
                 , acq_merchant acq2
                 , cmid
                 , acq_terminal trm
             where acq2.parent_id(+) = acq.id
               and acq2.id is null
               and trm.merchant_id   = acq.id
               and trm.is_template   = 0
               and trm.inst_id       = acq.inst_id
               and acq.inst_id       = cmid.inst_id
               and acq.mcc           = vis_api_const_pkg.MCC_CASH
               and nvl(trm.mcc, acq.mcc) = vis_api_const_pkg.MCC_CASH
               and trm.status        = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
               and (select min(pso.start_date)
                              from prd_service_object pso
                             where pso.object_id = acq.id
                               and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                           ) <= i_end_date
         )

         union all

        select cmid.cmid as cmid
             , 'Number Merchant' as param_name
             , to_char(null) as address_name
             , acq.id
             , cmid.inst_id
             , 1 as nn
          from acq_merchant acq
             , cmid
         where acq.inst_id    = cmid.inst_id
           and acq.parent_id  is null
           and acq.mcc        not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
           and (select min(pso.start_date)
                  from prd_service_object pso
                 where pso.object_id = acq.id
                   and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               ) <= i_end_date

         union all

        select distinct
               cmid.cmid as cmid
             , 'Number Outlets' param_name
             , com_api_address_pkg.get_address_string(o.address_id) address_name
             , acq.id
             , cmid.inst_id
             , 1 nn
          from acq_terminal trm
             , acq_merchant acq
             , cmid
             , com_address_object o
         where trm.merchant_id = acq.id
           and trm.inst_id    = acq.inst_id
           and acq.inst_id    = cmid.inst_id
           and acq.mcc        not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
           and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
           and o.object_id    = trm.id
           and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
           and (select min(pso.start_date)
                  from prd_service_object pso
                 where pso.object_id = acq.id
                   and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               ) <= i_end_date

          union all

        select distinct
               cmid.cmid as cmid
             , 'Number Outlets Electron' param_name
             , com_api_address_pkg.get_address_string(o.address_id) address_name
             , acq.id
             , cmid.inst_id
             , 1 nn
          from acq_terminal trm
             , acq_merchant acq
             , cmid
             , com_address_object o
         where trm.merchant_id = acq.id
           and trm.inst_id    = acq.inst_id
           and acq.inst_id    = cmid.inst_id
           and acq.mcc        not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
           and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
           and o.object_id    = trm.id
           and trm.card_data_input_cap in ('F2210000','F2210001','F2210002','F221000B','F221000C','F221000D','F221000M')
           and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
           and (select min(pso.start_date)
                  from prd_service_object pso
                 where pso.object_id = acq.id
                   and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               ) <= i_end_date

          union all

        select distinct
               cmid.cmid as cmid
             , 'Number Outlets CHIP' param_name
             , com_api_address_pkg.get_address_string(o.address_id) address_name
             , acq.id
             , cmid.inst_id
             , 1 nn
          from acq_terminal trm
             , acq_merchant acq
             , cmid
             , com_address_object o
         where trm.merchant_id = acq.id
           and trm.inst_id    = acq.inst_id
           and acq.inst_id    = cmid.inst_id
           and acq.mcc        not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
           and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
           and o.object_id    = trm.id
           and trm.card_data_input_cap in ('F2210005','F221000C','F221000D','F221000E','F221000M')
           and trm.status     = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
           and (select min(pso.start_date)
                  from prd_service_object pso
                 where pso.object_id = acq.id
                   and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               ) <= i_end_date
        ) t
    group by
        t.cmid
        , t.param_name
        , t.inst_id;

    -- Merchant Category Group Data
    cursor cu_data_group_2_2 (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.month_number
         , '206.Merchant Category Groups' group_name
         , t.visa_mcg param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount(
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.card_inst_id
                    , t.oper_date
                    , 1
                    , null
                )
            ) / i_del_value
        ) value_2
    from (
        select m.cmid cmid
             , to_number(to_char(trunc(o.oper_date,'Q'), 'mm')) month_number
             , o.card_inst_id card_inst_id
             , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
             , o.currency oper_currency
             , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
             , o.oper_date
             , nvl(cm.visa_mcg, 'Unknown, Not applicable') as visa_mcg
             , m.inst_id
          from qpr_aggr o
             , (select ct.id card_type_id
                  from net_card_type ct
                 where ct.network_id = i_network_id
               ) ct
             , cmid m
             , com_mcc cm
         where o.is_acq = 1
           and o.card_inst_id = m.inst_id
           and o.card_network_id = i_network_id
           and o.oper_date between i_start_date and i_end_date
           and o.card_type_id = ct.card_type_id
           and o.mcc = cm.mcc
           and com_api_array_pkg.conv_array_elem_v(
                   i_lov_id            => 49
                 , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                 , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                 , i_elem_value        => o.oper_type
               ) in ('Sales', 'Refunds')
         group by
              m.cmid
            , to_number(to_char(o.oper_date, 'mm'))
            , o.card_inst_id
            , o.currency
            , o.oper_date
            , nvl(cm.visa_mcg, 'Unknown, Not applicable')
            , m.inst_id
        ) t
    group by
        t.cmid
        , t.month_number
        , t.visa_mcg
        , t.inst_id
    order by
        t.month_number
        , t.visa_mcg;

    -- Merchant data
    cursor cu_data_group_2_1_ru (
        i_start_date              in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid cmid
         , '233.Merchant Data' group_name
         , t.information_name param_name
         , t.inst_id
         , sum(t.nn) value_1
      from (select m.cmid cmid
                 , 'Number Merchant' information_name
                 , null as address_name
                 , acq.id
                 , m.inst_id
                 , 1 nn
              from acq_merchant acq
                 , cmid m
             where acq.inst_id = m.inst_id
               and acq.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
               and acq.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
               and (select min(pso.start_date)
                      from prd_service_object pso
                     where pso.object_id = acq.id
                       and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   ) <= i_end_date

         union all

            select distinct
                   m.cmid cmid
                 , 'Number Outlets' information_name
                 , com_api_address_pkg.get_address_string(ao.address_id) address_name
                 , acq.id
                 , m.inst_id
                 , 1 nn
              from acq_merchant acq
                 , acq_merchant acq2
                 , cmid m
                 , acq_terminal trm
                 , com_address_object ao
             where acq2.parent_id(+) = acq.id
               and acq2.id is null
               and trm.merchant_id = acq.id
               and trm.id = ao.object_id(+)
               and ao.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
               and acq.inst_id = m.inst_id
               and acq.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
               and acq.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
               and (select min(pso.start_date)
                      from prd_service_object pso
                     where pso.object_id = acq.id
                       and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   ) <= i_end_date

         union all

            select distinct
                   m.cmid cmid
                 , 'Number Outlets Electron' information_name
                 , com_api_address_pkg.get_address_string(ao.address_id) address_name
                 , acq.id
                 , m.inst_id
                 , 1 nn
              from acq_merchant acq
                 , acq_merchant acq2
                 , cmid m
                 , acq_terminal trm
                 , com_address_object ao
             where acq2.parent_id(+) = acq.id
               and acq2.id is null
               and trm.merchant_id = acq.id
               and trm.id = ao.object_id(+)
               and ao.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
               and acq.inst_id = m.inst_id
               and acq.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
               and acq.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
               and trm.card_data_input_cap in ('F2210001','F2210002','F221000B','F221000C','F221000D','F221000M')
               and (select min(pso.start_date)
                      from prd_service_object pso
                     where pso.object_id = acq.id
                       and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   ) <= i_end_date

         union all

            select distinct
                   m.cmid cmid
                 , 'Number Outlets CHIP' information_name
                 , com_api_address_pkg.get_address_string(ao.address_id) address_name
                 , acq.id
                 , m.inst_id
                 , 1 nn
              from acq_merchant acq
                 , acq_merchant acq2
                 , cmid m
                 , acq_terminal trm
                 , com_address_object ao
             where acq2.parent_id(+) = acq.id
               and acq2.id is null
               and trm.merchant_id = acq.id
               and trm.id = ao.object_id(+)
               and ao.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
               and acq.inst_id = m.inst_id
               and acq.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
               and acq.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
               and trm.card_data_input_cap in ('F2210001','F2210005','F221000C','F221000D','F221000E','F221000M')
               and (select min(pso.start_date)
                      from prd_service_object pso
                     where pso.object_id = acq.id
                       and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   ) <= i_end_date

         union all

            select distinct
                   m.cmid cmid
                 , 'Number Outlets Contactless' information_name
                 , com_api_address_pkg.get_address_string(ao.address_id) address_name
                 , acq.id
                 , m.inst_id
                 , 1 nn
              from acq_merchant acq
                 , acq_merchant acq2
                 , cmid m
                 , acq_terminal trm
                 , com_address_object ao
             where acq2.parent_id(+) = acq.id
               and acq2.id is null
               and trm.merchant_id = acq.id
               and trm.id = ao.object_id(+)
               and ao.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
               and acq.inst_id = m.inst_id
               and acq.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
               and acq.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
               and trm.card_data_input_cap in ('F221000M')
               and (select min(pso.start_date)
                      from prd_service_object pso
                     where pso.object_id = acq.id
                       and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   ) <= i_end_date
        ) t
    group by
        t.cmid
        , t.information_name
        , t.inst_id;

    -- Merchant Category Groups
    cursor cu_data_group_2_2_ru (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.month_number
         , '234.Merchant Category Groups' group_name
         , t.ru_visa_mcg param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount(
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.card_inst_id
                    , t.oper_date
                    , 1
                    , null
                )
            ) / i_del_value
        ) value_2
    from (
        select m.cmid cmid
             , to_number(to_char(trunc(o.oper_date,'Q'), 'mm')) month_number
             , o.card_inst_id card_inst_id
             , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
             , o.currency oper_currency
             , sum(decode(o.is_reversal, 1, -1, 1) * decode(o.oper_type, 'OPTP0020', -1, 1) *  o.amount) oper_amount
             , o.oper_date
             , nvl(cm.ru_visa_mcg, 'Undefined MCG') as ru_visa_mcg
             , m.inst_id
          from qpr_aggr o
             , (select ct.id card_type_id
                  from net_card_type ct
                 where ct.network_id = i_network_id
               ) ct
             , cmid m
             , com_mcc cm
         where o.is_acq = 1
           and o.card_inst_id = m.inst_id
           and o.card_network_id = i_network_id
           and o.oper_date between i_start_date and i_end_date
           and o.card_type_id = ct.card_type_id
           and o.oper_type not in (opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                                 , opr_api_const_pkg.OPERATION_TYPE_CASHIN
                                 , opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT)
           and o.mcc = cm.mcc
           and com_api_array_pkg.conv_array_elem_v(
                   i_lov_id            => 49
                 , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                 , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                 , i_elem_value        => o.oper_type
               ) in ('Sales'/*, 'Refunds'*/)
         group by
              m.cmid
            , to_number(to_char(o.oper_date, 'mm'))
            , o.card_inst_id
            , o.currency
            , o.oper_date
            , nvl(cm.ru_visa_mcg, 'Undefined MCG')
            , m.inst_id
        ) t
    group by
        t.cmid
        , t.month_number
        , t.ru_visa_mcg
        , t.inst_id
    order by
        t.month_number
        , t.ru_visa_mcg;

    -- Co-Brands partners
    cursor cu_data_group_3 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_dest_curr             in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.card_type
         , t.month_number
         , rtrim(t.group_name) group_name
         , rtrim(t.param_name) param_name
         , t.inst_id
         , t.cards_count value_1
         , sum(t.nn_trans) value_2
         , sum(t.amount) value_3
         , t.bin
     from (
         select '213.Co-Brand' as group_name
              , o.cmid as cmid
              , i_quarter * 3 - 2 as month_number
              , 'Co-Brand partner name' as param_name
              , c.product_name as card_type
              , nvl(nn_trans, 0) as nn_trans
              , decode(
                        nvl(o.currency, i_dest_curr)
                      , i_dest_curr
                      , nvl(o.amount, 0)
                      , com_api_rate_pkg.convert_amount(
                            nvl(o.amount, 0)
                          , nvl(o.currency, i_dest_curr)
                          , i_dest_curr
                          , i_rate_type
                          , c.inst_id
                          , nvl(o.oper_date, i_start_date)
                          , 1
                          , null
                        )
                  ) / i_del_value
                as amount
              , c.cards_count
              , b.bin
              , c.inst_id
         from (select '213.Co-Brand' as group_name
                    , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 93
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CO_BRAND_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => o.card_product_id
                       )
                      as param_name
                    , m.cmid
                    , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
                    , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) amount
                    , o.currency
                    , o.oper_date
                    , card_inst_id
                    , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 130
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => o.card_type_id
                       )
                      as card_type_id
                 from qpr_aggr o
                    , (select ct.id as card_type_id
                         from net_card_type ct
                        where ct.network_id = i_network_id
                      ) ct
                    , cmid m
                where o.is_iss = 1
                  and o.card_inst_id = m.inst_id
                  and o.card_network_id = i_network_id
                  and o.status in (select element_value
                                     from com_array_element
                                    where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                  and o.oper_date between i_start_date and i_end_date
                  and o.card_type_id = ct.card_type_id
                  and nvl(com_api_array_pkg.conv_array_elem_v(
                                 i_lov_id            => 49
                               , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                               , i_array_id          => vis_api_const_pkg.QR_ISS_OPER_TYPE_ARRAY
                               , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                               , i_elem_value        => o.oper_type
                          ),'Refunds') != 'Refunds'
                  and com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 93
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CO_BRAND_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => o.card_product_id
                       ) is not null
                group by
                      m.cmid
                    , o.currency
                    , card_inst_id
                    , o.oper_date
                    , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 130
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => o.card_type_id
                       )
                    , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 93
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CO_BRAND_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => o.card_product_id
                       )
                    ) o
                    , (select count(c.id) as cards_count
                            , com_api_array_pkg.conv_array_elem_v(
                                      i_lov_id            => 130
                                    , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                                    , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                                    , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                    , i_elem_value        => c.card_type_id
                               )
                              as card_type_id
                            , c.inst_id
                            , m.cmid
                            , com_api_array_pkg.conv_array_elem_v(
                                 i_lov_id            => 93
                               , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                               , i_array_id          => vis_api_const_pkg.QR_CO_BRAND_ARRAY
                               , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                               , i_elem_value        => cn.product_id
                              )
                              as product_name
                         from iss_card c
                            , iss_card_instance ci
                            , prd_contract cn
                            , (select ct.id as card_type_id
                                 from net_card_type ct
                                where ct.network_id = i_network_id
                              ) ct
                            , cmid m
                        where c.inst_id = m.inst_id
                          and ci.card_id = c.id
                          and ci.expir_date > i_end_date
                          and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date
                          and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
                          and ct.card_type_id = c.card_type_id
                          and ci.is_last_seq_number = 1
                          and cn.id = c.contract_id
                          and com_api_array_pkg.conv_array_elem_v(
                                 i_lov_id            => 93
                               , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                               , i_array_id          => vis_api_const_pkg.QR_CO_BRAND_ARRAY
                               , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                               , i_elem_value        => cn.product_id
                              ) is not null
                     group by c.inst_id
                            , m.cmid
                            , com_api_array_pkg.conv_array_elem_v(
                                 i_lov_id            => 93
                               , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                               , i_array_id          => vis_api_const_pkg.QR_CO_BRAND_ARRAY
                               , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                               , i_elem_value        => cn.product_id
                              )
                            , com_api_array_pkg.conv_array_elem_v(
                                      i_lov_id            => 130
                                    , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                                    , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                                    , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                    , i_elem_value        => c.card_type_id
                               )
                      ) c
                    , iss_bin b
                where c.card_type_id = b.card_type_id
                  and c.inst_id = o.card_inst_id(+)
                  and c.product_name = o.param_name(+)
                  and c.card_type_id = o.card_type_id(+)
                  and c.cmid = o.cmid(+)
            ) t
        group by
              t.group_name
            , t.cmid
            , t.card_type
            , t.month_number
            , t.param_name
            , t.bin
            , t.inst_id
            , t.cards_count
        order by
              t.card_type
            , t.month_number
            , t.group_name
            , t.param_name
            , t.bin;

    -- Schedule F
    cursor cu_data_group_4 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_dest_curr             in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_inst_id               in com_api_type_pkg.t_inst_id
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
            p.name = vis_api_const_pkg.CMID
            and p.standard_id = i_standard_id
            and p.id = v.param_id
            and m.id = v.consumer_member_id
            and v.host_member_id = i_host_id
            and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select
        t.cmid
        , t.inst_id
        , i_quarter * 3 month_num
        , 'Schedule F' group_name
        , 'Organisation' param_name
        , sum(t.nn_trans) value_1
        , sum(decode(
                t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount(
                    t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                )
            ) / i_del_value
        ) value_2
        , sum(t.owner_id) value_3
    from (
        select
            m.cmid
            , o.acq_inst_id inst_id
            , count(distinct o.terminal_number) owner_id
            , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
            , o.currency oper_currency
            , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
            , o.oper_date
        from
            qpr_aggr o
            , cmid m
        where
            o.acq_inst_id = m.inst_id
            and o.status in (select element_value
                               from com_array_element
                              where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
            and o.oper_date between i_start_date and i_end_date
            and o.card_type_id in ( select
                    ct.id card_type_id
                from
                    net_card_type ct
                where
                    ct.network_id = i_network_id)
            and o.mcc not in (vis_api_const_pkg.MCC_CASH, vis_api_const_pkg.MCC_ATM)
            and o.oper_type not in ('OPTP0020','OPTP0022')
        group by
            m.cmid
            , o.acq_inst_id
            , o.currency
            , o.oper_date
        ) t
    group by
        t.cmid
        , t.inst_id;

    -- Monthly issuing
    cursor cu_data_group_5 (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.card_type
         , t.month_number
         , rtrim(t.group_name) group_name
         , rtrim(t.acq_param) param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(t.amount) value_2
     from (
         select group_name
              , cmid as cmid
              , get_text (
                     i_table_name    => 'net_card_type'
                   , i_column_name => 'name'
                   , i_object_id   => o.card_type_id
                  )
                as card_type
              , to_number(to_char(o.oper_date, 'mm')) month_number
              , nvl(
                    com_api_array_pkg.conv_array_elem_v(
                         i_lov_id            => 49
                       , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                       , i_array_id          => vis_api_const_pkg.QR_ISS_OPER_TYPE_ARRAY
                       , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                       , i_elem_value        => o.oper_type
                  )
                  , 'Unknown'
                )
                acq_param
              , inst_id
              , nn_trans  nn_trans
              , decode(
                        o.currency
                      , i_dest_curr
                      , o.amount
                      , com_api_rate_pkg.convert_amount(
                            o.amount
                          , o.currency
                          , i_dest_curr
                          , i_rate_type
                          , o.card_inst_id
                          , o.oper_date
                          , 1
                          , null
                        )
                  ) / i_del_value
                as amount
         from (select case
                          when o.is_acq = 1 then '215.On-Us'
                          when o.merchant_country = o.card_country then '216.National'
                          else '217.International'
                      end as group_name
                    , m.cmid
                    , o.oper_type
                    , ct.card_feature
                    , o.card_bin
                    , com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                           , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.card_type_id
                      ) as card_type_id
                    , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
                    , sum (decode(o.is_reversal, 1, -1, 1) * o.amount) amount
                    , o.currency
                    , o.oper_date
                    , card_inst_id
                    , m.inst_id
                 from qpr_aggr o
                    , (select cf.card_type_id
                            , cf.card_feature
                         from net_card_type ct
                            , net_card_type_feature cf
                        where ct.network_id = i_network_id
                          and ct.id = cf.card_type_id
                          and cf.card_feature in (vis_api_const_pkg.VISA_STANDART, vis_api_const_pkg.VISA_ELECTRON)
                      ) ct
                    , cmid m
                    , iss_bin b
                where o.is_iss = 1
                  and o.card_inst_id = m.inst_id
                  and o.card_network_id = i_network_id
                  and o.status in (select element_value
                                     from com_array_element
                                    where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                  and o.oper_date between i_start_date and i_end_date
                  and o.card_type_id = ct.card_type_id
                  and o.card_bin = b.bin
                group by
                      case
                          when o.is_acq = 1 then '215.On-Us'
                          when o.merchant_country = o.card_country then '216.National'
                          else '217.International'
                      end
                    , m.cmid
                    , o.oper_type
                    , ct.card_feature
                    , o.card_bin
                    , com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                           , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.card_type_id
                      )
                    , o.currency
                    , o.oper_date
                    , card_inst_id
                    , m.inst_id
               union
               select '218.Total Transactions' as group_name
                    , m.cmid
                    , o.oper_type
                    , ct.card_feature
                    , o.card_bin
                    , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 130
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => o.card_type_id
                       ) as card_type_id
                    , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
                    , sum (decode(o.is_reversal, 1, -1, 1) * o.amount) amount
                    , o.currency
                    , o.oper_date
                    , card_inst_id
                    , m.inst_id
                 from qpr_aggr o
                    , (select cf.card_type_id
                            , cf.card_feature
                         from net_card_type ct
                            , net_card_type_feature cf
                        where ct.network_id = i_network_id
                          and ct.id = cf.card_type_id
                          and cf.card_feature in (vis_api_const_pkg.VISA_STANDART, vis_api_const_pkg.VISA_ELECTRON)
                      ) ct
                    , cmid m
                    , iss_bin b
                where o.is_iss = 1
                  and o.card_inst_id = m.inst_id
                  and o.card_network_id = i_network_id
                  and o.status in (select element_value
                                     from com_array_element
                                    where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                  and o.oper_date between i_start_date and i_end_date
                  and o.card_type_id = ct.card_type_id
                  and o.card_bin = b.bin
                group by
                      m.cmid
                    , o.oper_type
                    , ct.card_feature
                    , o.card_bin
                    , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 130
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => o.card_type_id
                       )
                    , o.currency
                    , o.oper_date
                    , card_inst_id
                    , m.inst_id
                    ) o
            ) t
        where t.acq_param <> 'Unknown'
        group by
              t.group_name
            , t.cmid
            , t.card_type
            , t.month_number
            , t.acq_param
            , t.inst_id
        order by
              t.card_type
            , t.month_number
            , t.group_name
            , t.acq_param;

    -- Monthly issuing total
    cursor cu_data_group_5_total (
        i_start_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.month_num
         , '219.Number of Cards' group_name
         , 'Number of Cards' param_name
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => t.card_type_id
           )
           card_type
         , t.inst_id
         , count(distinct t.card_id) value_1
      from (select m.cmid cmid
                 , to_number(to_char(i_start_date, 'mm')) + (itr.val-1) month_num
                 , oc.id card_id
                 , com_api_array_pkg.conv_array_elem_v(
                          i_lov_id            => 130
                        , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                        , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                        , i_elem_value        => oc.card_type_id
                   ) as card_type_id
                 , (select min(decode(card_feature, net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT, 'debit', 'credit'))
                      from net_card_type_feature
                     where card_type_id = oc.card_type_id
                       and card_feature in (net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT,net_api_const_pkg.CARD_FEATURE_STATUS_CREDIT)
                   ) debit
                , m.inst_id
             from iss_card oc
                , iss_card_instance ci
                , net_card_type ct
                , (select level as val from dual connect by level<=3) itr
                , cmid m
            where oc.inst_id = m.inst_id
              and ci.card_id = oc.id
              and ci.expir_date > add_months(i_start_date, itr.val-1)
              and nvl(ci.iss_date, i_start_date) < add_months(i_start_date, itr.val)
              and ci.status in (iss_api_const_pkg.CARD_STATUS_VALID_CARD, iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED)
              and ct.network_id = i_network_id
              and ct.id = oc.card_type_id
            ) t
    group by
          t.cmid
        , t.month_num
        , t.card_type_id
        , t.debit
        , t.inst_id
    order by
          t.card_type_id
        , t.month_num;

    -- Card issuance - number of active cards
    cursor cu_data_group_6_1 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_end_date              in date
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , i_quarter * 3 - 2 month_num
         , '220.Card Issuance' group_name
         , 'Number of Active Cards' param_name
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => t.card_type_id
           )
           card_type
         , t.inst_id
         , count(distinct t.card_id) value_1
    from (select m.cmid cmid
               , q.card_id
               , com_api_array_pkg.conv_array_elem_v(
                          i_lov_id            => 130
                        , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                        , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                        , i_elem_value        => c.card_type_id
                 ) as card_type_id
               , m.inst_id
            from qpr_card_aggr q
               , iss_card c
               , (select id card_type_id
                    from net_card_type
                   where network_id = i_network_id
                 ) ct
               , cmid m
               , iss_card_instance ci
           where q.card_id = c.id
             and c.inst_id = m.inst_id
             and q.report_date = trunc(i_end_date,'Q')
             and c.card_type_id = ct.card_type_id
             and ci.card_id = c.id
             and ci.expir_date > i_end_date
             and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date
             and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
        ) t
    group by
        t.cmid
        , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => t.card_type_id
           )
        , t.inst_id;

    --  Card issuance - number of cards of which are CHIP
    cursor cu_data_group_6_1_1 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , i_quarter * 3 - 2 month_num
         , '220.Card Issuance' group_name
         , 'of which are CHIP' param_name
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => t.card_type_id
           )
           card_type
        , t.inst_id
        , count(distinct t.card_id) value_1
    from (select m.cmid cmid
               , q.card_id
               , com_api_array_pkg.conv_array_elem_v(
                          i_lov_id            => 130
                        , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                        , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                        , i_elem_value        => c.card_type_id
                 ) as card_type_id
               , m.inst_id
            from qpr_card_aggr q
               , iss_card c
               , (select id as card_type_id
                    from net_card_type ct
                   where ct.network_id = i_network_id
                 ) ct
               , cmid m
               , iss_card_instance ci
           where q.card_id = c.id
             and c.inst_id = m.inst_id
             and q.report_date = trunc(i_end_date,'Q')
             and c.card_type_id = ct.card_type_id
             and ci.card_id = c.id
             and ci.expir_date > i_end_date
             and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date
             and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
             and exists (select 1
                           from iss_card_instance ci
                              , prs_method pm
                          where ci.card_id = q.card_id
                            and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
                            and ci.perso_method_id = pm.id
                            and substr(pm.service_code,1,1) = '2'
                        )
        ) t
    group by
          t.cmid
        , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => t.card_type_id
           )
        , t.inst_id;

    -- Card issuance - number of which are Contactless
    cursor cu_data_group_6_1_2 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , i_quarter * 3 - 2 month_num
         , '220.Card Issuance' group_name
         , 'of which are Contactless' param_name
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => t.card_type_id
           )
           card_type
         , t.inst_id
         , count(distinct t.card_id) value_1
    from (select m.cmid cmid
               , q.card_id
               , com_api_array_pkg.conv_array_elem_v(
                          i_lov_id            => 130
                        , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                        , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                        , i_elem_value        => c.card_type_id
                 ) as card_type_id
               , m.inst_id
            from qpr_card_aggr q
               , iss_card c
               , (select cf.card_type_id
                       , cf.card_feature
                    from net_card_type ct
                       , net_card_type_feature cf
                   where ct.network_id = i_network_id
                     and ct.id = cf.card_type_id
                     and cf.card_feature in (vis_api_const_pkg.VISA_CONTACTLESS)
                 ) ct
               , cmid m
               , iss_card_instance ci
           where q.card_id = c.id
             and c.inst_id = m.inst_id
             and q.report_date = trunc(i_end_date,'Q')
             and c.card_type_id = ct.card_type_id
             and ci.card_id = c.id
             and ci.expir_date > i_end_date
             and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date
             and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
        ) t
    group by
          t.cmid
        , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => t.card_type_id
           )
        , t.inst_id;

    --  Card issuance - number of accounts
    cursor cu_data_group_6_2 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_end_date              in date
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select m.cmid
         , i_quarter * 3 - 2 month_num
         , '220.Card Issuance' group_name
         , 'Number of Accounts' param_name
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => ct.main_card_type_id
           )
           card_type
         , m.inst_id
         , count(distinct ao.account_id) value_1
      from iss_card oc
         , iss_card_instance ci
         , iss_bin ib
         , acc_account_object ao
         , (select ct.id card_type_id
                 , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 130
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => ct.id
                   ) as main_card_type_id
              from net_card_type ct
             where ct.network_id = i_network_id
           ) ct
         , cmid m
     where oc.inst_id = m.inst_id
       and ci.card_id = oc.id
       and oc.card_type_id = ct.card_type_id
       and ci.start_date <= i_end_date
       and ci.expir_date >= i_end_date
       and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
       and ib.id = ci.bin_id
       and ao.object_id = oc.id
       and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
     group by
           m.cmid
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => ct.main_card_type_id
           )
         , m.inst_id;

    --  Card issuance - number of active accounts
    cursor cu_data_group_6_3 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_start_date            in date
        , i_end_date              in date
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select m.cmid
         , i_quarter * 3 - 2 month_num
         , '220.Card Issuance' group_name
         , 'Number of Active Accounts' param_name
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => ct.main_card_type_id
           )
           card_type
         , m.inst_id
         , count(distinct ao.account_id) value_1
      from iss_card oc
         , iss_card_instance ci
         , iss_bin ib
         , acc_account_object ao
         , (select ct.id card_type_id
                 , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 130
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => ct.id
                   ) as main_card_type_id
              from net_card_type ct
             where ct.network_id = i_network_id
           ) ct
         , cmid m
     where oc.inst_id = m.inst_id
       and ci.card_id = oc.id
       and oc.card_type_id = ct.card_type_id
       and ci.start_date <= i_end_date
       and ci.expir_date >= i_end_date
       and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
       and ib.id = ci.bin_id
       and ao.object_id = oc.id
       and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
       and exists (select 1
                     from acc_entry e
                    where e.account_id = ao.account_id
                      and e.sttl_date between i_start_date and i_end_date
                  )
     group by
           m.cmid
         , get_text (
               i_table_name     => 'net_card_type'
               , i_column_name  => 'name'
               , i_object_id    => ct.main_card_type_id
           )
         , m.inst_id;

    --  Schedule A,E
    cursor cu_data_group_7 (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
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
            p.name = vis_api_const_pkg.CMID
            and p.standard_id = i_standard_id
            and p.id = v.param_id
            and m.id = v.consumer_member_id
            and v.host_member_id = i_host_id
            and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select
        t.cmid cmid
        , t.inst_id inst_id
        , 'Schedule A,E' group_name
        , 'Schedule' param_name
        , to_number(to_char(i_end_date,'mm')) month_num
        , get_text (
              i_table_name    => 'net_card_type'
              , i_column_name => 'name'
              , i_object_id   => t.card_type_id
        ) as name
        , t.bin
        , sum(t.nn_trans) value_1
        , sum(t.amount) value_2
        , ( select
                count(1)
            from
                iss_card oc
                , iss_card_instance ci
            where
                oc.card_type_id = t.card_type_id
                and ci.card_id = oc.id
                and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
        ) value_3
    from (
        select
            m.cmid cmid
            , o.card_inst_id inst_id
            , o.card_type_id
            , o.card_bin bin
            , decode(o.is_reversal, 1, -1, 1) * o.cnt  nn_trans
            , decode(o.is_reversal, 1, -1, 1)
              * decode(
                    o.currency
                    , i_dest_curr
                    , o.amount
                    , com_api_rate_pkg.convert_amount(
                        o.amount
                        , o.currency
                        , i_dest_curr
                        , i_rate_type
                        , o.card_inst_id
                        , o.oper_date
                        , 1
                        , null
                    )
             ) / i_del_value amount
        from

            qpr_aggr o
            , ( select
                    cf.card_type_id
                from
                    net_card_type ct
                    , net_card_type_feature cf
                where
                    ct.network_id = i_network_id
                    and ct.id = cf.card_type_id
                    and cf.card_feature in (vis_api_const_pkg.VISA_STANDART, vis_api_const_pkg.VISA_ELECTRON)
            ) ct
            , cmid m
        where
            o.oper_date between i_start_date and i_end_date
            and o.status in (select element_value
                               from com_array_element
                              where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
            and o.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
            and o.card_inst_id = m.inst_id
            and o.card_network_id = i_network_id
            and o.card_type_id = ct.card_type_id
            and o.oper_type not in ('OPTP0020')
        ) t
    group by
        t.cmid
        , t.inst_id
        , t.card_type_id
        , t.bin;

    --  V PAY Acquiring
    cursor cu_data_group_8 (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.month_number
         , group_name group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
      from (
            select m.cmid
                 , to_number(to_char(o.oper_date, 'mm')) month_number
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                   as param_name
                 , '232.V PAY Acquiring Data'
                   as group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                           , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.card_type_id
                      ) = vis_api_const_pkg.QR_V_PAY_CARD_TYPE
               and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   ) is not null
          group by m.cmid
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                 , to_number(to_char(o.oper_date, 'mm'))
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
           ) t
  group by t.cmid
         , t.month_number
         , t.param_name
         , t.group_name
         , t.inst_id
  order by t.cmid
         , t.month_number
         , t.param_name;

    --  V PAY Acquired Electronic Commerce Transaction Data
    cursor cu_data_group_8_1 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_dest_curr             in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.month_number
         , group_name group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
      from (
            select m.cmid
                 , i_quarter * 3 - 2 as month_number
                 , case when o.merchant_country = o.card_country then 'Domestic Acquired E-Commerce Transactions'
                        else 'Intra-Regional Domestic Acquired E-Commerce Transactions'
                    end
                   as param_name
                 , '224.V PAY Acquired Electronic Commerce Transaction'
                   as group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                           , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.card_type_id
                      ) = vis_api_const_pkg.QR_V_PAY_CARD_TYPE
               and o.card_data_input_mode in ('F2270005', 'F2270007', 'F2270009', 'F227000R', 'F227000S')
          group by m.cmid
                 , case when o.merchant_country = o.card_country then 'Domestic Acquired E-Commerce Transactions'
                        else 'Intra-Regional Domestic Acquired E-Commerce Transactions'
                    end
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
           ) t
  group by t.cmid
         , t.month_number
         , t.param_name
         , t.group_name
         , t.inst_id
  order by t.cmid
         , t.month_number
         , t.param_name;

    --  V PAY Member And Merchant Data
    cursor cu_data_group_8_2 (
        i_start_date              in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid cmid
         , '225.V PAY Member And Merchant Data' group_name
         , t.param_name
         , t.inst_id
         , sum(t.n1) value_1
         , sum(t.n2) value_2
      from (
          -- No of ATMs acceptting V PAY Cards
          select cmid.cmid
                 , 'Number V PAY ATMs' param_name
                 , to_char(null) as address_name
                 , trm.id
                 , cmid.inst_id
                 , 1 n1
                 , 0 n2
           from acq_terminal trm
              , acq_merchant acq
              , cmid
          where trm.merchant_id    = acq.id
            and trm.is_template    = 0
            and trm.inst_id        = acq.inst_id
            and acq.inst_id        = cmid.inst_id
            and acq.mcc            in (vis_api_const_pkg.MCC_CASH, vis_api_const_pkg.MCC_ATM)
            and nvl(trm.mcc, acq.mcc) = vis_api_const_pkg.MCC_ATM
            and trm.status         = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
            and (select min(pso.start_date)
                   from prd_service_object pso
                  where pso.object_id = acq.id
                    and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                ) <= i_end_date
         union all

          -- No of outlets
          select distinct
                 cmid.cmid as cmid
               , 'V PAY Merchants' param_name
               , com_api_address_pkg.get_address_string(o.address_id) address_name
               , acq.id
               , cmid.inst_id
               , 1 as n1
               , 0 as n2
           from acq_terminal trm
              , acq_merchant acq
              , cmid
              , com_address_object o
          where trm.merchant_id = acq.id
            and trm.is_template = 0
            and trm.inst_id     = acq.inst_id
            and acq.inst_id     = cmid.inst_id
            and acq.mcc         not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
            and o.entity_type   = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
            and o.object_id     = trm.id
            and trm.status      = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
            and (select min(pso.start_date)
                   from prd_service_object pso
                  where pso.object_id = acq.id
                    and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                ) <= i_end_date

         union all

          -- No of POS Terminals
          select cmid.cmid as cmid
                 , 'V PAY Merchants' as param_name
                 , to_char(null) as address_name
                 , acq.id
                 , cmid.inst_id
                 , 0 as n1
                 , 1 as n2
           from acq_terminal trm
              , acq_merchant acq
              , cmid
          where trm.merchant_id = acq.id
            and trm.is_template = 0
            and trm.inst_id     = acq.inst_id
            and acq.inst_id     = cmid.inst_id
            and acq.mcc         not in (vis_api_const_pkg.MCC_CASH, vis_api_const_pkg.MCC_ATM)
            and trm.status      = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
            and (select min(pso.start_date)
                   from prd_service_object pso
                  where pso.object_id = acq.id
                    and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                 ) <= i_end_date
        ) t
    group by
        t.cmid
        , t.param_name
        , t.inst_id;

    --  Contactless acquiring
    cursor cu_data_group_9 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , i_quarter * 3 - 2 month_num
         , group_name group_name
         , t.param_name
         , t.inst_id
         , sum(t.cnt) value_1
      from (
            select distinct
                   m.cmid
                 , 'Number of active Merchant'
                   as param_name
                 , '226.Contactless'
                   as group_name
                 , m.inst_id
                 , com_api_address_pkg.get_address_string(ao.address_id) address_name
                 , acq.id
                 , 1 as cnt
              from acq_merchant acq
                 , acq_merchant acq2
                 , cmid m
                 , acq_terminal trm
                 , com_address_object ao
             where acq2.parent_id(+) = acq.id
               and acq2.id is null
               and trm.merchant_id = acq.id
               and trm.id = ao.object_id(+)
               and ao.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
               and acq.inst_id = m.inst_id
               and acq.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
               and acq.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
               and exists (select 1 from qpr_aggr o, cmid m
                            where o.is_acq = 1
                              and o.card_inst_id = m.inst_id
                              and o.terminal_number = trm.terminal_number
                              and o.card_network_id = i_network_id
                              and o.status in (select element_value
                                                 from com_array_element
                                                where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                              and o.oper_date between i_start_date and i_end_date
                              and o.card_data_input_mode in ('F227000P','F227000N','F227000M'))
           ) t
  group by t.cmid
         , t.param_name
         , t.group_name
         , t.inst_id
  order by t.cmid
         , t.param_name;

    --  Contactless transactions acquiring
    cursor cu_data_group_9_1 (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.month_number
         , group_name group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
         , t.account_funding_source as value_3
      from (
            select m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                   as month_number
                 , nvl(com_api_array_pkg.conv_array_elem_v(
                           i_lov_id            => 10
                         , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                         , i_array_id          => vis_api_const_pkg.QR_CONTACTLESS_ARRAY
                         , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                         , i_elem_value        => o.mcc
                       ), 'Other')
                   as  param_name
                 , '226.Contactless' as group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
                 , case
                       when o.account_funding_source = 'DEBIT'
                       then 0
                       when o.account_funding_source in ('CREDIT')
                       then 1
                       else 0
                    end as account_funding_source
              from qpr_aggr o
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and o.card_data_input_mode in ('F227000P','F227000N','F227000M')
          group by m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
                 , o.account_funding_source
                 , nvl(com_api_array_pkg.conv_array_elem_v(
                           i_lov_id            => 10
                         , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                         , i_array_id          => vis_api_const_pkg.QR_CONTACTLESS_ARRAY
                         , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                         , i_elem_value        => o.mcc
                       ), 'Other')
           ) t
  group by t.cmid
         , t.month_number
         , t.param_name
         , t.group_name
         , t.inst_id
         , t.account_funding_source
  order by t.cmid
         , t.month_number
         , t.param_name;

    --  Acquired Electronic Commerce Transactions
    cursor cu_data_group_10 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_dest_curr             in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , i_quarter * 3 - 2 month_num
         , group_name group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
      from (
            select m.cmid
                 , case when o.merchant_country = o.card_country
                        then 'Domestic Sales Acquired E-Commerce'
                        when nvl(ci.visa_region,'X') = nvl(ca.visa_region,'Y')
                        then 'Intra-Regional Sales Acquired E-Commerce'
                        else 'Inter-Regional Sales Acquired E-Commerce'
                   end
                   as param_name
                 , '227.Acquired Electronic Commerce Transactions'
                   as group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , cmid m
                 , com_country ca
                 , com_country ci
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.card_country = ci.code(+)
               and o.merchant_country = ca.code(+)
               and o.oper_date between i_start_date and i_end_date
               and com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                           , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.card_type_id
                      ) != vis_api_const_pkg.QR_V_PAY_CARD_TYPE
               and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   ) = 'Sales'
               and o.card_data_input_mode in ('F2270005', 'F2270007', 'F2270009', 'F227000R', 'F227000S')
          group by m.cmid
                 , case when o.merchant_country = o.card_country
                        then 'Domestic Sales Acquired E-Commerce'
                        when nvl(ci.visa_region,'X') = nvl(ca.visa_region,'Y')
                        then 'Intra-Regional Sales Acquired E-Commerce'
                        else 'Inter-Regional Sales Acquired E-Commerce'
                   end
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
           ) t
  group by t.cmid
         , t.param_name
         , t.group_name
         , t.inst_id
  order by t.cmid
         , t.param_name;

    --  Acquired Electronic Commerce Merchant Data
    cursor cu_data_group_10_1 (
        i_start_date              in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid cmid
         , '227.Acquired Electronic Commerce Transactions' group_name
         , t.param_name
         , t.inst_id
         , sum(t.n1) value_1
      from (select m.cmid cmid
                 , 'Merchants acquiring E-commerce' param_name
                 , acq.id
                 , m.inst_id
                 , 1 n1
              from acq_merchant acq
                 , cmid m
             where acq.inst_id = m.inst_id
               and (select min(pso.start_date)
                      from prd_service_object pso
                     where pso.object_id = acq.id
                       and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   ) <= i_end_date
               and exists (select 1 from acq_terminal trm
                            where trm.merchant_id = acq.id
                              and trm.card_data_input_mode in ('F2270005', 'F2270007', 'F2270009', 'F227000R', 'F227000S'))
        ) t
    group by
        t.cmid
        , t.param_name
        , t.inst_id;

    --  Acquired International ATM Transactions
    cursor cu_data_group_12 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_dest_curr             in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , i_quarter * 3 - 2 month_num
         , group_name group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
      from (
            select m.cmid
                 , case when nvl(ci.visa_region,'X') = nvl(ca.visa_region,'Y')
                        then 'Total Intra-Regional ATM Transactions'
                        else 'Total Inter-Regional ATM Transactions'
                   end
                   as param_name
                 , '228.Acquired International ATM Transactions'
                   as group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , cmid m
                 , com_country ca
                 , com_country ci
                 , acq_terminal trm
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.card_country = ci.code(+)
               and o.merchant_country = ca.code(+)
               and o.merchant_country != o.card_country
               and o.oper_date between i_start_date and i_end_date
               and o.terminal_number = trm.terminal_number
               and trm.inst_id = m.inst_id
               and trm.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
               and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   ) is not null
               and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.card_type_id
                   ) != vis_api_const_pkg.QR_V_PAY_CARD_TYPE
          group by m.cmid
                 , case when nvl(ci.visa_region,'X') = nvl(ca.visa_region,'Y')
                        then 'Total Intra-Regional ATM Transactions'
                        else 'Total Inter-Regional ATM Transactions'
                   end
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
           ) t
  group by t.cmid
         , t.param_name
         , t.group_name
         , t.inst_id
  order by t.cmid
         , t.param_name;

    --  Acquiring
    cursor cu_data_group_13 (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.month_number
         , group_name group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
         , t.account_funding_source as value_3
         , t.regional value_4
      from (
            select m.cmid
                 , to_number(to_char(o.oper_date, 'mm')) month_number
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                   as param_name
                 , '229.Acquirer Data'
                   as group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
                 , case
                       when o.account_funding_source = 'DEBIT'
                       then 0
                       when o.account_funding_source in ('CREDIT', 'DEFFERED DEBIT')
                       then 1
                       else 0
                    end as account_funding_source
                 , case when o.merchant_country = o.card_country
                        then 'On Us'
                        when nvl(ci.visa_region,'X') = nvl(ca.visa_region,'Y')
                        then 'Intra'
                        else 'Inter'
                   end as regional
              from qpr_aggr o
                 , cmid m
                 , com_country ca
                 , com_country ci
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                           , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.card_type_id
                      ) != vis_api_const_pkg.QR_V_PAY_CARD_TYPE
               and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   ) is not null
               and o.card_country = ci.code(+)
               and o.merchant_country = ca.code(+)
          group by m.cmid
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                 , to_number(to_char(o.oper_date, 'mm'))
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
                 , o.account_funding_source
                 , case when o.merchant_country = o.card_country
                        then 'On Us'
                        when nvl(ci.visa_region,'X') = nvl(ca.visa_region,'Y')
                        then 'Intra'
                        else 'Inter'
                   end
           ) t
     where t.account_funding_source is not null
  group by t.cmid
         , t.month_number
         , t.param_name
         , t.group_name
         , t.inst_id
         , t.account_funding_source
         , t.regional
  order by t.cmid
         , t.month_number
         , t.param_name;

    --  Acquired MOTO (Mail and Telephone Order)
    cursor cu_data_group_14 (
        i_start_date              in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid cmid
         , '230.MOTO (Mail and Telephone Order)' group_name
         , t.information_name param_name
         , t.inst_id
         , sum(t.n1) value_1
      from (select cmid.cmid
                 , 'Number of Merchants acquiring MOTO transactions' information_name
                 , acq.id
                 , cmid.inst_id
                 , 1 n1
              from acq_merchant acq
                 , cmid
             where acq.inst_id    = cmid.inst_id
               and acq.parent_id  is null
               and acq.mcc        not in (vis_api_const_pkg.MCC_CASH, vis_api_const_pkg.MCC_ATM)
               and (select min(pso.start_date)
                      from prd_service_object pso
                     where pso.object_id = acq.id
                       and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   ) <= i_end_date
               and exists (select 1 from acq_terminal trm
                            where trm.merchant_id = acq.id
                              and trm.crdh_data_present in ('F2250001', 'F2250002', 'F2250003', 'F2250005'))
        ) t
    group by
        t.cmid
        , t.information_name
        , t.inst_id;

    --  Acquired MOTO (Mail and Telephone Order) Transaction
    cursor cu_data_group_14_1 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_dest_curr             in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , i_quarter * 3 - 2 month_num
         , group_name group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
      from (
            select m.cmid
                 , 'Total Gross Sales acquired MOTO transactions'
                   as param_name
                 , '230.MOTO (Mail and Telephone Order)'
                   as group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and o.crdh_presence in ('F2250001', 'F2250002', 'F2250003', 'F2250005')
               and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   ) = 'Sales'
          group by m.cmid
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
           ) t
     group by t.cmid
            , t.param_name
            , t.group_name
            , t.inst_id
     order by t.cmid
            , t.param_name;

    --  Acquired Recurring Transaction
    cursor cu_data_group_15 (
        i_quarter                 in com_api_type_pkg.t_tiny_id
        , i_dest_curr             in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , i_quarter * 3 - 2 month_num
         , group_name group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
      from (
            select m.cmid
                 , 'Acquired Recurring Transactions'
                   as param_name
                 , '231.Acquired Recurring Transaction'
                   as group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and o.crdh_presence in ('F2250004')
               and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   ) is not null
          group by m.cmid
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
           ) t
     group by t.cmid
            , t.param_name
            , t.group_name
            , t.inst_id
     order by t.cmid
            , t.param_name;

    cursor cu_data_group_16 (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select
               distinct
               m.inst_id inst_id
             , v.param_value     cmid
          from cmn_parameter                  p
             , net_api_interface_param_val_vw v
             , net_member                     m
         where p.name           = vis_api_const_pkg.CMID
           and p.standard_id    = i_standard_id
           and p.id             = v.param_id
           and m.id             = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.month_number
         , group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                   t.oper_currency
                 , i_dest_curr
                 , t.oper_amount
                 , com_api_rate_pkg.convert_amount(
                       t.oper_amount
                     , t.oper_currency
                     , i_dest_curr
                     , i_rate_type
                     , t.inst_id
                     , t.oper_date
                     , 1
                     , null
                   )
               ) / i_del_value
           ) value_2
      from(
            select m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))           month_number
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id           => 49
                     , i_array_type_id    => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id         => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id          => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value       => o.oper_type
                   )                                               param_name
                 , case when o.is_iss = 1 then '236.On-Us'
                        when o.merchant_country = o.card_country then '237.National'
                        else '238.International'
                   end                                             group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt )   nn_trans
                 , o.currency                                      oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr    o
                 , cmid        m
             where o.is_acq = 1
               and o.trans_code_qualifier in (vis_api_const_pkg.TCQ_AFT, vis_api_const_pkg.TCQ_OCT)
               and o.card_inst_id = m.inst_id
               and o.card_network_id in (select element_value from com_array_element where array_id = vis_api_const_pkg.QR_CARD_NETWORK_ARRAY)
               and o.card_type_id    in (select element_value from com_array_element where array_id = vis_api_const_pkg.QR_CARD_TYPE_ARRAY)
               and o.status          in (select element_value from com_array_element where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
          group by m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id           => 49
                     , i_array_type_id    => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id         => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id          => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value       => o.oper_type
                   )
                 , case when o.is_iss = 1 then '236.On-Us'
                        when o.merchant_country = o.card_country then '237.National'
                        else '238.International'
                   end
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
         union all
            select m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))           month_number
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id           => 49
                     , i_array_type_id    => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id         => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id          => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value       => o.oper_type
                   )                                               param_name
                 , '239.Total Transactions'                        group_name
                 , o.card_inst_id                                  inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt )   nn_trans
                 , o.currency                                      oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr    o
                 , cmid        m
             where o.is_acq = 1
               and o.trans_code_qualifier in (vis_api_const_pkg.TCQ_AFT, vis_api_const_pkg.TCQ_OCT)
               and o.card_inst_id = m.inst_id
               and o.card_network_id in (select element_value from com_array_element where array_id = vis_api_const_pkg.QR_CARD_NETWORK_ARRAY)
               and o.card_type_id    in (select element_value from com_array_element where array_id = vis_api_const_pkg.QR_CARD_TYPE_ARRAY)
               and o.status          in (select element_value from com_array_element where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
          group by m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id           => 49
                     , i_array_type_id    => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id         => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id          => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value       => o.oper_type
                   )
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
           ) t
    group by t.cmid
           , t.month_number
           , t.param_name
           , t.group_name
           , t.inst_id
    order by t.cmid
           , t.month_number
           , t.param_name;

    -- CEMEA
    -- Monthly issuing
    cursor cu_data_group_17_3_1(
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    ),
    iss as (
    select t.cmid
         , t.card_type
         , t.month_number
         , rtrim(t.group_name) group_name
         , rtrim(t.acq_param) param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , decode(rtrim(t.acq_param) , 'Refunds', -1, 1) * sum(t.amount) value_2
         , t.account_funding_source as value_3
     from (
         select group_name
              , cmid as cmid
              , get_text (
                     i_table_name    => 'net_card_type'
                   , i_column_name => 'name'
                   , i_object_id   => o.card_type_id
                  )
                as card_type
              , to_number(to_char(o.oper_date, 'mm')) month_number
              , nvl(
                    com_api_array_pkg.conv_array_elem_v(
                         i_lov_id            => 49
                       , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                       , i_array_id          => vis_api_const_pkg.QR_CEMEA_ISS_OPER_TYPE_ARRAY
                       , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                       , i_elem_value        => o.oper_type
                  )
                  , 'Unknown'
                )
                acq_param
              , inst_id
              , nn_trans  nn_trans
              , decode(
                        o.currency
                      , i_dest_curr
                      , o.amount
                      , com_api_rate_pkg.convert_amount(
                            o.amount
                          , o.currency
                          , i_dest_curr
                          , i_rate_type
                          , o.card_inst_id
                          , o.oper_date
                          , 1
                          , null
                        )
                  ) / i_del_value
                as amount
              , o.account_funding_source
         from (select case
                          when o.is_acq = 1 then '249.On-Us'
                          when o.merchant_country = o.card_country then '250.National'
                          else '251.International'
                      end as group_name
                    , m.cmid
                    , o.oper_type
                    , ct.card_feature
                    , o.card_bin
                    , com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                           , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.card_type_id
                      ) as card_type_id
                    , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
                    , sum (decode(o.is_reversal, 1, -1, 1) * o.amount) amount
                    , o.currency
                    , o.oper_date
                    , card_inst_id
                    , m.inst_id
                    , case
                          when o.account_funding_source = 'DEBIT' then 0
                          when o.account_funding_source = 'CREDIT' then 1
                          when o.account_funding_source = 'PREPAID' then 2
                          else 0
                      end as account_funding_source
                 from qpr_aggr o
                    , (select cf.card_type_id
                            , cf.card_feature
                         from net_card_type ct
                            , net_card_type_feature cf
                        where ct.network_id = i_network_id
                          and ct.id = cf.card_type_id
                          and cf.card_feature in (vis_api_const_pkg.VISA_STANDART, vis_api_const_pkg.VISA_ELECTRON)
                      ) ct
                    , cmid m
                    , iss_bin b
                where o.is_iss = 1
                  and o.card_inst_id = m.inst_id
                  and o.card_network_id = i_network_id
                  and o.status in (select element_value
                                     from com_array_element
                                    where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                  and o.oper_date between i_start_date and i_end_date
                  and o.card_type_id = ct.card_type_id
                  and o.card_bin = b.bin
                group by
                      case
                          when o.is_acq = 1 then '249.On-Us'
                          when o.merchant_country = o.card_country then '250.National'
                          else '251.International'
                      end
                    , m.cmid
                    , o.oper_type
                    , ct.card_feature
                    , o.card_bin
                    , com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                           , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.card_type_id
                      )
                    , o.currency
                    , o.oper_date
                    , card_inst_id
                    , m.inst_id
                    , o.account_funding_source
                    ) o
            ) t
        where t.acq_param <> 'Unknown'
        group by
              t.group_name
            , t.cmid
            , t.card_type
            , t.month_number
            , t.acq_param
            , t.inst_id
            , t.account_funding_source
        order by
              t.card_type
            , t.month_number
            , t.group_name
            , t.acq_param
    )
    select a.cmid
         , a.month_number
         , a.group_name
         , substr(a.group_name, 5, 17)||' '||param_name||' Count - Month '||replace(mod(a.month_number, 3), 0, 3) as param_name
         , a.card_type
         , a.inst_id
         , a.value_1
         , a.value_3
      from iss a
     union all
    select a.cmid
         , a.month_number
         , a.group_name
         , substr(a.group_name, 5, 17)||' '||param_name||' Volume - Month '||replace(mod(a.month_number, 3), 0, 3) as param_name
         , a.card_type
         , a.inst_id
         , a.value_2
         , a.value_3
      from iss a;

    -- Issuing (cards, accounts)
    cursor cu_data_group_17_3_2(
        i_quarter               in com_api_type_pkg.t_tiny_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with
    cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    ),
    cards as (
        select t.cmid
             , i_quarter * 3 - 2        as month_num
             , '252.Cards and Accounts' as group_name
             , get_text (
                   i_table_name     => 'net_card_type'
                   , i_column_name  => 'name'
                   , i_object_id    => t.card_type_id
               )
               card_type
             , t.inst_id
             , count(1) as cnt_all
             , sum(case when t.is_chip = 0 and t.is_contactless = 0 then 1 else 0 end) as cnt_magn
             , sum(case when t.is_chip > 0 and t.is_contactless = 0 then 1 else 0 end) as cnt_chip
             , sum(case when t.is_chip = 0 and t.is_contactless > 0 then 1 else 0 end) as cnt_cless
             , sum(case when t.is_chip > 0 and t.is_contactless > 0 then 1 else 0 end) as cnt_chip_cless
          from (select m.cmid cmid
                     , oc.id card_id
                     , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 130
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => oc.card_type_id
                       ) as card_type_id
                     , m.inst_id
                     , (select count(1)
                          from prs_method pm
                         where pm.id = ci.perso_method_id
                           and substr(pm.service_code,1,1) = '2') as is_chip
                     , (select count(1)
                          from net_card_type_feature cf
                         where ct.network_id = 1003
                           and cf.card_feature in ('CFCHCNTL')
                           and cf.card_type_id = oc.card_type_id) as is_contactless
                 from iss_card oc
                    , iss_card_instance ci
                    , net_card_type ct
                    , cmid m
                where oc.inst_id = m.inst_id
                  and ci.card_id = oc.id
                  and ci.seq_number = (select max(i.seq_number)
                                         from iss_card_instance i
                                        where i.card_id = ci.card_id)
                  and ci.expir_date > i_end_date
                  and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date
                  and ci.status in (iss_api_const_pkg.CARD_STATUS_VALID_CARD, iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED)
                  and ct.network_id = i_network_id
                  and ct.id = oc.card_type_id
                  and exists (select 1 from net_card_type_feature f
                               where f.card_type_id = oc.card_type_id
                                 and f.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT)
                ) t
        group by t.cmid
               , get_text (
                     i_table_name     => 'net_card_type'
                     , i_column_name  => 'name'
                     , i_object_id    => t.card_type_id
                 )
               , t.inst_id
    ),
    active_cards as (
        select t.cmid
             , i_quarter * 3 - 2        as month_num
             , '252.Cards and Accounts' as group_name
             , get_text (
                   i_table_name     => 'net_card_type'
                   , i_column_name  => 'name'
                   , i_object_id    => t.card_type_id
               )
               card_type
             , t.inst_id
             , count(1) as cnt_all
          from (select m.cmid cmid
                     , q.card_id
                     , com_api_array_pkg.conv_array_elem_v(
                                i_lov_id            => 130
                              , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                              , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                              , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                              , i_elem_value        => c.card_type_id
                       ) as card_type_id
                     , m.inst_id
                  from qpr_card_aggr q
                     , iss_card c
                     , (select id card_type_id
                          from net_card_type
                         where network_id = i_network_id
                       ) ct
                     , cmid m
                     , iss_card_instance ci
                 where q.card_id = c.id
                   and c.inst_id = m.inst_id
                   and q.report_date = trunc(i_end_date,'Q')
                   and c.card_type_id = ct.card_type_id
                   and ci.card_id = c.id
                   and ci.seq_number = (select max(i.seq_number)
                                         from iss_card_instance i
                                        where i.card_id = ci.card_id)
                   and ci.expir_date > i_end_date
                   and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date
                   and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
                   and exists (select 1 from net_card_type_feature f
                                where f.card_type_id = q.card_type_id
                                  and f.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT)
                ) t
        group by t.cmid
               , get_text (
                     i_table_name     => 'net_card_type'
                     , i_column_name  => 'name'
                     , i_object_id    => t.card_type_id
                 )
               , t.inst_id
    ),
    accounts as (
        select t.cmid
             , i_quarter * 3 - 2            as month_num
             , '252.Cards and Accounts'     as group_name
             , t.card_type
             , t.inst_id
             , count(t.account_id) as cnt_all
             , sum(case when nvl((select 1
                        from acc_entry e
                       where e.account_id = t.account_id
                         and e.sttl_date between i_start_date and i_end_date
                         and rownum = 1), 0) = 1 then 1 else 0 end) as cnt_actives
          from (select distinct
                       m.cmid
                     , get_text (
                           i_table_name     => 'net_card_type'
                           , i_column_name  => 'name'
                           , i_object_id    => ct.main_card_type_id
                       ) as card_type
                     , m.inst_id
                     , ao.account_id
                  from iss_card oc
                     , iss_card_instance ci
                     , iss_bin ib
                     , acc_account_object ao
                     , (select ct.id card_type_id
                             , com_api_array_pkg.conv_array_elem_v(
                                          i_lov_id            => 130
                                        , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                                        , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                        , i_elem_value        => ct.id
                               ) as main_card_type_id
                          from net_card_type ct
                         where ct.network_id = i_network_id
                       ) ct
                     , cmid m
                 where oc.inst_id = m.inst_id
                   and ci.card_id = oc.id
                   and ci.seq_number = (select max(i.seq_number)
                                         from iss_card_instance i
                                        where i.card_id = ci.card_id)
                   and oc.card_type_id = ct.card_type_id
                   and ci.start_date <= i_end_date
                   and ci.expir_date >= i_end_date
                   and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
                   and ib.id = ci.bin_id
                   and ao.object_id = oc.id
                   and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           )t
         group by
               t.cmid
             , t.card_type
             , t.inst_id

    )
    -- Cards
    select c.cmid cmid
         , c.group_name
         , 'Total Number of Cards' as param_name
         , c.inst_id
         , c.card_type
         , c.cnt_all
      from cards c
     union all
    select c.cmid cmid
         , c.group_name
         , 'Number of Cards - Magnetic Stripe' as param_name
         , c.inst_id
         , c.card_type
         , c.cnt_magn
      from cards c
     union all
    select c.cmid cmid
         , c.group_name
         , 'Number of Cards - Magnetic Stripe, Chip' as param_name
         , c.inst_id
         , c.card_type
         , c.cnt_chip
      from cards c
     union all
    select c.cmid cmid
         , c.group_name
         , 'Number of Cards - Magnetic Stripe, Contactless' as param_name
         , c.inst_id
         , c.card_type
         , c.cnt_cless
      from cards c
     union all
    select c.cmid cmid
         , c.group_name
         , 'Number of Cards - Magnetic Stripe, Chip, Contactless' as param_name
         , c.inst_id
         , c.card_type
         , c.cnt_chip_cless
      from cards c
     union all
    select c.cmid cmid
         , c.group_name
         , 'Total Number of Active Cards' as param_name
         , c.inst_id
         , c.card_type
         , c.cnt_all
      from active_cards c
    -- Accounts
     union all
    select a.cmid cmid
         , a.group_name
         , 'Total Number of Accounts' as param_name
         , a.inst_id
         , a.card_type
         , a.cnt_all
      from accounts a
     union all
    select a.cmid cmid
         , a.group_name
         , 'Total Number of Active Accounts' as param_name
         , a.inst_id
         , a.card_type
         , a.cnt_actives
      from accounts a
     union all
    select a.cmid cmid
         , a.group_name
         , 'Number of Accounts - International Enabled' as param_name
         , a.inst_id
         , a.card_type
         , a.cnt_all
      from accounts a;

    -- Acquiring cemea - sales
    cursor cu_data_group_17_5_1(
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    ),
    acq as (
    select t.cmid
         , t.month_number
         , t.group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , decode(upper(t.param_name), 'REFUNDS', -1, 1) * sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
      from (select m.cmid
                 , to_number(to_char(o.oper_date, 'mm')) month_number
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_CEMEA_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                   as param_name
                 , case when o.is_iss = 1 then '242.On-Us'
                        when o.merchant_country = o.card_country then '243.National'
                        else '244.International'
                   end
                   as group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
          group by m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_CEMEA_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                 , case when o.is_iss = 1 then '242.On-Us'
                        when o.merchant_country = o.card_country then '243.National'
                        else '244.International'
                   end
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
           ) t
    group by t.cmid
           , t.month_number
           , t.param_name
           , t.group_name
           , t.inst_id
    )
    select a.cmid
         , a.group_name
         , substr(a.group_name, 5, 17)||' '||param_name||' Count - Month '||replace(mod(a.month_number, 3), 0, 3) as param_name
         , a.inst_id
         , a.value_1
      from acq a
     union all
    select a.cmid
         , a.group_name
         , substr(a.group_name, 5, 17)||' '||param_name||' Volume - Month '||replace(mod(a.month_number, 3), 0, 3) as param_name
         , a.inst_id
         , a.value_2
      from acq a;

    -- Merchant data
    cursor cu_data_group_17_5_2(
        i_start_date              in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with
    cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    ),
    merchant as (
        select t.cmid
             , t.inst_id
             , count(1) as cnt_all
             , sum(case when t.input_cap in ('2','5','B','C','D','E') then 1 else 0 end) as cnt_chip
             , sum(case when t.input_cap in ('3','4','S') or t.terminal_type in ('TRMT0004') then 1 else 0 end) as cnt_cless
             , sum(case when t.input_cap in ('M','A') then 1 else 0 end) as cnt_chip_cless
             , sum(case when t.terminal_type in ('TRMT0007') then 1 else 0 end) as cnt_mpos
          from (select distinct
                       m.cmid
                     , acq.id
                     , m.inst_id
                     , substr(trm.card_data_input_cap, -1) as input_cap
                     , trm.terminal_type
                  from acq_merchant acq
                     , acq_merchant acq2
                     , cmid m
                     , acq_terminal trm
                 where acq2.parent_id(+) = acq.id
                   and acq2.id is null
                   and trm.merchant_id = acq.id
                   and acq.inst_id = m.inst_id
                   and acq.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
                   and acq.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
                   and trm.card_data_input_cap != 'F2210001'
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date ) t
         group by t.cmid
                , t.inst_id
    ),
    outlet as (
        select t.cmid
             , t.inst_id
             , count(1) as cnt_all
             , sum(case when t.input_cap in ('2','5','B','C','D','E') then 1 else 0 end) as cnt_chip
             , sum(case when t.input_cap in ('3','4','S') or t.terminal_type in ('TRMT0004') then 1 else 0 end) as cnt_cless
             , sum(case when t.input_cap in ('M','A') then 1 else 0 end) as cnt_chip_cless
             , sum(case when t.terminal_type in ('TRMT0007') then 1 else 0 end) as cnt_mpos
          from (select distinct
                       m.cmid
                     , acq.id
                     , com_api_address_pkg.get_address_string(ao.address_id) address_name
                     , m.inst_id
                     , substr(trm.card_data_input_cap, -1) as input_cap
                     , trm.terminal_type
                  from acq_merchant acq
                     , acq_merchant acq2
                     , cmid m
                     , acq_terminal trm
                     , com_address_object ao
                 where acq2.parent_id(+) = acq.id
                   and acq2.id is null
                   and trm.merchant_id = acq.id
                   and trm.id = ao.object_id(+)
                   and ao.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                   and acq.inst_id = m.inst_id
                   and acq.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
                   and acq.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
                   and trm.card_data_input_cap != 'F2210001'
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date ) t
         group by t.cmid
                , t.inst_id
    ),
    terminal as (
        select t.cmid
             , t.inst_id
             , sum(case when t.terminal_type != 'TRMT0007' then 1 else 0 end)            as cnt_all
             , sum(case when t.terminal_type != 'TRMT0007'
                         and t.input_cap in ('2','5','B','C','D','E') then 1 else 0 end) as cnt_chip
             , sum(case when (t.terminal_type != 'TRMT0007' and t.input_cap in ('3','4','S'))
                          or t.terminal_type in ('TRMT0004') then 1 else 0 end)          as cnt_cless
             , sum(case when t.terminal_type != 'TRMT0007'
                         and t.input_cap in ('M','A') then 1 else 0 end)                 as cnt_chip_cless
             , sum(case when t.terminal_type != 'TRMT0007'
                         and t.auth_method = 1
                         and t.input_cap in ('2','B') then 1 else 0 end)                 as cnt_with_pin_mag
             , sum(case when t.terminal_type != 'TRMT0007'
                         and t.auth_method = 1
                         and t.input_cap in ('5','C','D','E','M','A') then 1 else 0 end) as cnt_with_pin_mag_chip
             , sum(case when t.terminal_type != 'TRMT0007'
                         and t.auth_method != 1
                         and t.input_cap in ('2','B') then 1 else 0 end)                 as cnt_without_pin_mag
             , sum(case when t.terminal_type != 'TRMT0007'
                         and t.auth_method != 1
                         and t.input_cap in ('5','C','D','E','M','A') then 1 else 0 end) as cnt_without_pin_mag_chip
             , sum(case when t.terminal_type = 'TRMT0007' then 1 else 0 end)             as cnt_mp_all
             , sum(case when t.terminal_type = 'TRMT0007'
                         and t.input_cap in ('2','5','B','C','D','E') then 1 else 0 end) as cnt_mp_chip
             , sum(case when t.terminal_type = 'TRMT0007'
                         and t.input_cap in ('3','4','S') then 1 else 0 end)             as cnt_mp_cless
             , sum(case when t.terminal_type = 'TRMT0007'
                         and t.input_cap in ('M','A') then 1 else 0 end)                 as cnt_mp_chip_cless
             , sum(case when t.terminal_type = 'TRMT0007'
                         and t.auth_method = 1
                         and t.input_cap in ('2','B') then 1 else 0 end)                 as cnt_mp_with_pin_mag
             , sum(case when t.terminal_type = 'TRMT0007'
                         and t.auth_method = 1
                         and t.input_cap in ('5','C','D','E','M','A') then 1 else 0 end) as cnt_mp_with_pin_mag_chip
             , sum(case when t.terminal_type = 'TRMT0007'
                         and t.auth_method != 1
                         and t.input_cap in ('2','B') then 1 else 0 end)                 as cnt_mp_without_pin_mag
             , sum(case when t.terminal_type = 'TRMT0007'
                         and t.auth_method != 1
                         and t.input_cap in ('5','C','D','E','M','A') then 1 else 0 end) as cnt_mp_without_pin_mag_chip
          from (select distinct
                       m.cmid
                     , acq.id
                     , com_api_address_pkg.get_address_string(ao.address_id) address_name
                     , m.inst_id
                     , substr(trm.card_data_input_cap, -1) as input_cap
                     , substr(trm.crdh_auth_method, -1)    as auth_method
                     , trm.terminal_type
                     , trm.id
                  from acq_merchant acq
                     , acq_merchant acq2
                     , cmid m
                     , acq_terminal trm
                     , com_address_object ao
                 where acq2.parent_id(+) = acq.id
                   and acq2.id is null
                   and trm.merchant_id = acq.id
                   and trm.id = ao.object_id(+)
                   and ao.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                   and acq.inst_id = m.inst_id
                   and acq.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
                   and acq.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
                   and trm.card_data_input_cap != 'F2210001'
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                   and exists (select 1 from qpr_aggr o, cmid m
                                where o.is_acq = 1
                                  and o.card_inst_id = m.inst_id
                                  and o.terminal_number = trm.terminal_number
                                  and o.status in (select element_value
                                                     from com_array_element
                                                    where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                                  and o.oper_date between i_start_date and i_end_date
                                  and substr(o.card_data_input_mode, -1) in ('P','N','M'))
                       ) t
         group by t.cmid
                , t.inst_id
    ),
    principal as (
        select t.cmid
             , t.inst_id
             , count(1) as cnt_all
          from (select distinct
                       m.cmid
                     , cao.id
                     , m.inst_id
                  from acq_merchant acq
                     , acq_merchant acq2
                     , cmid m
                     , acq_terminal trm
                     , com_address_object cao
                 where acq2.parent_id(+) = acq.id
                   and acq2.id is null
                   and trm.merchant_id   = acq.id
                   and trm.is_template   = 0
                   and trm.inst_id       = acq.inst_id
                   and acq.inst_id       = m.inst_id
                   and nvl(trm.mcc, acq.mcc) = vis_api_const_pkg.MCC_CASH
                   and trm.status        = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and trm.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                   and cao.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and cao.address_type  = com_api_const_pkg.ADDRESS_TYPE_BUSINESS
                   and cao.object_id     = acq.id
                   and exists (select 1 from ost_institution i
                                where i.id = m.inst_id
                                  and i.parent_id is null)
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                ) t
         group by t.cmid
                , t.inst_id
    ),
    assoc as (
        select t.cmid
             , t.inst_id
             , count(1) as cnt_all
          from (select distinct
                       m.cmid
                     , cao.id
                     , m.inst_id
                  from acq_merchant acq
                     , acq_merchant acq2
                     , cmid m
                     , acq_terminal trm
                     , com_address_object cao
                 where acq2.parent_id(+) = acq.id
                   and acq2.id is null
                   and trm.merchant_id   = acq.id
                   and trm.is_template   = 0
                   and trm.inst_id       = acq.inst_id
                   and acq.inst_id       = m.inst_id
                   and nvl(trm.mcc, acq.mcc) = vis_api_const_pkg.MCC_CASH
                   and trm.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                   and trm.status        = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and cao.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and cao.address_type  = com_api_const_pkg.ADDRESS_TYPE_BUSINESS
                   and cao.object_id     = acq.id
                   and (exists (select 1 from ost_institution i
                                where i.id = m.inst_id
                                  and i.parent_id is not null)
                        or
                        exists (select 1 from ost_institution i
                                  where i.parent_id = m.inst_id))
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                ) t
         group by t.cmid
                , t.inst_id
    ),
    atm as (
        select t.cmid
             , t.inst_id
             , count(1) as cnt_all
             , sum(case when t.input_cap in ('2','B') then 1 else 0 end) as cnt_mag
             , sum(case when t.input_cap in ('5','C','D','E') then 1 else 0 end) as cnt_mag_chip
             , sum(case when t.input_cap in ('M','A') then 1 else 0 end) as cnt_mag_cless
          from (select distinct
                       m.cmid
                     , acq.id
                     , trm.id terminal_id
                     , m.inst_id
                     , substr(trm.card_data_input_cap, -1) as input_cap
                     , trm.terminal_type
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid m
                 where trm.merchant_id    = acq.id
                   and trm.is_template    = 0
                   and trm.inst_id        = acq.inst_id
                   and acq.inst_id        = m.inst_id
                   and nvl(trm.mcc, acq.mcc) = vis_api_const_pkg.MCC_ATM
                   and trm.status         = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and trm.card_data_input_cap != 'F2210001'
                   and (select min(pso.start_date)
                                  from prd_service_object pso
                                 where pso.object_id = acq.id
                                   and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                               ) <= i_end_date
                ) t
         group by t.cmid
                , t.inst_id
    )
    -- Merchants
    select m.cmid cmid
         , '240.Merchant Data' group_name
         , 'Total Number of Merchants' as param_name
         , m.inst_id
         , m.cnt_all
      from merchant m
     union all
    select m.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchants - Magnetic Stripe, Chip' as param_name
         , m.inst_id
         , m.cnt_chip
      from merchant m
     union all
    select m.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchants - Magnetic Stripe, Contactless' as param_name
         , m.inst_id
         , m.cnt_cless
      from merchant m
     union all
    select m.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchants - Magnetic Stripe, Chip, Contactless' as param_name
         , m.inst_id
         , m.cnt_chip_cless
      from merchant m
     union all
    select m.cmid cmid
         , '240.Merchant Data' group_name
         , 'Total Number of mPOS Merchants' as param_name
         , m.inst_id
         , m.cnt_mpos
      from merchant m
     union all
    -- Outlets
    select o.cmid cmid
         , '240.Merchant Data' group_name
         , 'Total Number of Merchant Outlets' as param_name
         , o.inst_id
         , o.cnt_all
      from outlet o
     union all
    select o.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchant Outlets - Magnetic Stripe, Chip' as param_name
         , o.inst_id
         , o.cnt_chip
      from outlet o
     union all
    select o.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchant Outlets - Magnetic Stripe, Contactless' as param_name
         , o.inst_id
         , o.cnt_cless
      from outlet o
     union all
    select o.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchant Outlets - Magnetic Stripe, Chip, Contactless' as param_name
         , o.inst_id
         , o.cnt_chip_cless
      from outlet o
     union all
    select o.cmid cmid
         , '240.Merchant Data' group_name
         , 'Total Number of mPOS Merchant Outlets' as param_name
         , o.inst_id
         , o.cnt_mpos
      from outlet o
     union all
    -- Terminals
    select t.cmid cmid
         , '240.Merchant Data' group_name
         , 'Total Number of Merchant Terminals' as param_name
         , t.inst_id
         , t.cnt_all
      from terminal t
     union all
    select t.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchant Terminals - Magnetic Stripe, Chip' as param_name
         , t.inst_id
         , t.cnt_chip
      from terminal t
     union all
    select t.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchant Terminals - Magnetic Stripe, Contactless' as param_name
         , t.inst_id
         , t.cnt_cless
      from terminal t
     union all
    select t.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchant Terminals - Magnetic Stripe, Chip, Contactless' as param_name
         , t.inst_id
         , t.cnt_chip_cless
      from terminal t
     union all
    select t.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchant Terminal with Pin Entry - Magnetic Stripe' as param_name
         , t.inst_id
         , t.cnt_with_pin_mag
      from terminal t
     union all
    select t.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchant Terminal with Pin Entry - Magnetic Stripe, Chip' as param_name
         , t.inst_id
         , t.cnt_with_pin_mag_chip
      from terminal t
     union all
    select t.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchant Terminal without Pin Entry - Magnetic Stripe' as param_name
         , t.inst_id
         , t.cnt_without_pin_mag
      from terminal t
     union all
    select t.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Merchant Terminal without Pin Entry - Magnetic Stripe, Chip' as param_name
         , t.inst_id
         , t.cnt_without_pin_mag_chip
      from terminal t
     union all
    -- Principals
    select p.cmid cmid
         , '240.Merchant Data' group_name
         , 'Principal Branches' as param_name
         , p.inst_id
         , p.cnt_all
      from principal p
     union all
    -- Associates
    select a.cmid cmid
         , '240.Merchant Data' group_name
         , 'Associate Branches' as param_name
         , a.inst_id
         , a.cnt_all
      from assoc a
     union all
    -- ATMs
    select a.cmid cmid
         , '240.Merchant Data' group_name
         , 'Total Number of Visa/Plus ATMs' as param_name
         , a.inst_id
         , a.cnt_all
      from atm a
     union all
    select a.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Visa/Plus ATMs - Magnetic Stripe' as param_name
         , a.inst_id
         , a.cnt_mag
      from atm a
     union all
    select a.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Visa/Plus ATMs - Magnetic Stripe, Chip' as param_name
         , a.inst_id
         , a.cnt_mag_chip
      from atm a
     union all
    select a.cmid cmid
         , '240.Merchant Data' group_name
         , 'Number of Visa/Plus ATMs - Magnetic Stripe, Contactless' as param_name
         , a.inst_id
         , a.cnt_mag_cless
      from atm a;

    -- Merchant Category Groups
    cursor cu_data_group_17_5_3(
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with
    cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    ),
    c as (
    select t.cmid
         , t.month_number
         , '241.Merchant Category Groups' group_name
         , t.ru_visa_mcg param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount(
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.card_inst_id
                    , t.oper_date
                    , 1
                    , null
                )
            ) / i_del_value
        ) value_2
    from (
        select m.cmid cmid
             , to_number(to_char(trunc(o.oper_date,'Q'), 'mm')) month_number
             , o.card_inst_id card_inst_id
             , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
             , o.currency oper_currency
             , sum(decode(o.is_reversal, 1, -1, 1) * decode(o.oper_type, 'OPTP0020', -1, 1) *  o.amount) oper_amount
             , o.oper_date
             , cm.ru_visa_mcg
             , m.inst_id
          from qpr_aggr o
             , (select ct.id card_type_id
                  from net_card_type ct
                 where ct.network_id = i_network_id
               ) ct
             , cmid m
             , com_mcc cm
         where o.is_acq = 1
           and o.card_inst_id = m.inst_id
           and o.card_network_id = i_network_id
           and o.oper_date between i_start_date and i_end_date
           and o.card_type_id = ct.card_type_id
           and o.oper_type not in (opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                                 , opr_api_const_pkg.OPERATION_TYPE_CASHIN
                                 , opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT)
           and o.mcc = cm.mcc
           and com_api_array_pkg.conv_array_elem_v(
                   i_lov_id            => 49
                 , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                 , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                 , i_elem_value        => o.oper_type
               ) in ('Sales', 'Refunds')
         group by
              m.cmid
            , to_number(to_char(o.oper_date, 'mm'))
            , o.card_inst_id
            , o.currency
            , o.oper_date
            , cm.ru_visa_mcg
            , m.inst_id
        ) t
    group by
        t.cmid
        , t.month_number
        , t.ru_visa_mcg
        , t.inst_id
    ),
    recurring_trans as (
        select t.cmid
             , '241.Merchant Category Groups' group_name
             , t.inst_id
             , sum(t.nn_trans) value_1
             , sum(decode(
                      t.oper_currency
                    , i_dest_curr
                    , t.oper_amount
                    , com_api_rate_pkg.convert_amount (
                          t.oper_amount
                        , t.oper_currency
                        , i_dest_curr
                        , i_rate_type
                        , t.inst_id
                        , t.oper_date
                        , 1
                        , null
                      )
                   ) / i_del_value
               ) value_2
          from (select a.cmid
                     , a.inst_id
                     , a.oper_currency
                     , a.oper_date
                     , a.nn_trans
                     , decode(upper(a.param_name), 'OPTP0020', -1, 1) * oper_amount as oper_amount
                  from (select m.cmid
                             , com_api_array_pkg.conv_array_elem_v(
                                   i_lov_id            => 49
                                 , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                                 , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                 , i_elem_value        => o.oper_type
                               )
                               as param_name
                             , o.card_inst_id inst_id
                             , o.oper_date
                             , o.currency oper_currency
                             , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                             , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                          from qpr_aggr o
                             , cmid m
                         where o.is_acq = 1
                           and o.pos_environment = 'R'
                           and o.card_inst_id = m.inst_id
                           and o.card_network_id = i_network_id
                           and o.status in (select element_value
                                              from com_array_element
                                             where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                           and o.oper_date between i_start_date and i_end_date
                      group by m.cmid
                             , com_api_array_pkg.conv_array_elem_v(
                                   i_lov_id            => 49
                                 , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                                 , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                 , i_elem_value        => o.oper_type
                               )
                             , o.card_inst_id
                             , o.oper_date
                             , o.currency
                        ) a
                ) t
      group by t.cmid
             , t.inst_id
    )
    select c.cmid
         , c.group_name
         , 'Merchant Category Groups - '||c.param_name||' - Count' as param_name
         , c.inst_id
         , c.value_1
      from c
     union all
    select c.cmid
         , c.group_name
         , 'Merchant Category Groups - '||c.param_name||' - Volume' as param_name
         , c.inst_id
         , c.value_2
      from c
     union all
    select rt.cmid
         , rt.group_name
         , 'Merchant Category Groups - Recurring Transactions - Count' as param_name
         , rt.inst_id
         , rt.value_1
      from recurring_trans rt
     union all
    select rt.cmid
         , rt.group_name
         , 'Merchant Category Groups - Recurring Transactions - Volume' as param_name
         , rt.inst_id
         , rt.value_2
      from recurring_trans rt;

    -- Associates
    cursor cu_data_group_17_6_1(
        i_quarter               in com_api_type_pkg.t_tiny_id
        , i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.ACQ_BUSINESS_ID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    ),
    iss as (
    select t.cmid
         , i_quarter * 3 - 2 as month_number
         , rtrim(t.group_name) group_name
         , rtrim(t.acq_param) param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(t.amount) value_2
     from (
         select group_name
              , cmid as cmid
              , to_number(to_char(o.oper_date, 'mm')) month_number
              , case when
                    com_api_array_pkg.conv_array_elem_v(
                         i_lov_id            => 49
                       , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                       , i_array_id          => vis_api_const_pkg.QR_CEMEA_ISS_OPER_TYPE_ARRAY
                       , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                       , i_elem_value        => o.oper_type
                     ) = 'Payments' then 'Payments'
                    else 'Cash Disbursements'
                end as acq_param
              , inst_id
              , nn_trans  nn_trans
              , decode(
                        o.currency
                      , i_dest_curr
                      , o.amount
                      , com_api_rate_pkg.convert_amount(
                            o.amount
                          , o.currency
                          , i_dest_curr
                          , i_rate_type
                          , o.card_inst_id
                          , o.oper_date
                          , 1
                          , null
                        )
                  ) / i_del_value
                as amount
         from (select '257.Associate' as group_name
                    , m.cmid
                    , o.oper_type
                    , ct.card_feature
                    , com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                           , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.card_type_id
                      ) as card_type_id
                    , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
                    , sum (decode(o.is_reversal, 1, -1, 1) * o.amount) amount
                    , o.currency
                    , o.oper_date
                    , card_inst_id
                    , m.inst_id
                 from qpr_aggr o
                    , (select cf.card_type_id
                            , cf.card_feature
                         from net_card_type ct
                            , net_card_type_feature cf
                        where ct.network_id = i_network_id
                          and ct.id = cf.card_type_id
                          and cf.card_feature in (vis_api_const_pkg.VISA_STANDART, vis_api_const_pkg.VISA_ELECTRON)
                      ) ct
                    , cmid m
                where o.is_iss = 1
                  and o.card_inst_id = m.inst_id
                  and o.card_network_id = i_network_id
                  and o.status in (select element_value
                                     from com_array_element
                                    where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                  and o.oper_date between i_start_date and i_end_date
                  and o.card_type_id = ct.card_type_id
                  and com_api_array_pkg.conv_array_elem_v(
                           i_lov_id            => 49
                         , i_array_type_id     => 1030
                         , i_array_id          => 10000116
                         , i_inst_id           => 9999
                         , i_elem_value        => o.oper_type
                    ) in ('Payments', 'ATM Cash Advances', 'Manual Cash')
                group by
                    m.cmid
                    , o.oper_type
                    , ct.card_feature
                    , com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                           , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.card_type_id
                      )
                    , o.currency
                    , o.oper_date
                    , card_inst_id
                    , m.inst_id
                    ) o
            ) t
        group by
            t.cmid
            , t.month_number
            , t.group_name
            , t.acq_param
            , t.inst_id
    ),
    acq as (
    select t.cmid
         , t.month_number
         , t.group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
      from (select m.cmid
                 , to_number(to_char(o.oper_date, 'mm')) month_number
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_CEMEA_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                   as param_name
                 , '257.Associate' as group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
              from qpr_aggr o
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_CEMEA_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   ) in ('Payments', 'ATM Cash Advances', 'Manual Cash')
          group by m.cmid
                 , to_number(to_char(o.oper_date, 'mm'))
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_CEMEA_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
           ) t
    group by t.cmid
           , t.month_number
           , t.param_name
           , t.group_name
           , t.inst_id
    )
    select a.cmid
         , a.month_number
         , a.group_name
         , 'Issuing '||param_name||' Count - Total Quarter' as param_name
         , a.inst_id
         , a.value_1
      from iss a
     union all
    select a.cmid
         , a.month_number
         , a.group_name
         , 'Issuing '||param_name||' Volume - Total Quarter' as param_name
         , a.inst_id
         , a.value_2
      from iss a
     union all
    select a.cmid
         , a.month_number
         , a.group_name
         , 'Acquiring '||param_name||' Count - Total Quarter' as param_name
         , a.inst_id
         , a.value_1
      from iss a
     union all
    select a.cmid
         , a.month_number
         , a.group_name
         , 'Acquiring '||param_name||' Volume - Total Quarter' as param_name
         , a.inst_id
         , a.value_2
      from iss a;

    -- Associates (cards, accounts)
    cursor cu_data_group_17_6_2(
        i_quarter               in com_api_type_pkg.t_tiny_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with
    cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.ACQ_BUSINESS_ID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    ),
    cards as (
        select t.cmid
             , i_quarter * 3 - 2        as month_number
             , '257.Associate'          as group_name
             , t.inst_id
             , count(1)                 as cnt_all
          from (select m.cmid cmid
                     , oc.id card_id
                     , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 130
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => oc.card_type_id
                       ) as card_type_id
                     , m.inst_id
                 from iss_card oc
                    , iss_card_instance ci
                    , net_card_type ct
                    , cmid m
                where oc.inst_id = m.inst_id
                  and ci.card_id = oc.id
                  and ci.seq_number = (select max(i.seq_number)
                                         from iss_card_instance i
                                        where i.card_id = ci.card_id)
                  and ci.expir_date > i_end_date
                  and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date
                  and ci.status in (iss_api_const_pkg.CARD_STATUS_VALID_CARD, iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED)
                  and ct.network_id = i_network_id
                  and ct.id = oc.card_type_id
                ) t
        group by t.cmid
               , t.inst_id
    ),
    accounts as (
        select t.cmid
             , i_quarter * 3 - 2            as month_number
             , '257.Associate'              as group_name
             , t.inst_id
             , count(distinct t.account_id) as cnt_all
          from (select distinct
                       m.cmid
                     , m.inst_id
                     , ao.account_id
                  from iss_card oc
                     , iss_card_instance ci
                     , iss_bin ib
                     , acc_account_object ao
                     , (select ct.id card_type_id
                             , com_api_array_pkg.conv_array_elem_v(
                                          i_lov_id            => 130
                                        , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                                        , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                        , i_elem_value        => ct.id
                               ) as main_card_type_id
                          from net_card_type ct
                         where ct.network_id = i_network_id
                       ) ct
                     , cmid m
                 where oc.inst_id = m.inst_id
                   and ci.card_id = oc.id
                   and ci.seq_number = (select max(i.seq_number)
                                         from iss_card_instance i
                                        where i.card_id = ci.card_id)
                   and oc.card_type_id = ct.card_type_id
                   and ci.start_date <= i_end_date
                   and ci.expir_date >= i_end_date
                   and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
                   and ib.id = ci.bin_id
                   and ao.object_id = oc.id
                   and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           )t
         group by
               t.cmid
             , t.inst_id
    ),
    merchant as (
        select t.cmid
             , i_quarter * 3 - 2        as month_number
             , '257.Associate'          as group_name
             , t.inst_id
             , count(1) as cnt_all
          from (select distinct
                       m.cmid
                     , acq.id
                     , m.inst_id
                     , substr(trm.card_data_input_cap, -1) as input_cap
                     , trm.terminal_type
                  from acq_merchant acq
                     , acq_merchant acq2
                     , cmid m
                     , acq_terminal trm
                 where acq2.parent_id(+) = acq.id
                   and acq2.id is null
                   and trm.merchant_id = acq.id
                   and acq.inst_id = m.inst_id
                   and acq.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
                   and acq.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date ) t
         group by t.cmid
                , t.inst_id
    ),
    outlet as (
        select t.cmid
             , i_quarter * 3 - 2        as month_number
             , '257.Associate'          as group_name
             , t.inst_id
             , count(1) as cnt_all
          from (select distinct
                       m.cmid
                     , acq.id
                     , com_api_address_pkg.get_address_string(ao.address_id) address_name
                     , m.inst_id
                     , substr(trm.card_data_input_cap, -1) as input_cap
                     , trm.terminal_type
                  from acq_merchant acq
                     , acq_merchant acq2
                     , cmid m
                     , acq_terminal trm
                     , com_address_object ao
                 where acq2.parent_id(+) = acq.id
                   and acq2.id is null
                   and trm.merchant_id = acq.id
                   and trm.id = ao.object_id(+)
                   and ao.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                   and acq.inst_id = m.inst_id
                   and acq.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
                   and acq.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date ) t
         group by t.cmid
                , t.inst_id
    )
    select c.cmid cmid
         , c.month_number
         , c.group_name
         , 'Total Number of Cards' as param_name
         , c.inst_id
         , c.cnt_all
      from cards c
     union all
    select a.cmid cmid
         , a.month_number
         , a.group_name
         , 'Total Number of Accounts - International Enabled' as param_name
         , a.inst_id
         , a.cnt_all
      from accounts a
     union all
    select m.cmid cmid
         , m.month_number
         , m.group_name
         , 'Total Number of Sponsored Merchants' as param_name
         , m.inst_id
         , m.cnt_all
      from merchant m
     union all
    select o.cmid cmid
         , o.month_number
         , o.group_name
         , 'Total Number of Sponsored Merchant Outlets' as param_name
         , o.inst_id
         , o.cnt_all
      from outlet o;

    -- BIN Reporting
    cursor cu_data_group_17_7_1(
        i_quarter               in com_api_type_pkg.t_tiny_id
        , i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    ),
    iss as (
    select t.cmid
         , i_quarter * 3 - 2 as month_number
         , rtrim(t.group_name) group_name
         , rtrim(t.acq_param) param_name
         , t.inst_id
         , t.card_bin
         , sum(t.nn_trans) value_1
         , sum(t.amount) value_2
     from (
         select group_name
              , cmid as cmid
              , to_number(to_char(o.oper_date, 'mm')) month_number
              , case when
                    com_api_array_pkg.conv_array_elem_v(
                         i_lov_id            => 49
                       , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                       , i_array_id          => vis_api_const_pkg.QR_CEMEA_ISS_OPER_TYPE_ARRAY
                       , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                       , i_elem_value        => o.oper_type
                     ) = 'Payments' then 'Payments'
                    else 'Cash Disbursements'
                end as acq_param
              , inst_id
              , o.card_bin
              , nn_trans  nn_trans
              , decode(
                        o.currency
                      , i_dest_curr
                      , o.amount
                      , com_api_rate_pkg.convert_amount(
                            o.amount
                          , o.currency
                          , i_dest_curr
                          , i_rate_type
                          , o.card_inst_id
                          , o.oper_date
                          , 1
                          , null
                        )
                  ) / i_del_value
                as amount
         from (select case
                          when o.is_acq = 1 then '260.On-Us'
                          when o.merchant_country = o.card_country then '261.National'
                          else '262.International'
                      end as group_name
                    , m.cmid
                    , o.oper_type
                    , ct.card_feature
                    , o.card_bin
                    , com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                           , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.card_type_id
                      ) as card_type_id
                    , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt)  nn_trans
                    , sum (decode(o.is_reversal, 1, -1, 1) * o.amount) amount
                    , o.currency
                    , o.oper_date
                    , card_inst_id
                    , m.inst_id
                 from qpr_aggr o
                    , (select cf.card_type_id
                            , cf.card_feature
                         from net_card_type ct
                            , net_card_type_feature cf
                        where ct.network_id = i_network_id
                          and ct.id = cf.card_type_id
                          and cf.card_feature in (vis_api_const_pkg.VISA_STANDART, vis_api_const_pkg.VISA_ELECTRON)
                      ) ct
                    , cmid m
                    , iss_bin b
                where o.is_iss = 1
                  and o.card_inst_id = m.inst_id
                  and o.card_network_id = i_network_id
                  and o.status in (select element_value
                                     from com_array_element
                                    where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                  and o.oper_date between i_start_date and i_end_date
                  and o.card_type_id = ct.card_type_id
                  and o.card_bin = b.bin
                  and com_api_array_pkg.conv_array_elem_v(
                           i_lov_id            => 49
                         , i_array_type_id     => 1030
                         , i_array_id          => 10000116
                         , i_inst_id           => 9999
                         , i_elem_value        => o.oper_type
                    ) in ('Payments', 'ATM Cash Advances', 'Manual Cash')
                group by
                      case
                          when o.is_acq = 1 then '260.On-Us'
                          when o.merchant_country = o.card_country then '261.National'
                          else '262.International'
                      end
                    , m.cmid
                    , o.oper_type
                    , ct.card_feature
                    , o.card_bin
                    , com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                           , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => o.card_type_id
                      )
                    , o.currency
                    , o.oper_date
                    , card_inst_id
                    , m.inst_id
                    , o.account_funding_source
                    ) o
            ) t
        group by
              t.group_name
            , t.cmid
            , t.month_number
            , t.acq_param
            , t.inst_id
            , t.card_bin
    )
    select a.cmid
         , a.month_number
         , a.group_name
         , substr(a.group_name, 5, 17)||' '||param_name||' Count - Total Quarter' as param_name
         , a.inst_id
         , a.value_1
         , a.card_bin as bin
      from iss a
     union all
    select a.cmid
         , a.month_number
         , a.group_name
         , substr(a.group_name, 5, 17)||' '||param_name||' Volume - Total Quarter' as param_name
         , a.inst_id
         , a.value_2
         , a.card_bin as bin
      from iss a;

    -- BIN Reporting (cards, accounts)
    cursor cu_data_group_17_7_2(
        i_quarter               in com_api_type_pkg.t_tiny_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with
    cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    ),
    cards as (
        select t.cmid
             , i_quarter * 3 - 2        as month_number
             , '263.Cards and Accounts' as group_name
             , t.card_bin
             , t.inst_id
             , count(1)                 as cnt_all
          from (select m.cmid cmid
                     , substr(oc.card_mask, 1, 6) as card_bin
                     , oc.id card_id
                     , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 130
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => oc.card_type_id
                       ) as card_type_id
                     , m.inst_id
                 from iss_card oc
                    , iss_card_instance ci
                    , net_card_type ct
                    , cmid m
                where oc.inst_id = m.inst_id
                  and ci.card_id = oc.id
                  and ci.seq_number = (select max(i.seq_number)
                                         from iss_card_instance i
                                        where i.card_id = ci.card_id)
                  and ci.expir_date > i_end_date
                  and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date
                  and ci.status in (iss_api_const_pkg.CARD_STATUS_VALID_CARD, iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED)
                  and ct.network_id = i_network_id
                  and ct.id = oc.card_type_id
                ) t
        group by t.cmid
               , t.card_bin
               , t.inst_id
    ),
    accounts as (
        select t.cmid
             , i_quarter * 3 - 2            as month_number
             , '263.Cards and Accounts'     as group_name
             , t.card_bin
             , t.inst_id
             , count(distinct t.account_id) as cnt_all
          from (select distinct
                       m.cmid
                     , substr(oc.card_mask, 1, 6) as card_bin
                     , m.inst_id
                     , ao.account_id
                  from iss_card oc
                     , iss_card_instance ci
                     , iss_bin ib
                     , acc_account_object ao
                     , (select ct.id card_type_id
                             , com_api_array_pkg.conv_array_elem_v(
                                          i_lov_id            => 130
                                        , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                                        , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                        , i_elem_value        => ct.id
                               ) as main_card_type_id
                          from net_card_type ct
                         where ct.network_id = i_network_id
                       ) ct
                     , cmid m
                 where oc.inst_id = m.inst_id
                   and ci.card_id = oc.id
                   and ci.seq_number = (select max(i.seq_number)
                                         from iss_card_instance i
                                        where i.card_id = ci.card_id)
                   and oc.card_type_id = ct.card_type_id
                   and ci.start_date <= i_end_date
                   and ci.expir_date >= i_end_date
                   and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
                   and ib.id = ci.bin_id
                   and ao.object_id = oc.id
                   and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           )t
         group by
               t.cmid
             , t.card_bin
             , t.inst_id
    )
    select c.cmid cmid
         , c.month_number
         , c.group_name
         , 'Total Number of Cards' as param_name
         , c.inst_id
         , c.cnt_all
         , c.card_bin as bin
      from cards c
     union all
    select a.cmid cmid
         , a.month_number
         , a.group_name
         , 'Total Number of Accounts' as param_name
         , a.inst_id
         , a.cnt_all
         , a.card_bin as bin
      from accounts a;

    -- Proprietary Plus BIN
    cursor cu_data_group_17_8_1 (
        i_quarter               in com_api_type_pkg.t_tiny_id
        , i_dest_curr             in com_api_type_pkg.t_curr_code
        , i_del_value             in com_api_type_pkg.t_short_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_rate_type             in com_api_type_pkg.t_dict_value
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    ),
    iss as (
    select t.cmid
         , i_quarter * 3 - 2        as month_number
         , '259.Plus'               as group_name
         , t.inst_id
         , sum(case when is_domestic = 1 then t.nn_trans else 0 end) dom_cnt
         , sum(case when is_domestic = 1 then t.amount else 0 end) dom_amount
         , sum(case when is_domestic != 1 then t.nn_trans else 0 end) int_cnt
         , sum(case when is_domestic != 1 then t.amount else 0 end) int_amount
     from (select cmid as cmid
                , inst_id
                , is_domestic
                , nn_trans  nn_trans
                , decode(
                          o.currency
                        , i_dest_curr
                        , o.amount
                        , com_api_rate_pkg.convert_amount(
                              o.amount
                            , o.currency
                            , i_dest_curr
                            , i_rate_type
                            , o.inst_id
                            , o.oper_date
                            , 1
                            , null
                          )
                    ) / i_del_value
                  as amount
         from (select m.cmid
                    , o.oper_type
                    , case
                          when o.merchant_country = o.card_country then 1
                          else 0
                      end as is_domestic
                    , o.currency
                    , o.oper_date
                    , m.inst_id
                    , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt) nn_trans
                    , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) amount
                 from qpr_aggr o
                    , (select cf.card_type_id
                            , cf.card_feature
                         from net_card_type ct
                            , net_card_type_feature cf
                        where ct.network_id = i_network_id
                          and ct.id = cf.card_type_id
                          and cf.card_feature in (vis_api_const_pkg.VISA_STANDART, vis_api_const_pkg.VISA_ELECTRON)
                      ) ct
                    , cmid m
                    , iss_bin b
                where o.is_iss = 1
                  and o.card_inst_id = m.inst_id
                  and o.card_network_id = i_network_id
                  and o.status in (select element_value
                                     from com_array_element
                                    where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
                  and o.oper_date between i_start_date and i_end_date
                  and o.card_type_id = ct.card_type_id
                  and o.card_bin = b.bin
                  and o.product_id in ('R', 'E')
                  and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_CEMEA_ISS_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   ) = 'ATM Cash Advances'
                group by
                      case
                          when o.merchant_country = o.card_country then 1
                          else 0
                      end
                    , m.cmid
                    , o.oper_type
                    , o.currency
                    , o.oper_date
                    , m.inst_id
                    ) o
            ) t
        group by
              t.cmid
            , t.inst_id
    )
    select a.cmid
         , a.month_number
         , a.group_name
         , 'Domestic Proprietary Plus ATM Cash Advances Count - Total Quarter' as param_name
         , a.inst_id
         , a.dom_cnt
      from iss a
     union all
    select a.cmid
         , a.month_number
         , a.group_name
         , 'Domestic Proprietary Plus ATM Cash Advances Volume - Total Quarter' as param_name
         , a.inst_id
         , a.dom_amount
      from iss a
     union all
    select a.cmid
         , a.month_number
         , a.group_name
         , 'International Proprietary Plus ATM Cash Advances Count - Total Quarter' as param_name
         , a.inst_id
         , a.int_cnt
      from iss a
     union all
    select a.cmid
         , a.month_number
         , a.group_name
         , 'International Proprietary Plus ATM Cash Advances Volume - Total Quarter' as param_name
         , a.inst_id
         , a.int_amount
      from iss a;

    -- Proprietary Plus BIN (cards, accounts)
    cursor cu_data_group_17_8_2 (
        i_quarter               in com_api_type_pkg.t_tiny_id
        , i_start_date            in date
        , i_end_date              in date
        , i_standard_id           in com_api_type_pkg.t_tiny_id
        , i_host_id               in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_short_id
        , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with
    cmid as (
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
    ),
    cards as (
        select t.cmid
             , i_quarter * 3 - 2        as month_number
             , '259.Plus'               as group_name
             , t.inst_id
             , count(1)                 as cnt_all
          from (select m.cmid cmid
                     , oc.id card_id
                     , com_api_array_pkg.conv_array_elem_v(
                              i_lov_id            => 130
                            , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                            , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                            , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                            , i_elem_value        => oc.card_type_id
                       ) as card_type_id
                     , m.inst_id
                 from iss_card oc
                    , iss_card_instance ci
                    , iss_card_number cn
                    , net_card_type ct
                    , cmid m
                where oc.inst_id = m.inst_id
                  and ci.card_id = oc.id
                  and ci.seq_number = (select max(i.seq_number)
                                         from iss_card_instance i
                                        where i.card_id = ci.card_id)
                  and ci.expir_date > i_end_date
                  and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date
                  and ci.status in (iss_api_const_pkg.CARD_STATUS_VALID_CARD, iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED)
                  and oc.id = cn.card_id
                  and substr(cn.card_number, 1, 9) in (select visa_bin from qpr_detail_visa_bin where product_id in ('R', 'E'))
                  and ct.network_id = i_network_id
                  and ct.id = oc.card_type_id
                ) t
        group by t.cmid
               , t.inst_id
    ),
    accounts as (
        select t.cmid
             , i_quarter * 3 - 2            as month_number
             , '259.Plus'                   as group_name
             , t.inst_id
             , count(distinct t.account_id) as cnt_all
          from (select distinct
                       m.cmid
                     , m.inst_id
                     , ao.account_id
                  from iss_card oc
                     , iss_card_instance ci
                     , iss_card_number cn
                     , acc_account_object ao
                     , (select ct.id card_type_id
                             , com_api_array_pkg.conv_array_elem_v(
                                          i_lov_id            => 130
                                        , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                                        , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                                        , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                        , i_elem_value        => ct.id
                               ) as main_card_type_id
                          from net_card_type ct
                         where ct.network_id = i_network_id
                       ) ct
                     , cmid m
                 where oc.inst_id = m.inst_id
                   and ci.card_id = oc.id
                   and ci.seq_number = (select max(i.seq_number)
                                         from iss_card_instance i
                                        where i.card_id = ci.card_id)
                   and oc.card_type_id = ct.card_type_id
                   and ci.start_date <= i_end_date
                   and ci.expir_date >= i_end_date
                   and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
                   and oc.id = cn.card_id
                   and substr(cn.card_number, 1, 9) in (select visa_bin from qpr_detail_visa_bin where product_id in ('R', 'E'))
                   and ao.object_id = oc.id
                   and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           )t
         group by t.cmid
                , t.inst_id
    )
    select c.cmid cmid
         , c.month_number
         , c.group_name
         , 'Total Number of Proprietary Plus Cards' as param_name
         , c.inst_id
         , c.cnt_all
      from cards c
     union all
    select a.cmid cmid
         , a.month_number
         , a.group_name
         , 'Total Number of Proprietary Plus Accounts' as param_name
         , a.inst_id
         , a.cnt_all
      from accounts a;

    -- Acquiring Cross Border
    cursor cu_data_group_18_1(
        i_dest_curr             in com_api_type_pkg.t_curr_code
      , i_del_value             in com_api_type_pkg.t_short_id
      , i_start_date            in date
      , i_end_date              in date
      , i_standard_id           in com_api_type_pkg.t_tiny_id
      , i_network_id            in com_api_type_pkg.t_short_id
      , i_rate_type             in com_api_type_pkg.t_dict_value
      , i_host_id               in com_api_type_pkg.t_tiny_id
      , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as (
        select m.inst_id
             , max(v.param_value) cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.CMID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
         group by m.inst_id
    )
    select t.cmid
         , '264.Cross Border Data' as group_name
         , decode(t.param_name, 'Sales', 'Merchant Sales'
                              , 'ATM Cash', 'Acquired Cash Transactions (ATM)'
                              , 'Manual Cash' , 'Acquired Cash Transactions (Manual)') as param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , decode(upper(t.param_name), 'REFUNDS', -1, 1) * sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
         , t.merchant_country as value_3
      from (select m.cmid
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                   as param_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
                 , o.merchant_country
              from qpr_aggr o
                 , cmid m
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   ) in ('Sales', 'ATM Cash', 'Manual Cash')
               and o.oper_date between i_start_date and i_end_date
          group by m.cmid
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 49
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_ACQ_OPER_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type
                   )
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
                 , o.merchant_country
           ) t
    group by t.cmid
           , t.param_name
           , t.inst_id
           , t.merchant_country
    order by t.cmid
           , t.merchant_country
           , t.param_name;

    -- Cross Border Locations
    cursor cu_data_group_18_2(
        i_start_date            in date
      , i_end_date              in date
      , i_standard_id           in com_api_type_pkg.t_tiny_id
      , i_host_id               in com_api_type_pkg.t_tiny_id
      , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with
    cmid as (
        select m.inst_id
             , max(v.param_value) cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
	group by m.inst_id
    ),
    assoc as (
        select t.cmid
             , t.inst_id
             , t.country
             , count(1) as cnt_all
          from (select distinct
                       m.cmid
                     , cao.id
                     , m.inst_id
                     , com_api_country_pkg.get_country_code(
                           i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                         , i_object_id         => acq.id
                       ) as country
                  from acq_merchant acq
                     , acq_merchant acq2
                     , cmid m
                     , acq_terminal trm
                     , com_address_object cao
                 where acq2.parent_id(+) = acq.id
                   and acq2.id is null
                   and trm.merchant_id   = acq.id
                   and trm.is_template   = 0
                   and trm.inst_id       = acq.inst_id
                   and acq.inst_id       = m.inst_id
                   and nvl(trm.mcc, acq.mcc) = vis_api_const_pkg.MCC_CASH
                   and trm.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                   and trm.status        = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and cao.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and cao.address_type  = com_api_const_pkg.ADDRESS_TYPE_BUSINESS
                   and cao.object_id     = acq.id
                   /*and (exists (select 1 from ost_institution i
                                where i.id = m.inst_id
                                  and i.parent_id is not null)
                        or
                        exists (select 1 from ost_institution i
                                  where i.parent_id = m.inst_id))*/
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date
                ) t
         group by t.cmid
                , t.inst_id
                , t.country
    ),
    atm as (
        select t.cmid
             , t.inst_id
             , t.country
             , count(1) as cnt_all
          from (select distinct
                       m.cmid
                     , acq.id
                     , trm.id terminal_id
                     , m.inst_id
                     , trm.terminal_type
                     , com_api_country_pkg.get_country_code(
                           i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                         , i_object_id         => trm.id
                       ) as country
                  from acq_terminal trm
                     , acq_merchant acq
                     , cmid m
                 where trm.merchant_id    = acq.id
                   and trm.is_template    = 0
                   and trm.inst_id        = acq.inst_id
                   and acq.inst_id        = m.inst_id
                   and nvl(trm.mcc, acq.mcc) = vis_api_const_pkg.MCC_ATM
                   and trm.status         = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
                   and trm.card_data_input_cap != 'F2210001'
                   /*and (exists (select 1 from ost_institution i
                                where i.id = m.inst_id
                                  and i.parent_id is not null)
                        or
                        exists (select 1 from ost_institution i
                                  where i.parent_id = m.inst_id))     */
                   and (select min(pso.start_date)
                                  from prd_service_object pso
                                 where pso.object_id = acq.id
                                   and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                               ) <= i_end_date
                ) t
         group by t.cmid
                , t.inst_id
                , t.country
    )
    select ac.cmid cmid
         , '265.Cross Border Locations'            as group_name
         , 'Number of Cash Disbursement Locations' as param_name
         , ac.inst_id
         , ac.cnt_all                              as value_1
         , am.cnt_all                              as value_2
         , ac.country                              as value_3
      from assoc ac
         , atm am
     where ac.inst_id = am.inst_id
       and ac.cmid = am.cmid
       and ac.country = am.country;

    -- Cross Border Outlets
    cursor cu_data_group_18_3(
        i_start_date            in date
      , i_end_date              in date
      , i_standard_id           in com_api_type_pkg.t_tiny_id
      , i_host_id               in com_api_type_pkg.t_tiny_id
      , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with
    cmid as (
        select m.inst_id
             , max(v.param_value) cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
        where p.name = vis_api_const_pkg.CMID
          and p.standard_id = i_standard_id
          and p.id = v.param_id
          and m.id = v.consumer_member_id
          and v.host_member_id = i_host_id
          and (m.inst_id = i_inst_id or i_inst_id is null)
	group by m.inst_id
    ),
    outlet as (
        select t.cmid
             , t.inst_id
             , t.country as country
             , count(1)  as cnt_all
             , sum(case when t.input_cap in ('0','2','B','C','D','M') then 1 else 0 end) as cnt_electron
          from (select distinct
                       m.cmid
                     , acq.id
                     , com_api_address_pkg.get_address_string(nvl(aot.address_id, aom.address_id)) address_name
                     , m.inst_id
                     , substr(trm.card_data_input_cap, -1) as input_cap
                     , trm.terminal_type
                     , com_api_country_pkg.get_country_code(
                           i_entity_type       => nvl2(aot.id, acq_api_const_pkg.ENTITY_TYPE_TERMINAL, acq_api_const_pkg.ENTITY_TYPE_MERCHANT)
                         , i_object_id         => nvl2(aot.id, trm.id, acq.id)
                       ) as country
                  from acq_merchant acq
                     , acq_merchant acq2
                     , cmid m
                     , acq_terminal trm
                     , com_address_object aot
                     , com_address_object aom
                 where acq2.parent_id(+) = acq.id
                   and acq2.id is null
                   and trm.merchant_id = acq.id
                   and trm.id = aot.object_id(+)
                   and aot.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                   and acq.id = aom.object_id(+)
                   and aom.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and acq.inst_id = m.inst_id
                   and acq.mcc not in (vis_api_const_pkg.MCC_ATM, vis_api_const_pkg.MCC_CASH)
                   and acq.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
                   and trm.card_data_input_cap != 'F2210001'
                   and (select min(pso.start_date)
                          from prd_service_object pso
                         where pso.object_id = acq.id
                           and pso.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       ) <= i_end_date ) t
         group by t.cmid
                , t.inst_id
                , t.country
    )
    select o.cmid cmid
         , '266.Cross Border Outlets'   as group_name
         , 'Number of Merchant Outlets' as param_name
         , o.inst_id
         , o.cnt_all                    as value_1
         , o.cnt_electron               as value_2
         , o.country                    as value_3
      from outlet o;

    --  Acquiring grouped by BAI
    cursor cu_data_group_19(
        i_dest_curr             in com_api_type_pkg.t_curr_code
      , i_del_value             in com_api_type_pkg.t_short_id
      , i_start_date            in date
      , i_end_date              in date
      , i_standard_id           in com_api_type_pkg.t_tiny_id
      , i_network_id            in com_api_type_pkg.t_short_id
      , i_rate_type             in com_api_type_pkg.t_dict_value
      , i_host_id               in com_api_type_pkg.t_tiny_id
      , i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    with cmid as(
        select distinct
               m.inst_id inst_id
             , v.param_value cmid
          from cmn_parameter p
             , net_api_interface_param_val_vw v
             , net_member m
         where p.name = vis_api_const_pkg.ACQ_BUSINESS_ID
           and p.standard_id = i_standard_id
           and p.id = v.param_id
           and m.id = v.consumer_member_id
           and v.host_member_id = i_host_id
           and (m.inst_id = i_inst_id or i_inst_id is null)
    )
    select t.cmid
         , t.month_number
         , group_name group_name
         , t.param_name
         , t.inst_id
         , sum(t.nn_trans) value_1
         , sum(decode(
                  t.oper_currency
                , i_dest_curr
                , t.oper_amount
                , com_api_rate_pkg.convert_amount (
                      t.oper_amount
                    , t.oper_currency
                    , i_dest_curr
                    , i_rate_type
                    , t.inst_id
                    , t.oper_date
                    , 1
                    , null
                  )
               ) / i_del_value
           ) value_2
         , t.regional value_4
      from (select m.cmid
                 , to_number(to_char(o.oper_date, 'mm')) month_number
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 744
                     , i_array_type_id     => vis_api_const_pkg.QR_BAI_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_BAI_REPORT_PARAMS_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type||'/'||o.business_application_id
                   ) as param_name
                 , '267.Acquirer Data by BAI'
                   as group_name
                 , o.card_inst_id inst_id
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.cnt ) nn_trans
                 , o.currency oper_currency
                 , sum(decode(o.is_reversal, 1, -1, 1) * o.amount) oper_amount
                 , o.oper_date
                 , case when o.merchant_country = o.card_country
                        then 'On Us'
                        when nvl(ci.visa_region,'X') = nvl(ca.visa_region,'Y')
                        then 'Intra'
                        else 'Inter'
                   end as regional
              from qpr_aggr o
                 , cmid m
                 , com_country ca
                 , com_country ci
             where o.is_acq = 1
               and o.card_inst_id = m.inst_id
               and o.card_network_id = i_network_id
               and o.status in (select element_value
                                  from com_array_element
                                 where array_id = qpr_api_const_pkg.ARRAY_ID_OPER_STATUS)
               and o.oper_date between i_start_date and i_end_date
               and com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130
                     , i_array_type_id     => vis_api_const_pkg.QR_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_CARD_TYPE_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.card_type_id
                   ) != vis_api_const_pkg.QR_V_PAY_CARD_TYPE
               and o.oper_type in (select element_value from com_array_element where array_id = 10000122)
               and o.card_country = ci.code(+)
               and o.merchant_country = ca.code(+)
          group by m.cmid
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 744
                     , i_array_type_id     => vis_api_const_pkg.QR_BAI_ARRAY_TYPE
                     , i_array_id          => vis_api_const_pkg.QR_BAI_REPORT_PARAMS_ARRAY
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => o.oper_type||'/'||o.business_application_id
                   )
                 , to_number(to_char(o.oper_date, 'mm'))
                 , o.card_inst_id
                 , o.currency
                 , o.oper_date
                 , case when o.merchant_country = o.card_country
                        then 'On Us'
                        when nvl(ci.visa_region,'X') = nvl(ca.visa_region,'Y')
                        then 'Intra'
                        else 'Inter'
                   end
           ) t
     group by t.cmid
            , t.month_number
            , t.param_name
            , t.group_name
            , t.inst_id
            , t.regional
     order by t.cmid
            , t.month_number
            , t.param_name;

    function estimate_messages_for_visa (
        i_report_name           in com_api_type_pkg.t_name := null
    ) return com_api_type_pkg.t_long_id is
    begin
        return
            case i_report_name
            when vis_api_const_pkg.QUARTER_REPORT_CASH_ACQUIRING  then 1
            when vis_api_const_pkg.QUARTER_REPORT_MRC_ACQUIRING   then 1
            when vis_api_const_pkg.QUARTER_REPORT_MRC_CATEGORY    then 1
            when vis_api_const_pkg.QUARTER_REPORT_CO_BRAND        then 1
            when vis_api_const_pkg.QUARTER_REPORT_SCHEDULE_F      then 1
            when vis_api_const_pkg.QUARTER_REPORT_MONTHLY_ISSUING then 1
            when vis_api_const_pkg.QUARTER_REPORT_SCHEDULE_A_E    then 1
            when vis_api_const_pkg.QUARTER_REPORT_V_PAY_ACQUIRING then 1
            when vis_api_const_pkg.QUARTER_REPORT_CONTACTLESS     then 1
            when vis_api_const_pkg.QUARTER_REPORT_ECOMMERCE       then 1
            when vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_ATM   then 1
            when vis_api_const_pkg.QUARTER_REPORT_ACQUIRING       then 1
            when vis_api_const_pkg.QUARTER_REPORT_MOTO_RECURRING  then 1
            when vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_VMT   then 1
            when vis_api_const_pkg.QUARTER_REPORT_CEMEA           then 1
            when vis_api_const_pkg.QUARTER_REPORT_CROSS_BORDER    then 1
            when vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_BAI   then 1
            else
                11
            end;
    end;

    procedure qpr_visa_data (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_year                  in com_api_type_pkg.t_tiny_id
        , i_quarter               in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_tiny_id
        , i_report_code           in com_api_type_pkg.t_dict_value-- := null
        , i_rate_type             in com_api_type_pkg.t_dict_value default vis_api_const_pkg.VISA_RATE_TYPE
        , i_inst_id               in com_api_type_pkg.t_inst_id    default null
        , i_host_inst_id          in com_api_type_pkg.t_inst_id    default null
    ) is
        l_del_value               com_api_type_pkg.t_tiny_id;
        l_start_date              date;
        l_end_date                date;

        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_standard_id             com_api_type_pkg.t_tiny_id;

        l_excepted_count          com_api_type_pkg.t_long_id := 0;
        l_processed_count         com_api_type_pkg.t_long_id := 0;
        l_estimated_count         com_api_type_pkg.t_long_id := 0;
        l_count                   com_api_type_pkg.t_long_id := 0;

        l_group_name              com_api_type_pkg.t_name_tab;
        l_param_name              com_api_type_pkg.t_name_tab;
        l_month_number            com_api_type_pkg.t_integer_tab;
        l_cmid                    com_api_type_pkg.t_cmid_tab;
        l_inst_id                 com_api_type_pkg.t_inst_id_tab;
        l_card_type               com_api_type_pkg.t_name_tab;
        l_bin                     com_api_type_pkg.t_name_tab;

        l_value_1                 com_api_type_pkg.t_money_tab;
        l_value_2                 com_api_type_pkg.t_money_tab;
        l_value_3                 com_api_type_pkg.t_money_tab;

        l_report_name             com_api_type_pkg.t_name := case when i_report_code = vis_api_const_pkg.QR_CODE_ACQ_VOLUMES     then vis_api_const_pkg.QUARTER_REPORT_CASH_ACQUIRING
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_MRC_CATEGORY    then vis_api_const_pkg.QUARTER_REPORT_MRC_CATEGORY
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_MRC_INFORM      then vis_api_const_pkg.QUARTER_REPORT_MRC_ACQUIRING
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_CO_BRAND        then vis_api_const_pkg.QUARTER_REPORT_CO_BRAND
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_SCHEDULE_F      then vis_api_const_pkg.QUARTER_REPORT_SCHEDULE_F
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_SCHEDULE_A_E    then vis_api_const_pkg.QUARTER_REPORT_SCHEDULE_A_E
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_MONTHLY_ISSUING then vis_api_const_pkg.QUARTER_REPORT_MONTHLY_ISSUING
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_CARD_ISSUANCE   then vis_api_const_pkg.QUARTER_REPORT_CARD_ISSUANCE
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_V_PAY           then vis_api_const_pkg.QUARTER_REPORT_V_PAY_ACQUIRING
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_CONTACTLESS     then vis_api_const_pkg.QUARTER_REPORT_CONTACTLESS
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_ECOMMERCE       then vis_api_const_pkg.QUARTER_REPORT_ECOMMERCE
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_ACQUIRING_ATM   then vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_ATM
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_ACQUIRING       then vis_api_const_pkg.QUARTER_REPORT_ACQUIRING
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_MOTO_RECURRING  then vis_api_const_pkg.QUARTER_REPORT_MOTO_RECURRING
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_ACQUIRING_VMT   then vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_VMT
                                                                  when i_report_code = vis_api_const_pkg.QR_CODE_CEMEA           then vis_api_const_pkg.QUARTER_REPORT_CEMEA
                                                                else null end;
    begin
        savepoint qpr_start_prepare;

        prc_api_stat_pkg.log_start;

        if i_host_inst_id is null then
            l_host_id := net_api_network_pkg.get_default_host(i_network_id);
        else
            l_host_id := net_api_network_pkg.get_default_host (
                            i_network_id     => i_network_id
                            , i_host_inst_id => i_host_inst_id
                         );
        end if;
        l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

        l_start_date :=
            add_months(
                to_date(
                    '01' || lpad(i_quarter * 3, 2, '0') || to_char(i_year)
                  , 'ddmmyyyy'
                )
              , -2
            );
        l_end_date := add_months(l_start_date, 3) - com_api_const_pkg.ONE_SECOND;
        l_del_value :=
            power(
                10
              , nvl(
                    com_api_currency_pkg.get_currency_exponent(i_dest_curr)
                  , 0
                )
            );

        qpr_api_util_pkg.clear_values;

        l_estimated_count := estimate_messages_for_visa (
            i_report_name  => l_report_name
        );

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_CASH_ACQUIRING) in (vis_api_const_pkg.QUARTER_REPORT_CASH_ACQUIRING) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_CASH_ACQUIRING
                , i_inst_id      => i_inst_id
            );

            open cu_data_group_1 (
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
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
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    l_count := 1;
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_CASH_ACQUIRING
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_1%notfound;
            end loop;
            close cu_data_group_1;

            open cu_data_group_1_1 (
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop

                fetch cu_data_group_1_1
                bulk collect into
                l_cmid
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => i_quarter * 3 - 2
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_CASH_ACQUIRING
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_1_1%notfound;
            end loop;
            close cu_data_group_1_1;

            l_processed_count := l_processed_count + l_count;
            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
                , i_excepted_count  => l_excepted_count
            );
        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_MRC_ACQUIRING) in (vis_api_const_pkg.QUARTER_REPORT_MRC_ACQUIRING) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_MRC_ACQUIRING
                , i_inst_id      => i_inst_id
            );
            l_count := 0;
            open cu_data_group_1_2 (
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_1_2
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
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_MRC_ACQUIRING
                    );

                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_1_2%notfound;
            end loop;
            close cu_data_group_1_2;

            l_processed_count := l_processed_count + l_count;
            prc_api_stat_pkg.log_current(
                i_current_count   => l_processed_count
              , i_excepted_count  => l_excepted_count
            );
        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_MRC_CATEGORY) in (vis_api_const_pkg.QUARTER_REPORT_MRC_CATEGORY) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => 'PS_VISA_MRC_MCC'
                , i_inst_id      => i_inst_id
            );
            l_count := 0;
            open cu_data_group_2_1 (
                i_start_date     => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_2_1
                bulk collect into
                l_cmid
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    l_count := 1;
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => i_quarter * 3 - 2
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_VISA_MRC_MCC'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_2_1%notfound;
            end loop;
            close cu_data_group_2_1;

            open cu_data_group_2_2 (
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_2_2
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
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_VISA_MRC_MCC'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_2_2%notfound;
            end loop;
            close cu_data_group_2_2;

            l_processed_count := l_processed_count + l_count;
            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
                , i_excepted_count  => l_excepted_count
            );
        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_MRC_CATEGORY) in (vis_api_const_pkg.QUARTER_REPORT_MRC_CATEGORY) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => 'PS_RU_VISA_MRC_MCC'
                , i_inst_id      => i_inst_id
            );
            l_count := 0;
            open cu_data_group_2_1_ru (
                i_start_date     => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_2_1_ru
                bulk collect into
                l_cmid
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    l_count := 1;
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => i_quarter * 3 - 2
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_RU_VISA_MRC_MCC'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_2_1_ru%notfound;
            end loop;
            close cu_data_group_2_1_ru;

            open cu_data_group_2_2_ru (
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_2_2_ru
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
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_RU_VISA_MRC_MCC'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_2_2_ru%notfound;
            end loop;
            close cu_data_group_2_2_ru;

            l_processed_count := l_processed_count + l_count;
            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
                , i_excepted_count  => l_excepted_count
            );
        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_CO_BRAND) in (vis_api_const_pkg.QUARTER_REPORT_CO_BRAND) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => 'PS_VISA_CO_BRAND'
                , i_inst_id      => i_inst_id
            );
            l_count := 0;
            open cu_data_group_3 (
                i_quarter        => i_quarter
                , i_dest_curr    => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_network_id   => i_network_id
                , i_standard_id  => l_standard_id
                , i_host_id      => l_host_id
                , i_rate_type    => i_rate_type
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_3
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
                , l_bin
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    l_count := 1;
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_value_3      => l_value_3(i)
                        , i_curr_code    => i_dest_curr
                        , i_card_type    => l_card_type(i)
                        , i_bin          => l_bin(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_VISA_CO_BRAND'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_3%notfound;
            end loop;
            close cu_data_group_3;

            l_processed_count := l_processed_count + l_count;
            prc_api_stat_pkg.log_current(
                i_current_count   => l_processed_count
              , i_excepted_count  => l_excepted_count
            );
        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_SCHEDULE_F) in (vis_api_const_pkg.QUARTER_REPORT_SCHEDULE_F) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_SCHEDULE_F
                , i_inst_id      => i_inst_id
            );
            open cu_data_group_4 (
                i_quarter        => i_quarter
                , i_dest_curr    => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_network_id   => i_network_id
                , i_standard_id  => l_standard_id
                , i_host_id      => l_host_id
                , i_rate_type    => i_rate_type
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_4
                bulk collect into
                l_cmid
                , l_inst_id
                , l_month_number
                , l_group_name
                , l_param_name
                , l_value_1
                , l_value_2
                , l_value_3
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_value_3      => l_value_3(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_Id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_SCHEDULE_F
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_4%notfound;
            end loop;
            close cu_data_group_4;

        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_MONTHLY_ISSUING) in (vis_api_const_pkg.QUARTER_REPORT_MONTHLY_ISSUING) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => 'PS_VISA_ISSUING'
                , i_inst_id      => i_inst_id
            );
            l_count := 0;
            open cu_data_group_5 (
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
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
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    l_count := 1;
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_curr_code    => i_dest_curr
                        , i_card_type    => l_card_type(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_VISA_ISSUING'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_5%notfound;
            end loop;
            close cu_data_group_5;

            open cu_data_group_5_total (
                i_start_date     => l_start_date
                , i_standard_id  => l_standard_id
                , i_host_id      => l_host_id
                , i_network_id   => i_network_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_5_total
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_card_type
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_card_type    => l_card_type(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_VISA_ISSUING'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_5_total%notfound;
            end loop;
            close cu_data_group_5_total;

            open cu_data_group_6_1 (
                i_quarter        => i_quarter
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_6_1
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_card_type
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_card_type    => l_card_type(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_VISA_ISSUING'
                    );

                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_6_1%notfound;
            end loop;
            close cu_data_group_6_1;

            open cu_data_group_6_1_1 (
                i_quarter        => i_quarter
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_6_1_1
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_card_type
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_card_type    => l_card_type(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_VISA_ISSUING'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_6_1_1%notfound;
            end loop;
            close cu_data_group_6_1_1;

            open cu_data_group_6_1_2 (
                i_quarter        => i_quarter
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_6_1_2
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_card_type
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_card_type    => l_card_type(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_VISA_ISSUING'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_6_1_2%notfound;
            end loop;
            close cu_data_group_6_1_2;

            open cu_data_group_6_2 (
                i_quarter        => i_quarter
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_6_2
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_card_type
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_card_type    => l_card_type(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_VISA_ISSUING'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_6_2%notfound;
            end loop;
            close cu_data_group_6_2;

            open cu_data_group_6_3 (
                i_quarter        => i_quarter
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_6_3
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_card_type
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_card_type    => l_card_type(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_VISA_ISSUING'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_6_3%notfound;
            end loop;
            close cu_data_group_6_3;

            l_processed_count := l_processed_count + l_count;
            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
                , i_excepted_count  => l_excepted_count
            );
        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_SCHEDULE_A_E) in (vis_api_const_pkg.QUARTER_REPORT_SCHEDULE_A_E) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_SCHEDULE_A_E
                , i_inst_id      => i_inst_id
            );
            open cu_data_group_7 (
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_network_id   => i_network_id
                , i_standard_id  => l_standard_id
                , i_host_id      => l_host_id
                , i_rate_type    => i_rate_type
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_7
                bulk collect into
                l_cmid
                , l_inst_id
                , l_group_name
                , l_param_name
                , l_month_number
                , l_card_type
                , l_bin
                , l_value_1
                , l_value_2
                , l_value_3
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_value_3      => l_value_3(i)
                        , i_curr_code    => i_dest_curr
                        , i_card_type    => l_card_type(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_bin          => l_bin(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_SCHEDULE_A_E
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_7%notfound;
            end loop;
            close cu_data_group_7;

        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_V_PAY_ACQUIRING) in (vis_api_const_pkg.QUARTER_REPORT_V_PAY_ACQUIRING) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_V_PAY_ACQUIRING
                , i_inst_id      => i_inst_id
            );
            open cu_data_group_8 (
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_network_id   => i_network_id
                , i_standard_id  => l_standard_id
                , i_host_id      => l_host_id
                , i_rate_type    => i_rate_type
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_8
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
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_V_PAY_ACQUIRING
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_8%notfound;
            end loop;
            close cu_data_group_8;

            open cu_data_group_8_1 (
                i_quarter        => i_quarter
                , i_dest_curr    => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_network_id   => i_network_id
                , i_standard_id  => l_standard_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_8_1
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
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_V_PAY_ACQUIRING
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_8_1%notfound;
            end loop;
            close cu_data_group_8_1;

            open cu_data_group_8_2 (
                i_start_date     => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_8_2
                bulk collect into
                l_cmid
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => i_quarter * 3 - 2
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_V_PAY_ACQUIRING
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_8_2%notfound;
            end loop;
            close cu_data_group_8_2;

        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_CONTACTLESS) in (vis_api_const_pkg.QUARTER_REPORT_CONTACTLESS) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_CONTACTLESS
                , i_inst_id      => i_inst_id
            );
            open cu_data_group_9 (
                i_quarter        => i_quarter
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_9
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_CONTACTLESS
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_9%notfound;
            end loop;
            close cu_data_group_9;

            open cu_data_group_9_1 (
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_9_1
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
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_value_3      => l_value_3(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_CONTACTLESS
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_9_1%notfound;
            end loop;
            close cu_data_group_9_1;

        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_ECOMMERCE) in (vis_api_const_pkg.QUARTER_REPORT_ECOMMERCE) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_ECOMMERCE
                , i_inst_id      => i_inst_id
            );
            open cu_data_group_10 (
                i_quarter        => i_quarter
                , i_dest_curr    => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_10
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
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_ECOMMERCE
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_10%notfound;
            end loop;
            close cu_data_group_10;

            open cu_data_group_10_1 (
                i_start_date     => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_10_1
                bulk collect into
                l_cmid
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => i_quarter * 3 - 2
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_ECOMMERCE
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_10_1%notfound;
            end loop;
            close cu_data_group_10_1;

        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_ATM) in (vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_ATM) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_ATM
                , i_inst_id      => i_inst_id
            );
            open cu_data_group_12 (
                i_quarter        => i_quarter
                , i_dest_curr    => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_12
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
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_ATM
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_12%notfound;
            end loop;
            close cu_data_group_12;

        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_ACQUIRING) in (vis_api_const_pkg.QUARTER_REPORT_ACQUIRING) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_ACQUIRING
                , i_inst_id      => i_inst_id
            );
            open cu_data_group_13 (
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_13
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_value_2
                , l_value_3
                , l_bin
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_value_3      => l_value_3(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_bin          => l_bin(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_ACQUIRING
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_13%notfound;
            end loop;
            close cu_data_group_13;

        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_MOTO_RECURRING) in (vis_api_const_pkg.QUARTER_REPORT_MOTO_RECURRING) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_MOTO_RECURRING
                , i_inst_id      => i_inst_id
            );
            open cu_data_group_14 (
                i_start_date     => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_14
                bulk collect into
                l_cmid
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => i_quarter * 3 - 2
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_MOTO_RECURRING
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_14%notfound;
            end loop;
            close cu_data_group_14;

            open cu_data_group_14_1 (
                i_quarter        => i_quarter
                , i_dest_curr    => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_14_1
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
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_MOTO_RECURRING
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_14_1%notfound;
            end loop;
            close cu_data_group_14_1;

            open cu_data_group_15 (
                i_quarter        => i_quarter
                , i_dest_curr    => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_15
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
                    qpr_api_util_pkg.insert_param (
                        i_param_name     => l_param_name(i)
                        , i_group_name   => l_group_name(i)
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_MOTO_RECURRING
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_15%notfound;
            end loop;
            close cu_data_group_15;

        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_VMT) = vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_VMT then

            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_VMT
                , i_inst_id      => i_inst_id
            );

            open cu_data_group_16 (
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_16
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

                    qpr_api_util_pkg.insert_param (
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_2      => l_value_2(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_VMT
                    );
                end loop;

                qpr_api_util_pkg.save_values;

                exit when cu_data_group_16%notfound;
            end loop;
            close cu_data_group_16;
        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_CEMEA) in (vis_api_const_pkg.QUARTER_REPORT_CEMEA) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_report_type  => 2
                , i_report_name  => 'PS_CEMEA_VISA_ACQUIRING'
                , i_inst_id      => i_inst_id
            );
            l_count := 0;

            open cu_data_group_17_3_1(
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_17_3_1
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_card_type
                , l_inst_id
                , l_value_1
                , l_value_3
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_value_3      => l_value_3(i)
                        , i_curr_code    => i_dest_curr
                        , i_card_type    => l_card_type(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_CEMEA_VISA_ISSUING_DB'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_17_3_1%notfound;
            end loop;
            close cu_data_group_17_3_1;

            open cu_data_group_17_3_2(
                i_quarter      => i_quarter
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_host_id      => l_host_id
                , i_network_id   => i_network_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_17_3_2
                bulk collect into
                l_cmid
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_card_type
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => i_quarter * 3 - 2
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_card_type    => l_card_type(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_CEMEA_VISA_ISSUING_DB'
                    );
                end loop;

                qpr_api_util_pkg.save_values;

                exit when cu_data_group_17_3_2%notfound;
            end loop;
            close cu_data_group_17_3_2;

            open cu_data_group_17_5_1(
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_17_5_1
                bulk collect into
                l_cmid
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => i_quarter * 3 - 2
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_CEMEA_VISA_ACQUIRING'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_17_5_1%notfound;
            end loop;
            close cu_data_group_17_5_1;

            open cu_data_group_17_5_2(
                i_start_date     => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_17_5_2
                bulk collect into
                l_cmid
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    l_count := 1;
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => i_quarter * 3 - 2
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_CEMEA_VISA_ACQUIRING'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_17_5_2%notfound;
            end loop;
            close cu_data_group_17_5_2;

            open cu_data_group_17_5_3(
                i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_17_5_3
                bulk collect into
                l_cmid
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => i_quarter * 3 - 2
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_CEMEA_VISA_ACQUIRING'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_17_5_3%notfound;
            end loop;
            close cu_data_group_17_5_3;

            open cu_data_group_17_6_1(
                i_quarter      => i_quarter
                , i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_17_6_1
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_CEMEA_VISA_ASSOCIATE'
                    );
                end loop;

                qpr_api_util_pkg.save_values;

                exit when cu_data_group_17_6_1%notfound;
            end loop;
            close cu_data_group_17_6_1;

            open cu_data_group_17_6_2(
                i_quarter      => i_quarter
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_17_6_2
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_CEMEA_VISA_ASSOCIATE'
                    );
                end loop;

                qpr_api_util_pkg.save_values;

                exit when cu_data_group_17_6_2%notfound;
            end loop;
            close cu_data_group_17_6_2;

            open cu_data_group_17_7_1(
                i_quarter      => i_quarter
                , i_dest_curr      => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_17_7_1
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_bin
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_bin          => l_bin(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_CEMEA_VISA_BIN_PROGRAM'
                    );
                end loop;

                qpr_api_util_pkg.save_values;

                exit when cu_data_group_17_7_1%notfound;
            end loop;
            close cu_data_group_17_7_1;

            open cu_data_group_17_7_2(
                i_quarter      => i_quarter
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_17_7_2
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                , l_bin
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_bin          => l_bin(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_CEMEA_VISA_BIN_PROGRAM'
                    );
                end loop;

                qpr_api_util_pkg.save_values;

                exit when cu_data_group_17_7_2%notfound;
            end loop;
            close cu_data_group_17_7_2;

            open cu_data_group_17_8_1(
                i_quarter      => i_quarter
                , i_dest_curr    => i_dest_curr
                , i_del_value    => l_del_value
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_rate_type    => i_rate_type
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_17_8_1
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_curr_code    => i_dest_curr
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_CEMEA_VISA_PLUS'
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_17_8_1%notfound;
            end loop;
            close cu_data_group_17_8_1;

            open cu_data_group_17_8_2 (
                i_quarter      => i_quarter
                , i_start_date   => l_start_date
                , i_end_date     => l_end_date
                , i_standard_id  => l_standard_id
                , i_network_id   => i_network_id
                , i_host_id      => l_host_id
                , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_17_8_2
                bulk collect into
                l_cmid
                , l_month_number
                , l_group_name
                , l_param_name
                , l_inst_id
                , l_value_1
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name     => rtrim(l_param_name(i))
                        , i_group_name   => rtrim(l_group_name(i))
                        , i_year         => i_year
                        , i_month_num    => l_month_number(i)
                        , i_cmid         => l_cmid(i)
                        , i_value_1      => l_value_1(i)
                        , i_inst_id      => l_inst_id(i)
                        , i_report_name  => 'PS_CEMEA_VISA_PLUS'
                    );
                end loop;

                qpr_api_util_pkg.save_values;

                exit when cu_data_group_17_8_2%notfound;
            end loop;
            close cu_data_group_17_8_2;

            l_processed_count := l_processed_count + l_count;
            prc_api_stat_pkg.log_current(
                i_current_count   => l_processed_count
              , i_excepted_count  => l_excepted_count
            );
        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_CROSS_BORDER) in (vis_api_const_pkg.QUARTER_REPORT_CROSS_BORDER) then
            qpr_api_util_pkg.clear_table(
                i_year         => i_year
              , i_start_date   => l_start_date
              , i_end_date     => l_end_date
              , i_report_type  => 2
              , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_CROSS_BORDER
              , i_inst_id      => i_inst_id
            );

            open cu_data_group_18_1(
                i_dest_curr    => i_dest_curr
              , i_del_value    => l_del_value
              , i_start_date   => l_start_date
              , i_end_date     => l_end_date
              , i_standard_id  => l_standard_id
              , i_network_id   => i_network_id
              , i_rate_type    => i_rate_type
              , i_host_id      => l_host_id
              , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_18_1
                 bulk collect
                 into l_cmid
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
                        i_param_name   => rtrim(l_param_name(i))
                      , i_group_name   => rtrim(l_group_name(i))
                      , i_year         => i_year
                      , i_month_num    => i_quarter * 3 - 2
                      , i_cmid         => l_cmid(i)
                      , i_value_1      => l_value_1(i)
                      , i_value_2      => l_value_2(i)
                      , i_value_3      => l_value_3(i)
                      , i_curr_code    => i_dest_curr
                      , i_inst_id      => l_inst_id(i)
                      , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_CROSS_BORDER
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_18_1%notfound;
            end loop;
            close cu_data_group_18_1;

            open cu_data_group_18_2(
                i_start_date   => l_start_date
              , i_end_date     => l_end_date
              , i_standard_id  => l_standard_id
              , i_host_id      => l_host_id
              , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_18_2
                 bulk collect
                 into l_cmid
                    , l_group_name
                    , l_param_name
                    , l_inst_id
                    , l_value_1
                    , l_value_2
                    , l_value_3
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name   => rtrim(l_param_name(i))
                      , i_group_name   => rtrim(l_group_name(i))
                      , i_year         => i_year
                      , i_month_num    => i_quarter * 3 - 2
                      , i_cmid         => l_cmid(i)
                      , i_value_1      => l_value_1(i)
                      , i_value_2      => l_value_2(i)
                      , i_value_3      => l_value_3(i)
                      , i_curr_code    => i_dest_curr
                      , i_inst_id      => l_inst_id(i)
                      , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_CROSS_BORDER
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_18_2%notfound;
            end loop;
            close cu_data_group_18_2;

            open cu_data_group_18_3(
                i_start_date   => l_start_date
              , i_end_date     => l_end_date
              , i_standard_id  => l_standard_id
              , i_host_id      => l_host_id
              , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_18_3
                 bulk collect
                 into l_cmid
                    , l_group_name
                    , l_param_name
                    , l_inst_id
                    , l_value_1
                    , l_value_2
                    , l_value_3
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param(
                        i_param_name   => rtrim(l_param_name(i))
                      , i_group_name   => rtrim(l_group_name(i))
                      , i_year         => i_year
                      , i_month_num    => i_quarter * 3 - 2
                      , i_cmid         => l_cmid(i)
                      , i_value_1      => l_value_1(i)
                      , i_value_2      => l_value_2(i)
                      , i_value_3      => l_value_3(i)
                      , i_curr_code    => i_dest_curr
                      , i_inst_id      => l_inst_id(i)
                      , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_CROSS_BORDER
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_18_3%notfound;
            end loop;
            close cu_data_group_18_3;

            l_processed_count := l_processed_count + l_count;
            prc_api_stat_pkg.log_current(
                i_current_count   => l_processed_count
              , i_excepted_count  => l_excepted_count
            );
        end if;

        if nvl(l_report_name, vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_BAI) in (vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_BAI) then
            qpr_api_util_pkg.clear_table (
                i_year           => i_year
              , i_start_date   => l_start_date
              , i_end_date     => l_end_date
              , i_report_type  => 2
              , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_BAI
              , i_inst_id      => i_inst_id
            );
            open cu_data_group_19 (
                i_dest_curr      => i_dest_curr
              , i_del_value    => l_del_value
              , i_start_date   => l_start_date
              , i_end_date     => l_end_date
              , i_standard_id  => l_standard_id
              , i_network_id   => i_network_id
              , i_rate_type    => i_rate_type
              , i_host_id      => l_host_id
              , i_inst_id      => i_inst_id
            );
            loop
                fetch cu_data_group_19
                 bulk collect
                 into l_cmid
                    , l_month_number
                    , l_group_name
                    , l_param_name
                    , l_inst_id
                    , l_value_1
                    , l_value_2
                    , l_bin
                limit BULK_LIMIT;

                for i in 1..l_cmid.count loop
                    qpr_api_util_pkg.insert_param (
                        i_param_name   => l_param_name(i)
                      , i_group_name   => l_group_name(i)
                      , i_year         => i_year
                      , i_month_num    => l_month_number(i)
                      , i_cmid         => l_cmid(i)
                      , i_value_1      => l_value_1(i)
                      , i_value_2      => l_value_2(i)
                      , i_curr_code    => i_dest_curr
                      , i_inst_id      => l_inst_id(i)
                      , i_bin          => l_bin(i)
                      , i_report_name  => vis_api_const_pkg.QUARTER_REPORT_ACQUIRING_BAI
                    );
                end loop;
                qpr_api_util_pkg.save_values;

                exit when cu_data_group_19%notfound;
            end loop;
            close cu_data_group_19;

            l_processed_count := l_processed_count + l_count;
            prc_api_stat_pkg.log_current(
                i_current_count   => l_processed_count
              , i_excepted_count  => l_excepted_count
            );
        end if;

        qpr_api_util_pkg.save_values;

        prc_api_stat_pkg.log_end (
            i_processed_total   => l_processed_count
            , i_excepted_total  => l_excepted_count
            , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            rollback to savepoint qpr_start_prepare;

            if cu_data_group_19%isopen then
                close cu_data_group_19;
            end if;
            if cu_data_group_18_3%isopen then
                close cu_data_group_18_3;
            end if;
            if cu_data_group_18_2%isopen then
                close cu_data_group_18_2;
            end if;
            if cu_data_group_18_1%isopen then
                close cu_data_group_18_1;
            end if;
            if cu_data_group_17_8_2%isopen then
                close cu_data_group_17_8_2;
            end if;
            if cu_data_group_17_8_1%isopen then
                close cu_data_group_17_8_1;
            end if;
            if cu_data_group_17_7_2%isopen then
                close cu_data_group_17_7_2;
            end if;
            if cu_data_group_17_7_1%isopen then
                close cu_data_group_17_7_1;
            end if;
            if cu_data_group_17_6_2%isopen then
                close cu_data_group_17_6_2;
            end if;
            if cu_data_group_17_6_1%isopen then
                close cu_data_group_17_6_1;
            end if;
            if cu_data_group_17_5_3%isopen then
                close cu_data_group_17_5_3;
            end if;
            if cu_data_group_17_5_2%isopen then
                close cu_data_group_17_5_2;
            end if;
            if cu_data_group_17_5_1%isopen then
                close cu_data_group_17_5_1;
            end if;
            if cu_data_group_17_3_2%isopen then
                close cu_data_group_17_3_2;
            end if;
            if cu_data_group_17_3_1%isopen then
                close cu_data_group_17_3_1;
            end if;
            if cu_data_group_16%isopen then
                close cu_data_group_16;
            end if;
            if cu_data_group_15%isopen then
                close cu_data_group_15;
            end if;
            if cu_data_group_14_1%isopen then
                close cu_data_group_14_1;
            end if;
            if cu_data_group_14%isopen then
                close cu_data_group_14;
            end if;
            if cu_data_group_13%isopen then
                close cu_data_group_13;
            end if;
            if cu_data_group_12%isopen then
                close cu_data_group_12;
            end if;
            if cu_data_group_10_1%isopen then
                close cu_data_group_10_1;
            end if;
            if cu_data_group_10%isopen then
                close cu_data_group_10;
            end if;
            if cu_data_group_9_1%isopen then
                close cu_data_group_9_1;
            end if;
            if cu_data_group_9%isopen then
                close cu_data_group_9;
            end if;
            if cu_data_group_8_2%isopen then
                close cu_data_group_8_2;
            end if;
            if cu_data_group_8_1%isopen then
                close cu_data_group_8_1;
            end if;
            if cu_data_group_8%isopen then
                close cu_data_group_8;
            end if;
            if cu_data_group_7%isopen then
                close cu_data_group_7;
            end if;
            if cu_data_group_6_3%isopen then
                close cu_data_group_6_3;
            end if;
            if cu_data_group_6_2%isopen then
                close cu_data_group_6_2;
            end if;
            if cu_data_group_6_1_2%isopen then
                close cu_data_group_6_1_2;
            end if;
            if cu_data_group_6_1_1%isopen then
                close cu_data_group_6_1_1;
            end if;
            if cu_data_group_6_1%isopen then
                close cu_data_group_6_1;
            end if;
            if cu_data_group_5_total%isopen then
                close cu_data_group_5_total;
            end if;
            if cu_data_group_5%isopen then
                close cu_data_group_5;
            end if;
            if cu_data_group_4%isopen then
                close cu_data_group_4;
            end if;
            if cu_data_group_3%isopen then
                close cu_data_group_3;
            end if;
            if cu_data_group_2_2%isopen then
                close cu_data_group_2_2;
            end if;
            if cu_data_group_2_1%isopen then
                close cu_data_group_2_1;
            end if;
            if cu_data_group_2_2_ru%isopen then
                close cu_data_group_2_2_ru;
            end if;
            if cu_data_group_2_1_ru%isopen then
                close cu_data_group_2_1_ru;
            end if;
            if cu_data_group_1_2%isopen then
                close cu_data_group_1_2;
            end if;
            if cu_data_group_1_1%isopen then
                close cu_data_group_1_1;
            end if;
            if cu_data_group_1%isopen then
                close cu_data_group_1;
            end if;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;

            raise;
    end;

end;
/
