create or replace package body fcl_prc_fee_cycle_pkg as

procedure process (
    i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_sysdate           date;
    l_next_date         date;
    l_prev_date         date;
    l_prev_next_date    date;
    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_entity_type       com_api_type_pkg.t_dict_value;
    l_object_id         com_api_type_pkg.t_long_id;
    l_fee_type          com_api_type_pkg.t_dict_value;
    l_period_number     com_api_type_pkg.t_tiny_id;
    l_cycle_counter_id  com_api_type_pkg.t_long_id;
    l_product_id        com_api_type_pkg.t_short_id;
    l_params            com_api_type_pkg.t_param_tab;
    l_fee_id            com_api_type_pkg.t_short_id;
    l_oper_id           com_api_type_pkg.t_long_id;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_record_count      pls_integer;
    l_excepted_count    pls_integer;
    l_fee_amount        com_api_type_pkg.t_money;
    l_fee_currency      com_api_type_pkg.t_curr_code;
    l_oper_type         com_api_type_pkg.t_dict_value;
    l_acq_inst_id       com_api_type_pkg.t_inst_id;
    l_iss_inst_id       com_api_type_pkg.t_inst_id;
    l_card_id           com_api_type_pkg.t_medium_id;
    l_merchant_id       com_api_type_pkg.t_short_id;
    l_terminal_id       com_api_type_pkg.t_short_id;
    l_account_number    com_api_type_pkg.t_account_number;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_calc_period       com_api_type_pkg.t_tiny_id;
    l_advc_period_count com_api_type_pkg.t_tiny_id;
    l_service_type_id   com_api_type_pkg.t_short_id;
    l_service_fee_id    com_api_type_pkg.t_short_id;

    l_terminal_number               com_api_type_pkg.t_terminal_number;
    l_terminal_type                 com_api_type_pkg.t_dict_value;
        
    l_merchant_number               com_api_type_pkg.t_merchant_number;
    l_merchant_name                 com_api_type_pkg.t_name;
        
    l_merchant_street               com_api_type_pkg.t_name;
    l_merchant_city                 com_api_type_pkg.t_name;
    l_merchant_country              com_api_type_pkg.t_country_code;
    l_merchant_postcode             com_api_type_pkg.t_postal_code;

    cursor cu_fees_count is
        select count(1)
          from fcl_cycle_counter a
             , fcl_fee_type b
         where b.cycle_type = a.cycle_type
           and b.cycle_type is not null
           and a.next_date <= l_sysdate
           and a.split_hash in (select split_hash from com_split_map where thread_number = get_thread_number);  

    cursor cu_fees is
        select a.next_date
             , a.prev_date
             , a.cycle_type
             , a.entity_type
             , a.object_id
             , b.fee_type
             , a.period_number
             , a.id
             , a.split_hash
          from fcl_cycle_counter a
             , fcl_fee_type b
         where b.cycle_type = a.cycle_type
           and b.cycle_type is not null
           and a.next_date <= l_sysdate
           and a.split_hash in (select split_hash from com_split_map where thread_number = get_thread_number);
          
begin
    savepoint sp_process;
    
    prc_api_stat_pkg.log_start;

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    
    open cu_fees_count;
    fetch cu_fees_count into l_record_count;
    close cu_fees_count;
    
    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    if l_record_count = 0 then
        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
        return;
    end if;
    
    l_record_count := 0;
    
    open cu_fees;
    loop
        savepoint sp_record;
        
        fetch cu_fees into
            l_next_date
          , l_prev_date
          , l_cycle_type
          , l_entity_type
          , l_object_id
          , l_fee_type
          , l_period_number
          , l_cycle_counter_id
          , l_split_hash;
          
        exit when cu_fees%notfound;
        
        begin
            l_product_id        := null;
            l_fee_id            := null;
            l_fee_amount        := 0;
            l_fee_currency      := null;
            l_oper_id           := null;
            l_oper_type         := null;
            l_acq_inst_id       := null;
            l_iss_inst_id       := null;
            l_card_id           := null;
            l_merchant_id       := null;
            l_terminal_id       := null;
            l_account_number    := null;
            l_inst_id           := null;
            l_terminal_number   := null;
            l_terminal_type     := null;
            l_merchant_number   := null;
            l_merchant_name     := null;
            l_merchant_street   := null;
            l_merchant_city     := null;
            l_merchant_country  := null;
            l_merchant_postcode := null;

            l_product_id :=
                prd_api_product_pkg.get_product_id(
                    i_entity_type       => l_entity_type
                  , i_object_id         => l_object_id
                );

            select a.service_type_id
                 , s.service_fee
              into l_service_type_id
                 , l_service_fee_id
              from prd_attribute a
                 , prd_service_type s
             where a.object_type = l_fee_type
               and a.service_type_id = s.id;
                
            l_fee_id :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id        => l_product_id
                  , i_entity_type       => l_entity_type
                  , i_object_id         => l_object_id
                  , i_fee_type          => l_fee_type
                  , i_params            => l_params
                  , i_eff_date          => l_next_date
                  , i_inst_id           => i_inst_id                
                );
                
            if l_service_fee_id is not null then
                select nvl(sum(
                           least(l_next_date, nvl(o.end_date, l_next_date)) - o.start_date
                          ), 0)
                  into l_calc_period
                  from prd_service_object o
                     , prd_service s
                 where o.service_id      = s.id
                   and s.service_type_id = l_service_type_id
                   and o.entity_type     = l_entity_type
                   and o.object_id       = l_object_id
                   and l_next_date between nvl(trunc(o.start_date), l_next_date) and nvl(o.end_date, trunc(l_next_date)+1);
            else
                select nvl(
                           sum(least(l_next_date, nvl(end_date, l_next_date)) - greatest(l_prev_date, start_date))
                         , 0
                       )
                  into l_calc_period
                  from fcl_fee_counter
                 where fee_type    = l_fee_type
                   and entity_type = l_entity_type
                   and object_id   = l_object_id
                   and start_date <= l_next_date
                   and nvl(end_date, l_next_date) >= l_prev_date
                   and split_hash  = l_split_hash;
            end if;
            
            l_advc_period_count :=
                nvl(
                    com_api_flexible_data_pkg.get_flexible_value(
                        i_field_name   => 'ADVANCE_PERIOD_COUNT'
                      , i_entity_type  => fcl_api_const_pkg.ENTITY_TYPE_FEE
                      , i_object_id    => l_fee_id
                    )
                  , 1
                );
            
            if nvl(l_period_number, 1) = 1 and l_advc_period_count > 0 then
                null;
            else
                l_advc_period_count := 1;
            end if;
            
            for i in 1..l_advc_period_count loop
                l_prev_next_date := l_next_date;
                
                l_fee_amount := l_fee_amount +
                    fcl_api_fee_pkg.get_fee_amount(
                        i_fee_id            => l_fee_id
                      , i_base_amount       => 0
                      , i_base_count        => 0
                      , io_base_currency    => l_fee_currency
                      , i_entity_type       => l_entity_type
                      , i_object_id         => l_object_id
                      , i_eff_date          => l_next_date
                      , i_calc_period       => l_calc_period
                      , i_split_hash        => l_split_hash
                    );
                    
                fcl_api_cycle_pkg.switch_cycle(
                    i_cycle_type        => l_cycle_type
                  , i_product_id        => l_product_id
                  , i_entity_type       => l_entity_type
                  , i_object_id         => l_object_id
                  , i_params            => l_params
                  , i_eff_date          => l_sysdate
                  , i_split_hash        => l_split_hash
                  , o_new_finish_date   => l_next_date
                );
            end loop;

            if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                acc_api_account_pkg.get_account_info(
                    i_account_id            => l_object_id
                  , o_account_number        => l_account_number
                  , o_entity_type           => l_entity_type
                  , o_inst_id               => l_inst_id
                );
            end if;

            case
                when l_entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
                    l_oper_type   := opr_api_const_pkg.OPERATION_TYPE_INSTITUTION_FEE;
                    l_acq_inst_id :=
                        com_api_flexible_data_pkg.get_flexible_value (
                            i_field_name      => 'PROCESSOR_INSTITUTION'
                          , i_entity_type     => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                          , i_object_id       => l_inst_id
                        );
                when l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
                    if l_account_number is null then
                        acc_api_account_pkg.get_account_info(
                            i_entity_type           => l_entity_type
                          , i_object_id             => l_object_id
                          , i_curr_code             => l_fee_currency
                          , o_account_number        => l_account_number
                          , o_inst_id               => l_inst_id
                        );
                    end if;
                    
                    l_oper_type   := opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE; 

                when l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
                    if l_account_number is null then
                        acc_api_account_pkg.get_account_info(
                            i_entity_type           => l_entity_type
                          , i_object_id             => l_object_id
                          , i_curr_code             => l_fee_currency
                          , o_account_number        => l_account_number
                          , o_inst_id               => l_inst_id
                        );
                    end if;
                    
                    l_oper_type   := opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE; 

                    l_card_id := l_object_id;
                when l_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
                    l_oper_type   := opr_api_const_pkg.OPERATION_TYPE_ACQUIRER_FEE;
                    l_merchant_id := l_object_id;

                    for rec in (
                        select
                            inst_id
                            , merchant_number
                            , merchant_name
                        from
                            acq_merchant_vw m
                        where
                            m.id = l_merchant_id
                    ) loop
                        if l_inst_id is null then
                             l_inst_id := rec.inst_id;
                        end if;
                        l_merchant_number := rec.merchant_number;
                        l_merchant_name := rec.merchant_name;
                    end loop;

                    for rec in (
                        select
                            a.street merchant_street
                            , a.city merchant_city
                            , a.country merchant_country
                            , a.postal_code merchant_postcode
                        from
                            com_address_vw a
                        where
                            a.id = acq_api_merchant_pkg.get_merchant_address_id (
                                i_merchant_id => l_merchant_id
                            )
                            and a.lang = com_ui_user_env_pkg.get_user_lang
                    ) loop
                        l_merchant_street := rec.merchant_street;
                        l_merchant_city := rec.merchant_city;
                        l_merchant_country := rec.merchant_country;
                        l_merchant_postcode := rec.merchant_postcode;
                    end loop;

                when l_entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
                    l_oper_type   := opr_api_const_pkg.OPERATION_TYPE_ACQUIRER_FEE; 
                    l_terminal_id := l_object_id;

                    for rec in (
                        select
                            inst_id
                            , terminal_number
                            , terminal_type
                        from
                            acq_terminal_vw
                        where
                            id = l_terminal_id
                    ) loop
                        if l_inst_id is null then
                             l_inst_id := rec.inst_id;
                        end if;
                        l_terminal_number := rec.terminal_number;
                        l_terminal_type := rec.terminal_type;
                    end loop;

            else
                null;
            end case;

            opr_api_create_pkg.create_operation (
                io_oper_id           => l_oper_id
              , i_session_id         => get_session_id
              , i_status             => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
              , i_is_reversal        => com_api_const_pkg.FALSE
              , i_sttl_type          => opr_api_const_pkg.SETTLEMENT_INTERNAL_INTRAINST
              , i_msg_type           => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
              , i_oper_type          => l_oper_type
              , i_oper_reason        => l_fee_type
              , i_merchant_number    => l_merchant_number
              , i_merchant_name      => l_merchant_name
              , i_merchant_street    => l_merchant_street
              , i_merchant_city      => l_merchant_city
              , i_merchant_country   => l_merchant_country
              , i_merchant_postcode  => l_merchant_postcode
              , i_terminal_number    => l_terminal_number
              , i_terminal_type      => l_terminal_type
              , i_oper_amount        => l_fee_amount
              , i_oper_currency      => l_fee_currency
              , i_oper_date          => l_sysdate
              , i_host_date          => l_prev_next_date
            );
            
            opr_api_create_pkg.add_participant(
                i_oper_id               => l_oper_id
              , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
              , i_oper_type             => l_oper_type
              , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
              , i_host_date             => l_prev_next_date
              , i_inst_id               => l_inst_id
--              , i_customer_id           => l_customer_id
              , i_card_id               => l_card_id
--              , i_account_id            => l_account_id
              , i_account_number        => l_account_number
              , i_merchant_id           => l_merchant_id
              , i_terminal_id           => l_terminal_id
              , i_split_hash            => l_split_hash
              , i_without_checks        => com_api_const_pkg.TRUE
            );

            l_record_count := l_record_count + 1;
            
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_record;
                l_excepted_count := l_excepted_count + 1;
                
            when com_api_error_pkg.e_fatal_error then
                raise;
                
            when others then
                rollback to sp_process;
                
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => SQLERRM
                );
        end;
        
        if mod(l_record_count, 100) = 0 then
            prc_api_stat_pkg.log_current (
                i_current_count     => l_record_count
              , i_excepted_count    => l_excepted_count
            );
        end if;
    end loop;
    close cu_fees;

    prc_api_stat_pkg.log_current (
        i_current_count     => l_record_count
      , i_excepted_count    => l_excepted_count
    );

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to sp_process;
        
        if cu_fees_count%isopen then
            close cu_fees_count;
        end if;
        if cu_fees%isopen then
            close cu_fees;
        end if;
      
        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
        raise;
end;

end;
/