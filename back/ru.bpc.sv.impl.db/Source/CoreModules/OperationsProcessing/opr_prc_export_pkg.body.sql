create or replace package body opr_prc_export_pkg is
/************************************************************
 * Export operation process <br />
 * Created by Kopachev D.(kopachev@bpc.ru)  at 18.10.2013 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-10-28 11:47:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 27843 $ <br />
 * Module: OPR_PRC_EXPORT_PKG <br />
 * @headcom
 *************************************************************/

g_inst_flag_tab                com_api_type_pkg.t_boolean_tab;

procedure remain_active_inst_param(
    io_inst_flag_tab   in out nocopy com_api_type_pkg.t_boolean_tab
) is
    l_inst_id             com_api_type_pkg.t_inst_id;
begin
    if io_inst_flag_tab.count > 0 then
        l_inst_id := io_inst_flag_tab.first;
        while l_inst_id is not null
        loop
            if nvl(io_inst_flag_tab(l_inst_id), com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                io_inst_flag_tab.delete(l_inst_id);
            end if;
            l_inst_id := io_inst_flag_tab.next(l_inst_id);
        end loop;
    end if;
end remain_active_inst_param;

function check_inst_id(i_inst_id  in com_api_type_pkg.t_inst_id)
return com_api_type_pkg.t_boolean
is
begin
    return case
               when g_inst_flag_tab.exists(i_inst_id)
                and g_inst_flag_tab(i_inst_id) = com_api_const_pkg.TRUE
               then com_api_const_pkg.TRUE
               else com_api_const_pkg.FALSE
            end;
end check_inst_id;

procedure upload_operation(
    i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
  , i_start_date                in     date                             default null
  , i_end_date                  in     date                             default null
  , i_upl_oper_event_type       in     com_api_type_pkg.t_dict_value    default null
  , i_terminal_type             in     com_api_type_pkg.t_dict_value    default null
  , i_full_export               in     com_api_type_pkg.t_boolean       default null
  , i_load_successfull          in     com_api_type_pkg.t_dict_value    default null
  , i_include_auth              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_include_clearing          in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_masking_card              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_process_container         in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_session_id                in     com_api_type_pkg.t_long_id       default null
  , i_split_files               in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_reversal_upload_type      in     com_api_type_pkg.t_dict_value    default null
  , i_array_operations_type_id  in     com_api_type_pkg.t_medium_id     default null
  , i_count                     in     com_api_type_pkg.t_medium_id     default null
  , i_array_account_type_cbs    in     com_api_type_pkg.t_medium_id     default null
  , i_array_trans_type_id       in     com_api_type_pkg.t_medium_id     default null
  , i_array_balance_type_id     in     com_api_type_pkg.t_medium_id     default null
  , i_include_additional_amount in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_include_canceled_entries  in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) ||'.upload_operation: ';
    DATETIME_FORMAT       constant com_api_type_pkg.t_name         := 'dd.mm.yyyy hh24:mi:ss';

    BULK_LIMIT            constant com_api_type_pkg.t_count        := 2000;
    l_bulk_limit                   com_api_type_pkg.t_count        := nvl(i_count, BULK_LIMIT);
    cur_objects                    sys_refcursor;
    l_file                         clob;

    l_session_file_id              com_api_type_pkg.t_long_id;
    l_sysdate                      date;
    l_params                       com_api_type_pkg.t_param_tab;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_min_date                     date;
    l_max_date                     date;
    l_full_export                  com_api_type_pkg.t_boolean;
    l_load_successfull             com_api_type_pkg.t_dict_value;
    l_include_auth                 com_api_type_pkg.t_boolean;
    l_include_clearing             com_api_type_pkg.t_boolean;
    l_include_canceled_entries     com_api_type_pkg.t_boolean;

    l_fetched_event_object_id_tab  num_tab_tpt                     := num_tab_tpt();
    l_fetched_oper_id_tab          num_tab_tpt                     := num_tab_tpt();
    l_event_object_id_tab          num_tab_tpt                     := num_tab_tpt();
    l_oper_id_tab                  num_tab_tpt                     := num_tab_tpt();
    l_oper_id                      com_api_type_pkg.t_long_id;
    l_estimated_count              com_api_type_pkg.t_long_id;
    l_processed_count              com_api_type_pkg.t_long_id      := 0;
    l_session_id_tab               num_tab_tpt                     := num_tab_tpt();
    l_process_session_id           com_api_type_pkg.t_long_id;
    l_use_session_id               com_api_type_pkg.t_boolean      := com_api_const_pkg.FALSE;
    l_incom_sess_file_id_tab       num_tab_tpt                     := num_tab_tpt();
    l_incom_sess_file_id           com_api_type_pkg.t_long_id;
    l_split_files                  com_api_type_pkg.t_boolean      := com_api_const_pkg.FALSE;
    l_reversal_upload_type         com_api_type_pkg.t_dict_value;
    l_thread_number                com_api_type_pkg.t_tiny_id;
    l_splitted_file_count          com_api_type_pkg.t_count        := 1;
    l_total_file_count             com_api_type_pkg.t_count        := 0;
    l_original_file_name           com_api_type_pkg.t_name;
    l_entry_id_tab                 com_api_type_pkg.t_long_tab;
    l_inst_id_tab                  com_api_type_pkg.t_inst_id_tab;
    l_split_hash_tab               com_api_type_pkg.t_tiny_tab;

    l_array_operations_type_list   com_api_type_pkg.t_full_desc;
    l_array_account_type_list      com_api_type_pkg.t_full_desc;
    l_array_trans_type_list        com_api_type_pkg.t_full_desc;  

    cursor cur_entry is
        select ae.id
             , ac.inst_id
             , ac.split_hash
          from opr_operation oo
             , acc_macros    am
             , acc_entry     ae
             , acc_account   ac
         where oo.id          in (select column_value from table(cast(l_oper_id_tab as num_tab_tpt)))
           and oo.id           = am.object_id
           and am.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and am.id           = ae.macros_id
           and ae.account_id   = ac.id
           and (ae.status     != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
           and (i_array_trans_type_id    is null or instr(l_array_trans_type_list,   ae.transaction_type) != 0)
           and (i_array_account_type_cbs is null or instr(l_array_account_type_list, ac.account_type)     != 0)
           and (i_array_balance_type_id  is null or ae.balance_type in (select element_value from com_array_element where array_id = i_array_balance_type_id));

    cursor cur_xml is
        select
            count(o.id) as current_count
          , com_api_const_pkg.XML_HEADER ||
            xmlelement("clearing"
              , xmlattributes('http://bpc.ru/sv/SVXP/clearing' as "xmlns")
              , xmlforest(
                    to_char(l_session_file_id, 'TM9')                                   as "file_id"
                  , opr_api_const_pkg.FILE_TYPE_UNLOADING                               as "file_type"
                  , to_char(i_start_date, com_api_const_pkg.XML_DATE_FORMAT)            as "start_date"
                  , to_char(i_end_date, com_api_const_pkg.XML_DATE_FORMAT)              as "end_date"
                  , i_inst_id                                                           as "inst_id"
                )
              , xmlagg(
                    xmlelement("operation"
                      , xmlforest(
                            to_char(o.id, com_api_const_pkg.XML_NUMBER_FORMAT)          as "oper_id"
                          , o.oper_type                                                 as "oper_type"
                          , o.msg_type                                                  as "msg_type"
                          , o.sttl_type                                                 as "sttl_type"
                          , o.original_id                                               as "original_id"
                          , to_char(o.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "oper_date"
                          , to_char(o.host_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "host_date"
                          , to_char(o.oper_count, com_api_const_pkg.XML_NUMBER_FORMAT)  as "oper_count"
                          , case when o.oper_amount is not null then
                                 xmlforest(
                                     o.oper_amount           as "amount_value"
                                   , o.oper_currency         as "currency"
                                 )
                            end                                                         as "oper_amount"
                          , case when o.oper_request_amount is not null then
                                 xmlforest(
                                     o.oper_request_amount   as "amount_value"
                                   , o.oper_currency         as "currency"
                                 )
                            end                                                         as "oper_request_amount"
                          , case when o.oper_surcharge_amount is not null then
                                 xmlforest(
                                     o.oper_surcharge_amount as "amount_value"
                                   , o.oper_currency         as "currency"
                                 )
                            end                                                         as "oper_surcharge_amount"
                          , case when o.oper_cashback_amount is not null then
                                 xmlforest(
                                     o.oper_cashback_amount   as "amount_value"
                                   , o.oper_currency          as "currency"
                                 )
                            end                                                         as "oper_cashback_amount"
                          , case when o.sttl_amount is not null then
                                 xmlforest(
                                     o.sttl_amount            as "amount_value"
                                   , o.sttl_currency          as "currency"
                                 )
                            end                                                         as "sttl_amount"
                          , case when o.fee_amount is not null then
                                 xmlforest(
                                     o.fee_amount            as "amount_value"
                                   , o.fee_currency          as "currency"
                                 )
                            end                                                             as "interchange_fee"
                          , o.originator_refnum                                             as "originator_refnum"
                          , o.network_refnum                                                as "network_refnum"
                          , o.acq_inst_bin                                                  as "acq_inst_bin"
                          , o.forw_inst_bin                                                 as "forwarding_inst_bin"
                            --
                          , case o.status_reason
                                when aut_api_const_pkg.AUTH_REASON_DUE_TO_RESP_CODE
                                then (select a.resp_code    from aut_auth a where a.id = o.id)
                                when aut_api_const_pkg.AUTH_REASON_DUE_TO_COMPLT_FLAG
                                then (select a.is_completed from aut_auth a where a.id = o.id)
                                else o.status_reason                                           
                            end                                                             as "response_code"                                            
                            --
                          , o.oper_reason                                                   as "oper_reason"
                          , o.status                                                        as "status"
                          , o.is_reversal                                                   as "is_reversal"
                          , o.merchant_number                                               as "merchant_number"
                          , o.mcc                                                           as "mcc"
                          , o.merchant_name                                                 as "merchant_name"
                          , o.merchant_street                                               as "merchant_street"
                          , o.merchant_city                                                 as "merchant_city"
                          , o.merchant_region                                               as "merchant_region"
                          , o.merchant_country                                              as "merchant_country"
                          , o.merchant_postcode                                             as "merchant_postcode"
                            --
                          , case o.terminal_type
                                when acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS
                                then acq_api_const_pkg.TERMINAL_TYPE_POS
                                else o.terminal_type
                            end                                                                       as "terminal_type"
                            --
                          , o.terminal_number                                                         as "terminal_number"
                          , to_char(o.sttl_date,               com_api_const_pkg.XML_DATETIME_FORMAT) as "sttl_date"
                          , to_char(o.acq_sttl_date,           com_api_const_pkg.XML_DATETIME_FORMAT) as "acq_sttl_date"
                          , to_char(o.match_id,                com_api_const_pkg.XML_NUMBER_FORMAT)   as "match_id"
                          , to_char(o.clearing_sequence_num,   com_api_const_pkg.XML_NUMBER_FORMAT)   as "clearing_sequence_num"
                          , to_char(o.clearing_sequence_count, com_api_const_pkg.XML_NUMBER_FORMAT)   as "clearing_sequence_count"
                        ) -- xmlforest
                        --
                      , (select
                             xmlelement("payment_order"
                               , xmlforest(
                                     po.id                as "payment_order_id"
                                   , po.status            as "payment_order_status"
                                   , po.purpose_id        as "purpose_id"
                                   , pp.purpose_number    as "purpose_number"
                                   , xmlforest(
                                         po.amount            as "amount_value"
                                       , po.currency          as "currency"
                                     ) as "payment_amount"
                                   , po.event_date        as "payment_date"
                                 )
                               , (select xmlagg(
                                             xmlelement("payment_parameter"
                                               , xmlforest(
                                                     xp.param_name    as "payment_parameter_name"
                                                   , xod.param_value  as "payment_parameter_value"
                                                 )
                                             ) 
                                         )
                                    from pmo_parameter xp
                                    join pmo_order_data xod on xod.param_id = xp.id
                                   where xod.order_id = po.id
                                 ) -- payment_parameter
                               , (select xmlagg(
                                             xmlelement("document"
                                               , d.id                 as "document_id"
                                               , d.document_type      as "document_type"
                                               , to_char(d.document_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "document_date"
                                               , d.document_number    as "document_number"
                                               , xmlagg(
                                                     case when dc.document_content is not null then
                                                         xmlelement("document_content"
                                                           , xmlforest(
                                                                 dc.content_type                                     as "content_type"
                                                               , com_api_hash_pkg.base64_encode(dc.document_content) as "content"
                                                             )
                                                         )
                                                     end
                                                 )
                                             ) -- document
                                         )
                                    from rpt_document d
                                    left join rpt_document_content dc on dc.document_id = d.id
                                   where d.object_id = po.id
                                     and d.entity_type = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                                   group by
                                         d.id
                                       , d.document_type
                                       , d.document_date
                                       , d.document_number
                                 ) -- document
                             ) -- payment_order
                          from pmo_order po
                          left join pmo_purpose pp on pp.id = po.purpose_id
                         where po.id = o.payment_order_id
                        )
                        --
                      , (select
                             xmlagg(
                                 xmlelement("transaction"
                                   , xmlelement("transaction_id",   ae.transaction_id)
                                   , xmlelement("transaction_type", ae.transaction_type)
                                   , xmlelement("posting_date",     to_char(min(ae.posting_date), com_api_const_pkg.XML_DATETIME_FORMAT))
                                   , (select xmlagg(
                                                 xmlelement("debit_entry"
                                                   , xmlelement("entry_id",           dae.id)
                                                   , xmlelement("status",             dae.status)
                                                   , xmlelement("account"
                                                       , xmlelement("account_number", da.account_number)
                                                       , xmlelement("currency",       da.currency)
                                                       , xmlelement("balance_type",   dae.balance_type)
                                                       , xmlelement("agent_number",   (select doa.agent_number from ost_agent doa where doa.id = da.agent_id))
                                                     )
                                                   , xmlelement("amount"
                                                       , xmlelement("amount_value",   dae.amount)
                                                       , xmlelement("currency",       dae.currency)
                                                     )
                                                   , xmlforest(case check_inst_id(i_inst_id  => da.inst_id)
                                                                   when com_api_const_pkg.TRUE then dae.is_settled
                                                                   else null
                                                                end as "is_settled")
                                                 )
                                             )
                                        from acc_entry   dae
                                        join acc_account da     on da.id  = dae.account_id
                                       where dae.transaction_id  = ae.transaction_id
                                         and dae.balance_impact  = com_api_const_pkg.DEBIT
                                         and (dae.status        != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                                         and (i_array_trans_type_id    is null or instr(l_array_trans_type_list,   dae.transaction_type) != 0)
                                         and (i_array_account_type_cbs is null or instr(l_array_account_type_list, da.account_type)      != 0)
                                         and (i_array_balance_type_id  is null or dae.balance_type in (select element_value from com_array_element where array_id = i_array_balance_type_id))
                                     ) -- debit entry
                                   , (select xmlagg(
                                                 xmlelement("credit_entry"
                                                   , xmlelement("entry_id",           cae.id)
                                                   , xmlelement("status",             cae.status)
                                                   , xmlelement("account"
                                                       , xmlelement("account_number", ca.account_number)
                                                       , xmlelement("currency",       ca.currency)
                                                       , xmlelement("balance_type",   cae.balance_type)
                                                       , xmlelement("agent_number",   (select coa.agent_number from ost_agent coa where coa.id = ca.agent_id))
                                                     )
                                                   , xmlelement("amount"
                                                       , xmlelement("amount_value", cae.amount)
                                                       , xmlelement("currency", cae.currency)
                                                     )
                                                   , xmlforest(case check_inst_id(i_inst_id  => ca.inst_id)
                                                                   when com_api_const_pkg.TRUE then cae.is_settled
                                                                   else null
                                                                end as "is_settled")
                                                 )
                                             )
                                        from acc_entry   cae
                                        join acc_account ca     on ca.id = cae.account_id
                                       where cae.transaction_id  = ae.transaction_id
                                         and cae.balance_impact  = com_api_const_pkg.CREDIT
                                         and (cae.status        != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                                         and (i_array_trans_type_id    is null or instr(l_array_trans_type_list,   cae.transaction_type) != 0)
                                         and (i_array_account_type_cbs is null or instr(l_array_account_type_list, ca.account_type)      != 0)
                                         and (i_array_balance_type_id  is null or cae.balance_type in (select element_value from com_array_element where array_id = i_array_balance_type_id))
                                     ) -- credit entry
                                   , (select
                                          xmlagg(
                                              xmlelement("document"
                                                , xmlelement("document_id",            d.id)
                                                , xmlelement("document_type",          d.document_type)
                                                , xmlelement("document_date",          to_char(d.document_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                                , xmlelement("document_number",        d.document_number)
                                                , xmlagg(
                                                      xmlelement("document_content"
                                                          , xmlelement("content_type", dc.content_type)
                                                          , xmlelement("content",      com_api_hash_pkg.base64_encode(dc.document_content))
                                                      )
                                                  )
                                              )
                                          )
                                        from rpt_document d
                                        left join rpt_document_content dc on dc.document_id = d.id
                                       where d.object_id   = ae.transaction_id
                                         and d.entity_type = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
                                       group by d.id
                                              , d.document_type
                                              , d.document_date
                                              , d.document_number
                                     ) -- document
                                   , xmlelement("conversion_rate", coalesce(to_char(am.conversion_rate, com_api_const_pkg.XML_FLOAT_FORMAT), '1'))
                                   , xmlelement("rate_type",       coalesce(am.rate_type,               com_api_const_pkg.CUST_RATE_TYPE))
                                   , xmlelement("amount_purpose",  am.amount_purpose)
                                 ) -- xmlelement transaction
                             ) -- xmlagg
                           from acc_macros  am
                           join acc_entry   ae  on ae.macros_id = am.id
                           join acc_account acc on acc.id       = ae.account_id
                          where am.object_id     = o.id
                            and am.entity_type   = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                            and (ae.status      != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                            and (i_array_trans_type_id    is null or instr(l_array_trans_type_list,   ae.transaction_type) != 0)
                            and (i_array_account_type_cbs is null or instr(l_array_account_type_list, acc.account_type)    != 0)
                            and (i_array_balance_type_id  is null or ae.balance_type in (select element_value from com_array_element where array_id = i_array_balance_type_id))
                          group by
                                ae.transaction_id
                              , ae.transaction_type
                              , am.conversion_rate
                              , am.rate_type
                              , am.amount_purpose
                        ) -- transaction
                        --
                      , (select xmlagg(
                                    xmlelement("document"
                                      , xmlelement("document_id",              d.id)
                                      , xmlelement("document_type",            d.document_type)
                                      , xmlelement("document_date",            to_char(d.document_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , xmlelement("document_number",          d.document_number)
                                      , xmlagg(
                                            case when dc.document_content is not null then
                                                xmlelement("document_content"
                                                  , xmlelement("content_type", dc.content_type)
                                                  , xmlelement("content",      com_api_hash_pkg.base64_encode(dc.document_content))
                                                )
                                            end
                                        )
                                    )
                                )
                           from rpt_document d
                           left join rpt_document_content dc on dc.document_id = d.id
                          where d.object_id   = o.id
                            and d.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          group by
                                d.id
                              , d.document_type
                              , d.document_date
                              , d.document_number
                        ) as document
                        --
                      , (select xmlforest(
                                    xmlforest(
                                        p.client_id_type      as "client_id_type" 
                                      , p.client_id_value     as "client_id_value"
                                      , case nvl(i_masking_card, com_api_const_pkg.TRUE)
                                            when com_api_const_pkg.TRUE
                                            then iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)
                                            else c.card_number
                                        end as "card_number"
                                      , case
                                            when p.card_id is not null
                                            then iss_api_card_instance_pkg.get_card_uid(
                                                     i_card_instance_id => iss_api_card_instance_pkg.get_card_instance_id(
                                                                               i_card_id => p.card_id
                                                                           )
                                                 )
                                            else null
                                        end                   as "card_id"
                                      , p.card_instance_id    as "card_instance_id"
                                      , p.card_seq_number     as "card_seq_number"
                                      , to_char(p.card_expir_date, com_api_const_pkg.XML_DATE_FORMAT) as "card_expir_date"
                                      , p.card_country        as "card_country"                                      
                                      , p.inst_id             as "inst_id"
                                      , p.network_id          as "network_id"
                                      , p.auth_code           as "auth_code"
                                      , p.account_number      as "account_number"
                                      , p.account_amount      as "account_amount"
                                      , p.account_currency    as "account_currency"
                                    ) as "issuer"
                                )
                           from opr_participant p
                           left join opr_card c on c.oper_id = p.oper_id
                          where p.oper_id = o.id
                            and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                            and c.participant_type = p.participant_type
                        ) as issuer
                        --
                      , (select xmlforest(
                                    xmlforest(
                                        p.inst_id             as "inst_id"
                                      , p.network_id          as "network_id"
                                      , p.auth_code           as "auth_code"
                                      , p.account_number      as "account_number"
                                      , p.account_amount      as "account_amount"
                                      , p.account_currency    as "account_currency"
                                    ) as "acquirer"
                                )
                           from opr_participant p
                          where p.oper_id = o.id
                            and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                        ) as acquier
                        --
                      , (select xmlforest(
                                    xmlforest(
                                        p.client_id_type      as "client_id_type"
                                      , p.client_id_value     as "client_id_value"
                                      , p.inst_id             as "inst_id"
                                    ) as "destination"
                                )
                           from opr_participant p
                          where p.oper_id = o.id
                            and p.participant_type = com_api_const_pkg.PARTICIPANT_DEST
                        ) as destination
                        --
                      , (select xmlforest(
                                    xmlforest(
                                        p.client_id_type      as "client_id_type"
                                      , p.client_id_value     as "client_id_value"
                                      , p.inst_id             as "inst_id"
                                    ) as "aggregator"
                                )
                           from opr_participant p
                          where p.oper_id = o.id
                            and p.participant_type = com_api_const_pkg.PARTICIPANT_AGGREGATOR
                        ) as aggregator
                        --
                      , (select xmlforest(
                                    xmlforest(
                                        p.client_id_type      as "client_id_type"
                                      , p.client_id_value     as "client_id_value"
                                      , p.inst_id             as "inst_id"
                                    ) as "service_provider"
                                )
                           from opr_participant p
                          where p.oper_id = o.id
                            and p.participant_type = com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER
                        ) as service_provider
                        --
                      , (select xmlagg(
                                    xmlelement("note"
                                      , xmlelement("note_type", n.note_type)
                                      , xmlagg(
                                            xmlelement("note_content"
                                              , xmlattributes(l_lang as "language")
                                              , xmlforest(
                                                    com_api_i18n_pkg.get_text(
                                                        i_table_name  => 'ntb_note'
                                                      , i_column_name => 'header'
                                                      , i_object_id   => n.id
                                                      , i_lang        => l_lang
                                                    ) as "note_header"
                                                  , com_api_i18n_pkg.get_text(
                                                        i_table_name  => 'ntb_note'
                                                      , i_column_name => 'text'
                                                      , i_object_id   => n.id
                                                      , i_lang        => l_lang
                                                    ) as "note_text"
                                                )
                                            )
                                        )
                                    )
                                )
                           from ntb_note n
                          where n.object_id = o.id
                            and n.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          group by n.note_type
                        ) as note
                        --
                      , case when l_include_auth = com_api_const_pkg.TRUE
                             then
                                 (select
                                      xmlagg(
                                          xmlelement("auth_data"
                                            , xmlforest(
                                                  a.resp_code                             as "resp_code"
                                                , a.proc_type                             as "proc_type"
                                                , a.proc_mode                             as "proc_mode"
                                                , to_char(a.is_advice, com_api_const_pkg.XML_NUMBER_FORMAT)           as "is_advice"
                                                , to_char(a.is_repeat, com_api_const_pkg.XML_NUMBER_FORMAT)           as "is_repeat"
                                                , to_char(a.bin_amount, com_api_const_pkg.XML_NUMBER_FORMAT)          as "bin_amount"
                                                , a.bin_currency                          as "bin_currency"
                                                , to_char(a.bin_cnvt_rate, com_api_const_pkg.XML_NUMBER_FORMAT)       as "bin_cnvt_rate"
                                                , to_char(a.network_amount, com_api_const_pkg.XML_NUMBER_FORMAT)      as "network_amount"
                                                , a.network_currency                      as "network_currency"
                                                , to_char(a.network_cnvt_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "network_cnvt_date"
                                                , to_char(a.account_cnvt_rate, com_api_const_pkg.XML_NUMBER_FORMAT)   as "account_cnvt_rate"
                                                , a.addr_verif_result                     as "addr_verif_result"
                                                , a.acq_resp_code                         as "acq_resp_code"
                                                , a.acq_device_proc_result                as "acq_device_proc_result"
                                                , a.cat_level                             as "cat_level"
                                                , a.card_data_input_cap                   as "card_data_input_cap"
                                                , a.crdh_auth_cap                         as "crdh_auth_cap"
                                                , a.card_capture_cap                      as "card_capture_cap"
                                                , a.terminal_operating_env                as "terminal_operating_env"
                                                , a.crdh_presence                         as "crdh_presence"
                                                , a.card_presence                         as "card_presence"
                                                , a.card_data_input_mode                  as "card_data_input_mode"
                                                , a.crdh_auth_method                      as "crdh_auth_method"
                                                , a.crdh_auth_entity                      as "crdh_auth_entity"
                                                , a.card_data_output_cap                  as "card_data_output_cap"
                                                , a.terminal_output_cap                   as "terminal_output_cap"
                                                , a.pin_capture_cap                       as "pin_capture_cap"
                                                , a.pin_presence                          as "pin_presence"
                                                , a.cvv2_presence                         as "cvv2_presence"
                                                , a.cvc_indicator                         as "cvc_indicator"
                                                , a.pos_entry_mode                        as "pos_entry_mode"
                                                , a.pos_cond_code                         as "pos_cond_code"
                                                , a.emv_data                              as "emv_data"
                                                , a.atc                                   as "atc"
                                                , a.tvr                                   as "tvr"
                                                , a.cvr                                   as "cvr"
                                                , a.addl_data                             as "addl_data"
                                                , a.service_code                          as "service_code"
                                                , a.device_date                           as "device_date"
                                                , a.cvv2_result                           as "cvv2_result"
                                                , a.certificate_method                    as "certificate_method"
                                                , a.merchant_certif                       as "merchant_certif"
                                                , a.cardholder_certif                     as "cardholder_certif"
                                                , a.ucaf_indicator                        as "ucaf_indicator"
                                                , to_char(a.is_early_emv, com_api_const_pkg.XML_NUMBER_FORMAT)        as "is_early_emv"
                                                , a.is_completed                          as "is_completed"
                                                , a.amounts                               as "amounts"
                                                , a.agent_unique_id                       as "agent_unique_id"
                                                , a.external_auth_id                      as "external_auth_id"
                                                , a.external_orig_id                      as "external_orig_id"
                                                , a.auth_purpose_id                       as "auth_purpose_id"
                                                , a.system_trace_audit_number             as "system_trace_audit_number"
                                                , a.transaction_id                        as "auth_transaction_id"
                                              )
                                            , (select
                                                   xmlagg(
                                                       xmlelement("auth_tag"
                                                         , xmlelement("tag_id", t.tag)
                                                         , xmlelement("tag_value", v.tag_value)
                                                         , xmlelement("tag_name", t.reference)
                                                         , xmlelement("seq_number", v.seq_number)
                                                       )
                                                   )
                                                 from aup_tag t
                                                    , aup_tag_value v
                                                where v.tag_id  = t.tag
                                                  and v.auth_id = a.id
                                              )
                                          )
                                      )
                                   from aut_auth a
                                  where a.id = o.id
                                 )
                        end as auth_data
                        --
                      , case when l_include_clearing = com_api_const_pkg.TRUE
                             then (
                                 select
                                     xmlforest(
                                         xmlforest(
                                             to_char(m.is_incoming, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_incoming"
                                           , to_char(m.is_reversal, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_reversal"
                                           , to_char(m.is_rejected, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_rejected"
                                           , to_char(m.impact, com_api_const_pkg.XML_NUMBER_FORMAT)      as "impact"
                                           , m.mti              as "mti"
                                           , m.de024            as "de024"
                                           , m.de002            as "de002"
                                           , m.de003_1          as "de003_1"
                                           , m.de003_2          as "de003_2"
                                           , m.de003_3          as "de003_3"
                                           , to_char(m.de004, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de004"
                                           , to_char(m.de005, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de005"
                                           , to_char(m.de006, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de006"
                                           , m.de009            as "de009"
                                           , m.de010            as "de010"
                                           , to_char(m.de012, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de012"
                                           , to_char(m.de014, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de014" 
                                           , m.de022_1          as "de022_1"
                                           , m.de022_2          as "de022_2"
                                           , m.de022_3          as "de022_3"
                                           , m.de022_4          as "de022_4"     
                                           , m.de022_5          as "de022_5"
                                           , m.de022_6          as "de022_6"
                                           , m.de022_7          as "de022_7"
                                           , m.de022_8          as "de022_8"
                                           , m.de022_9          as "de022_9" 
                                           , m.de022_10         as "de022_10"
                                           , m.de022_11         as "de022_11"
                                           , m.de022_12         as "de022_12"
                                           , to_char(m.de023, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de023"
                                           , m.de025            as "de025"
                                           , m.de026            as "de026"
                                           , to_char(m.de030_1, com_api_const_pkg.XML_NUMBER_FORMAT)     as "de030_1"
                                           , to_char(m.de030_2, com_api_const_pkg.XML_NUMBER_FORMAT)     as "de030_2"
                                           , m.de031            as "de031"
                                           , m.de032            as "de032"
                                           , m.de033            as "de033"
                                           , m.de037            as "de037"
                                           , m.de038            as "de038"
                                           , m.de040            as "de040"
                                           , m.de041            as "de041"
                                           , m.de042            as "de042"
                                           , m.de043_1          as "de043_1"
                                           , m.de043_2          as "de043_2"
                                           , m.de043_3          as "de043_3"
                                           , m.de043_4          as "de043_4"
                                           , m.de043_5          as "de043_5"
                                           , m.de043_6          as "de043_6"
                                           , m.de049            as "de049"
                                           , m.de050            as "de050"
                                           , m.de051            as "de051"
                                           , m.de054            as "de054"
                                           , m.de055            as "de055"
                                           , m.de063            as "de063"
                                           , to_char(m.de071, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de071"
                                           , regexp_replace(m.de072, '[[:cntrl:]]', null)                as "de072"
                                           , to_char(m.de073, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de073"
                                           , m.de093            as "de093"
                                           , m.de094            as "de094"
                                           , m.de095            as "de095"
                                           , m.de100            as "de100"
                                           , to_char(m.de111, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de111"
                                           , m.p0002            as "p0002"
                                           , m.p0023            as "p0023"
                                           , m.p0025_1          as "p0025_1"
                                           , to_char(m.p0025_2, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0025_2"
                                           , m.p0043            as "p0043"
                                           , m.p0052            as "p0052"
                                           , m.p0137            as "p0137"
                                           , m.p0148            as "p0148"
                                           , m.p0146            as "p0146"
                                           , to_char(m.p0146_net, com_api_const_pkg.XML_NUMBER_FORMAT)   as "p0146_net"
                                           , m.p0147            as "p0147"
                                           , m.p0149_1          as "p0149_1"
                                           , lpad(m.p0149_2, 3, '0') as "p0149_2"
                                           , m.p0158_1          as "p0158_1"
                                           , m.p0158_2          as "p0158_2"
                                           , m.p0158_3          as "p0158_3"           
                                           , m.p0158_4          as "p0158_4"
                                           , to_char(m.p0158_5, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0158_5"
                                           , to_char(m.p0158_6, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0158_6"
                                           , m.p0158_7          as "p0158_7"
                                           , m.p0158_8          as "p0158_8"
                                           , m.p0158_9          as "p0158_9"
                                           , m.p0158_10         as "p0158_10"
                                           , m.p0159_1          as "p0159_1"
                                           , m.p0159_2          as "p0159_2"
                                           , to_char(m.p0159_3, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_3"
                                           , m.p0159_4          as "p0159_4"
                                           , m.p0159_5          as "p0159_5"
                                           , to_char(m.p0159_6, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0159_6"
                                           , to_char(m.p0159_7, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_7"
                                           , to_char(m.p0159_8, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0159_8"
                                           , to_char(m.p0159_9, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_9"
                                           , m.p0165            as "p0165"
                                           , m.p0176            as "p0176"
                                           , to_char(m.p0228, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0228" 
                                           , to_char(m.p0230, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0230"
                                           , m.p0241            as "p0241"
                                           , m.p0243            as "p0243"
                                           , m.p0244            as "p0244"
                                           , m.p0260            as "p0260"
                                           , to_char(m.p0261, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0261"
                                           , to_char(m.p0262, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0262"
                                           , to_char(m.p0264, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0264"
                                           , m.p0265            as "p0265"
                                           , m.p0266            as "p0266"
                                           , m.p0267            as "p0267"
                                           , to_char(m.p0268_1, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0268_1"
                                           , m.p0268_2          as "p0268_2"
                                           , m.p0375            as "p0375"
                                           , m.emv_9f26         as "emv_9f26"
                                           , to_char(m.emv_9f02, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f02"
                                           , m.emv_9f27         as "emv_9f27"
                                           , m.emv_9f10         as "emv_9f10"
                                           , m.emv_9f36         as "emv_9f36"
                                           , m.emv_95           as "emv_95"
                                           , m.emv_82           as "emv_82"
                                           , to_char(m.emv_9a, com_api_const_pkg.XML_DATETIME_FORMAT)    as "emv_9a"
                                           , to_char(m.emv_9c, com_api_const_pkg.XML_NUMBER_FORMAT)      as "emv_9c"
                                           , m.emv_9f37         as "emv_9f37"
                                           , to_char(m.emv_5f2a, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_5f2a"
                                           , m.emv_9f33         as "emv_9f33"
                                           , m.emv_9f34         as "emv_9f34"
                                           , to_char(m.emv_9f1a, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f1a"
                                           , to_char(m.emv_9f35, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f35"
                                           , m.emv_9f53         as "emv_9f53"
                                           , m.emv_84           as "emv_84"
                                           , m.emv_9f09         as "emv_9f09"
                                           , to_char(m.emv_9f03, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f03"
                                           , m.emv_9f1e         as "emv_9f1e"
                                           , to_char(m.emv_9f41, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f41"
                                           , m.p0042            as "p0042"
                                           , m.p0158_11         as "p0158_11"
                                           , m.p0158_12         as "p0158_12"
                                           , m.p0158_13         as "p0158_13"
                                           , m.p0158_14         as "p0158_14"
                                           , m.p0198            as "p0198"
                                           , to_char(m.p0200_1, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0200_1"
                                           , to_char(m.p0200_2, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0200_2"
                                           , m.p0210_1          as "p0210_1"
                                           , m.p0210_2          as "p0210_2"                                   
                                         ) as "ipm_data" -- xmlforest
                                     ) -- xmlforest
                                  from mcw_fin m
                                 where m.id = o.id
                            )
                        end
                        --
                      , case when l_include_clearing = com_api_const_pkg.TRUE
                             then (
                                 select
                                     xmlforest(
                                         xmlforest(
                                             to_char(v.is_reversal, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_reversal"
                                           , to_char(v.is_incoming, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_incoming"
                                           , to_char(v.is_returned, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_returned"
                                           , to_char(v.is_invalid, com_api_const_pkg.XML_NUMBER_FORMAT)     as "is_invalid"
                                           , v.rrn                    as "rrn"
                                           , v.trans_code             as "trans_code"
                                           , v.trans_code_qualifier   as "trans_code_qualifier"
                                           , v.card_mask              as "card_mask"
                                           , to_char(v.oper_amount, com_api_const_pkg.XML_NUMBER_FORMAT)    as "oper_amount"
                                           , v.oper_currency          as "oper_currency"
                                           , to_char(v.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT)    as "oper_date"
                                           , to_char(v.sttl_amount, com_api_const_pkg.XML_NUMBER_FORMAT)    as "sttl_amount"
                                           , v.sttl_currency          as "sttl_currency"
                                           , to_char(v.network_amount, com_api_const_pkg.XML_NUMBER_FORMAT) as "network_amount"
                                           , v.network_currency       as "network_currency"
                                           , v.floor_limit_ind        as "floor_limit_ind"
                                           , v.exept_file_ind         as "exept_file_ind"
                                           , v.pcas_ind               as "pcas_ind"
                                           , v.arn                    as "arn"
                                           , v.acquirer_bin           as "acquirer_bin"
                                           , v.acq_business_id        as "acq_business_id"
                                           , v.merchant_name          as "merchant_name"
                                           , v.merchant_city          as "merchant_city"
                                           , v.merchant_country       as "merchant_country"
                                           , v.merchant_postal_code   as "merchant_postal_code"
                                           , v.merchant_region        as "merchant_region"
                                           , v.merchant_street        as "merchant_street"
                                           , v.mcc                    as "mcc"
                                           , v.req_pay_service        as "req_pay_service"
                                           , v.usage_code             as "usage_code"
                                           , v.reason_code            as "reason_code"
                                           , v.settlement_flag        as "settlement_flag"
                                           , v.auth_char_ind          as "auth_char_ind"
                                           , v.auth_code              as "auth_code"
                                           , v.pos_terminal_cap       as "pos_terminal_cap"
                                           , v.inter_fee_ind          as "inter_fee_ind"
                                           , v.crdh_id_method         as "crdh_id_method"
                                           , v.collect_only_flag      as "collect_only_flag"
                                           , v.pos_entry_mode         as "pos_entry_mode"
                                           , v.central_proc_date      as "central_proc_date"
                                           , v.reimburst_attr         as "reimburst_attr"
                                           , v.iss_workst_bin         as "iss_workst_bin"
                                           , v.acq_workst_bin         as "acq_workst_bin"
                                           , v.chargeback_ref_num     as "chargeback_ref_num"
                                           , v.docum_ind              as "docum_ind"
                                           , v.member_msg_text        as "member_msg_text"
                                           , v.spec_cond_ind          as "spec_cond_ind"
                                           , v.fee_program_ind        as "fee_program_ind"
                                           , v.issuer_charge          as "issuer_charge"
                                           , v.merchant_number        as "merchant_number"
                                           , v.terminal_number        as "terminal_number"
                                           , v.national_reimb_fee     as "national_reimb_fee"
                                           , v.electr_comm_ind        as "electr_comm_ind"
                                           , v.spec_chargeback_ind    as "spec_chargeback_ind"
                                           , v.interface_trace_num    as "interface_trace_num"
                                           , v.unatt_accept_term_ind  as "unatt_accept_term_ind"
                                           , v.prepaid_card_ind       as "prepaid_card_ind"
                                           , v.service_development    as "service_development"
                                           , v.avs_resp_code          as "avs_resp_code"
                                           , v.auth_source_code       as "auth_source_code"
                                           , v.purch_id_format        as "purch_id_format"
                                           , v.account_selection      as "account_selection"
                                           , v.installment_pay_count  as "installment_pay_count"
                                           , v.purch_id               as "purch_id"
                                           , v.cashback               as "cashback"
                                           , v.chip_cond_code         as "chip_cond_code"
                                           , v.pos_environment        as "pos_environment"
                                           , v.transaction_type       as "transaction_type"
                                           , v.card_seq_number        as "card_seq_number"
                                           , v.terminal_profile       as "terminal_profile"
                                           , v.unpredict_number       as "unpredict_number"
                                           , v.appl_trans_counter     as "appl_trans_counter"
                                           , v.appl_interch_profile   as "appl_interch_profile"
                                           , v.cryptogram             as "cryptogram"
                                           , v.term_verif_result      as "term_verif_result"
                                           , v.cryptogram_amount      as "cryptogram_amount"
                                           , v.card_verif_result      as "card_verif_result"
                                           , v.issuer_appl_data       as "issuer_appl_data"
                                           , v.issuer_script_result   as "issuer_script_result"
                                           , v.card_expir_date        as "card_expir_date"
                                           , v.cryptogram_version     as "cryptogram_version"
                                           , v.cvv2_result_code       as "cvv2_result_code"
                                           , v.auth_resp_code         as "auth_resp_code"
                                           , v.cryptogram_info_data   as "cryptogram_info_data"
                                           , v.transaction_id         as "transaction_id"
                                           , v.merchant_verif_value   as "merchant_verif_value"
                                           , v.proc_bin               as "proc_bin"
                                           , v.chargeback_reason_code as "chargeback_reason_code"
                                           , v.destination_channel    as "destination_channel"
                                           , v.source_channel         as "source_channel"
                                           , v.acq_inst_bin           as "acq_inst_bin"
                                           , v.spend_qualified_ind    as "spend_qualified_ind"
                                           , v.service_code           as "service_code"
                                           , v.product_id             as "product_id"
                                         ) as "baseII_data" -- xmlforest
                                     ) -- xmlforest
                                  from vis_fin_message v
                                 where v.id = o.id
                            )
                        end
                        --
                      , case when i_include_additional_amount = com_api_const_pkg.TRUE then
                            (select xmlagg(
                                        xmlelement("additional_amount"
                                          , xmlelement("amount_value", a.amount)
                                          , xmlelement("currency",     a.currency)
                                          , xmlelement("amount_type",  a.amount_type)
                                        )
                                    )
                               from opr_additional_amount a
                              where a.oper_id = o.id
                                and a.amount is not null
                            )
                        end as additional_amount
                    ) -- xmlelement("operation"
                ) -- xmlagg (for <operation>)
            ).getClobVal() as xml_file
        from opr_operation o
       where o.id in (select column_value from table(cast(l_oper_id_tab as num_tab_tpt)));

    -- Function returns a reference for a cursor with operations being processed.
    -- In case of incremental unloading it also returns event objects' identifiers.
    procedure open_cur_objects(
        o_cursor                   out sys_refcursor
      , i_incom_sess_file_id    in     com_api_type_pkg.t_long_id
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor for all operations those are processed...');

        if l_full_export = com_api_const_pkg.FALSE then
            -- Select IDs of operations using actual events
            open o_cursor for
                select eo.id         as evt_id
                     , eo.object_id  as evt_obj_id
                  from evt_event_object eo
                     , com_split_map    sm
                     , opr_operation    o
                 where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'OPR_PRC_EXPORT_PKG.UPLOAD_OPERATION'
                   and nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST) in (eo.inst_id, ost_api_const_pkg.DEFAULT_INST)
                   and eo.eff_date           <= l_sysdate
                   and sm.split_hash          = eo.split_hash
                   and l_thread_number       in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   and (eo.event_type         = i_upl_oper_event_type or i_upl_oper_event_type is null)
                   and eo.entity_type         = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and o.id                   = eo.object_id
                   and o.host_date      between l_min_date and l_max_date
                   and (o.terminal_type       = i_terminal_type or i_terminal_type is null)
                   and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or o.status     in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                   and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or o.status not in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                   and (o.is_reversal         = com_api_const_pkg.FALSE or l_reversal_upload_type in (opr_api_const_pkg.REVERSAL_UPLOAD_ALL, opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED))
                   and (l_use_session_id      = com_api_const_pkg.FALSE
                        or (l_use_session_id  = com_api_const_pkg.TRUE
                            and o.session_id in (select column_value from table(cast(l_session_id_tab as num_tab_tpt)))
                        )
                   )
                   and (l_split_files = com_api_const_pkg.FALSE
                        or (l_split_files = com_api_const_pkg.TRUE
                            and o.incom_sess_file_id = i_incom_sess_file_id
                        )
                   )
                   and (case
                            when l_load_successfull not in (opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS
                                                          , opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE)
                            then com_api_const_pkg.TRUE
                            else (
                                     select nvl(
                                                max(
                                                       case
                                                           when l_load_successfull = opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS
                                                                and (a.resp_code is null or a.resp_code  = aup_api_const_pkg.RESP_CODE_OK)
                                                           then com_api_const_pkg.TRUE
 
                                                           when l_load_successfull = opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE
                                                                and (a.resp_code is null or a.resp_code != aup_api_const_pkg.RESP_CODE_OK)
                                                           then com_api_const_pkg.TRUE
 
                                                           else  com_api_const_pkg.FALSE
                                                       end
                                                   )
                                                  , com_api_const_pkg.TRUE
                                               )
                                       from aut_auth a
                                      where a.id = o.id
                                 )
                        end
                       ) = com_api_const_pkg.TRUE
                   and (i_array_operations_type_id is null or instr(l_array_operations_type_list, o.oper_type) != 0)
                   and (case
                            when i_array_account_type_cbs    is null
                                 and i_array_trans_type_id   is null
                                 and i_array_balance_type_id is null
                                 and l_include_canceled_entries = com_api_const_pkg.TRUE
                            then com_api_const_pkg.TRUE

                            when i_array_account_type_cbs   is null
                                 and (i_array_trans_type_id is not null
                                      or i_array_balance_type_id is null
                                      or l_include_canceled_entries = com_api_const_pkg.FALSE)
                            then (
                                     select com_api_const_pkg.TRUE
                                       from acc_macros  m
                                          , acc_entry   ent
                                      where m.object_id    = o.id
                                        and m.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                        and ent.macros_id  = m.id
                                        and (ent.status   != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                                        and (i_array_trans_type_id   is null or instr(l_array_trans_type_list, ent.transaction_type) != 0)
                                        and (i_array_balance_type_id is null or ent.balance_type in (select element_value from com_array_element where array_id = i_array_balance_type_id))
                                        and rownum = 1
                                 )

                            else (
                                     select com_api_const_pkg.TRUE
                                       from acc_macros  m
                                          , acc_entry   ent
                                          , acc_account ac
                                      where m.object_id    = o.id
                                        and m.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                        and ent.macros_id  = m.id
                                        and ac.id          = ent.account_id
                                        and (ent.status   != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                                        and (i_array_trans_type_id    is null or instr(l_array_trans_type_list,   ent.transaction_type) != 0)
                                        and (i_array_account_type_cbs is null or instr(l_array_account_type_list, ac.account_type)      != 0)
                                        and (i_array_balance_type_id  is null or ent.balance_type in (select element_value from com_array_element where array_id = i_array_balance_type_id))
                                        and rownum = 1
                                 )
                        end
                       ) = com_api_const_pkg.TRUE
                   and (case
                            when l_reversal_upload_type     = opr_api_const_pkg.REVERSAL_UPLOAD_ALL
                                 or (l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_ORIGINAL
                                     and o.is_reversal      = com_api_const_pkg.FALSE)
                            then com_api_const_pkg.FALSE

                             when l_reversal_upload_type    = opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED
                                  and o.is_reversal         = com_api_const_pkg.TRUE
                                  and o.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
                            then (
                                     select nvl(max(com_api_const_pkg.TRUE), com_api_const_pkg.FALSE)
                                       from opr_operation    orig
                                          , evt_event_object eo_orig
                                      where orig.id                = o.original_id
                                        and orig.is_reversal       = com_api_const_pkg.FALSE
                                        and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or orig.status     in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                                        and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or orig.status not in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                                        and (orig.oper_amount - o.oper_amount) = 0
                                        and o.oper_currency        = orig.oper_currency
                                        and eo_orig.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                        and eo_orig.object_id      = orig.id
                                        and eo_orig.split_hash     = eo.split_hash
                                        and eo_orig.procedure_name = 'OPR_PRC_EXPORT_PKG.UPLOAD_OPERATION'
                                        and eo_orig.status         = evt_api_const_pkg.EVENT_STATUS_READY
                                        and (eo_orig.event_type    = i_upl_oper_event_type or i_upl_oper_event_type is null)
                            )

                            when l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED
                                 and o.is_reversal = com_api_const_pkg.FALSE
                            then (
                                     select nvl(max(com_api_const_pkg.TRUE), com_api_const_pkg.FALSE)
                                       from opr_operation    rev
                                          , evt_event_object eo_rev
                                      where rev.original_id       = o.id
                                        and rev.is_reversal       = com_api_const_pkg.TRUE
                                        and rev.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
                                        and (rev.oper_amount - o.oper_amount) = 0
                                        and o.oper_currency       = rev.oper_currency
                                        and eo_rev.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                        and eo_rev.object_id      = rev.id
                                        and eo_rev.split_hash     = eo.split_hash
                                        and eo_rev.procedure_name = 'OPR_PRC_EXPORT_PKG.UPLOAD_OPERATION'
                                        and eo_rev.status         = evt_api_const_pkg.EVENT_STATUS_READY
                                        and (eo_rev.event_type    = i_upl_oper_event_type or i_upl_oper_event_type is null)
                            )

                             else com_api_const_pkg.FALSE
                        end
                   ) = com_api_const_pkg.FALSE
                 order by eo.object_id+0;

        else
            -- Select IDs of all operations
            open o_cursor for
                select to_number(null) as evt_id
                     , o.id            as evt_obj_id
                  from opr_operation   o
                 where o.host_date      between l_min_date and l_max_date
                   and (o.terminal_type       = i_terminal_type or i_terminal_type is null)
                   and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or o.status     in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                   and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or o.status not in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                   and (o.is_reversal         = com_api_const_pkg.FALSE or l_reversal_upload_type in (opr_api_const_pkg.REVERSAL_UPLOAD_ALL, opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED))
                   and (l_use_session_id      = com_api_const_pkg.FALSE
                        or (l_use_session_id  = com_api_const_pkg.TRUE
                            and o.session_id in (select column_value from table(cast(l_session_id_tab as num_tab_tpt)))
                        )
                   )
                   and (l_split_files = com_api_const_pkg.FALSE
                        or (l_split_files = com_api_const_pkg.TRUE
                            and o.incom_sess_file_id = i_incom_sess_file_id
                        )
                   )
                   and (
                           select com_api_const_pkg.TRUE
                             from opr_participant p
                                , com_split_map   sm
                            where p.oper_id           = o.id 
                              and p.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER
                              and nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST) in (p.inst_id, ost_api_const_pkg.DEFAULT_INST)
                              and sm.split_hash       = p.split_hash
                              and l_thread_number    in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                       ) = com_api_const_pkg.TRUE
                   and (case
                            when l_load_successfull not in (opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS
                                                          , opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE)
                            then com_api_const_pkg.TRUE
                            else (
                                     select nvl(
                                                max(
                                                       case
                                                           when l_load_successfull = opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS
                                                                and (a.resp_code is null or a.resp_code  = aup_api_const_pkg.RESP_CODE_OK)
                                                           then com_api_const_pkg.TRUE
 
                                                           when l_load_successfull = opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE
                                                                and (a.resp_code is null or a.resp_code != aup_api_const_pkg.RESP_CODE_OK)
                                                           then com_api_const_pkg.TRUE
 
                                                           else  com_api_const_pkg.FALSE
                                                       end
                                                   )
                                                  , com_api_const_pkg.TRUE
                                               )
                                       from aut_auth a
                                      where a.id = o.id
                                 )
                        end
                       ) = com_api_const_pkg.TRUE
                   and (i_array_operations_type_id is null or instr(l_array_operations_type_list, o.oper_type) != 0)
                   and (case
                            when i_array_account_type_cbs    is null
                                 and i_array_trans_type_id   is null
                                 and i_array_balance_type_id is null
                                 and l_include_canceled_entries = com_api_const_pkg.TRUE
                            then com_api_const_pkg.TRUE

                            when i_array_account_type_cbs   is null
                                 and (i_array_trans_type_id is not null
                                      or i_array_balance_type_id is null
                                      or l_include_canceled_entries = com_api_const_pkg.FALSE)
                            then (
                                     select com_api_const_pkg.TRUE
                                       from acc_macros  m
                                          , acc_entry   ent
                                      where m.object_id    = o.id
                                        and m.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                        and ent.macros_id  = m.id
                                        and (ent.status   != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                                        and (i_array_trans_type_id   is null or instr(l_array_trans_type_list, ent.transaction_type) != 0)
                                        and (i_array_balance_type_id is null or ent.balance_type in (select element_value from com_array_element where array_id = i_array_balance_type_id))
                                        and rownum = 1
                                 )

                            else (
                                     select com_api_const_pkg.TRUE
                                       from acc_macros  m
                                          , acc_entry   ent
                                          , acc_account ac
                                      where m.object_id    = o.id
                                        and m.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                        and ent.macros_id  = m.id
                                        and ac.id          = ent.account_id
                                        and (ent.status   != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                                        and (i_array_trans_type_id    is null or instr(l_array_trans_type_list,   ent.transaction_type) != 0)
                                        and (i_array_account_type_cbs is null or instr(l_array_account_type_list, ac.account_type)      != 0)
                                        and (i_array_balance_type_id  is null or ent.balance_type in (select element_value from com_array_element where array_id = i_array_balance_type_id))
                                        and rownum = 1
                                 )
                        end
                       ) =  com_api_const_pkg.TRUE
                   and (case
                            when l_reversal_upload_type     = opr_api_const_pkg.REVERSAL_UPLOAD_ALL
                                 or (l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_ORIGINAL
                                     and o.is_reversal      = com_api_const_pkg.FALSE)
                            then com_api_const_pkg.FALSE

                             when l_reversal_upload_type    = opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED
                                  and o.is_reversal         = com_api_const_pkg.TRUE
                                  and o.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
                            then (
                                     select nvl(max(com_api_const_pkg.TRUE), com_api_const_pkg.FALSE)
                                       from opr_operation orig
                                      where orig.id                = o.original_id
                                        and orig.is_reversal       = com_api_const_pkg.FALSE
                                        and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or orig.status     in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                                        and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or orig.status not in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                                        and (orig.oper_amount - o.oper_amount) = 0
                                        and o.oper_currency        = orig.oper_currency
                            )

                            when l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED
                                 and o.is_reversal = com_api_const_pkg.FALSE
                            then (
                                     select nvl(max(com_api_const_pkg.TRUE), com_api_const_pkg.FALSE)
                                       from opr_operation rev
                                      where rev.original_id       = o.id
                                        and rev.is_reversal       = com_api_const_pkg.TRUE
                                        and rev.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
                                        and (rev.oper_amount - o.oper_amount) = 0
                                        and o.oper_currency       = rev.oper_currency
                            )

                             else com_api_const_pkg.FALSE
                        end
                   ) = com_api_const_pkg.FALSE;

        end if;

        trc_log_pkg.debug('Cursor was opened...');
    end open_cur_objects;

    procedure open_file(
        i_incom_sess_file_id  in     com_api_type_pkg.t_long_id
    ) is
        l_params                   com_api_type_pkg.t_param_tab;
        l_report_id                com_api_type_pkg.t_short_id;
        l_report_template_id       com_api_type_pkg.t_short_id;
    begin
        trc_log_pkg.debug('Creating a new XML file');

        -- Preparing for passing into <prc_api_file_pkg.open_file> Id of the institute
        l_params := evt_api_shared_data_pkg.g_params;

        rul_api_param_pkg.set_param(
            i_name    => 'INST_ID'
          , i_value   => to_char(i_inst_id)
          , io_params => l_params
        );

        if l_split_files = com_api_const_pkg.TRUE then
            select f.file_name
              into l_original_file_name
              from prc_session_file f
             where f.id = i_incom_sess_file_id;
                
            if l_original_file_name is not null then
                rul_api_param_pkg.set_param(
                    i_name    => 'ORIGINAL_FILE_NAME'
                  , i_value   => l_original_file_name
                  , io_params => l_params
                );
            end if;                                                
        end if;

        l_total_file_count := l_total_file_count + 1;

        rul_api_param_pkg.set_param(
            i_name    => 'FILE_NUMBER'
          , i_value   => l_total_file_count
          , io_params => l_params
        );

        prc_api_file_pkg.open_file (
            o_sess_file_id        => l_session_file_id
          , i_file_type           => null
          , i_file_purpose        => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params             => l_params
          , o_report_id           => l_report_id
          , o_report_template_id  => l_report_template_id
        );

    end open_file;

    -- Generate XML file
    procedure generate_xml(
        i_incom_sess_file_id  in     com_api_type_pkg.t_long_id
    ) is
        l_fetched_count        com_api_type_pkg.t_count    := 0;
    begin
        if l_oper_id_tab.count() > 0 then

            l_estimated_count := nvl(l_estimated_count, 0) + l_oper_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
              , i_measure         => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            );
            trc_log_pkg.debug('Estimated count of operations is [' || l_estimated_count || ']');

            open  cur_entry;
            fetch cur_entry bulk collect into l_entry_id_tab, l_inst_id_tab, l_split_hash_tab;
            close cur_entry;

            trc_log_pkg.debug(i_text => 'Count of entries [' || l_entry_id_tab.count || ']');

            if g_inst_flag_tab.count > 0 then
                for i in 1..l_entry_id_tab.count
                loop
                    if g_inst_flag_tab.exists(l_inst_id_tab(i)) then
                        acc_api_entry_pkg.set_is_settled(
                            i_entry_id                  => l_entry_id_tab(i)
                          , i_is_settled                => com_api_const_pkg.FALSE
                          , i_inst_id                   => l_inst_id_tab(i)
                          , i_sttl_flag_date            => null
                          , i_split_hash                => l_split_hash_tab(i)
                        );
                    end if;
                end loop;
            end if;

            open_file(
                i_incom_sess_file_id => i_incom_sess_file_id
            );

            -- For every processing batch of card instances we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_fetched_count, l_file;
            close cur_xml;

            prc_api_file_pkg.put_file (
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
            );

            if l_full_export = com_api_const_pkg.FALSE then
                -- Mark processed event object between "open_file" and "close_file"
                -- and set "evt_event_object.proc_session_file_id" correctly.
                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab  => l_event_object_id_tab
                );

                trc_log_pkg.debug(
                    i_text       => '[#1] event objects marked as PROCESSED.'
                  , i_env_param1 => l_event_object_id_tab.count
                );
            end if;

            l_oper_id_tab.delete;
            l_event_object_id_tab.delete;

            prc_api_file_pkg.close_file(
                i_sess_file_id        => l_session_file_id
              , i_status              => prc_api_const_pkg.FILE_STATUS_ACCEPTED
              , i_record_count        => l_fetched_count
            );

            trc_log_pkg.debug('file saved, count=' || l_fetched_count || ', length=' || length(l_file));

            l_processed_count := l_processed_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count
              , i_excepted_count => 0
            );

        end if;

    end generate_xml;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'inst_id ['                     || i_inst_id
                                   || '], upl_oper_event_type ['      || i_upl_oper_event_type
                                   || '], terminal_type ['            || i_terminal_type
                                   || '], start_date ['               || to_char(i_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
                                   || '], end_date ['                 || to_char(i_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
                                   || '], full_export ['              || i_full_export
                                   || '], reversal_upload_type ['     || i_reversal_upload_type
                                   || '], load_successfull ['         || i_load_successfull
                                   || '], include_auth ['             || i_include_auth
                                   || '], include_clearing ['         || i_include_clearing
                                   || '], array_operations_type_id [' || i_array_operations_type_id
                                   || '], array_account_type_cbs ['    || i_array_account_type_cbs
                                   || '], array_trans_type_id ['      || i_array_trans_type_id || ']'
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_process_container [#1] i_session_id [#2] i_split_files [#3]'
      , i_env_param1 => i_process_container
      , i_env_param2 => i_session_id
      , i_env_param3 => i_split_files
    );

    l_sysdate            := com_api_sttl_day_pkg.get_sysdate;
    l_lang               := com_ui_user_env_pkg.get_user_lang;
    l_process_session_id := prc_api_session_pkg.get_session_id;
    l_thread_number      := prc_api_session_pkg.get_thread_number;

    trc_log_pkg.debug(
        i_text       => 'sysdate [#1], user_lang [#2]'
      , i_env_param1 => to_char(l_sysdate, DATETIME_FORMAT)
      , i_env_param2 => l_lang
    );

    -- Set default values for parameters
    l_full_export              := nvl(i_full_export,              com_api_const_pkg.FALSE);
    l_load_successfull         := nvl(i_load_successfull,         opr_api_const_pkg.UNLOADING_OPER_STATUS_ALL);
    l_include_auth             := nvl(i_include_auth,             com_api_const_pkg.TRUE);
    l_include_clearing         := nvl(i_include_clearing,         com_api_const_pkg.TRUE);
    l_include_canceled_entries := nvl(i_include_canceled_entries, com_api_const_pkg.FALSE);
    l_reversal_upload_type     := nvl(i_reversal_upload_type,     opr_api_const_pkg.REVERSAL_UPLOAD_ALL);

    -- Check for the case when end date less than start date
    if nvl(i_end_date, date '9999-12-31') < nvl(i_start_date, date '0001-01-01') then
        com_api_error_pkg.raise_error (
            i_error      => 'END_DATE_LESS_THAN_START_DATE'
          , i_env_param1 => com_api_type_pkg.convert_to_char(i_end_date)
          , i_env_param2 => com_api_type_pkg.convert_to_char(i_start_date)
        );
    end if;

    l_min_date := nvl(i_start_date, date '0001-01-01');
    l_max_date := nvl(i_end_date, trunc(get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND);

    trc_log_pkg.debug(
        i_text       => 'min_date [#1], max_date [#2]'
      , i_env_param1 => to_char(l_min_date, DATETIME_FORMAT)
      , i_env_param2 => to_char(l_max_date, DATETIME_FORMAT)
    );

    l_array_operations_type_list := com_api_array_pkg.get_element_list(
                                        i_array_id => i_array_operations_type_id
                                    );
    l_array_account_type_list    := com_api_array_pkg.get_element_list(
                                        i_array_id => i_array_account_type_cbs
                                    );
    l_array_trans_type_list      := com_api_array_pkg.get_element_list(
                                        i_array_id => i_array_trans_type_id
                                    );  

    set_ui_value_pkg.get_inst_by_param_n(
        i_param_name        => 'CBS_SETTLEMENT_FLAG'
      , o_inst_id           => g_inst_flag_tab
    );

    remain_active_inst_param(io_inst_flag_tab  => g_inst_flag_tab);

    -- Get session list
    if nvl(i_process_container, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE and i_session_id is not null then
        select id
          bulk collect into l_session_id_tab
          from prc_session
          connect by parent_id = prior id
          start with id        = i_session_id
        intersect
          select id
            from prc_session
            start with id = (
                               select max(id) keep (dense_rank last order by level)
                                 from prc_session
                                 start with id = l_process_session_id
                                 connect by id = prior parent_id
                            )
            connect by prior id = parent_id;

    elsif nvl(i_process_container, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
          select id
            bulk collect into l_session_id_tab
            from prc_session
            start with id = (
                               select max(id) keep (dense_rank last order by level)
                                 from prc_session
                                 start with id = l_process_session_id
                                 connect by id = prior parent_id
                            )
            connect by prior id = parent_id;

    elsif i_session_id is not null then
        select id
          bulk collect into l_session_id_tab
          from prc_session
          connect by parent_id = prior id
          start with id        = i_session_id;

    end if;

    if l_session_id_tab.count > 0 then
      l_use_session_id := com_api_const_pkg.TRUE;
    end if;

    trc_log_pkg.debug(
        i_text       => 'l_use_session_id [#1] l_session_id_tab.count [#2]'
      , i_env_param1 => l_use_session_id
      , i_env_param2 => l_session_id_tab.count
    );

    if i_split_files = com_api_const_pkg.TRUE and l_use_session_id = com_api_const_pkg.TRUE then
        l_split_files := com_api_const_pkg.TRUE;
    end if;

    -- Get session list for incoming files
    if l_split_files = com_api_const_pkg.TRUE then
        select s.id
          bulk collect into l_incom_sess_file_id_tab
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where s.session_id in (
                   select column_value
                     from table(cast(l_session_id_tab as num_tab_tpt))
               )
           and s.file_attr_id   = a.id
           and f.id             = a.file_id
           and f.file_purpose   = prc_api_const_pkg.FILE_PURPOSE_IN
           and f.file_type      = opr_api_const_pkg.FILE_TYPE_LOADING;

        l_splitted_file_count := l_incom_sess_file_id_tab.count;
    end if;

    trc_log_pkg.debug(
        i_text       => 'l_split_files [#1] l_file_count [#2]'
      , i_env_param1 => l_split_files
      , i_env_param2 => l_splitted_file_count
    );

    for i in 1 .. l_splitted_file_count loop

        if l_split_files = com_api_const_pkg.TRUE then
            l_incom_sess_file_id := l_incom_sess_file_id_tab(i);
        end if;

        open_cur_objects(
            o_cursor             => cur_objects
          , i_incom_sess_file_id => l_incom_sess_file_id
        );

        loop
            -- Select IDs of all event objects need to proceed
            fetch cur_objects
                bulk collect
                into l_fetched_event_object_id_tab
                   , l_fetched_oper_id_tab
               limit l_bulk_limit;

            trc_log_pkg.debug('l_fetched_oper_id_tab.count  = ' || l_fetched_oper_id_tab.count);

            for i in 1 .. l_fetched_oper_id_tab.count loop
                -- All events for every single operation should be marked as processed
                l_event_object_id_tab.extend;
                l_event_object_id_tab(l_event_object_id_tab.count) := l_fetched_event_object_id_tab(i);

                -- Decrease operation count and remove the last operation id from previous iteration
                if l_fetched_oper_id_tab(i) != l_oper_id
                   or l_oper_id is null
                then
                    l_oper_id := l_fetched_oper_id_tab(i);

                    l_oper_id_tab.extend;
                    l_oper_id_tab(l_oper_id_tab.count) := l_oper_id;

                    if l_oper_id_tab.count >= l_bulk_limit then
                        -- Generate XML file for current portion of the "l_bulk_limit" records
                        generate_xml(
                            i_incom_sess_file_id => l_incom_sess_file_id
                        );

                    end if;

                end if;

            end loop;

            trc_log_pkg.debug('events were processed, cnt = ' || l_fetched_event_object_id_tab.count);

            exit when cur_objects%notfound;

        end loop;

        -- Generate XML file for last portion of records
        generate_xml(
            i_incom_sess_file_id => l_incom_sess_file_id
        );

    end loop;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'was successfully completed.'
    );

    if l_estimated_count is null then
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => 0
          , i_measure         => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total  => l_processed_count
    );

exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end upload_operation;

end opr_prc_export_pkg;
/
