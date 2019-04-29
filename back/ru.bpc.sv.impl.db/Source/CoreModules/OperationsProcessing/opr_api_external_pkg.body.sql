create or replace package body opr_api_external_pkg as
/**********************************************************
 * API external for OPR <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 06.03.2018 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: OPR_API_EXTERNAL_PKG
 * @headcom
 **********************************************************/
procedure get_operations_data(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_participant_type          in  com_api_type_pkg.t_dict_value       default null
  , i_start_date                in  date
  , i_end_date                  in  date
  , i_object_tab                in  com_api_type_pkg.t_object_tab
  , i_oper_currency             in  com_api_type_pkg.t_curr_code        default null
  , i_array_operations_type_id  in  com_api_type_pkg.t_medium_id        default null
  , i_array_oper_statuses_id    in  com_api_type_pkg.t_medium_id        default null
  , i_mask_error                in  com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_row_count                out  com_api_type_pkg.t_long_id
  , o_ref_cursor               out  com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_operations_data: ';
    OBJECT_TAB_COUNT_MAX   constant com_api_type_pkg.t_short_id := 1;
    
    l_cursor_count     com_api_type_pkg.t_name := 'select /*+ index(o opr_oper_date_ndx) */ count(1) '
    ;
    l_cursor_column    com_api_type_pkg.t_text := 'select /*+ index(o opr_oper_date_ndx) */ row_number() over(order by o.id) as oper_num'
                                               ||      ', o.id as oper_id'
                                               ||      ', o.oper_type'
                                               ||      ', o.oper_reason'
                                               ||      ', o.is_reversal'
                                               ||      ', o.original_id'
                                               ||      ', o.msg_type'
                                               ||      ', o.sttl_type'
                                               ||      ', o.oper_amount'
                                               ||      ', o.oper_currency'
                                               ||      ', o.oper_date'
                                               ||      ', o.host_date'
                                               ||      ', o.unhold_date'
                                               ||      ', o.sttl_date as oper_sttl_date'
                                               ||      ', o.status as oper_status'
                                               ||      ', o.status_reason as oper_status_reason'
                                               ||      ', o.terminal_type'
                                               ||      ', o.acq_inst_bin'
                                               ||      ', o.forw_inst_bin'
                                               ||      ', o.merchant_number'
                                               ||      ', o.terminal_number'
                                               ||      ', o.merchant_name'
                                               ||      ', o.merchant_street'
                                               ||      ', o.merchant_city'
                                               ||      ', o.merchant_region'
                                               ||      ', o.merchant_country'
                                               ||      ', o.merchant_postcode'
                                               ||      ', o.mcc'
                                               ||      ', o.originator_refnum'
                                               ||      ', o.network_refnum'
                                               ||      ', o.match_status'
                                               ||      ', o.dispute_id'
                                               ||      ', o.payment_order_id'
                                               ||      ', o.payment_host_id'
                                               ||      ', o.fee_amount'
                                               ||      ', o.fee_currency'
                                               ||      ', a.resp_code'
                                               ||      ', a.proc_type'
                                               ||      ', a.proc_mode'
                                               ||      ', a.bin_amount'
                                               ||      ', a.bin_currency'
                                               ||      ', a.bin_cnvt_rate'
                                               ||      ', a.network_amount'
                                               ||      ', a.network_currency'
                                               ||      ', a.network_cnvt_date'
                                               ||      ', a.network_cnvt_rate'
                                               ||      ', a.account_cnvt_rate'
                                               ||      ', a.transaction_id'
                                               ||      ', a.system_trace_audit_number'
                                               ||      ', a.external_auth_id'
                                               ||      ', a.external_orig_id'
                                               ||      ', a.agent_unique_id'
                                               ||      ', a.trace_number'
                                               ||      ', og.msg_type orig_msg_type'
                                               ||      ', og.sttl_type orig_sttl_type'
                                               ||      ', og.oper_amount orig_oper_amount'
                                               ||      ', og.oper_currency orig_oper_currency'
                                               ||      ', og.oper_date orig_oper_date'
                                               ||      ', og.host_date orig_host_date'
                                               ||      ', og.unhold_date orig_unhold_date'
                                               ||      ', og.terminal_type orig_terminal_type'
                                               ||      ', og.acq_inst_bin orig_acq_inst_bin'
                                               ||      ', og.forw_inst_bin orig_forw_inst_bin'
                                               ||      ', og.originator_refnum orig_originator_refnum'
                                               ||      ', og.network_refnum orig_network_refnum'
                                               ||      ', ag.bin_amount orig_bin_amount'
                                               ||      ', ag.bin_currency orig_bin_currency'
                                               ||      ', ag.bin_cnvt_rate orig_bin_cnvt_rate'
                                               ||      ', ag.network_amount orig_network_amount'
                                               ||      ', ag.network_currency orig_network_currency'
                                               ||      ', ag.network_cnvt_date orig_network_cnvt_date'
                                               ||      ', ag.network_cnvt_rate orig_network_cnvt_rate'
                                               ||      ', ag.account_cnvt_rate orig_account_cnvt_rate'
                                               ||      ', ag.transaction_id orig_transaction_id'
                                               ||      ', ag.system_trace_audit_number orig_system_trace_audit_number'
                                               ||      ', ag.external_auth_id orig_external_auth_id'
                                               ||      ', ag.external_orig_id orig_external_orig_id'
                                               ||      ', ag.agent_unique_id orig_agent_unique_id'
                                               ||      ', ag.trace_number orig_trace_number '
    ;
    l_cursor_tbl       com_api_type_pkg.t_text := '  from opr_operation o '
                                               ||        'left outer join aut_auth a on o.id = a.id '
                                               ||        'left outer join opr_operation og on o.original_id = og.id '
                                               ||        'left outer join aut_auth ag on og.id = ag.id '
    ;
    l_cursor_order     com_api_type_pkg.t_full_desc := 
                                                    'order by o.id '
    ;
    l_cursor_where     com_api_type_pkg.t_text := 'where '
                                               ||       'trunc(o.oper_date) between :start_date and :end_date '
                                               ||   'and exists(select /*+ index(p opr_participant_pk) */ 1 from opr_participant p where p.oper_id = o.id and p.participant_type = nvl(:participant_type, p.participant_type) and p.inst_id = decode(:inst_id, ' || ost_api_const_pkg.DEFAULT_INST || ', p.inst_id, :inst_id)) '
    ;
    l_cursor_str       com_api_type_pkg.t_sql_statement;
    
    l_inst_id          com_api_type_pkg.t_inst_id;
    
begin
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - inst_id [#1] start_date [#2] end_date [#3] object_tab.count [#4] array_operations_type_id [#5] array_oper_statuses_id [#6'
               || '], participant_type [' || i_participant_type
               || '], oper_currency [' || i_oper_currency
               || '], mask_error [' || i_mask_error
               || ']'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_start_date
      , i_env_param3 => i_end_date
      , i_env_param4 => i_object_tab.count
      , i_env_param5 => i_array_operations_type_id
      , i_env_param6 => i_array_oper_statuses_id
    );
    
    l_inst_id := nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);
    
    if i_object_tab.count > 0 then
        for i in i_object_tab.first .. i_object_tab.last loop
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'Create where clause on object_tab count [#1] level_type [#2]'
                  , i_env_param1 => i
                  , i_env_param2 => i_object_tab(i).level_type
                );
            if i_object_tab(i).level_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'Create where clause on object_tab count [#1] entity_type [#2] object_id.count [#3]'
                  , i_env_param1 => i
                  , i_env_param2 => i_object_tab(i).entity_type
                  , i_env_param3 => case when i_object_tab(i).object_id.exists(1) then i_object_tab(i).object_id.count else 0 end
                );
                if i_object_tab(i).entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
                    l_cursor_where := l_cursor_where
                                   || 'and o.id in (select column_value from table(:tab' || i || ')) '
                    ;
                else
                    com_api_error_pkg.raise_error(
                        i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
                      , i_env_param1 => i_object_tab(i).entity_type
                    );
                end if;
            else
                com_api_error_pkg.raise_error(
                    i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
                  , i_env_param1 => i_object_tab(i).level_type
                );
            end if;
        end loop;
    end if;
    
    if i_oper_currency is not null then
        l_cursor_where := l_cursor_where || 'and o.oper_currency = ''' || i_oper_currency || ''' '
        ;
    end if;
    
    if i_array_operations_type_id is not null then
        l_cursor_where := l_cursor_where || 'and exists(select 1 from com_array_element where array_id = ' || i_array_operations_type_id || ' and element_value = o.oper_type) '
        ;
    end if;
    
    if i_array_oper_statuses_id is not null then
        l_cursor_where := l_cursor_where || 'and exists(select 1 from com_array_element where array_id = ' || i_array_oper_statuses_id || ' and element_value = o.status) '
        ;
    end if;
    
    l_cursor_str := l_cursor_count || l_cursor_tbl || l_cursor_where;
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'l_sql_statement (1): ' || substr(l_cursor_str, 1, 3900)
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'l_sql_statement (2): ' || substr(l_cursor_str, 3901, 3900)
    );
    if i_object_tab.count = 0 then
        execute immediate l_cursor_str
                     into o_row_count
                    using 
                       in i_start_date,
                       in i_end_date,
                       in i_participant_type,
                       in l_inst_id,
                       in l_inst_id
        ;
    elsif i_object_tab.count = 1 then
        execute immediate l_cursor_str
                     into o_row_count
                    using 
                       in i_start_date,
                       in i_end_date,
                       in i_participant_type,
                       in l_inst_id,
                       in l_inst_id,
                       in i_object_tab(1).object_id
        ;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'NOT_SUPPORTED_QUANTITY_OBJECTS'
          , i_env_param1 => i_object_tab.count
          , i_env_param2 => OBJECT_TAB_COUNT_MAX
        );
    end if;
    
    if o_row_count = 0 then
        if i_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'The requested data [#1] was not found'
              , i_env_param1  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'REQUESTED_DATA_NOT_FOUND'
              , i_env_param1 => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            );
        end if;
    else
        
        l_cursor_str := l_cursor_column || l_cursor_tbl || l_cursor_where || l_cursor_order;
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_sql_statement (1): ' || substr(l_cursor_str, 1, 3900)
        );
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_sql_statement (2): ' || substr(l_cursor_str, 3901, 3900)
        );
        if i_object_tab.count = 0 then
            open  o_ref_cursor 
              for l_cursor_str
            using i_start_date
                , i_end_date
                , i_participant_type
                , l_inst_id
                , l_inst_id
            ;
        elsif i_object_tab.count = 1 then
            open  o_ref_cursor 
              for l_cursor_str
            using i_start_date
                , i_end_date
                , i_participant_type
                , l_inst_id
                , l_inst_id
                , i_object_tab(1).object_id
            ;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'NOT_SUPPORTED_QUANTITY_OBJECTS'
              , i_env_param1 => i_object_tab.count
              , i_env_param2 => OBJECT_TAB_COUNT_MAX
            );
        end if;
        
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished success!'
        );
    end if;
exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished failed with params - inst_id [#1] start_date [#2] end_date [#3] object_tab.count [#4] array_operations_type_id [#5] array_oper_statuses_id [#6'
               || '], participant_type [' || i_participant_type
               || '], oper_currency [' || i_oper_currency
               || '], mask_error [' || i_mask_error
               || ']'
          , i_env_param1 => l_inst_id
          , i_env_param2 => i_start_date
          , i_env_param3 => i_end_date
          , i_env_param4 => i_object_tab.count
          , i_env_param5 => i_array_operations_type_id
          , i_env_param6 => i_array_oper_statuses_id
        );
        
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
           
            if i_mask_error = com_api_const_pkg.TRUE then
            
                null;
                
            else
                
                raise;
                
            end if;
            
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            
            raise;

        else
            
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
            
        end if;
        
end get_operations_data;

procedure get_oper_participants_data(
    i_inst_id                       in  com_api_type_pkg.t_inst_id
  , i_oper_id                       in  com_api_type_pkg.t_long_id
  , i_array_oper_paricipant_type    in  com_api_type_pkg.t_medium_id        default null
  , i_mask_error                    in  com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_row_count                    out  com_api_type_pkg.t_long_id
  , o_ref_cursor                   out  com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_oper_participants_data: ';
    
    l_cursor_count     com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column    com_api_type_pkg.t_text := 'select op.oper_id'
                                               ||      ', op.participant_type'
                                               ||      ', op.client_id_type'
                                               ||      ', op.client_id_value'
                                               ||      ', op.inst_id'
                                               ||      ', op.network_id'
                                               ||      ', op.card_inst_id'
                                               ||      ', op.card_network_id'
                                               ||      ', op.card_id'
                                               ||      ', op.card_instance_id'
                                               ||      ', op.card_type_id'
                                               ||      ', iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) card_number'
                                               ||      ', op.card_mask'
                                               ||      ', op.card_hash'
                                               ||      ', op.card_seq_number'
                                               ||      ', op.card_expir_date'
                                               ||      ', op.card_service_code'
                                               ||      ', op.card_country'
                                               ||      ', op.customer_id'
                                               ||      ', op.account_id'
                                               ||      ', op.account_type'
                                               ||      ', op.account_number'
                                               ||      ', op.account_amount'
                                               ||      ', op.account_currency'
                                               ||      ', op.auth_code'
                                               ||      ', op.merchant_id'
                                               ||      ', op.terminal_id'
                                               ||      ', op.split_hash'
                                               ||      ', (select 1 '
                                               ||           'from acc_macros am'
                                               ||              ', acc_entry ae'
                                               ||              ', acc_account_object ao '
                                               ||          'where am.object_id = op.oper_id '
                                               ||            'and am.entity_type = ''' || opr_api_const_pkg.ENTITY_TYPE_OPERATION || ''' '
                                               ||            'and ao.object_id(+)   = case op.participant_type '
                                               ||                                        'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_CARD || ''' '
                                               ||                                            'then op.card_id '
                                               ||                                        'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL || ''' '
                                               ||                                            'then op.terminal_id '
                                               ||                                        'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_MERCHANT || ''' '
                                               ||                                            'then op.merchant_id '
                                               ||                                        'else '
                                               ||                                              'null '
                                               ||                                    'end '
                                               ||            'and ao.entity_type(+) = case op.participant_type '
                                               ||                                        'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_CARD || ''' '
                                               ||                                            'then ''' || iss_api_const_pkg.ENTITY_TYPE_CARD || ''' '
                                               ||                                        'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL || ''' '
                                               ||                                            'then ''' || acq_api_const_pkg.ENTITY_TYPE_TERMINAL || ''' '
                                               ||                                        'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_MERCHANT || ''' '
                                               ||                                            'then ''' || acq_api_const_pkg.ENTITY_TYPE_MERCHANT || ''' '
                                               ||                                        'else '
                                               ||                                            'null '
                                               ||                                    'end '
                                               ||            'and ae.macros_id   = am.id '
                                               ||            'and ae.account_id  = nvl(op.account_id, ao.account_id) '
                                               ||            'and ae.balance_impact = ' || com_api_const_pkg.DEBIT || ' '
                                               ||            'and rownum < 2 '
                                               ||        ') debit_entry_impact'
                                               ||      ', (select 1 '
                                               ||           'from acc_macros am'
                                               ||              ', acc_entry ae'
                                               ||              ', acc_account_object ao '
                                               ||          'where am.object_id = op.oper_id '
                                               ||            'and am.entity_type = ''' || opr_api_const_pkg.ENTITY_TYPE_OPERATION || ''' '
                                               ||            'and ao.object_id(+)   = case op.participant_type '
                                               ||                                        'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_CARD || ''' '
                                               ||                                            'then op.card_id '
                                               ||                                        'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL || ''' '
                                               ||                                            'then op.terminal_id '
                                               ||                                        'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_MERCHANT || ''' '
                                               ||                                            'then op.merchant_id '
                                               ||                                        'else '
                                               ||                                              'null '
                                               ||                                    'end '
                                               ||            'and ao.entity_type(+) = case op.participant_type '
                                               ||                                        'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_CARD || ''' '
                                               ||                                            'then ''' || iss_api_const_pkg.ENTITY_TYPE_CARD || ''' '
                                               ||                                        'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL || ''' '
                                               ||                                            'then ''' || acq_api_const_pkg.ENTITY_TYPE_TERMINAL || ''' '
                                               ||                                        'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_MERCHANT || ''' '
                                               ||                                            'then ''' || acq_api_const_pkg.ENTITY_TYPE_MERCHANT || ''' '
                                               ||                                        'else '
                                               ||                                            'null '
                                               ||                                    'end '
                                               ||            'and ae.macros_id   = am.id '
                                               ||            'and ae.account_id  = nvl(op.account_id, ao.account_id) '
                                               ||            'and ae.balance_impact = ' || com_api_const_pkg.CREDIT || ' '
                                               ||            'and rownum < 2 '
                                               ||        ') credit_entry_impact '
    ;
    l_cursor_tbl       com_api_type_pkg.t_text := '  from opr_participant op'
                                               ||      ' left outer join opr_card c on op.oper_id = c.oper_id and op.participant_type = c.participant_type '
    ;
    l_cursor_where     com_api_type_pkg.t_text := 'where '
                                               ||       'op.oper_id = :oper_id '
    ;
    l_cursor_str       com_api_type_pkg.t_sql_statement;
    
    l_inst_id          com_api_type_pkg.t_inst_id;
    
begin
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Started with params - inst_id [#1] oper_id [#2] array_oper_paricipant_type [#3] mask_error [#4]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_oper_id
      , i_env_param3 => i_array_oper_paricipant_type
      , i_env_param4 => i_mask_error
    );
    
    l_inst_id := nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);
    
    if i_array_oper_paricipant_type is not null then
        l_cursor_where := l_cursor_where || 'and op.participant_type in (select element_value from com_array_element where array_id = ' || i_array_oper_paricipant_type || ') '
        ;
    end if;
    
    if l_inst_id <> ost_api_const_pkg.DEFAULT_INST then
        l_cursor_where := l_cursor_where
                       || 'and op.inst_id = ' || l_inst_id || ' '
        ;
    end if;
    
    l_cursor_str := l_cursor_count || l_cursor_tbl || l_cursor_where;
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'l_sql_statement (1): ' || substr(l_cursor_str, 1, 3900)
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'l_sql_statement (2): ' || substr(l_cursor_str, 3901, 3900)
    );
    execute immediate l_cursor_str
                 into o_row_count
                using 
                   in i_oper_id
    ;
    
    if o_row_count = 0 then
        if i_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'The requested data [#1] was not found'
              , i_env_param1  => opr_api_const_pkg.ENTITY_TYPE_OPER_PARTICIPANT
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'REQUESTED_DATA_NOT_FOUND'
              , i_env_param1 => opr_api_const_pkg.ENTITY_TYPE_OPER_PARTICIPANT
            );
        end if;
    else
        l_cursor_str := l_cursor_column || l_cursor_tbl || l_cursor_where;
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_sql_statement (1): ' || substr(l_cursor_str, 1, 3900)
        );
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_sql_statement (2): ' || substr(l_cursor_str, 3901, 3900)
        );
        open  o_ref_cursor 
          for l_cursor_str
        using i_oper_id
        ;
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished success!'
        );
    end if;
exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'Finished failed with params - inst_id [#1] oper_id [#2] array_oper_paricipant_type [#3] mask_error [#4]'
          , i_env_param1 => l_inst_id
          , i_env_param2 => i_oper_id
          , i_env_param3 => i_array_oper_paricipant_type
          , i_env_param4 => i_mask_error
        );
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            if i_mask_error = com_api_const_pkg.TRUE then
                null;
            else
                raise;
            end if;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end get_oper_participants_data;

procedure get_aggr_oper_transact_data(
    i_inst_id                       in  com_api_type_pkg.t_inst_id
  , i_start_date                    in  date
  , i_end_date                      in  date
  , i_object_tab                    in  com_api_type_pkg.t_object_tab
  , i_oper_currency                 in  com_api_type_pkg.t_curr_code        default null
  , i_array_oper_paricipant_type    in  com_api_type_pkg.t_medium_id        default null
  , i_array_operations_type_id      in  com_api_type_pkg.t_medium_id        default null
  , i_array_oper_statuses_id        in  com_api_type_pkg.t_medium_id        default null
  , i_aggr_operations_type          in  com_api_type_pkg.t_boolean
  , i_aggr_opr_participant          in  com_api_type_pkg.t_boolean
  , i_aggr_terminal_type            in  com_api_type_pkg.t_boolean
  , i_aggr_balance_impact           in  com_api_type_pkg.t_boolean
  , i_mask_error                    in  com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_row_count                    out  com_api_type_pkg.t_long_id
  , o_ref_cursor                   out  com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_aggr_oper_transact_data: ';
    OBJECT_TAB_COUNT_MAX   constant com_api_type_pkg.t_short_id := 1;
    CURSOR_COLUMN_STATIC   constant com_api_type_pkg.t_full_desc :=   'ae.currency as entry_currecy'
                                                                 || ', sum(nvl(ae.amount, 0)) as amount '
    ;
    CURSOR_WHERE_STATIC    constant com_api_type_pkg.t_full_desc := 'and p.inst_id = decode(:inst_id, ' || ost_api_const_pkg.DEFAULT_INST || ', p.inst_id, :inst_id) '
                                                                 || 'and ao.entity_type(+) = case p.participant_type '
                                                                 ||                             'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_CARD || ''' '
                                                                 ||                                 'then ''' || iss_api_const_pkg.ENTITY_TYPE_CARD || ''' '
                                                                 ||                             'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL || ''' '
                                                                 ||                                 'then ''' || acq_api_const_pkg.ENTITY_TYPE_TERMINAL || ''' '
                                                                 ||                             'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_MERCHANT || ''' '
                                                                 ||                                 'then ''' || acq_api_const_pkg.ENTITY_TYPE_MERCHANT || ''' '
                                                                 ||                             'else '
                                                                 ||                                 'null '
                                                                 ||                         'end '
                                                                 || 'and ao.object_id(+)   = case p.participant_type '
                                                                 ||                             'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_CARD || ''' '
                                                                 ||                                 'then p.card_id '
                                                                 ||                             'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL || ''' '
                                                                 ||                                 'then p.terminal_id '
                                                                 ||                             'when ''' || opr_api_const_pkg.CLIENT_ID_TYPE_MERCHANT || ''' '
                                                                 ||                                 'then p.merchant_id '
                                                                 ||                             'else '
                                                                 ||                                 'null '
                                                                 ||                         'end '
                                                                 || 'and am.entity_type = ''' || opr_api_const_pkg.ENTITY_TYPE_OPERATION || ''' '
                                                                 || 'and am.object_id   = o.id '
                                                                 || 'and ae.macros_id   = am.id '
                                                                 || 'and ae.account_id  = nvl(p.account_id, ao.account_id) '
                                                                 || 'and ae.balance_impact <> 0 '
    ;
    CURSOR_GROUP_BY_STATIC constant com_api_type_pkg.t_name := 'ae.currency '
    ;
    CURSOR_ORDER_BY_STATIC constant com_api_type_pkg.t_name := 'ae.currency '
    ;
    l_cursor_count     com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column    com_api_type_pkg.t_text := 'select /*+ index(o opr_oper_date_ndx) */ '
                                               
    ;
    l_cursor_tbl       com_api_type_pkg.t_name := ' from opr_operation o'
                                               ||     ', opr_participant p'
                                               ||     ', acc_account_object ao'
                                               ||     ', acc_macros am'
                                               ||     ', acc_entry ae '
    ;
    l_cursor_where     com_api_type_pkg.t_text := 'where '
                                               ||       'trunc(o.oper_date) between :start_date and :end_date '
                                               ||   'and p.oper_id = o.id '
    ;
    l_cursor_group_by  com_api_type_pkg.t_full_desc := 'group by ';
    l_cursor_order_by  com_api_type_pkg.t_full_desc := 'order by ';
    l_cursor_str       com_api_type_pkg.t_sql_statement;
    
    l_inst_id          com_api_type_pkg.t_inst_id;
    
begin
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - inst_id [#1] start_date [#2] end_date [#3] object_tab.count [#4] array_operations_type_id [#5] array_oper_statuses_id [#6'
               || '], oper_currency [' || i_oper_currency
               || '], array_oper_paricipant_type [' || i_array_oper_paricipant_type
               || '], aggr_operations_type [' || i_aggr_operations_type
               || '], aggr_opr_participant [' || i_aggr_opr_participant
               || '], aggr_terminal_type [' || i_aggr_terminal_type
               || '], aggr_balance_impact [' || i_aggr_balance_impact
               || '], mask_error [' || i_mask_error
               || ']'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_start_date
      , i_env_param3 => i_end_date
      , i_env_param4 => i_object_tab.count
      , i_env_param5 => i_array_operations_type_id
      , i_env_param6 => i_array_oper_statuses_id
    );
    
    l_inst_id := nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);
    
    if i_array_oper_paricipant_type is not null then
        l_cursor_where := l_cursor_where || 'and p.participant_type in (select element_value from com_array_element where array_id = ' || i_array_oper_paricipant_type || ') '
        ;
    end if;
    
    if i_object_tab.count > 0 then
        for i in i_object_tab.first .. i_object_tab.last loop
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'Create where clause on object_tab count [#1] level_type [#2]'
                  , i_env_param1 => i
                  , i_env_param2 => i_object_tab(i).level_type
                );
            if i_object_tab(i).level_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'Create where clause on object_tab count [#1] entity_type [#2] object_id.count [#3]'
                  , i_env_param1 => i
                  , i_env_param2 => i_object_tab(i).entity_type
                  , i_env_param3 => case when i_object_tab(i).object_id.exists(1) then i_object_tab(i).object_id.count else 0 end
                );
                if i_object_tab(i).entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
                    l_cursor_where := l_cursor_where
                                   || 'and o.id in (select column_value from table(:tab' || i || ')) '
                    ;
                else
                    com_api_error_pkg.raise_error(
                        i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
                      , i_env_param1 => i_object_tab(i).entity_type
                    );
                end if;
            else
                com_api_error_pkg.raise_error(
                    i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
                  , i_env_param1 => i_object_tab(i).level_type
                );
            end if;
        end loop;
    end if;
    
    if i_oper_currency is not null then
        l_cursor_where := l_cursor_where || 'and o.oper_currency = ''' || i_oper_currency || ''' '
        ;
    end if;
    
    if i_array_operations_type_id is not null then
        l_cursor_where := l_cursor_where || 'and exists(select 1 from com_array_element where array_id = ' || i_array_operations_type_id || ' and element_value = o.oper_type) '
        ;
    end if;
    
    if i_array_oper_statuses_id is not null then
        l_cursor_where := l_cursor_where || 'and exists(select 1 from com_array_element where array_id = ' || i_array_oper_statuses_id || ' and element_value = o.status) '
        ;
    end if;
    
    l_cursor_where := l_cursor_where || CURSOR_WHERE_STATIC;
    
    if nvl(i_aggr_operations_type, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
        l_cursor_column := l_cursor_column || 'o.oper_type, ';
        l_cursor_group_by := l_cursor_group_by || 'o.oper_type, ';
        l_cursor_order_by := l_cursor_order_by || 'o.oper_type, ';
    else
        l_cursor_column := l_cursor_column || 'null as oper_type, ';
    end if;
    if nvl(i_aggr_opr_participant, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
        l_cursor_column := l_cursor_column || 'p.participant_type, ';
        l_cursor_group_by := l_cursor_group_by || 'p.participant_type, ';
        l_cursor_order_by := l_cursor_order_by || 'p.participant_type, ';
    else
        l_cursor_column := l_cursor_column || 'null as participant_type, ';
    end if;
    if nvl(i_aggr_terminal_type, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
        l_cursor_column := l_cursor_column || 'o.terminal_type, ';
        l_cursor_group_by := l_cursor_group_by || 'o.terminal_type, ';
        l_cursor_order_by := l_cursor_order_by || 'o.terminal_type, ';
    else
        l_cursor_column := l_cursor_column || 'null as terminal_type, ';
    end if;
    if nvl(i_aggr_balance_impact, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
        l_cursor_column := l_cursor_column || 'ae.balance_impact, ';
        l_cursor_group_by := l_cursor_group_by || 'ae.balance_impact, ';
        l_cursor_order_by := l_cursor_order_by || 'ae.balance_impact, ';
    else
        l_cursor_column := l_cursor_column || 'null as balance_impact, ';
    end if;
    l_cursor_column := l_cursor_column || CURSOR_COLUMN_STATIC;
    l_cursor_group_by := l_cursor_group_by || CURSOR_GROUP_BY_STATIC;
    l_cursor_order_by := l_cursor_order_by || CURSOR_ORDER_BY_STATIC;
    l_cursor_str := l_cursor_count || 'from (' || l_cursor_column || l_cursor_tbl || l_cursor_where || l_cursor_group_by || ')';
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'l_sql_statement (1): ' || substr(l_cursor_str, 1, 3900)
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'l_sql_statement (2): ' || substr(l_cursor_str, 3901, 3900)
    );
    if i_object_tab.count = 0 then
        execute immediate l_cursor_str
                     into o_row_count
                    using 
                       in i_start_date,
                       in i_end_date,
                       in l_inst_id,
                       in l_inst_id
        ;
    elsif i_object_tab.count = 1 then
        execute immediate l_cursor_str
                     into o_row_count
                    using 
                       in i_start_date,
                       in i_end_date,
                       in i_object_tab(1).object_id,
                       in l_inst_id,
                       in l_inst_id
        ;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'NOT_SUPPORTED_QUANTITY_OBJECTS'
          , i_env_param1 => i_object_tab.count
          , i_env_param2 => OBJECT_TAB_COUNT_MAX
        );
    end if;
    
    if o_row_count = 0 then
        if i_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'The requested data [#1] was not found'
              , i_env_param1  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'REQUESTED_DATA_NOT_FOUND'
              , i_env_param1 => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            );
        end if;
    else
        
        l_cursor_str := l_cursor_column || l_cursor_tbl || l_cursor_where || l_cursor_group_by || l_cursor_order_by;
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_sql_statement (1): ' || substr(l_cursor_str, 1, 3900)
        );
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_sql_statement (2): ' || substr(l_cursor_str, 3901, 3900)
        );
        if i_object_tab.count = 0 then
            open  o_ref_cursor 
              for l_cursor_str
            using i_start_date
                , i_end_date
                , l_inst_id
                , l_inst_id
            ;
        elsif i_object_tab.count = 1 then
            open  o_ref_cursor 
              for l_cursor_str
            using i_start_date
                , i_end_date
                , i_object_tab(1).object_id
                , l_inst_id
                , l_inst_id
            ;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'NOT_SUPPORTED_QUANTITY_OBJECTS'
              , i_env_param1 => i_object_tab.count
              , i_env_param2 => OBJECT_TAB_COUNT_MAX
            );
        end if;
        
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished success!'
        );
    end if;
exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished failed with params - inst_id [#1] start_date [#2] end_date [#3] object_tab.count [#4] array_operations_type_id [#5] array_oper_statuses_id [#6'
                   || '], oper_currency [' || i_oper_currency
                   || '], array_oper_paricipant_type [' || i_array_oper_paricipant_type
                   || '], aggr_operations_type [' || i_aggr_operations_type
                   || '], aggr_opr_participant [' || i_aggr_opr_participant
                   || '], aggr_terminal_type [' || i_aggr_terminal_type
                   || '], aggr_balance_impact [' || i_aggr_balance_impact
                   || '], mask_error [' || i_mask_error
                   || ']'
          , i_env_param1 => i_inst_id
          , i_env_param2 => i_start_date
          , i_env_param3 => i_end_date
          , i_env_param4 => i_object_tab.count
          , i_env_param5 => i_array_operations_type_id
          , i_env_param6 => i_array_oper_statuses_id
        );
        
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            if i_mask_error = com_api_const_pkg.TRUE then
                null;
            else
                raise;
            end if;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end get_aggr_oper_transact_data;

procedure get_operations(
    i_inst_id                  in  com_api_type_pkg.t_inst_id
  , i_date_type                in  com_api_type_pkg.t_dict_value  
  , i_start_date               in  date
  , i_end_date                 in  date
  , i_array_balance_type_id    in  com_api_type_pkg.t_medium_id        default null
  , i_array_trans_type_id      in  com_api_type_pkg.t_medium_id        default null
  , i_array_settl_type_id      in  com_api_type_pkg.t_medium_id        default null
  , i_array_operations_type_id in  com_api_type_pkg.t_medium_id        default null
  , o_ref_cursor              out  com_api_type_pkg.t_ref_cur
) is
    l_inst_id           com_api_type_pkg.t_inst_id        := nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);  
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_operations';
begin

    open o_ref_cursor for
  select distinct op.id
       , op.oper_type
       , op.msg_type
       , op.sttl_type
       , rcn.recon_type
       , op.oper_date
       , op.host_date
       , op.oper_count   
       , op.oper_currency             
       , op.oper_amount
       , op.oper_request_amount
       , op.oper_surcharge_amount
       , op.oper_cashback_amount
       , op.sttl_amount
       , op.sttl_currency
       , op.fee_amount
       , op.fee_currency
       , op.originator_refnum
       , op.network_refnum
       , op.acq_inst_bin
       , op.forw_inst_bin  
       , case op.status_reason
             when aut_api_const_pkg.AUTH_REASON_DUE_TO_RESP_CODE
                 then (select a.resp_code    from aut_auth a where a.id = op.id)
             when aut_api_const_pkg.AUTH_REASON_DUE_TO_COMPLT_FLAG
                 then (select a.is_completed from aut_auth a where a.id = op.id)
                 else op.status_reason                                           
         end
       , op.oper_reason
       , op.status
       , op.status_reason
       , op.is_reversal
       , op.merchant_number
       , op.mcc
       , op.merchant_name
       , op.merchant_street
       , op.merchant_city
       , op.merchant_region
       , op.merchant_country
       , op.merchant_postcode
       , case op.terminal_type
             when acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS
                 then acq_api_const_pkg.TERMINAL_TYPE_POS
                 else op.terminal_type
         end
       , op.terminal_number
       , mr.risk_indicator
       , op.sttl_date
       , op.acq_sttl_date
       , op.match_id
       , op.match_status
       , op.clearing_sequence_num
       , op.clearing_sequence_count
       , op.payment_order_id
       , au.resp_code
       , au.proc_type
       , au.proc_mode
       , au.is_advice
       , au.is_repeat
       , au.bin_amount
       , au.bin_currency
       , au.bin_cnvt_rate
       , au.network_amount
       , au.network_currency
       , au.network_cnvt_date
       , au.network_cnvt_rate
       , au.account_cnvt_rate
       , au.addr_verif_result
       , au.acq_resp_code
       , au.acq_device_proc_result
       , au.cat_level
       , au.card_data_input_cap
       , au.crdh_auth_cap
       , au.card_capture_cap
       , au.terminal_operating_env
       , au.crdh_presence
       , au.card_presence
       , au.card_data_input_mode
       , au.crdh_auth_method
       , au.crdh_auth_entity
       , au.card_data_output_cap
       , au.terminal_output_cap
       , au.pin_capture_cap
       , au.pin_presence
       , au.cvv2_presence
       , au.cvc_indicator
       , au.pos_entry_mode
       , au.pos_cond_code
       , au.emv_data
       , au.atc
       , au.tvr
       , au.cvr
       , au.addl_data
       , au.service_code
       , au.device_date
       , au.cvv2_result 
       , au.certificate_method
       , au.certificate_type
       , au.merchant_certif
       , au.cardholder_certif
       , au.ucaf_indicator
       , au.is_early_emv
       , au.is_completed
       , au.amounts
       , au.system_trace_audit_number
       , au.transaction_id
       , au.external_auth_id
       , au.external_orig_id
       , au.agent_unique_id
       , au.native_resp_code
       , au.auth_purpose_id
    from opr_operation op 
         left join rcn_cbs_msg rcn on rcn.oper_id = op.id  
         left join aut_auth au on au.id = op.id
       , acc_macros   mc
         left join acc_entry cr on
             cr.balance_impact = com_api_const_pkg.CREDIT
         and cr.macros_id = mc.id
         left join acc_entry db on
             db.balance_impact = com_api_const_pkg.DEBIT
         and db.macros_id = mc.id
       , acq_merchant mr
       
   where mc.object_id = op.id
     and mc.entity_type =  opr_api_const_pkg.ENTITY_TYPE_OPERATION
     and mr.merchant_number = op.merchant_number
     and mr.inst_id = l_inst_id
     and nvl(db.transaction_id, cr.transaction_id) = nvl(cr.transaction_id, db.transaction_id)
     and trunc(decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, nvl(db.posting_date, cr.posting_date)
                                 , com_api_const_pkg.DATE_PURPOSE_OPERATION,  op.oper_date
                                 , com_api_const_pkg.DATE_PURPOSE_SETTLEMENT, op.sttl_date
                                 , com_api_const_pkg.DATE_PURPOSE_MACROS,     mc.posting_date
                                 , com_api_const_pkg.DATE_PURPOSE_UNHOLD,     op.unhold_date 
                                 , com_api_const_pkg.DATE_PURPOSE_BANK,       nvl(db.sttl_date, cr.sttl_date)
                                 , com_api_const_pkg.DATE_PURPOSE_HOST,       op.host_date
                                 , null)) 
         between trunc(i_start_date) and trunc(i_end_date)
     and (i_array_balance_type_id is null 
          or exists (select 1 from com_array_element 
                      where array_id = i_array_balance_type_id 
                        and element_value in (db.balance_type, cr.balance_type)
                     )
         )
     and (i_array_trans_type_id is null 
          or exists (select 1 from com_array_element 
                      where array_id = i_array_trans_type_id 
                        and element_value in (db.transaction_type, cr.transaction_type)
                     )
         )
     and (i_array_settl_type_id is null 
          or exists (select 1 from com_array_element 
                      where array_id = i_array_settl_type_id 
                        and element_value = op.sttl_type
                     )
         )
     and (i_array_operations_type_id is null 
          or exists (select 1 from com_array_element 
                      where array_id = i_array_operations_type_id 
                        and element_value = op.oper_type
                     )
         );
exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished failed with params - inst_id '||i_inst_id||' date_type '||i_date_type
           ||' start_date '||i_start_date||' end_date '||i_end_date||' balance_type '||i_array_balance_type_id
           ||' trans_type '||i_array_trans_type_id||' settl_type '||i_array_settl_type_id||' operations_type_id '||i_array_operations_type_id
        );
        raise;
end get_operations;

procedure get_opr_clearing_data(
    i_oper_id      in  com_api_type_pkg.t_long_id
  , o_ipm_data    out  t_ipm_data_rec
  , o_baseii_data out  t_baseii_data_rec
) is
begin
    begin
        select fn.is_incoming
             , fn.is_reversal
             , fn.is_rejected
             , fn.impact
             , fn.mti
             , fn.de024
             , fn.de002
             , fn.de003_1
             , fn.de003_2
             , fn.de003_3
             , fn.de004
             , fn.de005
             , fn.de006
             , fn.de009
             , fn.de010
             , fn.de012
             , fn.de014
             , fn.de022_1
             , fn.de022_2
             , fn.de022_3
             , fn.de022_4
             , fn.de022_5
             , fn.de022_6
             , fn.de022_7
             , fn.de022_8
             , fn.de022_9
             , fn.de022_10
             , fn.de022_11
             , fn.de022_12
             , fn.de023
             , fn.de025
             , fn.de026
             , fn.de030_1
             , fn.de030_2
             , fn.de031
             , fn.de032
             , fn.de033
             , fn.de037
             , fn.de038
             , fn.de040
             , fn.de041
             , fn.de042
             , fn.de043_1
             , fn.de043_2
             , fn.de043_3
             , fn.de043_4
             , fn.de043_5
             , fn.de043_6
             , fn.de049
             , fn.de050
             , fn.de051
             , fn.de054
             , fn.de055
             , fn.de063
             , fn.de071
             , fn.de072
             , fn.de073
             , fn.de093
             , fn.de094
             , fn.de095
             , fn.de100
             , fn.de111
             , fn.p0002
             , fn.p0023
             , fn.p0025_1
             , fn.p0025_2
             , fn.p0043
             , fn.p0052
             , fn.p0137
             , fn.p0148
             , fn.p0146
             , fn.p0146_net
             , fn.p0147
             , fn.p0149_1
             , fn.p0149_2
             , fn.p0158_1
             , fn.p0158_2
             , fn.p0158_3
             , fn.p0158_4
             , fn.p0158_5
             , fn.p0158_6
             , fn.p0158_7
             , fn.p0158_8
             , fn.p0158_9
             , fn.p0158_10
             , fn.p0159_1
             , fn.p0159_2
             , fn.p0159_3
             , fn.p0159_4
             , fn.p0159_5
             , fn.p0159_6
             , fn.p0159_7
             , fn.p0159_8
             , fn.p0159_9
             , fn.p0165
             , fn.p0176
             , fn.p0208_1
             , fn.p0208_2
             , fn.p0209
             , fn.p0228
             , fn.p0230
             , fn.p0241
             , fn.p0243
             , fn.p0244
             , fn.p0260
             , fn.p0261
             , fn.p0262
             , fn.p0264
             , fn.p0265
             , fn.p0266
             , fn.p0267
             , fn.p0268_1
             , fn.p0268_2
             , fn.p0375
             , fn.emv_9f26
             , fn.emv_9f02
             , fn.emv_9f27
             , fn.emv_9f10
             , fn.emv_9f36
             , fn.emv_95
             , fn.emv_82
             , fn.emv_9a
             , fn.emv_9c
             , fn.emv_9f37
             , fn.emv_5f2a
             , fn.emv_9f33
             , fn.emv_9f34
             , fn.emv_9f1a
             , fn.emv_9f35
             , fn.emv_9f53
             , fn.emv_84
             , fn.emv_9f09
             , fn.emv_9f03
             , fn.emv_9f1e
             , fn.emv_9f41
             , fn.p0042
             , fn.p0158_11
             , fn.p0158_12
             , fn.p0158_13
             , fn.p0158_14
             , fn.p0198
             , fn.p0200_1
             , fn.p0200_2
             , fn.p0210_1
             , fn.p0210_2
             , sp.p0302
             , sp.p0368
          into o_ipm_data
          from mcw_fin fn
     full join mcw_spd sp
            on fn.id = sp.id
         where i_oper_id in (fn.id, sp.id);
    exception when no_data_found then
        null; 
    end;

    begin
        select fn.is_reversal
             , fn.is_incoming
             , fn.is_returned
             , fn.is_invalid
             , fn.trans_code
             , fn.trans_code_qualifier
             , fn.card_mask
             , fn.oper_amount
             , fn.oper_currency
             , fn.oper_date
             , fn.sttl_amount
             , fn.sttl_currency
             , fn.network_amount
             , fn.network_currency
             , fn.floor_limit_ind
             , fn.exept_file_ind
             , fn.pcas_ind
             , fn.arn
             , fn.acquirer_bin
             , fn.acq_business_id
             , fn.merchant_name
             , fn.merchant_city
             , fn.merchant_country
             , fn.merchant_postal_code
             , fn.merchant_region
             , fn.merchant_street
             , fn.mcc
             , fn.req_pay_service
             , fn.usage_code
             , fn.reason_code
             , fn.settlement_flag
             , fn.auth_char_ind
             , fn.auth_code
             , fn.pos_terminal_cap
             , fn.inter_fee_ind
             , fn.crdh_id_method
             , fn.collect_only_flag
             , fn.pos_entry_mode
             , fn.central_proc_date
             , fn.reimburst_attr
             , fn.iss_workst_bin
             , fn.acq_workst_bin
             , fn.chargeback_ref_num
             , fn.docum_ind
             , fn.member_msg_text
             , fn.spec_cond_ind
             , fn.fee_program_ind
             , fn.issuer_charge
             , fn.merchant_number
             , fn.terminal_number
             , fn.national_reimb_fee
             , fn.electr_comm_ind
             , fn.spec_chargeback_ind
             , fn.interface_trace_num
             , fn.unatt_accept_term_ind
             , fn.prepaid_card_ind
             , fn.service_development
             , fn.avs_resp_code
             , fn.auth_source_code
             , fn.purch_id_format
             , fn.account_selection
             , fn.installment_pay_count
             , fn.purch_id
             , fn.cashback
             , fn.chip_cond_code
             , fn.pos_environment
             , fn.transaction_type
             , fn.card_seq_number
             , fn.terminal_profile
             , fn.unpredict_number
             , fn.appl_trans_counter
             , fn.appl_interch_profile
             , fn.cryptogram
             , fn.term_verif_result
             , fn.cryptogram_amount
             , fn.card_verif_result
             , fn.issuer_appl_data
             , fn.issuer_script_result
             , fn.card_expir_date
             , fn.cryptogram_version
             , fn.cvv2_result_code
             , fn.auth_resp_code
             , fn.cryptogram_info_data
             , fn.transaction_id
             , fn.merchant_verif_value
             , fn.proc_bin
             , fn.chargeback_reason_code
             , fn.destination_channel
             , fn.source_channel
             , fn.acq_inst_bin
             , fn.spend_qualified_ind
             , fn.service_code
             , fn.product_id
             , vs.sttl_service
             , vs.sre_id
             , vs.up_sre_id
             , vs.jurisdict
             , vs.routing
             , vs.src_region
             , vs.dst_region
             , vs.src_country
             , vs.dst_country
             , vs.bus_tr_type
             , vs.first_count
          into o_baseii_data
          from vis_fin_message fn  
     left join vis_vss4 vs
            on vs.file_id       = fn.file_id
           and vs.record_number = fn.record_number
         where fn.id            = i_oper_id;
    exception when no_data_found then
        null;
    end;
end get_opr_clearing_data;

procedure get_opr_participants(
    i_oper_id              in  com_api_type_pkg.t_long_id
  , i_participant_type     in  com_api_type_pkg.t_dict_value default null
  , o_ref_cursor          out  com_api_type_pkg.t_ref_cur
) is
begin

    open o_ref_cursor for 
  select pt.participant_type
       , pt.client_id_type
       , pt.client_id_value
       , cr.card_number
       , pt.card_id
       , pt.card_instance_id
       , pt.card_seq_number
       , pt.card_expir_date
       , pt.card_country
       , pt.inst_id
       , pt.network_id
       , pt.auth_code
       , pt.account_number
       , pt.account_amount
       , pt.account_currency
    from opr_operation op
       , opr_participant pt
    left join opr_card cr
           on cr.oper_id = pt.oper_id
   where op.id = pt.oper_id
     and op.id = i_oper_id
     and pt.participant_type = nvl(i_participant_type, pt.participant_type);

end get_opr_participants;

procedure get_opr_additional_amount(
    i_oper_id              in  com_api_type_pkg.t_long_id
  , i_amount_type          in  com_api_type_pkg.t_dict_value default null
  , o_ref_cursor          out  com_api_type_pkg.t_ref_cur
) is
begin

      open o_ref_cursor for
    select am.amount
         , am.currency
         , am.amount_type
      from opr_additional_amount am
     where am.oper_id = i_oper_id
       and am.amount is not null
       and am.amount_type = nvl(i_amount_type, am.amount_type);

end get_opr_additional_amount;

end opr_api_external_pkg;
/
