create or replace package body ins_prc_premium_pkg is
/********************************************************* 
 *  process for insurance premium  <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 26.12.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: ins_prc_premium_pkg  <br /> 
 *  @headcom 
 **********************************************************/
 
procedure process(
    i_inst_id           in      com_api_type_pkg.t_inst_id      default null
) is

    l_sysdate           date;

    cursor cu_events_count is
        select count(1) 
          from evt_event_object o
             , evt_event e
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'INS_PRC_PREMIUM_PKG.PROCESS'
           and o.eff_date      <= l_sysdate
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and (
                o.inst_id        = i_inst_id
                or
                i_inst_id is null
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
               );

    cursor cu_events is
        select o.id
             , e.event_type
             , o.entity_type
             , o.object_id
             , o.eff_date
             , o.split_hash
          from evt_event_object o
             , evt_event e
             , evt_subscriber s
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'INS_PRC_PREMIUM_PKG.PROCESS'
           and o.eff_date      <= l_sysdate
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and (
                o.inst_id        = i_inst_id
                or
                i_inst_id is null
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           and e.event_type     = s.event_type
           and o.procedure_name = s.procedure_name
         order by o.eff_date, s.priority;
        
    l_record_count      com_api_type_pkg.t_count := 0;
    l_excepted_count    com_api_type_pkg.t_count := 0;
    l_event_id_tab      com_api_type_pkg.t_number_tab;
    l_event_type_tab    com_api_type_pkg.t_dict_tab;
    l_entity_type_tab   com_api_type_pkg.t_dict_tab;
    l_object_id_tab     com_api_type_pkg.t_number_tab;
    l_eff_date_tab      com_api_type_pkg.t_date_tab;
    l_split_hash_tab    com_api_type_pkg.t_number_tab;
    l_processed_tab     com_api_type_pkg.t_number_tab;

    l_product_id        com_api_type_pkg.t_short_id;
    l_service_id        com_api_type_pkg.t_short_id;
    l_params            com_api_type_pkg.t_param_tab;
    l_attr_base         com_api_type_pkg.t_dict_value;
    l_amount            com_api_type_pkg.t_money;
    l_oper_id           com_api_type_pkg.t_long_id;
    l_currency          com_api_type_pkg.t_curr_code;
    l_account_number    com_api_type_pkg.t_account_number;
    l_customer_id       com_api_type_pkg.t_medium_id;
    l_fee_id            com_api_type_pkg.t_short_id;
    l_inst_id           com_api_type_pkg.t_inst_id;
begin
    l_sysdate := com_api_sttl_day_pkg.get_sysdate; 
    
    trc_log_pkg.debug('Start Insurance premium calculation: sysdate=['||l_sysdate||'], thread_number=['||get_thread_number||'], inst_id=['||i_inst_id||']');

    prc_api_stat_pkg.log_start;

    open cu_events_count;
    fetch cu_events_count into l_record_count;
    close cu_events_count;
    
    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count 
    );
    
    l_record_count := 0;
    
    open cu_events;
    
    loop
        fetch cu_events bulk collect into
            l_event_id_tab
          , l_event_type_tab
          , l_entity_type_tab
          , l_object_id_tab
          , l_eff_date_tab
          , l_split_hash_tab
        limit 100;
        
        for i in 1..l_event_type_tab.count loop
            begin
                savepoint sp_ins_record;
        
                trc_log_pkg.debug('Insurance premium calculation: event type [' || l_event_type_tab(i) ||
                                  '], object ID [' || l_object_id_tab(i) || '] of entity type [' || l_entity_type_tab(i) ||
                                  '], eff date [' || com_api_type_pkg.convert_to_char(l_eff_date_tab(i)) || ']');

                begin
                    -- get account attributes
                    select a.inst_id
                         , a.currency
                         , t.product_id
                         , a.customer_id
                         , a.account_number
                      into l_inst_id
                         , l_currency
                         , l_product_id
                         , l_customer_id
                         , l_account_number
                      from acc_account a
                         , prd_contract t
                     where a.id         = l_object_id_tab(i)
                       and t.id         = a.contract_id
                       and t.split_hash = a.split_hash;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(
                            i_error         => 'ACCOUNT_NOT_FOUND'
                          , i_env_param1    => l_object_id_tab(i)
                        );
                end;
                
                l_service_id := null;

                l_service_id :=
                    prd_api_service_pkg.get_active_service_id(
                        i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id         => l_object_id_tab(i)
                      , i_attr_name         => null
                      , i_service_type_id   => ins_api_const_pkg.INS_CREDIT_SERVICE_TYPE
                      , i_split_hash        => l_split_hash_tab(i)
                      , i_eff_date          => l_eff_date_tab(i)
                      , i_inst_id           => l_inst_id
                      , i_mask_error        => com_api_type_pkg.TRUE
                    );
                    
                if l_service_id is not null then
              
                    l_attr_base := 
                        prd_api_product_pkg.get_attr_value_char(
                            i_product_id   => l_product_id
                          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id    => l_object_id_tab(i)
                          , i_attr_name    => ins_api_const_pkg.INS_ATTRIBUTE_BASE
                          , i_params       => l_params
                          , i_service_id   => l_service_id 
                          , i_eff_date     => l_eff_date_tab(i)
                          , i_inst_id      => l_inst_id
                        );

                    l_fee_id :=
                        prd_api_product_pkg.get_fee_id (
                            i_product_id    => l_product_id
                          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => l_object_id_tab(i)
                          , i_fee_type      => ins_api_const_pkg.INS_ATTRIBUTE_FEE
                          , i_service_id    => l_service_id
                          , i_params        => l_params
                          , i_eff_date      => l_eff_date_tab(i)
                          , i_split_hash    => l_split_hash_tab(i)
                          , i_inst_id       => l_inst_id
                        );
                        
                    begin
                        select case l_attr_base 
                                   when ins_api_const_pkg.INS_BASE_TOTAL_AMOUNT_DUE then total_amount_due 
                                   when ins_api_const_pkg.INS_BASE_CREDIT_LIMIT then exceed_limit
                                   when ins_api_const_pkg.INS_BASE_UNUSED_CREDIT_LIMIT then (exceed_limit - total_amount_due)
                                   else 0
                               end
                          into l_amount
                          from crd_invoice
                         where account_id   = l_object_id_tab(i)
                           and split_hash   = l_split_hash_tab(i)
                           and invoice_date = l_eff_date_tab(i);
                    exception
                        when no_data_found then
                            com_api_error_pkg.raise_error(
                                i_error         => 'INVOICE_NOT_FOUND'
                              , i_env_param1    => l_object_id_tab(i)
                            );
                    end;
                    
                    l_amount := 
                        fcl_api_fee_pkg.get_fee_amount(
                            i_fee_id          => l_fee_id
                          , i_base_amount     => l_amount
                          , i_base_count      => 1
                          , io_base_currency  => l_currency
                          , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id       => l_object_id_tab(i)
                          , i_eff_date        => l_eff_date_tab(i)
                          , i_calc_period     => null
                          , i_split_hash      => l_split_hash_tab(i)
                        );
                        
                    if l_amount > 0 then
    
                        l_oper_id := null;
                    
                        opr_api_create_pkg.create_operation (
                            io_oper_id          => l_oper_id
                          , i_is_reversal       => com_api_const_pkg.FALSE
                          , i_oper_type         => opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
                          , i_oper_reason       => ins_api_const_pkg.INS_ATTRIBUTE_FEE
                          , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                          , i_status            => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                          , i_status_reason     => null
                          , i_sttl_type         => opr_api_const_pkg.SETTLEMENT_INTERNAL_INTRAINST
                          , i_oper_count        => 1
                          , i_oper_amount       => l_amount
                          , i_oper_currency     => l_currency
                          , i_oper_date         => l_eff_date_tab(i)
                          , i_host_date         => l_sysdate
                        );

                        opr_api_create_pkg.add_participant(
                            i_oper_id               => l_oper_id
                          , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                          , i_oper_type             => opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
                          , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
                          , i_client_id_type        => opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
                          , i_client_id_value       => l_account_number
                          , i_host_date             => l_sysdate
                          , i_inst_id               => l_inst_id
                          , i_customer_id           => l_customer_id
                          , i_account_id            => l_object_id_tab(i)
                          , i_account_number        => l_account_number
                          , i_split_hash            => l_split_hash_tab(i)
                          , i_without_checks        => com_api_const_pkg.TRUE
                        );

                    end if;
                end if;

                l_processed_tab(l_processed_tab.count+1) := l_event_id_tab(i);

            exception
                when others then
                    rollback to sp_ins_record;
                    
                    l_excepted_count := l_excepted_count + 1;

                    if com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
                        raise;
                    elsif com_api_error_pkg.is_application_error(SQLCODE) = com_api_const_pkg.FALSE then
                        com_api_error_pkg.raise_fatal_error(
                            i_error         => 'UNHANDLED_EXCEPTION'
                          , i_env_param1    => SQLERRM
                        );
                    end if;
                    
            end;
        end loop;

        l_record_count := l_record_count + l_event_id_tab.count;
        
        prc_api_stat_pkg.log_current(
            i_current_count     => l_record_count
          , i_excepted_count    => l_excepted_count
        );
        
        exit when cu_events%notfound;
    end loop;

    evt_api_event_pkg.process_event_object(
        i_event_object_id_tab   => l_processed_tab
    );
    
    close cu_events;
    
    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
            
        rollback;
            
        if cu_events_count%isopen then
            close cu_events_count;
        end if;

        if cu_events%isopen then
            close cu_events;
        end if;
            
        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => SQLERRM
            );
        end if;
end;

end;
/
