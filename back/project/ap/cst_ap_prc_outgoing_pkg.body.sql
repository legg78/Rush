create or replace package body cst_ap_prc_outgoing_pkg is
/**********************************************************
 * Custom handlers for uploading various data
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 21.03.2019 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_AP_PRC_OUTGOING_PKG
 * @headcom
 **********************************************************/
CRLF           constant  com_api_type_pkg.t_name := chr(13) || chr(10);

procedure uploading_cbs_file(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_full_export           in  com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_date_type             in  com_api_type_pkg.t_dict_value
  , i_eff_date              in  date
  , i_array_settl_type_id   in  com_api_type_pkg.t_medium_id        default null
) is
    PROC_NAME              constant com_api_type_pkg.t_name :=  $$PLSQL_UNIT || '.UPLOADING_CBS_FILE';
    LOG_PREFIX             constant com_api_type_pkg.t_name :=  lower(PROC_NAME) || ': ';
    
    COUNT_TRANS_DEF        constant com_api_type_pkg.t_short_id   := 5;
    COUNT_ADD_AMOUNT_DEF   constant com_api_type_pkg.t_short_id   := 10;
    
    SIZE_TRANS_BLOCK_DEF        constant com_api_type_pkg.t_short_id   := 225;
    SIZE_ENTRY_BLOCK_DEF        constant com_api_type_pkg.t_short_id   := 78;
    SIZE_ADD_AMNT_BLOCK_DEF     constant com_api_type_pkg.t_short_id   := 33;
    
    SIZE_TRAILER_FILL           constant com_api_type_pkg.t_short_id   := 616;
    
    SPACE_CHAR             constant com_api_type_pkg.t_byte_char  := ' ';
    ZERO_CHAR              constant com_api_type_pkg.t_byte_char  := '0';
    ONE_CHAR               constant com_api_type_pkg.t_byte_char  := '1';
    
    l_estimated_count      com_api_type_pkg.t_long_id    := 0;
    l_processed_count      com_api_type_pkg.t_long_id    := 0;
    l_excepted_count       com_api_type_pkg.t_long_id    := 0;
    l_rejected_count       com_api_type_pkg.t_long_id    := 0;
    
    l_session_file_id      com_api_type_pkg.t_long_id;
    
    l_count_trans          com_api_type_pkg.t_short_id;
    
    l_text                 com_api_type_pkg.t_text;
    
    l_eff_date             date := trunc(i_eff_date);
    
    l_start_date           date := l_eff_date;
    l_end_date             date := l_eff_date + 1 -com_api_const_pkg.ONE_SECOND;
    
    l_full_export          com_api_type_pkg.t_boolean := nvl(i_full_export, com_api_type_pkg.FALSE);
    
    l_event_tab            com_api_type_pkg.t_number_tab;
    l_oper_tab             com_api_type_pkg.t_number_tab;
    
    l_oper_rec             opr_api_type_pkg.t_oper_rec;
    l_participant_rec      opr_api_type_pkg.t_oper_part_rec;
    l_add_amount_tab       com_api_type_pkg.t_amount_tab;
    
    l_add_amount_by_name_tab    com_api_type_pkg.t_amount_by_name_tab;
    
    l_national_currency    com_api_type_pkg.t_curr_code;
    
    cursor oper_incremental_cur is
        select distinct(oper_id)
          from (
                select oo.id as oper_id
                  from evt_event_object o
                     , evt_event e
                     , acc_entry ae
                     , acc_macros am
                     , opr_operation oo
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_AP_PRC_OUTGOING_PKG.UPLOADING_CBS_FILE'
                   and o.entity_type      = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.eff_date        <= l_end_date
                   and o.inst_id          = i_inst_id
                   and e.id               = o.event_id
                   and e.event_type       = acc_api_const_pkg.EVENT_ENTRY_POSTING
                   and ae.id              = o.object_id
                   and am.id              = ae.macros_id
                   and am.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and oo.id              = am.object_id
                   and decode(
                           i_date_type
                         , com_api_const_pkg.DATE_PURPOSE_PROCESSING, ae.posting_date
                         , com_api_const_pkg.DATE_PURPOSE_OPERATION,  oo.oper_date
                         , com_api_const_pkg.DATE_PURPOSE_SETTLEMENT, oo.sttl_date
                         , com_api_const_pkg.DATE_PURPOSE_MACROS,     am.posting_date
                         , com_api_const_pkg.DATE_PURPOSE_UNHOLD,     oo.unhold_date
                         , com_api_const_pkg.DATE_PURPOSE_BANK,       ae.sttl_date
                         , com_api_const_pkg.DATE_PURPOSE_HOST,       oo.host_date
                         ,                                            null
                       ) between l_start_date and l_end_date
                   and (i_array_settl_type_id is null
                        or 
                        exists(select 1 from com_array_element where array_id = i_array_settl_type_id and element_value = oo.sttl_type)
                       )
                union all
                select oo.id as oper_id
                  from evt_event_object o
                     , evt_event e
                     , acc_entry ae
                     , acc_macros am
                     , opr_operation oo
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_AP_PRC_OUTGOING_PKG.UPLOADING_CBS_FILE'
                   and o.entity_type      = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
                   and o.eff_date        <= l_end_date
                   and o.inst_id          = i_inst_id
                   and e.id               = o.event_id
                   and e.event_type       = acc_api_const_pkg.EVENT_TRANSACTION_REGISTERED
                   and ae.transaction_id  = o.object_id
                   and am.id              = ae.macros_id
                   and am.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and oo.id              = am.object_id
                   and decode(
                           i_date_type
                         , com_api_const_pkg.DATE_PURPOSE_PROCESSING, ae.posting_date
                         , com_api_const_pkg.DATE_PURPOSE_OPERATION,  oo.oper_date
                         , com_api_const_pkg.DATE_PURPOSE_SETTLEMENT, oo.sttl_date
                         , com_api_const_pkg.DATE_PURPOSE_MACROS,     am.posting_date
                         , com_api_const_pkg.DATE_PURPOSE_UNHOLD,     oo.unhold_date
                         , com_api_const_pkg.DATE_PURPOSE_BANK,       ae.sttl_date
                         , com_api_const_pkg.DATE_PURPOSE_HOST,       oo.host_date
                         ,                                            null
                       ) between l_start_date and l_end_date
                   and (i_array_settl_type_id is null
                        or 
                        exists(select 1 from com_array_element where array_id = i_array_settl_type_id and element_value = oo.sttl_type)
                       )
          )
         order by
               oper_id;
          
    cursor event_incremental_cur is
        select distinct(o.id)
          from evt_event_object o
             , evt_event e
             , acc_entry ae
             , acc_macros am
             , opr_operation oo
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_AP_PRC_OUTGOING_PKG.UPLOADING_CBS_FILE'
           and o.entity_type      = acc_api_const_pkg.ENTITY_TYPE_ENTRY
           and o.eff_date        <= l_end_date
           and o.inst_id          = i_inst_id
           and e.id               = o.event_id
           and e.event_type       = acc_api_const_pkg.EVENT_ENTRY_POSTING
           and ae.id              = o.object_id
           and am.id              = ae.macros_id
           and am.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and oo.id              = am.object_id
           and decode(
                   i_date_type
                 , com_api_const_pkg.DATE_PURPOSE_PROCESSING, ae.posting_date
                 , com_api_const_pkg.DATE_PURPOSE_OPERATION,  oo.oper_date
                 , com_api_const_pkg.DATE_PURPOSE_SETTLEMENT, oo.sttl_date
                 , com_api_const_pkg.DATE_PURPOSE_MACROS,     am.posting_date
                 , com_api_const_pkg.DATE_PURPOSE_UNHOLD,     oo.unhold_date
                 , com_api_const_pkg.DATE_PURPOSE_BANK,       ae.sttl_date
                 , com_api_const_pkg.DATE_PURPOSE_HOST,       oo.host_date
                 ,                                            null
               ) between l_start_date and l_end_date
           and (i_array_settl_type_id is null
                or 
                exists(select 1 from com_array_element where array_id = i_array_settl_type_id and element_value = oo.sttl_type)
               )
        union all
        select distinct(o.id)
          from evt_event_object o
             , evt_event e
             , acc_entry ae
             , acc_macros am
             , opr_operation oo
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_AP_PRC_OUTGOING_PKG.UPLOADING_CBS_FILE'
           and o.entity_type      = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
           and o.eff_date        <= l_end_date
           and o.inst_id          = i_inst_id
           and e.id               = o.event_id
           and e.event_type       = acc_api_const_pkg.EVENT_TRANSACTION_REGISTERED
           and ae.transaction_id  = o.object_id
           and am.id              = ae.macros_id
           and am.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and oo.id              = am.object_id
           and decode(
                   i_date_type
                 , com_api_const_pkg.DATE_PURPOSE_PROCESSING, ae.posting_date
                 , com_api_const_pkg.DATE_PURPOSE_OPERATION,  oo.oper_date
                 , com_api_const_pkg.DATE_PURPOSE_SETTLEMENT, oo.sttl_date
                 , com_api_const_pkg.DATE_PURPOSE_MACROS,     am.posting_date
                 , com_api_const_pkg.DATE_PURPOSE_UNHOLD,     oo.unhold_date
                 , com_api_const_pkg.DATE_PURPOSE_BANK,       ae.sttl_date
                 , com_api_const_pkg.DATE_PURPOSE_HOST,       oo.host_date
                 ,                                            null
               ) between l_start_date and l_end_date
           and (i_array_settl_type_id is null
                or 
                exists(select 1 from com_array_element where array_id = i_array_settl_type_id and element_value = oo.sttl_type)
               );
          
    cursor oper_full_cur is
        select distinct(oo.id)
          from acc_entry ae
             , acc_macros am
             , opr_operation oo
         where am.id              = ae.macros_id
           and am.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and oo.id              = am.object_id
           and decode(
                   i_date_type
                 , com_api_const_pkg.DATE_PURPOSE_PROCESSING, ae.posting_date
                 , com_api_const_pkg.DATE_PURPOSE_OPERATION,  oo.oper_date
                 , com_api_const_pkg.DATE_PURPOSE_SETTLEMENT, oo.sttl_date
                 , com_api_const_pkg.DATE_PURPOSE_MACROS,     am.posting_date
                 , com_api_const_pkg.DATE_PURPOSE_UNHOLD,     oo.unhold_date
                 , com_api_const_pkg.DATE_PURPOSE_BANK,       ae.sttl_date
                 , com_api_const_pkg.DATE_PURPOSE_HOST,       oo.host_date
                 ,                                            null
               ) between l_start_date and l_end_date
           and (i_array_settl_type_id is null
                or 
                exists(select 1 from com_array_element where array_id = i_array_settl_type_id and element_value = oo.sttl_type)
               );

begin
    
    prc_api_stat_pkg.log_start;
        
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'started with params inst_id [#1], full_export [#2], date_type [#3], eff_date [#4], start date [#5], end date [#6], array_settlement [' || i_array_settl_type_id || ']'
      , i_env_param1  => i_inst_id
      , i_env_param2  => l_full_export
      , i_env_param3  => i_date_type
      , i_env_param4  => i_eff_date
      , i_env_param5  => l_start_date
      , i_env_param6  => l_end_date
    );
    
    l_national_currency := set_ui_value_pkg.get_system_param_v(
                               i_param_name => 'NATIONAL_CURRENCY'
                             , i_data_type  => com_api_const_pkg.DATA_TYPE_CHAR
                           );
        
    if l_full_export = com_api_const_pkg.FALSE then
        open oper_incremental_cur;
        fetch oper_incremental_cur
         bulk collect
         into l_oper_tab;
        close oper_incremental_cur;
    else
        open oper_full_cur;
        fetch oper_full_cur
         bulk collect
         into l_oper_tab;
        close oper_full_cur;
    end if;
    
    l_estimated_count := l_oper_tab.count;
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_estimated_count
    );
    
    if l_estimated_count > 0 then
        prc_api_file_pkg.open_file(o_sess_file_id  => l_session_file_id);
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_session_file_id=' || l_session_file_id
        );
        
        if l_full_export = com_api_const_pkg.FALSE then
            open event_incremental_cur;
            fetch event_incremental_cur
             bulk collect
             into l_event_tab;
            close event_incremental_cur;
        end if;
        
        for i in l_oper_tab.first .. l_oper_tab.last
        loop
            l_count_trans      := 0;
            opr_api_operation_pkg.get_operation(
                i_oper_id   => l_oper_tab(i)
              , o_operation => l_oper_rec
            );
            l_text := lpad(nvl(l_oper_rec.id, ZERO_CHAR), 16, ZERO_CHAR);                                                                       -- oper_id
            l_text := l_text || lpad(nvl(l_oper_rec.oper_type, SPACE_CHAR), 8, SPACE_CHAR);                                                      -- oper_type
            l_text := l_text || lpad(nvl(l_oper_rec.msg_type, SPACE_CHAR), 8, SPACE_CHAR);                                                       -- msg_type
            l_text := l_text || lpad(nvl(l_oper_rec.sttl_type, SPACE_CHAR), 8, SPACE_CHAR);                                                      -- sttl_type
            l_text := l_text || lpad(SPACE_CHAR, 8, SPACE_CHAR);                                                                -- reconcilliation_type
            l_text := l_text || lpad(nvl(to_char(l_oper_rec.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT), SPACE_CHAR), 19, SPACE_CHAR);                           -- oper_date
            l_text := l_text || lpad(nvl(to_char(l_oper_rec.host_date, com_api_const_pkg.XML_DATETIME_FORMAT), SPACE_CHAR), 19, SPACE_CHAR);                           -- host_date
            l_text := l_text || lpad(nvl(l_oper_rec.oper_count, ZERO_CHAR), 16, ZERO_CHAR);                                                     -- oper_count
            l_text := l_text || lpad(nvl(l_oper_rec.oper_amount, ZERO_CHAR), 16, ZERO_CHAR);                                                    -- oper_amount
            l_text := l_text || com_api_currency_pkg.get_currency_name(i_curr_code => nvl(l_oper_rec.oper_currency, l_national_currency));                                                  -- currency
            l_text := l_text || lpad(nvl(l_oper_rec.oper_request_amount, ZERO_CHAR), 16, ZERO_CHAR);                                            -- oper_request_amount
            l_text := l_text || com_api_currency_pkg.get_currency_name(i_curr_code => nvl(l_oper_rec.oper_currency, l_national_currency));                                                  -- currency
            l_text := l_text || lpad(nvl(l_oper_rec.oper_surcharge_amount, ZERO_CHAR), 16, ZERO_CHAR);                                          -- oper_surcharge_amount
            l_text := l_text || com_api_currency_pkg.get_currency_name(i_curr_code => nvl(l_oper_rec.oper_currency, l_national_currency));                                                  -- currency
            l_text := l_text || lpad(nvl(l_oper_rec.oper_cashback_amount, ZERO_CHAR), 16, ZERO_CHAR);                                           -- oper_cashback_amount
            l_text := l_text || com_api_currency_pkg.get_currency_name(i_curr_code => nvl(l_oper_rec.oper_currency, l_national_currency));                                                  -- currency
            l_text := l_text || lpad(nvl(l_oper_rec.sttl_amount, ZERO_CHAR), 16, ZERO_CHAR);                                                    -- sttt_amount
            l_text := l_text || com_api_currency_pkg.get_currency_name(i_curr_code => nvl(l_oper_rec.sttl_currency, l_national_currency));                                                  -- currency
            l_text := l_text || lpad(ZERO_CHAR, 16, ZERO_CHAR);                                                                 -- interchange_amount
            l_text := l_text || lpad(SPACE_CHAR, 3, SPACE_CHAR);                                                                -- currency
            l_text := l_text || lpad(nvl(l_oper_rec.originator_refnum, SPACE_CHAR), 36, SPACE_CHAR);                                             -- originator_refnum
            l_text := l_text || lpad(nvl(l_oper_rec.network_refnum, SPACE_CHAR), 36, SPACE_CHAR);                                                -- network_refnum
            l_text := l_text || lpad(nvl(l_oper_rec.acq_inst_bin, SPACE_CHAR), 12, SPACE_CHAR);                                                  -- acq_inst_bin
            l_text := l_text || lpad(nvl(l_oper_rec.forw_inst_bin, SPACE_CHAR), 12, SPACE_CHAR);                                                 -- forwarding_inst_bin
            l_text := l_text || lpad(SPACE_CHAR, 8, SPACE_CHAR);                                                                -- response_code
            l_text := l_text || lpad(nvl(l_oper_rec.oper_reason, SPACE_CHAR), 8, SPACE_CHAR);                                                    -- oper_reason
            l_text := l_text || lpad(nvl(l_oper_rec.status, SPACE_CHAR), 8, SPACE_CHAR);                                                         -- status
            l_text := l_text || lpad(nvl(l_oper_rec.status_reason, SPACE_CHAR), 8, SPACE_CHAR);                                                  -- status_reason
            l_text := l_text || nvl(l_oper_rec.is_reversal, ZERO_CHAR);                                                    -- is_reversal
            l_text := l_text || lpad(nvl(l_oper_rec.merchant_number, SPACE_CHAR), 15, SPACE_CHAR);                                               -- merchant_number
            l_text := l_text || lpad(nvl(l_oper_rec.mcc, SPACE_CHAR), 4, SPACE_CHAR);                                                            -- mcc
            l_text := l_text || lpad(nvl(substr(l_oper_rec.merchant_name, 1, 30), SPACE_CHAR), 30, SPACE_CHAR);                                  -- merchant_name
            l_text := l_text || lpad(nvl(substr(l_oper_rec.merchant_street, 1, 30), SPACE_CHAR), 30, SPACE_CHAR);                                -- merchant_street
            l_text := l_text || lpad(nvl(substr(l_oper_rec.merchant_city, 1, 30), SPACE_CHAR), 30, SPACE_CHAR);                                  -- merchant_city
            l_text := l_text || lpad(nvl(l_oper_rec.merchant_region, SPACE_CHAR), 3, SPACE_CHAR);                                                -- merchant_region
            l_text := l_text || lpad(nvl(l_oper_rec.merchant_country, SPACE_CHAR), 3, SPACE_CHAR);                                               -- merchant_country
            l_text := l_text || lpad(nvl(l_oper_rec.merchant_postcode, SPACE_CHAR), 10, SPACE_CHAR);                                             -- merchant_postcode
            l_text := l_text || lpad(nvl(l_oper_rec.terminal_type, SPACE_CHAR), 8, SPACE_CHAR);                                                  -- terminal_type
            l_text := l_text || lpad(nvl(substr(l_oper_rec.terminal_number, 1, 8), SPACE_CHAR), 8, SPACE_CHAR);                                  -- terminal_number
            l_text := l_text || lpad(nvl(to_char(l_oper_rec.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT), SPACE_CHAR), 19, SPACE_CHAR);     -- sttl_date
            l_text := l_text || lpad(SPACE_CHAR, 19, SPACE_CHAR);                                                               -- acq_sttl_date
            l_text := l_text || lpad(nvl(l_oper_rec.match_status, SPACE_CHAR), 8, SPACE_CHAR);                                                   -- match_status
            
            -- issuer
            opr_api_operation_pkg.get_participant(
                i_oper_id           => l_oper_tab(i)
              , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
              , o_participant       => l_participant_rec
            );
            
            l_text := l_text || lpad(nvl(l_participant_rec.client_id_type, SPACE_CHAR), 8, SPACE_CHAR);                                                  -- client_id_type
            l_text := l_text || lpad(nvl(l_participant_rec.card_number, SPACE_CHAR), 19, SPACE_CHAR);                                                    -- card_number
            l_text := l_text || lpad(nvl(to_char(l_participant_rec.card_id), SPACE_CHAR), 12, SPACE_CHAR);                                                        -- card_id
            l_text := l_text || lpad(nvl(to_char(l_participant_rec.card_instance_id), SPACE_CHAR), 12, SPACE_CHAR);                                               -- card_instance_id
            l_text := l_text || lpad(nvl(to_char(l_participant_rec.card_seq_number), SPACE_CHAR), 4, SPACE_CHAR);                                                -- card_seq_number
            l_text := l_text || lpad(nvl(to_char(l_participant_rec.card_expir_date, com_api_const_pkg.XML_DATE_FORMAT), SPACE_CHAR), 10, SPACE_CHAR);    -- card_expir_date
            l_text := l_text || lpad(nvl(l_participant_rec.card_country, SPACE_CHAR), 3, SPACE_CHAR);                                                    -- card_country
            l_text := l_text || lpad(nvl(to_char(l_participant_rec.inst_id), SPACE_CHAR), 4, SPACE_CHAR);                                                         -- inst_id
            l_text := l_text || lpad(nvl(to_char(l_participant_rec.network_id), SPACE_CHAR), 4, SPACE_CHAR);                                                      -- network_id
            l_text := l_text || lpad(nvl(l_participant_rec.auth_code, SPACE_CHAR), 6, SPACE_CHAR);                                                       -- auth_code
            l_text := l_text || lpad(nvl(substr(l_participant_rec.account_number, 1, 20), SPACE_CHAR), 20, SPACE_CHAR);                                  -- account_number
            l_text := l_text || lpad(nvl(substr(to_char(l_participant_rec.account_amount), 1, 16), SPACE_CHAR), 16, ZERO_CHAR);                          -- account_amount
            l_text := l_text || com_api_currency_pkg.get_currency_name(i_curr_code => nvl(l_participant_rec.account_currency, l_national_currency));                                                -- account_currency
            
            -- acquirer  
            opr_api_operation_pkg.get_participant(
                i_oper_id           => l_oper_tab(i)
              , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
              , o_participant       => l_participant_rec
            );
              
            l_text := l_text || lpad(nvl(l_participant_rec.client_id_type, SPACE_CHAR), 8, SPACE_CHAR);                                                  -- client_id_type
            l_text := l_text || lpad(nvl(substr(l_participant_rec.client_id_value, 1, 16), SPACE_CHAR), 16, SPACE_CHAR);                                 -- client_id_value
            l_text := l_text || lpad(nvl(to_char(l_participant_rec.inst_id), SPACE_CHAR), 4, SPACE_CHAR);                                                         -- inst_id
            l_text := l_text || lpad(nvl(to_char(l_participant_rec.network_id), SPACE_CHAR), 4, SPACE_CHAR);                                                      -- network_id
            l_text := l_text || lpad(nvl(substr(l_participant_rec.account_number, 1, 20), SPACE_CHAR), 20, SPACE_CHAR);                                  -- account_number
            
            -- custom participant
            -- now is dummy
            l_text := l_text || lpad(SPACE_CHAR, 52, SPACE_CHAR);
            
            -- transactions
            for r in (
            select am.posting_date
                 , am.conversion_rate
                 , am.amount_purpose
                 , p.*
                 , adeb.account_number as debt_acc_number
                 , adeb.currency as debt_acc_currency
                 , adeb.agent_id as debt_agent_id
                 , acrd.account_number as credit_acc_number
                 , acrd.currency as credit_acc_currency
                 , acrd.agent_id as credit_agent_id
              from acc_macros am
             inner join
                   (select nvl(d.macros_id, c.macros_id) as macros_id
                         , nvl(d.transaction_id, c.transaction_id) as transaction_id
                         , nvl(d.transaction_type, c.transaction_type) as transaction_type
                         , d.id as debt_id
                         , d.account_id as debt_account_id
                         , d.amount as debt_amount
                         , d.currency as debt_currency
                         , c.id as credit_id
                         , c.account_id as credit_account_id
                         , c.amount as credit_amount
                         , c.currency as credit_currency
                      from (select ae.* from acc_entry ae where ae.balance_impact = com_api_const_pkg.DEBIT) d
                      full outer
                      join (select ae.* from acc_entry ae where ae.balance_impact = com_api_const_pkg.CREDIT) c
                        on d.transaction_id = c.transaction_id
                   ) p
                on am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and am.object_id   = l_oper_tab(i)
               and am.id = p.macros_id
              left outer
              join acc_account adeb
                on p.debt_account_id = adeb.id
              left outer
              join acc_account acrd
                on p.credit_account_id = acrd.id
             where rownum <= COUNT_TRANS_DEF
             order by
                   p.transaction_id
            ) loop
                l_text := l_text || lpad(r.transaction_id, 16, ZERO_CHAR);                                                                      -- transaction_id
                l_text := l_text || lpad(nvl(r.transaction_type, SPACE_CHAR), 8, SPACE_CHAR);                                                                    -- transaction_type
                l_text := l_text || lpad(nvl(to_char(r.posting_date, com_api_const_pkg.XML_DATETIME_FORMAT), SPACE_CHAR), 19, SPACE_CHAR);                       -- posting_date
                -- debit_entry
                if r.debt_id is not null then
                    l_text := l_text || lpad(r.debt_id, 16, ZERO_CHAR);                                                                         -- entry_id
                    l_text := l_text || lpad(nvl(substr(r.debt_acc_number, 1, 20), SPACE_CHAR), 20, SPACE_CHAR);                                             -- account_number
                    l_text := l_text || com_api_currency_pkg.get_currency_name(i_curr_code => nvl(r.debt_acc_currency, l_national_currency));        -- currency
                    l_text := l_text || lpad(nvl(substr(ost_ui_agent_pkg.get_agent_number(i_agent_id => r.debt_agent_id), 1, 20), SPACE_CHAR), 20, SPACE_CHAR);  -- agent_number
                    l_text := l_text || lpad(nvl(to_char(r.debt_amount), ZERO_CHAR), 16, ZERO_CHAR);                                                            -- amount_value
                    l_text := l_text || com_api_currency_pkg.get_currency_name(i_curr_code => nvl(r.debt_currency, l_national_currency));            -- currency
                else
                    l_text := l_text || lpad(SPACE_CHAR, SIZE_ENTRY_BLOCK_DEF, SPACE_CHAR);
                end if;
                -- credit_entry
                if r.credit_id is not null then
                    l_text := l_text || lpad(r.credit_id, 16, ZERO_CHAR);                                                                           -- entry_id
                    l_text := l_text || lpad(nvl(substr(r.credit_acc_number, 1, 20), SPACE_CHAR), 20, SPACE_CHAR);                                               -- account_number
                    l_text := l_text || com_api_currency_pkg.get_currency_name(i_curr_code => nvl(r.credit_acc_currency, l_national_currency));          -- currency
                    l_text := l_text || lpad(nvl(substr(ost_ui_agent_pkg.get_agent_number(i_agent_id => r.credit_agent_id), 1, 20), SPACE_CHAR), 20, SPACE_CHAR);    -- agent_number
                    l_text := l_text || lpad(nvl(to_char(r.credit_amount), ZERO_CHAR), 16, ZERO_CHAR);                                                              -- amount_value
                    l_text := l_text || com_api_currency_pkg.get_currency_name(i_curr_code => nvl(r.credit_currency, l_national_currency));              -- currency
                else
                    l_text := l_text || lpad(SPACE_CHAR, SIZE_ENTRY_BLOCK_DEF, SPACE_CHAR);
                end if;

                l_text := l_text || lpad(nvl(r.conversion_rate, ONE_CHAR), 10, ZERO_CHAR);                                                                         -- conversion_rate
                l_text := l_text || lpad(SPACE_CHAR, 8, SPACE_CHAR);                                                                                -- rate_type
                l_text := l_text || lpad(nvl(r.amount_purpose, SPACE_CHAR), 8, SPACE_CHAR);                                                                          -- amount_purpose
                l_count_trans := l_count_trans + 1;
            end loop;
            
            if l_count_trans < COUNT_TRANS_DEF then
                l_text := l_text || lpad(SPACE_CHAR, SIZE_TRANS_BLOCK_DEF * (COUNT_TRANS_DEF - l_count_trans), SPACE_CHAR);
            end if;
            
            -- additional_amount
            opr_api_additional_amount_pkg.get_amounts(
                i_oper_id       => l_oper_tab(i)
              , o_amount_tab    => l_add_amount_tab
            );
            
            if l_add_amount_tab.count > 0 then
                for j in l_add_amount_tab.first .. l_add_amount_tab.last
                loop
                    l_add_amount_by_name_tab(l_add_amount_tab(j).amount_type).amount   := l_add_amount_tab(j).amount;
                    l_add_amount_by_name_tab(l_add_amount_tab(j).amount_type).currency := com_api_currency_pkg.get_currency_name(i_curr_code => nvl(l_add_amount_tab(j).currency, l_national_currency));
                end loop;
                
                -- AMPR0002
                if l_add_amount_by_name_tab.exists('AMPR0002') then
                    l_text := l_text || lpad(nvl(to_char(l_add_amount_by_name_tab('AMPR0002').amount), ZERO_CHAR), 22, ZERO_CHAR);       -- amount_value
                    l_text := l_text || l_add_amount_by_name_tab('AMPR0002').currency;                                   -- currency
                    l_text := l_text || 'AMPR0002';                                                                      -- amount_type
                else
                    l_text := l_text || lpad(SPACE_CHAR, SIZE_ADD_AMNT_BLOCK_DEF, SPACE_CHAR);
                end if;
                
                -- AMPR0003
                if l_add_amount_by_name_tab.exists('AMPR0003') then
                    l_text := l_text || lpad(nvl(to_char(l_add_amount_by_name_tab('AMPR0003').amount), ZERO_CHAR), 22, ZERO_CHAR);       -- amount_value
                    l_text := l_text || l_add_amount_by_name_tab('AMPR0003').currency;                                   -- currency
                    l_text := l_text || 'AMPR0003';                                                                      -- amount_type
                else
                    l_text := l_text || lpad(SPACE_CHAR, SIZE_ADD_AMNT_BLOCK_DEF, SPACE_CHAR);
                end if;
                
                -- AMPR0004
                if l_add_amount_by_name_tab.exists('AMPR0004') then
                    l_text := l_text || lpad(nvl(to_char(l_add_amount_by_name_tab('AMPR0004').amount), ZERO_CHAR), 22, ZERO_CHAR);       -- amount_value
                    l_text := l_text || l_add_amount_by_name_tab('AMPR0004').currency;                                   -- currency
                    l_text := l_text || 'AMPR0004';                                                                      -- amount_type
                else
                    l_text := l_text || lpad(SPACE_CHAR, SIZE_ADD_AMNT_BLOCK_DEF, SPACE_CHAR);
                end if;
                
                -- AMPR0011
                if l_add_amount_by_name_tab.exists('AMPR0011') then
                    l_text := l_text || lpad(nvl(to_char(l_add_amount_by_name_tab('AMPR0011').amount), ZERO_CHAR), 22, ZERO_CHAR);       -- amount_value
                    l_text := l_text || l_add_amount_by_name_tab('AMPR0011').currency;                                   -- currency
                    l_text := l_text || 'AMPR0011';                                                                      -- amount_type
                else
                    l_text := l_text || lpad(SPACE_CHAR, SIZE_ADD_AMNT_BLOCK_DEF, SPACE_CHAR);
                end if;
                
                -- AMPR0016
                if l_add_amount_by_name_tab.exists('AMPR0016') then
                    l_text := l_text || lpad(nvl(to_char(l_add_amount_by_name_tab('AMPR0016').amount), ZERO_CHAR), 22, ZERO_CHAR);       -- amount_value
                    l_text := l_text || l_add_amount_by_name_tab('AMPR0016').currency;                                   -- currency
                    l_text := l_text || 'AMPR0016';                                                                      -- amount_type
                else
                    l_text := l_text || lpad(SPACE_CHAR, SIZE_ADD_AMNT_BLOCK_DEF, SPACE_CHAR);
                end if;
                
                -- AMPR0020
                if l_add_amount_by_name_tab.exists('AMPR0020') then
                    l_text := l_text || lpad(nvl(to_char(l_add_amount_by_name_tab('AMPR0020').amount), ZERO_CHAR), 22, ZERO_CHAR);       -- amount_value
                    l_text := l_text || l_add_amount_by_name_tab('AMPR0020').currency;                                   -- currency
                    l_text := l_text || 'AMPR0020';                                                                      -- amount_type
                else
                    l_text := l_text || lpad(SPACE_CHAR, SIZE_ADD_AMNT_BLOCK_DEF, SPACE_CHAR);
                end if;
                
                -- AMPR7205
                if l_add_amount_by_name_tab.exists('AMPR7205') then
                    l_text := l_text || lpad(nvl(to_char(l_add_amount_by_name_tab('AMPR7205').amount), ZERO_CHAR), 22, ZERO_CHAR);       -- amount_value
                    l_text := l_text || l_add_amount_by_name_tab('AMPR7205').currency;                                   -- currency
                    l_text := l_text || 'AMPR7205';                                                                      -- amount_type
                else
                    l_text := l_text || lpad(SPACE_CHAR, SIZE_ADD_AMNT_BLOCK_DEF, SPACE_CHAR);
                end if;
                
                -- AMPR7206
                if l_add_amount_by_name_tab.exists('AMPR7206') then
                    l_text := l_text || lpad(nvl(to_char(l_add_amount_by_name_tab('AMPR7206').amount), ZERO_CHAR), 22, ZERO_CHAR);       -- amount_value
                    l_text := l_text || l_add_amount_by_name_tab('AMPR7206').currency;                                   -- currency
                    l_text := l_text || 'AMPR7206';                                                                      -- amount_type
                else
                    l_text := l_text || lpad(SPACE_CHAR, SIZE_ADD_AMNT_BLOCK_DEF, SPACE_CHAR);
                end if;
                
                -- AMPR7207
                if l_add_amount_by_name_tab.exists('AMPR7207') then
                    l_text := l_text || lpad(nvl(to_char(l_add_amount_by_name_tab('AMPR7207').amount), ZERO_CHAR), 22, ZERO_CHAR);       -- amount_value
                    l_text := l_text || l_add_amount_by_name_tab('AMPR7207').currency;                                   -- currency
                    l_text := l_text || 'AMPR7207';                                                                      -- amount_type
                else
                    l_text := l_text || lpad(SPACE_CHAR, SIZE_ADD_AMNT_BLOCK_DEF, SPACE_CHAR);
                end if;
                
                -- AMPR7208
                if l_add_amount_by_name_tab.exists('AMPR7208') then
                    l_text := l_text || lpad(nvl(to_char(l_add_amount_by_name_tab('AMPR7208').amount), ZERO_CHAR), 22, ZERO_CHAR);       -- amount_value
                    l_text := l_text || l_add_amount_by_name_tab('AMPR7208').currency;                                   -- currency
                    l_text := l_text || 'AMPR7208';                                                                      -- amount_type
                else
                    l_text := l_text || lpad(SPACE_CHAR, SIZE_ADD_AMNT_BLOCK_DEF, SPACE_CHAR);
                end if;

            else
                l_text := l_text || lpad(SPACE_CHAR, SIZE_ADD_AMNT_BLOCK_DEF * COUNT_ADD_AMOUNT_DEF, SPACE_CHAR);
            end if;
            
            -- Fill end
            l_text := l_text || lpad(SPACE_CHAR, SIZE_TRAILER_FILL, SPACE_CHAR);
            
            prc_api_file_pkg.put_line(
                i_raw_data      => l_text
              , i_sess_file_id  => l_session_file_id
            );
            prc_api_file_pkg.put_file(
                i_sess_file_id   => l_session_file_id
              , i_clob_content   => l_text || CRLF
              , i_add_to         => com_api_const_pkg.TRUE
            );
            
            l_processed_count := l_processed_count + 1;
        end loop;
        
        prc_api_file_pkg.close_file(
            i_sess_file_id => l_session_file_id
          , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
        
        if l_event_tab.count > 0 then
            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab => l_event_tab
            );
        end if;
        
    end if;
    
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'finished success'
    );

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
exception
    when others then
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'finished with errors: [#1]'
          , i_env_param1  => sqlcode
        );
        
        l_excepted_count := l_estimated_count - l_processed_count;
        
        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE 
           and com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
        then
            
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
            
        end if;
        
        raise;
        
end uploading_cbs_file;

end cst_ap_prc_outgoing_pkg;
/
