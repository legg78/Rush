create or replace package body itf_prc_account_export_pkg is
/************************************************************
 * API for process files <br />
 * Created by Kolodkina Y.(kolodkina@bpcbt.com)  at 22.12.2014 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-11-19 16:00:00 +0300#$ <br />
 * Revision: $LastChangedRevision: 60179 $ <br />
 * Module: itf_prc_account_export_pkg <br />
 * @headcom
 ***********************************************************/

CRLF                     constant  com_api_type_pkg.t_name    := chr(13)||chr(10);
FRONT_END_ACCOUNT_TYPES  constant com_api_type_pkg.t_short_id := 10000083;

/*
 * Process for unloading data for DBAL.
 * @param i_export_clear_pan  - if it is FALSE then process unloads undecoded
 *     PANs (tokens) for case when Message Bus is capable to handle them.
 */
procedure process_unload_turnover(
    i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_full_export               in     com_api_type_pkg.t_boolean        default null
  , i_unload_limits             in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_count                     in     com_api_type_pkg.t_medium_id      default null
  , i_array_balance_type_id     in     com_api_type_pkg.t_medium_id      default null
  , i_include_service           in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_lang                      in     com_api_type_pkg.t_dict_value     default null
  , i_export_clear_pan          in     com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_array_account_type        in     com_api_type_pkg.t_dict_value     default null
  , i_unload_payments           in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_replace_inst_id_by_number in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_unload_acquiring_accounts in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
) is
    BULK_LIMIT                     constant com_api_type_pkg.t_count := 2000;
    PAYMENT_OPERATION_LIMIT        constant com_api_type_pkg.t_count := 100;

    l_bulk_limit                   com_api_type_pkg.t_count          := nvl(i_count, BULK_LIMIT);
    l_estimated_count              com_api_type_pkg.t_long_id; 
    l_processed_count              com_api_type_pkg.t_count          := 0;
    l_file_count                   com_api_type_pkg.t_count          := 0;
    l_file                         clob;
    l_file_type                    com_api_type_pkg.t_dict_value;
    l_container_id                 com_api_type_pkg.t_long_id        :=  prc_api_session_pkg.get_container_id;

    l_full_export                  com_api_type_pkg.t_boolean;
    l_unload_limits                com_api_type_pkg.t_boolean;
    l_unload_payments              com_api_type_pkg.t_boolean;
    l_include_service              com_api_type_pkg.t_boolean;
    l_export_clear_pan             com_api_type_pkg.t_boolean;
    l_params                       com_api_type_pkg.t_param_tab;

    l_fetched_event_object_id_tab  com_api_type_pkg.t_number_tab;
    l_fetched_account_id_tab       num_tab_tpt                       := num_tab_tpt();
    l_fetched_split_hash_tab       com_api_type_pkg.t_number_tab;
    l_fetched_oper_id_tab          num_tab_tpt                       := num_tab_tpt();
    l_oper_count                   com_api_type_pkg.t_long_id;

    l_event_object_id_tab          com_api_type_pkg.t_number_tab;
    l_account_id_tab               num_tab_tpt                       := num_tab_tpt();
    l_oper_id_tab                  num_tab_tpt                       := num_tab_tpt();
    l_event_oper_id_tab            num_tab_tpt                       := num_tab_tpt();
    l_service_id_tab               prd_service_tpt                   := prd_service_tpt();

    l_account_id                   com_api_type_pkg.t_medium_id;
    l_sysdate                      date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_masking_card_in_file         com_api_type_pkg.t_boolean;
    l_inst_number                  com_api_type_pkg.t_mcc;

    cursor all_account_cur(i_current_inst_id   in    com_api_type_pkg.t_inst_id) is
        select a.id
          from acc_account a
             , acc_account_type t
         where a.split_hash    in (select split_hash from com_api_split_map_vw)
           and a.inst_id        = i_current_inst_id
           and a.inst_id        = t.inst_id
           and a.account_type   = t.account_type
           and (t.product_type  = prd_api_const_pkg.PRODUCT_TYPE_ISS or (i_unload_acquiring_accounts = com_api_const_pkg.TRUE and t.product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ))
           and (i_array_account_type is null or a.account_type in (select element_value from com_array_element el where el.array_id = FRONT_END_ACCOUNT_TYPES))
        ;

    cursor evt_object_cur(i_current_inst_id in     com_api_type_pkg.t_inst_id) is
        select o.id
             , o.object_id     as account_id
             , o.split_hash
             , to_number(null) as oper_id
          from evt_event_object o
             , acc_account a
             , acc_account_type t
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and o.eff_date      <= l_sysdate
           and o.inst_id        = i_current_inst_id
           and (o.container_id  = l_container_id or o.container_id is null)
           and a.id             = o.object_id
           and a.split_hash     = o.split_hash
           and a.inst_id        = o.inst_id
           and t.account_type   = a.account_type
           and t.inst_id        = a.inst_id
           and (t.product_type  = prd_api_const_pkg.PRODUCT_TYPE_ISS or (i_unload_acquiring_accounts = com_api_const_pkg.TRUE and t.product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ))
           and (i_array_account_type is null or a.account_type in (select element_value from com_array_element el where el.array_id = FRONT_END_ACCOUNT_TYPES))
       union all
        select o.id
             , ae.account_id
             , ae.split_hash
             , to_number(null) as oper_id
          from evt_event_object o
             , acc_entry ae
             , acc_account a
             , acc_account_type t
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ENTRY
           and o.eff_date      <= l_sysdate
           and o.inst_id        = i_current_inst_id
           and (o.container_id  = l_container_id or o.container_id is null)
           and ae.id            = o.object_id+0
           and ae.split_hash    = o.split_hash
           and a.id             = ae.account_id
           and a.split_hash     = ae.split_hash
           and a.inst_id        = o.inst_id
           and t.account_type   = a.account_type
           and t.inst_id        = a.inst_id
           and (t.product_type  = prd_api_const_pkg.PRODUCT_TYPE_ISS or (i_unload_acquiring_accounts = com_api_const_pkg.TRUE and t.product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ))
           and (i_array_account_type is null or a.account_type in (select element_value from com_array_element el where el.array_id = FRONT_END_ACCOUNT_TYPES))
       union all
        select case
                   when p.participant_type    = com_api_const_pkg.PARTICIPANT_ISSUER
                        and l_unload_payments = com_api_const_pkg.TRUE
                   then o.id
                   else to_number(null)
               end as event_object_id
             , p.account_id
             , p.split_hash
             , case
                   when p.participant_type    = com_api_const_pkg.PARTICIPANT_ISSUER
                        and l_unload_payments = com_api_const_pkg.TRUE
                   then op.id
                   else to_number(null)
               end as oper_id
          from evt_event_object o
             , opr_operation op
             , opr_participant p
             , acc_account a
         where (l_unload_payments = com_api_const_pkg.TRUE or i_unload_acquiring_accounts = com_api_const_pkg.TRUE)
           and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'
           and o.split_hash      in (select split_hash from com_api_split_map_vw)
           and o.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and o.eff_date        <= l_sysdate
           and o.event_type       = opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY
           and (o.container_id  = l_container_id or o.container_id is null)
           and op.id              = o.object_id
           and p.oper_id          = op.id
           and (p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER or (i_unload_acquiring_accounts = com_api_const_pkg.TRUE and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER))
           and p.inst_id          = i_current_inst_id
           and a.id               = p.account_id
           and (i_array_account_type is null or a.account_type in (select element_value from com_array_element el where el.array_id = FRONT_END_ACCOUNT_TYPES))
       union all
        select o.id
             , a.id            as account_id
             , a.split_hash
             , to_number(null) as oper_id
          from evt_event_object o
             , prd_attribute_value av
             , prd_attribute pa
             , prd_service ps
             , prd_service_type st
             , prd_product pr
             , prd_contract c
             , acc_account a
             , acc_account_type t
         where l_unload_limits = com_api_type_pkg.TRUE
           and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and o.entity_type    = prd_api_const_pkg.ENTITY_TYPE_PRODUCT_ATTR_VAL
           and o.eff_date      <= l_sysdate
           and o.inst_id        = i_current_inst_id
           and o.event_type     = prd_api_const_pkg.EVENT_ATTR_CHANGE_PRD_ATTR_LVL
           and (o.container_id  = l_container_id or o.container_id is null)
           and av.id            = o.object_id
           and av.entity_type   = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
           and pa.id            = av.attr_id
           and pa.entity_type   = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
           and ps.id            = av.service_id
           and st.id            = ps.service_type_id
           and (t.product_type  = prd_api_const_pkg.PRODUCT_TYPE_ISS or (i_unload_acquiring_accounts = com_api_const_pkg.TRUE and t.product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ))
           and st.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and pr.id            = av.object_id
           and c.product_id     = pr.id
           and l_sysdate between c.start_date and nvl(c.end_date, l_sysdate)
           and c.inst_id        = o.inst_id
           and exists (
                   select 1 
                     from prd_service_object so
                    where so.contract_id = c.id
                      and so.service_id  = ps.id
                      and l_sysdate between so.start_date and nvl(so.end_date, l_sysdate)
               )
           and a.customer_id    = c.customer_id
           and a.contract_id    = c.id
           and a.inst_id        = o.inst_id
           and a.split_hash     = c.split_hash
           and t.account_type   = a.account_type
           and t.inst_id        = a.inst_id
           and t.product_type   = st.product_type
           and (i_array_account_type is null or a.account_type in (select element_value from com_array_element el where el.array_id = FRONT_END_ACCOUNT_TYPES))
      order by split_hash
             , account_id
        ;

    cursor main_limit_cur_xml(i_current_inst_id in    com_api_type_pkg.t_inst_id) is
        with products as (
            select connect_by_root id as product_id
                 , level              as level_priority
                 , id                 as parent_id
                 , split_hash
                 , case when parent_id is null then 1 else 0 end as top_flag
              from prd_product
           connect by prior parent_id = id
           --start with id = i_product_id
        )
        select
            xmlelement("accounts", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns")
              , xmlelement("file_type",     l_file_type)
              , xmlelement("date_purpose",  com_api_const_pkg.DATE_PURPOSE_PROCESSING)
              , xmlelement("start_date",    to_char(l_sysdate, 'yyyy-mm-dd'))
              , xmlelement("end_date",      to_char(l_sysdate, 'yyyy-mm-dd'))
              , xmlelement("inst_id",       case nvl(i_replace_inst_id_by_number, com_api_const_pkg.FALSE)
                                            when com_api_const_pkg.TRUE
                                            then l_inst_number
                                            else to_char(i_current_inst_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                                            end)
              , xmlelement("tokenized_pan", case l_export_clear_pan
                                                when com_api_const_pkg.FALSE
                                                then com_api_const_pkg.TRUE
                                                else com_api_const_pkg.FALSE
                                            end)
              , xmlagg(xmlelement("account", xmlattributes(g.account_id as "id")
                  , xmlelement("account_number",  min(g.account_number))
                  , xmlelement("currency",        min(g.currency))
                  , xmlelement("account_type",    min(g.account_type))
                  , xmlelement("account_status",  min(g.status))
                  , xmlelement("status_reason",
                        evt_api_status_pkg.get_status_reason(
                            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => g.account_id
                          , i_raise_error   => com_api_const_pkg.FALSE
                        )
                    )
                  , xmlelement("aval_balance",    min(g.aval_balance))
                  , xmlelement("create_date",     min(to_char(g.open_date, com_api_const_pkg.XML_DATE_FORMAT)))
                  , ( --xmlagg support only 1 level
                     select xmlagg(xmlelement("balance", xmlattributes(b.id as "id")
                              , xmlelement("balance_type", b.balance_type)
                              , xmlelement("turnover"
                                  , xmlelement("outgoing_balance", b.balance)
                                )
                            ))
                       from acc_balance b
                      where b.account_id = g.account_id
                        and b.split_hash = g.split_hash
                        and (i_array_balance_type_id is null
                             or b.balance_type in (select element_value
                                                     from com_array_element
                                                    where array_id = i_array_balance_type_id))
                    )
                  -- credit 
                  , (select xmlelement(
                                "credit"
                              , xmlagg(
                                    xmlforest(
                                         to_char(i.invoice_date, com_api_const_pkg.XML_DATE_FORMAT) as "sttl_date"
                                       , to_char(i.min_amount_due, com_api_const_pkg.XML_NUMBER_FORMAT) as "mad_amount"
                                       , to_char(i.grace_date, com_api_const_pkg.XML_DATE_FORMAT) as "grace_date"
                                       , to_char(i.total_amount_due, com_api_const_pkg.XML_NUMBER_FORMAT) as "total_amount_due"
                                       , to_char(i.due_date, com_api_const_pkg.XML_DATE_FORMAT) as "due_date"
                                       , to_char(i.payment_amount, com_api_const_pkg.XML_NUMBER_FORMAT) as "payment_amount"
                                       , to_char(i.aging_period, com_api_const_pkg.XML_NUMBER_FORMAT) as "aging_period"
                                    )
                                )
                            )
                       from crd_invoice i 
                      where i.id = crd_invoice_pkg.get_last_invoice_id(
                                       i_account_id => g.account_id
                                     , i_split_hash => g.split_hash
                                     , i_mask_error => com_api_type_pkg.TRUE
                                   )
                    )
                  , case when l_unload_limits = com_api_type_pkg.TRUE then (
                        select xmlelement("limits",
                                   xmlagg(xmlelement("limit"
                                     , xmlelement("limit_type",   l.limit_type)
                                     , xmlelement("limit_usage",  nvl((select t.limit_usage from fcl_limit_type t where l.limit_type = t.limit_type), fcl_api_const_pkg.LIMIT_USAGE_SUM_COUNT))
                                     , xmlelement("sum_limit",
                                           case when l.limit_base is not null and l.limit_rate is not null
                                           then
                                               nvl(fcl_api_limit_pkg.get_limit_border_sum(
                                                       i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                     , i_object_id            => g.account_id
                                                     , i_limit_type           => l.limit_type
                                                     , i_limit_base           => l.limit_base
                                                     , i_limit_rate           => l.limit_rate
                                                     , i_currency             => l.currency
                                                     , i_inst_id              => g.inst_id
                                                     , i_product_id           => prd_api_product_pkg.get_product_id(
                                                                                     i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                                   , i_object_id         => g.account_id
                                                                                   , i_inst_id           => g.inst_id
                                                                                 )
                                                     , i_split_hash           => g.split_hash
                                                     , i_mask_error           => com_api_const_pkg.TRUE
                                                  ), 0
                                               )
                                           else
                                               nvl(l.sum_limit, 0)
                                           end
                                       )
                                     , xmlelement("count_limit",
                                           case when l.limit_base is not null and l.limit_rate is not null
                                           then
                                               nvl(fcl_api_limit_pkg.get_limit_border_count(
                                                       i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                     , i_object_id            => g.account_id
                                                     , i_limit_type           => l.limit_type
                                                     , i_limit_base           => l.limit_base
                                                     , i_limit_rate           => l.limit_rate
                                                     , i_currency             => l.currency
                                                     , i_inst_id              => g.inst_id
                                                     , i_product_id           => prd_api_product_pkg.get_product_id(
                                                                                     i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                                   , i_object_id         => g.account_id
                                                                                   , i_inst_id           => g.inst_id
                                                                                 )
                                                     , i_split_hash           => g.split_hash
                                                     , i_mask_error           => com_api_const_pkg.TRUE
                                                  ), 0
                                               )
                                           else
                                               nvl(l.count_limit, 0)
                                           end
                                       )
                                     , xmlelement("sum_current",  nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                                                          i_limit_type   => l.limit_type
                                                                        , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                        , i_object_id    => g.account_id
                                                                        , i_limit_id     => l.id
                                                                        , i_mask_error   => com_api_type_pkg.FALSE
                                                                        , i_split_hash   => g.split_hash
                                                                      )
                                                                    , 0))
                                     , xmlelement("currency",     l.currency)
                                     , xmlelement("next_date",    case when b.next_date > l_sysdate or b.next_date is null
                                                                       then b.next_date
                                                                       else fcl_api_cycle_pkg.calc_next_date(
                                                                                i_cycle_type  => b.cycle_type
                                                                              , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                              , i_object_id   => g.account_id
                                                                              , i_split_hash  => g.split_hash
                                                                              , i_start_date  => l_sysdate
                                                                              , i_inst_id     => g.inst_id
                                                                            )
                                                                  end
                                                 )
                                     , xmlelement("length_type",  c.length_type)
                                     , xmlelement("cycle_length", c.cycle_length)
                                     , xmlelement("start_date", to_char(limits.start_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                     , xmlelement("end_date", to_char(limits.end_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                   ))
                               )
                          from fcl_limit l
                             , (select to_number(limit_id, 'FM000000000000000000.0000') limit_id
                                     , row_number() over (partition by account_id, limit_type order by decode(level_priority, 0, 0, 1)
                                                                                                            , level_priority
                                                                                                            , start_date desc
                                                                                                            , register_timestamp desc) rn
                                     , account_id
                                     , split_hash
                                     , start_date
                                     , end_date
                                  from (
                                        select v.attr_value limit_id
                                             , 0 level_priority
                                             , a.object_type limit_type
                                             , v.register_timestamp
                                             , v.start_date
                                             , v.end_date
                                             , v.object_id  account_id
                                             , v.split_hash
                                          from prd_attribute_value v
                                             , prd_attribute a
                                         where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                           and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                           and a.id           = v.attr_id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                     union all
                                        select v.attr_value
                                             , p.level_priority
                                             , a.object_type limit_type
                                             , v.register_timestamp
                                             , v.start_date
                                             , v.end_date
                                             , ac.id  account_id
                                             , ac.split_hash
                                          from products p
                                             , prd_attribute_value v
                                             , prd_attribute a
                                             , prd_service_type st
                                             , prd_service s
                                             , prd_product_service ps
                                             , prd_contract c
                                             , acc_account ac
                                         where v.entity_type     = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                                           and v.object_id       = p.parent_id
                                           and v.attr_id         = a.id
                                           and v.service_id      = s.id
                                           and v.split_hash      = p.split_hash
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                           and a.service_type_id = s.service_type_id
                                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                           and st.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                           and st.id             = s.service_type_id
                                           and p.product_id      = ps.product_id
                                           and s.id              = ps.service_id
                                           and ps.product_id     = c.product_id
                                           and c.id              = ac.contract_id
                                           and c.split_hash      = ac.split_hash
                                           -- Get active service id with subquery instead of the "prd_api_service_pkg.get_active_service_id" function
                                           and s.id = (
                                                          select min(service_id)
                                                            from prd_service_object o
                                                               , prd_service s
                                                           where o.service_id      = s.id
                                                             and s.service_type_id = a.service_type_id
                                                             and o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                             and o.object_id       = ac.id
                                                             and o.split_hash      = ac.split_hash
                                                             and l_sysdate between nvl(trunc(o.start_date), l_sysdate) and nvl(o.end_date, trunc(l_sysdate)+1)
                                                      )
                                    ) tt
                               ) limits
                             , fcl_cycle c
                             , fcl_cycle_counter b
                         where limits.account_id = g.account_id
                           and limits.split_hash = g.split_hash
                           and limits.rn         = 1
                           and l.id              = limits.limit_id
                           and c.id(+)           = l.cycle_id
                           and b.cycle_type(+)   = c.cycle_type
                           and b.entity_type(+)  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                           and b.object_id(+)    = g.account_id
                           and b.split_hash(+)   = g.split_hash
                        )
                    end
                    -- payment
                  , case when l_full_export         = com_api_const_pkg.FALSE
                              and l_unload_payments = com_api_const_pkg.TRUE
                         then (
                             select xmlagg(
                                   coalesce(
                                       (select xmlelement("payment"
                                             , xmlelement("oper_id", op.id)
                                             , xmlelement(
                                                   "card_number"
                                                 , coalesce(
                                                       (
                                                           select case when l_masking_card_in_file = com_api_const_pkg.TRUE
                                                                       then iss_api_card_pkg.get_card_mask(i_card_number => 
                                                                                iss_api_token_pkg.decode_card_number(i_card_number => d.card_number)
                                                                            )
                                                                       when l_export_clear_pan = com_api_const_pkg.FALSE
                                                                       then d.card_number
                                                                       else iss_api_token_pkg.decode_card_number(
                                                                                i_card_number => d.card_number
                                                                            )
                                                                  end
                                                             from opr_card d
                                                            where d.oper_id          = p.oper_id
                                                              and d.split_hash       = p.split_hash
                                                              and d.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                                       )
                                                     , (
                                                           select case when l_masking_card_in_file = com_api_const_pkg.TRUE
                                                                       then iss_api_card_pkg.get_card_mask(i_card_number => 
                                                                                iss_api_token_pkg.decode_card_number(i_card_number => n.card_number)
                                                                            )
                                                                       when l_export_clear_pan = com_api_const_pkg.FALSE
                                                                       then n.card_number
                                                                       else iss_api_token_pkg.decode_card_number(
                                                                                i_card_number => n.card_number
                                                                            )
                                                                  end
                                                             from iss_card_number n
                                                            where n.card_id = c.id
                                                       )
                                                   )
                                               )
                                             , xmlelement("card_seq_number",   nvl(p.card_seq_number, i.seq_number))
                                             , xmlelement("oper_amount",       op.oper_amount)
                                             , xmlelement("oper_currency",     op.oper_currency)
                                             , xmlelement("oper_date",         to_char(op.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                             , xmlelement("oper_type",         op.oper_type)
                                             , xmlelement("originator_refnum", op.originator_refnum)
                                             , nvl2(itf_cst_account_export_pkg.get_date_out_name(op.id)
                                                  , xmlelement(evalname itf_cst_account_export_pkg.get_date_out_name(op.id)
                                                             , to_char( itf_cst_account_export_pkg.get_date_out_value(op.id), com_api_const_pkg.XML_DATETIME_FORMAT))
                                                  , null)
                                             , xmlelement("sttl_date",         to_char(op.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                             , (select xmlagg(xmlelement("note"
                                                         , xmlelement("note_type", n.note_type)
                                                         , (select xmlagg(xmlelement("note_content", xmlattributes(lang.lang as "language")
                                                                     , xmlelement("note_header", h.text)
                                                                     , xmlelement("note_text", t.text)
                                                                   ))
                                                              from com_i18n_vw h
                                                                 , com_i18n_vw t
                                                                 , com_language_vw lang
                                                             where h.table_name(+)          = ntb_api_const_pkg.NOTE_TABLE
                                                               and t.table_name(+)          = ntb_api_const_pkg.NOTE_TABLE
                                                               and coalesce(h.lang, t.lang) = lang.lang
                                                               and h.lang(+)                = lang.lang
                                                               and t.lang(+)                = lang.lang
                                                               and h.column_name(+)         = 'HEADER'
                                                               and t.column_name(+)         = 'TEXT'
                                                               and h.object_id(+)           = n.id
                                                               and t.object_id(+)           = n.id)
                                                       ))
                                                  from ntb_note n
                                                 where n.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                                   and n.object_id   = op.id
                                               )
                                           )
                                          from iss_card_instance i
                                             , iss_card c
                                             , acc_account_object b
                                         where b.account_id   = p.account_id
                                           and b.split_hash   = p.split_hash
                                           and b.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and c.id           = b.object_id
                                           and c.split_hash   = b.split_hash
                                           and i.card_id      = c.id
                                           and i.split_hash   = c.split_hash
                                           and i.state       != iss_api_const_pkg.CARD_STATE_CLOSED
                                           and c.category     = iss_api_const_pkg.CARD_CATEGORY_PRIMARY
                                           and rownum         = 1
                                   )
                                 , (select xmlelement("payment"
                                             , xmlelement("oper_id", op.id)
                                             , xmlelement(
                                                   "card_number"
                                                 , coalesce(
                                                       (
                                                           select case when l_masking_card_in_file = com_api_const_pkg.TRUE
                                                                       then iss_api_card_pkg.get_card_mask(i_card_number => 
                                                                                iss_api_token_pkg.decode_card_number(i_card_number => d.card_number)
                                                                            )
                                                                       when l_export_clear_pan = com_api_const_pkg.FALSE
                                                                       then d.card_number
                                                                       else iss_api_token_pkg.decode_card_number(
                                                                                i_card_number => d.card_number
                                                                            )
                                                                  end
                                                             from opr_card d
                                                            where d.oper_id          = p.oper_id
                                                              and d.split_hash       = p.split_hash
                                                              and d.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                                       )
                                                     , (
                                                           select case when l_masking_card_in_file = com_api_const_pkg.TRUE
                                                                       then iss_api_card_pkg.get_card_mask(i_card_number => 
                                                                                iss_api_token_pkg.decode_card_number(i_card_number => n.card_number)
                                                                            )
                                                                       when l_export_clear_pan = com_api_const_pkg.FALSE
                                                                       then n.card_number
                                                                       else iss_api_token_pkg.decode_card_number(
                                                                                i_card_number => n.card_number
                                                                            )
                                                                  end
                                                             from iss_card_number n
                                                            where n.card_id = c.id
                                                       )
                                                   )
                                               )
                                             , xmlelement("card_seq_number",   nvl(p.card_seq_number, i.seq_number))
                                             , xmlelement("oper_amount",       op.oper_amount)
                                             , xmlelement("oper_currency",     op.oper_currency)
                                             , xmlelement("oper_date",         to_char(op.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                             , xmlelement("oper_type",         op.oper_type)
                                             , xmlelement("originator_refnum", op.originator_refnum)
                                             , nvl2(itf_cst_account_export_pkg.get_date_out_name(op.id)
                                                  , xmlelement(evalname itf_cst_account_export_pkg.get_date_out_name(op.id)
                                                             , to_char( itf_cst_account_export_pkg.get_date_out_value(op.id), com_api_const_pkg.XML_DATETIME_FORMAT))
                                                  , null)
                                             , xmlelement("sttl_date",         to_char(op.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                             , (select xmlagg(xmlelement("note"
                                                         , xmlelement("note_type", n.note_type)
                                                         , (select xmlagg(xmlelement("note_content", xmlattributes(lang.lang as "language")
                                                                     , xmlelement("note_header", h.text)
                                                                     , xmlelement("note_text", t.text)
                                                                   ))
                                                              from com_i18n_vw h
                                                                 , com_i18n_vw t
                                                                 , com_language_vw lang
                                                             where h.table_name(+)          = ntb_api_const_pkg.NOTE_TABLE
                                                               and t.table_name(+)          = ntb_api_const_pkg.NOTE_TABLE
                                                               and coalesce(h.lang, t.lang) = lang.lang
                                                               and h.lang(+)                = lang.lang
                                                               and t.lang(+)                = lang.lang
                                                               and h.column_name(+)         = 'HEADER'
                                                               and t.column_name(+)         = 'TEXT'
                                                               and h.object_id(+)           = n.id
                                                               and t.object_id(+)           = n.id)
                                                       ))
                                                  from ntb_note n
                                                 where n.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                                   and n.object_id   = op.id
                                               )
                                           )
                                          from iss_card_instance i
                                             , iss_card c
                                             , acc_account_object b
                                         where b.account_id   = p.account_id
                                           and b.split_hash   = p.split_hash
                                           and b.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and c.id           = b.object_id
                                           and c.split_hash   = b.split_hash
                                           and i.card_id      = c.id
                                           and i.split_hash   = c.split_hash
                                           and i.state       != iss_api_const_pkg.CARD_STATE_CLOSED
                                           and c.category    != iss_api_const_pkg.CARD_CATEGORY_PRIMARY
                                           and rownum         = 1
                                       )
                                   )
                               )
                          from opr_operation op
                             , opr_participant p
                         where op.id in (select column_value from table(cast(l_oper_id_tab as num_tab_tpt)))
                           and p.oper_id(+)       = op.id
                           and p.split_hash       = g.split_hash
                           and p.account_id+0     = g.account_id                         -- disable index for the 'account_id' field
                           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                        )
                    end
                  -- services  
                  , case when l_include_service = com_api_type_pkg.TRUE then 
                        case when l_full_export = com_api_type_pkg.TRUE then (
                            select xmlagg(
                                  xmlelement("service"
                                      , xmlelement("service_type",          s.service_type_id)
                                      , xmlelement("service_type_name",     s.service_type_name)
                                      , xmlelement("service_external_code", nvl(s.external_code, s.service_type_id))
                                      , xmlelement("service_number",        s.service_number)
                                      , xmlelement("is_active",             s.is_active)
                                      , (
                                            select xmlagg(
                                                        xmlelement("service_attribute"
                                                          , xmlelement("service_attribute_name",   attr.attr_name)                    
                                                          , xmlelement("service_attribute_value",  attr.attr_value)                    
                                                        )
                                                    )    
                                             from (
                                                 select attr_value
                                                       , row_number() over (partition by account_id, attr_name order by decode(level_priority, 0, 0, 1)
                                                                                                                              , level_priority
                                                                                                                              , start_date desc
                                                                                                                              , register_timestamp desc) rn
                                                       , account_id
                                                       , split_hash
                                                       , attr_name
                                                       , service_id
                                                    from (
                                                        select v.attr_value 
                                                             , 0 level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , v.object_id  account_id
                                                             , v.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from prd_attribute_value v
                                                             , prd_attribute a
                                                         where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                           and a.entity_type  is null 
                                                           and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and a.id           = v.attr_id
                                                           and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                     union all
                                                        select v.attr_value
                                                             , p.level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , ac.id  account_id
                                                             , ac.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from products p
                                                             , prd_attribute_value v
                                                             , prd_attribute a
                                                             , (select distinct id, service_type_id from table(cast(l_service_id_tab as prd_service_tpt))) srv
                                                             , prd_product_service ps
                                                             , prd_contract c
                                                             , acc_account ac
                                                         where v.service_id      = srv.id 
                                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                           and v.attr_id         = a.id
                                                           and a.service_type_id = srv.service_type_id
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                           and a.entity_type  is null 
                                                           and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR --'DTTPCHAR'
                                                           and ps.service_id     = srv.id
                                                           and ps.service_id     = v.service_id                                              
                                                           and p.product_id      = ps.product_id                                           
                                                           and ps.product_id     = c.product_id
                                                           and c.id              = ac.contract_id
                                                           and c.split_hash      = ac.split_hash
                                                     ) tt
                                                  ) attr
                                              where attr.rn = 1
                                                and attr.service_id = s.id 
                                                and attr.account_id = b.object_id
                                                and attr.split_hash = b.split_hash
                                              )
                                      )             
                                  )  
                                  from table(cast(l_service_id_tab as prd_service_tpt)) s
                                     , prd_service_object b                       
                                 where b.service_id    = s.id
                                   and b.object_id     = g.account_id
                                   and b.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                   and b.split_hash    = g.split_hash                  
                            )
                        else ( --incremental
                            select xmlagg(
                                  xmlelement("service"
                                      , xmlelement("service_type",          s.service_type_id)
                                      , xmlelement("service_type_name",     s.service_type_name)
                                      , xmlelement("service_external_code", nvl(s.external_code, s.service_type_id))
                                      , xmlelement("service_number",        s.service_number)
                                      , xmlelement("is_active",             s.is_active)
                                      , (
                                            select xmlagg(
                                                        xmlelement("service_attribute"
                                                          , xmlelement("service_attribute_name",   attr.attr_name)                    
                                                          , xmlelement("service_attribute_value",  attr.attr_value)                    
                                                        )
                                                    )    
                                             from (
                                                 select attr_value
                                                       , row_number() over (partition by account_id, attr_name order by decode(level_priority, 0, 0, 1)
                                                                                                                              , level_priority
                                                                                                                              , start_date desc
                                                                                                                              , register_timestamp desc) rn
                                                       , account_id
                                                       , split_hash
                                                       , attr_name
                                                       , service_id
                                                    from (
                                                        select v.attr_value 
                                                             , 0 level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , v.object_id  account_id
                                                             , v.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from prd_attribute_value v
                                                             , prd_attribute a
                                                         where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                           and a.entity_type  is null 
                                                           and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and a.id           = v.attr_id
                                                           and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                     union all
                                                        select v.attr_value
                                                             , p.level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , ac.id  account_id
                                                             , ac.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from products p
                                                             , prd_attribute_value v
                                                             , prd_attribute a
                                                             , (select distinct id, service_type_id from table(cast(l_service_id_tab as prd_service_tpt))) srv
                                                             , prd_product_service ps
                                                             , prd_contract c
                                                             , acc_account ac
                                                         where v.service_id      = srv.id 
                                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                           and v.attr_id         = a.id
                                                           and a.service_type_id = srv.service_type_id
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                           and a.entity_type  is null 
                                                           and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and ps.service_id     = srv.id
                                                           and ps.service_id     = v.service_id                                              
                                                           and p.product_id      = ps.product_id                                           
                                                           and ps.product_id     = c.product_id
                                                           and c.id              = ac.contract_id
                                                           and c.split_hash      = ac.split_hash
                                                     ) tt
                                                  ) attr
                                              where attr.rn = 1
                                                and attr.service_id = s.id 
                                                and attr.account_id = b.object_id
                                                and attr.split_hash = b.split_hash
                                              )
                                      )             
                                  )  
                                  from evt_event_object o
                                     , table(cast(l_service_id_tab as prd_service_tpt)) s
                                     , prd_service_object b                       
                                 where o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                   and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'
                                   and o.object_id     = g.account_id
                                   and o.split_hash    = g.split_hash 
                                   and o.eff_date      <= l_sysdate
                                   and s.event_type    = o.event_type
                                   and s.id            = b.service_id
                                   and o.object_id     = b.object_id
                                   and o.entity_type   = b.entity_type
                                   and o.split_hash    = b.split_hash   
                            )                                                  
                        end            
                  end
                  , itf_cst_account_export_pkg.generate_add_data(
                      i_account_id  => g.account_id
                   )
                  , com_api_flexible_data_pkg.generate_xml(
                        i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                      , i_object_id   => g.account_id
                    ) -- account flexible fields
                ))
            ).getclobval()
          , count(1)
       from (
          select f.id account_id
               , f.account_type
               , f.status
               , f.account_number
               , (
                 select nvl(
                            sum(t.aval_impact *
                                case
                                    when f.currency = b.currency
                                    then b.balance
                                    else com_api_rate_pkg.convert_amount(
                                             i_src_amount   => b.balance
                                           , i_src_currency => b.currency
                                           , i_dst_currency => f.currency
                                           , i_rate_type    => t.rate_type
                                           , i_inst_id      => f.inst_id
                                           , i_eff_date     => l_sysdate
                                         )
                                end)
                          , 0
                        )
                   from acc_balance_type t
                      , acc_balance b
                  where b.account_id   = f.id
                    and b.split_hash   = f.split_hash
                    and t.account_type = f.account_type
                    and t.inst_id      = f.inst_id
                    and t.aval_impact != 0
                    and t.balance_type = b.balance_type
               ) aval_balance
               , f.split_hash
               , f.currency
               , f.inst_id
               , (select min(open_date) from acc_balance where account_id = f.id and split_hash = f.split_hash) open_date
            from acc_account f
           where f.id in (select column_value from table(cast(l_account_id_tab as num_tab_tpt)))
        ) g
    group by g.account_id
           , g.split_hash
           , g.inst_id
        ;

    cursor main_cur_xml(i_current_inst_id  in    com_api_type_pkg.t_inst_id) is
        with products as (
            select connect_by_root id product_id
                 , level level_priority
                 , id parent_id
                 , product_type
                 , case when parent_id is null then 1 else 0 end top_flag
              from prd_product
           connect by prior parent_id = id
           --start with id = i_product_id
        )
        select
            xmlelement("accounts", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns")
              , xmlelement("file_type",    l_file_type)
              , xmlelement("date_purpose", com_api_const_pkg.DATE_PURPOSE_PROCESSING)
              , xmlelement("start_date",   to_char(l_sysdate, 'yyyy-mm-dd'))
              , xmlelement("end_date",     to_char(l_sysdate, 'yyyy-mm-dd'))
              , xmlelement("inst_id",      case nvl(i_replace_inst_id_by_number, com_api_const_pkg.FALSE)
                                           when com_api_const_pkg.TRUE
                                           then l_inst_number
                                           else to_char(i_current_inst_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                                           end)
              , xmlelement("tokenized_pan", case l_export_clear_pan
                                            when com_api_const_pkg.FALSE
                                            then com_api_const_pkg.TRUE
                                            else com_api_const_pkg.FALSE
                                            end)
              , xmlagg(xmlelement("account", xmlattributes(g.account_id as "id")
                  , xmlelement("account_number",  min(g.account_number))
                  , xmlelement("currency",        min(g.account_currency))
                  , xmlelement("account_type",    min(g.account_type))
                  , xmlelement("account_status",  min(g.status))
                  , xmlelement("status_reason",
                        evt_api_status_pkg.get_status_reason(
                            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => g.account_id
                          , i_raise_error   => com_api_const_pkg.FALSE
                        )
                    )
                  , xmlelement("aval_balance",    min(g.aval_balance))
                  , xmlelement("create_date",     min(to_char(g.open_date, com_api_const_pkg.XML_DATE_FORMAT)))
                  , xmlagg(xmlelement("balance", xmlattributes(g.balance_id as "id")
                      , xmlelement("balance_type", g.balance_type)
                      , xmlelement("turnover"
                          , xmlelement("outgoing_balance", g.balance)
                        )
                    ))
                  -- credit 
                  , (select xmlelement(
                                "credit"
                              , xmlagg(
                                    xmlforest(
                                         to_char(i.invoice_date, com_api_const_pkg.XML_DATE_FORMAT) as "sttl_date"
                                       , to_char(i.min_amount_due, com_api_const_pkg.XML_NUMBER_FORMAT) as "mad_amount"
                                       , to_char(i.grace_date, com_api_const_pkg.XML_DATE_FORMAT) as "grace_date"
                                       , to_char(i.total_amount_due, com_api_const_pkg.XML_NUMBER_FORMAT) as "total_amount_due"
                                       , to_char(i.due_date, com_api_const_pkg.XML_DATE_FORMAT) as "due_date"
                                    )
                                )
                            )
                       from crd_invoice i 
                      where i.id = crd_invoice_pkg.get_last_invoice_id(
                                       i_account_id => g.account_id
                                     , i_split_hash => g.split_hash
                                     , i_mask_error => com_api_type_pkg.TRUE
                                   )
                    )
                    -- payment
                  , case when l_full_export         = com_api_const_pkg.FALSE
                              and l_unload_payments = com_api_const_pkg.TRUE
                         then (
                             select xmlagg(
                                   coalesce(
                                       (select xmlelement("payment"
                                             , xmlelement("oper_id", op.id)
                                             , xmlelement(
                                                   "card_number"
                                                 , coalesce(
                                                       (
                                                           select case when l_masking_card_in_file = com_api_const_pkg.TRUE
                                                                       then iss_api_card_pkg.get_card_mask(i_card_number => 
                                                                                iss_api_token_pkg.decode_card_number(i_card_number => d.card_number)
                                                                            )
                                                                       when l_export_clear_pan = com_api_const_pkg.FALSE
                                                                       then d.card_number
                                                                       else iss_api_token_pkg.decode_card_number(
                                                                                i_card_number => d.card_number
                                                                            )
                                                                  end
                                                             from opr_card d
                                                            where d.oper_id          = p.oper_id
                                                              and d.split_hash       = p.split_hash
                                                              and d.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                                       )
                                                     , (
                                                           select case when l_masking_card_in_file = com_api_const_pkg.TRUE
                                                                       then iss_api_card_pkg.get_card_mask(i_card_number => 
                                                                                iss_api_token_pkg.decode_card_number(i_card_number => n.card_number)
                                                                            )
                                                                       when l_export_clear_pan = com_api_const_pkg.FALSE
                                                                       then n.card_number
                                                                       else iss_api_token_pkg.decode_card_number(
                                                                                i_card_number => n.card_number
                                                                            )
                                                                  end
                                                             from iss_card_number n
                                                            where n.card_id = c.id
                                                       )
                                                   )
                                               )
                                             , xmlelement("card_seq_number",   nvl(p.card_seq_number, i.seq_number))
                                             , xmlelement("oper_amount",       op.oper_amount)
                                             , xmlelement("oper_currency",     op.oper_currency)
                                             , xmlelement("oper_date",         to_char(op.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                             , xmlelement("oper_type",         op.oper_type)
                                             , xmlelement("originator_refnum", op.originator_refnum)
                                             , nvl2(itf_cst_account_export_pkg.get_date_out_name(op.id)
                                                  , xmlelement(evalname itf_cst_account_export_pkg.get_date_out_name(op.id)
                                                             , to_char( itf_cst_account_export_pkg.get_date_out_value(op.id), com_api_const_pkg.XML_DATETIME_FORMAT))
                                                  , null)
                                             , xmlelement("sttl_date",         to_char(op.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                             , (select xmlagg(xmlelement("note"
                                                         , xmlelement("note_type", n.note_type)
                                                         , (select xmlagg(xmlelement("note_content", xmlattributes(lang.lang as "language")
                                                                     , xmlelement("note_header", h.text)
                                                                     , xmlelement("note_text", t.text)
                                                                   ))
                                                              from com_i18n_vw h
                                                                 , com_i18n_vw t
                                                                 , com_language_vw lang
                                                             where h.table_name(+)          = ntb_api_const_pkg.NOTE_TABLE
                                                               and t.table_name(+)          = ntb_api_const_pkg.NOTE_TABLE
                                                               and coalesce(h.lang, t.lang) = lang.lang
                                                               and h.lang(+)                = lang.lang
                                                               and t.lang(+)                = lang.lang
                                                               and h.column_name(+)         = 'HEADER'
                                                               and t.column_name(+)         = 'TEXT'
                                                               and h.object_id(+)           = n.id
                                                               and t.object_id(+)           = n.id)
                                                       ))
                                                  from ntb_note n
                                                 where n.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                                   and n.object_id   = op.id
                                               )
                                           )
                                          from iss_card_instance i
                                             , iss_card c
                                             , acc_account_object b
                                         where b.account_id   = p.account_id
                                           and b.split_hash   = p.split_hash
                                           and b.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and c.id           = b.object_id
                                           and c.split_hash   = b.split_hash
                                           and i.card_id      = c.id
                                           and i.split_hash   = c.split_hash
                                           and i.state       != iss_api_const_pkg.CARD_STATE_CLOSED
                                           and c.category     = iss_api_const_pkg.CARD_CATEGORY_PRIMARY
                                           and rownum         = 1
                                   )
                                 , (select xmlelement("payment"
                                             , xmlelement("oper_id", op.id)
                                             , xmlelement(
                                                   "card_number"
                                                 , coalesce(
                                                       (
                                                           select case when l_masking_card_in_file = com_api_const_pkg.TRUE
                                                                       then iss_api_card_pkg.get_card_mask(i_card_number => 
                                                                                iss_api_token_pkg.decode_card_number(i_card_number => d.card_number)
                                                                            )
                                                                       when l_export_clear_pan = com_api_const_pkg.FALSE
                                                                       then d.card_number
                                                                       else iss_api_token_pkg.decode_card_number(
                                                                                i_card_number => d.card_number
                                                                            )
                                                                  end
                                                             from opr_card d
                                                            where d.oper_id          = p.oper_id
                                                              and d.split_hash       = p.split_hash
                                                              and d.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                                       )
                                                     , (
                                                           select case when l_masking_card_in_file = com_api_const_pkg.TRUE
                                                                       then iss_api_card_pkg.get_card_mask(i_card_number => 
                                                                                iss_api_token_pkg.decode_card_number(i_card_number => n.card_number)
                                                                            )
                                                                       when l_export_clear_pan = com_api_const_pkg.FALSE
                                                                       then n.card_number
                                                                       else iss_api_token_pkg.decode_card_number(
                                                                                i_card_number => n.card_number
                                                                            )
                                                                  end
                                                             from iss_card_number n
                                                            where n.card_id = c.id
                                                       )
                                                   )
                                               )
                                             , xmlelement("card_seq_number",   nvl(p.card_seq_number, i.seq_number))
                                             , xmlelement("oper_amount",       op.oper_amount)
                                             , xmlelement("oper_currency",     op.oper_currency)
                                             , xmlelement("oper_date",         to_char(op.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                             , xmlelement("oper_type",         op.oper_type)
                                             , xmlelement("originator_refnum", op.originator_refnum)
                                             , nvl2(itf_cst_account_export_pkg.get_date_out_name(op.id)
                                                  , xmlelement(evalname itf_cst_account_export_pkg.get_date_out_name(op.id)
                                                             , to_char( itf_cst_account_export_pkg.get_date_out_value(op.id), com_api_const_pkg.XML_DATETIME_FORMAT))
                                                  , null)
                                             , xmlelement("sttl_date",         to_char(op.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                             , (select xmlagg(xmlelement("note"
                                                         , xmlelement("note_type", n.note_type)
                                                         , (select xmlagg(xmlelement("note_content", xmlattributes(lang.lang as "language")
                                                                     , xmlelement("note_header", h.text)
                                                                     , xmlelement("note_text", t.text)
                                                                   ))
                                                              from com_i18n_vw h
                                                                 , com_i18n_vw t
                                                                 , com_language_vw lang
                                                             where h.table_name(+)          = ntb_api_const_pkg.NOTE_TABLE
                                                               and t.table_name(+)          = ntb_api_const_pkg.NOTE_TABLE
                                                               and coalesce(h.lang, t.lang) = lang.lang
                                                               and h.lang(+)                = lang.lang
                                                               and t.lang(+)                = lang.lang
                                                               and h.column_name(+)         = 'HEADER'
                                                               and t.column_name(+)         = 'TEXT'
                                                               and h.object_id(+)           = n.id
                                                               and t.object_id(+)           = n.id)
                                                       ))
                                                  from ntb_note n
                                                 where n.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                                   and n.object_id   = op.id
                                               )
                                           )
                                          from iss_card_instance i
                                             , iss_card c
                                             , acc_account_object b
                                         where b.account_id   = p.account_id
                                           and b.split_hash   = p.split_hash
                                           and b.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and c.id           = b.object_id
                                           and c.split_hash   = b.split_hash
                                           and i.card_id      = c.id
                                           and i.split_hash   = c.split_hash
                                           and i.state       != iss_api_const_pkg.CARD_STATE_CLOSED
                                           and c.category    != iss_api_const_pkg.CARD_CATEGORY_PRIMARY
                                           and rownum         = 1
                                       )
                                   )
                               )
                          from opr_operation op
                             , opr_participant p
                         where op.id in (select column_value from table(cast(l_oper_id_tab as num_tab_tpt)))
                           and p.oper_id(+)       = op.id
                           and p.split_hash       = g.split_hash
                           and p.account_id+0     = g.account_id                         -- disable index for the 'account_id' field
                           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                        )
                    end
                  -- services  
                  , case when l_include_service = com_api_type_pkg.TRUE then 
                        case when l_full_export = com_api_type_pkg.TRUE then (
                            select xmlagg(
                                  xmlelement("service"
                                      , xmlelement("service_type",          s.service_type_id)
                                      , xmlelement("service_type_name",     s.service_type_name)
                                      , xmlelement("service_external_code", nvl(s.external_code, s.service_type_id))
                                      , xmlelement("service_number",        s.service_number)
                                      , xmlelement("is_active",             s.is_active)
                                      , (
                                            select xmlagg(
                                                        xmlelement("service_attribute"
                                                          , xmlelement("service_attribute_name",   attr.attr_name)                    
                                                          , xmlelement("service_attribute_value",  attr.attr_value)                    
                                                        )
                                                    )    
                                             from (
                                                 select attr_value
                                                       , row_number() over (partition by account_id, attr_name order by decode(level_priority, 0, 0, 1)
                                                                                                                              , level_priority
                                                                                                                              , start_date desc
                                                                                                                              , register_timestamp desc) rn
                                                       , account_id
                                                       , split_hash
                                                       , attr_name
                                                       , service_id
                                                    from (
                                                        select v.attr_value 
                                                             , 0 level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , v.object_id  account_id
                                                             , v.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from prd_attribute_value v
                                                             , prd_attribute a
                                                         where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                           and a.entity_type  is null 
                                                           and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and a.id           = v.attr_id
                                                           and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                     union all
                                                        select v.attr_value
                                                             , p.level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , ac.id  account_id
                                                             , ac.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from products p
                                                             , prd_attribute_value v
                                                             , prd_attribute a
                                                             , (select distinct id, service_type_id from table(cast(l_service_id_tab as prd_service_tpt))) srv
                                                             , prd_product_service ps
                                                             , prd_contract c
                                                             , acc_account ac
                                                         where v.service_id      = srv.id 
                                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                           and v.attr_id         = a.id
                                                           and a.service_type_id = srv.service_type_id
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                           and a.entity_type  is null 
                                                           and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and ps.service_id     = srv.id
                                                           and ps.service_id     = v.service_id                                              
                                                           and p.product_id      = ps.product_id                                           
                                                           and ps.product_id     = c.product_id
                                                           and c.id              = ac.contract_id
                                                           and c.split_hash      = ac.split_hash
                                                     ) tt
                                                  ) attr
                                              where attr.rn = 1
                                                and attr.service_id = s.id 
                                                and attr.account_id = b.object_id
                                                and attr.split_hash = b.split_hash
                                              )
                                      )             
                                  )  
                                  from table(cast(l_service_id_tab as prd_service_tpt)) s
                                     , prd_service_object b                       
                                 where b.service_id    = s.id
                                   and b.object_id     = g.account_id
                                   and b.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                   and b.split_hash    = g.split_hash                  
                            )
                        else ( --incremental
                            select xmlagg(
                                  xmlelement("service"
                                      , xmlelement("service_type",          s.service_type_id)
                                      , xmlelement("service_type_name",     s.service_type_name)
                                      , xmlelement("service_external_code", nvl(s.external_code, s.service_type_id))
                                      , xmlelement("service_number",        s.service_number)
                                      , xmlelement("is_active",             s.is_active)
                                      , (
                                            select xmlagg(
                                                        xmlelement("service_attribute"
                                                          , xmlelement("service_attribute_name",   attr.attr_name)                    
                                                          , xmlelement("service_attribute_value",  attr.attr_value)                    
                                                        )
                                                    )    
                                             from (
                                                 select attr_value
                                                       , row_number() over (partition by account_id, attr_name order by decode(level_priority, 0, 0, 1)
                                                                                                                              , level_priority
                                                                                                                              , start_date desc
                                                                                                                              , register_timestamp desc) rn
                                                       , account_id
                                                       , split_hash
                                                       , attr_name
                                                       , service_id
                                                    from (
                                                        select v.attr_value 
                                                             , 0 level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , v.object_id  account_id
                                                             , v.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from prd_attribute_value v
                                                             , prd_attribute a
                                                         where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                           and a.entity_type  is null 
                                                           and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and a.id           = v.attr_id
                                                           and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                     union all
                                                        select v.attr_value
                                                             , p.level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , ac.id  account_id
                                                             , ac.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from products p
                                                             , prd_attribute_value v
                                                             , prd_attribute a
                                                             , (select distinct id, service_type_id from table(cast(l_service_id_tab as prd_service_tpt))) srv
                                                             , prd_product_service ps
                                                             , prd_contract c
                                                             , acc_account ac
                                                         where v.service_id      = srv.id 
                                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                           and v.attr_id         = a.id
                                                           and a.service_type_id = srv.service_type_id
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                           and a.entity_type  is null 
                                                           and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and ps.service_id     = srv.id
                                                           and ps.service_id     = v.service_id                                              
                                                           and p.product_id      = ps.product_id                                           
                                                           and ps.product_id     = c.product_id
                                                           and c.id              = ac.contract_id
                                                           and c.split_hash      = ac.split_hash
                                                     ) tt
                                                  ) attr
                                              where attr.rn = 1
                                                and attr.service_id = s.id 
                                                and attr.account_id = b.object_id
                                                and attr.split_hash = b.split_hash
                                              )
                                      )             
                                  )  
                                  from evt_event_object o
                                     , table(cast(l_service_id_tab as prd_service_tpt)) s
                                     , prd_service_object b                       
                                 where o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                   and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'
                                   and o.object_id     = g.account_id
                                   and o.split_hash    = g.split_hash 
                                   and o.eff_date      <= l_sysdate
                                   and s.event_type    = o.event_type
                                   and s.id            = b.service_id
                                   and o.object_id     = b.object_id
                                   and o.entity_type   = b.entity_type
                                   and o.split_hash    = b.split_hash   
                            )                                                  
                        end            
                  end
                  , itf_cst_account_export_pkg.generate_add_data(
                      i_account_id  => g.account_id
                   )
                ))
            ).getclobval()
          , count(1)
       from (
          select f.account_id
              , f.currency balance_currency
              , f.account_type
              , f.status
              , f.account_number
              , f.balance_type
              , f.balance_id
              , f.balance
              , (
                  select nvl(
                             sum(t.aval_impact *
                                 case
                                     when f.account_currency = b.currency
                                     then b.balance
                                     else com_api_rate_pkg.convert_amount(
                                              i_src_amount   => b.balance
                                            , i_src_currency => b.currency
                                            , i_dst_currency => f.account_currency
                                            , i_rate_type    => t.rate_type
                                            , i_inst_id      => f.inst_id
                                            , i_eff_date     => l_sysdate
                                          )
                                 end)
                           , 0
                         )
                  from acc_balance_type t
                     , acc_balance b
                 where b.account_id   = f.account_id
                   and b.split_hash   = f.split_hash
                   and t.account_type = f.account_type
                   and t.inst_id      = f.inst_id
                   and t.aval_impact != 0
                   and t.balance_type = b.balance_type
              ) aval_balance
              , f.split_hash
              , f.inst_id account_inst_id
              , f.account_currency
              , f.inst_id
              , f.open_date
            from (
                    select a.id account_id
                         , a.currency account_currency
                         , a.account_type
                         , a.status
                         , a.account_number
                         , a.inst_id
                         , a.split_hash
                         , ab.id as balance_id
                         , ab.balance_type
                         , ab.currency
                         , ab.balance
                         , ab.open_date
                      from acc_account a
                         , acc_balance ab
                     where a.id in (select column_value from table(cast(l_account_id_tab as num_tab_tpt)))
                       and ab.split_hash  = a.split_hash
                       and ab.account_id  = a.id
                    and (i_array_balance_type_id is null
                         or
                         ab.balance_type in (select element_value
                                               from com_array_element
                                              where array_id = i_array_balance_type_id))
               ) f
           ) g
    group by g.account_id
           , g.split_hash
           , g.inst_id
        ;

    procedure save_file(
        i_counter           in     com_api_type_pkg.t_count
      , i_current_inst_id   in     com_api_type_pkg.t_inst_id
    ) is
        l_report_id                com_api_type_pkg.t_short_id;
        l_report_template_id       com_api_type_pkg.t_short_id;
    begin
        trc_log_pkg.debug('Creating a new XML file, count=' || i_counter);

        l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_current_inst_id
            , io_params  => l_params
        );

        l_file_count := l_file_count + 1;

        rul_api_param_pkg.set_param(
            i_name    => 'FILE_NUMBER'
          , i_value   => l_file_count
          , io_params => l_params
        );

        prc_api_file_pkg.save_file (
            i_file_type           => l_file_type
          , io_params             => l_params
          , o_report_id           => l_report_id
          , o_report_template_id  => l_report_template_id
          , i_clob_content        => l_file
          , i_status              => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count        => i_counter
        );

        trc_log_pkg.debug('file saved, count=' || i_counter || ', length=' || length(l_file));

    end save_file;

    -- Generate XML file
    procedure generate_xml(i_current_inst_id  in     com_api_type_pkg.t_inst_id) is
        l_fetched_count        com_api_type_pkg.t_count    := 0;
    begin
        if l_account_id_tab.count > 0 then

            l_estimated_count := nvl(l_estimated_count, 0) + l_account_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
              , i_measure         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            );
            trc_log_pkg.debug('Estimated count of accounts is [' || l_estimated_count || ']');

            -- For every processing batch of accounts we fetch data and save it in a separate file
            if l_unload_limits = com_api_type_pkg.TRUE then
                open  main_limit_cur_xml(i_current_inst_id => i_current_inst_id);
                fetch main_limit_cur_xml into l_file, l_fetched_count;
                close main_limit_cur_xml;
            else
                open  main_cur_xml(i_current_inst_id => i_current_inst_id);
                fetch main_cur_xml into l_file, l_fetched_count;
                close main_cur_xml;
            end if;

            trc_log_pkg.debug('l_fetched_count = ' || l_fetched_count);

            save_file(
                i_counter         => l_fetched_count
              , i_current_inst_id => i_current_inst_id
            );

            l_processed_count := l_processed_count + l_fetched_count;

            prc_api_stat_pkg.log_current (
                i_current_count   => l_processed_count
              , i_excepted_count  => 0
            );

        end if;
    end generate_xml;

begin
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_full_export     := nvl(i_full_export,     com_api_const_pkg.FALSE);
    l_unload_limits   := nvl(i_unload_limits,   com_api_const_pkg.FALSE);
    l_unload_payments := nvl(i_unload_payments, com_api_const_pkg.FALSE);
    l_include_service := nvl(i_include_service, com_api_const_pkg.FALSE);

    l_sysdate         := com_api_sttl_day_pkg.get_sysdate;
    l_lang            := nvl(i_lang, com_ui_user_env_pkg.get_user_lang());

    -- If tokenization isn't used then there is no sense to call decoding function
    -- in then select section to reduce count of SQL-PLSQL context switches
    l_export_clear_pan :=
        case
            when iss_api_token_pkg.is_token_enabled() = com_api_const_pkg.TRUE
            then nvl(i_export_clear_pan, com_api_const_pkg.TRUE)
            else com_api_const_pkg.FALSE
        end;

    trc_log_pkg.debug(
        i_text       => 'process_unload_turnover START: file_type [#1], l_unload_limits [#2], thread_number [#3], l_container_id [#4], l_full_export [#5], l_sysdate [#6]'
      , i_env_param1 => l_file_type
      , i_env_param2 => l_unload_limits
      , i_env_param3 => get_thread_number()
      , i_env_param4 => l_container_id
      , i_env_param5 => l_full_export
      , i_env_param6 => to_char(l_sysdate, 'dd.mm.yyyy hh24:mi:ss')
    );

    trc_log_pkg.debug(
        i_text       => 'process_unload_turnover: l_include_service [#1], l_lang [#2], l_export_clear_pan [#3], l_masking_card_in_file [#4]'
      , i_env_param1 => l_include_service
      , i_env_param2 => l_lang
      , i_env_param3 => l_export_clear_pan
      , i_env_param4 => l_masking_card_in_file
    );

    prc_api_stat_pkg.log_start;

    for inst in (
        select i.id 
          from ost_institution i
         where (i.id = i_inst_id
             or i_inst_id = ost_api_const_pkg.DEFAULT_INST 
             or i_inst_id is null)
           and i.id != ost_api_const_pkg.UNIDENTIFIED_INST
    ) loop  

        l_inst_number := ost_api_institution_pkg.get_inst_number(
                             i_inst_id => inst.id
                         );

        
        l_masking_card_in_file := set_ui_value_pkg.get_inst_param_n(
                                      i_param_name => 'MASKING_CARD_IN_DBAL_FILE'
                                    , i_inst_id    => inst.id
                                  );

        trc_log_pkg.debug(
            i_text       => 'process_unload_turnover, inst_id=[#1], inst_number=[#2], l_masking_card_in_file=[#3]'
          , i_env_param1 => inst.id
          , i_env_param2 => l_inst_number
          , i_env_param3 => l_masking_card_in_file
        );

        if l_include_service = com_api_type_pkg.TRUE then

            trc_log_pkg.debug(
                i_text => 'Get collection of services'
            );

            if l_full_export = com_api_type_pkg.TRUE then
            
                select prd_service_tpr(
                       s.id
                     , t.id  
                     , get_text ('prd_service_type', 'label', t.id, l_lang) 
                     , t.external_code
                     , s.service_number
                     , 1
                     , null  
                  )   
                  bulk collect into l_service_id_tab   
                  from prd_service_type t
                     , prd_service s
                 where t.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                   and (product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS or (i_unload_acquiring_accounts = com_api_const_pkg.TRUE and product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ))
                   and s.inst_id     = inst.id
                   and s.service_type_id = t.id;     
            else
            
                select prd_service_tpr(
                           s.id
                         , t.id  
                         , t.service_type_name
                         , t.external_code
                         , s.service_number
                         , t.is_active
                         , t.event_type 
                     )    
                  bulk collect into l_service_id_tab   
                  from prd_service s
                     , (  
                        select id
                             , enable_event_type event_type
                             , get_text ('prd_service_type', 'label', id, l_lang) service_type_name
                             , external_code
                             , 1 is_active
                          from prd_service_type 
                         where entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                           and (product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS or (i_unload_acquiring_accounts = com_api_const_pkg.TRUE and product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ))
                        union
                        select id
                             , disable_event_type event_type
                             , get_text ('prd_service_type', 'label', id, l_lang) service_type_name
                             , external_code
                             , 0 is_active
                          from prd_service_type st
                         where st.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                           and (product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS or (i_unload_acquiring_accounts = com_api_const_pkg.TRUE and product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ))
                    ) t
                where s.service_type_id = t.id
                  and s.inst_id     = inst.id;
                
            end if;
            
            trc_log_pkg.debug(
                i_text => 'Services collection created. Count = [#1], inst_id=[#2]'
              , i_env_param1 => l_service_id_tab.count
              , i_env_param2 => inst.id
            );

        end if;

        if l_full_export = com_api_type_pkg.TRUE then

            open all_account_cur(i_current_inst_id => inst.id);

            loop
                begin
                    savepoint sp_before_iteration;

                    fetch all_account_cur 
                     bulk collect into
                          l_account_id_tab
                    limit l_bulk_limit;

                    -- Generate XML file
                    generate_xml(i_current_inst_id => inst.id);

                    -- Commit the current iteration
                    commit;

                    exit when all_account_cur%notfound;

                exception
                    when others then
                        rollback to sp_before_iteration;
                        raise;
                end;
            end loop;

            close all_account_cur;

        else -- incremental export

            open evt_object_cur(i_current_inst_id => inst.id);

            loop
                begin
                    savepoint sp_before_iteration;

                    fetch evt_object_cur 
                     bulk collect into
                          l_fetched_event_object_id_tab
                        , l_fetched_account_id_tab
                        , l_fetched_split_hash_tab
                        , l_fetched_oper_id_tab
                    limit l_bulk_limit;

                    trc_log_pkg.debug(
                        i_text       => 'inst_id [#1], l_fetched_account_id_tab.count [#2] '
                      , i_env_param1 => inst.id
                      , i_env_param2 => l_fetched_account_id_tab.count
                    );

                    l_oper_count := 0;

                    for i in 1 .. l_fetched_account_id_tab.count loop

                        -- Add operations for account
                        if l_fetched_oper_id_tab(i) is not null then
                            l_oper_count := l_oper_count + 1;

                            -- Check limit for many payment operations
                            if l_oper_count <= PAYMENT_OPERATION_LIMIT then
                                l_oper_id_tab.extend;
                                l_oper_id_tab(l_oper_id_tab.count) := l_fetched_oper_id_tab(i);

                                l_event_oper_id_tab.extend;
                                l_event_oper_id_tab(l_event_oper_id_tab.count) := l_fetched_event_object_id_tab(i);
                            end if;
                        else
                            -- All events for every single account should be marked as processed
                            l_event_object_id_tab(l_event_object_id_tab.count + 1) := l_fetched_event_object_id_tab(i);
                        end if;
                        
                        -- Decrease account count and remove the last account id from previous iteration
                        if (l_fetched_account_id_tab(i) != l_account_id or l_account_id is null)
                           and l_fetched_account_id_tab(i) is not null
                        then
                            l_account_id := l_fetched_account_id_tab(i);
                            l_oper_count := 0;

                            l_account_id_tab.extend;
                            l_account_id_tab(l_account_id_tab.count) := l_fetched_account_id_tab(i);

                            if l_account_id_tab.count >= l_bulk_limit then
                                -- Generate XML file for current portion of the "l_bulk_limit" records
                                generate_xml(i_current_inst_id      => inst.id);

                                evt_api_event_pkg.process_event_object(
                                    i_event_object_id_tab => l_event_object_id_tab
                                );

                                -- process events for operations
                                evt_api_event_pkg.process_event_object(
                                    i_event_object_id_tab => l_event_oper_id_tab
                                );
                                trc_log_pkg.debug('processed events of operations l_event_oper_id_tab.count = ' || l_event_oper_id_tab.count);

                                l_account_id_tab.delete;
                                l_event_object_id_tab.delete;
                                l_oper_id_tab.delete;
                                l_event_oper_id_tab.delete;
                            end if;
                        end if;
                    end loop;

                    trc_log_pkg.debug('events were processed, cnt = ' || l_fetched_event_object_id_tab.count);

                    -- Commit the current iteration
                    commit;

                    exit when evt_object_cur%notfound;

                exception
                    when others then
                        rollback to sp_before_iteration;
                        raise;
                end;
            end loop;

            -- Generate XML file for last portion of records
            generate_xml(i_current_inst_id      => inst.id);

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab => l_event_object_id_tab
            );

            -- process events for operations by last accounts
            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab => l_event_oper_id_tab
            );

            close evt_object_cur;
                
        end if;      -- incremental export
    end loop; -- institution

    if l_estimated_count is null then
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => 0
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total  => nvl(l_processed_count, 0)
      , i_excepted_total   => 0
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('process_unload_turnover END: l_processed_count [' || l_processed_count || ']');

    -- Commit the last process changes before exit
    commit;

exception
    when others then
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        -- Commit the last process changes before exit
        commit;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end process_unload_turnover;

procedure unload_merchant_accounts(
    i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_full_export               in     com_api_type_pkg.t_boolean        default null
  , i_unload_limits             in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_count                     in     com_api_type_pkg.t_medium_id      default null
  , i_array_balance_type_id     in     com_api_type_pkg.t_medium_id      default null
  , i_include_service           in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_lang                      in     com_api_type_pkg.t_dict_value     default null
  , i_export_clear_pan          in     com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_array_account_type        in     com_api_type_pkg.t_dict_value     default null
  , i_replace_inst_id_by_number in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
) is
    BULK_LIMIT                     constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit                   com_api_type_pkg.t_count          := nvl(i_count, BULK_LIMIT);
    l_estimated_count              com_api_type_pkg.t_count          := 0;
    l_processed_count              com_api_type_pkg.t_count          := 0;
    l_total_file_count             com_api_type_pkg.t_count          := 0;
    l_file                         clob;
    l_file_type                    com_api_type_pkg.t_dict_value;
    l_container_id                 com_api_type_pkg.t_long_id        :=  prc_api_session_pkg.get_container_id;

    l_full_export                  com_api_type_pkg.t_boolean;
    l_unload_limits                com_api_type_pkg.t_boolean;
    l_include_service              com_api_type_pkg.t_boolean;
    l_export_clear_pan             com_api_type_pkg.t_boolean;
    l_params                       com_api_type_pkg.t_param_tab;

    l_fetched_event_object_id_tab  com_api_type_pkg.t_number_tab;
    l_fetched_account_id_tab       num_tab_tpt                       := num_tab_tpt();
    l_fetched_split_hash_tab       com_api_type_pkg.t_number_tab;

    l_event_object_id_tab          com_api_type_pkg.t_number_tab;
    l_account_id_tab               num_tab_tpt                       := num_tab_tpt();
    l_event_oper_id_tab            num_tab_tpt                       := num_tab_tpt();
    l_service_id_tab               prd_service_tpt                   := prd_service_tpt();

    l_account_id                   com_api_type_pkg.t_medium_id;
    l_sysdate                      date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_masking_card_in_file         com_api_type_pkg.t_boolean;
    l_inst_number                  com_api_type_pkg.t_mcc;

    cursor all_account_cur is
        select a.id
          from acc_account a
             , acc_account_type t
         where a.split_hash    in (select split_hash from com_api_split_map_vw)
           and a.inst_id        = i_inst_id
           and a.inst_id        = t.inst_id
           and a.account_type   = t.account_type
           and t.product_type  = prd_api_const_pkg.PRODUCT_TYPE_ACQ
           and (i_array_account_type is null or a.account_type in (select element_value from com_array_element el where el.array_id = FRONT_END_ACCOUNT_TYPES))
           and exists (select null
                         from acc_account_object ao
                        where ao.account_id  = a.id
                          and ao.split_hash  = a.split_hash
                          and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD)
        ;

    cursor evt_object_cur is
        select o.id
             , o.object_id     as account_id
             , o.split_hash
          from evt_event_object o
             , acc_account a
             , acc_account_type t
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.UNLOAD_MERCHANT_ACCOUNTS'
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and o.eff_date      <= l_sysdate
           and o.inst_id        = i_inst_id
           and a.id             = o.object_id
           and a.split_hash     = o.split_hash
           and a.inst_id        = o.inst_id
           and t.account_type   = a.account_type
           and t.inst_id        = a.inst_id
           and t.product_type  = prd_api_const_pkg.PRODUCT_TYPE_ACQ
           and (i_array_account_type is null or a.account_type in (select element_value from com_array_element el where el.array_id = FRONT_END_ACCOUNT_TYPES))
           and exists (select null
                         from acc_account_object ao
                        where ao.account_id  = a.id
                          and ao.split_hash  = a.split_hash
                          and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD)
       union all
        select o.id
             , ae.account_id
             , ae.split_hash
          from evt_event_object o
             , acc_entry ae
             , acc_account a
             , acc_account_type t
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.UNLOAD_MERCHANT_ACCOUNTS'
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ENTRY
           and o.eff_date      <= l_sysdate
           and o.inst_id        = i_inst_id
           and ae.id            = o.object_id+0
           and ae.split_hash    = o.split_hash
           and a.id             = ae.account_id
           and a.split_hash     = ae.split_hash
           and a.inst_id        = o.inst_id
           and t.account_type   = a.account_type
           and t.inst_id        = a.inst_id
           and t.product_type  = prd_api_const_pkg.PRODUCT_TYPE_ACQ
           and (i_array_account_type is null or a.account_type in (select element_value from com_array_element el where el.array_id = FRONT_END_ACCOUNT_TYPES))
           and exists (select null
                         from acc_account_object ao
                        where ao.account_id  = a.id
                          and ao.split_hash  = a.split_hash
                          and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD)
       union all
        select to_number(null) event_object_id
             , p.account_id
             , p.split_hash
          from evt_event_object o
             , opr_operation op
             , opr_participant p
             , acc_account a
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.UNLOAD_MERCHANT_ACCOUNTS'
           and o.split_hash      in (select split_hash from com_api_split_map_vw)
           and o.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and o.eff_date        <= l_sysdate
           and o.event_type       = opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY
           and op.id              = o.object_id
           and p.oper_id          = op.id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and p.inst_id          = i_inst_id
           and a.id               = p.account_id
           and (i_array_account_type is null or a.account_type in (select element_value from com_array_element el where el.array_id = FRONT_END_ACCOUNT_TYPES))
           and exists (select null
                         from acc_account_object ao
                        where ao.account_id  = a.id
                          and ao.split_hash  = a.split_hash
                          and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD)
       union all
        select o.id
             , a.id            as account_id
             , a.split_hash
          from evt_event_object o
             , prd_attribute_value av
             , prd_attribute pa
             , prd_service ps
             , prd_service_type st
             , prd_product pr
             , prd_contract c
             , acc_account a
             , acc_account_type t
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.UNLOAD_MERCHANT_ACCOUNTS'
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and o.entity_type    = prd_api_const_pkg.ENTITY_TYPE_PRODUCT_ATTR_VAL
           and o.eff_date      <= l_sysdate
           and o.inst_id        = i_inst_id
           and o.event_type     = prd_api_const_pkg.EVENT_ATTR_CHANGE_PRD_ATTR_LVL
           and av.id            = o.object_id
           and av.entity_type   = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
           and pa.id            = av.attr_id
           and pa.entity_type   = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
           and ps.id            = av.service_id
           and st.id            = ps.service_type_id
           and t.product_type  = prd_api_const_pkg.PRODUCT_TYPE_ACQ
           and st.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and pr.id            = av.object_id
           and c.product_id     = pr.id
           and l_sysdate between c.start_date and nvl(c.end_date, l_sysdate)
           and c.inst_id        = o.inst_id
           and exists (
                   select 1 
                     from prd_service_object so
                    where so.contract_id = c.id
                      and so.service_id  = ps.id
                      and l_sysdate between so.start_date and nvl(so.end_date, l_sysdate)
               )
           and a.customer_id    = c.customer_id
           and a.contract_id    = c.id
           and a.inst_id        = o.inst_id
           and a.split_hash     = c.split_hash
           and t.account_type   = a.account_type
           and t.inst_id        = a.inst_id
           and t.product_type   = st.product_type
           and (i_array_account_type is null or a.account_type in (select element_value from com_array_element el where el.array_id = FRONT_END_ACCOUNT_TYPES))
           and exists (select null
                         from acc_account_object ao
                        where ao.account_id  = a.id
                          and ao.split_hash  = a.split_hash
                          and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD)
      order by split_hash
             , account_id
        ;

    cursor main_limit_cur_xml is
        with products as (
            select connect_by_root id product_id
                 , level level_priority
                 , id parent_id
                 , product_type
                 , case when parent_id is null then 1 else 0 end top_flag
              from prd_product
           connect by prior parent_id = id
           --start with id = i_product_id
        )
        select
            xmlelement("accounts", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns")
              , xmlelement("file_type",     l_file_type)
              , xmlelement("date_purpose",  com_api_const_pkg.DATE_PURPOSE_PROCESSING)
              , xmlelement("start_date",    to_char(l_sysdate, 'yyyy-mm-dd'))
              , xmlelement("end_date",      to_char(l_sysdate, 'yyyy-mm-dd'))
              , xmlelement("inst_id",       case nvl(i_replace_inst_id_by_number, com_api_const_pkg.FALSE)
                                            when com_api_const_pkg.TRUE
                                            then l_inst_number
                                            else to_char(i_inst_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                                            end)
              , xmlelement("tokenized_pan", case l_export_clear_pan
                                                when com_api_const_pkg.FALSE
                                                then com_api_const_pkg.TRUE
                                                else com_api_const_pkg.FALSE
                                            end)
              , xmlagg(xmlelement("account", xmlattributes(g.account_id as "id")
                  , xmlelement("account_number",  min(g.account_number))
                  , xmlelement("currency",        min(g.currency))
                  , xmlelement("account_type",    min(g.account_type))
                  , xmlelement("account_status",  min(g.status))
                  , xmlelement("status_reason",
                        evt_api_status_pkg.get_status_reason(
                            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => g.account_id
                          , i_raise_error   => com_api_const_pkg.FALSE
                        )
                    )
                  , xmlelement("aval_balance",    min(g.aval_balance))
                  , xmlelement("create_date",     min(to_char(g.open_date, com_api_const_pkg.XML_DATE_FORMAT)))
                  , ( --xmlagg support only 1 level
                     select xmlagg(xmlelement("balance", xmlattributes(b.id as "id")
                              , xmlelement("balance_type", b.balance_type)
                              , xmlelement("turnover"
                                  , xmlelement("outgoing_balance", b.balance)
                                )
                            ))
                       from acc_balance b
                      where b.account_id = g.account_id
                        and b.split_hash = g.split_hash
                        and (i_array_balance_type_id is null
                             or b.balance_type in (select element_value
                                                     from com_array_element
                                                    where array_id = i_array_balance_type_id))
                    )
                  -- services  
                  , case when l_include_service = com_api_type_pkg.TRUE then 
                        case when l_full_export = com_api_type_pkg.TRUE then (
                            select xmlagg(
                                  xmlelement("service"
                                      , xmlelement("service_type",          s.service_type_id)
                                      , xmlelement("service_type_name",     s.service_type_name)
                                      , xmlelement("service_external_code", nvl(s.external_code, s.service_type_id))
                                      , xmlelement("service_number",        s.service_number)
                                      , xmlelement("is_active",             s.is_active)
                                      , (
                                            select xmlagg(
                                                        xmlelement("service_attribute"
                                                          , xmlelement("service_attribute_name",   attr.attr_name)                    
                                                          , xmlelement("service_attribute_value",  attr.attr_value)                    
                                                        )
                                                    )    
                                             from (
                                                 select attr_value
                                                       , row_number() over (partition by account_id, attr_name order by decode(level_priority, 0, 0, 1)
                                                                                                                              , level_priority
                                                                                                                              , start_date desc
                                                                                                                              , register_timestamp desc) rn
                                                       , account_id
                                                       , split_hash
                                                       , attr_name
                                                       , service_id
                                                    from (
                                                        select v.attr_value 
                                                             , 0 level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , v.object_id  account_id
                                                             , v.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from prd_attribute_value v
                                                             , prd_attribute a
                                                         where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                           and a.entity_type  is null 
                                                           and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and a.id           = v.attr_id
                                                           and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                     union all
                                                        select v.attr_value
                                                             , p.level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , ac.id  account_id
                                                             , ac.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from products p
                                                             , prd_attribute_value v
                                                             , prd_attribute a
                                                             , (select distinct id, service_type_id from table(cast(l_service_id_tab as prd_service_tpt))) srv
                                                             , prd_product_service ps
                                                             , prd_contract c
                                                             , acc_account ac
                                                         where v.service_id      = srv.id 
                                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                           and v.attr_id         = a.id
                                                           and a.service_type_id = srv.service_type_id
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                           and a.entity_type  is null 
                                                           and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and ps.service_id     = srv.id
                                                           and ps.service_id     = v.service_id                                              
                                                           and p.product_id      = ps.product_id                                           
                                                           and ps.product_id     = c.product_id
                                                           and c.id              = ac.contract_id
                                                           and c.split_hash      = ac.split_hash
                                                     ) tt
                                                  ) attr
                                              where attr.rn = 1
                                                and attr.service_id = s.id 
                                                and attr.account_id = b.object_id
                                                and attr.split_hash = b.split_hash
                                              )
                                      )             
                                  )  
                                  from table(cast(l_service_id_tab as prd_service_tpt)) s
                                     , prd_service_object b                       
                                 where b.service_id    = s.id
                                   and b.object_id     = g.account_id
                                   and b.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                   and b.split_hash    = g.split_hash                  
                            )
                        else ( --incremental
                            select xmlagg(
                                  xmlelement("service"
                                      , xmlelement("service_type",          s.service_type_id)
                                      , xmlelement("service_type_name",     s.service_type_name)
                                      , xmlelement("service_external_code", nvl(s.external_code, s.service_type_id))
                                      , xmlelement("service_number",        s.service_number)
                                      , xmlelement("is_active",             s.is_active)
                                      , (
                                            select xmlagg(
                                                        xmlelement("service_attribute"
                                                          , xmlelement("service_attribute_name",   attr.attr_name)                    
                                                          , xmlelement("service_attribute_value",  attr.attr_value)                    
                                                        )
                                                    )    
                                             from (
                                                 select attr_value
                                                       , row_number() over (partition by account_id, attr_name order by decode(level_priority, 0, 0, 1)
                                                                                                                              , level_priority
                                                                                                                              , start_date desc
                                                                                                                              , register_timestamp desc) rn
                                                       , account_id
                                                       , split_hash
                                                       , attr_name
                                                       , service_id
                                                    from (
                                                        select v.attr_value 
                                                             , 0 level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , v.object_id  account_id
                                                             , v.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from prd_attribute_value v
                                                             , prd_attribute a
                                                         where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                           and a.entity_type  is null 
                                                           and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and a.id           = v.attr_id
                                                           and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                     union all
                                                        select v.attr_value
                                                             , p.level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , ac.id  account_id
                                                             , ac.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from products p
                                                             , prd_attribute_value v
                                                             , prd_attribute a
                                                             , (select distinct id, service_type_id from table(cast(l_service_id_tab as prd_service_tpt))) srv
                                                             , prd_product_service ps
                                                             , prd_contract c
                                                             , acc_account ac
                                                         where v.service_id      = srv.id 
                                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                           and v.attr_id         = a.id
                                                           and a.service_type_id = srv.service_type_id
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                           and a.entity_type  is null 
                                                           and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and ps.service_id     = srv.id
                                                           and ps.service_id     = v.service_id                                              
                                                           and p.product_id      = ps.product_id                                           
                                                           and ps.product_id     = c.product_id
                                                           and c.id              = ac.contract_id
                                                           and c.split_hash      = ac.split_hash
                                                     ) tt
                                                  ) attr
                                              where attr.rn = 1
                                                and attr.service_id = s.id 
                                                and attr.account_id = b.object_id
                                                and attr.split_hash = b.split_hash
                                              )
                                      )             
                                  )  
                                  from evt_event_object o
                                     , table(cast(l_service_id_tab as prd_service_tpt)) s
                                     , prd_service_object b                       
                                 where o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                   and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.UNLOAD_MERCHANT_ACCOUNTS'
                                   and o.object_id     = g.account_id
                                   and o.split_hash    = g.split_hash 
                                   and o.eff_date     <= l_sysdate
                                   and s.event_type    = o.event_type
                                   and s.id            = b.service_id
                                   and o.object_id     = b.object_id
                                   and o.entity_type   = b.entity_type
                                   and o.split_hash    = b.split_hash   
                            )                                                  
                        end            
                  end
                  , itf_cst_account_export_pkg.generate_add_data(
                      i_account_id  => g.account_id
                   )
                  , com_api_flexible_data_pkg.generate_xml(
                        i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                      , i_object_id   => g.account_id
                    ) -- account flexible fields
                ))
            ).getclobval()
          , count(1)
       from (
          select f.id account_id
               , f.account_type
               , f.status
               , f.account_number
               , (
                 select nvl(
                            sum(t.aval_impact *
                                case
                                    when f.currency = b.currency
                                    then b.balance
                                    else com_api_rate_pkg.convert_amount(
                                             i_src_amount   => b.balance
                                           , i_src_currency => b.currency
                                           , i_dst_currency => f.currency
                                           , i_rate_type    => t.rate_type
                                           , i_inst_id      => f.inst_id
                                           , i_eff_date     => l_sysdate
                                         )
                                end)
                          , 0
                        )
                   from acc_balance_type t
                      , acc_balance b
                  where b.account_id   = f.id
                    and b.split_hash   = f.split_hash
                    and t.account_type = f.account_type
                    and t.inst_id      = f.inst_id
                    and t.aval_impact != 0
                    and t.balance_type = b.balance_type
               ) aval_balance
               , f.split_hash
               , f.currency
               , f.inst_id
               , (select min(open_date) from acc_balance where account_id = f.id and split_hash = f.split_hash) open_date
            from acc_account f
           where f.id in (select column_value from table(cast(l_account_id_tab as num_tab_tpt)))
        ) g
    group by g.account_id
           , g.split_hash
           , g.inst_id
        ;

    cursor main_cur_xml is
        with products as (
            select connect_by_root id product_id
                 , level level_priority
                 , id parent_id
                 , product_type
                 , case when parent_id is null then 1 else 0 end top_flag
              from prd_product
           connect by prior parent_id = id
           --start with id = i_product_id
        )
        select
            xmlelement("accounts", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns")
              , xmlelement("file_type",    l_file_type)
              , xmlelement("date_purpose", com_api_const_pkg.DATE_PURPOSE_PROCESSING)
              , xmlelement("start_date",   to_char(l_sysdate, 'yyyy-mm-dd'))
              , xmlelement("end_date",     to_char(l_sysdate, 'yyyy-mm-dd'))
              , xmlelement("inst_id",      case nvl(i_replace_inst_id_by_number, com_api_const_pkg.FALSE)
                                           when com_api_const_pkg.TRUE
                                           then l_inst_number
                                           else to_char(i_inst_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                                           end)
              , xmlelement("tokenized_pan", case l_export_clear_pan
                                            when com_api_const_pkg.FALSE
                                            then com_api_const_pkg.TRUE
                                            else com_api_const_pkg.FALSE
                                            end)
              , xmlagg(xmlelement("account", xmlattributes(g.account_id as "id")
                  , xmlelement("account_number",  min(g.account_number))
                  , xmlelement("currency",        min(g.account_currency))
                  , xmlelement("account_type",    min(g.account_type))
                  , xmlelement("account_status",  min(g.status))
                  , xmlelement("status_reason",
                        evt_api_status_pkg.get_status_reason(
                            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => g.account_id
                          , i_raise_error   => com_api_const_pkg.FALSE
                        )
                    )
                  , xmlelement("aval_balance",    min(g.aval_balance))
                  , xmlelement("create_date",     min(to_char(g.open_date, com_api_const_pkg.XML_DATE_FORMAT)))
                  , xmlagg(xmlelement("balance", xmlattributes(g.balance_id as "id")
                      , xmlelement("balance_type", g.balance_type)
                      , xmlelement("turnover"
                          , xmlelement("outgoing_balance", g.balance)
                        )
                    ))
                  -- services  
                  , case when l_include_service = com_api_type_pkg.TRUE then 
                        case when l_full_export = com_api_type_pkg.TRUE then (
                            select xmlagg(
                                  xmlelement("service"
                                      , xmlelement("service_type",          s.service_type_id)
                                      , xmlelement("service_type_name",     s.service_type_name)
                                      , xmlelement("service_external_code", nvl(s.external_code, s.service_type_id))
                                      , xmlelement("service_number",        s.service_number)
                                      , xmlelement("is_active",             s.is_active)
                                      , (
                                            select xmlagg(
                                                        xmlelement("service_attribute"
                                                          , xmlelement("service_attribute_name",   attr.attr_name)                    
                                                          , xmlelement("service_attribute_value",  attr.attr_value)                    
                                                        )
                                                    )    
                                             from (
                                                 select attr_value
                                                       , row_number() over (partition by account_id, attr_name order by decode(level_priority, 0, 0, 1)
                                                                                                                              , level_priority
                                                                                                                              , start_date desc
                                                                                                                              , register_timestamp desc) rn
                                                       , account_id
                                                       , split_hash
                                                       , attr_name
                                                       , service_id
                                                    from (
                                                        select v.attr_value 
                                                             , 0 level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , v.object_id  account_id
                                                             , v.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from prd_attribute_value v
                                                             , prd_attribute a
                                                         where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                           and a.entity_type  is null 
                                                           and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and a.id           = v.attr_id
                                                           and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                     union all
                                                        select v.attr_value
                                                             , p.level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , ac.id  account_id
                                                             , ac.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from products p
                                                             , prd_attribute_value v
                                                             , prd_attribute a
                                                             , (select distinct id, service_type_id from table(cast(l_service_id_tab as prd_service_tpt))) srv
                                                             , prd_product_service ps
                                                             , prd_contract c
                                                             , acc_account ac
                                                         where v.service_id      = srv.id 
                                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                           and v.attr_id         = a.id
                                                           and a.service_type_id = srv.service_type_id
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                           and a.entity_type  is null 
                                                           and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and ps.service_id     = srv.id
                                                           and ps.service_id     = v.service_id                                              
                                                           and p.product_id      = ps.product_id                                           
                                                           and ps.product_id     = c.product_id
                                                           and c.id              = ac.contract_id
                                                           and c.split_hash      = ac.split_hash
                                                     ) tt
                                                  ) attr
                                              where attr.rn = 1
                                                and attr.service_id = s.id 
                                                and attr.account_id = b.object_id
                                                and attr.split_hash = b.split_hash
                                              )
                                      )             
                                  )  
                                  from table(cast(l_service_id_tab as prd_service_tpt)) s
                                     , prd_service_object b                       
                                 where b.service_id    = s.id
                                   and b.object_id     = g.account_id
                                   and b.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                   and b.split_hash    = g.split_hash                  
                            )
                        else ( --incremental
                            select xmlagg(
                                  xmlelement("service"
                                      , xmlelement("service_type",          s.service_type_id)
                                      , xmlelement("service_type_name",     s.service_type_name)
                                      , xmlelement("service_external_code", nvl(s.external_code, s.service_type_id))
                                      , xmlelement("service_number",        s.service_number)
                                      , xmlelement("is_active",             s.is_active)
                                      , (
                                            select xmlagg(
                                                        xmlelement("service_attribute"
                                                          , xmlelement("service_attribute_name",   attr.attr_name)                    
                                                          , xmlelement("service_attribute_value",  attr.attr_value)                    
                                                        )
                                                    )    
                                             from (
                                                 select attr_value
                                                       , row_number() over (partition by account_id, attr_name order by decode(level_priority, 0, 0, 1)
                                                                                                                              , level_priority
                                                                                                                              , start_date desc
                                                                                                                              , register_timestamp desc) rn
                                                       , account_id
                                                       , split_hash
                                                       , attr_name
                                                       , service_id
                                                    from (
                                                        select v.attr_value 
                                                             , 0 level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , v.object_id  account_id
                                                             , v.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from prd_attribute_value v
                                                             , prd_attribute a
                                                         where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                           and a.entity_type  is null 
                                                           and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and a.id           = v.attr_id
                                                           and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                     union all
                                                        select v.attr_value
                                                             , p.level_priority
                                                             , a.object_type 
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , ac.id  account_id
                                                             , ac.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from products p
                                                             , prd_attribute_value v
                                                             , prd_attribute a
                                                             , (select distinct id, service_type_id from table(cast(l_service_id_tab as prd_service_tpt))) srv
                                                             , prd_product_service ps
                                                             , prd_contract c
                                                             , acc_account ac
                                                         where v.service_id      = srv.id 
                                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                           and v.attr_id         = a.id
                                                           and a.service_type_id = srv.service_type_id
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                           and a.entity_type  is null 
                                                           and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
                                                           and ps.service_id     = srv.id
                                                           and ps.service_id     = v.service_id                                              
                                                           and p.product_id      = ps.product_id                                           
                                                           and ps.product_id     = c.product_id
                                                           and c.id              = ac.contract_id
                                                           and c.split_hash      = ac.split_hash
                                                     ) tt
                                                  ) attr
                                              where attr.rn = 1
                                                and attr.service_id = s.id 
                                                and attr.account_id = b.object_id
                                                and attr.split_hash = b.split_hash
                                              )
                                      )             
                                  )  
                                  from evt_event_object o
                                     , table(cast(l_service_id_tab as prd_service_tpt)) s
                                     , prd_service_object b                       
                                 where o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                   and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.UNLOAD_MERCHANT_ACCOUNTS'
                                   and o.object_id     = g.account_id
                                   and o.split_hash    = g.split_hash 
                                   and o.eff_date     <= l_sysdate
                                   and s.event_type    = o.event_type
                                   and s.id            = b.service_id
                                   and o.object_id     = b.object_id
                                   and o.entity_type   = b.entity_type
                                   and o.split_hash    = b.split_hash   
                            )                                                  
                        end            
                  end
                  , itf_cst_account_export_pkg.generate_add_data(
                      i_account_id  => g.account_id
                   )
                ))
            ).getclobval()
          , count(1)
       from (
          select f.account_id
              , f.currency balance_currency
              , f.account_type
              , f.status
              , f.account_number
              , f.balance_type
              , f.balance_id
              , f.balance
              , (
                  select nvl(
                             sum(t.aval_impact *
                                 case
                                     when f.account_currency = b.currency
                                     then b.balance
                                     else com_api_rate_pkg.convert_amount(
                                              i_src_amount   => b.balance
                                            , i_src_currency => b.currency
                                            , i_dst_currency => f.account_currency
                                            , i_rate_type    => t.rate_type
                                            , i_inst_id      => f.inst_id
                                            , i_eff_date     => l_sysdate
                                          )
                                 end)
                           , 0
                         )
                  from acc_balance_type t
                     , acc_balance b
                 where b.account_id   = f.account_id
                   and b.split_hash   = f.split_hash
                   and t.account_type = f.account_type
                   and t.inst_id      = f.inst_id
                   and t.aval_impact != 0
                   and t.balance_type = b.balance_type
              ) aval_balance
              , f.split_hash
              , f.inst_id account_inst_id
              , f.account_currency
              , f.inst_id
              , f.open_date
            from (
                    select a.id account_id
                         , a.currency account_currency
                         , a.account_type
                         , a.status
                         , a.account_number
                         , a.inst_id
                         , a.split_hash
                         , ab.id as balance_id
                         , ab.balance_type
                         , ab.currency
                         , ab.balance
                         , ab.open_date
                      from acc_account a
                         , acc_balance ab
                     where a.id in (select column_value from table(cast(l_account_id_tab as num_tab_tpt)))
                       and ab.split_hash  = a.split_hash
                       and ab.account_id  = a.id
                    and (i_array_balance_type_id is null
                         or
                         ab.balance_type in (select element_value
                                               from com_array_element
                                              where array_id = i_array_balance_type_id))
               ) f
           ) g
    group by g.account_id
           , g.split_hash
           , g.inst_id
        ;

    procedure save_file(
        i_counter           in     com_api_type_pkg.t_count
    ) is
        l_report_id                com_api_type_pkg.t_short_id;
        l_report_template_id       com_api_type_pkg.t_short_id;
    begin
        trc_log_pkg.debug('Creating a new XML file, count=' || i_counter);

        l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_inst_id
            , io_params  => l_params
        );

        l_total_file_count := l_total_file_count + 1;

        rul_api_param_pkg.set_param(
            i_name    => 'FILE_NUMBER'
          , i_value   => l_total_file_count
          , io_params => l_params
        );

        rul_api_param_pkg.set_param(
            i_name    => 'FILE_COUNT'
          , i_value   => prc_api_const_pkg.NAME_PART_FILE_COUNT
          , io_params => l_params
        );

        prc_api_file_pkg.save_file (
            i_file_type           => l_file_type
          , io_params             => l_params
          , o_report_id           => l_report_id
          , o_report_template_id  => l_report_template_id
          , i_clob_content        => l_file
          , i_status              => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count        => i_counter
        );

        trc_log_pkg.debug('file saved, count=' || i_counter || ', length=' || length(l_file));

    end save_file;

    -- Generate XML file
    procedure generate_xml is
        l_fetched_count        com_api_type_pkg.t_count    := 0;
    begin
        if l_account_id_tab.count > 0 then

            l_estimated_count := l_estimated_count + l_account_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
              , i_measure         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            );
            trc_log_pkg.debug('Estimated count of accounts is [' || l_estimated_count || ']');

            -- For every processing batch of accounts we fetch data and save it in a separate file
            if l_unload_limits = com_api_type_pkg.TRUE then
                open  main_limit_cur_xml;
                fetch main_limit_cur_xml into l_file, l_fetched_count;
                close main_limit_cur_xml;
            else
                open  main_cur_xml;
                fetch main_cur_xml into l_file, l_fetched_count;
                close main_cur_xml;
            end if;

            trc_log_pkg.debug('l_fetched_count = ' || l_fetched_count);

            save_file(
                    i_counter     => l_fetched_count
                );

            l_processed_count := l_processed_count + l_fetched_count;

            prc_api_stat_pkg.log_current (
                i_current_count   => l_processed_count
              , i_excepted_count  => 0
            );

        end if;
    end generate_xml;

begin
    l_inst_number := ost_api_institution_pkg.get_inst_number(
                         i_inst_id => i_inst_id
                     );

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_full_export     := nvl(i_full_export,     com_api_const_pkg.FALSE);
    l_unload_limits   := nvl(i_unload_limits,   com_api_const_pkg.FALSE);
    l_include_service := nvl(i_include_service, com_api_const_pkg.FALSE);

    l_sysdate         := com_api_sttl_day_pkg.get_sysdate;
    l_lang            := nvl(i_lang, com_ui_user_env_pkg.get_user_lang());

    -- If tokenization isn't used then there is no sense to call decoding function
    -- in then select section to reduce count of SQL-PLSQL context switches
    l_export_clear_pan :=
        case
            when iss_api_token_pkg.is_token_enabled() = com_api_const_pkg.TRUE
            then nvl(i_export_clear_pan, com_api_const_pkg.TRUE)
            else com_api_const_pkg.FALSE
        end;

    l_masking_card_in_file := set_ui_value_pkg.get_inst_param_n(
                                  i_param_name => 'MASKING_CARD_IN_DBAL_FILE'
                                , i_inst_id    => i_inst_id
                              );

    trc_log_pkg.debug(
        i_text       => 'process_unload_turnover START: file_type [#1], l_unload_limits [' || l_unload_limits
                     || '], thread_number [' || get_thread_number()
                     || '], l_container_id [' || l_container_id
                     || '], l_full_export [' || l_full_export
                     || '], l_sysdate [' || to_char(l_sysdate, 'dd.mm.yyyy hh24:mi:ss')
                     || '], l_export_clear_pan [' || l_export_clear_pan || ']'
                     || '], l_masking_card_in_file [' || l_masking_card_in_file || ']'
      , i_env_param1 => l_file_type
    );
    trc_log_pkg.debug(
        i_text => 'process_unload_turnover, l_include_service=#1, l_lang=#2'
      , i_env_param1 => l_include_service
      , i_env_param2 => l_lang
    );
    
    prc_api_stat_pkg.log_start;

    if l_include_service = com_api_type_pkg.TRUE then

        trc_log_pkg.debug(
            i_text => 'Get collection of services'
        );

        if l_full_export = com_api_type_pkg.TRUE then
        
            select prd_service_tpr(
                   s.id
                 , t.id  
                 , get_text ('prd_service_type', 'label', t.id, l_lang) 
                 , t.external_code
                 , s.service_number
                 , 1
                 , null  
              )   
              bulk collect into l_service_id_tab   
              from prd_service_type t
                 , prd_service s
             where entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
               and product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ --'PRDT0200'
               and s.service_type_id = t.id;     
        else
        
            select prd_service_tpr(
                       s.id
                     , t.id  
                     , t.service_type_name
                     , t.external_code
                     , s.service_number
                     , t.is_active
                     , t.event_type 
                 )    
              bulk collect into l_service_id_tab   
              from prd_service s
                 , (  
                    select id
                         , enable_event_type event_type
                         , get_text ('prd_service_type', 'label', id, l_lang) service_type_name
                         , external_code
                         , 1 is_active
                      from prd_service_type 
                     where entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                       and product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ --'PRDT0200'
                    union
                    select id
                         , disable_event_type event_type
                         , get_text ('prd_service_type', 'label', id, l_lang) service_type_name
                         , external_code
                         , 0 is_active
                      from prd_service_type 
                     where entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                       and product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ --'PRDT0200'
                ) t
            where s.service_type_id = t.id;
            
        end if;
        
        trc_log_pkg.debug(
            i_text => 'Collection created. Count = ' || l_service_id_tab.count
        );

    end if;

    if l_full_export = com_api_type_pkg.TRUE then

        open all_account_cur;

        loop
            begin
                savepoint sp_before_iteration;

                fetch all_account_cur bulk collect into
                      l_account_id_tab
                limit l_bulk_limit;

                -- Generate XML file
                generate_xml;

                -- Commit the current iteration
                commit;

                exit when all_account_cur%notfound;

            exception
                when others then
                    rollback to sp_before_iteration;
                    raise;
            end;
        end loop;

        close all_account_cur;

    else -- incremental export

        open evt_object_cur;

        loop
            begin
                savepoint sp_before_iteration;

                fetch evt_object_cur bulk collect into
                      l_fetched_event_object_id_tab
                    , l_fetched_account_id_tab
                    , l_fetched_split_hash_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('l_fetched_account_id_tab.count  = ' || l_fetched_account_id_tab.count);

                for i in 1 .. l_fetched_account_id_tab.count loop
                    -- All events for every single account should be marked as processed
                    if l_fetched_event_object_id_tab(i) is not null then
                        l_event_object_id_tab(l_event_object_id_tab.count + 1) := l_fetched_event_object_id_tab(i);
                    end if;
                    
                    -- Decrease account count and remove the last account id from previous iteration
                    if (l_fetched_account_id_tab(i) != l_account_id or l_account_id is null)
                       and l_fetched_account_id_tab(i) is not null
                    then
                        l_account_id := l_fetched_account_id_tab(i);

                        l_account_id_tab.extend;
                        l_account_id_tab(l_account_id_tab.count) := l_fetched_account_id_tab(i);

                        if l_account_id_tab.count >= l_bulk_limit then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_event_object_id_tab
                            );

                            -- process events for operations
                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_event_oper_id_tab
                            );
                            trc_log_pkg.debug('processed events of operations l_event_oper_id_tab.count = ' || l_event_oper_id_tab.count);

                            l_account_id_tab.delete;
                            l_event_object_id_tab.delete;
                        end if;
                    end if;
                end loop;

                trc_log_pkg.debug('events were processed, cnt = ' || l_fetched_event_object_id_tab.count);

                -- Commit the current iteration
                commit;

                exit when evt_object_cur%notfound;

            exception
                when others then
                    rollback to sp_before_iteration;
                    raise;
            end;
        end loop;

        -- Generate XML file for last portion of records
        generate_xml;

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_object_id_tab
        );

        -- process events for operations by last accounts
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_oper_id_tab
        );

        close evt_object_cur;
            
    end if;      -- incremental export

    prc_api_file_pkg.change_file_names_in_thread(
        i_session_id       => get_session_id
      , i_thread_number    => get_thread_number
      , i_total_file_count => l_total_file_count
    );

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_processed_count
      , i_excepted_total   => 0
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('process_unload_turnover END: l_processed_count [' || l_processed_count || ']');

    -- Commit the last process changes before exit
    commit;

exception
    when others then
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        -- Commit the last process changes before exit
        commit;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;

end unload_merchant_accounts;

end itf_prc_account_export_pkg;
/
