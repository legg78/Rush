create or replace package body crd_cst_cfc_payment_pkg as

procedure load_payment_param(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , io_param_tab        in out  com_api_type_pkg.t_param_tab
) is
begin
    for rec in (
        select p.is_reversal
             , p.posting_date
             , o.oper_date
             , o.oper_type
             , o.sttl_type
             , p.sttl_day
             , p.currency
             , p.amount
             , p.is_new
             , p.inst_id
          from crd_payment p
             , opr_operation o
         where p.id = i_payment_id
           and p.oper_id = o.id
    ) loop
        rul_api_param_pkg.set_param (
            io_params           => io_param_tab
            , i_name            => 'IS_REVERSAL'
            , i_value           => rec.is_reversal
        );
        rul_api_param_pkg.set_param (
            io_params           => io_param_tab
            , i_name            => 'POSTING_DATE'
            , i_value           => rec.posting_date
        );
        rul_api_param_pkg.set_param (
            io_params           => io_param_tab
            , i_name            => 'OPER_DATE'
            , i_value           => rec.oper_date
        );
        rul_api_param_pkg.set_param (
            io_params           => io_param_tab
            , i_name            => 'OPER_TYPE'
            , i_value           => rec.oper_type
        );
        rul_api_param_pkg.set_param (
            io_params           => io_param_tab
            , i_name            => 'STTL_TYPE'
            , i_value           => rec.sttl_type
        );
        rul_api_param_pkg.set_param (
            io_params           => io_param_tab
            , i_name            => 'STTL_DAY'
            , i_value           => rec.sttl_day
        );
        rul_api_param_pkg.set_param (
            io_params           => io_param_tab
            , i_name            => 'CURRENCY'
            , i_value           => rec.currency
        );
        rul_api_param_pkg.set_param (
            io_params           => io_param_tab
            , i_name            => 'AMOUNT'
            , i_value           => rec.amount
        );
        rul_api_param_pkg.set_param (
            io_params           => io_param_tab
            , i_name            => 'IS_NEW'
            , i_value           => rec.is_new
        );
        rul_api_param_pkg.set_param (
            io_params           => io_param_tab
            , i_name            => 'INST_ID'
            , i_value           => rec.inst_id
        );
        exit;
    end loop;
end;

procedure apply_balance_payment(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , i_balance_type      in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , o_remainder_amount     out  com_api_type_pkg.t_money
) is
    l_account_id            com_api_type_pkg.t_account_id;
    l_payment_amount        com_api_type_pkg.t_money;
    l_currency              com_api_type_pkg.t_curr_code;
    l_debt_id_tab           com_api_type_pkg.t_number_tab;
    l_debt_added            com_api_type_pkg.t_boolean;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_bunch_type_id         com_api_type_pkg.t_tiny_id;
    l_original_oper_id      com_api_type_pkg.t_long_id;
    l_bunch_id              com_api_type_pkg.t_long_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_payment_condition     com_api_type_pkg.t_dict_value;
    l_use_own_funds         com_api_type_pkg.t_boolean;
    l_account_type          com_api_type_pkg.t_dict_value;
    l_service_id            com_api_type_pkg.t_short_id;
    l_unpaid_debt           com_api_type_pkg.t_money;
    l_product_id            com_api_type_pkg.t_short_id;
    l_repay_mad_first       com_api_type_pkg.t_boolean;
    l_is_tad_paid           com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_is_mad_paid           com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_penalty_date          date;
    l_charge_interest       com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE;
    l_tad_paid_amount       com_api_type_pkg.t_money := 0;
    l_mad_paid_amount       com_api_type_pkg.t_money := 0;
    l_debt_id               com_api_type_pkg.t_long_id;
    l_credit_balance_type   com_api_type_pkg.t_dict_value;
    l_debit_balance_type    com_api_type_pkg.t_dict_value;
    l_reg_mad_event         com_api_type_pkg.t_boolean;
    l_invoice               crd_api_type_pkg.t_invoice_rec;

    l_cur_debts             com_api_type_pkg.t_ref_cur;
    l_debt_rec              crd_api_type_pkg.t_payment_debt_rec;
    l_query                 com_api_type_pkg.t_text := '
        select d.id debt_id
             , e.bunch_type_id
             , case when d.is_new = 1 or :l_repay_mad_first = 0 then b.amount
                    when iteration = 1 then b.min_amount_due
                    else b.amount - b.min_amount_due
               end amount
             , case when iteration = 2 and :l_repay_mad_first = 1 then 0
                    else nvl(b.min_amount_due, 0)
               end min_amount_due
             , b.balance_type
             , d.macros_type_id
             , d.card_id
             , iteration
          from crd_debt d
             , crd_debt_balance b
             , crd_event_bunch_type e
             , (select rownum iteration from dual connect by rownum <= 2)
         where decode(d.status, ''DBTSACTV'', d.account_id, null) = :l_account_id
           and d.id           = b.debt_id
           and b.amount       > 0
           and e.balance_type = b.balance_type
           and e.balance_type = :i_balance_type
           and e.inst_id      = d.inst_id
           and e.event_type   = ''EVNT1003''
           and e.bunch_type_id is not null
           and d.split_hash   = :i_split_hash
           and b.split_hash   = :i_split_hash
           and b.id          >= trunc(d.id, -10)
           and not (iteration = 2 and b.amount = b.min_amount_due and d.is_new = 0 and :l_repay_mad_first = 1)
           and not (iteration = 1 and (d.is_new = 1 or :l_repay_mad_first = 0))
           and (
                (:l_original_oper_id = d.oper_id)
                or
                (:l_payment_condition = ''RPCD0001'')
                or
                (
                 :l_payment_condition = ''RPCD0002''
                 and
                 d.is_new = 0
                )
                or
                (
                 :l_payment_condition = ''RPCD0003''
                 and
                 d.is_new = 0
                 and
                 exists (
                         select null
                           from crd_invoice a
                              , crd_invoice_debt c
                          where c.debt_id    = d.id
                            and c.invoice_id = a.id
                            and :i_eff_date between a.invoice_date and a.penalty_date
                        )
               ))';
    l_order_by              com_api_type_pkg.t_text :=
        ' order by decode(:l_original_oper_id, d.oper_id, 0, 1, 1), iteration, b.repay_priority, d.posting_date';
begin
    trc_log_pkg.debug('apply_payment: payment id=['||i_payment_id||'] effective date=['||i_eff_date||'] split hash=['||i_split_hash||']');

    begin
        select p.account_id
             , p.currency
             , p.pay_amount
             , p.inst_id
             , p.original_oper_id
             , a.account_type
             , c.product_id
          into l_account_id
             , l_currency
             , l_payment_amount
             , l_inst_id
             , l_original_oper_id
             , l_account_type
             , l_product_id
          from crd_payment p
             , acc_account a
             , prd_contract c
         where p.id         = i_payment_id
           and p.split_hash = i_split_hash
           and a.id         = p.account_id
           and c.id         = a.contract_id;
    exception
        when no_data_found then
            trc_log_pkg.error('apply_payment: payment not found');
            raise;
    end;

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => i_split_hash
          , i_eff_date          => i_eff_date
          , i_inst_id           => l_inst_id
        );

    load_payment_param(
        i_payment_id    => i_payment_id
      , io_param_tab    => l_param_tab
    );

    begin
        l_charge_interest :=
            nvl(
                prd_api_product_pkg.get_attr_value_number(
                    i_product_id    => l_product_id
                  , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => l_account_id
                  , i_attr_name     => crd_api_const_pkg.CHARGE_INTR_BEFORE_PAYMENT
                  , i_split_hash    => i_split_hash
                  , i_service_id    => l_service_id
                  , i_params        => l_param_tab
                  , i_eff_date      => i_eff_date
                  , i_inst_id       => l_inst_id
                )
              , com_api_const_pkg.TRUE
            );
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then
                trc_log_pkg.debug('Attribute value [CRD_CHARGE_INTR_BEFORE_PAYMENT] not defined. Set attribute = 1');
                l_charge_interest := com_api_const_pkg.TRUE;
            else
                raise;
            end if;
        when others then
            trc_log_pkg.debug('Get attribute value error. ' || sqlerrm);
            raise;
    end;
    trc_log_pkg.debug('l_charge_interest=' || l_charge_interest);

    if l_charge_interest = com_api_const_pkg.TRUE then
        crd_interest_pkg.charge_interest(
            i_account_id        => l_account_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
        );
    end if;

    l_payment_condition :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id    => l_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => l_account_id
          , i_attr_name     => crd_api_const_pkg.PAYMENT_CONDITION
          , i_params        => l_param_tab
          , i_eff_date      => i_eff_date
          , i_service_id    => l_service_id
          , i_split_hash    => i_split_hash
          , i_inst_id       => l_inst_id
        );

    l_repay_mad_first :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id    => l_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => l_account_id
          , i_attr_name     => crd_api_const_pkg.REPAY_MAD_FIRST
          , i_params        => l_param_tab
          , i_eff_date      => i_eff_date
          , i_service_id    => l_service_id
          , i_split_hash    => i_split_hash
          , i_inst_id       => l_inst_id
        );

    -- User-exit allows either to open a custom cursor or to modify the cursor query
    crd_cst_payment_pkg.enum_debt_order(
        io_cur_debts        => l_cur_debts
      , io_query            => l_query
      , io_order_by         => l_order_by
      , i_account_id        => l_account_id
      , i_split_hash        => i_split_hash
      , i_product_id        => l_product_id
      , i_service_id        => l_service_id
      , i_inst_id           => l_inst_id
      , i_eff_date          => i_eff_date
      , i_original_oper_id  => l_original_oper_id
      , i_payment_condition => l_payment_condition
      , i_repay_mad_first   => l_repay_mad_first
    );

    if not l_cur_debts%isopen then
        open l_cur_debts for l_query || l_order_by
        using l_repay_mad_first
          , l_repay_mad_first
          , l_account_id
          , i_balance_type
          , i_split_hash
          , i_split_hash
          , l_repay_mad_first
          , l_repay_mad_first
          , l_original_oper_id
          , l_payment_condition
          , l_payment_condition
          , l_payment_condition
          , i_eff_date
          , l_original_oper_id;
    end if;

    loop
        fetch l_cur_debts
         into l_debt_rec;

        exit when l_cur_debts%notfound;

        trc_log_pkg.debug('apply_payment: pay debt=['||l_debt_rec.debt_id||'] balance type=['||l_debt_rec.balance_type||'] amount=['||l_debt_rec.amount||']');

        if l_debt_id is null or l_debt_id != l_debt_rec.debt_id then

            l_debt_id := l_debt_rec.debt_id;
            l_param_tab.delete;

            crd_debt_pkg.load_debt_param (
                i_debt_id           => l_debt_id
              , i_split_hash        => i_split_hash
              , io_param_tab        => l_param_tab
            );
        end if;

        acc_api_entry_pkg.put_bunch (
            o_bunch_id          => l_bunch_id
          , i_bunch_type_id     => l_debt_rec.bunch_type_id
          , i_macros_id         => l_debt_rec.debt_id
          , i_amount            => least(l_payment_amount, l_debt_rec.amount)
          , i_currency          => l_currency
          , i_account_type      => l_account_type
          , i_account_id        => l_account_id
          , i_posting_date      => i_eff_date
          , i_macros_type_id    => l_debt_rec.macros_type_id
          , i_param_tab         => l_param_tab
        );

        l_debt_added := com_api_const_pkg.FALSE;
        for i in 1..l_debt_id_tab.count loop
            if l_debt_id_tab(i) = l_debt_rec.debt_id then
                l_debt_added := com_api_const_pkg.TRUE;
                exit;
            end if;
        end loop;

        if l_debt_added = com_api_const_pkg.FALSE then
            l_debt_id_tab(l_debt_id_tab.count + 1) := l_debt_rec.debt_id;
        end if;

        insert into crd_debt_payment(
            id
          , debt_id
          , balance_type
          , pay_id
          , pay_amount
          , eff_date
          , split_hash
          , bunch_id
          , pay_mandatory_amount
        ) values (
            com_api_id_pkg.get_id(crd_debt_payment_seq.nextval, l_debt_rec.debt_id)
          , l_debt_rec.debt_id
          , l_debt_rec.balance_type
          , i_payment_id
          , least(l_payment_amount, l_debt_rec.amount)
          , i_eff_date
          , i_split_hash
          , l_bunch_id
          , least(l_payment_amount, l_debt_rec.min_amount_due)
        );

        if l_debt_rec.iteration = 1 then
            l_mad_paid_amount := l_mad_paid_amount + least(l_payment_amount, l_debt_rec.amount);
        elsif l_debt_rec.min_amount_due > 0 and l_payment_amount > l_debt_rec.min_amount_due then
            l_mad_paid_amount := l_mad_paid_amount + least(l_payment_amount, l_debt_rec.min_amount_due);
        end if;

        l_tad_paid_amount := l_tad_paid_amount + least(l_payment_amount, l_debt_rec.amount);

        l_payment_amount := l_payment_amount - l_debt_rec.amount;

        trc_log_pkg.debug('apply_payment: payment amount=['||l_payment_amount||']');

        exit when l_payment_amount <= 0;
    end loop;

    close l_cur_debts;

    acc_api_entry_pkg.flush_job;

    for i in 1..l_debt_id_tab.count loop
        crd_debt_pkg.change_debt(
            i_debt_id           => l_debt_id_tab(i)
          , i_eff_date          => i_eff_date
          , i_account_id        => l_account_id
          , i_service_id        => l_service_id
          , i_inst_id           => l_inst_id
          , i_split_hash        => i_split_hash
          , i_event_type        => crd_api_const_pkg.APPLY_PAYMENT_EVENT
          , o_unpaid_debt       => l_unpaid_debt
        );
    end loop;

    if l_payment_amount > 0 then
        -- Save the rest of payment because it may be used in custom functional
        l_param_tab.delete;

        l_use_own_funds :=
            prd_api_product_pkg.get_attr_value_number(
                i_product_id    => l_product_id
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => l_account_id
              , i_attr_name     => crd_api_const_pkg.USE_OWN_FUNDS
              , i_params        => l_param_tab
              , i_eff_date      => i_eff_date
              , i_service_id    => l_service_id
              , i_split_hash    => i_split_hash
              , i_inst_id       => l_inst_id
            );

        if l_use_own_funds = com_api_const_pkg.TRUE then
            -- transfer payment remainder to ledger balance
            trc_log_pkg.debug('apply_payment: move payment amount to ledger');
            begin
                select e.bunch_type_id
                  into l_bunch_type_id
                  from crd_event_bunch_type e
                 where e.inst_id      = l_inst_id
                   and e.event_type   = crd_api_const_pkg.OVERPAYMENT_EVENT
                   and rownum         = 1;

                -- check balance types of l_bunch_type_id. If they are same we don't need to transfer remainder to Ledger
                select min(case when balance_impact = -1 then balance_type else null end) debit_balance_type
                     , min(case when balance_impact = 1 then balance_type else null end) credit_balance_type
                  into l_credit_balance_type
                     , l_debit_balance_type
                  from acc_entry_tpl t
                 where t.bunch_type_id = l_bunch_type_id;

                trc_log_pkg.debug('apply_payment: l_bunch_type_id [' || l_bunch_type_id || '], l_credit_balance_type [' || l_credit_balance_type || '], l_debit_balance_type [' || l_debit_balance_type || ']');

                if l_credit_balance_type is not null
                    and l_debit_balance_type is not null
                    and l_credit_balance_type != l_debit_balance_type
                then
                    acc_api_entry_pkg.put_bunch (
                        o_bunch_id          => l_bunch_id
                      , i_bunch_type_id     => l_bunch_type_id
                      , i_macros_id         => i_payment_id
                      , i_amount            => l_payment_amount
                      , i_currency          => l_currency
                      , i_account_type      => l_account_type
                      , i_account_id        => l_account_id
                      , i_posting_date      => i_eff_date
                      , i_param_tab         => l_param_tab
                    );

                    acc_api_entry_pkg.flush_job;

                    l_payment_amount := 0;
                end if;
            exception
                when no_data_found then
                    null;
            end;
        end if;

        l_is_tad_paid := com_api_const_pkg.TRUE;
        l_is_mad_paid := com_api_const_pkg.TRUE;

    else
        select case when count(1) > 0 then com_api_const_pkg.FALSE else com_api_const_pkg.TRUE end
             , case when sum(b.min_amount_due) > 0 then com_api_const_pkg.FALSE else com_api_const_pkg.TRUE end
          into l_is_tad_paid
             , l_is_mad_paid
          from crd_debt d
             , crd_debt_balance b
             , crd_event_bunch_type e
         where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_id
           and d.id           = b.debt_id
           and b.amount       > 0
           and e.balance_type = b.balance_type
           and e.inst_id      = d.inst_id
           and e.event_type   = crd_api_const_pkg.APPLY_PAYMENT_EVENT
           and d.split_hash   = i_split_hash
           and b.split_hash   = i_split_hash;
    end if;

    trc_log_pkg.debug(
        i_text       => 'apply_payment: l_is_mad_paid [#1], l_is_tad_paid [#2]'
      , i_env_param1 => l_is_mad_paid
      , i_env_param2 => l_is_tad_paid
    );

    update crd_payment
       set pay_amount = greatest(0, l_payment_amount)
         , status     = case when greatest(0, l_payment_amount) = 0 then crd_api_const_pkg.PAYMENT_STATUS_SPENT
                             else status
                        end
     where id         = i_payment_id;

    if l_is_mad_paid = com_api_const_pkg.TRUE and l_mad_paid_amount > 0 then

        select max(penalty_date)
          into l_penalty_date
          from crd_invoice
         where id = crd_invoice_pkg.get_last_invoice_id(l_account_id, i_split_hash, com_api_type_pkg.TRUE);
         
        l_reg_mad_event :=
            prd_api_product_pkg.get_attr_value_number(
                i_product_id        => l_product_id
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => l_account_id
              , i_attr_name         => crd_api_const_pkg.REG_MAD_EVNT_IN_PENALTY_PERIOD
              , i_params            => l_param_tab
              , i_eff_date          => i_eff_date
              , i_service_id        => l_service_id
              , i_split_hash        => i_split_hash
              , i_inst_id           => l_inst_id
              , i_mask_error        => com_api_const_pkg.TRUE
              , i_use_default_value => com_api_const_pkg.TRUE
              , i_default_value     => null
            );
        
        if (l_penalty_date is not null and l_penalty_date >= i_eff_date)
         or l_reg_mad_event = com_api_const_pkg.TRUE then
            evt_api_event_pkg.register_event(
                i_event_type            => crd_api_const_pkg.MAD_REPAYMENT_EVENT
              , i_eff_date              => i_eff_date
              , i_entity_type           => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id             => l_account_id
              , i_inst_id               => l_inst_id
              , i_split_hash            => i_split_hash
              , i_param_tab             => l_param_tab
            );
        end if;
    end if;

    if l_is_tad_paid = com_api_const_pkg.TRUE and l_tad_paid_amount > 0 then
        -- filled parameter INVOICE_AGING_PERIOD
        l_invoice :=
            crd_invoice_pkg.get_last_invoice(
                i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => l_account_id
              , i_split_hash   => i_split_hash
              , i_mask_error   => com_api_const_pkg.TRUE
            );
        rul_api_param_pkg.set_param(
            io_params  => l_param_tab
          , i_name     => 'INVOICE_AGING_PERIOD'
          , i_value    => nvl(l_invoice.aging_period, 0)
        );
    
        evt_api_event_pkg.register_event(
            i_event_type            => crd_api_const_pkg.TAD_REPAYMENT_EVENT
          , i_eff_date              => i_eff_date
          , i_entity_type           => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id             => l_account_id
          , i_inst_id               => l_inst_id
          , i_split_hash            => i_split_hash
          , i_param_tab             => l_param_tab
        );
    end if;

    crd_payment_pkg.cancel_invoice(
        i_account_id        => l_account_id
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_service_id        => l_service_id
    );

    o_remainder_amount := greatest(l_payment_amount, 0);

exception
    when others then
        if l_cur_debts%isopen then
            close l_cur_debts;
        end if;

        raise;
end apply_balance_payment;

end;
/
