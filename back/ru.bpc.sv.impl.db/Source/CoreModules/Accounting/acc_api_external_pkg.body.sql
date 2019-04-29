create or replace package body acc_api_external_pkg as
/**********************************************************
 * API for external GUI <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 17.02.2017 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: GUI_API_EXTERNAL_PKG
 * @headcom
 **********************************************************/
procedure get_transactions_data(
    i_inst_id                  in  com_api_type_pkg.t_inst_id
  , i_date_type                in  com_api_type_pkg.t_dict_value
  , i_start_date               in  date                                default null
  , i_end_date                 in  date                                default null
  , i_balance_type             in  com_api_type_pkg.t_dict_value       default null
  , i_account_number           in  com_api_type_pkg.t_account_number   default null
  , i_fees                     in  com_api_type_pkg.t_boolean          default null
  , i_gl_accounts              in  com_api_type_pkg.t_boolean          default null
  , i_load_reversals           in  com_api_type_pkg.t_boolean          default null
  , i_object_tab               in  com_api_type_pkg.t_object_tab
  , i_array_balance_type_id    in  com_api_type_pkg.t_medium_id        default null
  , i_array_trans_type_id      in  com_api_type_pkg.t_medium_id        default null
  , i_array_settl_type_id      in  com_api_type_pkg.t_medium_id        default null
  , i_array_operations_type_id in  com_api_type_pkg.t_medium_id        default null
  , i_mask_error               in  com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_row_count               out  com_api_type_pkg.t_long_id
  , o_ref_cursor              out  com_api_type_pkg.t_ref_cur
) is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_transactions_data: ';
    OBJECT_TAB_COUNT_MAX   constant com_api_type_pkg.t_short_id := 5;
    
    l_cursor_count     com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column    com_api_type_pkg.t_text := 'select o.id as oper_id'
                                               ||      ', o.oper_type'
                                               ||      ', o.oper_reason'
                                               ||      ', o.is_reversal'
                                               ||      ', o.msg_type'
                                               ||      ', o.sttl_type'
                                               ||      ', o.oper_amount'
                                               ||      ', o.oper_currency'
                                               ||      ', o.oper_date'
                                               ||      ', o.host_date'
                                               ||      ', o.unhold_date'
                                               ||      ', o.sttl_date as oper_sttl_date'
                                               ||      ', am.id as macros_id'
                                               ||      ', am.account_id as macros_account_id'
                                               ||      ', am.amount as macros_amount'
                                               ||      ', am.currency as macros_currency'
                                               ||      ', am.amount_purpose as macros_amount_purpose'
                                               ||      ', am.posting_date as macros_posting_date'
                                               ||      ', am.conversion_rate as macros_currency_rate'
                                               ||      ', am.conversion_rate_id as macros_currency_rate_id'
                                               ||      ', am.rate_type as macros_rate_type'
                                               ||      ', nvl(edeb.transaction_id, ecred.transaction_id) as transaction_id'
                                               ||      ', nvl(edeb.transaction_type, ecred.transaction_type) as transaction_type'
                                               ||      ', edeb.entry_id as debt_entry_id'
                                               ||      ', edeb.account_id as debt_account_id'
                                               ||      ', adeb.account_number as debt_account_number'
                                               ||      ', adeb.currency as debt_account_currency'
                                               ||      ', bdeb.currency as debt_balance_currency'
                                               ||      ', edeb.amount as debt_amount'
                                               ||      ', edeb.currency as debt_currency'
                                               ||      ', edeb.balance_type as debt_balance_type'
                                               ||      ', edeb.balance_impact as debt_balance_impact'
                                               ||      ', edeb.balance as debt_balance'
                                               ||      ', edeb.posting_date as debt_posting_date'
                                               ||      ', edeb.sttl_date as debt_sttl_date'
                                               ||      ', ecred.entry_id as credit_entry_id'
                                               ||      ', ecred.account_id as credit_account_id'
                                               ||      ', acred.account_number as credit_account_number'
                                               ||      ', acred.currency as credit_account_currency'
                                               ||      ', bcred.currency as credit_balance_currency'
                                               ||      ', ecred.amount as credit_amount'
                                               ||      ', ecred.currency as credit_currency'
                                               ||      ', ecred.balance_type as credit_balance_type'
                                               ||      ', ecred.balance_impact as credit_balance_impact'
                                               ||      ', ecred.balance as credit_balance'
                                               ||      ', ecred.posting_date as credit_posting_date'
                                               ||      ', ecred.sttl_date as credit_sttl_date '
    ;
    l_cursor_tbl       com_api_type_pkg.t_text := '  from ('
                                               ||         'select ae.macros_id'
                                               ||              ', ae.bunch_id'
                                               ||              ', ae.transaction_id'
                                               ||              ', ae.transaction_type'
                                               ||              ', ae.id as entry_id'
                                               ||              ', ae.split_hash'
                                               ||              ', ae.posting_date'
                                               ||              ', ae.sttl_date'
                                               ||              ', ae.account_id'
                                               ||              ', ae.amount'
                                               ||              ', ae.currency'
                                               ||              ', ae.balance_type'
                                               ||              ', ae.balance_impact'
                                               ||              ', ae.balance '
                                               ||           'from acc_entry ae '
                                               ||          'where ae.balance_impact = ' || com_api_const_pkg.DEBIT
                                               ||        ') edeb '
                                               ||   'full outer '
                                               ||   'join ('
                                               ||         'select ae.macros_id'
                                               ||              ', ae.bunch_id'
                                               ||              ', ae.transaction_id'
                                               ||              ', ae.transaction_type'
                                               ||              ', ae.id as entry_id'
                                               ||              ', ae.split_hash'
                                               ||              ', ae.posting_date'
                                               ||              ', ae.sttl_date'
                                               ||              ', ae.account_id'
                                               ||              ', ae.amount'
                                               ||              ', ae.currency'
                                               ||              ', ae.balance_type'
                                               ||              ', ae.balance_impact'
                                               ||              ', ae.balance '
                                               ||           'from acc_entry ae '
                                               ||          'where ae.balance_impact = ' || com_api_const_pkg.CREDIT
                                               ||        ') ecred '
                                               ||     'on edeb.transaction_id = ecred.transaction_id '
                                               ||   'left outer '
                                               ||   'join acc_account adeb '
                                               ||     'on edeb.account_id = adeb.id '
                                               ||   'left outer '
                                               ||   'join acc_balance bdeb '
                                               ||     'on edeb.account_id = bdeb.account_id and edeb.balance_type = bdeb.balance_type '
                                               ||   'left outer '
                                               ||   'join acc_account acred '
                                               ||     'on ecred.account_id = acred.id '
                                               ||   'left outer '
                                               ||   'join acc_balance bcred '
                                               ||     'on ecred.account_id = bcred.account_id and ecred.balance_type = bcred.balance_type '
                                               ||   'left outer '
                                               ||   'join acc_macros am '
                                               ||     'on edeb.macros_id = am.id or ecred.macros_id = am.id '
                                               ||  'inner join '
                                               ||        'opr_operation o '
                                               ||     'on am.entity_type = ''' || opr_api_const_pkg.ENTITY_TYPE_OPERATION || ''' and am.object_id = o.id '
    ;
    l_cursor_order     com_api_type_pkg.t_full_desc := 
                                                    'order by '
                                               ||       'decode(:date_type,'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_PROCESSING || ''', nvl(edeb.posting_date, ecred.posting_date),'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_OPERATION  || ''', o.oper_date,'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_SETTLEMENT || ''', o.sttl_date,'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_MACROS     || ''', am.posting_date,'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_UNHOLD     || ''', o.unhold_date,'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_BANK       || ''', nvl(edeb.sttl_date, ecred.sttl_date),'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_HOST       || ''', o.host_date,'
                                               ||                                                                'null'
                                               ||      ')'
                                               ||     ', nvl(edeb.transaction_id, ecred.transaction_id) '
                                               ||     ', nvl(edeb.entry_id, ecred.entry_id) '
    ;
    l_cursor_where     com_api_type_pkg.t_text := 'where '
                                               ||       'decode(:date_type,'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_PROCESSING || ''', nvl(edeb.posting_date, ecred.posting_date),'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_OPERATION  || ''', o.oper_date,'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_SETTLEMENT || ''', o.sttl_date,'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_MACROS     || ''', am.posting_date,'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_UNHOLD     || ''', o.unhold_date,'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_BANK       || ''', nvl(edeb.sttl_date, ecred.sttl_date),'
                                               ||       '''' || com_api_const_pkg.DATE_PURPOSE_HOST       || ''', o.host_date,'
                                               ||                                                                'null'
                                               ||       ') between :start_date and :end_date '
    ;
    l_cursor_str       com_api_type_pkg.t_sql_statement;
    
    l_account          acc_api_type_pkg.t_account_rec;
    
begin
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - inst_id [#1] date_type [#2] start_date [#3] end_date [#4] fees [#5] gl_accounts [#6' 
               || '], balance_type [' || i_balance_type
               || '], account_number [' || i_account_number
               || '], load_reversals [' || i_load_reversals
               || '], i_object_tab.count [' || i_object_tab.count
               || '], array_balance_type_id [' || i_array_balance_type_id
               || '], array_trans_type_id [' || i_array_trans_type_id
               || '], array_settl_type_id [' || i_array_settl_type_id
               || '], array_operations_type_id [' || i_array_operations_type_id
               || '], mask_error [' || i_mask_error
               || ']'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_date_type
      , i_env_param3 => i_start_date
      , i_env_param4 => i_end_date
      , i_env_param5 => i_fees
      , i_env_param6 => i_gl_accounts
    );
    
    if i_inst_id is not null and i_inst_id <> ost_api_const_pkg.DEFAULT_INST then
        l_cursor_where := l_cursor_where || 'and ' || i_inst_id || ' in (adeb.inst_id, acred.inst_id) ';
    end if;
    
    if i_balance_type is not null then
        l_cursor_where := l_cursor_where || 'and ''' || i_balance_type || ''' in (edeb.balance_type, ecred.balance_type) ';
    end if;
    
    if i_array_balance_type_id is not null then
        l_cursor_where := l_cursor_where || 'and exists(select 1 from com_array_element where array_id = ' || i_array_balance_type_id || ' and element_value in (edeb.balance_type, ecred.balance_type)) '
        ;
    end if;
    
    if i_account_number is not null then
        l_account := acc_api_account_pkg.get_account(
                         i_account_id     => null
                       , i_account_number => i_account_number
                       , i_mask_error     => com_api_const_pkg.FALSE
                     );
        l_cursor_where := l_cursor_where || 'and ' || l_account.account_id || ' in (adeb.id, acred.id) ';
    end if;
    
    if i_fees in (com_api_const_pkg.FALSE, com_api_const_pkg.TRUE) then
        l_cursor_where := l_cursor_where
                       || 'and '
                       ||      case when i_fees = com_api_const_pkg.FALSE then 'not ' else null end
                       ||     '(lower(com_api_dictionary_pkg.get_article_text('
                       ||                'i_article  => o.oper_type'
                       ||              ', i_lang     => ''' || com_api_const_pkg.LANGUAGE_ENGLISH || ''''
                       ||            ')'
                       ||      ') like ''%fee%'' '
                       ||      'or nvl(o.oper_reason, ''ABSENT'') like ''FETP%'' '
                       ||      'or nvl(am.amount_purpose, ''ABSENT'') like ''FETP%'''
                       ||     ') '
        ;
    end if;
    
    if i_gl_accounts in (com_api_const_pkg.FALSE, com_api_const_pkg.TRUE) then
        l_cursor_where := l_cursor_where
                       || 'and ' 
                       ||      case when i_gl_accounts = com_api_const_pkg.FALSE then 'not ' else null end
                       ||     'exists(select 1 from acc_gl_account_mvw mv where mv.id in (adeb.id, acred.id)) '
        ;
    end if;
    
    if i_object_tab.count > 0 then
        for i in i_object_tab.first .. i_object_tab.last loop
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'Create where clause on object_tab count [#1] level_type [#2]'
                  , i_env_param1 => i
                  , i_env_param2 => i_object_tab(i).level_type
                );
            if i_object_tab(i).level_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'Create where clause on object_tab count [#1] entity_type [#2] object_id.count [#3]'
                  , i_env_param1 => i
                  , i_env_param2 => i_object_tab(i).entity_type
                  , i_env_param3 => case when i_object_tab(i).object_id.exists(1) then i_object_tab(i).object_id.count else 0 end
                );
                if i_object_tab(i).entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
                    l_cursor_where := l_cursor_where
                                   || 'and exists(select 1 from acc_account_object ao where ao.object_id in (select column_value from table(:tab' || i || ')) and ao.entity_type = ''' || i_object_tab(i).entity_type || ''' and ao.account_id in (adeb.id, acred.id)) '
                    ;
                elsif i_object_tab(i).entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                    l_cursor_where := l_cursor_where
                                   || 'and exists(select 1 from acc_account_object ao where ao.object_id in (select column_value from table(:tab' || i || ')) and ao.entity_type = ''' || i_object_tab(i).entity_type || ''' and ao.account_id in (adeb.id, acred.id)) '
                    ;
                elsif i_object_tab(i).entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
                    l_cursor_where := l_cursor_where
                                   || 'and exists(select 1 from acc_account_object ao where ao.object_id in (select column_value from table(:tab' || i || ')) and ao.entity_type = ''' || i_object_tab(i).entity_type || ''' and ao.account_id in (adeb.id, acred.id)) '
                    ;
                elsif i_object_tab(i).entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
                    l_cursor_where := l_cursor_where
                                   || 'and exists(select 1 from acc_account_object ao where ao.object_id in (select column_value from table(:tab' || i || ')) and ao.entity_type = ''' || i_object_tab(i).entity_type || ''' and ao.account_id in (adeb.id, acred.id)) '
                    ;
                elsif i_object_tab(i).entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
                    l_cursor_where := l_cursor_where
                                   || 'and exists(select 1 from prd_customer pc where pc.id in (adeb.customer_id, acred.customer_id) and pc.ext_entity_type = ''' || i_object_tab(i).entity_type || ''' and pc.ext_object_id in (select column_value from table(:tab' || i || '))) '
                    ;
                elsif i_object_tab(i).entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT then
                    l_cursor_where := l_cursor_where
                                   || 'and exists(select 1 from prd_customer pc where pc.id in (adeb.customer_id, acred.customer_id) and pc.ext_entity_type = ''' || i_object_tab(i).entity_type || ''' and pc.ext_object_id in (select column_value from table(:tab' || i || '))) '
                    ;
                elsif i_object_tab(i).entity_type = pmo_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER then
                    l_cursor_where := l_cursor_where
                                   || 'and exists(select 1 from prd_customer pc where pc.id in (adeb.customer_id, acred.customer_id) and pc.ext_entity_type = ''' || i_object_tab(i).entity_type || ''' and pc.ext_object_id in (select column_value from table(:tab' || i || '))) '
                    ;
                else
                    com_api_error_pkg.raise_error(
                        i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
                      , i_env_param1 => i_object_tab(i).entity_type
                    );
                end if;
            elsif i_object_tab(i).level_type = acc_api_const_pkg.ENTITY_TYPE_ENTRY then
                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'Create where clause on object_tab count [#1] entity_type [#2] object_id.count [#3]'
                  , i_env_param1 => i
                  , i_env_param2 => i_object_tab(i).entity_type
                  , i_env_param3 => case when i_object_tab(i).object_id.exists(1) then i_object_tab(i).object_id.count else 0 end
                );
                if i_object_tab(i).entity_type = acc_api_const_pkg.ENTITY_TYPE_ENTRY then
                    l_cursor_where := l_cursor_where
                                   || 'and exists(select 1 from table(:tab' || i || ') where column_value in (edeb.entry_id, ecred.entry_id)  ) '
                    ;
                else
                    com_api_error_pkg.raise_error(
                        i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
                      , i_env_param1 => i_object_tab(i).entity_type
                    );
                end if;
            elsif i_object_tab(i).level_type = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION then
                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || 'Create where clause on object_tab count [#1] entity_type [#2] object_id.count [#3]'
                  , i_env_param1 => i
                  , i_env_param2 => i_object_tab(i).entity_type
                  , i_env_param3 => case when i_object_tab(i).object_id.exists(1) then i_object_tab(i).object_id.count else 0 end
                );
                if i_object_tab(i).entity_type = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION then
                    l_cursor_where := l_cursor_where
                                   || 'and exists(select 1 from table(:tab' || i || ') where column_value = nvl(edeb.transaction_id, ecred.transaction_id) ) '
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

    if i_load_reversals = com_api_const_pkg.FALSE then
        l_cursor_where := l_cursor_where 
                       || 'and '
                       || '('
                       ||  'o.is_reversal = ' || com_api_const_pkg.TRUE || ' '
                       ||  'and not exists (select 1 '
                       ||                    'from opr_operation o2'
                       ||                       ', acc_macros m2'
                       ||                       ', acc_entry f2 '
                       ||                   'where o2.id          = o.original_id '
                       ||                   'and m2.object_id     = o2.id '
                       ||                   'and m2.entity_type   = ''' || opr_api_const_pkg.ENTITY_TYPE_OPERATION || ''' '
                       ||                   'and f2.macros_id     = m2.id '
                       ||                   'and f2.status       != ''' || acc_api_const_pkg.ENTRY_STATUS_CANCELED || ''' '
                       ||                   'and decode(''' || i_date_type || ''','
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_PROCESSING || ''', f2.posting_date,'
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_OPERATION  || ''', o2.oper_date,'
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_SETTLEMENT || ''', o2.sttl_date,'
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_MACROS     || ''', m2.posting_date,'
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_UNHOLD     || ''', o2.unhold_date,'
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_BANK       || ''', f2.sttl_date,'
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_HOST       || ''', o2.host_date,'
                       ||                                                                           ' null'
                       ||                   ') between to_date(''' || to_char(i_start_date, com_api_const_pkg.DATE_FORMAT) || ''', ''' || com_api_const_pkg.DATE_FORMAT || ''') and to_date(''' || to_char(i_end_date, com_api_const_pkg.DATE_FORMAT) || ''', ''' || com_api_const_pkg.DATE_FORMAT || ''') '
                       ||                   'and o2.oper_amount = o.oper_amount'
                       ||                 ') '
                       ||  'or '
                       ||  'o.is_reversal = ' || com_api_const_pkg.FALSE || ' '
                       ||  'and not exists (select 1 '
                       ||                    'from opr_operation o2'
                       ||                       ', acc_macros m2'
                       ||                       ', acc_entry f2 '
                       ||                   'where o2.original_id = o.id '
                       ||                   'and m2.object_id     = o2.id '
                       ||                   'and m2.entity_type   = ''' || opr_api_const_pkg.ENTITY_TYPE_OPERATION || ''' '
                       ||                   'and f2.macros_id     = m2.id '
                       ||                   'and f2.status       != ''' || acc_api_const_pkg.ENTRY_STATUS_CANCELED || ''' '
                       ||                   'and decode(''' || i_date_type || ''','
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_PROCESSING || ''', f2.posting_date,'
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_OPERATION  || ''', o2.oper_date,'
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_SETTLEMENT || ''', o2.sttl_date,'
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_MACROS     || ''', m2.posting_date,'
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_UNHOLD     || ''', o2.unhold_date,'
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_BANK       || ''', f2.sttl_date,'
                       ||                   ''''            || com_api_const_pkg.DATE_PURPOSE_HOST       || ''', o2.host_date,'
                       ||                                                                           ' null'
                       ||                   ') between to_date(''' || to_char(i_start_date, com_api_const_pkg.DATE_FORMAT) || ''', ''' || com_api_const_pkg.DATE_FORMAT || ''') and to_date(''' || to_char(i_end_date, com_api_const_pkg.DATE_FORMAT) || ''', ''' || com_api_const_pkg.DATE_FORMAT || ''') '
                       ||                   'and o2.oper_amount = o.oper_amount'
                       ||                 ')'
                       || ') '
        ;
    end if;
    
    if i_array_trans_type_id is not null then
        l_cursor_where := l_cursor_where || 'and exists(select 1 from com_array_element where array_id = ' || i_array_trans_type_id || ' and element_value in (edeb.transaction_type, ecred.transaction_type)) '
        ;
    end if;
    
    if i_array_settl_type_id is not null then
        l_cursor_where := l_cursor_where || 'and exists(select 1 from com_array_element where array_id = ' || i_array_settl_type_id || ' and element_value = o.sttl_type) '
        ;
    end if;
    
    if i_array_operations_type_id is not null then
        l_cursor_where := l_cursor_where || 'and exists(select 1 from com_array_element where array_id = ' || i_array_operations_type_id || ' and element_value = o.oper_type) '
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
                       in i_date_type,
                       in i_start_date,
                       in i_end_date
                       
        ;
    elsif i_object_tab.count = 1 then
        execute immediate l_cursor_str
                     into o_row_count
                    using 
                       in i_date_type,
                       in i_start_date,
                       in i_end_date,
                       in i_object_tab(1).object_id
        ;
    elsif i_object_tab.count = 2 then
        execute immediate l_cursor_str
                     into o_row_count
                    using 
                       in i_date_type,
                       in i_start_date,
                       in i_end_date,
                       in i_object_tab(1).object_id,
                       in i_object_tab(2).object_id
        ;
    elsif i_object_tab.count = 3 then
        execute immediate l_cursor_str
                     into o_row_count
                    using 
                       in i_date_type,
                       in i_start_date,
                       in i_end_date,
                       in i_object_tab(1).object_id,
                       in i_object_tab(2).object_id,
                       in i_object_tab(3).object_id
        ;
    elsif i_object_tab.count = 4 then
        execute immediate l_cursor_str
                     into o_row_count
                    using 
                       in i_date_type,
                       in i_start_date,
                       in i_end_date,
                       in i_object_tab(1).object_id,
                       in i_object_tab(2).object_id,
                       in i_object_tab(3).object_id,
                       in i_object_tab(4).object_id
        ;
    elsif i_object_tab.count = 5 then
        execute immediate l_cursor_str
                     into o_row_count
                    using 
                       in i_date_type,
                       in i_start_date,
                       in i_end_date,
                       in i_object_tab(1).object_id,
                       in i_object_tab(2).object_id,
                       in i_object_tab(3).object_id,
                       in i_object_tab(4).object_id,
                       in i_object_tab(5).object_id
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
              , i_env_param1  => acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'REQUESTED_DATA_NOT_FOUND'
              , i_env_param1 => acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
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
            using i_date_type
                , i_start_date
                , i_end_date
                , i_date_type
            ;
        elsif i_object_tab.count = 1 then
            open  o_ref_cursor 
              for l_cursor_str
            using i_date_type
                , i_start_date
                , i_end_date
                , i_object_tab(1).object_id
                , i_date_type
            ;
        elsif i_object_tab.count = 2 then
            open  o_ref_cursor 
              for l_cursor_str
            using i_date_type
                , i_start_date
                , i_end_date
                , i_object_tab(1).object_id
                , i_object_tab(2).object_id
                , i_date_type
            ;
        elsif i_object_tab.count = 3 then
            open  o_ref_cursor 
              for l_cursor_str
            using i_date_type
                , i_start_date
                , i_end_date
                , i_object_tab(1).object_id
                , i_object_tab(2).object_id
                , i_object_tab(3).object_id
                , i_date_type
            ;
        elsif i_object_tab.count = 4 then
            open  o_ref_cursor 
              for l_cursor_str
            using i_date_type
                , i_start_date
                , i_end_date
                , i_object_tab(1).object_id
                , i_object_tab(2).object_id
                , i_object_tab(3).object_id
                , i_object_tab(4).object_id
                , i_date_type
            ;
        elsif i_object_tab.count = 5 then
            open  o_ref_cursor 
              for l_cursor_str
            using i_date_type
                , i_start_date
                , i_end_date
                , i_object_tab(1).object_id
                , i_object_tab(2).object_id
                , i_object_tab(3).object_id
                , i_object_tab(4).object_id
                , i_object_tab(5).object_id
                , i_date_type
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
            i_text => LOG_PREFIX || 'Finished failed with params - inst_id [#1] date_type [#2] start_date [#3] end_date [#4] fees [#5] gl_accounts [#6' 
                   || '], balance_type [' || i_balance_type
                   || '], account_number [' || i_account_number
                   || '], load_reversals [' || i_load_reversals
                   || '], array_balance_type_id [' || i_array_balance_type_id
                   || '], array_trans_type_id [' || i_array_trans_type_id
                   || '], array_settl_type_id [' || i_array_settl_type_id
                   || '], mask_error [' || i_mask_error
                   || ']'
          , i_env_param1 => i_inst_id
          , i_env_param2 => i_date_type
          , i_env_param3 => i_start_date
          , i_env_param4 => i_end_date
          , i_env_param5 => i_fees
          , i_env_param6 => i_gl_accounts
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
        
end get_transactions_data;

procedure get_active_accounts_for_period(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_date_type             in     com_api_type_pkg.t_dict_value
  , i_start_date            in     date
  , i_end_date              in     date
  , i_account_id            in     com_api_type_pkg.t_account_id       default null
  , io_account_id_tab       in out num_tab_tpt
  , i_mask_error            in     com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_ref_cursor               out com_api_type_pkg.t_ref_cur
) is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_active_accounts_for_period: ';
    OBJECT_TAB_COUNT_MAX   constant com_api_type_pkg.t_short_id := 1;

    l_year_shift_date      date;
begin    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - inst_id [#1] date_type [#2] start_date [#3] end_date [#4] account_id [#5] mask_error [#6]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_date_type
      , i_env_param3 => i_start_date
      , i_env_param4 => i_end_date
      , i_env_param5 => i_account_id
      , i_env_param6 => i_mask_error
    );
    
    l_year_shift_date := add_months(i_end_date, -1 * com_api_const_pkg.YEAR_IN_MONTHS);
    
    if i_account_id is not null then
        open o_ref_cursor for
            select ac.account_id
                 , aa.account_number
                 , aa.split_hash
                 , ic.card_mask
                 , cu.customer_number
                 , io.id_type as national_id_type
                 , io.national_id
                 , pr.id as product_id
                 , pr.product_number
                 , crd_debt_pkg.get_count_debt_for_period(
                       i_account_id => aa.id
                     , i_split_hash => aa.split_hash
                     , i_start_date => l_year_shift_date
                     , i_end_date   => i_end_date
                   ) as loan_for_year
                 , crd_invoice_pkg.get_aging_period(
                       i_invoice_id => crd_invoice_pkg.get_last_invoice_id(
                                           i_account_id => aa.id
                                         , i_split_hash => aa.split_hash
                                         , i_mask_error => com_api_const_pkg.TRUE
                                         , i_eff_date   => i_end_date
                                       )
                     , i_mask_error => 1
                   ) as aging
              from (
                   select distinct(e.account_id)
                     from acc_entry e
                        , acc_macros m
                        , opr_operation o
                    where m.id          = e.macros_id
                      and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      and m.object_id   = o.id
                      and decode(i_date_type,
                                 com_api_const_pkg.DATE_PURPOSE_PROCESSING, e.posting_date,
                                 com_api_const_pkg.DATE_PURPOSE_OPERATION,  o.oper_date,
                                 com_api_const_pkg.DATE_PURPOSE_SETTLEMENT, o.sttl_date,
                                 com_api_const_pkg.DATE_PURPOSE_MACROS,     m.posting_date,
                                 com_api_const_pkg.DATE_PURPOSE_UNHOLD,     o.unhold_date,
                                 com_api_const_pkg.DATE_PURPOSE_BANK,       e.sttl_date,
                                 com_api_const_pkg.DATE_PURPOSE_HOST,       o.host_date,
                                 null
                          ) between i_start_date and i_end_date
                  ) ac
                , (select ao.account_id
                        , c.card_mask
                        , row_number() over(partition by ao.account_id order by decode(c.category, iss_api_const_pkg.CARD_CATEGORY_PRIMARY, 0, 1) asc, c.id desc) as rnk
                     from acc_account_object ao
                        , iss_card c
                    where ao.object_id   = c.id
                      and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                  ) ic
                , acc_account aa
                , prd_customer cu
                , prd_contract co
                , prd_product pr
                , (select io.entity_type
                        , io.object_id
                        , io.id_type
                        , max(io.id_series || io.id_number) keep(dense_rank first order by id desc) as national_id
                     from com_id_object io
                    where io.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                      and io.id_type     = com_api_const_pkg.ID_TYPE_NATIONAL_ID
                    group by io.entity_type, io.object_id, io.id_type
                  ) io
            where ac.account_id     = ic.account_id
              and ic.rnk(+)         = 1
              and aa.id             = ac.account_id
              and aa.inst_id        = decode(i_inst_id, ost_api_const_pkg.DEFAULT_INST, aa.inst_id, i_inst_id)
              and ic.account_id     = aa.id
              and cu.id             = aa.customer_id
              and co.id             = aa.contract_id
              and pr.id             = co.product_id
              and io.entity_type(+) = cu.entity_type
              and io.object_id(+)   = cu.object_id
              and aa.id             = i_account_id
            order by aa.id;

    elsif io_account_id_tab.count > 0 then
        open o_ref_cursor for
            select ac.account_id
                 , aa.account_number
                 , aa.split_hash
                 , ic.card_mask
                 , cu.customer_number
                 , io.id_type as national_id_type
                 , io.national_id
                 , pr.id as product_id
                 , pr.product_number
                 , crd_debt_pkg.get_count_debt_for_period(
                       i_account_id => aa.id
                     , i_split_hash => aa.split_hash
                     , i_start_date => l_year_shift_date
                     , i_end_date   => i_end_date
                   ) as loan_for_year
                 , crd_invoice_pkg.get_aging_period(
                       i_invoice_id => crd_invoice_pkg.get_last_invoice_id(
                                           i_account_id => aa.id
                                         , i_split_hash => aa.split_hash
                                         , i_mask_error => com_api_const_pkg.TRUE
                                         , i_eff_date   => i_end_date
                                       )
                     , i_mask_error => 1
                   ) as aging
              from (
                   select distinct(e.account_id)
                     from acc_entry e
                        , acc_macros m
                        , opr_operation o
                    where m.id          = e.macros_id
                      and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      and m.object_id   = o.id
                      and decode(i_date_type,
                                 com_api_const_pkg.DATE_PURPOSE_PROCESSING, e.posting_date,
                                 com_api_const_pkg.DATE_PURPOSE_OPERATION,  o.oper_date,
                                 com_api_const_pkg.DATE_PURPOSE_SETTLEMENT, o.sttl_date,
                                 com_api_const_pkg.DATE_PURPOSE_MACROS,     m.posting_date,
                                 com_api_const_pkg.DATE_PURPOSE_UNHOLD,     o.unhold_date,
                                 com_api_const_pkg.DATE_PURPOSE_BANK,       e.sttl_date,
                                 com_api_const_pkg.DATE_PURPOSE_HOST,       o.host_date,
                                 null
                          ) between i_start_date and i_end_date
                  ) ac
                , (select ao.account_id
                        , c.card_mask
                        , row_number() over(partition by ao.account_id order by decode(c.category, iss_api_const_pkg.CARD_CATEGORY_PRIMARY, 0, 1) asc, c.id desc) as rnk
                     from acc_account_object ao
                        , iss_card c
                    where ao.object_id   = c.id
                      and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                  ) ic
                , acc_account aa
                , prd_customer cu
                , prd_contract co
                , prd_product pr
                , (select io.entity_type
                        , io.object_id
                        , io.id_type
                        , max(io.id_series || io.id_number) keep(dense_rank first order by id desc) as national_id
                     from com_id_object io
                    where io.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                      and io.id_type     = com_api_const_pkg.ID_TYPE_NATIONAL_ID
                    group by io.entity_type, io.object_id, io.id_type
                  ) io
            where ac.account_id     = ic.account_id
              and ic.rnk(+)         = 1
              and aa.id             = ac.account_id
              and aa.inst_id        = decode(i_inst_id, ost_api_const_pkg.DEFAULT_INST, aa.inst_id, i_inst_id)
              and ic.account_id     = aa.id
              and cu.id             = aa.customer_id
              and co.id             = aa.contract_id
              and pr.id             = co.product_id
              and io.entity_type(+) = cu.entity_type
              and io.object_id(+)   = cu.object_id
              and exists (select 1 from table(cast(io_account_id_tab as num_tab_tpt)) where column_value = ac.account_id)
            order by aa.id;

    else
        com_api_error_pkg.raise_error(
            i_error      => 'NOT_SUPPORTED_QUANTITY_OBJECTS'
          , i_env_param1 => io_account_id_tab.count
          , i_env_param2 => OBJECT_TAB_COUNT_MAX
        );
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finished success!'
    );

end get_active_accounts_for_period;

procedure get_link_account_balances(
    i_date_type                    in  com_api_type_pkg.t_dict_value
  , i_start_date                   in  date
  , i_end_date                     in  date
  , i_account_id                   in  com_api_type_pkg.t_account_id
  , i_gl_accounts                  in  com_api_type_pkg.t_boolean          default null
  , i_array_link_account_numbers   in  com_api_type_pkg.t_medium_id        default null
  , i_mask_error                   in  com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_ref_cursor                  out  com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_link_account_balances: ';
begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - date_type [#1] start_date [#2] end_date [#3] account_id [#4] gl_accounts [#5] array_link_account_numbers [#6' 
               || '], mask_error [' || i_mask_error
               || ']'
      , i_env_param1 => i_date_type
      , i_env_param2 => i_start_date
      , i_env_param3 => i_end_date
      , i_env_param4 => i_account_id
      , i_env_param5 => i_gl_accounts
      , i_env_param6 => i_array_link_account_numbers
    );    
    
    open o_ref_cursor for
        select p.account_id
             , e.account_id as link_account_id
             , a.account_number as link_account_number
             , sum(e.balance_impact * e.amount) as balance_amount
         from opr_participant p
            , acc_macros m
            , acc_entry e
            , acc_account a
            , opr_operation o
        where p.account_id       = i_account_id
          and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
          and m.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
          and m.object_id        = p.oper_id
          and e.macros_id        = m.id
          and e.account_id      != p.account_id
          and e.balance_impact  in (com_api_const_pkg.DEBIT,com_api_const_pkg.CREDIT)
          and a.id               = e.account_id
          and o.id               = p.oper_id
          and decode(i_date_type
                   , com_api_const_pkg.DATE_PURPOSE_PROCESSING, e.posting_date
                   , com_api_const_pkg.DATE_PURPOSE_OPERATION,  o.oper_date
                   , com_api_const_pkg.DATE_PURPOSE_SETTLEMENT, o.sttl_date
                   , com_api_const_pkg.DATE_PURPOSE_MACROS,     m.posting_date
                   , com_api_const_pkg.DATE_PURPOSE_UNHOLD,     o.unhold_date
                   , com_api_const_pkg.DATE_PURPOSE_BANK,       e.sttl_date
                   , com_api_const_pkg.DATE_PURPOSE_HOST,       o.host_date
                   , null
               ) between i_start_date and i_end_date
          and (
                  i_gl_accounts is null
                  or (select max(i_gl_accounts) from acc_gl_account_mvw mv where mv.id = a.id) = i_gl_accounts
              )
          and (
                  i_array_link_account_numbers is null
                  or exists (
                                select 1
                                  from com_array_element t
                                 where t.array_id      = i_array_link_account_numbers
                                   and t.element_value = a.account_number
                            )
              )
        group by p.account_id, e.account_id, a.account_number
        order by a.account_number;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finished success!'
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished failed with params - date_type [#1] start_date [#2] end_date [#3] account_id [#4] gl_accounts [#5] array_link_account_numbers [#6' 
               || '], mask_error [' || i_mask_error
                   || ']'
          , i_env_param1 => i_date_type
          , i_env_param2 => i_start_date
          , i_env_param3 => i_end_date
          , i_env_param4 => i_account_id
          , i_env_param5 => i_gl_accounts
          , i_env_param6 => i_array_link_account_numbers
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
        
end get_link_account_balances;

procedure close_ref_cursor(
    i_ref_cursor         in    com_api_type_pkg.t_ref_cur
)
is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.close_ref_cursor: ';
    
begin
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Start'
    );
    
    if i_ref_cursor%isopen then
        close i_ref_cursor;
    end if;
    
exception
    when others then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        raise;

end close_ref_cursor;

procedure get_gl_account_numbers_data(
    i_inst_id    in     com_api_type_pkg.t_inst_id
  , i_start_date in     date                        default null
  , i_end_date   in     date                        default null
  , o_row_count     out com_api_type_pkg.t_long_id
  , o_gl_acc_tab    out acc_api_type_pkg.t_gl_account_numbers_ext_tab
) is
    l_inst_id    com_api_type_pkg.t_inst_id;
    l_start_date date;
    l_end_date   date;
    l_start_id   com_api_type_pkg.t_long_id;
    l_till_id    com_api_type_pkg.t_long_id;
begin
    l_inst_id    := nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);
    l_start_date := nvl(i_start_date, trunc(com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := nvl(i_end_date, l_start_date + 1 - com_api_const_pkg.ONE_SECOND);

    l_start_id   := com_api_id_pkg.get_from_id(i_date => l_start_date - 7);
    l_till_id    := com_api_id_pkg.get_till_id(i_date => l_end_date);

    select card_acc.account_number
         , card_acc.id         as card_account_id
         , card_acc.split_hash as card_split_hash
         , ic.card_mask        as card_mask
         , cu.customer_number
         , cu.entity_type      as customer_entity_type
         , cu.object_id        as customer_object_id
         , null                as national_id
         , gl_acc.account_number gl_account_number
         , m.macros_type_id
         , o.oper_type
         , o.oper_date
         , ec.posting_date
         , ec.balance_impact * ec.amount as amount
         , ec.currency
         , null as due_date
         , null as aging
         , gl_acc.account_type as gl_account_type
         , null as overdue_date
      bulk collect into o_gl_acc_tab
      from acc_entry          ec         
         , acc_account        gl_acc
         , acc_account        card_acc
         , acc_macros         m
         , opr_operation      o
         , opr_participant    p
         , prd_customer       cu
         , (select ao.account_id
                 , c.card_mask
                 , c.id as card_id
                 , row_number() over(partition by ao.account_id order by decode(c.category, iss_api_const_pkg.CARD_CATEGORY_PRIMARY, 0, 1) asc, c.id desc) as rnk
              from acc_account_object ao
                 , iss_card c
             where ao.object_id   = c.id
               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           ) ic
     where ec.id           between l_start_id and l_till_id
       and ec.posting_date between l_start_date and l_end_date
       and gl_acc.id             = ec.account_id
       and m.id                  = ec.macros_id 
       and m.entity_type         = opr_api_const_pkg.ENTITY_TYPE_OPERATION -- 'ENTTOPER'
       and o.id                  = m.object_id
       and p.oper_id             = o.id
       and p.participant_type    = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
       and (    p.client_id_type      = opr_api_const_pkg.CLIENT_ID_TYPE_CARD
            and ic.card_id            = p.card_id
            and card_acc.id           = ic.account_id 
            and cu.id                 = card_acc.customer_id
            or
                p.client_id_type      = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
            and card_acc.id           = p.account_id 
            and cu.id                 = card_acc.customer_id
            and ic.account_id         = card_acc.id 
            and ic.rnk                = 1
           )
       and exists(select 1 
                    from acc_gl_account_mvw gl 
                   where gl.id       = ec.account_id
                     and (gl.inst_id = l_inst_id or l_inst_id = ost_api_const_pkg.DEFAULT_INST)
                    )
     union all
    select card_acc.account_number
         , card_acc.id         as card_account_id
         , card_acc.split_hash as card_split_hash
         , null                as card_mask
         , cu.customer_number
         , cu.entity_type      as customer_entity_type
         , cu.object_id        as customer_object_id
         , null                as national_id
         , gl_acc.account_number gl_account_number
         , m.macros_type_id
         , o.oper_type
         , o.oper_date
         , ec.posting_date
         , ec.amount
         , ec.currency
         , null as due_date
         , null as aging
         , gl_acc.account_type as gl_account_type
         , null as overdue_date
      from acc_entry          ec         
         , acc_account        gl_acc
         , acc_account        card_acc
         , acc_macros         m
         , opr_operation      o
         , opr_participant    p
         , prd_customer       cu
     where ec.id           between l_start_id and l_till_id
       and ec.posting_date between l_start_date and l_end_date
       and gl_acc.id             = ec.account_id
       and m.id                  = ec.macros_id 
       and m.entity_type         = opr_api_const_pkg.ENTITY_TYPE_OPERATION -- 'ENTTOPER'
       and o.id                  = m.object_id
       and p.oper_id             = o.id
       and p.participant_type    = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
       and p.client_id_type      = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
       and card_acc.id           = p.account_id 
       and cu.id                 = card_acc.customer_id
       and not exists (select 1 
                         from acc_account_object ao
                        where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                          and card_acc.id    = ao.account_id)
       and exists(select 1 
                    from acc_gl_account_mvw gl 
                   where gl.id       = ec.account_id
                     and (gl.inst_id = l_inst_id or l_inst_id = ost_api_const_pkg.DEFAULT_INST)
                    );


    for i in 1 .. o_gl_acc_tab.count loop

        select t.id_series || t.id_number
          into o_gl_acc_tab(i).national_id
          from (
              select q.id_series
                   , q.id_number
                from com_id_object q
               where q.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                 and q.object_id   = case
                                         when o_gl_acc_tab(i).customer_entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                                         then o_gl_acc_tab(i).customer_object_id
                                         else null
                                     end
                 and q.id_type     = com_api_const_pkg.ID_TYPE_NATIONAL_ID -- 'IDTP0045'
               order by q.id desc
          ) t
         where rownum = 1;

        select t.due_date
             , t.aging_period
          into o_gl_acc_tab(i).due_date
             , o_gl_acc_tab(i).aging
          from (
              select i.due_date
                   , i.aging_period
                from crd_invoice i
               where i.account_id = o_gl_acc_tab(i).card_account_id
                 and i.split_hash = o_gl_acc_tab(i).card_split_hash
               order by i.invoice_date desc
                      , i.id desc
          ) t
         where rownum = 1;

        select t.overdue_date
          into o_gl_acc_tab(i).overdue_date
          from (
              select i.overdue_date
                from crd_invoice i
               where i.account_id = o_gl_acc_tab(i).card_account_id
                 and i.split_hash = o_gl_acc_tab(i).card_split_hash
               order by i.invoice_date
                      , i.id
          ) t
         where rownum = 1;

    end loop;

    o_row_count := o_gl_acc_tab.count;

end get_gl_account_numbers_data;

procedure create_account(
    o_id                     out com_api_type_pkg.t_account_id
  , io_split_hash         in out com_api_type_pkg.t_tiny_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , io_account_number     in out com_api_type_pkg.t_account_number
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id
  , i_status              in     com_api_type_pkg.t_dict_value
  , i_contract_id         in     com_api_type_pkg.t_medium_id
  , i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_customer_number     in     com_api_type_pkg.t_name
) is
begin
    acc_api_account_pkg.create_account(
        o_id                  => o_id
      , io_split_hash         => io_split_hash
      , i_account_type        => i_account_type
      , io_account_number     => io_account_number
      , i_currency            => i_currency
      , i_inst_id             => i_inst_id
      , i_agent_id            => i_agent_id
      , i_status              => i_status
      , i_contract_id         => i_contract_id
      , i_customer_id         => i_customer_id
      , i_customer_number     => i_customer_number
    );
end create_account;

procedure add_account_object(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_usage_order         in     com_api_type_pkg.t_tiny_id             default null
  , i_is_pos_default      in     com_api_type_pkg.t_boolean             default null
  , i_is_atm_default      in     com_api_type_pkg.t_boolean             default null
  , i_is_atm_currency     in     com_api_type_pkg.t_boolean             default null
  , i_is_pos_currency     in     com_api_type_pkg.t_boolean             default null
  , i_account_seq_number  in     acc_api_type_pkg.t_account_seq_number  default null
  , o_account_object_id      out com_api_type_pkg.t_long_id
) is
begin
    acc_api_account_pkg.add_account_object(
        i_account_id          => i_account_id
      , i_entity_type         => i_entity_type
      , i_object_id           => i_object_id
      , i_usage_order         => i_usage_order
      , i_is_pos_default      => i_is_pos_default
      , i_is_atm_default      => i_is_atm_default
      , i_is_atm_currency     => i_is_atm_currency
      , i_is_pos_currency     => i_is_pos_currency
      , i_account_seq_number  => i_account_seq_number
      , o_account_object_id   => o_account_object_id
    );
end add_account_object;

procedure set_is_settled(
    i_entry_id             in    com_api_type_pkg.t_long_id
  , i_is_settled           in    com_api_type_pkg.t_boolean     := com_api_const_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id
  , i_sttl_flag_date       in    date                           := null
  , i_split_hash           in    com_api_type_pkg.t_tiny_id
) is
begin
    acc_api_entry_pkg.set_is_settled(
        i_entry_id             => i_entry_id
      , i_is_settled           => i_is_settled
      , i_inst_id              => i_inst_id
      , i_sttl_flag_date       => i_sttl_flag_date
      , i_split_hash           => i_split_hash
    );
end set_is_settled;

procedure set_is_settled(
    i_entry_id_tab         in    com_api_type_pkg.t_long_tab
  , i_is_settled           in    com_api_type_pkg.t_boolean     := com_api_const_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id_tab
  , i_sttl_flag_date       in    date                           := null
  , i_split_hash           in    com_api_type_pkg.t_tiny_tab
) is
begin
    acc_api_entry_pkg.set_is_settled(
        i_entry_id_tab         => i_entry_id_tab
      , i_is_settled           => i_is_settled
      , i_inst_id              => i_inst_id
      , i_sttl_flag_date       => i_sttl_flag_date
      , i_split_hash           => i_split_hash
    );
end set_is_settled;

procedure set_is_settled(
    i_operation_id_tab     in    num_tab_tpt
  , i_is_settled           in    com_api_type_pkg.t_boolean     := com_api_const_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id_tab
  , i_sttl_flag_date       in    date                           := null
  , i_split_hash           in    com_api_type_pkg.t_tiny_tab
) is
begin
    acc_api_entry_pkg.set_is_settled(
        i_operation_id_tab     => i_operation_id_tab
      , i_is_settled           => i_is_settled
      , i_inst_id              => i_inst_id
      , i_sttl_flag_date       => i_sttl_flag_date
      , i_split_hash           => i_split_hash
    );
end set_is_settled;

procedure get_opr_entries(
    i_oper_id                  in    com_api_type_pkg.t_long_id
  , i_array_balance_type_id    in    com_api_type_pkg.t_medium_id        default null
  , i_array_trans_type_id      in    com_api_type_pkg.t_medium_id        default null
  , i_array_settl_type_id      in    com_api_type_pkg.t_medium_id        default null
  , i_array_operations_type_id in    com_api_type_pkg.t_medium_id        default null 
  , o_ref_cursor               out   com_api_type_pkg.t_ref_cur  
) is
begin
      open o_ref_cursor for
    select nvl(cr.transaction_id, db.transaction_id)
         , nvl(cr.transaction_type, db.transaction_type)
         , nvl(cr.posting_date, db.posting_date)
         , db.id
         , dbac.account_number
         , dbac.currency
         , dag.agent_number
         , db.amount
         , db.currency
         , cr.id
         , crac.account_number
         , crac.currency
         , cag.agent_number
         , cr.amount
         , cr.currency
         , mc.conversion_rate
         , mc.rate_type
         , mc.amount_purpose
      from opr_operation op
         , acc_macros mc
         , acc_entry cr
         , acc_account crac 
 left join ost_agent cag on cag.id = crac.agent_id 
         , acc_entry db
         , acc_account dbac
 left join ost_agent dag on dag.id = dbac.agent_id
     where op.id = i_oper_id
       and op.id = mc.object_id
       and mc.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and cr.balance_impact = com_api_const_pkg.CREDIT
       and cr.macros_id      = mc.id
       and db.balance_impact = com_api_const_pkg.DEBIT
       and db.macros_id      = mc.id
       and dbac.id = db.account_id
       and crac.id = cr.account_id
       and nvl(cr.transaction_id, db.transaction_id) = nvl(db.transaction_id, cr.transaction_id)
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
end;

end acc_api_external_pkg;
/
