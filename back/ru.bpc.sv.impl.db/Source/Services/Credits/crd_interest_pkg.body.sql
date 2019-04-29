create or replace package body crd_interest_pkg as

procedure set_interest(
    i_debt_id           in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_is_forced         in      com_api_type_pkg.t_tiny_id          default com_api_const_pkg.FALSE
  , i_event_type        in      com_api_type_pkg.t_dict_value       default null
) is
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_product_id            com_api_type_pkg.t_short_id;
    l_fee_id                com_api_type_pkg.t_short_id;
    l_add_fee_id            com_api_type_pkg.t_short_id;
    l_debt_intr_id          com_api_type_pkg.t_long_id;
    l_posting_date          date;
    l_from_id               com_api_type_pkg.t_long_id;
    l_till_id               com_api_type_pkg.t_long_id;
    l_prev_date             date;
    l_next_date             date;
    l_is_promotional_period com_api_type_pkg.t_boolean;
    l_rate_eff_date         com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => 'set_interest: i_account_id [#1], i_debt_id [#2], i_event_type [#3]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_debt_id
      , i_env_param3 => i_event_type
    );

    crd_debt_pkg.load_debt_param(
        i_debt_id       => i_debt_id
      , io_param_tab    => l_param_tab
      , i_split_hash    => i_split_hash
      , o_product_id    => l_product_id
    );

    l_rate_eff_date :=
        prd_api_product_pkg.get_attr_value_char(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.INTEREST_RATE_EFF_DATE
          , i_service_id        => i_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
          , i_mask_error        => com_api_const_pkg.TRUE
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => crd_api_const_pkg.INTEREST_RATE_POSTING_DATE
        );

    if l_rate_eff_date = crd_api_const_pkg.INTEREST_RATE_POSTING_DATE then
        l_posting_date := rul_api_param_pkg.get_param_date('POSTING_DATE', l_param_tab);
    elsif l_rate_eff_date = crd_api_const_pkg.INTEREST_RATE_CURRENT_DATE then
        l_posting_date := i_eff_date;
    end if;

    l_from_id      := com_api_id_pkg.get_from_id_num(i_debt_id);
    l_till_id      := com_api_id_pkg.get_till_id_num(i_debt_id);

    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type    => crd_api_const_pkg.PROMOTIONAL_PERIOD_CYCLE_TYPE
      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id     => i_account_id
      , i_split_hash    => i_split_hash
      , i_add_counter   => com_api_type_pkg.FALSE
      , o_prev_date     => l_prev_date
      , o_next_date     => l_next_date
    );
    
    if l_next_date is not null and l_next_date >= l_posting_date then
        l_is_promotional_period := com_api_type_pkg.TRUE;
    else
        l_is_promotional_period := com_api_type_pkg.FALSE;
    end if;

    for r in (
        select x.debt_id
             , x.balance_type
             , x.amount
             , x.min_amount_due
             , x.split_hash
             , x.new_balance_date
             , x.new_amount
             , e.bunch_type_id
             , x.is_grace_applied
             , x.fee_id
             , x.inst_id
             , x.posting_order
          from (
                select b.debt_id
                     , b.balance_type
                     , b.amount
                     , b.min_amount_due
                     , b.split_hash
                     , nvl(i.balance_date, i_eff_date) old_balance_date
                     , greatest(i_eff_date, nvl(i.balance_date, i_eff_date)) new_balance_date
                     , nvl(i.amount, 0) old_amount
                     , b.amount new_amount
                     , d.inst_id
                     , d.is_grace_applied
                     , i.fee_id
                     , b.posting_order
                  from crd_debt_balance b
                     , crd_debt_interest i
                     , crd_debt d
                 where b.debt_id      = i_debt_id
                   and b.id between l_from_id and l_till_id
                   and b.split_hash   = i_split_hash
                   and b.debt_intr_id = i.id(+)
                   and d.id = b.debt_id
               ) x
             , crd_event_bunch_type e
         where (
                x.old_amount != x.new_amount
                or
                (
                 i_is_forced = com_api_const_pkg.TRUE
                 and
                 x.old_amount > 0
                )
               )
           and e.event_type(+) = crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
           and e.balance_type(+) = x.balance_type
           and e.inst_id(+) = x.inst_id
    ) loop
        rul_api_param_pkg.set_param(
            i_value         => r.balance_type
          , i_name          => 'BALANCE_TYPE'
          , io_params       => l_param_tab
        );
        rul_api_param_pkg.set_param(
            i_value         => r.new_balance_date
          , i_name          => 'BALANCE_DATE'
          , io_params       => l_param_tab
        );

        -- if grace applied for debt we do not need to calculate fee again
        if r.is_grace_applied = com_api_const_pkg.FALSE 
           or i_event_type = crd_api_const_pkg.PROMOTIONAL_PERIOD_CYCLE_TYPE then
            if l_is_promotional_period = com_api_type_pkg.TRUE then
                l_fee_id :=
                    prd_api_product_pkg.get_fee_id (
                        i_product_id    => l_product_id
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                      , i_fee_type      => crd_api_const_pkg.PROMO_INTEREST_RATE_FEE_TYPE
                      , i_split_hash    => i_split_hash
                      , i_service_id    => i_service_id
                      , i_params        => l_param_tab
                      , i_eff_date      => l_posting_date
                      , i_inst_id       => r.inst_id
                    );
                l_add_fee_id := null;
            else
                -- Get reference to algorithm using for calculating interest
                l_fee_id :=
                    prd_api_product_pkg.get_fee_id (
                        i_product_id    => l_product_id
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                      , i_fee_type      => crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
                      , i_split_hash    => i_split_hash
                      , i_service_id    => i_service_id
                      , i_params        => l_param_tab
                      , i_eff_date      => l_posting_date
                      , i_inst_id       => r.inst_id
                    );
                -- Get reference to algorithm using for calculating additional interest
                l_add_fee_id :=
                    prd_api_product_pkg.get_fee_id (
                        i_product_id    => l_product_id
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                      , i_fee_type      => crd_api_const_pkg.ADDIT_INTEREST_RATE_FEE_TYPE
                      , i_split_hash    => i_split_hash
                      , i_service_id    => i_service_id
                      , i_params        => l_param_tab
                      , i_eff_date      => l_posting_date
                      , i_inst_id       => r.inst_id
                    );
            end if;
        else
            l_fee_id     := r.fee_id;
            l_add_fee_id := null;
        end if;

        insert into crd_debt_interest(
            id
          , debt_id
          , balance_type
          , balance_date
          , amount
          , min_amount_due
          , interest_amount
          , fee_id
          , add_fee_id
          , is_charged
          , is_grace_enable
          , split_hash
          , posting_order
          , event_type
          , is_waived
        ) values (
            (l_from_id + crd_debt_interest_seq.nextval)
          , r.debt_id
          , r.balance_type
          , r.new_balance_date
          , r.amount
          , r.min_amount_due
          , 0
          , l_fee_id
          , l_add_fee_id
          , case when l_fee_id is null or r.amount = 0 or r.bunch_type_id is null then com_api_const_pkg.TRUE
                 else com_api_const_pkg.FALSE
            end
          , null --l_is_grace_enable
          , r.split_hash
          , r.posting_order
          , i_event_type
          , com_api_const_pkg.FALSE
        ) returning id into l_debt_intr_id;

        update crd_debt_balance
           set debt_intr_id = l_debt_intr_id
         where debt_id      = r.debt_id
           and balance_type = r.balance_type
           and split_hash   = i_split_hash
           and id between l_from_id and l_till_id;
    end loop;

end set_interest;

procedure charge_interest(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_period_date       in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_event_type        in      com_api_type_pkg.t_dict_value       default null
) is
    l_interest_amount   com_api_type_pkg.t_money;
    l_total_amount      com_api_type_pkg.t_money    := 0;
    l_bunch_id          com_api_type_pkg.t_long_id;
    l_eff_date          date;
    l_interest_sum      com_api_type_pkg.t_money    := 0;
    l_currency          com_api_type_pkg.t_curr_code;
    l_service_id        com_api_type_pkg.t_short_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_account_number    com_api_type_pkg.t_account_number;
    l_macros_type_id    com_api_type_pkg.t_tiny_id;
    l_from_id           com_api_type_pkg.t_long_id;
    l_till_id           com_api_type_pkg.t_long_id;
    l_alg_calc_intr     com_api_type_pkg.t_dict_value;
    l_event_type        com_api_type_pkg.t_dict_value;
    l_product_id        com_api_type_pkg.t_long_id;
    l_charge_needed     com_api_type_pkg.t_boolean;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_addl_fee_amount   com_api_type_pkg.t_money    := 0;
    l_interest_tab      crd_api_type_pkg.t_interest_tab;
    l_waive_interest    com_api_type_pkg.t_boolean;
    l_waive_cycle_id    com_api_type_pkg.t_short_id;

    l_calc_interest_end_attr   com_api_type_pkg.t_dict_value;
    l_calc_interest_date_end   date;

    l_calc_due_date            date;

    procedure fill_interest_tab(
        i_bunch_type_id      in      com_api_type_pkg.t_tiny_id
      , i_add_bunch_type_id  in      com_api_type_pkg.t_tiny_id := null
      , i_interest_amount    in com_api_type_pkg.t_money
    ) is
        l_bunch_type_id      com_api_type_pkg.t_tiny_id := nvl(i_add_bunch_type_id, i_bunch_type_id);
    begin
        if i_interest_amount = 0 then
            return;
        end if;

        if l_interest_tab.exists(l_bunch_type_id) then
            l_interest_tab(l_bunch_type_id) := l_interest_tab(l_bunch_type_id) + i_interest_amount;
        else
            l_interest_tab(l_bunch_type_id) := i_interest_amount;
        end if;
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'charge_interest: i_account_id [#1], i_eff_date [#2], i_period_date [#3], i_event_type [#4]'
      , i_env_param1 => i_account_id
      , i_env_param2 => to_char(i_eff_date,    'dd.mm.yyyy hh24:mi:ss')
      , i_env_param3 => to_char(i_period_date, 'dd.mm.yyyy hh24:mi:ss')
      , i_env_param4 => i_event_type
    );

    l_eff_date := nvl(i_period_date, i_eff_date);

    l_inst_id :=
        acc_api_account_pkg.get_account(
            i_account_id        => i_account_id
          , i_mask_error        => com_api_const_pkg.FALSE
        ).inst_id;

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

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
        );

    -- get algorithm ACIL
    begin
        l_alg_calc_intr :=
            nvl(prd_api_product_pkg.get_attr_value_char(
                i_product_id    => l_product_id
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => i_account_id
              , i_attr_name     => crd_api_const_pkg.ALGORITHM_CALC_INTEREST
              , i_split_hash    => i_split_hash
              , i_service_id    => l_service_id
              , i_params        => l_param_tab
              , i_eff_date      => i_eff_date
              , i_inst_id       => l_inst_id
            ), crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD);

    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then

                trc_log_pkg.debug('Attribute value [CRD_ALGORITHM_CALC_INTEREST] not defined. Set algorithm = ACIL0001');
                l_alg_calc_intr := crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD;
            else
                raise;

            end if;
        when others then
            trc_log_pkg.debug('Get attribute value error. '||sqlerrm);
            raise;
    end;

    l_calc_interest_end_attr :=
        get_interest_calc_end_date(
            i_account_id  => i_account_id
          , i_eff_date    => i_eff_date
          , i_split_hash  => i_split_hash
          , i_inst_id     => l_inst_id
        );

    -- Get Due Date
    l_calc_due_date :=
        crd_invoice_pkg.calc_next_invoice_due_date(
            i_service_id => l_service_id
          , i_account_id => i_account_id
          , i_split_hash => i_split_hash
          , i_inst_id    => l_inst_id
          , i_eff_date   => i_eff_date
          , i_mask_error => case l_calc_interest_end_attr
                                when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                                    then com_api_const_pkg.FALSE
                                when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                                    then com_api_const_pkg.TRUE
                                else com_api_const_pkg.FALSE
                            end
        );

    l_waive_cycle_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.WAIVE_INTEREST_PERIOD
          , i_params            => l_param_tab
          , i_service_id        => l_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
          , i_inst_id           => l_inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => null
        );

    if l_waive_cycle_id is not null then
        l_waive_interest := com_api_const_pkg.TRUE;
    else
        l_waive_interest := com_api_const_pkg.FALSE;
    end if;

    l_event_type :=
        coalesce(
            crd_cst_interest_pkg.get_interest_charge_event_type(
                i_account_id   => i_account_id
              , i_eff_date     => i_eff_date
              , i_period_date  => i_period_date
              , i_split_hash   => i_split_hash
              , i_event_type   => i_event_type
            )
          , i_event_type
          , crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
        );

    trc_log_pkg.debug(
        i_text       => 'l_alg_calc_intr [#1], l_waive_interest [#2], l_event_type [#3]'
      , i_env_param1 => l_alg_calc_intr
      , i_env_param2 => l_waive_interest
      , i_env_param3 => l_event_type
    );

    for p in (
        select d.id debt_id
             , c.account_type
             , c.currency
             , c.account_number
             , c.inst_id
             , d.oper_id
          from crd_debt d
             , acc_account c
         where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
           and d.account_id = c.id
           and d.split_hash = i_split_hash
    ) loop
        l_charge_needed :=
            crd_cst_interest_pkg.charge_interest_needed(
                i_debt_id       => p.debt_id
              , i_oper_id       => p.oper_id
              , i_account_id    => i_account_id
              , i_eff_date      => i_eff_date
              , i_inst_id       => p.inst_id
              , i_split_hash    => i_split_hash
              , i_event_type    => l_event_type
            );

        if l_charge_needed = com_api_const_pkg.FALSE then
            continue;
        end if;

        l_currency := p.currency;
        l_account_number := p.account_number;
        l_from_id      := com_api_id_pkg.get_from_id_num(p.debt_id);
        l_till_id      := com_api_id_pkg.get_till_id_num(p.debt_id);

        set_interest(
            i_debt_id           => p.debt_id
          , i_eff_date          => l_eff_date
          , i_account_id        => i_account_id
          , i_service_id        => l_service_id
          , i_split_hash        => i_split_hash
          , i_is_forced         => com_api_const_pkg.TRUE
          , i_event_type        => l_event_type
        );

        crd_debt_pkg.load_debt_param (
            i_debt_id           => p.debt_id
          , i_split_hash        => i_split_hash
          , io_param_tab        => l_param_tab
        );

        for r in (
            select x.balance_type
                 , x.fee_id
                 , x.add_fee_id
                 , x.amount
                 , x.start_date
                 , x.end_date
                 , b.bunch_type_id
                 , b.add_bunch_type_id
                 , x.id
                 , x.macros_type_id
                 , x.interest_amount
                 , x.debt_intr_id
                 , x.card_id
                 , x.due_date
              from (
                    select a.id debt_intr_id
                         , a.balance_type
                         , a.fee_id
                         , a.add_fee_id
                         , a.amount
                         , a.balance_date start_date
                         , lead(a.balance_date) over (partition by a.balance_type order by a.posting_order, a.balance_date, a.id) end_date
                         , a.debt_id
                         , a.id
                         , d.inst_id
                         , d.macros_type_id
                         , a.interest_amount
                         , a.is_charged
                         , d.card_id
                         , i.due_date
                      from crd_debt_interest a
                         , crd_debt d
                         , crd_invoice i
                     where a.debt_id         = p.debt_id
                       and d.is_grace_enable = com_api_const_pkg.FALSE
                       and d.id              = a.debt_id
                       and a.split_hash      = i_split_hash
                       and a.id between l_from_id and l_till_id
                       and a.invoice_id      = i.id(+)
                   ) x
                 , crd_event_bunch_type b
             where x.end_date        <= l_eff_date
               and b.event_type(+)    = l_event_type
               and x.is_charged       = com_api_const_pkg.FALSE
               and b.balance_type(+)  = x.balance_type
               and b.inst_id(+)       = x.inst_id
             order by b.bunch_type_id nulls first

        ) loop
            l_calc_interest_date_end :=
                case l_calc_interest_end_attr
                    when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                        then r.end_date
                    when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                        then nvl(r.due_date, l_calc_due_date)
                    else r.end_date
                end;

            if r.bunch_type_id is not null then

                l_macros_type_id := r.macros_type_id;

                -- only for migration purposes - interest amount could be sent in migration data
                -- so we do not need to recalculate it
                if nvl(r.interest_amount, 0) = 0 then
                    -- Calculate interest amount. Base algorithm
                    if l_alg_calc_intr in (
                           crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
                         , crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM
                       )
                    then
                        fcl_api_fee_pkg.get_fee_amount(
                            i_fee_id            => r.fee_id
                          , i_base_amount       => r.amount
                          , i_base_currency     => p.currency
                          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id         => i_account_id
                          , i_split_hash        => i_split_hash
                          , i_eff_date          => r.start_date
                          , i_start_date        => r.start_date
                          , i_end_date          => l_calc_interest_date_end
                          , io_fee_currency     => p.currency
                          , o_fee_amount        => l_interest_amount
                        );

                        fill_interest_tab(
                            i_bunch_type_id   => r.bunch_type_id
                          , i_interest_amount => l_interest_amount
                        );

                        -- Calculate additional interest amount
                        if r.add_fee_id is not null then
                            fcl_api_fee_pkg.get_fee_amount(
                                i_fee_id            => r.add_fee_id
                              , i_base_amount       => r.amount
                              , i_base_currency     => p.currency
                              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id         => i_account_id
                              , i_split_hash        => i_split_hash
                              , i_eff_date          => r.start_date
                              , i_start_date        => r.start_date
                              , i_end_date          => l_calc_interest_date_end
                              , io_fee_currency     => p.currency
                              , o_fee_amount        => l_addl_fee_amount
                            );

                            fill_interest_tab(
                                i_bunch_type_id     => r.bunch_type_id
                              , i_add_bunch_type_id => r.add_bunch_type_id
                              , i_interest_amount   => l_addl_fee_amount
                            );

                            l_interest_amount := l_interest_amount + l_addl_fee_amount;
                        end if;

                        if l_alg_calc_intr = crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD then
                            l_interest_amount := round(l_interest_amount, 4);
                        elsif l_alg_calc_intr = crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM then
                            l_interest_amount := round(l_interest_amount, 0);
                        else
                            com_api_error_pkg.raise_error(
                                i_error       => 'ALGORITHM_NOT_SUPPORTED'
                              , i_env_param1  => l_alg_calc_intr
                            );
                        end if;

                    -- Custom algorithm
                    else
                        l_interest_amount := round(
                            crd_cst_interest_pkg.get_fee_amount(
                                i_fee_id            => r.fee_id
                              , i_base_amount       => r.amount
                              , io_base_currency    => p.currency
                              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id         => i_account_id
                              , i_split_hash        => i_split_hash
                              , i_eff_date          => r.start_date
                              , i_start_date        => r.start_date
                              , i_end_date          => l_calc_interest_date_end
                              , i_alg_calc_intr     => l_alg_calc_intr
                              , i_debt_id           => p.debt_id
                              , i_balance_type      => r.balance_type
                              , i_debt_intr_id      => r.debt_intr_id
                              , i_service_id        => l_service_id
                              , i_product_id        => l_product_id
                            )
                          , 4
                        );

                        fill_interest_tab(
                            i_bunch_type_id   => r.bunch_type_id
                          , i_interest_amount => l_interest_amount
                        );

                        -- Calculate additional interest amount
                        if r.add_fee_id is not null then
                            l_addl_fee_amount := round(
                                crd_cst_interest_pkg.get_fee_amount(
                                    i_fee_id            => r.add_fee_id
                                  , i_base_amount       => r.amount
                                  , io_base_currency    => p.currency
                                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                  , i_object_id         => i_account_id
                                  , i_split_hash        => i_split_hash
                                  , i_eff_date          => r.start_date
                                  , i_start_date        => r.start_date
                                  , i_end_date          => l_calc_interest_date_end
                                  , i_alg_calc_intr     => l_alg_calc_intr
                                  , i_debt_id           => p.debt_id
                                  , i_balance_type      => r.balance_type
                                  , i_debt_intr_id      => r.debt_intr_id
                                  , i_service_id        => l_service_id
                                  , i_product_id        => l_product_id
                                )
                              , 4
                            );

                            fill_interest_tab(
                                i_bunch_type_id     => r.bunch_type_id
                              , i_add_bunch_type_id => r.add_bunch_type_id
                              , i_interest_amount   => l_addl_fee_amount
                            );

                            l_interest_amount := l_interest_amount + l_addl_fee_amount;

                        end if;

                    end if;
                else
                    l_interest_amount := r.interest_amount;

                    fill_interest_tab(
                        i_bunch_type_id   => r.bunch_type_id
                      , i_interest_amount => l_interest_amount
                    );
                end if;

                l_total_amount := l_total_amount + l_interest_amount;

                l_interest_sum := l_interest_sum + l_interest_amount;

                trc_log_pkg.debug('Calculating interest amount base amount ['||r.amount||'] Fee Id ['||r.fee_id||'] Additional fee Id ['||r.add_fee_id||'] Interest amount ['||l_interest_amount||']');

            else
                l_interest_amount := 0;

                trc_log_pkg.debug('Calculating interest. bunch_type_id [NULL], interest_amount [0]');

            end if;

            update crd_debt_interest
               set is_charged      = com_api_const_pkg.TRUE
                 , interest_amount = l_interest_amount
                 , is_waived       = l_waive_interest
             where id              = r.id;
        end loop;

        if l_waive_interest = com_api_const_pkg.FALSE and l_interest_tab.count > 0 then
            for bunch_type_id in l_interest_tab.first..l_interest_tab.last loop
                if l_interest_tab.exists(bunch_type_id) then
                    acc_api_entry_pkg.put_bunch (
                        o_bunch_id          => l_bunch_id
                      , i_bunch_type_id     => bunch_type_id
                      , i_macros_id         => p.debt_id
                      , i_amount            => case l_alg_calc_intr
                                                   when crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM
                                                       then round(l_interest_tab(bunch_type_id), 0)
                                                   else round(l_interest_tab(bunch_type_id), 4)
                                               end
                      , i_currency          => p.currency
                      , i_account_type      => p.account_type
                      , i_account_id        => i_account_id
                      , i_posting_date      => i_eff_date
                      , i_macros_type_id    => l_macros_type_id
                      , i_param_tab         => l_param_tab
                    );
                end if;
            end loop;
        end if;

        l_total_amount  := 0;
        l_interest_tab.delete;

        acc_api_entry_pkg.flush_job;

        crd_debt_pkg.set_balance(
            i_debt_id           => p.debt_id
          , i_eff_date          => l_eff_date
          , i_account_id        => i_account_id
          , i_service_id        => l_service_id
          , i_inst_id           => p.inst_id
          , i_split_hash        => i_split_hash
        );

        set_interest(
            i_debt_id           => p.debt_id
          , i_eff_date          => l_eff_date
          , i_account_id        => i_account_id
          , i_service_id        => l_service_id
          , i_split_hash        => i_split_hash
          , i_event_type        => l_event_type
        );

        crd_debt_pkg.set_debt_paid(
            i_debt_id           => p.debt_id
        );
    end loop;
end;

procedure grace_period(
    i_invoice_id        in      com_api_type_pkg.t_medium_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) is
    l_product_id                com_api_type_pkg.t_short_id;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_total_amount_due          com_api_type_pkg.t_money;
    l_own_funds                 com_api_type_pkg.t_money;
    l_payment_amount            com_api_type_pkg.t_money;
    l_calc_amount               com_api_type_pkg.t_money;
    l_debt_id                   com_api_type_pkg.t_long_id;
    l_fee_id                    com_api_type_pkg.t_short_id;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_tolerance_amount          com_api_type_pkg.t_money;
    l_account_id                com_api_type_pkg.t_account_id;
    l_invoice_date              date;
    l_service_id                com_api_type_pkg.t_short_id;
    l_debt_id_tab               num_tab_tpt := num_tab_tpt();
    l_inst_id                   com_api_type_pkg.t_inst_id;
begin
    select i.account_id
         , i.total_amount_due
         , i.own_funds
         , i.invoice_date
         , a.currency
         , a.inst_id
      into l_account_id
         , l_total_amount_due
         , l_own_funds
         , l_invoice_date
         , l_currency
         , l_inst_id
      from crd_invoice i
         , acc_account a
     where i.id         = i_invoice_id
       and i.split_hash = i_split_hash
       and a.id         = i.account_id;

    select nvl(sum(amount), 0)
      into l_payment_amount
      from crd_payment p
     where decode(is_new, 1, account_id, null) = l_account_id;

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

    l_total_amount_due := 0;

    -- Calculate grace period repayment amount (l_total_amount_due) as percentage for last invoice TAD
    for r in (
        select a.debt_id
             , b.balance_type
             , b.amount
          from crd_invoice_debt a
             , crd_debt_interest b
         where a.invoice_id = i_invoice_id
           and b.id         = a.debt_intr_id
    ) loop

        if l_debt_id != r.debt_id or l_debt_id is null then
            crd_debt_pkg.load_debt_param(
                i_debt_id       => r.debt_id
              , io_param_tab    => l_param_tab
              , o_product_id    => l_product_id
              , i_split_hash    => i_split_hash
            );
            l_debt_id := r.debt_id;
        end if;

        rul_api_param_pkg.set_param(
            i_value         => r.balance_type
          , i_name          => 'BALANCE_TYPE'
          , io_params       => l_param_tab
        );

        l_fee_id :=
            prd_api_product_pkg.get_fee_id (
                i_product_id    => l_product_id
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => l_account_id
              , i_fee_type      => crd_api_const_pkg.GRACE_REPAYMENT_FEE_TYPE
              , i_split_hash    => i_split_hash
              , i_service_id    => l_service_id
              , i_params        => l_param_tab
              , i_eff_date      => i_eff_date
              , i_inst_id       => l_inst_id
            );

        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_fee_id
          , i_base_amount       => r.amount
          , i_base_currency     => l_currency
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
          , io_fee_currency     => l_currency
          , o_fee_amount        => l_calc_amount
        );

        l_calc_amount := round(l_calc_amount);

        trc_log_pkg.debug('grace_period repayment amount: l_fee_id=['||l_fee_id||'] l_calc_amount=['||l_calc_amount||']');

        l_total_amount_due := l_total_amount_due + l_calc_amount;

        if r.debt_id not member of l_debt_id_tab then
            l_debt_id_tab.extend(1);
            l_debt_id_tab(l_debt_id_tab.count) := r.debt_id;
        end if;

    end loop;

    l_tolerance_amount := 0;

    if (l_payment_amount + l_own_funds) < l_total_amount_due then
        l_fee_id :=
            prd_api_product_pkg.get_fee_id (
                i_product_id    => l_product_id
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => l_account_id
              , i_fee_type      => crd_api_const_pkg.TAD_TOLERANCE_FEE_TYPE
              , i_params        => l_param_tab
              , i_service_id    => l_service_id
              , i_eff_date      => i_eff_date
              , i_split_hash    => i_split_hash
              , i_inst_id       => l_inst_id
            );

        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_fee_id
          , i_base_amount       => l_total_amount_due
          , i_base_currency     => l_currency
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
          , io_fee_currency     => l_currency
          , o_fee_amount        => l_tolerance_amount
        );

        l_tolerance_amount := round(l_tolerance_amount);

    end if;

    trc_log_pkg.debug('grace_period: l_total_amount_due=['||l_total_amount_due||'] l_payment_amount=['||l_payment_amount||'] l_own_funds=['||l_own_funds||'] l_tolerance_amount=['||l_tolerance_amount||']');

    if (l_payment_amount + l_own_funds) >= (l_total_amount_due - l_tolerance_amount) then

        l_param_tab.delete;

        l_debt_id := null;

        for r in (
            select d.id
                 , d.debt_id
                 , d.balance_type
                 , t.inst_id
              from crd_invoice_debt i
                 , crd_debt_interest d
                 , crd_debt t
             where i.invoice_id      = i_invoice_id
               and i.split_hash      = i_split_hash
               and i.is_new          = com_api_const_pkg.TRUE
               and i.debt_intr_id    = d.id
               and i.debt_id         = t.id
               and d.debt_id         = t.id
               and t.is_grace_enable = com_api_const_pkg.TRUE
        ) loop

            if l_debt_id != r.debt_id or l_debt_id is null then
                crd_debt_pkg.load_debt_param(
                    i_debt_id       => r.debt_id
                  , io_param_tab    => l_param_tab
                  , o_product_id    => l_product_id
                  , i_split_hash    => i_split_hash
                );
                l_debt_id := r.debt_id;
            end if;

            rul_api_param_pkg.set_param(
                i_value         => r.balance_type
              , i_name          => 'BALANCE_TYPE'
              , io_params       => l_param_tab
            );

            l_fee_id :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id    => l_product_id
                  , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => l_account_id
                  , i_fee_type      => crd_api_const_pkg.GRACE_INTEREST_FEE_TYPE
                  , i_params        => l_param_tab
                  , i_service_id    => l_service_id
                  , i_eff_date      => i_eff_date
                  , i_split_hash    => i_split_hash
                  , i_inst_id       => r.inst_id
                );

            trc_log_pkg.debug('grace_period set grace fee: l_debt_id=['||l_debt_id||'] l_fee_id=['||l_fee_id||'] l_own_funds=['||l_own_funds||'] l_calc_amount=['||l_tolerance_amount||']');

            update crd_debt_interest i
               set i.fee_id          = l_fee_id
                 , i.add_fee_id      = null
                 , i.interest_amount = null
             where i.debt_id         = r.debt_id
               and i.is_charged      = com_api_const_pkg.FALSE
               and i.balance_type    = r.balance_type
               and i.split_hash      = i_split_hash
               and i.id between trunc(r.debt_id, com_api_id_pkg.DAY_ROUNDING)
                            and trunc(r.debt_id, com_api_id_pkg.DAY_ROUNDING) + com_api_id_pkg.DAY_TILL_ID;
        end loop;

        update crd_invoice
           set is_tad_paid = com_api_const_pkg.TRUE
         where id          = i_invoice_id;
    end if;

    forall dbt in l_debt_id_tab.first .. l_debt_id_tab.last
        update crd_debt
           set is_grace_applied = case when (l_payment_amount + l_own_funds) >= (l_total_amount_due - l_tolerance_amount) then is_grace_enable
                                       else com_api_const_pkg.FALSE
                                  end
             , is_grace_enable  = com_api_const_pkg.FALSE
         where id = l_debt_id_tab(dbt);

    for p in (
        select id
          from crd_debt d
         where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_id
           and split_hash = i_split_hash
    ) loop
        set_interest(
            i_debt_id           => p.id
          , i_eff_date          => i_eff_date
          , i_account_id        => l_account_id
          , i_service_id        => l_service_id
          , i_split_hash        => i_split_hash
          , i_is_forced         => com_api_const_pkg.TRUE
          , i_event_type        => crd_api_const_pkg.GRACE_PERIOD_CYCLE_TYPE
        );
    end loop;

--    crd_payment_pkg.cancel_invoice(
--        i_account_id        => l_account_id
--      , i_eff_date          => i_eff_date
--    );
end;

procedure recalc_interest_on_fix_period(
    i_invoice_id               in      com_api_type_pkg.t_long_id
  , i_interest_calc_start_date in      date                         default null
  , i_interest_calc_end_date   in      date                         default null
  , o_recalculation_interest      out  com_api_type_pkg.t_money
  , o_current_interest            out  com_api_type_pkg.t_money
  , o_currency                    out  com_api_type_pkg.t_curr_code
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.recalc_interest_on_fix_period: ';
    l_account_id               com_api_type_pkg.t_account_id;
    l_split_hash               com_api_type_pkg.t_tiny_id;
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_currency                 com_api_type_pkg.t_dict_value;
    l_interest_amount          com_api_type_pkg.t_money := 0;
    l_calc_interest_end_attr   com_api_type_pkg.t_dict_value;
    l_calc_interest_date_end   date;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' Start with params - i_invoice_id ['||i_invoice_id
               ||'] i_interest_calc_start_date ['||to_char(i_interest_calc_start_date, 'dd.mm.yyyy hh24:mi:ss')
               ||'] i_interest_calc_end_date ['||to_char(i_interest_calc_end_date, 'dd.mm.yyyy hh24:mi:ss')
               ||']'
    );

    if i_interest_calc_start_date is not null
       or i_interest_calc_end_date is not null
    then
        select i.account_id
             , a.split_hash
             , i.interest_amount
             , a.currency
             , a.inst_id
          into l_account_id
             , l_split_hash
             , o_current_interest
             , o_currency
             , l_inst_id
          from crd_invoice i
             , acc_account a
         where i.id = i_invoice_id
           and a.id = i.account_id;

        l_calc_interest_end_attr :=
            get_interest_calc_end_date(
                i_account_id  => l_account_id
              , i_split_hash  => l_split_hash
              , i_inst_id     => l_inst_id
            );

        -- get total_interest
        for r in (
            select a.balance_type
                 , a.fee_id
                 , a.debt_id
                 , a.amount
                 , a.balance_date start_date
                 , lead(a.balance_date) over (partition by a.balance_type order by a.id) end_date
                 , i.due_date
              from crd_debt_interest a
                 , crd_debt d
                 , crd_invoice i
             where i.id              = i_invoice_id
               and a.invoice_id      = i.id
               and a.split_hash      = l_split_hash
               and a.is_charged      = com_api_const_pkg.TRUE
               and d.is_grace_enable = com_api_const_pkg.FALSE
               and d.id              = a.debt_id
             order by
                   d.id
        ) loop
            l_calc_interest_date_end :=
                case l_calc_interest_end_attr
                    when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                        then r.end_date
                    when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                        then r.due_date
                    else r.end_date
                end;
            l_interest_amount := round(
                fcl_api_fee_pkg.get_fee_amount(
                    i_fee_id            => r.fee_id
                  , i_base_amount       => r.amount
                  , io_base_currency    => l_currency
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id         => l_account_id
                  , i_split_hash        => l_split_hash
                  , i_eff_date          => r.start_date
                  , i_start_date        => coalesce(i_interest_calc_start_date, r.start_date)
                  , i_end_date          => coalesce(
                                               i_interest_calc_end_date
                                             , l_calc_interest_date_end
                                           )
                )
              , 4
            );
            trc_log_pkg.debug(
                i_text        => 'Calc interest [#1] [#2] [#3] [#4] [#5]'
              , i_env_param1  => r.fee_id
              , i_env_param2  => r.amount
              , i_env_param3  => r.debt_id
              , i_env_param4  => r.start_date
              , i_env_param5  => r.end_date
            );

            if o_recalculation_interest is null then
                o_recalculation_interest := 0;
            end if;

            o_recalculation_interest := o_recalculation_interest + l_interest_amount;
        end loop;
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' Finished success'
    );
end recalc_interest_on_fix_period;

function get_interest_start_date(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_posting_date      in      date
  , i_eff_date          in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return date is
    l_interest_start_date_trnsf com_api_type_pkg.t_dict_value;
    l_eff_date                  date;
begin
    l_interest_start_date_trnsf :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id        => i_product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.INTEREST_START_DATE_TRANSFORM
          , i_params            => i_param_tab
          , i_service_id        => i_service_id
          , i_eff_date          => i_posting_date
          , i_split_hash        => i_split_hash
          , i_inst_id           => i_inst_id
          , i_use_default_value => com_api_type_pkg.TRUE
          , i_default_value     => crd_api_const_pkg.INTER_DATE_TRNSF_REAL_TIME
        );

    l_eff_date :=
        case l_interest_start_date_trnsf
            when crd_api_const_pkg.INTER_DATE_TRNSFM_START_OF_DAY then trunc(i_eff_date)
            when crd_api_const_pkg.INTER_DATE_TRNSF_REAL_TIME     then i_eff_date
            when crd_api_const_pkg.INTER_DATE_TRNSF_END_OF_DAY    then trunc(i_eff_date) + 1
        end;

    return l_eff_date;

end get_interest_start_date;

function get_interest_calc_end_date(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date                           default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id     default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id     default null
  , i_service_id        in      com_api_type_pkg.t_short_id    default null
) return com_api_type_pkg.t_dict_value
is
begin
    return
        prd_api_product_pkg.get_attr_value_char(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.INTEREST_CALC_END_DATE
          , i_service_id        => i_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
          , i_inst_id           => i_inst_id
          , i_mask_error        => com_api_const_pkg.FALSE
          , i_use_default_value => com_api_type_pkg.TRUE
          , i_default_value     => crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
        );
end get_interest_calc_end_date;

procedure waive_interest(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) as
    l_charge_intereset     com_api_type_pkg.t_boolean;

    l_param_tab             com_api_type_pkg.t_param_tab;
    l_product_id            com_api_type_pkg.t_short_id;
    l_service_id            com_api_type_pkg.t_short_id;
    l_cycle_id              com_api_type_pkg.t_short_id;
    l_alg_calc_intr         com_api_type_pkg.t_dict_value;

    l_start_date            date;

    l_bunch_id              com_api_type_pkg.t_long_id;
    l_event_type            com_api_type_pkg.t_dict_value;
    l_interest_amount       com_api_type_pkg.t_money := 0;
    l_account               acc_api_type_pkg.t_account_rec;
begin
    trc_log_pkg.debug('waive_interest: i_account_id=[' || i_account_id || '] i_eff_date=[' || i_eff_date || '] i_split_hash=[' || i_split_hash|| ']');

    acc_api_account_pkg.get_account_info(
        i_account_id       => i_account_id
      , o_account_rec      => l_account
      , i_mask_error       => com_api_const_pkg.FALSE
    );

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => i_account_id
          , i_eff_date    => i_eff_date
          , i_inst_id     => l_account.inst_id
        );

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => i_split_hash
          , i_eff_date          => i_eff_date
          , i_inst_id           => l_account.inst_id
        );

    l_charge_intereset :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id    => l_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_attr_name     => crd_api_const_pkg.CHARGE_WAIVED_INTEREST
          , i_params        => l_param_tab
          , i_service_id    => l_service_id
          , i_eff_date      => i_eff_date
          , i_split_hash    => i_split_hash
          , i_inst_id       => l_account.inst_id
        );

    l_cycle_id :=
        prd_api_product_pkg.get_cycle_id(
            i_product_id   => l_product_id
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
          , i_cycle_type   => crd_api_const_pkg.WAIVE_INTEREST_CYCLE_TYPE
          , i_params       => l_param_tab
          , i_service_id   => l_service_id
          , i_eff_date     => i_eff_date
          , i_inst_id      => l_account.inst_id
        );

    fcl_api_cycle_pkg.calc_next_date(
        i_cycle_id    => l_cycle_id
      , i_start_date  => i_eff_date
      , i_forward     => com_api_const_pkg.FALSE
      , o_next_date   => l_start_date
    );

    trc_log_pkg.debug(
        i_text       => 'start_cycle_id [' || l_cycle_id || '], start_date [#1]'
      , i_env_param1 => to_char(l_start_date, com_api_const_pkg.DATE_FORMAT)
    );

    l_alg_calc_intr :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id        => l_product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.ALGORITHM_CALC_INTEREST
          , i_split_hash        => i_split_hash
          , i_service_id        => l_service_id
          , i_params            => l_param_tab
          , i_eff_date          => i_eff_date
          , i_inst_id           => l_account.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
        );

    if l_charge_intereset = com_api_const_pkg.FALSE then
        l_event_type := crd_api_const_pkg.WAIVE_INTEREST_CYCLE_TYPE;
    else
        l_event_type := crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE;
    end if;

    for r in (
        select l.debt_id
             , l.currency
             , l.macros_type_id
             , l.debt_status
             , l.balance_type
             , l.interest_amount
             , l.debt_interest_id
             , bt.bunch_type_id
             , row_number() over(partition by l.debt_id order by bunch_type_id desc, l.debt_interest_id desc) as debt_rn_desc
          from (
            select d.id as debt_id
                 , d.currency
                 , d.macros_type_id
                 , d.status as debt_status
                 , i.balance_type
                 , i.interest_amount
                 , i.id as debt_interest_id
                 , d.inst_id
              from crd_debt d
                 , crd_debt_interest i
             where i.balance_date between l_start_date and i_eff_date
               and i.is_waived       = com_api_const_pkg.TRUE
               and d.id              = i.debt_id
               and d.split_hash      = i.split_hash
               and d.account_id      = i_account_id
               and d.split_hash      = i_split_hash
        ) l
        , crd_event_bunch_type bt
        where l.balance_type    = bt.balance_type(+)
          and l.inst_id         = bt.inst_id(+)
          and bt.event_type(+)  = l_event_type
        order by l.debt_id, bt.bunch_type_id, l.debt_interest_id
    )
    loop
        trc_log_pkg.debug(
            i_text       => 'debt_id [#1], debt_interest_id [#2], interest_amount [#3], bunch_type_id [#4], rn [#5]'
          , i_env_param1 => r.debt_id
          , i_env_param2 => r.debt_interest_id
          , i_env_param3 => r.interest_amount
          , i_env_param4 => r.bunch_type_id
          , i_env_param5 => r.debt_rn_desc
        );
        l_interest_amount := l_interest_amount + r.interest_amount;

        if r.debt_rn_desc = 1 then
            if l_alg_calc_intr = crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM then
                l_interest_amount := round(l_interest_amount, 0);
            else
                l_interest_amount := round(l_interest_amount, 4);
            end if;

            trc_log_pkg.debug(
                i_text       => 'l_interest_amount [#1]'
              , i_env_param1 => l_interest_amount
            );

            if r.bunch_type_id is not null then
                if l_interest_amount <> 0 then
                    acc_api_entry_pkg.put_bunch(
                        o_bunch_id          => l_bunch_id
                      , i_bunch_type_id     => r.bunch_type_id
                      , i_macros_id         => r.debt_id
                      , i_amount            => l_interest_amount
                      , i_currency          => r.currency
                      , i_account_type      => l_account.account_type
                      , i_account_id        => i_account_id
                      , i_posting_date      => i_eff_date
                      , i_macros_type_id    => r.macros_type_id
                      , i_param_tab         => l_param_tab
                    );
                end if;
            else
                trc_log_pkg.debug(
                    i_text       => 'bunch_type_id not found for event [#1], debt_id [#2], balance_type [#3]'
                  , i_env_param1 => l_event_type
                  , i_env_param2 => r.debt_id
                  , i_env_param3 => r.balance_type
                );
            end if;

            if l_charge_intereset = com_api_const_pkg.TRUE and r.debt_status = crd_api_const_pkg.DEBT_STATUS_PAID then
                update crd_debt d
                   set d.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE
                 where id = r.debt_id;
            end if;

            acc_api_entry_pkg.flush_job;
            crd_debt_pkg.set_balance(
                i_debt_id           => r.debt_id
              , i_eff_date          => i_eff_date
              , i_account_id        => i_account_id
              , i_service_id        => l_service_id
              , i_inst_id           => l_account.inst_id
              , i_split_hash        => i_split_hash
            );
            set_interest(
                i_debt_id           => r.debt_id
              , i_eff_date          => i_eff_date
              , i_account_id        => i_account_id
              , i_service_id        => l_service_id
              , i_split_hash        => i_split_hash
              , i_event_type        => l_event_type
            );
            crd_debt_pkg.set_debt_paid(
                i_debt_id           => r.debt_id
            );

            l_interest_amount := 0;
        end if;

        if l_charge_intereset = com_api_const_pkg.TRUE then
            update crd_debt_interest d
               set d.is_waived  = com_api_const_pkg.FALSE
                 , d.invoice_id = null
             where id = r.debt_interest_id;
        end if;
    end loop;
end waive_interest;

function calculate_accrued_interest(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_alg_calc_intr     in      com_api_type_pkg.t_dict_value
  , o_interest_tab         out  crd_api_type_pkg.t_interest_tab
) return com_api_type_pkg.t_money
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.calculate_accrued_interest ';
    l_account                   acc_api_type_pkg.t_account_rec;
    l_invoice                   crd_api_type_pkg.t_invoice_rec;
    l_interest_amount           com_api_type_pkg.t_money;
    l_interest_sum              com_api_type_pkg.t_money            := 0;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_from_id                   com_api_type_pkg.t_long_id;
    l_till_id                   com_api_type_pkg.t_long_id;
    l_eff_date                  date;
    l_event_type                com_api_type_pkg.t_dict_value;
    l_calc_interest_end_attr    com_api_type_pkg.t_dict_value;
    l_calc_interest_date_end    date;
    l_calc_due_date             date;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_account_id [#1], i_eff_date [#2], i_alg_calc_intr [#3]'
      , i_env_param1 => i_account_id
      , i_env_param2 => to_char(i_eff_date, 'dd.mm.yyyy hh24:mi:ss')
      , i_env_param3 => i_alg_calc_intr
    );

    if i_split_hash is null or i_inst_id is null then
        l_account := acc_api_account_pkg.get_account(
                         i_account_id   => i_account_id
                       , i_mask_error   => com_api_const_pkg.FALSE
                     );
    else
        l_account.inst_id    := i_inst_id;
        l_account.split_hash := i_split_hash;
    end if;

    l_calc_interest_end_attr :=
        get_interest_calc_end_date(
            i_account_id  => i_account_id
          , i_eff_date    => i_eff_date
          , i_split_hash  => l_account.split_hash
          , i_inst_id     => l_account.inst_id
        );

    l_eff_date := i_eff_date;

    l_eff_date := get_interest_start_date(
                      i_product_id   => i_product_id
                    , i_account_id   => i_account_id
                    , i_split_hash   => l_account.split_hash
                    , i_service_id   => i_service_id
                    , i_param_tab    => l_param_tab
                    , i_posting_date => null
                    , i_eff_date     => l_eff_date
                    , i_inst_id      => l_account.inst_id
                  );

    l_invoice := crd_invoice_pkg.get_last_invoice(
                     i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                   , i_object_id    => i_account_id
                   , i_split_hash   => l_account.split_hash
                   , i_mask_error   => com_api_const_pkg.TRUE
                 );

    -- Get Due Date
    l_calc_due_date :=
        crd_invoice_pkg.calc_next_invoice_due_date(
            i_service_id => i_service_id
          , i_account_id => i_account_id
          , i_split_hash => l_account.split_hash
          , i_inst_id    => l_account.inst_id
          , i_eff_date   => i_eff_date
          , i_mask_error => case l_calc_interest_end_attr
                                when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                                    then com_api_const_pkg.FALSE
                                when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                                    then com_api_const_pkg.TRUE
                                else com_api_const_pkg.FALSE
                            end
        );

    l_event_type :=
        coalesce(
            crd_cst_interest_pkg.get_interest_charge_event_type(
                i_account_id   => i_account_id
              , i_eff_date     => l_eff_date
              , i_period_date  => null
              , i_split_hash   => l_account.split_hash
              , i_event_type   => null
            )
          , crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
        );

    for p in (
        select d.id debt_id
             , c.account_type
             , c.currency
             , c.account_number
             , c.inst_id
          from crd_debt d
             , acc_account c
         where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
           and d.account_id = c.id
           and d.split_hash = l_account.split_hash
           and crd_cst_interest_pkg.charge_interest_needed(i_debt_id => d.id) = com_api_const_pkg.TRUE
    ) loop
        l_from_id := com_api_id_pkg.get_from_id_num(i_object_id => p.debt_id);
        l_till_id := com_api_id_pkg.get_till_id_num(i_object_id => p.debt_id);

        for r in (
            select x.balance_type
                 , x.fee_id
                 , x.add_fee_id
                 , x.amount
                 , x.start_date
                 , x.end_date
                 , b.bunch_type_id
                 , x.id
                 , x.macros_type_id
                 , x.interest_amount
                 , x.debt_intr_id
                 , x.due_date
              from (
                    select a.id debt_intr_id
                         , a.balance_type
                         , a.fee_id
                         , a.add_fee_id
                         , a.amount
                         , a.balance_date start_date
                         , nvl(lead(a.balance_date) over (partition by a.balance_type order by a.id), l_eff_date) end_date
                         , a.debt_id
                         , a.id
                         , d.inst_id
                         , d.macros_type_id
                         , a.interest_amount
                         , a.is_charged
                         , i.due_date
                      from crd_debt_interest a
                         , crd_debt d
                         , crd_invoice i
                     where a.debt_id         = p.debt_id
                       and (d.is_grace_enable = com_api_const_pkg.FALSE
                            or (l_invoice.grace_date is not null
                                and l_invoice.grace_date < l_eff_date
                                and d.oper_date  < l_invoice.invoice_date)
                           )
                       and d.id              = a.debt_id
                       and a.split_hash      = l_account.split_hash
                       and a.id between l_from_id and l_till_id
                       and a.invoice_id      = i.id(+)
                   ) x
                 , crd_event_bunch_type b
             where x.end_date        <= l_eff_date
               and b.event_type(+)    = l_event_type
               and x.is_charged       = com_api_const_pkg.FALSE
               and b.balance_type(+)  = x.balance_type
               and b.inst_id(+)       = x.inst_id
          order by bunch_type_id nulls first
        ) loop
            l_calc_interest_date_end :=
                case l_calc_interest_end_attr
                    when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                        then r.end_date
                    when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                        then nvl(r.due_date, l_calc_due_date)
                    else r.end_date
                end;

            trc_log_pkg.debug(
                i_text       => 'Calulate interest: r.interest_amount [#1], r.start_date [#2], l_calc_interest_date_end [#3]'
              , i_env_param1 => r.interest_amount
              , i_env_param2 => r.start_date
              , i_env_param3 => l_calc_interest_date_end
            );

            if nvl(r.interest_amount, 0) = 0 then
                -- Calculate interest amount. Base algorithm
                if i_alg_calc_intr in (
                       crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
                     , crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM
                   )
                then
                    l_interest_amount :=  round(
                        fcl_api_fee_pkg.get_fee_amount(
                            i_fee_id            => r.fee_id
                          , i_base_amount       => r.amount
                          , io_base_currency    => p.currency
                          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id         => i_account_id
                          , i_split_hash        => l_account.split_hash
                          , i_eff_date          => r.start_date
                          , i_start_date        => r.start_date
                          , i_end_date          => l_calc_interest_date_end
                        )
                      , case i_alg_calc_intr
                            when crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
                                then 4
                            when crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM
                                then 0
                        end
                    );

                    if r.add_fee_id is not null then
                        -- Calculate additional interest amount
                        l_interest_amount := l_interest_amount + round(
                            fcl_api_fee_pkg.get_fee_amount(
                                i_fee_id            => r.add_fee_id
                              , i_base_amount       => r.amount
                              , io_base_currency    => p.currency
                              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id         => i_account_id
                              , i_split_hash        => l_account.split_hash
                              , i_eff_date          => r.start_date
                              , i_start_date        => r.start_date
                              , i_end_date          => l_calc_interest_date_end
                            )
                          , case i_alg_calc_intr
                                when crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
                                    then 4
                                when crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM
                                    then 0
                            end
                        );
                    end if;

                -- Custom algorithm
                else
                    l_interest_amount :=  round(
                        crd_cst_interest_pkg.get_fee_amount(
                            i_fee_id            => r.fee_id
                          , i_base_amount       => r.amount
                          , io_base_currency    => p.currency
                          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id         => i_account_id
                          , i_split_hash        => l_account.split_hash
                          , i_eff_date          => l_eff_date   --r.start_date
                          , i_start_date        => r.start_date
                          , i_end_date          => l_calc_interest_date_end
                          , i_alg_calc_intr     => i_alg_calc_intr
                          , i_debt_id           => p.debt_id
                          , i_balance_type      => r.balance_type
                          , i_debt_intr_id      => r.debt_intr_id
                          , i_service_id        => i_service_id
                          , i_product_id        => i_product_id
                        )
                      , 4
                    );
                    if r.add_fee_id is not null then
                        -- Calculate additional interest amount
                        l_interest_amount := l_interest_amount + round(
                            crd_cst_interest_pkg.get_fee_amount(
                                i_fee_id            => r.add_fee_id
                              , i_base_amount       => r.amount
                              , io_base_currency    => p.currency
                              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id         => i_account_id
                              , i_split_hash        => l_account.split_hash
                              , i_eff_date          => l_eff_date   --r.start_date
                              , i_start_date        => r.start_date
                              , i_end_date          => l_calc_interest_date_end
                              , i_alg_calc_intr     => i_alg_calc_intr
                              , i_debt_id           => p.debt_id
                              , i_balance_type      => r.balance_type
                              , i_debt_intr_id      => r.debt_intr_id
                              , i_service_id        => i_service_id
                              , i_product_id        => i_product_id
                            )
                          , 4
                        );
                    end if;
                end if;
            else
                l_interest_amount := r.interest_amount;
            end if;

            l_interest_sum := l_interest_sum + l_interest_amount;

            if r.bunch_type_id is not null then
                if o_interest_tab.exists(r.bunch_type_id) then
                    o_interest_tab(r.bunch_type_id) := o_interest_tab(r.bunch_type_id) + l_interest_amount;
                else
                    o_interest_tab(r.bunch_type_id) := l_interest_amount;
                end if;
            end if;

            trc_log_pkg.debug(
                i_text       => 'Calulate interest: base amount [#1], fee_id [#2], add_fee_id [#3], interest amount [#4]'
              , i_env_param1 => r.amount
              , i_env_param2 => r.fee_id
              , i_env_param3 => r.add_fee_id
              , i_env_param4 => l_interest_amount
            );
        end loop;
    end loop;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> l_interest_sum [#1]'
      , i_env_param1 => l_interest_sum
    );

    return round(l_interest_sum);
end; --calculate_accrued_interest

procedure interest_change(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) as
    l_service_id                com_api_type_pkg.t_short_id;
begin
    for r in (
        select d.id debt_id
             , a.id account_id
             , a.inst_id
          from acc_account a
             , crd_debt d
         where a.id          = i_account_id
           and a.split_hash  = i_split_hash
           and decode(d.status, 'DBTSACTV', d.account_id, null) = a.id
    ) loop
        l_service_id :=
            crd_api_service_pkg.get_active_service(
                i_account_id => r.account_id
              , i_eff_date   => i_eff_date
              , i_split_hash => i_split_hash
              , i_mask_error => com_api_const_pkg.TRUE
            );

        set_interest(
            i_debt_id           => r.debt_id
          , i_eff_date          => i_eff_date
          , i_account_id        => r.account_id
          , i_service_id        => l_service_id
          , i_split_hash        => i_split_hash
          , i_is_forced         => com_api_const_pkg.TRUE
          , i_event_type        => crd_api_const_pkg.PROMOTIONAL_PERIOD_CYCLE_TYPE
        );
    end loop;
end interest_change;

procedure change_interest_rate(
    i_account_id        in      com_api_type_pkg.t_medium_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_service_id                com_api_type_pkg.t_short_id;
begin
    l_service_id :=
          crd_api_service_pkg.get_active_service(
              i_account_id => i_account_id
            , i_eff_date   => i_eff_date
            , i_split_hash => i_split_hash
            , i_mask_error => com_api_const_pkg.FALSE
          );

    for r in (
        select d.product_id
             , d.id debt_id
             , d.account_id
             , d.inst_id
          from crd_debt d
         where d.split_hash = i_split_hash
           and decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
    ) loop
        set_interest(
            i_debt_id     => r.debt_id
          , i_eff_date    => i_eff_date
          , i_account_id  => r.account_id
          , i_service_id  => l_service_id
          , i_split_hash  => i_split_hash
          , i_is_forced   => com_api_const_pkg.TRUE
          , i_event_type  => i_event_type
        );
    end loop;
end;

procedure change_interest_rate(
    i_product_id        in      com_api_type_pkg.t_medium_id
  , i_eff_date          in      date
  , i_event_type        in      com_api_type_pkg.t_dict_value
) is
begin
    for r in (
        select a.id account_id
             , a.inst_id
             , a.split_hash
          from acc_account a
             , prd_contract c
             , (select connect_by_root id product_id
                     , level level_priority
                     , id parent_id
                     , product_type
                     , case when parent_id is null then 1 else 0 end top_flag
                  from prd_product
                connect by prior id = parent_id
                  start with id = i_product_id
               ) p
         where c.product_id = p.parent_id
           and a.contract_id = c.id
    ) loop
        change_interest_rate(
            i_account_id => r.account_id
          , i_eff_date   => i_eff_date
          , i_split_hash => r.split_hash
          , i_event_type => i_event_type
          , i_inst_id    => r.inst_id
        );
    end loop;
end;

end crd_interest_pkg;
/
