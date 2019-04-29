create or replace package body crd_cst_payment_pkg as

procedure apply_payment(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_account_type      in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , io_payment_amount   in out  com_api_type_pkg.t_money
) is
begin
    crd_cst_payment_pkg.apply_payment(
        i_payment_id        => i_payment_id
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_account_id        => i_account_id
      , i_currency          => i_currency
      , i_inst_id           => i_inst_id
      , i_account_type      => i_account_type
      , i_product_id        => i_product_id
      , i_service_id        => i_service_id
      , i_payment_amount    => io_payment_amount
    );
end;

procedure apply_payment(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_account_type      in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_payment_amount    in      com_api_type_pkg.t_money
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.apply_payment: ';
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_bunch_id                  com_api_type_pkg.t_long_id;
    l_bunch_type_id             com_api_type_pkg.t_long_id;
    l_bunch_type                varchar(2000);
    l_save_mask_error           com_api_type_pkg.t_boolean;
    l_debt_level                com_api_type_pkg.t_tiny_id;
    l_curr_debt_level           com_api_type_pkg.t_tiny_id;
    l_prev_debt_level           com_api_type_pkg.t_tiny_id;
    l_debt_level_start_date     date;
    l_invoice_date              date;
    l_invoice_mad               com_api_type_pkg.t_money;
    l_invoice_tad               com_api_type_pkg.t_money;
    l_sum_payment_amount        com_api_type_pkg.t_money;
    l_last_invoice_id           com_api_type_pkg.t_medium_id;

    cursor cur_payment_gl (
        i_payment_id    com_api_type_pkg.t_long_id
      , i_account_id    com_api_type_pkg.t_account_id
    ) is
    select cdp.balance_type
         , con.contract_type
         , o.merchant_country
         , o.id as oper_id
         , cd.oper_type
         , o.sttl_type
         , cd.macros_type_id
         , cd.fee_type
         , o.oper_reason
         , o.msg_type
         , o.is_reversal
         , cdp.pay_amount
         , cdp.id as pay_debt_id
      from crd_payment          cp
         , crd_debt_payment     cdp
         , crd_debt             cd
         , opr_operation        o
         , acc_account          a
         , prd_contract         con
     where cd.account_id        = i_account_id
       and cd.id                = cdp.debt_id
       and cp.id                = cdp.pay_id
       and cp.id                = i_payment_id
       and o.id                 = decode(cd.oper_type, dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER
                                       , cd.original_id, cd.oper_id)
       and cd.account_id        = a.id
       and a.contract_id        = con.id
       and cdp.eff_date         = i_eff_date
       and cdp.pay_amount       > 0
       and (case when (cp.is_reversal = 1 and cp.original_oper_id is not null
                  and cp.original_oper_id = cd.oper_id)
                 then 0
                 else 1
            end) = 1
       and not exists (select 1
                        from opr_operation
                       where oper_type  = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER -- 'OPTP1501'
                         and id         = cp.oper_id
                      )
    union all
    select null balance_type
         , con.contract_type
         , o.merchant_country
         , o.id as oper_id
         , o.oper_type
         , o.sttl_type
         , null macros_type_id
         , null fee_type
         , o.oper_reason
         , o.msg_type
         , o.is_reversal
         , cdp.pay_amount
         , cdp.id as pay_debt_id
      from crd_payment          cp
         , crd_debt_payment     cdp
         , crd_debt             cd
         , opr_operation        o
         , acc_account          a
         , prd_contract         con
     where cd.account_id        = i_account_id
       and cd.id                = cdp.debt_id
       and cp.id                = cdp.pay_id
       and cp.id                = i_payment_id
       and cd.account_id        = a.id
       and a.contract_id        = con.id
       and cp.oper_id           = o.id
       and o.original_id        is null
       and cdp.eff_date         = i_eff_date
       and cdp.pay_amount       > 0
       and (o.is_reversal       = com_api_type_pkg.TRUE
            or
            o.oper_type         = opr_api_const_pkg.OPERATION_TYPE_REFUND --'OPTP0020'
            )
         ;
begin
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'GL routing payment: i_product_id=[#1], i_service_id=[#2], i_account_id=[#3], i_payment_id=[#4], i_payment_amount=[#5], i_eff_date=[#6]'
      , i_env_param1 => i_product_id
      , i_env_param2 => i_service_id
      , i_env_param3 => i_account_id
      , i_env_param4 => i_payment_id
      , i_env_param5 => i_payment_amount   
      , i_env_param6 => i_eff_date   
    );    

    l_debt_level := cst_lvp_debt_level_pkg.get_acc_debt_level(i_account_id);

    l_prev_debt_level := cst_lvp_debt_level_pkg.get_prev_debt_level(i_account_id);

    l_debt_level_start_date := cst_lvp_debt_level_pkg.get_debt_level_start_date(i_account_id);

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_debt_level=[#1], l_prev_debt_level=[#2], l_debt_level_start_date=[#3]'
      , i_env_param1 => l_debt_level
      , i_env_param2 => l_prev_debt_level
      , i_env_param3 => l_debt_level_start_date      
    );

    --Get debt level before payment
    begin          
        select curr_debt_level
          into l_curr_debt_level
          from (select to_number(substr(debt_level, -4)) as curr_debt_level
                     , row_number() over(order by id desc) rn
                  from cst_lvp_acc_debt_lvl_hist
                 where account_id = i_account_id
                   and trunc(end_date) = (select to_date(substr(max(bunch_id), 1, 6), 'yymmdd')
                                            from crd_debt_payment 
                                           where pay_id = i_payment_id
                                          )
                   and end_date = (select max(posting_date) keep (dense_rank first order by oper_id desc)
                                     from crd_payment 
                                    where account_id = i_account_id
                                   )
                )
         where rn = 1;                  
    exception
        when no_data_found then
            l_curr_debt_level := l_debt_level;
    end;

    trc_log_pkg.debug(LOG_PREFIX || 'l_curr_debt_level=' || l_curr_debt_level);        
    
    rul_api_param_pkg.set_param (
        io_params         => l_param_tab
      , i_name            => 'DEBT_LEVEL'
      , i_value           => l_debt_level
    );

    rul_api_param_pkg.set_param (
        io_params         => l_param_tab
      , i_name            => 'PREV_DEBT_LEVEL'
      , i_value           => l_prev_debt_level
    );

    rul_api_param_pkg.set_param (
        io_params         => l_param_tab
      , i_name            => 'DEBT_LVL_START_DATE'
      , i_value           => l_debt_level_start_date
    );

    rul_api_param_pkg.set_param (
        io_params         => l_param_tab
      , i_name            => 'CURRENT_DEBT_LV'
      , i_value           => l_curr_debt_level
    );
    
    if cst_lvp_com_pkg.check_set_product_attr(
            i_product_id        => i_product_id
          , i_attr_name         => cst_lvp_const_pkg.BUNCH_GL_ROUTING
        ) = com_api_const_pkg.TRUE then

        for rec in cur_payment_gl (
            i_payment_id
          , i_account_id)
        loop     
            begin
                insert into cst_lvp_payment_log (
                    pay_debt_id
                  , eff_date        
                  , run_date
                ) values (
                    rec.pay_debt_id   
                  , i_eff_date
                  , get_sysdate     
                );
                   
                rul_api_param_pkg.set_param (
                    io_params         => l_param_tab
                  , i_name            => 'BALANCE_TYPE'
                  , i_value           => rec.balance_type
                );

                rul_api_param_pkg.set_param (
                    io_params         => l_param_tab
                  , i_name            => 'CONTRACT_TYPE'
                  , i_value           => rec.contract_type
                );

                rul_api_param_pkg.set_param (
                    io_params         => l_param_tab
                  , i_name            => 'CST_CREDIT_DEBIT_FLAG'
                  , i_value           => com_api_type_pkg.TRUE
                );

                rul_api_param_pkg.set_param (
                    io_params         => l_param_tab
                  , i_name            => 'MERCHANT_COUNTRY'
                  , i_value           => rec.merchant_country
                );

                rul_api_param_pkg.set_param (
                    io_params         => l_param_tab
                  , i_name            => 'OPER_TYPE'
                  , i_value           => rec.oper_type
                );

                rul_api_param_pkg.set_param (
                    io_params         => l_param_tab
                  , i_name            => 'STTL_TYPE'
                  , i_value           => rec.sttl_type
                );

                rul_api_param_pkg.set_param (
                    io_params         => l_param_tab
                  , i_name            => 'MACROS_TYPE'
                  , i_value           => rec.macros_type_id
                );

                rul_api_param_pkg.set_param (
                    io_params         => l_param_tab
                  , i_name            => 'OPER_REASON'
                  , i_value           => rec.oper_reason
                );            

                rul_api_param_pkg.set_param (
                    io_params         => l_param_tab
                  , i_name            => 'IS_REVERSAL'
                  , i_value           => rec.is_reversal
                );
                
                begin
                    l_save_mask_error := com_api_error_pkg.get_mask_error;
                    com_api_error_pkg.set_mask_error (
                        i_mask_error  => com_api_type_pkg.FALSE
                    );                    
                    
                    l_bunch_type :=
                        prd_api_product_pkg.get_attr_value_char (
                                i_product_id    => i_product_id
                              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id     => i_account_id
                              , i_attr_name     => cst_lvp_const_pkg.BUNCH_GL_ROUTING
                              , i_service_id    => i_service_id
                              , i_split_hash    => i_split_hash
                              , i_params        => l_param_tab
                              , i_eff_date      => i_eff_date
                              , i_inst_id       => i_inst_id
                            );
                            
                    com_api_error_pkg.set_mask_error (
                        i_mask_error  => l_save_mask_error
                    );
                    
                exception
                    when com_api_error_pkg.e_application_error then
                        trc_log_pkg.debug('Bunch type id does not exist.');
                        l_bunch_type := null;
                        insert into cst_lvp_payment_gl_routing_log(
                            payment_id
                          , oper_id
                          , balance_type
                          , contract_type
                          , merchant_country
                          , oper_type
                          , sttl_type
                          , macros_type_id
                          , fee_type
                          , oper_reason
                          , msg_type
                          , is_reversal
                          , pay_amount
                          , eff_date
                          ) values (
                            i_payment_id
                          , rec.oper_id
                          , rec.balance_type
                          , rec.contract_type
                          , rec.merchant_country
                          , rec.oper_type
                          , rec.sttl_type
                          , rec.macros_type_id
                          , rec.fee_type
                          , rec.oper_reason
                          , rec.msg_type
                          , rec.is_reversal
                          , rec.pay_amount
                          , i_eff_date
                        );
                end;

                if l_bunch_type is not null then
                    l_bunch_type_id := to_number(l_bunch_type);
                    acc_api_entry_pkg.put_bunch (
                        o_bunch_id          => l_bunch_id
                      , i_bunch_type_id     => l_bunch_type_id
                      , i_macros_id         => i_payment_id
                      , i_amount            => rec.pay_amount
                      , i_currency          => i_currency
                      , i_account_type      => i_account_type
                      , i_account_id        => i_account_id
                      , i_posting_date      => i_eff_date
                      , i_param_tab         => l_param_tab
                    );
                end if;
                
            exception
                when dup_val_on_index then
                    trc_log_pkg.debug(
                        i_text          => LOG_PREFIX || 'Payment duplicated! pay_id = [#1]'
                      , i_env_param1    => i_payment_id
                    );
            end;            
        end loop;
    end if;
    
    -- After payment, check and update values of is_mad_paid, is_tad_paid in invoice
    l_last_invoice_id :=
    crd_invoice_pkg.get_last_invoice_id(
        i_account_id    => i_account_id
      , i_split_hash    => i_split_hash
      , i_mask_error    => com_api_const_pkg.TRUE
    );
    
    begin 
        select invoice_date
             , min_amount_due
             , total_amount_due
          into l_invoice_date
             , l_invoice_mad
             , l_invoice_tad
          from crd_invoice
         where id = l_last_invoice_id;
    exception
        when no_data_found then
            l_invoice_date := null;
    end;  
    
    if l_invoice_date is not null then
        --Sum of all payments are not included in invoice yet (payments after invoice date)
        select nvl(sum(amount), 0) 
          into l_sum_payment_amount
          from crd_payment
         where decode(is_new, 1, account_id, null) = i_account_id
           and split_hash = i_split_hash;
        
        if l_sum_payment_amount >= l_invoice_mad then 
        
            update crd_invoice
               set is_mad_paid = com_api_type_pkg.TRUE
             where id = l_last_invoice_id;
             
            trc_log_pkg.debug(
                i_text          => LOG_PREFIX || 'l_sum_payment_amount=[#1], l_invoice_mad=[#2], update crd_invoice set is_mad_paid = 1 where id = #3 '
              , i_env_param1    => l_sum_payment_amount
              , i_env_param2    => l_invoice_mad
              , i_env_param3    => l_last_invoice_id
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => i_account_id
            );
            
        end if;
        
        if l_sum_payment_amount >= l_invoice_tad then 
        
            update crd_invoice
               set is_tad_paid = com_api_type_pkg.TRUE
             where id = l_last_invoice_id;
            
            trc_log_pkg.debug(
                i_text          => LOG_PREFIX || 'l_sum_payment_amount=[#1], l_invoice_tad=[#2], update crd_invoice set is_tad_paid = 1 where id = #3 '
              , i_env_param1    => l_sum_payment_amount
              , i_env_param2    => l_invoice_tad
              , i_env_param3    => l_last_invoice_id
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => i_account_id
            );
        end if;
    
    end if;
    
end;

procedure enum_debt_order(
    io_cur_debts        in out  com_api_type_pkg.t_ref_cur
  , io_query            in out  com_api_type_pkg.t_text
  , io_order_by         in out  com_api_type_pkg.t_text
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_eff_date          in      date
  , i_original_oper_id  in      com_api_type_pkg.t_long_id
  , i_payment_condition in      com_api_type_pkg.t_dict_value
  , i_repay_mad_first   in      com_api_type_pkg.t_boolean
) is
begin
    null;
end;

end;
/
