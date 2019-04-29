create or replace package body evt_prc_notification_pkg is
/**********************************************************
 * Creating notifications linked with defined events 
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 28.04.2017
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 * Module: EVT_PRC_NOTIFICATION_PKG
 * @headcom
 **********************************************************/

procedure gen_acq_min_amount_notifs(
    i_inst_id     in com_api_type_pkg.t_inst_id
) is

    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.gen_acq_min_amount_notifs: ';
    
    l_thread_number             com_api_type_pkg.t_tiny_id;
    l_excepted_count            com_api_type_pkg.t_long_id := 0;
    l_processed_count           com_api_type_pkg.t_long_id := 0;
    l_params                    com_api_type_pkg.t_param_tab;
    l_eff_date                  date;
    l_conv_sum                  com_api_type_pkg.t_money;
    l_rate_type                 com_api_type_pkg.t_dict_value;

begin
    savepoint proc_gen_acq_min_amount_notifs;

    l_thread_number := get_thread_number;
    l_eff_date    := com_api_sttl_day_pkg.get_calc_date(
                         i_inst_id => i_inst_id
                     );

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Start with inst_id [#1] eff date [#2]'
      , i_env_param1  => i_inst_id
      , i_env_param2  => to_char(l_eff_date, 'dd.mm.yyyy hh24:mi:ss')
    );    
    
    -- process 
    for tab in (
        with src as (
            select id
                 , split_hash
                 , currency
                 , fcl_api_limit_pkg.get_sum_limit(
                       i_limit_type    => acc_api_const_pkg.LIMIT_TYPE_MIN_TRESHOLD    
                     , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT        
                     , i_object_id     => id
                     , i_split_hash    => split_hash
                     , i_mask_error    => com_api_const_pkg.TRUE
                   ) limit_sum
                 , fcl_api_limit_pkg.get_limit_currency(
                       i_limit_type    => acc_api_const_pkg.LIMIT_TYPE_MIN_TRESHOLD
                     , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                     , i_object_id     => id
                     , i_split_hash    => split_hash
                     , i_mask_error    => com_api_const_pkg.TRUE
                   ) limit_currency
                 , acc_api_balance_pkg.get_aval_balance_amount_only(
                       i_account_id => id
                   ) account_sum
            from acc_account        
           where (inst_id = i_inst_id or i_inst_id is null)
             and account_type = acc_api_const_pkg.ACCOUNT_TYPE_MERCHANT
             and status = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
        )              
        select ac.id as account_id
             , ac.split_hash
             , trunc(ac.limit_sum / power(10, lcr.exponent), 2) limit_sum
             , ac.limit_currency
             , trunc(ac.account_sum / power(10, cr.exponent), 2) account_sum
             , ac.currency as account_currency  
          from src ac
          join com_currency cr
            on cr.code = ac.currency
          join com_currency lcr
            on lcr.code = ac.limit_currency
         where ac.limit_sum is not null
           and ac.account_sum is not null
    )          
    loop
        begin
            if tab.limit_currency != tab.account_currency then
                begin
                    select rate_type
                      into l_rate_type
                      from fcl_limit_rate r
                     where r.inst_id    = i_inst_id
                       and r.limit_type = acc_api_const_pkg.LIMIT_TYPE_MIN_TRESHOLD;

                    l_conv_sum := com_api_rate_pkg.convert_amount(
                                      i_src_amount      => tab.account_sum
                                    , i_src_currency    => tab.account_currency
                                    , i_dst_currency    => tab.limit_currency
                                    , i_rate_type       => l_rate_type
                                    , i_inst_id         => i_inst_id
                                    , i_eff_date        => l_eff_date
                                  );
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(
                            i_error         => 'LIMIT_RATE_TYPE_NOT_FOUND'
                          , i_env_param1    => acc_api_const_pkg.EVENT_MIN_THRESHOLD_OVERCOMING
                          , i_env_param2    => i_inst_id
                        );
                end;
            else 
                l_conv_sum := tab.account_sum;   
        end if;
            
            trc_log_pkg.debug(LOG_PREFIX || 'l_conv_sum=' || l_conv_sum);
            
            if l_conv_sum <= tab.limit_sum then 
                l_processed_count := l_processed_count + 1;
                savepoint sp_check_and_send_ntf;
        
                evt_api_event_pkg.register_event(
                    i_event_type   => acc_api_const_pkg.EVENT_MIN_THRESHOLD_OVERCOMING  -- 'EVNT2009'
                  , i_eff_date     => l_eff_date
                  , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id    => tab.account_id
                  , i_inst_id      => i_inst_id
                  , i_split_hash   => tab.split_hash    
                  , i_param_tab    => l_params
                );
                
            end if;    
            
        exception
            when com_api_error_pkg.e_application_error then
                l_excepted_count := l_excepted_count + 1;
                rollback to sp_check_and_send_ntf;
            when com_api_error_pkg.e_fatal_error then
                raise;
            when others then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );    
        end;    
        
        if l_processed_count mod 100 = 0 then
            prc_api_stat_pkg.log_current(
                i_current_count   => l_processed_count
              , i_excepted_count  => l_excepted_count
            );
        end if;

    end loop;  
    
    trc_log_pkg.debug (
        i_text      => LOG_PREFIX || 'Process finished success'
    );

    prc_api_stat_pkg.log_end (
        i_excepted_total    => l_excepted_count
      , i_processed_total   => l_processed_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    
exception
    when others then
        rollback to savepoint proc_gen_acq_min_amount_notifs;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        
        raise;
        
end gen_acq_min_amount_notifs;
   
end evt_prc_notification_pkg;
/
