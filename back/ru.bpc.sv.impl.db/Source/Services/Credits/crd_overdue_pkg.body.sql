create or replace package body crd_overdue_pkg as

procedure update_debt_aging(
    i_debt_id           in      com_api_type_pkg.t_long_id
  , i_invoice_aging     in      com_api_type_pkg.t_tiny_id
) is
    l_mad_sum               com_api_type_pkg.t_money;
begin
    select sum(min_amount_due)
      into l_mad_sum
      from crd_debt_balance
     where debt_id = i_debt_id;

    update crd_debt
       set aging_period = case when l_mad_sum = 0 then 0 else least (i_invoice_aging, aging_period + 1) end
     where id = i_debt_id;

end update_debt_aging;

procedure update_debt_aging(
    i_account_id        in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_aging_period      in      com_api_type_pkg.t_tiny_id
) is
begin
    for i in (
        select d.id debt_id
          from crd_debt d
         where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
           and d.split_hash = i_split_hash
        union
        select d.id debt_id
          from crd_debt d
         where decode(d.is_new, 1, d.account_id, null) = i_account_id
           and d.account_id = i_account_id
           and d.split_hash = i_split_hash
    )
    loop
        trc_log_pkg.debug('Update aging for debt_id=[' || i.debt_id || ']' || ' - Invoice aging [' || i_aging_period || ']');
        update_debt_aging(
            i_debt_id       => i.debt_id
          , i_invoice_aging => i_aging_period
        );
    end loop;
end;

procedure check_overdue(
    i_account_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) is
    l_account                   acc_api_type_pkg.t_account_rec;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_product_id                com_api_type_pkg.t_short_id;
    l_last_invoice              crd_api_type_pkg.t_invoice_rec;
    l_fee_id                    com_api_type_pkg.t_short_id;
    l_min_amount_due            com_api_type_pkg.t_money    := 0;
    l_min_amount_due_unpaid     com_api_type_pkg.t_money    := 0;
    l_debt_mad                  com_api_type_pkg.t_money;
    l_debt_mad_unpaid           com_api_type_pkg.t_money;
    l_debt_id_tab               com_api_type_pkg.t_number_tab;
    l_bunch_type_id_tab         com_api_type_pkg.t_number_tab;
    l_mad_tab                   com_api_type_pkg.t_number_tab;
    l_debt_id                   com_api_type_pkg.t_long_id;
    l_balance_type              com_api_type_pkg.t_dict_value;
    l_bunch_id                  com_api_type_pkg.t_long_id;
    l_tolerance_amount          com_api_type_pkg.t_money;
    l_service_id                com_api_type_pkg.t_short_id;
    l_total_payment_amount      com_api_type_pkg.t_money;
    l_aging_algorithm           com_api_type_pkg.t_dict_value;
    l_make_tad_equal_mad        com_api_type_pkg.t_boolean;
begin
    l_account :=
        acc_api_account_pkg.get_account(
            i_account_id  => i_account_id
          , i_mask_error  => com_api_const_pkg.FALSE
        );

    l_product_id :=
        prd_api_contract_pkg.get_contract(
            i_contract_id => l_account.contract_id
          , i_raise_error => com_api_const_pkg.TRUE
        ).product_id;

    l_service_id :=
        crd_api_service_pkg.get_active_service(
            i_account_id  => i_account_id
          , i_eff_date    => i_eff_date
          , i_split_hash  => l_account.split_hash
          , i_mask_error  => com_api_const_pkg.FALSE
        );

    l_last_invoice :=
        crd_invoice_pkg.get_last_invoice(
            i_account_id  => i_account_id
          , i_split_hash  => l_account.split_hash
        );

    l_aging_algorithm :=
        prd_api_product_pkg.get_attr_value_char(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.AGING_ALGORITHM
          , i_service_id        => l_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => l_account.split_hash
          , i_inst_id           => l_account.inst_id
          , i_mask_error        => com_api_const_pkg.FALSE
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => crd_api_const_pkg.ALGORITHM_AGING_DEFAULT
        );

    trc_log_pkg.debug(
        i_text       => 'check_overdue: l_last_invoice = {id [#1], invoice_date [#2], aging_period [#3]}'
                     || ', i_eff_date [#4], l_aging_algorithm [#5]'
      , i_env_param1 => l_last_invoice.id
      , i_env_param2 => to_char(l_last_invoice.invoice_date, com_api_const_pkg.DATE_FORMAT)
      , i_env_param3 => l_last_invoice.aging_period
      , i_env_param4 => to_char(i_eff_date, com_api_const_pkg.DATE_FORMAT)
      , i_env_param5 => l_aging_algorithm
    );

    select nvl(sum(amount), 0)
      into l_total_payment_amount
      from crd_payment p
     where decode(is_new, 1, account_id, null) = i_account_id
       and posting_date <= i_eff_date
       and split_hash  = l_account.split_hash
       and is_reversal = 0
       and not exists (select 1
                         from dpp_payment_plan
                        where reg_oper_id  = p.oper_id
                          and split_hash   = p.split_hash
                      );

    l_min_amount_due := l_last_invoice.min_amount_due;

    trc_log_pkg.debug(
        i_text       => 'l_total_payment_amount [#1], l_min_amount_due [#2]'
      , i_env_param1 => l_total_payment_amount
      , i_env_param2 => l_min_amount_due
    );

    if l_min_amount_due > l_total_payment_amount then
        -- Tolerance amount is a maximum part of MAD which is allowed not to be paid without starting overdue
        l_fee_id :=
            prd_api_product_pkg.get_fee_id(
                i_product_id    => l_product_id
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => i_account_id
              , i_fee_type      => crd_api_const_pkg.MAD_TOLERANCE_FEE_TYPE
              , i_service_id    => l_service_id
              , i_params        => l_param_tab
              , i_eff_date      => i_eff_date
              , i_split_hash    => l_account.split_hash
              , i_inst_id       => l_account.inst_id
            );

        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id        => l_fee_id
          , i_base_amount   => l_min_amount_due
          , i_base_currency => l_account.currency
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_eff_date      => i_eff_date
          , i_split_hash    => l_account.split_hash
          , io_fee_currency => l_account.currency
          , o_fee_amount    => l_tolerance_amount
        );

        l_tolerance_amount := round(l_tolerance_amount);
    else
        l_tolerance_amount := 0;
    end if;

    trc_log_pkg.debug('l_tolerance_amount [' || l_tolerance_amount || ']');

    -- Recalculate MAD if it is provided by MAD calculation algorithm
    crd_api_algo_proc_pkg.process_mad_when_overdue(
        i_account_id           => i_account_id
      , i_product_id           => l_product_id
      , i_service_id           => l_service_id
      , i_eff_date             => i_eff_date
      , i_invoice_id           => l_last_invoice.id
      , i_total_payment_amount => l_total_payment_amount
      , i_tolerance_amount     => l_tolerance_amount
      , io_mad                 => l_min_amount_due
      , o_make_tad_equal_mad   => l_make_tad_equal_mad
    );

    l_min_amount_due_unpaid := greatest(0, l_min_amount_due - l_total_payment_amount);

    trc_log_pkg.debug('l_min_amount_due_unpaid [' || l_min_amount_due_unpaid || ']');

    -- Correction of debt balances to make their total MAD equal to unrepaid portion of MAD,
    -- saving of unpaid amounts of MAD (by debts) into arrays to transfer to Overdue balance.
    -- MADs of debts with higher repayment priorities (or with earlier posting dates) will be set to 0.
    for r in (
        select x.min_amount_due
             , x.amount
             , x.debt_id
             , y.bunch_type_id
             , x.balance_type
             , x.card_id
             , x.balance_date
             , x.debt_intr_id
             , x.repay_priority
             , x.posting_date
             , x.debt_balance_id
             , x.posting_order
          from (
                select i.min_amount_due
                     , i.amount
                     , i.debt_id
                     , i.balance_type
                     , d.card_id
                     , i.balance_date
                     , i.id debt_intr_id
                     , b.repay_priority
                     , d.posting_date
                     , b.id debt_balance_id
                     , i.posting_order
                  from crd_debt_interest i
                     , crd_debt d
                     , crd_debt_balance b
                 where d.id in (select debt_id
                                  from crd_invoice_debt
                                 where invoice_id = l_last_invoice.id
                                   and split_hash = l_account.split_hash)
                   and i.debt_id = d.id
                   and i.split_hash = l_account.split_hash
                   and i.id between trunc(d.id, com_api_id_pkg.DAY_ROUNDING)
                                and trunc(d.id, com_api_id_pkg.DAY_ROUNDING) + com_api_id_pkg.DAY_TILL_ID
                   and i.balance_date >= l_last_invoice.invoice_date
                   and b.debt_id = d.id
                   and b.split_hash = l_account.split_hash
                   and b.id between trunc(d.id, com_api_id_pkg.DAY_ROUNDING)
                                and trunc(d.id, com_api_id_pkg.DAY_ROUNDING) + com_api_id_pkg.DAY_TILL_ID
                   and b.balance_type = i.balance_type
                   and nvl(i.is_waived, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
               ) x
             , (
                select e.bunch_type_id
                     , e.balance_type
                  from crd_event_bunch_type e
                 where e.inst_id      = l_account.inst_id
                   and e.event_type   = crd_api_const_pkg.OVERDUE_EVENT
               ) y
         where x.balance_type = y.balance_type(+)
      order by x.repay_priority desc
             , x.posting_date desc
             , x.debt_id
             , x.balance_type
             , x.balance_date desc
             , x.posting_order desc
    ) loop
        -- Actual MAD amount can be redefined by MAD calculation algorithm
        l_debt_mad := case
                          when l_make_tad_equal_mad = com_api_const_pkg.TRUE
                           and r.bunch_type_id is not null
                          then r.amount
                          else r.min_amount_due
                      end;

        trc_log_pkg.debug(
            i_text       => 'debt_id [#1][#2][#3], min_amount_due [#4], amount [#5]; l_debt_mad [#6]'
          , i_env_param1 => r.debt_id
          , i_env_param2 => r.balance_type
          , i_env_param3 => to_char(r.balance_date, 'dd.mm.yyyy')
          , i_env_param4 => r.min_amount_due
          , i_env_param5 => r.amount
          , i_env_param6 => l_debt_mad
        );

        if  l_debt_mad > 0
            and (l_debt_id is null or l_debt_id != r.debt_id or l_balance_type != r.balance_type)
        then
            l_debt_mad_unpaid := least(l_debt_mad, l_min_amount_due_unpaid);

            trc_log_pkg.debug(
                i_text       => 'l_min_amount_due_unpaid [#1], l_debt_mad_unpaid [#2]'
              , i_env_param1 => l_min_amount_due_unpaid
              , i_env_param2 => l_debt_mad_unpaid
            );

            if l_min_amount_due_unpaid > 0 then
                l_debt_id_tab(l_debt_id_tab.count + 1)             := r.debt_id;
                l_bunch_type_id_tab(l_bunch_type_id_tab.count + 1) := r.bunch_type_id;
                l_mad_tab(l_mad_tab.count + 1)                     := l_debt_mad_unpaid;
                trc_log_pkg.debug(
                    i_text       => 'Save amount No #1 for put_bunch(), bunch_type_id [#2]'
                  , i_env_param1 => l_mad_tab.count()
                  , i_env_param2 => r.bunch_type_id
                );
            end if;

            if  r.min_amount_due > l_min_amount_due_unpaid -- updating MADs (decrease) of fully/partially repaid debts
                or
                -- debt MAD should be changed due to MAD calculation algorithm
                (r.min_amount_due != l_debt_mad and r.min_amount_due < l_min_amount_due_unpaid)
            then
                trc_log_pkg.debug(
                    i_text       => 'update debt_intr_id [#1], debt_balance_id [#2]'
                  , i_env_param1 => r.debt_intr_id
                  , i_env_param2 => r.debt_balance_id
                );

                update crd_debt_interest
                   set min_amount_due = l_debt_mad_unpaid
                 where id = r.debt_intr_id;

                update crd_debt_balance
                   set min_amount_due = l_debt_mad_unpaid
                 where id = r.debt_balance_id;
            end if;

            l_min_amount_due_unpaid := greatest(0, l_min_amount_due_unpaid - l_debt_mad);
        end if;

        l_debt_id      := r.debt_id;
        l_balance_type := r.balance_type;
    end loop;

    if l_aging_algorithm = crd_api_const_pkg.ALGORITHM_AGING_DEFAULT then
        l_last_invoice.aging_period := l_last_invoice.aging_period + 1;
        update_debt_aging(
            i_account_id        => i_account_id
          , i_split_hash        => i_split_hash
          , i_aging_period      => l_last_invoice.aging_period
        );
    end if;

    if (l_min_amount_due - l_tolerance_amount) > l_total_payment_amount then
        -- if unpaid sum founded
        for i in 1..l_debt_id_tab.count loop
            l_debt_id := null;

            if l_debt_id is null or l_debt_id != l_debt_id_tab(i) then
                l_debt_id := l_debt_id_tab(i);
                l_param_tab.delete;

                crd_debt_pkg.load_debt_param (
                    i_debt_id           => l_debt_id
                  , i_split_hash        => l_account.split_hash
                  , io_param_tab        => l_param_tab
                );
            end if;

            if l_bunch_type_id_tab(i) is not null then
                acc_api_entry_pkg.put_bunch (
                    o_bunch_id          => l_bunch_id
                  , i_bunch_type_id     => l_bunch_type_id_tab(i)
                  , i_macros_id         => l_debt_id_tab(i)
                  , i_amount            => l_mad_tab(i)
                  , i_currency          => l_account.currency
                  , i_account_type      => l_account.account_type
                  , i_account_id        => i_account_id
                  , i_posting_date      => i_eff_date
                  , i_param_tab         => l_param_tab
                );
            end if;
        end loop;

        acc_api_entry_pkg.flush_job;

        l_debt_id := null;
        for i in 1..l_debt_id_tab.count loop
            if l_debt_id is null or l_debt_id != l_debt_id_tab(i) then
                crd_debt_pkg.set_balance(
                    i_debt_id           => l_debt_id_tab(i)
                  , i_account_id        => i_account_id
                  , i_service_id        => l_service_id
                  , i_inst_id           => l_account.inst_id
                  , i_eff_date          => i_eff_date
                  , i_split_hash        => l_account.split_hash
                  , i_is_overdue        => com_api_const_pkg.TRUE
                );
                crd_interest_pkg.set_interest(
                    i_debt_id           => l_debt_id_tab(i)
                  , i_eff_date          => i_eff_date
                  , i_account_id        => i_account_id
                  , i_service_id        => l_service_id
                  , i_split_hash        => l_account.split_hash
                  , i_event_type        => crd_api_const_pkg.OVERDUE_DATE_CYCLE_TYPE
                );
                l_debt_id := l_debt_id_tab(i);
            end if;
        end loop;

        -- registering Overdue event if unpaid sum founded
        evt_api_event_pkg.register_event (
            i_event_type   => crd_api_const_pkg.OVERDUE_EVENT
          , i_eff_date     => i_eff_date
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
          , i_inst_id      => l_account.inst_id
          , i_split_hash   => l_account.split_hash
          , i_param_tab    => l_param_tab
        );

        -- registering Aging events history
        if l_aging_algorithm = crd_api_const_pkg.ALGORITHM_AGING_DEFAULT then
            evt_api_event_pkg.register_event (
                i_event_type   => case l_last_invoice.aging_period
                                      when 1 then crd_api_const_pkg.AGING_1_EVENT -- EVNT1011
                                      when 2 then crd_api_const_pkg.AGING_2_EVENT -- EVNT1012
                                      when 3 then crd_api_const_pkg.AGING_3_EVENT -- EVNT1013
                                      when 4 then crd_api_const_pkg.AGING_4_EVENT -- EVNT1014
                                      when 5 then crd_api_const_pkg.AGING_5_EVENT -- EVNT1015
                                      when 6 then crd_api_const_pkg.AGING_6_EVENT -- EVNT1023
                                      when 7 then crd_api_const_pkg.AGING_7_EVENT -- EVNT1024
                                      when 8 then crd_api_const_pkg.AGING_8_EVENT -- EVNT1025
                                      when 9 then crd_api_const_pkg.AGING_9_EVENT -- EVNT1026
                                      when 10 then crd_api_const_pkg.AGING_10_EVENT -- EVNT1027
                                      when 11 then crd_api_const_pkg.AGING_11_EVENT -- EVNT1028
                                      when 12 then crd_api_const_pkg.AGING_12_EVENT -- EVNT1029
                                      when 13 then crd_api_const_pkg.AGING_13_EVENT -- EVNT1031
                                      else crd_api_const_pkg.AGING_1_EVENT
                                  end
              , i_eff_date     => i_eff_date
              , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => i_account_id
              , i_inst_id      => l_account.inst_id
              , i_split_hash   => l_account.split_hash
              , i_param_tab    => l_param_tab
            );
        end if;

    else
        update crd_invoice
           set is_mad_paid = com_api_const_pkg.TRUE
         where id          = l_last_invoice.id;

        evt_api_event_pkg.register_event(
            i_event_type   => crd_api_const_pkg.NON_OVERDUE_EVENT
          , i_eff_date     => i_eff_date
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
          , i_inst_id      => l_account.inst_id
          , i_split_hash   => l_account.split_hash
          , i_param_tab    => l_param_tab
        );
    end if;
end check_overdue;

procedure collect_penalty (
    i_account_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) is
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_product_id                com_api_type_pkg.t_short_id;
    l_last_invoice_id           com_api_type_pkg.t_medium_id;
    l_fee_id                    com_api_type_pkg.t_short_id;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_overdue_amount            com_api_type_pkg.t_money := 0;
    l_penalty_amount            com_api_type_pkg.t_money;
    l_due_period                number;
    l_overdue_date              date;
    l_penalty_date              date;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_customer_id               com_api_type_pkg.t_medium_id;
    l_account_number            com_api_type_pkg.t_account_number;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_oper_id                   com_api_type_pkg.t_long_id;

    l_account_type              com_api_type_pkg.t_dict_value;
    l_service_id                com_api_type_pkg.t_short_id;
    l_alg_calc_penalty          com_api_type_pkg.t_dict_value;
    l_charge_penalty            com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    select t.product_id
         , a.currency
         , a.inst_id
         , t.customer_id
         , a.account_number
         , a.account_type
         , a.split_hash
      into l_product_id
         , l_currency
         , l_inst_id
         , l_customer_id
         , l_account_number
         , l_account_type
         , l_split_hash
      from acc_account a
         , prd_contract t
     where a.id          = i_account_id
       and t.split_hash  = a.split_hash
       and a.contract_id = t.id;

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => l_split_hash
          , i_eff_date          => i_eff_date
          , i_inst_id           => l_inst_id
        );

    l_last_invoice_id :=
        crd_invoice_pkg.get_last_invoice_id(
            i_account_id    => i_account_id
          , i_split_hash    => l_split_hash
        );

    select overdue_date
         , penalty_date
      into l_overdue_date
         , l_penalty_date
      from crd_invoice
     where id = l_last_invoice_id;

    select nvl(sum(i.amount), 0)
      into l_overdue_amount
      from (
        select max(i.id) max_intr_id
             , i.balance_type
             , d.id debt_id
          from crd_debt_interest i
             , crd_debt d
         where d.id in (
               select debt_id
                 from crd_invoice_debt
                where invoice_id = l_last_invoice_id
                  and split_hash = l_split_hash
           )
           and i.debt_id       = d.id
           and i.split_hash    = l_split_hash
           and i.id      between trunc(d.id, com_api_id_pkg.DAY_ROUNDING) and trunc(d.id, com_api_id_pkg.DAY_ROUNDING) + com_api_id_pkg.DAY_TILL_ID
           and i.balance_type in (crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
                                , crd_api_const_pkg.BALANCE_TYPE_OVERDUE)
           and i.balance_date <= l_penalty_date
           and d.status        = crd_api_const_pkg.DEBT_STATUS_ACTIVE
         group by i.balance_type
             , d.id
        ) intr
        , crd_debt_interest i
    where intr.max_intr_id = i.id;

    if l_overdue_amount > 0 then

        l_charge_penalty :=
            prd_api_product_pkg.get_attr_value_number (
                i_product_id        => l_product_id
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => i_account_id
              , i_attr_name         => crd_api_const_pkg.CHARGE_PENALTY
              , i_params            => l_param_tab
              , i_eff_date          => i_eff_date
              , i_service_id        => l_service_id
              , i_split_hash        => l_split_hash
              , i_inst_id           => l_inst_id
            );
        trc_log_pkg.debug('l_charge_penalty=' || l_charge_penalty);

        if l_charge_penalty = com_api_const_pkg.TRUE then

            -- get penalty calculation algorithm
            begin
                l_alg_calc_penalty :=
                    prd_api_product_pkg.get_attr_value_char(
                        i_product_id    => l_product_id
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                      , i_attr_name     => crd_api_const_pkg.ALGORITHM_CALC_PENALTY
                      , i_split_hash    => l_split_hash
                      , i_service_id    => l_service_id
                      , i_params        => l_param_tab
                      , i_eff_date      => i_eff_date
                      , i_inst_id       => l_inst_id
                    );
            exception
                when com_api_error_pkg.e_application_error then
                    if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then
                        trc_log_pkg.debug('Attribute value [CRD_ALGORITHM_CALC_PENALTY] not defined. Set algorithm = PLTA0010');
                        l_alg_calc_penalty := crd_api_const_pkg.ALG_CALC_PENALTY_PLAIN_FEE;
                    else
                        raise;

                    end if;
                when others then
                    trc_log_pkg.debug('Get attribute value error. '||sqlerrm);
                    raise;
            end;
            trc_log_pkg.debug('l_alg_calc_intr=' || l_alg_calc_penalty);

            case l_alg_calc_penalty
            when crd_api_const_pkg.ALG_CALC_PENALTY_PLAIN_FEE then
                l_fee_id :=
                    prd_api_product_pkg.get_fee_id (
                        i_product_id    => l_product_id
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                      , i_fee_type      => crd_api_const_pkg.PENALTY_RATE_FEE_TYPE
                      , i_params        => l_param_tab
                      , i_eff_date      => i_eff_date
                      , i_service_id    => l_service_id
                      , i_split_hash    => l_split_hash
                      , i_inst_id       => l_inst_id
                    );

                select floor(i_eff_date - min(posting_date))
                  into l_due_period
                  from crd_debt d
                 where d.id in (select debt_id from crd_invoice_debt where invoice_id = l_last_invoice_id)
                   and d.status     = crd_api_const_pkg.DEBT_STATUS_ACTIVE;

                fcl_api_fee_pkg.get_fee_amount(
                    i_fee_id            => l_fee_id
                  , i_base_amount       => l_overdue_amount
                  , i_base_currency     => l_currency
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id         => i_account_id
                  , i_eff_date          => i_eff_date
                  , i_calc_period       => l_due_period
                  , i_split_hash        => l_split_hash
                  , io_fee_currency     => l_currency
                  , o_fee_amount        => l_penalty_amount
                );

                l_penalty_amount := round(l_penalty_amount);

                opr_api_create_pkg.create_operation (
                    io_oper_id          => l_oper_id
                  , i_is_reversal       => com_api_const_pkg.FALSE
                  , i_oper_type         => opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
                  , i_oper_reason       => crd_api_const_pkg.PENALTY_RATE_FEE_TYPE
                  , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                  , i_status            => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                  , i_status_reason     => null
                  , i_sttl_type         => opr_api_const_pkg.SETTLEMENT_INTERNAL_INTRAINST
                  , i_oper_count        => 1
                  , i_oper_amount       => l_penalty_amount
                  , i_oper_currency     => l_currency
                  , i_oper_date         => i_eff_date
                  , i_host_date         => i_eff_date
                );

                opr_api_create_pkg.add_participant(
                    i_oper_id               => l_oper_id
                  , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                  , i_oper_type             => opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
                  , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
                  , i_host_date             => i_eff_date
                  , i_inst_id               => l_inst_id
                  , i_customer_id           => l_customer_id
                  , i_account_id            => i_account_id
                  , i_account_number        => l_account_number
                  , i_split_hash            => l_split_hash
                  , i_without_checks        => com_api_const_pkg.TRUE
                );

            else
                crd_cst_overdue_pkg.collect_penalty(
                    i_account_id        => i_account_id
                  , i_account_number    => l_account_number
                  , i_inst_id           => l_inst_id
                  , i_split_hash        => l_split_hash
                  , i_service_id        => l_service_id
                  , i_product_id        => l_product_id
                  , i_customer_id       => l_customer_id
                  , i_last_invoice_id   => l_last_invoice_id
                  , i_eff_date          => i_eff_date
                  , i_overdue_date      => l_overdue_date
                  , i_overdue_amount    => l_overdue_amount
                  , i_currency          => l_currency
                  , i_alg_calc_penalty  => l_alg_calc_penalty
                );

            end case;

        end if;
    end if;
end;

procedure debt_in_collection(
    i_account_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
)is
    l_bunch_id              com_api_type_pkg.t_long_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_currency              com_api_type_pkg.t_curr_code;
    l_debt_id_tab           com_api_type_pkg.t_number_tab;
    l_debt_added            com_api_type_pkg.t_boolean;
    l_account_type          com_api_type_pkg.t_dict_value;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_service_id            com_api_type_pkg.t_short_id;

begin
    trc_log_pkg.debug('debt_in_collecttion Start');

    begin
        select a.currency
             , a.account_type
             , a.inst_id
          into l_currency
             , l_account_type
             , l_inst_id
          from acc_account a
         where a.id = i_account_id;

    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ACCOUNT_NOT_FOUND'
              , i_env_param1    => i_account_id
            );
    end;

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => i_split_hash
          , i_eff_date          => i_eff_date
          , i_inst_id           => l_inst_id
        );

    for r in(
        select d.id debt_id
             , e.bunch_type_id
             , b.amount
             , b.balance_type
             , d.macros_type_id
             , d.card_id
          from crd_debt d
             , crd_debt_balance b
             , crd_event_bunch_type e
         where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
           and d.id           = b.debt_id
           and b.amount       > 0
           and e.balance_type = b.balance_type
           and e.inst_id      = d.inst_id
           and e.event_type   = crd_api_const_pkg.DEBT_IN_COLLECTION_EVENT
           and e.bunch_type_id is not null
           and d.split_hash   = i_split_hash
           and b.split_hash   = i_split_hash
           and b.id >= trunc(d.id, com_api_id_pkg.DAY_ROUNDING)
       )
    loop
        rul_api_param_pkg.set_param (
            i_name       => 'CARD_TYPE_ID'
            , io_params  => l_param_tab
            , i_value    => iss_api_card_pkg.get_card(i_card_id => r.card_id).card_type_id
        );
        acc_api_entry_pkg.put_bunch (
            o_bunch_id          => l_bunch_id
          , i_bunch_type_id     => r.bunch_type_id
          , i_macros_id         => r.debt_id
          , i_amount            => r.amount
          , i_currency          => l_currency
          , i_account_type      => l_account_type
          , i_account_id        => i_account_id
          , i_posting_date      => i_eff_date
          , i_macros_type_id    => r.macros_type_id
          , i_param_tab         => l_param_tab
        );

        l_debt_added := com_api_const_pkg.FALSE;
        for i in 1..l_debt_id_tab.count loop
            if l_debt_id_tab(i) = r.debt_id then
                l_debt_added := com_api_const_pkg.TRUE;
                exit;
            end if;
        end loop;

        if l_debt_added = com_api_const_pkg.FALSE then
            l_debt_id_tab(l_debt_id_tab.count + 1) := r.debt_id;
        end if;

    end loop;

    acc_api_entry_pkg.flush_job;

    trc_log_pkg.debug('Update debts');

    for i in 1..l_debt_id_tab.count loop
        crd_debt_pkg.set_balance(
            i_debt_id           => l_debt_id_tab(i)
          , i_eff_date          => i_eff_date
          , i_account_id        => i_account_id
          , i_service_id        => l_service_id
          , i_inst_id           => l_inst_id
          , i_split_hash        => i_split_hash
        );

        crd_interest_pkg.set_interest(
            i_debt_id           => l_debt_id_tab(i)
          , i_eff_date          => i_eff_date
          , i_account_id        => i_account_id
          , i_service_id        => l_service_id
          , i_split_hash        => i_split_hash
          , i_event_type        => crd_api_const_pkg.DEBT_IN_COLLECTION_EVENT
        );

       update crd_debt set status = crd_api_const_pkg.DEBT_STATUS_COLLECT
        where id = l_debt_id_tab(i);

    end loop;

    trc_log_pkg.debug('debt_in_collecttion End');
end;

procedure block_card(
    i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) is
begin
    null;
end block_card;

procedure zero_limit(
    i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) is
begin
    null;
end zero_limit;

procedure check_mad_aging_indebtedness(
    i_account_id        in      com_api_type_pkg.t_account_id
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.check_mad_aging_indebtedness';

    l_last_invoice_rec          crd_api_type_pkg.t_invoice_rec;
    l_account_rec               acc_api_type_pkg.t_account_rec;
    l_mad_fact_amount           com_api_type_pkg.t_money;
    l_mad_fact_date             date;
    l_aging_total_sum           com_api_type_pkg.t_money := 0;
    l_mad_debt_amount           com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_account_id [#1]'
      , i_env_param1 => i_account_id
    );

    l_account_rec :=
        acc_api_account_pkg.get_account(
            i_account_id => i_account_id
          , i_mask_error => com_api_const_pkg.FALSE
        );

    l_last_invoice_rec :=
        crd_invoice_pkg.get_last_invoice(
            i_account_id => l_account_rec.account_id
          , i_split_hash => l_account_rec.split_hash
          , i_mask_error => com_api_const_pkg.TRUE
        );

    if l_last_invoice_rec.id is not null then
        if nvl(l_last_invoice_rec.is_mad_paid, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            crd_utl_pkg.get_mad_payment_data(
                i_invoice_id       => l_last_invoice_rec.id
              , o_mad_payment_date => l_mad_fact_date
              , o_mad_payment_sum  => l_mad_fact_amount
            );
            if l_mad_fact_amount is null then
                com_api_error_pkg.raise_error(
                    i_error      => 'MAD_NOT_PAID'
                  , i_env_param1 => l_last_invoice_rec.min_amount_due
                  , i_env_param2 => l_last_invoice_rec.id
                  , i_env_param3 => l_account_rec.account_number
                );
            end if;
        end if;

        if nvl(l_last_invoice_rec.aging_period, 0) > 0 then
            for i in (
                select d.id debt_id
                  from crd_debt d
                     , crd_invoice_debt id
                 where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_rec.account_id
                   and d.split_hash = l_account_rec.split_hash
                   and id.invoice_id = d.id
                   and id.invoice_id <> l_last_invoice_rec.id
                union
                select d.id debt_id
                  from crd_debt d
                     , crd_invoice_debt id
                 where decode(d.is_new, 1, d.account_id, null) = l_account_rec.account_id
                   and d.account_id = l_account_rec.account_id
                   and d.split_hash = l_account_rec.split_hash
                   and id.invoice_id = d.id
                   and id.invoice_id <> l_last_invoice_rec.id
            )
            loop
                select sum(min_amount_due)
                  into l_mad_debt_amount
                  from crd_debt_balance
                 where debt_id = i.debt_id;
                l_aging_total_sum := l_aging_total_sum + l_mad_debt_amount;
            end loop;

            if l_aging_total_sum > 0 then
                com_api_error_pkg.raise_error(
                    i_error      => 'FOUND_AGING_INDEBTEDNESS'
                  , i_env_param1 => l_last_invoice_rec.aging_period
                  , i_env_param2 => l_aging_total_sum
                  , i_env_param3 => l_account_rec.account_number
                );
            end if;
        end if;
    end if;
end check_mad_aging_indebtedness;

procedure reduce_credit_limit(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date                           default null
  , i_shift_fee_date    in      com_api_type_pkg.t_tiny_id     default 0
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.reduce_credit_limit: ';
    l_fee_type                      com_api_type_pkg.t_dict_value;
    l_fee_id                        com_api_type_pkg.t_long_id;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_eff_date                      date;
    l_eff_fee_date                  date;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_account_rec                   acc_api_type_pkg.t_account_rec;
    l_fee_amount                    com_api_type_pkg.t_money;
    l_aval_balance                  com_api_type_pkg.t_money;

    l_param_tab                     com_api_type_pkg.t_param_tab;
    l_new_account_status            com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'received - account_id [#1] eff_date [#2] shift_fee_date [#3]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_eff_date
      , i_env_param3 => i_shift_fee_date
    );
    l_eff_date     := coalesce(i_eff_date, trunc(get_sysdate));
    l_eff_fee_date := l_eff_date + nvl(i_shift_fee_date, 0);
    l_fee_type     := crd_api_const_pkg.LIMIT_VALUE_FEE_TYPE;
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'start with params - eff_date [#1] eff_fee_date [#2] limit_type [#3]'
      , i_env_param1 => l_eff_date
      , i_env_param2 => l_eff_fee_date
      , i_env_param3 => l_fee_type
    );
    l_account_rec := acc_api_account_pkg.get_account(
                         i_account_id => i_account_id
                       , i_mask_error => com_api_const_pkg.FALSE
                     );
    if l_account_rec.status = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE then
        l_aval_balance :=
            acc_api_balance_pkg.get_aval_balance_amount_only(
                i_account_id => i_account_id
            );
        l_product_id :=
            prd_api_product_pkg.get_product_id(
                i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id   => i_account_id
            );
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => i_account_id
              , i_attr_name         => null
              , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
              , i_split_hash        => l_account_rec.split_hash
              , i_eff_date          => l_eff_date
              , i_inst_id           => l_account_rec.inst_id
            );
        l_fee_id :=
            prd_api_product_pkg.get_fee_id (
                i_product_id    => l_product_id
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => i_account_id
              , i_fee_type      => l_fee_type
              , i_params        => l_param_tab
              , i_eff_date      => l_eff_fee_date
              , i_service_id    => l_service_id
              , i_split_hash    => l_account_rec.split_hash
              , i_inst_id       => l_account_rec.inst_id
            );
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_fee_id
          , i_base_amount       => 0
          , i_base_currency     => l_account_rec.currency
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_eff_date          => l_eff_fee_date
          , i_split_hash        => l_account_rec.split_hash
          , io_fee_currency     => l_account_rec.currency
          , o_fee_amount        => l_fee_amount
        );

        if l_aval_balance >= l_fee_amount then
            opr_api_create_pkg.create_operation (
                io_oper_id          => l_oper_id
              , i_is_reversal       => com_api_const_pkg.FALSE
              , i_oper_type         => crd_api_const_pkg.OPERATION_TYPE_REDUCE_LIMIT
              , i_oper_reason       => crd_api_const_pkg.LIMIT_VALUE_FEE_TYPE
              , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
              , i_status            => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
              , i_status_reason     => null
              , i_sttl_type         => opr_api_const_pkg.SETTLEMENT_INTERNAL_INTRAINST
              , i_oper_count        => 1
              , i_oper_amount       => l_fee_amount
              , i_oper_currency     => l_account_rec.currency
              , i_oper_date         => l_eff_date
              , i_host_date         => l_eff_date
            );
            opr_api_create_pkg.add_participant(
                i_oper_id               => l_oper_id
              , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
              , i_oper_type             => crd_api_const_pkg.OPERATION_TYPE_REDUCE_LIMIT
              , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
              , i_host_date             => l_eff_date
              , i_inst_id               => l_account_rec.inst_id
              , i_customer_id           => l_account_rec.customer_id
              , i_account_id            => i_account_id
              , i_account_number        => l_account_rec.account_number
              , i_split_hash            => l_account_rec.split_hash
              , i_without_checks        => com_api_const_pkg.TRUE
            );
        else
            l_new_account_status := acc_api_const_pkg.ACCOUNT_STATUS_CREDITS;
            acc_api_account_pkg.set_account_status(
                i_account_id => i_account_id
              , i_status     => l_new_account_status
            );
        end if;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_ACCOUNT_STATUS'
          , i_env_param1 => l_account_rec.status
        );
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'finish success - operation_id [#1] account_status [#2]'
      , i_env_param1 => l_oper_id
      , i_env_param2 => nvl(l_new_account_status, l_account_rec.status)
    );
end reduce_credit_limit;

begin
    null;
end crd_overdue_pkg;
/
