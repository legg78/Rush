create or replace package body crd_prc_reserve_pkg as

procedure process(
    i_inst_id        in      com_api_type_pkg.t_inst_id
)is
    l_account_id            com_api_type_pkg.t_account_id;
    l_account_number        com_api_type_pkg.t_account_number;
    l_customer_id           com_api_type_pkg.t_account_id;        
    l_product_id            com_api_type_pkg.t_short_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_eff_date              date;

    l_total_reserve         com_api_type_pkg.t_money    := 0;
    l_total_account_debt    com_api_type_pkg.t_money    := 0;
    l_reserve_amount        com_api_type_pkg.t_money    := 0;
    l_guarantee_sum         com_api_type_pkg.t_money    := 0;
    l_guarantee_amount      com_api_type_pkg.t_money    := 0;

    l_aging_period          com_api_type_pkg.t_tiny_id;
    l_coeff                 com_api_type_pkg.t_money;
    l_balances              com_api_type_pkg.t_amount_by_name_tab;

    l_params                com_api_type_pkg.t_param_tab;
    l_fee_id                com_api_type_pkg.t_long_id;
    l_national_currency     com_api_type_pkg.t_curr_code;
    l_guarantee_category    com_api_type_pkg.t_dict_value;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_xml                   xmltype;
    l_sess_file_id          com_api_type_pkg.t_long_id;
    l_file                  clob;
    c_crlf                  constant   com_api_type_pkg.t_name := chr(13)||chr(10);
    
begin
    trc_log_pkg.debug (
        i_text              => 'Calculation of reserves of inst_id [#1] start'
      , i_env_param1        => i_inst_id
    );

    prc_api_stat_pkg.log_start;
    
    l_eff_date := get_sysdate;
    
    select count(1)
      into l_estimated_count
      from acc_account a 
         , prd_customer c
         , prd_service_object o
         , prd_service s
     where account_type      = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
       and a.inst_id         = i_inst_id
       and a.status          = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
       and c.id              = a.customer_id           
       and o.object_id       = a.id
       and o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT  
       and o.service_id      = s.id
       and o.split_hash      = a.split_hash
       and s.service_type_id = 10000403
       and l_eff_date between nvl(o.start_date, l_eff_date) and nvl(o.end_date, l_eff_date);

    prc_api_stat_pkg.log_estimation (
        i_estimated_count    => l_estimated_count
    );

    trc_log_pkg.debug (
        i_text               => 'Estimated count = ' || l_estimated_count
    );   
       
    l_national_currency := set_ui_value_pkg.get_inst_param_v(
                                i_param_name     => 'NATIONAL_CURRENCY'
                              , i_inst_id        => i_inst_id
                              , i_data_type      => 'DTTPCHAR'
                           );
        
    for r in (
        select a.id account_id
             , a.split_hash
             , a.currency
             , a.customer_id
             , a.account_number
             , nvl(c.credit_rating, 'CRDR0006') credit_rating
             , o.start_date
             , o.service_id
             , crd_invoice_pkg.get_last_invoice_id(
                    i_account_id     => a.id
                  , i_split_hash     => a.split_hash
                  , i_mask_error     => 1
                ) invoice_id
             , a.inst_id   
          from acc_account a 
             , prd_customer c
             , prd_service_object o
             , prd_service s
         where account_type      = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
           and a.inst_id         = i_inst_id
           and a.status          = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
           and c.id              = a.customer_id           
           and o.object_id       = a.id
           and o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT  
           and o.service_id      = s.id
           and o.split_hash      = a.split_hash
           and s.service_type_id = 10000403
           and l_eff_date between nvl(o.start_date, l_eff_date) and nvl(o.end_date, l_eff_date)
    )
    loop
        begin
            trc_log_pkg.debug (
                i_text          => 'Process account [#1] start'
              , i_env_param1    => r.account_id
            );

            -- total_account_debt
            acc_api_balance_pkg.get_account_balances (
                i_account_id    => r.account_id
                , o_balances    => l_balances
            );        
            l_total_account_debt := l_balances(acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT).amount     --'BLTP1002'
                                  + l_balances(acc_api_const_pkg.BALANCE_TYPE_OVERDUE).amount       --'BLTP1004'
                                  + l_balances(acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT).amount;    --'BLTP1007'
            
            l_product_id := prd_api_product_pkg.get_product_id (
                i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                , i_object_id   => r.account_id
            );
                    
            -- aging period
            if r.invoice_id is not null then
            
                select nvl(aging_period, 0)
                  into l_aging_period
                  from crd_invoice 
                 where id = r.invoice_id;
            else
                l_aging_period := 0;
                                                             
            end if;
            
            l_params.delete;
            rul_api_param_pkg.set_param(
                io_params => l_params
              , i_name    => 'CREDIT_RATING'
              , i_value   => r.credit_rating
            );
            
            rul_api_param_pkg.set_param(
                io_params => l_params
              , i_name    => 'START_DATE'
              , i_value   => r.start_date
            );
            
            rul_api_param_pkg.set_param(
                io_params => l_params
              , i_name    => 'AGING_PERIOD'
              , i_value   => l_aging_period
            );
            
            --calc reserve
            l_fee_id := prd_api_product_pkg.get_fee_id (
                i_product_id        => l_product_id
                , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT  
                , i_object_id       => r.account_id
                , i_fee_type        => 'FETP0401'
                , i_params          => l_params
                , i_eff_date        => l_eff_date
                , i_inst_id         => r.inst_id
            );        
            
            fcl_api_fee_pkg.get_fee_amount(
                i_fee_id            => l_fee_id
              , i_base_amount       => abs(l_total_account_debt)
              , i_base_currency     => r.currency
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT 
              , i_object_id         => r.account_id
              , io_fee_currency     => l_national_currency
              , o_fee_amount        => l_reserve_amount
            );
            l_reserve_amount := round(l_reserve_amount);
            
            trc_log_pkg.debug (
                i_text              => 'Process account [#1], l_fee_id [#2], reserv_amount [#3]'
              , i_env_param1        => r.account_id
              , i_env_param2        => l_fee_id
              , i_env_param3        => l_reserve_amount
            );
               
            -- check crd_providing_sum
            l_guarantee_sum := prd_api_product_pkg.get_attr_value_number (
                                        i_product_id        => l_product_id
                                      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                      , i_object_id         => r.account_id
                                      , i_attr_name         => 'CRD_GUARANTEE_SUM'
                                      , i_params            => l_params
                                      , i_service_id        => r.service_id
                                      , i_eff_date          => l_eff_date
                                      , i_split_hash        => r.split_hash
                                      , i_inst_id           => r.inst_id
                                    );
                                
            l_guarantee_category := nvl(prd_api_product_pkg.get_attr_value_char (
                                        i_product_id        => l_product_id
                                      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                      , i_object_id         => r.account_id
                                      , i_attr_name         => 'CRD_GUARANTEE_TYPE'
                                      , i_params            => l_params
                                      , i_service_id        => r.service_id
                                      , i_eff_date          => l_eff_date
                                      , i_split_hash        => r.split_hash
                                      , i_inst_id           => r.inst_id
                                    ), 'CRDP0001');        
            
            if l_guarantee_sum is not null and l_guarantee_category != 'CRDP0001' then
            
                if l_guarantee_category = 'CRDP0002' then
                    l_coeff := 1;
                    
                elsif l_guarantee_category = 'CRDP0003' then
                    l_coeff := 0.5;
                    
                end if;
                
                if l_coeff * l_guarantee_sum >= l_total_account_debt then
                    l_guarantee_amount := 0;
                else    
                    l_guarantee_amount := l_reserve_amount * (1 - (l_coeff * l_guarantee_sum / l_total_account_debt));                
                end if;    
                
                l_reserve_amount := l_guarantee_amount;
            end if;
            
            trc_log_pkg.debug (
                i_text          => 'Process account [#1], l_fee_id [#2], providing_sum [#3], providing_category [#4], reserv_amount [#5]'
              , i_env_param1    => r.account_id
              , i_env_param2    => l_fee_id
              , i_env_param3    => l_guarantee_sum
              , i_env_param4    => l_guarantee_category
              , i_env_param5    => l_reserve_amount
            );
            
            --total
            l_total_reserve := l_total_reserve + l_reserve_amount;
            
            --save total
            insert into crd_reserve_tmp(
                account_id              
                , currency              
                , product_id            
                , credit_rating         
                , guarantee_category    
                , reserve_amount                 
            ) values (
                r.account_id              
                , r.currency              
                , l_product_id            
                , r.credit_rating          
                , l_guarantee_category    
                , l_reserve_amount                 
            );
            
            l_processed_count := l_processed_count + 1;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;        
            
            --save last record data
            l_account_id     := r.account_id;
            l_customer_id    := r.customer_id;
            l_account_number := r.account_number;
            l_split_hash     := r.split_hash;

            trc_log_pkg.debug (
                i_text          => 'Process account [#1] end'
              , i_env_param1    => r.account_id
            );
        
        exception
            when com_api_error_pkg.e_application_error then
                
                l_excepted_count := l_excepted_count + 1;
                
                prc_api_stat_pkg.log_current(
                    i_current_count  => l_processed_count
                  , i_excepted_count => l_excepted_count
                );
                trc_log_pkg.debug (
                    i_text          => sqlerrm
                );   
                trc_log_pkg.debug (
                    i_text          => 'Exception on account [#1]'
                  , i_env_param1    => r.account_id
                );
                
            when others then
                trc_log_pkg.debug (
                    i_text          => sqlerrm
                );   
                trc_log_pkg.debug (
                    i_text          => 'Exception on account [#1]'
                  , i_env_param1    => r.account_id
                );
                raise;                
        end;
                
    end loop;
    
    --create operation
    if l_total_reserve > 0 then
        opr_api_create_pkg.create_operation (
            io_oper_id          => l_oper_id
          , i_is_reversal       => com_api_const_pkg.FALSE
          , i_oper_type         => 'OPTP1010'
          , i_oper_reason       => null
          , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
          , i_status            => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
          , i_status_reason     => null
          , i_sttl_type         => opr_api_const_pkg.SETTLEMENT_INTERNAL_INTRAINST
          , i_oper_count        => 1
          , i_oper_amount       => l_total_reserve
          , i_oper_currency     => l_national_currency 
          , i_oper_date         => l_eff_date
          , i_host_date         => l_eff_date
        );
        
        opr_api_create_pkg.add_participant(
            i_oper_id           => l_oper_id
          , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
          , i_oper_type         => 'OPTP1010'
          , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
          , i_host_date         => l_eff_date
          , i_inst_id           => i_inst_id
          , i_customer_id       => l_customer_id
          , i_account_id        => l_account_id
          , i_account_number    => l_account_number
          , i_split_hash        => l_split_hash
          , i_without_checks    => com_api_const_pkg.TRUE
        );
        trc_log_pkg.debug (
            i_text              => 'Created operation wih id [#1], total_reserve [#2]'
          , i_env_param1        => l_oper_id
          , i_env_param2        => l_total_reserve
        );
    end if;
    
    --generate xml
    begin
        select
            xmlelement("reserves"
                    , xmlagg(
                        xmlelement("reserve"
                            , xmlelement("product_id", product_id)
                            , xmlelement("currency", currency)
                            , xmlelement("credit_rating", credit_rating)
                            , xmlelement("guarantee_category", guarantee_category)
                            , xmlelement("reserve_amount", reserve_amount)
                        )
                        order by product_id
                               , currency
                    )
                )
            into
                l_xml
            from (    
            select sum(reserve_amount) reserve_amount  
                 , currency              
                 , product_id            
                 , credit_rating         
                 , guarantee_category 
              from crd_reserve_tmp
             group by currency              
                 , product_id            
                 , credit_rating         
                 , guarantee_category
            ); 
    exception
        when no_data_found then
            select
                xmlelement("reserves", '')
            into
                l_xml
            from
                dual;          
    end; 
    
    -- save to file 
    prc_api_file_pkg.open_file (
        o_sess_file_id  => l_sess_file_id
    );

    trc_log_pkg.debug (
        i_text          => 'Create file [#1]'
      , i_env_param1    => l_sess_file_id
    );

    l_file  := com_api_const_pkg.XML_HEADER || c_crlf || l_xml.getclobval();

    prc_api_file_pkg.put_file (
        i_sess_file_id    => l_sess_file_id
        , i_clob_content  => l_file
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_sess_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );
     
    trc_log_pkg.debug (
        i_text          => 'File saved'
    );
    
    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text          => 'Calculation of reserves of inst_id [#1] end'
      , i_env_param1    => i_inst_id
    );
     
exception
    when others then
        prc_api_stat_pkg.log_end (
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
end;

end;
/
