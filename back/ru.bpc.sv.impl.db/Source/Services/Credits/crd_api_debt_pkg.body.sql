create or replace package body crd_api_debt_pkg as

procedure create_debt(
    i_macros_id         in      com_api_type_pkg.t_long_id
  , i_card_id           in      com_api_type_pkg.t_long_id
  , i_oper_id           in      com_api_type_pkg.t_long_id
  , i_oper_type         in      com_api_type_pkg.t_dict_value
  , i_sttl_type         in      com_api_type_pkg.t_dict_value
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_macros_type_id    in      com_api_type_pkg.t_tiny_id
  , i_terminal_type     in      com_api_type_pkg.t_dict_value
  , i_oper_date         in      date
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_amount            in      com_api_type_pkg.t_money
  , i_mcc               in      com_api_type_pkg.t_mcc
  , i_account_id        in      com_api_type_pkg.t_medium_id
  , i_posting_date      in      date
  , i_sttl_day          in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_is_reversal       in      com_api_type_pkg.t_boolean
  , i_original_id       in      com_api_type_pkg.t_long_id
) is
    l_debt_id                   com_api_type_pkg.t_long_id;
    l_prepaid_amount            com_api_type_pkg.t_money;
    l_debt_amount               com_api_type_pkg.t_money;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_service_id                com_api_type_pkg.t_short_id;
    l_prev_date                 date;
    l_next_date                 date;
    l_is_floating_period        com_api_type_pkg.t_boolean;
    l_eff_date                  date;
    l_interest_calc_start_date  com_api_type_pkg.t_dict_value;
    l_product_id                com_api_type_pkg.t_short_id;
    l_is_grace_enable           com_api_type_pkg.t_boolean;
    l_payment_reversal_method   com_api_type_pkg.t_dict_value;
    l_from_id                   com_api_type_pkg.t_long_id;
    l_till_id                   com_api_type_pkg.t_long_id;
    l_is_new                    com_api_type_pkg.t_boolean;
    l_ownfund_amt               com_api_type_pkg.t_money;
begin

    trc_log_pkg.debug('Create debt: macros id ['||i_macros_id||'] account id ['||i_account_id||'] split hash ['||i_split_hash||']');

    l_debt_id := i_macros_id;

    l_service_id := 
        crd_api_service_pkg.get_active_service(
            i_account_id        => i_account_id
          , i_eff_date          => i_posting_date
          , i_split_hash        => i_split_hash
        );

    if l_service_id is null then
        trc_log_pkg.debug('Debt registration: No active credit service, debt not registred.');
        return;
    end if;

    l_from_id              := com_api_id_pkg.get_from_id_num(i_macros_id);
    l_till_id              := com_api_id_pkg.get_till_id_num(i_macros_id);

    select nvl(abs(sum(e.amount * e.balance_impact)), 0)
      into l_debt_amount 
      from acc_entry e
         , crd_event_bunch_type s
     where e.macros_id      = i_macros_id
       and e.account_id     = i_account_id
       and s.event_type     = crd_api_const_pkg.APPLY_PAYMENT_EVENT
       and s.inst_id        = i_inst_id
       and e.balance_type   = s.balance_type
       and e.split_hash     = i_split_hash
       and e.id between l_from_id and l_till_id;

    if i_original_id is not null then
        begin
            select d.is_new
              into l_is_new
              from crd_debt d
                 , dpp_payment_plan p
             where d.id = p.id
               and d.oper_id = i_oper_id;

            if l_is_new = com_api_const_pkg.FALSE then
                l_is_grace_enable := com_api_const_pkg.FALSE;
            end if;

        exception
            when no_data_found then
                null;
        end;
    end if;

    insert into crd_debt(
        id
      , account_id
      , card_id
      , product_id
      , service_id
      , oper_id
      , oper_type
      , sttl_type
      , fee_type
      , terminal_type
      , oper_date
      , posting_date
      , sttl_day
      , currency
      , amount
      , debt_amount
      , mcc
      , aging_period
      , status
      , is_new
      , inst_id
      , agent_id
      , split_hash
      , macros_type_id
      , is_grace_enable
      , is_grace_applied
      , is_reversal
      , original_id
    ) values (
        i_macros_id
      , i_account_id
      , i_card_id
      , i_product_id
      , l_service_id
      , i_oper_id
      , i_oper_type
      , i_sttl_type
      , i_fee_type
      , i_terminal_type
      , i_oper_date
      , i_posting_date
      , i_sttl_day
      , i_currency
      , i_amount
      , l_debt_amount
      , i_mcc
      , 0
      , crd_api_const_pkg.DEBT_STATUS_ACTIVE
      , com_api_const_pkg.TRUE
      , i_inst_id
      , i_agent_id
      , i_split_hash
      , i_macros_type_id
      , com_api_const_pkg.FALSE
      , com_api_const_pkg.FALSE
      , i_is_reversal
      , i_original_id
    );
    
    -- fake record to include debt into invoice if it was paid fully by own funds
    if l_debt_amount = 0 then
        insert into crd_debt_balance(
            id
          , debt_id
          , balance_type
          , amount
          , repay_priority
          , min_amount_due
          , split_hash
          , posting_order
        ) values (
            com_api_id_pkg.get_id(crd_debt_balance_seq.nextval, i_macros_id)
          , i_macros_id
          , crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT
          , 0
          , null
          , 0
          , i_split_hash
          , 0
        );
    end if;

    crd_debt_pkg.load_debt_param(
        i_debt_id       => i_macros_id
      , io_param_tab    => l_param_tab
      , i_split_hash    => i_split_hash
      , o_product_id    => l_product_id
    );
    
    --get is_grace_enable 
    l_is_grace_enable :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id    => i_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_attr_name     => crd_api_const_pkg.GRACE_PERIOD_ENABLE
          , i_service_id    => l_service_id
          , i_split_hash    => i_split_hash
          , i_params        => l_param_tab
          , i_eff_date      => i_posting_date
          , i_inst_id       => i_inst_id
        );    
    
    update crd_debt
       set is_grace_enable = l_is_grace_enable
     where id = i_macros_id;

    trc_log_pkg.debug('Inserted debt rows '||sql%rowcount);
    
    l_interest_calc_start_date := 
        prd_api_product_pkg.get_attr_value_char(
            i_product_id    => i_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_attr_name     => crd_api_const_pkg.INTEREST_CALC_START_DATE
          , i_split_hash    => i_split_hash
          , i_service_id    => l_service_id
          , i_params        => l_param_tab
          , i_eff_date      => i_posting_date
          , i_inst_id       => i_inst_id
        );
    
    case l_interest_calc_start_date
        when crd_api_const_pkg.INTEREST_CALC_DATE_POSTING
        then l_eff_date := i_posting_date; 
        
        when crd_api_const_pkg.INTEREST_CALC_DATE_TRANSACTION
        then l_eff_date := i_oper_date;
        
        when crd_api_const_pkg.INTEREST_CALC_DATE_INVOICING
        then l_eff_date :=
                fcl_api_cycle_pkg.calc_next_date(
                    i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id         => i_account_id
                  , i_split_hash        => i_split_hash
                  , i_start_date        => i_posting_date
                  , i_raise_error       => com_api_type_pkg.TRUE
                );
                
        when crd_api_const_pkg.INTEREST_CALC_DATE_SETTLEMENT then
            begin
                select sttl_date
                  into l_eff_date
                  from (
                        select sttl_date
                          from com_settlement_day
                         where sttl_day = i_sttl_day
                           and inst_id in (i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                         order by inst_id
                       )
                 where rownum = 1;
            exception
                when no_data_found then
                    l_eff_date := trunc(i_posting_date);
            end;
            
        when crd_api_const_pkg.INTEREST_CALC_DATE_TRANS_NEXT then
            l_eff_date := trunc(i_posting_date) + 1;

        else
            l_eff_date := trunc(i_posting_date) + 1;
    end case;

    l_eff_date := crd_interest_pkg.get_interest_start_date(
                      i_product_id   => i_product_id
                    , i_account_id   => i_account_id
                    , i_split_hash   => i_split_hash
                    , i_service_id   => l_service_id
                    , i_param_tab    => l_param_tab
                    , i_posting_date => i_posting_date
                    , i_eff_date     => l_eff_date
                    , i_inst_id      => i_inst_id
                  );

    crd_debt_pkg.set_balance(
        i_debt_id           => l_debt_id
      , i_eff_date          => i_posting_date
      , i_account_id        => i_account_id
      , i_service_id        => l_service_id
      , i_inst_id           => i_inst_id
      , i_split_hash        => i_split_hash
    );

    trc_log_pkg.debug('Debt balances set'); 
    
    crd_interest_pkg.set_interest(
        i_debt_id           => l_debt_id
      , i_eff_date          => l_eff_date
      , i_account_id        => i_account_id
      , i_service_id        => l_service_id
      , i_split_hash        => i_split_hash
      , i_event_type        => crd_api_const_pkg.CREATE_DEBT_EVENT    
    );

    trc_log_pkg.debug('Debt interest set');
    
    l_payment_reversal_method := crd_api_const_pkg.PAYM_REV_METHOD_REG_DEBT;
    
    if i_is_reversal = com_api_const_pkg.TRUE and i_original_id is not null then
        begin
            l_payment_reversal_method := 
                prd_api_product_pkg.get_attr_value_char(
                    i_product_id    => i_product_id
                  , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => i_account_id
                  , i_attr_name     => crd_api_const_pkg.PAYMENT_REV_PROC_METHOD
                  , i_split_hash    => i_split_hash
                  , i_service_id    => l_service_id
                  , i_params        => l_param_tab
                  , i_eff_date      => i_posting_date            
                  , i_inst_id       => i_inst_id
                );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then
                    null;
                else
                    raise;
                end if;
        end;
        
        if l_payment_reversal_method = crd_api_const_pkg.PAYM_REV_METHOD_REVERT then
            crd_payment_pkg.cancel_payment(
                i_payment_id        => i_original_id
              , i_reversal_id       => l_debt_id
              , i_eff_date          => l_eff_date
              , i_reversal_amount   => i_amount
              , i_split_hash        => i_split_hash
            ); 
        end if;
    end if;
     
    l_prepaid_amount := greatest(0, i_amount - l_debt_amount);
     
    --get & check the current ownfund amount
    select sum(pay_amount) ownfund_amt
      into l_ownfund_amt 
      from crd_payment
     where decode(status, 'PMTSACTV', account_id, null) = i_account_id
       and split_hash = i_split_hash
     order by posting_date;
     
    if l_prepaid_amount > 0 and (l_payment_reversal_method != crd_api_const_pkg.PAYM_REV_METHOD_REVERT or nvl(l_ownfund_amt,0) > 0) then
        for r in (
            select id
                 , pay_amount
              from crd_payment
             where decode(status, crd_api_const_pkg.PAYMENT_STATUS_ACTIVE, account_id, null) = i_account_id
               and split_hash = i_split_hash
             order by posting_date
        ) loop
            insert into crd_debt_payment(
                id
              , debt_id
              , balance_type
              , pay_id
              , pay_amount
              , eff_date
              , split_hash
            ) values (
                com_api_id_pkg.get_id(crd_debt_payment_seq.nextval, l_debt_id)
              , l_debt_id
              , null
              , r.id
              , least(l_prepaid_amount, r.pay_amount)
              , i_posting_date
              , i_split_hash
            );
            
            update crd_payment
               set pay_amount = pay_amount - least(l_prepaid_amount, pay_amount)
                 , status     = case when pay_amount = 0 then crd_api_const_pkg.PAYMENT_STATUS_SPENT
                                     else status
                                end
             where id         = r.id;
             
            l_prepaid_amount := l_prepaid_amount - r.pay_amount;
            
            if l_prepaid_amount <= 0 then
                exit;
            end if;
        end loop;
        
    end if;
       
    -- floating billing period check 
    l_is_floating_period := 
        prd_api_product_pkg.get_attr_value_number(
            i_product_id    => i_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_attr_name     => crd_api_const_pkg.FLOATING_INVOICE_PERIOD
          , i_split_hash    => i_split_hash
          , i_service_id    => l_service_id
          , i_params        => l_param_tab
          , i_eff_date      => i_posting_date            
          , i_inst_id       => i_inst_id
        );
        
    if l_is_floating_period = com_api_const_pkg.TRUE then
        
        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id 
          , i_split_hash        => i_split_hash
          , o_prev_date         => l_prev_date
          , o_next_date         => l_next_date
        );
            
        if l_debt_amount > 0 then
    
            if l_next_date is null then
                fcl_api_cycle_pkg.switch_cycle(
                    i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
                  , i_product_id        => i_product_id
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id         => i_account_id
                  , i_params            => l_param_tab
                  , i_eff_date          => i_posting_date
                  , i_service_id        => l_service_id
                  , i_split_hash        => i_split_hash
                  , i_inst_id           => i_inst_id
                  , o_new_finish_date   => l_next_date
                );
            end if;
            
        end if;
        
        if l_next_date is null then    
            update crd_debt_vw
               set is_new      = com_api_const_pkg.FALSE
             where id          = l_debt_id;
        end if;
        
    end if;
    
    crd_cst_debt_pkg.debt_postprocess(
        i_debt_id           => l_debt_id
    );
    
end;

function check_operation_billing(
    i_oper_id   in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result            com_api_type_pkg.t_boolean;
begin
    select 1 as result
      into l_result
      from crd_debt d
         , crd_invoice_debt id
     where d.id = id.debt_id
       and d.oper_id = i_oper_id
       and rownum = 1;
    return com_api_type_pkg.TRUE;
exception 
    when no_data_found then
        return com_api_type_pkg.FALSE;
end;

end;
/
