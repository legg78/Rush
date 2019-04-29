create or replace package body crd_debt_pkg as

g_detailed_entities   com_api_type_pkg.t_dict_tab;

procedure product_change(
    i_contract_id       in      com_api_type_pkg.t_medium_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) is
    l_service_id                com_api_type_pkg.t_short_id;
begin
    for r in (
        select c.product_id
             , d.id debt_id
             , a.id account_id
             , a.inst_id
          from acc_account a
             , crd_debt d
             , prd_contract c
         where c.id = i_contract_id
           and a.contract_id = c.id
           and a.split_hash  = i_split_hash
           and decode(d.status, 'DBTSACTV', d.account_id, null) = a.id
    ) loop
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => r.account_id
              , i_attr_name         => null
              , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
              , i_split_hash        => i_split_hash
              , i_eff_date          => i_eff_date
              , i_inst_id           => r.inst_id
            );

        update crd_debt
           set product_id = r.product_id
         where id = r.debt_id;

        crd_interest_pkg.set_interest(
            i_debt_id           => r.debt_id
          , i_eff_date          => i_eff_date
          , i_account_id        => r.account_id
          , i_service_id        => l_service_id
          , i_split_hash        => i_split_hash
          , i_is_forced         => com_api_const_pkg.TRUE
          , i_event_type        => prd_api_const_pkg.EVENT_PRODUCT_CHANGE
        );
    end loop;
end product_change;

procedure set_balance(
    i_debt_id           in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_account_id        in      com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_is_overdue        in      com_api_type_pkg.t_boolean          default null
) is
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_product_id        com_api_type_pkg.t_short_id;
    l_fee_id            com_api_type_pkg.t_short_id;
    l_min_amount_due    com_api_type_pkg.t_money;
    l_repay_priority    com_api_type_pkg.t_tiny_id;
    l_from_id           com_api_type_pkg.t_long_id;
    l_till_id           com_api_type_pkg.t_long_id;
begin

    trc_log_pkg.debug('set_balance: i_debt_id=['||i_debt_id||'] i_eff_date=['||i_eff_date||'] i_split_hash=['||i_split_hash||']');

    l_from_id      := com_api_id_pkg.get_from_id_num(i_debt_id);
    l_till_id      := com_api_id_pkg.get_till_id_num(i_debt_id);

    merge into crd_debt_balance old
        using(
            select /*+ index(e acc_entry_macros_ndx) */ e.macros_id debt_id
                 , e.balance_type
                 -- prevention of wrong balance calculation when balance cross over zero
                 , greatest(sum(e.amount * e.balance_impact) * -1 * t.balance_impact, 0) amount
                 , max(e.posting_order) posting_order
              from acc_entry e
                 , crd_event_bunch_type s
                 , acc_entry_tpl t
             where e.macros_id      = i_debt_id
               and s.event_type     = crd_api_const_pkg.APPLY_PAYMENT_EVENT
               and s.inst_id        = i_inst_id
               and s.balance_type   = e.balance_type
               and e.split_hash     = i_split_hash
               and s.bunch_type_id  = t.bunch_type_id
               and s.balance_type   = t.balance_type
--               and e.id            >= l_from_id_date
             group by e.macros_id
                    , e.balance_type
                    , t.balance_impact
        ) new

        on(new.debt_id = old.debt_id and new.balance_type = old.balance_type
           and old.id between l_from_id and l_till_id
           and old.split_hash = i_split_hash)

        when matched then
            update
               set old.min_amount_due =
                    case
--                        when l_is_new = com_api_const_pkg.TRUE then 0 -- for NEW debts totaly recalc MAD
                        when new.amount > old.amount then old.min_amount_due -- for increased interest balance
                        when new.amount = 0 then 0
                        when nvl(i_is_overdue, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE and new.amount > old.amount then old.min_amount_due + new.amount - old.amount
                        else greatest(old.min_amount_due + least(0, (new.amount - old.amount)), 0)
                    end
                 , old.amount = new.amount
                 , old.posting_order = new.posting_order

        when not matched then
            insert (
                id
              , debt_id
              , balance_type
              , amount
              , repay_priority
              , min_amount_due
              , split_hash
              , posting_order
            ) values (
                (l_from_id + crd_debt_balance_seq.nextval)
              , new.debt_id
              , new.balance_type
              , new.amount
              , null
              -- for overdue balance mandatory amount should be equal to total amount
              , case nvl(i_is_overdue, com_api_const_pkg.FALSE) when com_api_const_pkg.FALSE then 0 else new.amount end
              , i_split_hash
              , new.posting_order
            );

    load_debt_param(
        i_debt_id       => i_debt_id
      , io_param_tab    => l_param_tab
      , i_split_hash    => i_split_hash
      , o_product_id    => l_product_id
    );

    for r in (
        select b.id
             , b.amount
             , b.balance_type
             , b.repay_priority
          from crd_debt_balance b
         where b.debt_id      = i_debt_id
           and (
                repay_priority is null
               )
           and b.split_hash   = i_split_hash
           and b.id between l_from_id and l_till_id
    ) loop

        rul_api_param_pkg.set_param(
            i_value         => r.balance_type
          , i_name          => 'BALANCE_TYPE'
          , io_params       => l_param_tab
        );

        l_fee_id :=
            prd_api_product_pkg.get_fee_id (
                i_product_id    => l_product_id
              , i_entity_type   => 'ENTTACCT'
              , i_object_id     => i_account_id
              , i_fee_type      => crd_api_const_pkg.MAD_PERCENTAGE_FEE_TYPE
              , i_split_hash    => i_split_hash
              , i_service_id    => i_service_id
              , i_params        => l_param_tab
              , i_eff_date      => i_eff_date
              , i_inst_id       => i_inst_id
            );

        l_min_amount_due := 0;
/*
        l_min_amount_due := round(
            fcl_api_fee_pkg.get_fee_amount(
                i_fee_id            => l_fee_id
              , i_base_amount       => r.amount
              , io_base_currency    => l_currency
              , i_entity_type       => 'ENTTACCT'
              , i_object_id         => l_account_id
              , i_eff_date          => i_eff_date
            )
        );
*/
        if r.repay_priority is null then
            l_repay_priority :=
                prd_api_product_pkg.get_attr_value_number (
                    i_product_id      => l_product_id
                  , i_entity_type     => 'ENTTACCT'
                  , i_object_id       => i_account_id
                  , i_attr_name       => crd_api_const_pkg.REPAYMENT_PRIORITY
                  , i_split_hash      => i_split_hash
                  , i_service_id      => i_service_id
                  , i_params          => l_param_tab
                  , i_eff_date        => i_eff_date
                  , i_inst_id         => i_inst_id
                );
        end if;

        update crd_debt_balance
           set repay_priority = nvl(l_repay_priority, repay_priority)
             , min_amount_due = least(nvl(min_amount_due, 0) + l_min_amount_due, amount)
         where id         = r.id;
    end loop;

end set_balance;

procedure load_debt_param(
    i_debt_id           in      com_api_type_pkg.t_long_id
  , io_param_tab        in out  com_api_type_pkg.t_param_tab
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , o_product_id           out  com_api_type_pkg.t_short_id
) is
begin
    for rec in (
        select d.product_id
             , d.service_id
             , d.account_id
             , d.oper_type
             , d.sttl_type
             , d.fee_type
             , d.terminal_type
             , d.oper_date
             , d.posting_date
             , d.sttl_day
             , d.currency
             , d.amount
             , d.debt_amount
             , d.mcc
             , d.aging_period
             , d.is_new
             , d.macros_type_id
             , d.inst_id
             , d.is_reversal
             , d.oper_id
          from crd_debt d
         where d.id = i_debt_id
    ) loop
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'OPER_TYPE'
          , i_value     => rec.oper_type
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'STTL_TYPE'
          , i_value     => rec.sttl_type
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'FEE_TYPE'
          , i_value     => rec.fee_type
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'TERMINAL_TYPE'
          , i_value     => rec.terminal_type
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'OPER_DATE'
          , i_value     => rec.oper_date
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'POSTING_DATE'
          , i_value     => rec.posting_date
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'STTL_DAY'
          , i_value     => rec.sttl_day
        );
        rul_api_param_pkg.set_param(
             io_params  => io_param_tab
          , i_name      => 'CURRENCY'
          , i_value     => rec.currency
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'AMOUNT'
          , i_value     => rec.amount
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'DEBT_AMOUNT'
          , i_value     => rec.debt_amount
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'MCC'
          , i_value     => rec.mcc
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'AGING_PERIOD'
          , i_value     => rec.aging_period
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'IS_NEW'
          , i_value     => rec.is_new
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'MACROS_TYPE'
          , i_value     => rec.macros_type_id
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'INST_ID'
          , i_value     => rec.inst_id
        );
        rul_api_param_pkg.set_param(
            io_params   => io_param_tab
          , i_name      => 'IS_REVERSAL'
          , i_value     => rec.is_reversal
        );

        if g_detailed_entities.count > 0 then
            for i in g_detailed_entities.first .. g_detailed_entities.last loop
                if g_detailed_entities(i) = com_api_const_pkg.PARTICIPANT_ISSUER then
                    for iss in (
                        select c.card_type_id
                             , p.inst_id iss_inst_id
                             , cn.contract_type iss_contract_type
                          from crd_debt d
                     left join opr_participant p on p.oper_id          = d.oper_id
                           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                     left join iss_card c on c.id = p.card_id
                     left join prd_contract cn on cn.id = c.contract_id
                         where d.id = i_debt_id
                    ) loop
                        rul_api_param_pkg.set_param(
                            i_name      => 'ISS_CONTRACT_TYPE'
                          , i_value     => iss.iss_contract_type
                          , io_params   => io_param_tab
                        );
                        rul_api_param_pkg.set_param(
                            i_name      => 'CARD_TYPE_ID'
                          , i_value     => iss.card_type_id
                          , io_params   => io_param_tab
                        );
                        rul_api_param_pkg.set_param(
                            i_name      => 'ISS_INST_ID'
                          , i_value     => iss.iss_inst_id
                          , io_params   => io_param_tab
                        );
                    end loop;
                elsif g_detailed_entities(i) = com_api_const_pkg.PARTICIPANT_ACQUIRER then
                    for acq in (
                        select o.merchant_name
                          from opr_operation o
                         where o.id = rec.oper_id
                    ) loop
                        rul_api_param_pkg.set_param(
                            i_name      => 'MERCHANT_NAME'
                          , i_value     => acq.merchant_name
                          , io_params   => io_param_tab
                        );
                    end loop;
                elsif g_detailed_entities(i) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL  then
                    for term in (
                        select p.terminal_id
                          from opr_participant p
                         where p.oper_id          = rec.oper_id
                           and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                           and p.terminal_id is not null
                    ) loop
                        rul_api_shared_data_pkg.load_extended_terminal_params(
                            i_terminal_id => term.terminal_id
                          , io_params     => io_param_tab
                        );
                    end loop;
                end if;
            end loop;
        end if;

        crd_cst_debt_pkg.load_debt_param(
            i_debt_id    => i_debt_id
          , i_account_id => rec.account_id
          , i_product_id => rec.product_id
          , i_service_id => rec.service_id
          , i_split_hash => i_split_hash
          , io_param_tab => io_param_tab
        );

        o_product_id := rec.product_id;
        exit;
    end loop;

--    raise no_data_found;
    /*
exception
    when others then
        com_api_error_pkg.raise_error(
            i_error         => 'DEBT_NOT_FOUND'
          , i_env_param1    => i_debt_id
          , i_env_param2    => i_split_hash
        );
    */
end load_debt_param;

procedure load_debt_param(
    i_debt_id           in      com_api_type_pkg.t_long_id
  , io_param_tab        in out  com_api_type_pkg.t_param_tab
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
) is
    l_product_id        com_api_type_pkg.t_short_id;
begin
    load_debt_param(
        i_debt_id           => i_debt_id
      , io_param_tab        => io_param_tab
      , i_split_hash        => i_split_hash
      , o_product_id        => l_product_id
    );
end load_debt_param;

procedure set_debt_paid(
    i_debt_id           in      com_api_type_pkg.t_long_id
  , o_unpaid_debt          out  com_api_type_pkg.t_money
) is
    l_from_id               com_api_type_pkg.t_long_id;
    l_till_id               com_api_type_pkg.t_long_id;
    l_uncharged_interest    com_api_type_pkg.t_count := 0;
begin
    l_from_id      := com_api_id_pkg.get_from_id_num(i_debt_id);
    l_till_id      := com_api_id_pkg.get_till_id_num(i_debt_id);

    select nvl(sum(amount), 0)
      into o_unpaid_debt
      from crd_debt_balance
     where debt_id    = i_debt_id
       and balance_type != acc_api_const_pkg.BALANCE_TYPE_LEDGER
       and id between l_from_id and l_till_id;

    if o_unpaid_debt = 0 then
        select count(1)
          into l_uncharged_interest
          from crd_debt_interest
         where debt_id    = i_debt_id
           and is_charged = com_api_const_pkg.FALSE
           and amount > 0
           and id between l_from_id and l_till_id;
    end if;

    trc_log_pkg.debug(
        i_text => 'set_debt_paid: debt_id [#1], unpaid debt [#2], uncharged interest [#3]'
      , i_env_param1 => i_debt_id
      , i_env_param2 => o_unpaid_debt
      , i_env_param3 => l_uncharged_interest
    );

    update crd_debt
       set status = case
                        when o_unpaid_debt = 0
                             and l_uncharged_interest = 0
                        then crd_api_const_pkg.DEBT_STATUS_PAID
                        else crd_api_const_pkg.DEBT_STATUS_ACTIVE
                    end
     where id = i_debt_id;

end set_debt_paid;

procedure set_debt_paid(
    i_debt_id           in      com_api_type_pkg.t_long_id
) is
    l_unpaid_debt       com_api_type_pkg.t_money;
begin
    set_debt_paid(
        i_debt_id           => i_debt_id
      , o_unpaid_debt       => l_unpaid_debt
    );
end set_debt_paid;

procedure set_detailed_entity_types(
    i_detailed_entities_array_id  in     com_api_type_pkg.t_short_id default null
) is
begin
    trc_log_pkg.debug('set_detailed_entity_types started, i_detailed_entities_array_id='||i_detailed_entities_array_id);

    if i_detailed_entities_array_id is not null then
        g_detailed_entities.delete();
        for rec in (
            select d.dict||d.code as entity
              from com_dictionary_vw d
             where i_detailed_entities_array_id is null
                or d.dict||d.code in (select e.element_value
                                        from com_array_element e
                                       where e.array_id = i_detailed_entities_array_id)
        ) loop
            g_detailed_entities(g_detailed_entities.count) := rec.entity;
            trc_log_pkg.debug('set_detailed_entity_types: added entity type ' || rec.entity);
        end loop;
    end if;
end set_detailed_entity_types;

function get_count_debt_for_period(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_start_date        in      date
  , i_end_date          in      date
) return com_api_type_pkg.t_short_id
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_count_debt_for_period: ';
    l_result           com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_account_id [#1], i_split_hash [#2], i_start_date [#3], i_end_date [#4]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_split_hash
      , i_env_param3 => i_start_date
      , i_env_param4 => i_end_date
    );

    select count(distinct cd.id)
      into l_result
      from crd_invoice ci
         , crd_invoice_debt id
         , crd_debt cd
     where ci.account_id = i_account_id
       and ci.split_hash = nvl(i_split_hash, ci.split_hash)
       and ci.invoice_date between i_start_date and i_end_date
       and id.invoice_id = ci.id
       and cd.id         = id.debt_id;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Finished success'
    );

    return l_result;

end get_count_debt_for_period;

procedure change_debt(
    i_debt_id           in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_account_id        in      com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id         default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_forced_interest   in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_unpaid_debt          out  com_api_type_pkg.t_money
) is
    l_service_id                com_api_type_pkg.t_short_id;
begin
    l_service_id := coalesce(
                        i_service_id
                      , crd_api_service_pkg.get_active_service(
                            i_account_id  => i_account_id
                          , i_split_hash  => i_split_hash
                          , i_eff_date    => i_eff_date
                          , i_mask_error  => com_api_const_pkg.FALSE
                        )
                    );
    set_balance(
        i_debt_id           => i_debt_id
      , i_eff_date          => i_eff_date
      , i_account_id        => i_account_id
      , i_service_id        => i_service_id
      , i_inst_id           => i_inst_id
      , i_split_hash        => i_split_hash
    );

    crd_interest_pkg.set_interest(
        i_debt_id           => i_debt_id
      , i_eff_date          => i_eff_date
      , i_account_id        => i_account_id
      , i_service_id        => i_service_id
      , i_split_hash        => i_split_hash
      , i_event_type        => i_event_type
      , i_is_forced         => i_forced_interest
    );

    set_debt_paid(
        i_debt_id           => i_debt_id
      , o_unpaid_debt       => o_unpaid_debt
    );
end change_debt;

procedure credit_clearance(
    i_account                       in      acc_api_type_pkg.t_account_rec
  , i_operation                     in      opr_api_type_pkg.t_oper_rec
  , i_macros_type_id                in      com_api_type_pkg.t_tiny_id
  , i_credit_bunch_type_id          in      com_api_type_pkg.t_tiny_id
  , i_over_bunch_type_id            in      com_api_type_pkg.t_tiny_id
  , i_card_id                       in      com_api_type_pkg.t_medium_id
  , i_card_type_id                  in      com_api_type_pkg.t_tiny_id
  , i_service_id                    in      com_api_type_pkg.t_short_id         default null
  , i_detailed_entities_array_id    in      com_api_type_pkg.t_short_id         default null
  , o_over_amount                      out  com_api_type_pkg.t_money
  , o_credit_amount                    out  com_api_type_pkg.t_money
) is
    LOG_PREFIX                     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.credit_clearance: ';
    l_eff_date                              date;
    l_service_id                            com_api_type_pkg.t_short_id;
    l_value                                 com_api_type_pkg.t_money;
    l_credit_limit                          com_api_type_pkg.t_money    := 0;
    l_overdraft_value                       com_api_type_pkg.t_money    := 0;
    l_overlimit_value                       com_api_type_pkg.t_money    := 0;
    l_param_tab                             com_api_type_pkg.t_param_tab;
    l_bunch_id                              com_api_type_pkg.t_long_id;
begin
    l_eff_date   := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_account.inst_id);

    l_service_id :=
        coalesce(
            i_service_id
          , crd_api_service_pkg.get_active_service(
                i_account_id  => i_account.account_id
              , i_eff_date    => l_eff_date
              , i_split_hash  => i_account.split_hash
              , i_mask_error  => com_api_const_pkg.TRUE
            )
        );

    if l_service_id is null then
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'credit service not found for account ID [#1]'
          , i_env_param1  => i_account.account_id
        );
    else
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'operation ID [#1], macros type ID [#2]'
          , i_env_param1  => i_operation.id
          , i_env_param2  => i_macros_type_id
        );

        set_detailed_entity_types(i_detailed_entities_array_id  => i_detailed_entities_array_id);

        acc_api_entry_pkg.flush_job;

        for r in (
            select * from (
                select e.balance
                     , m.id as macros_id
                     , m.macros_type_id
                     , m.amount
                     , m.posting_date
                     , m.amount_purpose
                     , e.sttl_day
                     , c.product_id
                     , e.split_hash
                     , e.balance_type
                     , a.currency
                     , a.inst_id
                     , nvl(t.aval_algorithm, acc_api_const_pkg.AVAIL_ALGORITHM_OWN) as aval_algorithm
                  from acc_macros m
                     , acc_entry e
                     , acc_account a
                     , prd_contract c
                     , acc_product_account_type t
                 where m.macros_type_id   = i_macros_type_id
                   and m.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and m.object_id        = i_operation.id
                   and e.macros_id        = m.id
                   and m.account_id       = a.id
                   and a.contract_id      = c.id
                   and t.product_id       = c.product_id
                   and t.account_type     = a.account_type
                   and not exists (
                           select 1
                             from crd_debt d
                            where d.id = m.id
                       )
                 order by
                       decode(e.balance_type, acc_api_const_pkg.BALANCE_TYPE_LEDGER, 1, 2)
                     , e.posting_order desc
            ) where rownum = 1
        ) loop
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'ledger balance [#1]'
              , i_env_param1  => r.balance
            );

            if r.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER and r.balance < 0 then
                for q in (
                    select b.balance
                         , b.currency
                         , t.rate_type
                         , b.balance_type
                      from acc_balance b
                         , acc_balance_type t
                     where b.split_hash   = r.split_hash
                       and t.balance_type = b.balance_type
                       and t.account_type = i_account.account_type
                       and t.inst_id      = b.inst_id
                       and b.account_id in (
                           select o2.account_id
                             from acc_account_object o
                                , acc_account_object o2
                            where o.account_id = i_account.account_id
                              and (
                                       r.aval_algorithm  = acc_api_const_pkg.AVAIL_ALGORITHM_OWN
                                   and o.account_id      = o2.account_id
                                   or
                                       r.aval_algorithm  = acc_api_const_pkg.AVAIL_ALGORITHM_CARD
                                   and o.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                   and o2.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                                   and o.object_id       = o2.object_id
                                  )
                           union
                           select i_account.account_id from dual
                       )
                       and b.balance_type in (crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
                                            , crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT
                                            , crd_api_const_pkg.BALANCE_TYPE_OVERLIMIT)
                ) loop
                    l_value := com_api_rate_pkg.convert_amount(
                                  i_src_amount    => q.balance
                                , i_src_currency  => q.currency
                                , i_dst_currency  => r.currency
                                , i_rate_type     => q.rate_type
                                , i_inst_id       => r.inst_id
                                , i_eff_date      => r.posting_date
                              );
                    if q.balance_type = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED then
                        l_credit_limit    := l_credit_limit    + l_value;
                    elsif q.balance_type = crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT then
                        l_overdraft_value := l_overdraft_value + l_value;
                    elsif q.balance_type = crd_api_const_pkg.BALANCE_TYPE_OVERLIMIT then
                        l_overlimit_value := l_overlimit_value + l_value;
                    end if;
                end loop;

                trc_log_pkg.debug(
                    i_text        => LOG_PREFIX || 'l_credit_limit [#1], l_overdraft_value [#2], l_overlimit_value [#3]'
                  , i_env_param1  => l_credit_limit
                  , i_env_param2  => l_overdraft_value
                  , i_env_param3  => l_overlimit_value
                );

                o_credit_amount := least(abs(r.balance), greatest(0, l_credit_limit - abs(l_overdraft_value)));
                o_over_amount   := greatest(0, abs(r.balance) - o_credit_amount);

                trc_log_pkg.debug(
                    i_text        => LOG_PREFIX || 'o_credit_amount [#1], o_over_amount [#2]'
                  , i_env_param1  => o_credit_amount
                  , i_env_param2  => o_over_amount
                );

                rul_api_param_pkg.set_param(
                    i_name           => 'CARD_TYPE_ID'
                  , i_value          => i_card_type_id
                  , io_params        => l_param_tab
                );

                -- Register an overlimit event when the account first goes to the overlimit
                if l_overlimit_value = 0 and o_over_amount > 0 then
                    evt_api_event_pkg.register_event(
                        i_event_type   => crd_api_const_pkg.OVERLIMIT_EVENT
                      , i_eff_date     => l_eff_date
                      , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id    => i_account.account_id
                      , i_inst_id      => i_account.inst_id
                      , i_split_hash   => i_account.split_hash
                      , i_param_tab    => l_param_tab
                    );
                end if;

                acc_api_entry_pkg.put_bunch(
                    o_bunch_id       => l_bunch_id
                  , i_bunch_type_id  => i_credit_bunch_type_id
                  , i_macros_id      => r.macros_id
                  , i_amount         => o_credit_amount
                  , i_currency       => i_account.currency
                  , i_account_type   => i_account.account_type
                  , i_account_id     => i_account.account_id
                  , i_param_tab      => l_param_tab
                );
                acc_api_entry_pkg.put_bunch(
                    o_bunch_id       => l_bunch_id
                  , i_bunch_type_id  => i_over_bunch_type_id
                  , i_macros_id      => r.macros_id
                  , i_amount         => o_over_amount
                  , i_currency       => i_account.currency
                  , i_account_type   => i_account.account_type
                  , i_account_id     => i_account.account_id
                  , i_param_tab      => l_param_tab
                );

                acc_api_entry_pkg.flush_job;
            end if;

            crd_api_debt_pkg.create_debt(
                i_macros_id      => r.macros_id
              , i_card_id        => i_card_id
              , i_oper_id        => i_operation.id
              , i_oper_type      => i_operation.oper_type
              , i_sttl_type      => i_operation.sttl_type
              , i_fee_type       => case
                                        when r.amount_purpose like fcl_api_const_pkg.FEE_TYPE_STATUS_KEY || '%'
                                        then r.amount_purpose
                                        else i_operation.oper_reason
                                    end
              , i_macros_type_id => r.macros_type_id
              , i_terminal_type  => i_operation.terminal_type
              , i_oper_date      => i_operation.oper_date
              , i_currency       => i_account.currency
              , i_amount         => r.amount
              , i_mcc            => i_operation.mcc
              , i_account_id     => i_account.account_id
              , i_posting_date   => r.posting_date
              , i_sttl_day       => r.sttl_day
              , i_inst_id        => i_account.inst_id
              , i_agent_id       => i_account.agent_id
              , i_product_id     => r.product_id
              , i_split_hash     => r.split_hash
              , i_is_reversal    => i_operation.is_reversal
              , i_original_id    => i_operation.original_id
            );
        end loop;
    end if;
end credit_clearance;

procedure lending_clearance(
    i_account                       in      acc_api_type_pkg.t_account_rec
  , i_operation                     in      opr_api_type_pkg.t_oper_rec
  , i_macros_type_id                in      com_api_type_pkg.t_tiny_id
  , i_bunch_type_id                 in      com_api_type_pkg.t_tiny_id
  , i_service_id                    in      com_api_type_pkg.t_short_id         default null
) is
    LOG_PREFIX                     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.lending_clearance: ';
    l_eff_date                              date;
    l_service_id                            com_api_type_pkg.t_short_id;
    l_bunch_id                              com_api_type_pkg.t_long_id;
    l_param_tab                             com_api_type_pkg.t_param_tab;

    procedure add_debt_balance(
        i_debt_id        in     com_api_type_pkg.t_long_id
      , i_eff_date       in     date
      , i_balance_type   in     com_api_type_pkg.t_dict_value
      , i_bunch_type_id  in     com_api_type_pkg.t_tiny_id
      , i_split_hash     in     com_api_type_pkg.t_tiny_id
    ) is
        l_from_id               com_api_type_pkg.t_long_id;
        l_till_id               com_api_type_pkg.t_long_id;
    begin
        l_from_id := com_api_id_pkg.get_from_id_num(i_object_id => i_debt_id);
        l_till_id := com_api_id_pkg.get_till_id_num(i_object_id => i_debt_id);

        merge into crd_debt_balance old
        using(
            select /*+ index(e acc_entry_macros_ndx) */
                   e.macros_id as debt_id
                 , e.balance_type
                   -- prevention of wrong balance calculation when balance crosses over zero
                 , greatest(sum(e.amount * e.balance_impact) * -1 * t.balance_impact, 0) as amount
                 , max(e.posting_order)                                                  as posting_order
              from acc_entry e
                 , acc_entry_tpl t
             where e.macros_id      = i_debt_id
               and e.split_hash     = i_split_hash
               and e.balance_type   = i_balance_type
               and t.balance_type   = e.balance_type
               and t.bunch_type_id  = i_bunch_type_id
             group by e.macros_id
                    , e.balance_type
                    , t.balance_impact
        ) new
        on (
               new.debt_id      = old.debt_id
           and new.balance_type = old.balance_type
           and old.id between l_from_id and l_till_id
           and old.split_hash   = i_split_hash
        )
        when matched then
            update
               set old.min_amount_due =
                       case
                           when new.amount = 0
                           then 0
                           else greatest(old.min_amount_due + least(0, (new.amount - old.amount)), 0)
                       end
                 , old.amount        = new.amount
                 , old.posting_order = new.posting_order
        when not matched then
            insert (
                id
              , debt_id
              , balance_type
              , amount
              , repay_priority
              , min_amount_due
              , split_hash
              , posting_order
            ) values (
                l_from_id + crd_debt_balance_seq.nextval
              , i_debt_id
              , i_balance_type
              , new.amount
              , null
                -- for overdue balance mandatory amount should be equal to total amount
              , 0
              , i_split_hash
              , new.posting_order
            );
    end add_debt_balance;

begin
    l_eff_date  := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_account.inst_id);

    l_service_id :=
        coalesce(
            i_service_id
          , crd_api_service_pkg.get_active_service(
                i_account_id  => i_account.account_id
              , i_eff_date    => l_eff_date
              , i_split_hash  => i_account.split_hash
              , i_mask_error  => com_api_const_pkg.TRUE
            )
        );

    if l_service_id is null then
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'credit service not found for account ID [#1]'
          , i_env_param1  => i_account.account_id
        );
    else
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'operation ID [#1], macros type ID [#2]'
          , i_env_param1  => i_operation.id
          , i_env_param2  => i_macros_type_id
        );

        acc_api_entry_pkg.flush_job;

        for r in (
            select e.balance
                 , m.id macros_id
                 , e.balance_type
                 , e.split_hash
              from acc_macros m
                 , acc_entry e
             where m.macros_type_id = i_macros_type_id
               and m.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and e.balance_type in (acc_api_const_pkg.BALANCE_TYPE_LEDGER)
               and m.object_id      = i_operation.id
               and e.macros_id      = m.id
               and rownum           = 1
        ) loop
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'ledger balance [#1]'
              , i_env_param1  => r.balance
            );

            acc_api_entry_pkg.put_bunch(
                o_bunch_id       => l_bunch_id
              , i_bunch_type_id  => i_bunch_type_id
              , i_macros_id      => r.macros_id
              , i_amount         => i_operation.oper_amount
              , i_currency       => i_account.currency
              , i_account_type   => i_account.account_type
              , i_account_id     => i_account.account_id
              , i_param_tab      => l_param_tab
            );

            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'bunch was created with ID [#1] and amount [#2]'
              , i_env_param1  => l_bunch_id
              , i_env_param2  => i_operation.oper_amount
            );

            acc_api_entry_pkg.flush_job;

            -- Add new record because it isn't handled by set_balance()
            -- since Lending balance is not present in table crd_event_bunch_type
            add_debt_balance(
                i_debt_id        => r.macros_id
              , i_eff_date       => l_eff_date
              , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_LENDING
              , i_bunch_type_id  => i_bunch_type_id
              , i_split_hash     => i_account.split_hash
            );
        end loop;
    end if;
end lending_clearance;

end;
/
