create or replace package body crd_invoice_pkg as

g_invoice                       crd_api_type_pkg.t_invoice_rec;

procedure switch_aging_cycle(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_eff_date          in      date
  , i_due_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_aging_algorithm   in      com_api_type_pkg.t_dict_value
  , i_aging_period      in      com_api_type_pkg.t_tiny_id
  , i_mad_amount        in      com_api_type_pkg.t_money
)
is
    l_aging_date                date;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_cycle_id                  com_api_type_pkg.t_short_id;
begin
    if i_aging_period = 0 then
        rul_api_param_pkg.set_param(
            i_value            => i_aging_period
          , i_name             => 'AGING_PERIOD'
          , io_params          => l_param_tab
        );

        trc_log_pkg.debug('switch_aging_cycle: aging_algorithm=[' || i_aging_algorithm || ']');

        if nvl(i_aging_algorithm, crd_api_const_pkg.ALGORITHM_AGING_INDEPENDENT) = crd_api_const_pkg.ALGORITHM_AGING_INDEPENDENT then
            if i_mad_amount <> 0 then
                fcl_api_cycle_pkg.switch_cycle(
                    i_cycle_type        => crd_api_const_pkg.AGING_PERIOD_CYCLE_TYPE
                  , i_product_id        => i_product_id
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id         => i_account_id
                  , i_params            => l_param_tab
                  , i_service_id        => i_service_id
                  , i_start_date        => i_due_date
                  , i_eff_date          => i_eff_date
                  , i_split_hash        => i_split_hash
                  , i_inst_id           => i_inst_id
                  , o_new_finish_date   => l_aging_date
                );
            end if;
        else
            l_cycle_id :=
                prd_api_product_pkg.get_attr_value_number(
                    i_product_id        => i_product_id
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id         => i_account_id
                  , i_attr_name         => crd_api_const_pkg.ZERO_PERIOD
                  , i_params            => l_param_tab
                  , i_service_id        => i_service_id
                  , i_eff_date          => i_eff_date
                  , i_split_hash        => i_split_hash
                  , i_inst_id           => i_inst_id
                  , i_use_default_value => com_api_const_pkg.TRUE
                  , i_default_value     => null
                );
            if l_cycle_id is not null then
                fcl_api_cycle_pkg.switch_cycle(
                    i_cycle_type        => crd_api_const_pkg.ZERO_PERIOD_CYCLE
                  , i_product_id        => i_product_id
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id         => i_account_id
                  , i_params            => l_param_tab
                  , i_service_id        => i_service_id
                  , i_start_date        => i_eff_date
                  , i_eff_date          => i_eff_date
                  , i_split_hash        => i_split_hash
                  , i_inst_id           => i_inst_id
                  , o_new_finish_date   => l_aging_date
                  , i_test_mode         => fcl_api_const_pkg.ATTR_MISS_IGNORE
                  , i_cycle_id          => l_cycle_id
                );
            end if;
        end if;

        trc_log_pkg.debug(
            i_text       => 'l_aging_date [#1]'
          , i_env_param1 => l_aging_date
        );
    end if;
end;

procedure switch_aging_cycle(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
)
is
    l_stop_aging_event          com_api_type_pkg.t_dict_value;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_aging_algorithm           com_api_type_pkg.t_dict_value;
    l_aging_event               com_api_type_pkg.t_dict_value;
    l_invoice                   crd_api_type_pkg.t_invoice_rec;
    l_service_id                com_api_type_pkg.t_short_id;
    l_product_id                com_api_type_pkg.t_short_id;
    l_aging_date                date;

    function aging_counter_is_reset(
        i_account_id        in      com_api_type_pkg.t_account_id
      , i_split_hash        in      com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_boolean
    is
        l_prev_date                 date;
        l_next_date                 date;
    begin
        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type   => crd_api_const_pkg.AGING_PERIOD_CYCLE_TYPE
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
          , i_split_hash   => i_split_hash
          , i_add_counter  => com_api_const_pkg.FALSE
          , o_prev_date    => l_prev_date
          , o_next_date    => l_next_date
        );
        -- Cycle AGING_PERIOD_CYCLE_TYPE is NOT repeatable, therefore both dates <o_prev_date> and
        -- <o_next_date> can be null if a cycle counter doesn't exists (or has been removed earlier)
        return com_api_type_pkg.to_bool(l_prev_date is null and l_next_date is null);
    end;

begin
    trc_log_pkg.debug('switch_aging_cycle: i_account_id=[' || i_account_id || '] i_eff_date=[' || i_eff_date || '] i_split_hash=[' || i_split_hash || ']');

    l_invoice :=
        get_last_invoice(
            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_split_hash    => i_split_hash
          , i_mask_error    => com_api_const_pkg.FALSE
        );

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => i_split_hash
          , i_eff_date          => i_eff_date
          , i_inst_id           => l_invoice.inst_id
        );

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => i_account_id
          , i_eff_date    => i_eff_date
          , i_inst_id     => l_invoice.inst_id
        );

    l_aging_algorithm :=
        prd_api_product_pkg.get_attr_value_char(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.AGING_ALGORITHM
          , i_service_id        => l_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
          , i_inst_id           => l_invoice.inst_id
          , i_mask_error        => com_api_type_pkg.FALSE
          , i_use_default_value => com_api_type_pkg.TRUE
          , i_default_value     => crd_api_const_pkg.ALGORITHM_AGING_DEFAULT
        );

    trc_log_pkg.debug(
        i_text          => 'invoice_id [#1], aging_algorithm [#2], aging_period [#3]'
      , i_env_param1    => l_invoice.id
      , i_env_param2    => l_aging_algorithm
      , i_env_param3    => l_invoice.aging_period
    );

    if  l_aging_algorithm = crd_api_const_pkg.ALGORITHM_AGING_INDEPENDENT
        -- Aging cycle counter can be reset from rule reset_aging_period only;
        -- but if it is reset earlier, and this cycle event is being processed after this,
        -- switching should be ignored.
        -- It may happen for some specific priority of processing event by the billing process, e.g.:
        -- a) switching cycles (+ generating of aging period event);
        -- b) checking for overdue (here aging period may be reset by non-overdue event);
        -- c) processing aging event (it is current procedure, aging period may be increased despite
        --    of the fact that it has been reset on the previous step (b)).
        and aging_counter_is_reset(
                i_account_id  => i_account_id
              , i_split_hash  => i_split_hash
            ) = com_api_const_pkg.FALSE
    then
        l_invoice.aging_period := l_invoice.aging_period + 1;

        update_invoice_aging(
            i_invoice_id   => l_invoice.id
          , i_aging_period => l_invoice.aging_period
        );

        add_aging_history(
            i_invoice     => l_invoice
          , i_eff_date    => i_eff_date
        );

        calculate_agings(
            i_account_id        => i_account_id
          , i_invoice_id        => l_invoice.id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
          , i_aging_algorithm   => l_aging_algorithm
        );

        crd_overdue_pkg.update_debt_aging(
            i_account_id        => i_account_id
          , i_split_hash        => i_split_hash
          , i_aging_period      => l_invoice.aging_period
        );

        rul_api_param_pkg.set_param(
            i_value            => l_invoice.aging_period
          , i_name             => 'AGING_PERIOD'
          , io_params          => l_param_tab
        );

        -- get aging event type for specific aging period
        l_aging_event :=
            prd_api_product_pkg.get_attr_value_char(
                i_product_id        => l_product_id
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => i_account_id
              , i_attr_name         => crd_api_const_pkg.AGING_EVENT_TYPE
              , i_params            => l_param_tab
              , i_service_id        => l_service_id
              , i_eff_date          => i_eff_date
              , i_split_hash        => i_split_hash
              , i_inst_id           => l_invoice.inst_id
            );

        l_stop_aging_event :=
            prd_api_product_pkg.get_attr_value_char(
                i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => i_account_id
              , i_attr_name         => crd_api_const_pkg.STOP_AGING_EVENT
              , i_service_id        => l_service_id
              , i_eff_date          => i_eff_date
              , i_split_hash        => i_split_hash
              , i_inst_id           => l_invoice.inst_id
              , i_mask_error        => com_api_type_pkg.FALSE
            );

        trc_log_pkg.debug(
            i_text          => 'l_aging_event [#1] l_stop_aging_event [#2]'
          , i_env_param1    => l_aging_event
          , i_env_param2    => l_stop_aging_event
        );

        if l_aging_event <> l_stop_aging_event then
            fcl_api_cycle_pkg.switch_cycle(
                i_cycle_type        => crd_api_const_pkg.AGING_PERIOD_CYCLE_TYPE
              , i_product_id        => l_product_id
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => i_account_id
              , i_params            => l_param_tab
              , i_service_id        => l_service_id
              , i_start_date        => i_eff_date
              , i_eff_date          => i_eff_date
              , i_split_hash        => i_split_hash
              , i_inst_id           => l_invoice.inst_id
              , o_new_finish_date   => l_aging_date
            );

            trc_log_pkg.debug(
                i_text          => 'Next l_aging_date [#1]'
              , i_env_param1    => l_aging_date
            );
        end if;

        evt_api_event_pkg.register_event(
            i_event_type   => l_aging_event
          , i_eff_date     => i_eff_date
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
          , i_inst_id      => l_invoice.inst_id
          , i_split_hash   => i_split_hash
          , i_param_tab    => l_param_tab
        );
    end if;
end;

procedure update_invoice_aging(
    i_invoice_id        in      com_api_type_pkg.t_medium_id
  , i_aging_period      in      com_api_type_pkg.t_tiny_id
) is
begin
    update crd_invoice i
       set i.aging_period = i_aging_period
     where i.id = i_invoice_id;
end;

procedure add_aging_history(
    i_invoice     in      crd_api_type_pkg.t_invoice_rec
  , i_eff_date    in      date
) as
begin
    insert into crd_aging (
        id
      , invoice_id
      , aging_period
      , aging_date
      , aging_amount
      , split_hash
    ) values (
        com_api_id_pkg.get_id(crd_aging_seq.nextval, i_eff_date)
      , i_invoice.id
      , i_invoice.aging_period
      , i_eff_date
      , i_invoice.total_amount_due
      , i_invoice.split_hash
    );
end;

procedure calculate_agings(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_invoice_id        in      com_api_type_pkg.t_medium_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_aging_algorithm   in      com_api_type_pkg.t_dict_value default null
) is
    l_aging_amount      com_api_type_pkg.t_money;
    l_total_amount      com_api_type_pkg.t_money;
    l_invoice           crd_api_type_pkg.t_invoice_rec;
begin
    if i_aging_algorithm = crd_api_const_pkg.ALGORITHM_AGING_INDEPENDENT then
        l_invoice := get_invoice(i_invoice_id => i_invoice_id);
        if l_invoice.aging_period = 0 then
            add_aging_history(
                i_invoice   => l_invoice
              , i_eff_date  => i_eff_date
            );
        end if;
    else
        for r in (
            select (min_amount_due - overdue_amount) curr_amount
                 , total_amount_due
                 , serial_number
                 , invoice_id
                 , rownum - 1 aging_period
              from (
                    select sum(c.amount) overdue_amount
                         , d.min_amount_due
                         , d.total_amount_due
                         , d.serial_number
                         , d.id invoice_id
                      from crd_invoice_debt a
                         , crd_event_bunch_type b
                         , crd_debt_interest c
                         , crd_invoice d
                     where b.event_type = crd_api_const_pkg.AGING_EVENT
                       and b.balance_type = c.balance_type
                       and c.id = a.debt_intr_id
                       and a.invoice_id = d.id
                       and d.account_id = i_account_id
                       and d.split_hash = i_split_hash
                     group by d.id, d.serial_number, d.min_amount_due, d.total_amount_due
                     order by d.serial_number desc
                   )
        ) loop
            if r.aging_period = 0 then
                l_total_amount := r.total_amount_due;
            end if;

            l_aging_amount := least(l_total_amount, r.curr_amount);

            insert into crd_aging (
                id
              , invoice_id
              , aging_period
              , aging_date
              , aging_amount
              , split_hash
            ) values (
                com_api_id_pkg.get_id(crd_aging_seq.nextval, i_eff_date)
              , i_invoice_id
              , r.aging_period
              , i_eff_date
              , l_aging_amount
              , i_split_hash
            );

            l_total_amount := l_total_amount - r.curr_amount;

            exit when l_total_amount <= 0;

        end loop;
    end if;
end;

/*
 * Function returns minimum MAD, if a minimum threshold is specified and incoming MAD is under this threshold.
 */
function get_min_mad(
    i_mandatory_amount_due  in            com_api_type_pkg.t_money
  , i_total_amount_due      in            com_api_type_pkg.t_money
  , i_account_id            in            com_api_type_pkg.t_medium_id
  , i_eff_date              in            date
  , i_currency              in            com_api_type_pkg.t_curr_code
  , i_product_id            in            com_api_type_pkg.t_short_id
  , i_service_id            in            com_api_type_pkg.t_short_id
  , i_param_tab             in out nocopy com_api_type_pkg.t_param_tab
  , i_split_hash            in            com_api_type_pkg.t_tiny_id       default null
  , i_inst_id               in            com_api_type_pkg.t_inst_id       default null
) return com_api_type_pkg.t_money
is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_min_mad ';
    l_fee_id                com_api_type_pkg.t_short_id;
    l_currency              com_api_type_pkg.t_curr_code := i_currency;
    l_fee_amount            com_api_type_pkg.t_money;
    l_minimum_amount_due    com_api_type_pkg.t_money;
    l_total_amount_due      com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_account_id [#1], i_mandatory_amount_due [#2], i_total_amount_due [#3]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_mandatory_amount_due
      , i_env_param3 => i_total_amount_due
    );

    l_total_amount_due := nvl(i_total_amount_due, 0);

    l_fee_id :=
        prd_api_product_pkg.get_fee_id(
            i_product_id     => i_product_id
          , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id      => i_account_id
          , i_fee_type       => crd_api_const_pkg.MINIMUM_MAD_FEE_TYPE
          , i_params         => i_param_tab
          , i_service_id     => i_service_id
          , i_eff_date       => i_eff_date
          , i_split_hash     => i_split_hash
          , i_inst_id        => i_inst_id
        );

    l_fee_amount := round(
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id         => l_fee_id
          , i_base_amount    => l_total_amount_due
          , io_base_currency => l_currency
          , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id      => i_account_id
          , i_eff_date       => i_eff_date
        )
    );

    l_minimum_amount_due := least(greatest(i_mandatory_amount_due, l_fee_amount), l_total_amount_due);

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> l_minimum_amount_due [#1], l_fee_amount [#2]'
      , i_env_param1 => l_minimum_amount_due
      , i_env_param2 => l_fee_amount
    );

    return l_minimum_amount_due;
end;

/*
 * Function returns MAD threshold.
 */
function get_mad_threshold(
    i_account               in     acc_api_type_pkg.t_account_rec
  , i_product_id            in     com_api_type_pkg.t_short_id
  , i_service_id            in     com_api_type_pkg.t_short_id
  , i_params                in     com_api_type_pkg.t_param_tab
  , i_eff_date              in     date
) return com_api_type_pkg.t_money
is
    l_threshold_fee_id             com_api_type_pkg.t_short_id;
    l_threshold_amount             com_api_type_pkg.t_money;
    l_currency                     com_api_type_pkg.t_curr_code;
begin
    l_threshold_fee_id :=
        prd_api_product_pkg.get_fee_id(
            i_product_id      => i_product_id
          , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id       => i_account.account_id
          , i_fee_type        => crd_api_const_pkg.MAD_THRESHOLD_FEE_TYPE
          , i_params          => i_params
          , i_service_id      => i_service_id
          , i_eff_date        => i_eff_date
          , i_split_hash      => i_account.split_hash
          , i_mask_error      => com_api_const_pkg.TRUE
        );
    l_currency := i_account.currency;
    l_threshold_amount :=
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id          => l_threshold_fee_id
          , i_base_amount     => 0
          , io_base_currency  => l_currency
          , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id       => i_account.account_id
          , i_split_hash      => i_account.split_hash
          , i_eff_date        => i_eff_date
        );

    trc_log_pkg.debug(
        i_text       => 'MAD threshold: [#1]'
      , i_env_param1 => l_threshold_amount
    );

    return l_threshold_amount;
exception
    when com_api_error_pkg.e_application_error then
        return 0;
end get_mad_threshold;

/*
 * Procedure calculates difference between actual MAD (i_mandatory_amount_due) and new MAD (i_modified_mad),
 * then it redistibutes this difference (+/-) among all debts in order of repayment priority.
 */
procedure recalculate_mad(
    i_invoice_id            in      com_api_type_pkg.t_medium_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_mandatory_amount_due  in      com_api_type_pkg.t_money
  , i_modified_mad          in      com_api_type_pkg.t_money
  , i_update_invoice        in      com_api_type_pkg.t_boolean
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.recalculate_mad ';
    l_calc_amount                   com_api_type_pkg.t_money    := 0;
    l_min_amount_due                com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_invoice_id [#1], i_split_hash [#2], i_update_invoice [#5]'
                                   ||  ', i_mandatory_amount_due (source) [#3], i_modified_mad (new) [#4]'
      , i_env_param1 => i_invoice_id
      , i_env_param2 => i_split_hash
      , i_env_param3 => i_mandatory_amount_due
      , i_env_param4 => i_modified_mad
      , i_env_param5 => i_update_invoice
    );

    l_calc_amount := i_modified_mad - i_mandatory_amount_due;

    trc_log_pkg.debug(
        i_text       => 'l_calc_amount (difference) [#1]'
      , i_env_param1 => l_calc_amount
    );

    if i_mandatory_amount_due < i_modified_mad then
        for r in (
            select b.min_amount_due
                 , b.amount
                 , b.id
                 , b.debt_intr_id
              from crd_debt_balance b
                 , crd_invoice_debt i
                 , crd_debt d
             where i.invoice_id   = i_invoice_id
               and b.debt_intr_id = i.debt_intr_id
               and b.amount       > 0
               and b.split_hash   = i_split_hash
               and i.split_hash   = i_split_hash
               and i.debt_id      = d.id
               and i.debt_id      = b.debt_id
               and b.id between trunc(i.debt_id, com_api_id_pkg.DAY_ROUNDING)
                            and trunc(i.debt_id, com_api_id_pkg.DAY_ROUNDING) + com_api_id_pkg.DAY_TILL_ID
             order by
                   b.repay_priority
                 , d.posting_date
        ) loop
            update crd_debt_balance
               set min_amount_due = least(amount, min_amount_due + l_calc_amount)
             where id = r.id
            returning min_amount_due into l_min_amount_due;

            update crd_debt_interest
               set min_amount_due = least(amount, min_amount_due + l_calc_amount)
             where id = r.debt_intr_id;

            l_calc_amount := l_calc_amount - (r.amount - r.min_amount_due);

            trc_log_pkg.debug(
                i_text       => 'crd_debt_balance: id [#1], debt_intr_id [#2], amount [#3]'
                             || ', min_amount_due [#4]=>[#5]; l_calc_amount [#6]'
              , i_env_param1 => r.id
              , i_env_param2 => r.debt_intr_id
              , i_env_param3 => r.amount
              , i_env_param4 => r.min_amount_due
              , i_env_param5 => l_min_amount_due
              , i_env_param6 => l_calc_amount
            );

            exit when l_calc_amount <= 0;
        end loop;

    elsif i_mandatory_amount_due > i_modified_mad then
        for r in (
            select b.min_amount_due
                 , b.amount
                 , b.id
                 , b.debt_intr_id
              from crd_debt_balance b
                 , crd_invoice_debt i
                 , crd_debt d
             where i.invoice_id   = i_invoice_id
               and b.debt_intr_id = i.debt_intr_id
               and b.amount       > 0
               and b.split_hash   = i_split_hash
               and i.split_hash   = i_split_hash
               and d.id           = i.debt_id
               and i.debt_id      = d.id
               and i.debt_id      = b.debt_id
               and b.id between trunc(i.debt_id, com_api_id_pkg.DAY_ROUNDING)
                            and trunc(i.debt_id, com_api_id_pkg.DAY_ROUNDING) + com_api_id_pkg.DAY_TILL_ID
             order by
                   b.repay_priority desc
                 , d.posting_date
        ) loop
            update crd_debt_balance
               set min_amount_due = greatest(0, min_amount_due + l_calc_amount)
             where id = r.id
            returning min_amount_due into l_min_amount_due;

            update crd_debt_interest
               set min_amount_due = greatest(0, min_amount_due + l_calc_amount)
             where id = r.debt_intr_id;

            l_calc_amount := l_calc_amount + r.min_amount_due;

            trc_log_pkg.debug(
                i_text       => 'crd_debt_balance: id [#1], debt_intr_id [#2], amount [#3]'
                             || ', min_amount_due [#4]=>[#5]; l_calc_amount [#6]'
              , i_env_param1 => r.id
              , i_env_param2 => r.debt_intr_id
              , i_env_param3 => r.amount
              , i_env_param4 => r.min_amount_due
              , i_env_param5 => l_min_amount_due
              , i_env_param6 => l_calc_amount
            );

            exit when l_calc_amount >= 0;
        end loop;
    end if;

    if i_modified_mad != i_mandatory_amount_due and i_update_invoice = com_api_const_pkg.TRUE then
        update crd_invoice
           set min_amount_due = i_modified_mad
         where id             = i_invoice_id
           and split_hash     = i_split_hash;
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> l_calc_amount [#1]'
      , i_env_param1 => l_calc_amount
    );
end recalculate_mad;

procedure create_invoice(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_calculate_apr     in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
    l_account                    acc_api_type_pkg.t_account_rec;
    l_invoice_id                 com_api_type_pkg.t_medium_id;
    l_last_invoice               crd_api_type_pkg.t_invoice_rec;
    l_param_tab                  com_api_type_pkg.t_param_tab;
    l_fee_id                     com_api_type_pkg.t_short_id;
    l_product_id                 com_api_type_pkg.t_short_id;
    l_mandatory_amount_due       com_api_type_pkg.t_money    := 0;
    l_modified_mad               com_api_type_pkg.t_money    := 0;
    l_total_amount_due           com_api_type_pkg.t_money    := 0;
    l_calc_amount                com_api_type_pkg.t_money    := 0;
    l_own_funds                  com_api_type_pkg.t_money    := 0;
    l_exceed_limit               com_api_type_pkg.t_amount_rec;
    l_penalty_date               date;
    l_grace_date                 date;
    l_due_date                   date;
    l_next_date                  date;
    l_overdue_date               date;
    l_aging_period               com_api_type_pkg.t_tiny_id;
    l_serial_number              com_api_type_pkg.t_tiny_id;
    l_ledger_amount              com_api_type_pkg.t_amount_rec;
    l_repay_priority             com_api_type_pkg.t_tiny_id;
    l_service_id                 com_api_type_pkg.t_short_id;
    l_from_id                    com_api_type_pkg.t_long_id;
    l_till_id                    com_api_type_pkg.t_long_id;
    l_interest_start_date        com_api_type_pkg.t_dict_value;
    l_date_type                  com_api_type_pkg.t_dict_value;

    l_agent_number               com_api_type_pkg.t_name;
    l_postal_code                com_api_type_pkg.t_name;
    l_aval_balance               com_api_type_pkg.t_amount_rec;
    l_balances                   com_api_type_pkg.t_amount_by_name_tab;
    l_debt_id_tab                com_api_type_pkg.t_number_tab;
    l_is_new_tab                 com_api_type_pkg.t_number_tab;
    l_status_tab                 com_api_type_pkg.t_dict_tab;
    cu_active_debts              com_api_type_pkg.t_ref_cur;

    l_waive_interest_amount      com_api_type_pkg.t_money    := 0;
    l_interest_amount            com_api_type_pkg.t_money    := 0;
    l_payment_amount             com_api_type_pkg.t_money    := 0;
    l_expense_amount             com_api_type_pkg.t_money    := 0;
    l_fee_amount                 com_api_type_pkg.t_money    := 0;
    l_last_entry_id              com_api_type_pkg.t_long_id;
    l_oper_type_tab              com_api_type_pkg.t_dict_tab;
    l_debt_amount_tab            com_api_type_pkg.t_money_tab;

    l_overlimit_balance          com_api_type_pkg.t_money    := 0;
    l_overdue_balance            com_api_type_pkg.t_money    := 0;
    l_overdue_intr_balance       com_api_type_pkg.t_money    := 0;
    l_overdraft_balance          com_api_type_pkg.t_money    := 0;
    l_hold_balance               com_api_type_pkg.t_money    := 0;
    l_interest_balance           com_api_type_pkg.t_money    := 0;

    l_irr                        com_api_type_pkg.t_money    := 0;
    l_apr                        com_api_type_pkg.t_money    := 0;
    l_send_blank_statement       com_api_type_pkg.t_boolean;
    l_aging_algorithm            com_api_type_pkg.t_dict_value;
    l_delivery_statement_method  com_api_type_pkg.t_dict_value;
    l_use_current_balance        com_api_type_pkg.t_boolean;

    procedure get_interest_amount(
        i_account_id        in     com_api_type_pkg.t_account_id
      , i_split_hash        in     com_api_type_pkg.t_tiny_id
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , o_interest_amount      out com_api_type_pkg.t_money
    ) is
        l_last_invoice_id          com_api_type_pkg.t_medium_id;
    begin
        l_last_invoice_id :=
            get_last_invoice_id(
                i_account_id    => i_account_id
              , i_split_hash    => i_split_hash
              , i_mask_error    => com_api_const_pkg.TRUE
            );

        if l_last_invoice_id is not null then
            begin
                select last_entry_id
                  into l_last_entry_id
                  from crd_invoice
                 where id = l_last_invoice_id;
            exception
                when no_data_found then
                    null;
            end;
        end if;

        trc_log_pkg.debug('create_invoice: l_last_entry_id=['||l_last_entry_id||']');

        select nvl(abs(sum(e.amount * e.balance_impact)), 0)
          into o_interest_amount
          from acc_entry e
             , acc_bunch b
         where e.account_id  = i_account_id
           and e.split_hash  = i_split_hash
           and b.id          = e.bunch_id
           and (l_last_entry_id is null or e.id > l_last_entry_id)
           and (e.balance_type, b.bunch_type_id) in (
                   select p.balance_type, p.bunch_type_id
                     from crd_event_bunch_type t
                        , acc_entry_tpl p
                    where t.bunch_type_id = p.bunch_type_id
                      and t.event_type    = crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
                      and t.inst_id       = i_inst_id
                    union
                   select p.balance_type, p.bunch_type_id
                     from crd_event_bunch_type t
                        , acc_entry_tpl p
                    where t.add_bunch_type_id = p.bunch_type_id
                      and t.event_type        = crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
                      and t.inst_id           = i_inst_id
           );
    end get_interest_amount;

    /*
     * Function returns true if event EVNT1018 should be generated
     */
    function generate_inv_creation_event(
        i_account_id        in     com_api_type_pkg.t_account_id
      , i_split_hash        in     com_api_type_pkg.t_tiny_id
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_currency          in     com_api_type_pkg.t_curr_code
      , i_product_id        in     com_api_type_pkg.t_short_id
      , i_service_id        in     com_api_type_pkg.t_short_id
      , i_params            in     com_api_type_pkg.t_param_tab
      , i_eff_date          in     date
      , i_total_amount_due  in     com_api_type_pkg.t_money
    ) return com_api_type_pkg.t_boolean
    is
        l_threshold_fee_id         com_api_type_pkg.t_short_id;
        l_threshold                com_api_type_pkg.t_money;
        l_result                   com_api_type_pkg.t_boolean;
        l_currency                 com_api_type_pkg.t_curr_code;
    begin
        begin
            l_threshold_fee_id :=
                prd_api_product_pkg.get_fee_id(
                    i_product_id      => i_product_id
                  , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id       => i_account_id
                  , i_fee_type        => crd_api_const_pkg.CRD_INV_CREATE_THRSHD_FEE_TYPE
                  , i_params          => i_params
                  , i_service_id      => i_service_id
                  , i_eff_date        => i_eff_date
                  , i_split_hash      => i_split_hash
                  , i_inst_id         => i_inst_id
                  , i_mask_error      => com_api_const_pkg.TRUE
                );

            l_currency := i_currency;

            l_threshold :=
                fcl_api_fee_pkg.get_fee_amount(
                    i_fee_id          => l_threshold_fee_id
                  , i_base_amount     => 0
                  , io_base_currency  => l_currency
                  , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id       => i_account_id
                  , i_eff_date        => i_eff_date
                );

            l_result := case
                            when nvl(i_total_amount_due, 0) < nvl(l_threshold, 0)
                            then com_api_const_pkg.FALSE
                            else com_api_const_pkg.TRUE
                        end;
        exception
            when com_api_error_pkg.e_application_error then
                l_result := com_api_const_pkg.TRUE;
        end;

        trc_log_pkg.debug(
            i_text       => 'Check if need to generate the event Credit invoice creation ENVT1018: #1'
          , i_env_param1 => case l_result when com_api_const_pkg.TRUE then 'yes' else 'no' end
        );

        return l_result;
    end generate_inv_creation_event;

    function get_waived_interest_amount(
        i_account_id            in      com_api_type_pkg.t_account_id
      , i_split_hash            in      com_api_type_pkg.t_tiny_id
      , i_inst_id               in      com_api_type_pkg.t_inst_id
      , i_invoice_id            in      com_api_type_pkg.t_medium_id
      , i_product_id            in      com_api_type_pkg.t_short_id
      , i_service_id            in      com_api_type_pkg.t_short_id
    )
    return com_api_type_pkg.t_money
    is
        l_interest_amount               com_api_type_pkg.t_money;
        l_alg_calc_intr                 com_api_type_pkg.t_dict_value;
        l_round_precision               com_api_type_pkg.t_tiny_id;
    begin
        l_alg_calc_intr :=
            prd_api_product_pkg.get_attr_value_char(
                i_product_id        => i_product_id
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => i_account_id
              , i_attr_name         => crd_api_const_pkg.ALGORITHM_CALC_INTEREST
              , i_split_hash        => i_split_hash
              , i_service_id        => i_service_id
              , i_params            => l_param_tab
              , i_eff_date          => i_eff_date
              , i_inst_id           => i_inst_id
              , i_use_default_value => com_api_const_pkg.TRUE
              , i_default_value     => crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
            );

        l_round_precision := case l_alg_calc_intr
                                 when crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM
                                 then 0
                                 else 4
                             end;

        select nvl(sum(round(interest_amount)), 0)
          into l_interest_amount
          from (
            select round(sum(c.interest_amount), l_round_precision) as interest_amount
              from (
                       select d.inst_id
                            , i.balance_type
                            , i.interest_amount
                         from crd_debt_interest i
                            , crd_debt d
                        where i.invoice_id      = i_invoice_id
                          and i.split_hash      = i_split_hash
                          and i.is_waived       = com_api_const_pkg.TRUE
                          and d.id              = i.debt_id
                          and d.split_hash      = i.split_hash
                          and d.account_id      = i_account_id
                   ) c
                 , crd_event_bunch_type b
             where b.event_type(+)   = crd_api_const_pkg.WAIVE_INTEREST_CYCLE_TYPE
               and b.balance_type(+) = c.balance_type
               and b.inst_id(+)      = c.inst_id
             group by b.id             -- Need rounding by crd_event_bunch_type.id
        );

        return l_interest_amount;
    end;

begin
    trc_log_pkg.debug('create_invoice: i_account_id=['||i_account_id||'] i_eff_date=['||i_eff_date||'] i_split_hash=['||i_split_hash||']');

    l_account      := acc_api_account_pkg.get_account(
                          i_account_id  => i_account_id
                        , i_mask_error  => com_api_const_pkg.FALSE
                      );
    l_product_id   := prd_api_contract_pkg.get_contract(
                          i_contract_id => l_account.contract_id
                        , i_raise_error => com_api_const_pkg.TRUE
                      ).product_id;
    l_service_id   := crd_api_service_pkg.get_active_service(
                          i_account_id  => i_account_id
                        , i_eff_date    => i_eff_date
                        , i_split_hash  => i_split_hash
                        , i_mask_error  => com_api_const_pkg.FALSE
                      );
    l_last_invoice := get_last_invoice(
                          i_account_id  => i_account_id
                        , i_split_hash  => i_split_hash
                        , i_mask_error  => com_api_const_pkg.TRUE
                      );

    if l_last_invoice.id is null then
        select o.start_date
          into l_last_invoice.invoice_date
          from prd_service_object o
         where o.service_id  = l_service_id
           and o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and o.object_id   = i_account_id
           and o.split_hash  = i_split_hash;
    end if;

    get_interest_amount(
        i_account_id         => i_account_id
      , i_split_hash         => i_split_hash
      , i_inst_id            => l_account.inst_id
      , o_interest_amount    => l_interest_amount
    );

    l_aging_algorithm :=
        prd_api_product_pkg.get_attr_value_char(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.AGING_ALGORITHM
          , i_service_id        => l_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
          , i_inst_id           => l_account.inst_id
          , i_mask_error        => com_api_const_pkg.FALSE
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => crd_api_const_pkg.ALGORITHM_AGING_DEFAULT
        );

    l_delivery_statement_method :=
        prd_api_product_pkg.get_attr_value_char(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.INVOICING_DELIVERY_STMT_METHOD
          , i_service_id        => l_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
          , i_inst_id           => l_account.inst_id
          , i_mask_error        => com_api_const_pkg.TRUE
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => null
        );

    trc_log_pkg.debug('create_invoice: l_interest_amount=[' || l_interest_amount || '], New l_last_entry_id=[' || l_last_entry_id || '], l_aging_algorithm=[' || l_aging_algorithm || '], l_delivery_statement_method=[' || l_delivery_statement_method || ']');

    crd_cst_invoice_pkg.get_aging_period(
        i_last_invoice_id    => l_last_invoice.id
      , o_aging_period       => l_aging_period
      , o_serial_number      => l_serial_number
      , i_aging_algorithm    => l_aging_algorithm
    );

    rul_api_param_pkg.set_param(
        i_value              => l_aging_period
      , i_name               => 'AGING_PERIOD'
      , io_params            => l_param_tab
    );
    rul_api_param_pkg.set_param(
        i_value              => l_serial_number
      , i_name               => 'BILLING_PERIOD_NUMBER'
      , io_params            => l_param_tab
    );
    rul_api_param_pkg.set_param(
        i_value              => l_aging_period
      , i_name               => 'INVOICE_AGING_PERIOD'
      , io_params            => l_param_tab
    );

    -- Get new invoice identifier
    select crd_invoice_seq.nextval into l_invoice_id from dual;

    open cu_active_debts for
        select d.id debt_id
             , d.is_new
             , d.status
             , d.oper_type
             , d.amount
          from crd_debt d
         where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
           and d.split_hash = i_split_hash
        union
        select d.id debt_id
             , d.is_new
             , d.status
             , d.oper_type
             , d.amount
          from crd_debt d
         where decode(d.is_new, 1, d.account_id, null) = i_account_id
           and d.account_id = i_account_id
           and d.split_hash = i_split_hash;

    fetch cu_active_debts bulk collect into
        l_debt_id_tab
      , l_is_new_tab
      , l_status_tab
      , l_oper_type_tab
      , l_debt_amount_tab;

    close cu_active_debts;

    crd_payment_pkg.apply_payments(
        i_account_id        => i_account_id
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
    );

    -- Check all unpaid debts and last period (new) ones for the account
    for r in 1..l_debt_id_tab.count loop

        l_from_id := com_api_id_pkg.get_from_id_num(l_debt_id_tab(r));
        l_till_id := com_api_id_pkg.get_till_id_num(l_debt_id_tab(r));

        crd_debt_pkg.load_debt_param(
            i_debt_id       => l_debt_id_tab(r)
          , io_param_tab    => l_param_tab
          , o_product_id    => l_product_id
          , i_split_hash    => i_split_hash
        );

        trc_log_pkg.debug(
            i_text       => 'Calculate MAD: debt_id = [#1], is_new = [#2]'
          , i_env_param1 => l_debt_id_tab(r)
          , i_env_param2 => l_is_new_tab(r)
        );

        for p in (
            select b.id
                 , case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER  -- 'BLTP0001'
                          or d.status      != crd_api_const_pkg.DEBT_STATUS_ACTIVE
                        then 0
                        else b.amount
                   end as amount
                 , b.balance_type
                 , b.min_amount_due
                 , b.debt_intr_id
              from crd_debt d
                 , crd_debt_balance b
             where d.id         = l_debt_id_tab(r)
               and b.debt_id    = d.id
               and b.split_hash = i_split_hash
               and b.id between l_from_id and l_till_id
        ) loop
            trc_log_pkg.debug(
                i_text       => 'balance_type = [#1], amount = [#2], min_amount_due = [#3]'
              , i_env_param1 => p.balance_type
              , i_env_param2 => p.amount
              , i_env_param3 => p.min_amount_due
            );

            l_calc_amount := p.min_amount_due;

            rul_api_param_pkg.set_param(
                i_value         => p.balance_type
              , i_name          => 'BALANCE_TYPE'
              , io_params       => l_param_tab
            );

            -- calculating minimum amount for every balance of debt,
            -- recalc MAD only for old debts
            if p.amount > p.min_amount_due and p.amount > 0 then

                l_fee_id :=
                    prd_api_product_pkg.get_fee_id(
                        i_product_id    => l_product_id
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                      , i_fee_type      => crd_api_const_pkg.MAD_PERCENTAGE_FEE_TYPE
                      , i_service_id    => l_service_id
                      , i_params        => l_param_tab
                      , i_eff_date      => i_eff_date
                      , i_split_hash    => i_split_hash
                      , i_inst_id       => l_account.inst_id
                    );

                fcl_api_fee_pkg.get_fee_amount(
                    i_fee_id            => l_fee_id
                  , i_base_amount       => (p.amount - p.min_amount_due)
                  , i_base_currency     => l_account.currency
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id         => i_account_id
                  , i_eff_date          => i_eff_date
                  , i_split_hash        => i_split_hash
                  , io_fee_currency     => l_account.currency
                  , o_fee_amount        => l_calc_amount
                );

                l_calc_amount := round(l_calc_amount);

                trc_log_pkg.debug('l_fee_id=['||l_fee_id||'] l_calc_amount=['||l_calc_amount||']');

                -- set minimum amount due for balance
                update crd_debt_balance
                   set min_amount_due = least(min_amount_due + l_calc_amount, amount)
                 where id             = p.id
                returning min_amount_due into l_calc_amount;

                update crd_debt_interest
                   set min_amount_due = l_calc_amount
                 where id             = p.debt_intr_id;
            end if;

            -- redefine repayment priority for new and active debts
            -- because IS_NEW parameter will be changed
            if l_is_new_tab(r) = com_api_const_pkg.TRUE and l_status_tab(r) = crd_api_const_pkg.DEBT_STATUS_ACTIVE then
                rul_api_param_pkg.set_param(
                    i_value         => com_api_const_pkg.FALSE
                  , i_name          => 'IS_NEW'
                  , io_params       => l_param_tab
                );

                l_repay_priority :=
                    prd_api_product_pkg.get_attr_value_number(
                        i_product_id    => l_product_id
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                      , i_attr_name     => crd_api_const_pkg.REPAYMENT_PRIORITY
                      , i_params        => l_param_tab
                      , i_service_id    => l_service_id
                      , i_eff_date      => i_eff_date
                      , i_split_hash    => i_split_hash
                      , i_inst_id       => l_account.inst_id
                    );

                update crd_debt_balance
                   set repay_priority = l_repay_priority
                 where id             = p.id
                   and repay_priority != l_repay_priority;
            end if;

            -- add link of an invoice with debt
            insert into crd_invoice_debt(
                id
              , invoice_id
              , debt_id
              , debt_intr_id
              , is_new
              , split_hash
            ) values (
                (l_from_id + crd_invoice_debt_seq.nextval)
              , l_invoice_id
              , l_debt_id_tab(r)
              , p.debt_intr_id
              , l_is_new_tab(r)
              , i_split_hash
            );

            -- calculating invoice total amount and minimum amount due
            l_total_amount_due       := l_total_amount_due + p.amount;
            l_mandatory_amount_due   := l_mandatory_amount_due + l_calc_amount;

            -- calculating balances. debt in status Suspend must be excluded
            case p.balance_type
                when crd_api_const_pkg.BALANCE_TYPE_OVERLIMIT then --'BLTP1007'
                    l_overlimit_balance := l_overlimit_balance + p.amount;

                when crd_api_const_pkg.BALANCE_TYPE_OVERDUE then --'BLTP1004'
                    l_overdue_balance := l_overdue_balance + p.amount;

                when crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST then --'BLTP1005'
                    l_overdue_intr_balance := l_overdue_intr_balance + p.amount;

                when crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT then --'BLTP1002'
                    l_overdraft_balance := l_overdraft_balance + p.amount;

                else null;
            end case;
        end loop;

        -- set debt as not new (added into invoice)
        update crd_debt
           set is_new     = com_api_const_pkg.FALSE
         where id         = l_debt_id_tab(r)
           and is_new     = com_api_const_pkg.TRUE;

        if sql%rowcount > 0 then
            crd_interest_pkg.set_interest(
                i_debt_id           => l_debt_id_tab(r)
              , i_eff_date          => i_eff_date
              , i_account_id        => i_account_id
              , i_service_id        => l_service_id
              , i_split_hash        => i_split_hash
              , i_is_forced         => com_api_const_pkg.TRUE
              , i_event_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
            );

            update crd_invoice_debt a
               set debt_intr_id = (
                                   select max(c.id)
                                     from crd_debt_interest b, crd_debt_interest c
                                    where b.id = a.debt_intr_id
                                      and b.debt_id = c.debt_id
                                      and b.balance_type = c.balance_type
                                      and b.split_hash = i_split_hash
                                      and c.split_hash = i_split_hash
                                      and b.id between l_from_id and l_till_id
                                      and c.id between l_from_id and l_till_id
                                  )
             where a.invoice_id = l_invoice_id
               and a.debt_id    = l_debt_id_tab(r)
               and a.split_hash = i_split_hash
               and a.id between l_from_id and l_till_id;
        end if;

        -- mark all charged interest by invoice identifier
        update crd_debt_interest i
           set i.invoice_id = l_invoice_id
         where i.invoice_id is null
           and i.is_charged      = com_api_const_pkg.TRUE
           and i.interest_amount > 0
           and i.debt_id = l_debt_id_tab(r)
           and i.split_hash = i_split_hash
           and i.id between l_from_id and l_till_id;

        -- calculating invoice expense amount
        if l_is_new_tab(r) = com_api_const_pkg.TRUE then
            l_expense_amount := l_expense_amount + l_debt_amount_tab(r);
        end if;

        -- calculating invoice fee amount
        if l_oper_type_tab(r) = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE then
            l_fee_amount := l_fee_amount + l_debt_amount_tab(r);
        end if;
    end loop;

    l_waive_interest_amount :=
        get_waived_interest_amount(
            i_account_id  => i_account_id
          , i_split_hash  => i_split_hash
          , i_inst_id     => l_account.inst_id
          , i_invoice_id  => l_invoice_id
          , i_product_id  => l_product_id
          , i_service_id  => l_service_id
        );

    -- Specific (re)calculating MAD if non-default MAD calculation algorithm is defined
    crd_api_algo_proc_pkg.process_mad_when_invoice(
        i_account_id            => i_account_id
      , i_product_id            => l_product_id
      , i_service_id            => l_service_id
      , i_eff_date              => i_eff_date
      , i_invoice_id            => l_invoice_id
      , i_aging_period          => l_aging_period
      , i_mad                   => l_mandatory_amount_due
      , i_tad                   => l_total_amount_due
      , i_overdraft_balance     => l_overdraft_balance
      , o_mad                   => l_modified_mad
    );

    -- If mandatory amount less than threshold (see modify_mandatory_amount_due),
    -- distribute difference between debts in order of repayment priority
    recalculate_mad(
        i_invoice_id            => l_invoice_id
      , i_split_hash            => i_split_hash
      , i_mandatory_amount_due  => l_mandatory_amount_due
      , i_modified_mad          => l_modified_mad
      , i_update_invoice        => com_api_const_pkg.FALSE
    );

    l_mandatory_amount_due := l_modified_mad;

    -- check all active payments and calculate own funds amount
    for r in (
        select id
             , pay_amount
             , is_new
          from crd_payment
         where decode(status, 'PMTSACTV', account_id, null) = i_account_id
           and split_hash = i_split_hash
        union
        select id
             , pay_amount
             , is_new
          from crd_payment
         where decode(is_new, 1, account_id, null) = i_account_id
           and split_hash = i_split_hash
    ) loop
        insert into crd_invoice_payment(
            id
          , invoice_id
          , pay_id
          , pay_amount
          , is_new
          , split_hash
        ) values (
            com_api_id_pkg.get_id(crd_invoice_payment_seq.nextval, r.id)
          , l_invoice_id
          , r.id
          , r.pay_amount
          , r.is_new
          , i_split_hash
        );

        -- calculating invoice payment amount
        if r.is_new = com_api_const_pkg.TRUE then
            l_payment_amount := l_payment_amount + r.pay_amount;
        end if;

        -- set payment as not new (added into invoice)
        update crd_payment
           set is_new     = com_api_const_pkg.FALSE
         where id         = r.id
           and is_new     = com_api_const_pkg.TRUE;

        l_own_funds := l_own_funds + r.pay_amount;
    end loop;

    if l_own_funds = 0 then
        -- use current balance in calculate own funds
        begin
            l_use_current_balance :=
                nvl(
                    prd_api_product_pkg.get_attr_value_number(
                        i_product_id    => l_product_id
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                      , i_attr_name     => crd_api_const_pkg.CURRENT_BALANCE
                      , i_split_hash    => i_split_hash
                      , i_service_id    => l_service_id
                      , i_params        => l_param_tab
                      , i_eff_date      => i_eff_date
                      , i_inst_id       => l_account.inst_id
                      , i_mask_error    => com_api_const_pkg.TRUE
                    )
                  , com_api_const_pkg.FALSE
                );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then
                    trc_log_pkg.debug('Attribute value [CRD_CURRENT_BALANCE] not defined. Set a value = FALSE');
                    l_use_current_balance := com_api_const_pkg.FALSE;
                else
                    raise;
                end if;
        end;

        if l_use_current_balance = com_api_const_pkg.TRUE then
            -- check ledger balance on invoice date
            l_interest_start_date :=
                prd_api_product_pkg.get_attr_value_char(
                    i_product_id    => l_product_id
                  , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => i_account_id
                  , i_attr_name     => crd_api_const_pkg.INTEREST_CALC_START_DATE
                  , i_split_hash    => i_split_hash
                  , i_service_id    => l_service_id
                  , i_params        => l_param_tab
                  , i_eff_date      => i_eff_date
                  , i_inst_id       => l_account.inst_id
                );

            if l_interest_start_date = crd_api_const_pkg.INTEREST_CALC_DATE_SETTLEMENT then
                l_date_type := com_api_const_pkg.DATE_PURPOSE_BANK;
            else
                l_date_type := com_api_const_pkg.DATE_PURPOSE_PROCESSING;
            end if;

            l_ledger_amount :=
                acc_api_balance_pkg.get_balance_amount (
                    i_account_id        => i_account_id
                  , i_balance_type      => acc_api_const_pkg.BALANCE_TYPE_LEDGER
                  , i_date              => i_eff_date
                  , i_date_type         => l_date_type
                  , i_mask_error        => com_api_const_pkg.TRUE
                );
        else
            l_ledger_amount :=
                acc_api_balance_pkg.get_balance_amount (
                    i_account_id        => i_account_id
                  , i_balance_type      => acc_api_const_pkg.BALANCE_TYPE_LEDGER
                  , i_mask_error        => com_api_const_pkg.TRUE
                  , i_lock_balance      => com_api_const_pkg.FALSE
                );
        end if;

        l_own_funds := l_own_funds + l_ledger_amount.amount;
    end if;

    l_param_tab.delete;

    -- calculating grace period date for current invoice
    l_grace_date :=
        fcl_api_cycle_pkg.calc_next_date(
            i_cycle_type        => crd_api_const_pkg.GRACE_PERIOD_CYCLE_TYPE
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_split_hash        => i_split_hash
          , i_start_date        => i_eff_date
          , i_raise_error       => com_api_type_pkg.TRUE
        );

    fcl_api_cycle_pkg.add_cycle_counter(
        i_cycle_type        => crd_api_const_pkg.GRACE_PERIOD_CYCLE_TYPE
      , i_entity_type       => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id         => l_invoice_id
      , i_split_hash        => i_split_hash
      , i_next_date         => l_grace_date
      , i_inst_id           => l_account.inst_id
    );

    -- calculating due date for current invoice
    fcl_api_cycle_pkg.switch_cycle(
        i_cycle_type        => crd_api_const_pkg.DUE_DATE_CYCLE_TYPE
      , i_product_id        => l_product_id
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_params            => l_param_tab
      , i_service_id        => l_service_id
      , i_start_date        => i_eff_date
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_inst_id           => l_account.inst_id
      , o_new_finish_date   => l_due_date
    );

    -- calculating date of penalties (if minimum amount will not be paid in time) for current invoice
    fcl_api_cycle_pkg.switch_cycle(
        i_cycle_type        => crd_api_const_pkg.PENALTY_PERIOD_CYCLE_TYPE
      , i_product_id        => l_product_id
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_params            => l_param_tab
      , i_service_id        => l_service_id
      , i_start_date        => i_eff_date
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_inst_id           => l_account.inst_id
      , o_new_finish_date   => l_penalty_date
    );

    -- calculating overdue date for current invoice
    l_overdue_date :=
        fcl_api_cycle_pkg.calc_next_date(
            i_cycle_type        => crd_api_const_pkg.OVERDUE_DATE_CYCLE_TYPE
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_split_hash        => i_split_hash
          , i_start_date        => i_eff_date
          , i_raise_error       => com_api_type_pkg.TRUE
        );

    fcl_api_cycle_pkg.add_cycle_counter(
        i_cycle_type        => crd_api_const_pkg.OVERDUE_DATE_CYCLE_TYPE
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_split_hash        => i_split_hash
      , i_next_date         => l_overdue_date
      , i_inst_id           => l_account.inst_id
    );

    l_exceed_limit :=
        acc_api_balance_pkg.get_balance_amount (
            i_account_id     => i_account_id
          , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
          , i_date           => i_eff_date
          , i_date_type      => com_api_const_pkg.DATE_PURPOSE_BANK
          , i_mask_error     => com_api_const_pkg.TRUE
        );

    l_agent_number := ost_ui_agent_pkg.get_agent_number(l_account.agent_id);

    begin
        select postal_code
          into l_postal_code
          from prd_customer c
             , com_address_object o
             , com_address a
         where c.id = l_account.customer_id
           and o.object_id = c.id
           and o.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and a.id = o.address_id
           and rownum < 2;

    exception
        when no_data_found then
            trc_log_pkg.error(
                i_text        => 'Address not found for customer [#1]'
              , i_env_param1  => l_account.customer_id
            );
            l_postal_code := null;
    end;

    acc_api_balance_pkg.get_account_balances(
        i_account_id  => i_account_id
      , o_balances    => l_balances
      , o_balance     => l_aval_balance.amount
    );

    if l_balances.exists(acc_api_const_pkg.BALANCE_TYPE_HOLD) then
        l_hold_balance := l_balances(acc_api_const_pkg.BALANCE_TYPE_HOLD).amount;
    end if;

    if l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_INTEREST) then
        l_interest_balance := l_balances(crd_api_const_pkg.BALANCE_TYPE_INTEREST).amount;
    end if;

    if l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST) then
        l_interest_balance := l_interest_balance + l_balances(crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST).amount;
    end if;

    -- get last entry id
    select max(e.id)
      into l_last_entry_id
      from acc_entry e
     where e.account_id = i_account_id
       and e.split_hash = i_split_hash;

    if i_calculate_apr = com_api_const_pkg.TRUE then
        l_irr := crd_utl_pkg.calculate_irr(
                     i_account_id            => i_account_id
                   , i_invoice_id            => l_invoice_id
                   , i_inst_id               => l_account.inst_id
                   , i_product_id            => l_product_id
                   , i_service_id            => l_service_id
                   , i_eff_date              => i_eff_date
                   , i_split_hash            => i_split_hash
                   , i_mandatory_amount_due  => l_mandatory_amount_due
                   , i_interest_amount       => l_interest_amount
                   , i_total_amount_due      => l_total_amount_due
                 );
        l_apr := crd_utl_pkg.calculate_apr(i_irr => l_irr);
    else
        l_irr := 0;
        l_apr := 0;
    end if;

    -- add invoce record
    insert into crd_invoice(
        id
      , account_id
      , invoice_type
      , serial_number
      , exceed_limit
      , total_amount_due
      , min_amount_due
      , own_funds
      , start_date
      , invoice_date
      , grace_date
      , due_date
      , penalty_date
      , aging_period
      , is_tad_paid
      , is_mad_paid
      , inst_id
      , agent_id
      , split_hash
      , overlimit_balance
      , overdue_balance
      , overdue_intr_balance
      , overdraft_balance
      , hold_balance
      , available_balance
      , postal_code
      , agent_number
      , overdue_date
      , interest_balance
      , interest_amount
      , payment_amount
      , expense_amount
      , fee_amount
      , last_entry_id
      , irr
      , apr
      , waive_interest_amount
    ) values (
        l_invoice_id
      , i_account_id
      , crd_api_const_pkg.INVOICE_TYPE_REGULAR
      , l_serial_number
      , l_exceed_limit.amount
      , l_total_amount_due
      , l_mandatory_amount_due
      , l_own_funds
      , l_last_invoice.invoice_date
      , i_eff_date
      , l_grace_date
      , l_due_date
      , l_penalty_date
      , l_aging_period
      , com_api_const_pkg.FALSE
      , com_api_const_pkg.FALSE
      , l_account.inst_id
      , l_account.agent_id
      , i_split_hash
      , l_overlimit_balance
      , l_overdue_balance
      , l_overdue_intr_balance
      , l_overdraft_balance
      , l_hold_balance
      , l_aval_balance.amount
      , l_postal_code
      , l_agent_number
      , l_overdue_date
      , l_interest_balance
      , l_interest_amount
      , l_payment_amount
      , l_expense_amount
      , l_fee_amount
      , l_last_entry_id
      , l_irr
      , l_apr
      , l_waive_interest_amount
    );

    calculate_agings(
        i_account_id        => i_account_id
      , i_invoice_id        => l_invoice_id
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_aging_algorithm   => l_aging_algorithm
    );

    switch_aging_cycle(
        i_account_id        => i_account_id
      , i_service_id        => l_service_id
      , i_product_id        => l_product_id
      , i_eff_date          => i_eff_date
      , i_due_date          => l_due_date
      , i_split_hash        => i_split_hash
      , i_inst_id           => l_account.inst_id
      , i_aging_algorithm   => l_aging_algorithm
      , i_aging_period      => l_aging_period
      , i_mad_amount        => l_mandatory_amount_due
    );

    -- calculating date of next invoice and adding new event
    fcl_api_cycle_pkg.switch_cycle(
        i_cycle_type        => crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
      , i_product_id        => l_product_id
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_params            => l_param_tab
      , i_service_id        => l_service_id
      , i_start_date        => i_eff_date
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_inst_id           => l_account.inst_id
      , o_new_finish_date   => l_next_date
    );

    fcl_api_cycle_pkg.switch_cycle(
        i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
      , i_product_id        => l_product_id
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_params            => l_param_tab
      , i_service_id        => l_service_id
      , i_start_date        => i_eff_date
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_inst_id           => l_account.inst_id
      , o_new_finish_date   => l_next_date
    );

    rul_api_param_pkg.set_param(
        i_name              => 'AGING_PERIOD'
      , i_value             => l_aging_period
      , io_params           => l_param_tab
    );
    rul_api_param_pkg.set_param(
        i_value              => l_delivery_statement_method
      , i_name               => 'CRD_INVOICING_DELIVERY_STMTD'
      , io_params            => l_param_tab
    );

    begin
        l_send_blank_statement := prd_api_product_pkg.get_attr_value_number(
                                      i_product_id    => l_product_id
                                    , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                    , i_object_id     => i_account_id
                                    , i_attr_name     => crd_api_const_pkg.SEND_BLANK_STATEMENT
                                    , i_params        => l_param_tab
                                    , i_service_id    => l_service_id
                                    , i_eff_date      => i_eff_date
                                    , i_split_hash    => i_split_hash
                                    , i_inst_id       => l_account.inst_id
                                  );
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then
                trc_log_pkg.debug('Attribute value [CRD_SEND_BLANK_STATEMENT] not defined. Set a value = TRUE');
                l_send_blank_statement := com_api_const_pkg.TRUE;
            else
                raise;
            end if;
    end;

    if  (
         nvl(l_send_blank_statement, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
         or
         l_total_amount_due != 0 or l_mandatory_amount_due != 0 or l_payment_amount != 0
        )
        and
        generate_inv_creation_event(
            i_account_id        => i_account_id
          , i_split_hash        => i_split_hash
          , i_inst_id           => l_account.inst_id
          , i_currency          => l_account.currency
          , i_product_id        => l_product_id
          , i_service_id        => l_service_id
          , i_params            => l_param_tab
          , i_eff_date          => i_eff_date
          , i_total_amount_due  => l_total_amount_due
        ) = com_api_const_pkg.TRUE
    then
        evt_api_event_pkg.register_event(
            i_event_type        => crd_api_const_pkg.INVOICE_CREATION_EVENT
          , i_eff_date          => i_eff_date
          , i_entity_type       => crd_api_const_pkg.ENTITY_TYPE_INVOICE
          , i_object_id         => l_invoice_id
          , i_inst_id           => l_account.inst_id
          , i_split_hash        => i_split_hash
          , i_param_tab         => l_param_tab
        );
    end if;

    g_invoice := null; -- last account's invoice is not actual now

exception
    when others then
        if cu_active_debts%isopen then
            close cu_active_debts;
        end if;
        raise;
end create_invoice;

function get_last_invoice_id(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_eff_date          in      date
) return com_api_type_pkg.t_medium_id
is
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_invoice_id                com_api_type_pkg.t_medium_id;
begin
    l_split_hash :=
        coalesce(
            i_split_hash
          , com_api_hash_pkg.get_split_hash(
                i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id   => i_account_id
            )
        );

    select max(id) keep (dense_rank last order by invoice_date) as id
      into l_invoice_id
      from crd_invoice
     where account_id = i_account_id
       and split_hash = l_split_hash
       and (i_eff_date is null or invoice_date <= i_eff_date);

    if l_invoice_id is null and i_mask_error = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_error(
            i_error         => 'ACCOUNT_HAS_NO_INVOICES'
          , i_env_param1    => i_account_id
        );
    end if;

    return l_invoice_id;
end;

function get_last_invoice_id(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_medium_id
is
begin
    return get_last_invoice(
               i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
             , i_object_id    => i_account_id
             , i_split_hash   => i_split_hash
             , i_mask_error   => i_mask_error
           ).id;
end;

function get_last_invoice(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id       default null
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return crd_api_type_pkg.t_invoice_rec
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_last_invoice ';
    l_invoice                   crd_api_type_pkg.t_invoice_rec;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_entity_type [#1], i_object_id [#2], i_split_hash [#3], i_mask_error [#4]'
      , i_env_param1 => i_entity_type
      , i_env_param2 => i_object_id
      , i_env_param3 => i_split_hash
      , i_env_param4 => i_mask_error
    );

    begin
        l_invoice.account_id :=
            case i_entity_type
                when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                    i_object_id
                else
                    acc_api_account_pkg.get_account(
                        i_entity_type  => i_entity_type
                      , i_object_id    => i_object_id
                      , i_account_type => acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
                      , i_mask_error   => i_mask_error
                    ).account_id
            end;

        if l_invoice.account_id is null then
            trc_log_pkg.debug(
                i_text       => 'Account was NOT found'
              , i_env_param1 => l_invoice.account_id
            );

        elsif g_invoice.account_id = l_invoice.account_id then
            l_invoice := g_invoice;

        else
            l_invoice.split_hash :=
                coalesce(
                    i_split_hash
                  , com_api_hash_pkg.get_split_hash(
                        i_entity_type => i_entity_type
                      , i_object_id   => i_object_id
                    )
                );
            begin
                select id
                     , account_id
                     , serial_number
                     , invoice_type
                     , exceed_limit
                     , total_amount_due
                     , own_funds
                     , min_amount_due
                     , invoice_date
                     , grace_date
                     , due_date
                     , penalty_date
                     , aging_period
                     , is_tad_paid
                     , is_mad_paid
                     , inst_id
                     , agent_id
                     , split_hash
                     , overdue_date
                     , start_date
                  into l_invoice
                  from crd_invoice
                 where id = (select max(id) keep (dense_rank last order by invoice_date) as id
                               from crd_invoice
                              where account_id = l_invoice.account_id
                                and split_hash = l_invoice.split_hash)
                  and split_hash = l_invoice.split_hash;

                g_invoice := l_invoice;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error       => 'ACCOUNT_HAS_NO_INVOICES'
                      , i_env_param1  => l_invoice.account_id
                      , i_env_param2  => l_invoice.split_hash
                      , i_mask_error  => i_mask_error
                    );
            end;
        end if;

    exception
        when com_api_error_pkg.e_application_error then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                raise;
            end if;
    end;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> l_invoice.id [#1]'
      , i_env_param1 => l_invoice.id
    );

    return l_invoice;
end get_last_invoice;

function get_last_invoice(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return crd_api_type_pkg.t_invoice_rec
is
begin
    return get_last_invoice(
               i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
             , i_object_id    => i_account_id
             , i_split_hash   => i_split_hash
             , i_mask_error   => i_mask_error
           );
end;

function get_last_invoice_date(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id       default null
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return date
is
begin
    return get_last_invoice(
               i_entity_type  => i_entity_type
             , i_object_id    => i_object_id
             , i_split_hash   => i_split_hash
             , i_mask_error   => i_mask_error
           ).invoice_date;
end;

function get_account_id(
    i_invoice_id        in      com_api_type_pkg.t_account_id
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_medium_id
is
    l_account_id        com_api_type_pkg.t_account_id;
begin
    begin
        select i.account_id
          into l_account_id
          from crd_invoice i
         where i.id = i_invoice_id;
    exception
        when no_data_found then
            if i_mask_error = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error(i_error => 'ACCOUNT_NOT_FOUND');
            end if;
    end;

    return l_account_id;
end get_account_id;

/*
 * Procedure returns total outstanding (instant TAD) on the specified date.
 */
procedure calculate_total_outstanding(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_payoff_date           in      date
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
  , i_apply_exponent        in      com_api_type_pkg.t_boolean       default com_api_type_pkg.TRUE
  , o_due_balance              out  com_api_type_pkg.t_money
  , o_accrued_interest         out  com_api_type_pkg.t_money
  , o_closing_balance          out  com_api_type_pkg.t_money
  , o_own_funds_balance        out  com_api_type_pkg.t_money
  , o_unsettled_amount         out  com_api_type_pkg.t_money
  , o_interest_tab             out  crd_api_type_pkg.t_interest_tab
) is
    LOG_PREFIX            constant  com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.calculate_total_outstanding ';
    l_account                       acc_api_type_pkg.t_account_rec;
    l_alg_calc_intr                 com_api_type_pkg.t_dict_value;
    l_eff_date                      date;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_param_tab                     com_api_type_pkg.t_param_tab;
    l_apply_exponent                com_api_type_pkg.t_boolean   := nvl(i_apply_exponent, com_api_type_pkg.TRUE);
    l_divider                       com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_account_id [#1], i_payoff_date [#2]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_payoff_date
    );

    if i_payoff_date is null then
        com_api_error_pkg.raise_error(
            i_error         => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
          , i_env_param1    => 'i_payoff_date'
        );
    end if;

    l_account := acc_api_account_pkg.get_account(
                     i_account_id   => i_account_id
                   , i_mask_error   => com_api_const_pkg.FALSE
                 );

    if l_apply_exponent = com_api_type_pkg.TRUE then
        l_divider := power(10, com_api_currency_pkg.get_currency_exponent(i_curr_code => l_account.currency));
    else
        l_divider := 1;
    end if;

    if l_account.status = acc_api_const_pkg.ACCOUNT_STATUS_CLOSED then
        com_api_error_pkg.raise_error(
            i_error       => 'ACCOUNT_ALREADY_CLOSED'
          , i_env_param1  => i_account_id
        );
    end if;

    l_product_id :=
        coalesce(
            i_product_id
          , prd_api_product_pkg.get_product_id(
                i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => i_account_id
              , i_eff_date     => i_payoff_date
            )
        );

    l_service_id :=
        coalesce(
            i_service_id
          , prd_api_service_pkg.get_active_service_id(
                i_entity_type      => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id        => i_account_id
              , i_attr_name        => null
              , i_service_type_id  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
              , i_split_hash       => l_account.split_hash
              , i_eff_date         => null
              , i_mask_error       => com_api_const_pkg.TRUE
            )
        );

    -- Calculate due balance sum
    select abs(round(nvl(sum(b.balance), 0)) / l_divider)
      into o_due_balance
      from acc_balance  b
         , crd_event_bunch_type t
     where b.account_id    = i_account_id
       and t.event_type    = crd_api_const_pkg.APPLY_PAYMENT_EVENT
       and t.inst_id       = l_account.inst_id
       and b.balance_type  = t.balance_type;

    trc_log_pkg.debug('Due balance [' || o_due_balance || ']');

    if l_service_id is not null then
        -- Get algorithm ACIL
        begin
            l_alg_calc_intr := nvl(
                                   prd_api_product_pkg.get_attr_value_char(
                                       i_product_id    => l_product_id
                                     , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                     , i_object_id     => i_account_id
                                     , i_attr_name     => crd_api_const_pkg.ALGORITHM_CALC_INTEREST
                                     , i_split_hash    => l_account.split_hash
                                     , i_service_id    => l_service_id
                                     , i_params        => l_param_tab
                                     , i_eff_date      => i_payoff_date
                                     , i_inst_id       => l_account.inst_id
                                   )
                                 , crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
                               );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error in ('ATTRIBUTE_VALUE_NOT_DEFINED'
                                                      , 'PRD_NO_ACTIVE_SERVICE')
                then
                    l_alg_calc_intr := crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD;
                    trc_log_pkg.debug(
                        i_text       => 'Attribute value [#1] is not defined. Use algorithm [#2]'
                      , i_env_param1 => crd_api_const_pkg.ALGORITHM_CALC_INTEREST
                      , i_env_param2 => l_alg_calc_intr
                    );
                else
                    raise;
                end if;
            when others then
                trc_log_pkg.debug('Get attribute value error. ' || sqlerrm);
                raise;
        end;

        -- Get sum of not charged interests
        l_eff_date         := i_payoff_date;
        l_eff_date         := crd_interest_pkg.get_interest_start_date(
                                  i_product_id    => l_product_id
                                , i_account_id    => i_account_id
                                , i_split_hash    => l_account.split_hash
                                , i_service_id    => l_service_id
                                , i_param_tab     => l_param_tab
                                , i_posting_date  => i_payoff_date
                                , i_eff_date      => l_eff_date
                                , i_inst_id       => l_account.inst_id
                              );
        o_accrued_interest := crd_interest_pkg.calculate_accrued_interest(
                                  i_account_id    => i_account_id
                                , i_eff_date      => l_eff_date
                                , i_split_hash    => l_account.split_hash
                                , i_inst_id       => l_account.inst_id
                                , i_service_id    => l_service_id
                                , i_product_id    => l_product_id
                                , i_alg_calc_intr => l_alg_calc_intr
                                , o_interest_tab  => o_interest_tab
                              );
        o_accrued_interest := round(o_accrued_interest) / l_divider;
    end if;
    trc_log_pkg.debug('Accrued interest [' || o_accrued_interest || ']');

    select abs(round(nvl(sum(b.balance), 0)) / l_divider)
      into o_own_funds_balance
      from acc_balance  b
     where b.account_id    = i_account_id
       and b.balance_type  = acc_api_const_pkg.BALANCE_TYPE_LEDGER;

    trc_log_pkg.debug('Own funds balance [' || o_own_funds_balance || ']');

    if o_own_funds_balance > 0 then
        if o_own_funds_balance >= o_accrued_interest then
            o_own_funds_balance := o_own_funds_balance - o_accrued_interest;
            o_accrued_interest  := o_accrued_interest;
            trc_log_pkg.debug(
                i_text       => 'Case 1: own funds balance [#1], accrued interest [#2]'
              , i_env_param1 => o_own_funds_balance
              , i_env_param2 => o_accrued_interest
            );
        elsif o_own_funds_balance < o_accrued_interest then
            o_own_funds_balance := 0;
            o_accrued_interest  := o_accrued_interest - o_own_funds_balance;
            trc_log_pkg.debug(
                i_text       => 'Case 2: own funds balance [#1], accrued interest [#2]'
              , i_env_param1 => o_own_funds_balance
              , i_env_param2 => o_accrued_interest
            );
        end if;
    end if;

    -- Calculate closing balance (instant TAD)
    o_closing_balance := greatest(o_due_balance + o_accrued_interest - o_own_funds_balance, 0);

    trc_log_pkg.debug('Closing balance (instant TAD) [' || o_closing_balance || ']');

    -- Calculate unsettled amount
    select abs(round(nvl(sum(b.balance), 0)) / l_divider)
      into o_unsettled_amount
      from acc_balance  b
     where b.account_id    = i_account_id
       and b.balance_type  = acc_api_const_pkg.BALANCE_TYPE_HOLD;

    trc_log_pkg.debug('Unsettled amount [' || o_unsettled_amount || ']');

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>>'
    );
end calculate_total_outstanding;

/*
 * Function returns total outstanding (instant TAD) on the specified date.
 */
function calculate_total_outstanding(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_payoff_date           in      date
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
  , i_apply_exponent        in      com_api_type_pkg.t_boolean       default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_money
is
    l_closing_balance               com_api_type_pkg.t_money;
    l_own_funds_balance             com_api_type_pkg.t_money;
    l_due_balance                   com_api_type_pkg.t_money;
    l_accrued_interest              com_api_type_pkg.t_money;
    l_unsettled_amount              com_api_type_pkg.t_money;
    l_interest_tab                  crd_api_type_pkg.t_interest_tab;
begin
    calculate_total_outstanding(
        i_account_id         => i_account_id
      , i_payoff_date        => i_payoff_date
      , i_product_id         => i_product_id
      , i_service_id         => i_service_id
      , i_apply_exponent     => i_apply_exponent
      , o_due_balance        => l_due_balance
      , o_accrued_interest   => l_accrued_interest
      , o_closing_balance    => l_closing_balance
      , o_own_funds_balance  => l_own_funds_balance
      , o_unsettled_amount   => l_unsettled_amount
      , o_interest_tab       => l_interest_tab
    );
    return l_closing_balance;
end;

function round_up_mad(
    i_account               in      acc_api_type_pkg.t_account_rec
  , i_mad                   in      com_api_type_pkg.t_money
  , i_tad                   in      com_api_type_pkg.t_money         default null
  , i_eff_date              in      date                             default null
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
) return com_api_type_pkg.t_money
is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.round_up_mad ';
    l_eff_date                      date;
    l_rounding_up_exponent          com_api_type_pkg.t_tiny_id;
    l_params                        com_api_type_pkg.t_param_tab;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_mad                           com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_account_id [#1], i_eff_date [#2], i_product_id [#3], i_service_id [#4]'
      , i_env_param1 => i_account.account_id
      , i_env_param2 => i_eff_date
      , i_env_param3 => i_product_id
      , i_env_param4 => i_service_id
    );

    l_eff_date   := coalesce(
                        i_eff_date
                      , com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_account.inst_id)
                    );
    l_product_id := coalesce(
                        i_product_id
                      , prd_api_product_pkg.get_product_id(
                            i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id    => i_account.account_id
                        )
                    );
    l_service_id := coalesce(
                        i_service_id
                      , crd_api_service_pkg.get_active_service(
                            i_account_id   => i_account.account_id
                          , i_eff_date     => l_eff_date
                          , i_split_hash   => i_account.split_hash
                          , i_mask_error   => com_api_const_pkg.FALSE
                        )
                    );
    l_rounding_up_exponent :=
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account.account_id
          , i_attr_name         => crd_api_const_pkg.MAD_ROUNDING_UP_EXPONENT
          , i_product_id        => l_product_id
          , i_service_id        => l_service_id
          , i_params            => l_params
          , i_eff_date          => l_eff_date
          , i_split_hash        => i_account.split_hash
          , i_inst_id           => i_account.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => 0
        );

    l_mad := case
                 when l_rounding_up_exponent <= 0
                 then i_mad -- do not use rounding if necessary attribute is not defined
                 else case  -- always rounding UP, result should be a multiple of 10^(l_rounding_up_exponent)
                          when trunc(i_mad, -l_rounding_up_exponent) = i_mad
                          then i_mad
                          else trunc(i_mad, -l_rounding_up_exponent) + power(10, l_rounding_up_exponent)
                      end
             end;
    trc_log_pkg.debug(
        i_text       => 'Rounded up l_mad [#1]'
      , i_env_param1 => l_mad
    );

    l_mad := least(
                 l_mad
               , coalesce(
                     i_tad
                   , calculate_total_outstanding(
                         i_account_id     => i_account.account_id
                       , i_payoff_date    => l_eff_date
                       , i_product_id     => l_product_id
                       , i_service_id     => l_service_id
                       , i_apply_exponent => com_api_const_pkg.FALSE
                     )
                 )
             );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> [' || l_mad || ']'
    );

    return l_mad;
end round_up_mad;

function round_up_mad(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_mad                   in      com_api_type_pkg.t_money
  , i_tad                   in      com_api_type_pkg.t_money         default null
  , i_eff_date              in      date                             default null
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
) return com_api_type_pkg.t_money
is
    l_account                       acc_api_type_pkg.t_account_rec;
begin
    l_account :=
        acc_api_account_pkg.get_account(
            i_account_id  => i_account_id
          , i_mask_error  => com_api_const_pkg.FALSE
        );
    return
        round_up_mad(
            i_account     => l_account
          , i_mad         => i_mad
          , i_tad         => i_tad
          , i_eff_date    => i_eff_date
          , i_product_id  => i_product_id
          , i_service_id  => i_service_id
        );
end round_up_mad;

function calc_next_invoice_due_date(
    i_service_id            in      com_api_type_pkg.t_short_id      default null
  , i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_eff_date              in      date
  , i_mask_error            in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return date
is
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.calc_next_invoice_due_date: ';
    l_calc_due_date            date;
    l_calc_invoice_next_date   date;
    l_calc_invoice_prev_date   date;
    l_service_start_date       date;
    l_calc_due_start_date      date;
    l_due_prev_date            date;
    l_due_next_date            date;
    l_service_id               com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'start: service_id [#1], account_id [#2], split_hash [#3], inst_id [#4], effective date [#5], mask_error [#6]'
      , i_env_param1 => i_service_id
      , i_env_param2 => i_account_id
      , i_env_param3 => i_split_hash
      , i_env_param4 => i_inst_id
      , i_env_param5 => i_eff_date
      , i_env_param6 => i_mask_error
    );

    if i_service_id is null then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => i_account_id
              , i_attr_name         => null
              , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
              , i_split_hash        => i_split_hash
              , i_eff_date          => i_eff_date
              , i_inst_id           => i_inst_id
            );
    else
        l_service_id := i_service_id;
    end if;

    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type  => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
      , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id   => i_account_id
      , i_split_hash  => i_split_hash
      , i_add_counter => com_api_const_pkg.FALSE
      , o_prev_date   => l_calc_invoice_prev_date
      , o_next_date   => l_calc_invoice_next_date
    );

    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type  => crd_api_const_pkg.DUE_DATE_CYCLE_TYPE
      , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id   => i_account_id
      , i_split_hash  => i_split_hash
      , i_add_counter => com_api_const_pkg.FALSE
      , o_prev_date   => l_due_prev_date
      , o_next_date   => l_due_next_date
    );

    if l_due_next_date < i_eff_date then
        l_due_next_date:=
            fcl_api_cycle_pkg.calc_next_date(
                i_cycle_type   => crd_api_const_pkg.DUE_DATE_CYCLE_TYPE
              , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => i_account_id
              , i_split_hash   => i_split_hash
              , i_eff_date     => l_due_next_date
            );
    end if;

    if l_calc_invoice_next_date is null
        or l_calc_invoice_prev_date is null
    then
        select p.start_date
          into l_service_start_date
          from prd_service_object p
         where p.service_id  = l_service_id
           and p.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and p.object_id   = i_account_id
        ;
        if l_calc_invoice_next_date is null then
            l_calc_invoice_next_date :=
                fcl_api_cycle_pkg.calc_next_date(
                    i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id         => i_account_id
                  , i_split_hash        => i_split_hash
                  , i_start_date        => l_service_start_date
                  , i_eff_date          => i_eff_date
                  , i_inst_id           => i_inst_id
                );
        end if;
    end if;

    if l_due_next_date > l_calc_invoice_next_date then
        l_calc_due_date := l_due_next_date;
    else
        if l_due_next_date is null then
            if i_eff_date >= nvl(l_calc_invoice_prev_date, l_service_start_date)
                and i_eff_date < l_calc_invoice_next_date
            then
                l_calc_due_start_date := l_calc_invoice_next_date;
            elsif i_eff_date >= l_calc_invoice_next_date then
                l_calc_due_start_date :=
                    fcl_api_cycle_pkg.calc_next_date(
                        i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
                      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id         => i_account_id
                      , i_split_hash        => i_split_hash
                      , i_start_date        => l_calc_invoice_next_date
                      , i_eff_date          => i_eff_date
                      , i_inst_id           => i_inst_id
                    );
            elsif i_eff_date < nvl(l_calc_invoice_prev_date, l_service_start_date) then
                l_calc_due_start_date := nvl(l_calc_invoice_prev_date, l_service_start_date);
            end if;
        else
            l_calc_due_start_date := l_due_next_date;
        end if;

        if l_calc_due_start_date is not null then
            l_calc_due_date :=
                fcl_api_cycle_pkg.calc_next_date(
                    i_cycle_type        => crd_api_const_pkg.DUE_DATE_CYCLE_TYPE
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id         => i_account_id
                  , i_split_hash        => i_split_hash
                  , i_start_date        => l_calc_due_start_date
                  , i_eff_date          => i_eff_date
                  , i_inst_id           => i_inst_id
                );
        end if;
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'finish'
    );

    return l_calc_due_date;

exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'finished with error'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            if i_mask_error = com_api_const_pkg.TRUE then
                return null;
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
end calc_next_invoice_due_date;

function get_invoice(
    i_invoice_id        in      com_api_type_pkg.t_medium_id
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return crd_api_type_pkg.t_invoice_rec
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_invoice ';
    l_invoice                   crd_api_type_pkg.t_invoice_rec;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_invoice_id [#1], i_mask_error [#2]'
      , i_env_param1 => i_invoice_id
      , i_env_param2 => i_mask_error
    );

    if g_invoice.id = i_invoice_id then
        l_invoice := g_invoice;
    else
        begin
            begin
                select id
                     , account_id
                     , serial_number
                     , invoice_type
                     , exceed_limit
                     , total_amount_due
                     , own_funds
                     , min_amount_due
                     , invoice_date
                     , grace_date
                     , due_date
                     , penalty_date
                     , aging_period
                     , is_tad_paid
                     , is_mad_paid
                     , inst_id
                     , agent_id
                     , split_hash
                     , overdue_date
                     , start_date
                  into l_invoice
                  from crd_invoice
                 where id = i_invoice_id;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error       => 'INVOICE_NOT_FOUND'
                      , i_env_param1  => i_invoice_id
                      , i_mask_error  => i_mask_error
                    );
            end;
        exception
            when com_api_error_pkg.e_application_error then
                if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                    raise;
                end if;
        end;
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> l_invoice.id [#1]'
      , i_env_param1 => l_invoice.id
    );

    return l_invoice;
end get_invoice;

function get_aging_period(
    i_invoice_id        in      com_api_type_pkg.t_medium_id
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_tiny_id
is
begin
    return get_invoice(
               i_invoice_id => i_invoice_id
             , i_mask_error => i_mask_error
           ).aging_period;
end;

function get_converted_aging_period(
    i_aging_period      in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name
is
    l_conv_aging_period     com_api_type_pkg.t_name;
begin
    l_conv_aging_period :=
        com_api_array_pkg.conv_array_elem_v(
            i_array_type_id   => crd_api_const_pkg.AGING_ARRAY_TYPE_ID
          , i_array_id        => crd_api_const_pkg.AGING_ARRAY_ID
          , i_elem_value      => to_char(i_aging_period)
          , i_mask_error      => com_api_const_pkg.TRUE
        );

    return l_conv_aging_period;
end;

end;
/
