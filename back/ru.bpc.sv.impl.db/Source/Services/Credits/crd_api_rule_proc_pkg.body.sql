create or replace package body crd_api_rule_proc_pkg is
/************************************************************
 * Credit module operations processing rules <br />
 * Created by Kolodkina Y.(kolodkina@bpcbt.com)  at 02.06.2014 <br />
 * Module: CRD_API_RULE_PROC_PKG <br />
 * @headcom
 ***********************************************************/

procedure debt_in_collection
is
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_event_date                    date;
    l_account_id                    com_api_type_pkg.t_long_id;
begin
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_split_hash  := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');

    if l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        begin
            select account_id
              into l_account_id
              from crd_invoice
             where id = l_object_id;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'INVOICE_NOT_FOUND'
                  , i_env_param1    => l_object_id
                );

        end;

    elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then

        l_account_id := l_object_id;

    else
        return;
    end if;

    crd_overdue_pkg.debt_in_collection(
        i_account_id        => l_account_id
      , i_eff_date          => l_event_date
      , i_split_hash        => l_split_hash
    );
end;

procedure resume_credit_calc(
    i_status                com_api_type_pkg.t_dict_value
) is
    l_account_name          com_api_type_pkg.t_name;
    l_account               acc_api_type_pkg.t_account_rec;
    l_service_id            com_api_type_pkg.t_short_id;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_selector              com_api_type_pkg.t_dict_value;
    l_host_date             date;
begin
    l_selector     := opr_api_shared_data_pkg.get_param_char(
                          i_name         => 'OPERATION_SELECTOR'
                        , i_mask_error   => com_api_type_pkg.TRUE
                        , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                      );
    l_account_name := opr_api_shared_data_pkg.get_param_char(
                          i_name         => 'ACCOUNT_NAME'
                        , i_mask_error   => com_api_const_pkg.TRUE
                      );

    l_oper_id := opr_api_shared_data_pkg.get_operation_id(i_selector => l_selector);

    begin
        select host_date
          into l_host_date
          from opr_operation
         where id = l_oper_id;
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text        => 'Operation not found by oper_id [#1]'
              , i_env_param1  => l_oper_id
            );
            return;
    end;

    if l_account_name is not null then
        opr_api_shared_data_pkg.get_account(
            i_name         => l_account_name
          , o_account_rec  => l_account
        );
    else
        l_account.account_id := opr_api_shared_data_pkg.get_participant(
                                    i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER
                                ).account_id;
        l_account.split_hash := com_api_hash_pkg.get_split_hash(
                                    i_entity_type      => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                  , i_object_id        => l_account.account_id
                                );
    end if;

    l_service_id := crd_api_service_pkg.get_active_service(
                        i_account_id  => l_account.account_id
                      , i_eff_date    => l_host_date
                      , i_split_hash  => l_account.split_hash
                    );

    if l_service_id is not null then
        crd_api_dispute_pkg.set_debt_status(
            i_oper_id        => l_oper_id
          , i_status         => i_status
        );
    else
        trc_log_pkg.debug(
            i_text          => 'Credit service not found for account [#1]'
          , i_env_param1    => l_account.account_id
        );
    end if;
end resume_credit_calc;

procedure suspend_credit_calc
is
begin
    resume_credit_calc(
        i_status     => crd_api_const_pkg.DEBT_STATUS_SUSPENDED
    );
exception
    when others then
        trc_log_pkg.debug('error executing suspend_credit_calc: ' || sqlerrm);

        opr_api_shared_data_pkg.rollback_process(
            i_id     => opr_api_shared_data_pkg.get_operation().id
          , i_status => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason => aup_api_const_pkg.RESP_CODE_ERROR
        );
end;

procedure continue_credit_calc
is
begin
    resume_credit_calc(
        i_status     => crd_api_const_pkg.DEBT_STATUS_ACTIVE
    );
exception
    when others then
        trc_log_pkg.debug('error executing continue_credit_calc: ' || sqlerrm);

        opr_api_shared_data_pkg.rollback_process(
            i_id     => opr_api_shared_data_pkg.get_operation().id
          , i_status => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason => aup_api_const_pkg.RESP_CODE_ERROR
        );
end;

procedure cancel_credit_calc is
    l_macros_type                   com_api_type_pkg.t_tiny_id;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_prev_date                     date;
    l_next_date                     date;
    l_is_new                        com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_operation                     opr_api_type_pkg.t_oper_rec;
    l_iss_participant               opr_api_type_pkg.t_oper_part_rec;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_eff_date                      date;
    l_interest_calc_start_date      com_api_type_pkg.t_dict_value;
    l_param_tab                     com_api_type_pkg.t_param_tab;
    l_selector                      com_api_type_pkg.t_dict_value;
    l_account_name                  com_api_type_pkg.t_name;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_remainder_amount              com_api_type_pkg.t_money;
begin
    l_selector :=
        opr_api_shared_data_pkg.get_param_char(
            i_name         => 'OPERATION_SELECTOR'
          , i_mask_error   => com_api_type_pkg.TRUE
          , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_ORIGINAL
        );

    l_account_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name         => 'ACCOUNT_NAME'
        );

    opr_api_shared_data_pkg.get_account(
        i_name             => l_account_name
      , o_account_rec      => l_account
    );

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account.account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => l_account.split_hash
          , i_eff_date          => com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_account.inst_id)
          , i_mask_error        => com_api_const_pkg.TRUE
        );

    if l_service_id is not null then

        l_oper_id := opr_api_shared_data_pkg.get_operation_id(i_selector => l_selector);

        if l_oper_id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
            );
        end if;

        l_macros_type := rul_api_param_pkg.get_param_num('MACROS_TYPE', opr_api_shared_data_pkg.g_params);

        l_operation := opr_api_shared_data_pkg.get_operation;

        l_iss_participant := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER);

        acc_api_entry_pkg.flush_job;

        for r in (
            select *
              from (
                select
                    e.balance
                    , m.id macros_id
                    , m.amount
                    , m.posting_date
                    , e.sttl_day
                    , c.product_id
                    , e.split_hash
                from
                    acc_macros m
                    , acc_entry e
                    , acc_account a
                    , prd_contract c
                where
                    m.macros_type_id  = l_macros_type
                    and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                    and m.object_id   = l_oper_id
                    and e.macros_id   = m.id
                    -- and e.balance_type = 'BLTP1010' --ledger
                    and m.account_id  = a.id
                    and a.contract_id = c.id
                order by
                    e.posting_order desc
              )
             where rownum = 1
        ) loop
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type    => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => l_account.account_id
              , i_split_hash    => r.split_hash
              , o_prev_date     => l_prev_date
              , o_next_date     => l_next_date
            );

            if l_next_date is not null then
                l_is_new := com_api_type_pkg.TRUE;
            end if;

            crd_api_payment_pkg.create_payment(
                i_macros_id     => r.macros_id
              , i_oper_id       => l_operation.id
              , i_is_reversal   => l_operation.is_reversal
              , i_original_id   => l_operation.original_id
              , i_oper_date     => l_operation.oper_date
              , i_currency      => l_account.currency
              , i_amount        => r.amount
              , i_account_id    => l_account.account_id
              , i_card_id       => l_iss_participant.card_id
              , i_posting_date  => r.posting_date
              , i_sttl_day      => r.sttl_day
              , i_inst_id       => l_account.inst_id
              , i_agent_id      => l_account.agent_id
              , i_product_id    => r.product_id
              , i_is_new        => l_is_new
              , i_split_hash    => r.split_hash
            );

            l_interest_calc_start_date :=
                prd_api_product_pkg.get_attr_value_char(
                    i_product_id    => r.product_id
                  , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => l_account.account_id
                  , i_attr_name     => crd_api_const_pkg.INTEREST_CALC_START_DATE
                  , i_split_hash    => r.split_hash
                  , i_service_id    => l_service_id
                  , i_params        => l_param_tab
                  , i_eff_date      => r.posting_date
                  , i_inst_id       => l_account.inst_id
                );

            case l_interest_calc_start_date
                when crd_api_const_pkg.INTEREST_CALC_DATE_POSTING
                then l_eff_date := r.posting_date;

                when crd_api_const_pkg.INTEREST_CALC_DATE_TRANSACTION
                then l_eff_date := l_operation.oper_date;

                when crd_api_const_pkg.INTEREST_CALC_DATE_SETTLEMENT then

                    begin
                        select sttl_date
                          into l_eff_date
                          from (
                                select sttl_date
                                  from com_settlement_day
                                 where sttl_day = r.sttl_day
                                   and inst_id in (l_account.inst_id, ost_api_const_pkg.DEFAULT_INST)
                                 order by inst_id
                               )
                         where rownum = 1;
                    exception
                        when no_data_found then
                            l_eff_date := trunc(r.posting_date);
                    end;

                else l_eff_date := r.posting_date;

            end case;

            l_eff_date := crd_interest_pkg.get_interest_start_date(
                              i_product_id   => r.product_id
                            , i_account_id   => l_account.account_id
                            , i_split_hash   => r.split_hash
                            , i_service_id   => l_service_id
                            , i_param_tab    => l_param_tab
                            , i_posting_date => r.posting_date
                            , i_eff_date     => l_eff_date
                            , i_inst_id      => l_account.inst_id
                          );

            crd_payment_pkg.apply_payment(
                i_payment_id        => r.macros_id
              , i_eff_date          => l_eff_date
              , i_split_hash        => r.split_hash
              , i_oper_id           => l_oper_id
              , i_charge_interest   => com_api_const_pkg.FALSE
            );

            crd_api_dispute_pkg.set_debt_status(
                i_oper_id           => l_oper_id
              , i_status            => crd_api_const_pkg.DEBT_STATUS_CANCELED
            );

            crd_payment_pkg.apply_payment(
                i_payment_id        => r.macros_id
              , i_eff_date          => l_eff_date
              , i_split_hash        => r.split_hash
              , o_remainder_amount  => l_remainder_amount
            );
        end loop;

        -- if no repayment of accrued interest
        if l_eff_date is null then
            crd_api_dispute_pkg.set_debt_status(
                i_oper_id           => l_oper_id
              , i_status            => crd_api_const_pkg.DEBT_STATUS_CANCELED
            );
        end if;

    else
        trc_log_pkg.debug(
            i_text          => 'Credit service not found on account [#1]'
          , i_env_param1    => l_account.account_id
        );

    end if;

exception
    when others then
        trc_log_pkg.debug('error executing cancel_credit_calc: ' || sqlerrm);

        opr_api_shared_data_pkg.rollback_process(
            i_id     => opr_api_shared_data_pkg.get_operation().id
          , i_status => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason => aup_api_const_pkg.RESP_CODE_ERROR
        );
end cancel_credit_calc;

procedure credit_limit_increase
is
    l_diff_amount               com_api_type_pkg.t_money        := 0;
    l_account_name              com_api_type_pkg.t_name;
    l_account                   acc_api_type_pkg.t_account_rec;
    l_balances                  com_api_type_pkg.t_amount_by_name_tab;
    l_debt_id_tab               com_api_type_pkg.t_number_tab;
    l_bunch_id                  com_api_type_pkg.t_long_id;
    l_interest_calc_start_date  com_api_type_pkg.t_dict_value;
    l_service_id                com_api_type_pkg.t_short_id;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_eff_date                  date;
    l_debt_added                com_api_type_pkg.t_boolean;
    l_product_id                com_api_type_pkg.t_short_id;
begin
    l_account_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'ACCOUNT_NAME'
        );

    opr_api_shared_data_pkg.get_account(
        i_name              => l_account_name
      , o_account_rec       => l_account
    );

    acc_api_entry_pkg.flush_job;

    acc_api_balance_pkg.get_account_balances(
        i_account_id     => l_account.account_id
      , o_balances       => l_balances
      , i_lock_balances  => com_api_type_pkg.TRUE
    );

    if l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED) and l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT) then
        l_diff_amount := greatest(0, nvl(l_balances(crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED).amount, 0) - abs(nvl(l_balances(crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT).amount, 0)));
    end if;

    if l_diff_amount >= 0 then

        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => l_account.account_id
              , i_attr_name         => null
              , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
              , i_split_hash        => l_account.split_hash
              , i_eff_date          => opr_api_shared_data_pkg.get_operation().host_date
              , i_inst_id           => l_account.inst_id
              , i_mask_error        => com_api_const_pkg.TRUE
            );

        if l_service_id is not null then

            l_product_id :=
                prd_api_product_pkg.get_product_id(
                    i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => l_account.account_id
                  , i_eff_date      => opr_api_shared_data_pkg.get_operation().host_date
                  , i_inst_id       => l_account.inst_id
                );

            l_interest_calc_start_date :=
                prd_api_product_pkg.get_attr_value_char(
                    i_product_id    => l_product_id
                  , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => l_account.account_id
                  , i_attr_name     => crd_api_const_pkg.INTEREST_CALC_START_DATE
                  , i_split_hash    => l_account.split_hash
                  , i_service_id    => l_service_id
                  , i_params        => l_param_tab
                  , i_eff_date      => opr_api_shared_data_pkg.get_operation().host_date
                  , i_inst_id       => l_account.inst_id
                );

            case l_interest_calc_start_date
                when crd_api_const_pkg.INTEREST_CALC_DATE_POSTING
                then l_eff_date := opr_api_shared_data_pkg.get_operation().host_date;

                when crd_api_const_pkg.INTEREST_CALC_DATE_TRANSACTION
                then l_eff_date := opr_api_shared_data_pkg.get_operation().oper_date;

                when crd_api_const_pkg.INTEREST_CALC_DATE_SETTLEMENT then

                    begin
                        select sttl_date
                          into l_eff_date
                          from (
                                select sttl_date
                                  from com_settlement_day
                                 where inst_id in (l_account.inst_id, ost_api_const_pkg.DEFAULT_INST)
                                   and is_open = com_api_const_pkg.TRUE
                                 order by inst_id
                               )
                         where rownum = 1;
                    exception
                        when no_data_found then
                            l_eff_date := trunc(opr_api_shared_data_pkg.get_operation().host_date);
                    end;

                else l_eff_date := opr_api_shared_data_pkg.get_operation().host_date;

            end case;

            l_eff_date := crd_interest_pkg.get_interest_start_date(
                              i_product_id   => l_product_id
                            , i_account_id   => l_account.account_id
                            , i_split_hash   => l_account.split_hash
                            , i_service_id   => l_service_id
                            , i_param_tab    => l_param_tab
                            , i_posting_date => opr_api_shared_data_pkg.get_operation().host_date
                            , i_eff_date     => l_eff_date
                            , i_inst_id      => l_account.inst_id
                          );

            for r in (
                select d.id debt_id
                     , e.bunch_type_id
                     , b.amount
                     , b.balance_type
                     , d.macros_type_id
                     , d.card_id
                  from crd_debt d
                     , crd_debt_balance b
                     , crd_event_bunch_type e
                 where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account.account_id
                   and d.id           = b.debt_id
                   and b.amount       > 0
                   and e.balance_type = b.balance_type
                   and e.inst_id      = d.inst_id
                   and e.event_type   = crd_api_const_pkg.INCREASE_LIMIT_EVENT
                   and e.bunch_type_id is not null
                   and d.split_hash   = l_account.split_hash
                   and b.split_hash   = l_account.split_hash
                   and b.id >= com_api_id_pkg.get_from_id(d.id)
                 order by d.is_new, b.repay_priority, d.posting_date
            ) loop

                trc_log_pkg.debug('credit_limit_increase: move debt=['||r.debt_id||'] balance type=['||r.balance_type||'] amount=['||r.amount||']');

                rul_api_param_pkg.set_param (
                    i_name       => 'CARD_TYPE_ID'
                    , io_params  => l_param_tab
                    , i_value    => iss_api_card_pkg.get_card(i_card_id => r.card_id).card_type_id
                );

                acc_api_entry_pkg.put_bunch(
                    o_bunch_id          => l_bunch_id
                  , i_bunch_type_id     => r.bunch_type_id
                  , i_macros_id         => r.debt_id
                  , i_amount            => least(l_diff_amount, r.amount)
                  , i_currency          => l_account.currency
                  , i_account_type      => l_account.account_type
                  , i_account_id        => l_account.account_id
                  , i_posting_date      => l_eff_date
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

                l_diff_amount := l_diff_amount - r.amount;

                trc_log_pkg.debug('credit_limit_increase: diff amount=['||l_diff_amount||']');

                exit when l_diff_amount <= 0;

            end loop;

            acc_api_entry_pkg.flush_job;

            for i in 1..l_debt_id_tab.count loop
                crd_debt_pkg.set_balance(
                    i_debt_id           => l_debt_id_tab(i)
                  , i_eff_date          => l_eff_date
                  , i_account_id        => l_account.account_id
                  , i_service_id        => l_service_id
                  , i_inst_id           => l_account.inst_id
                  , i_split_hash        => l_account.split_hash
                );

                crd_interest_pkg.set_interest(
                    i_debt_id           => l_debt_id_tab(i)
                  , i_eff_date          => l_eff_date
                  , i_account_id        => l_account.account_id
                  , i_service_id        => l_service_id
                  , i_split_hash        => l_account.split_hash
                  , i_event_type        => crd_api_const_pkg.INCREASE_LIMIT_EVENT
                );

            end loop;
        end if;
    end if;
end;

procedure calc_total_accrued_amount
is
    l_amount_name               com_api_type_pkg.t_name;
    l_oper_id                   com_api_type_pkg.t_long_id;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_total_amount              com_api_type_pkg.t_money;
begin
    l_oper_id := opr_api_shared_data_pkg.get_operation().original_id;

    begin
        select nvl(sum(interest_amount + debt_amount), 0)
             , currency
          into l_total_amount
             , l_currency
          from (
                select sum(e.amount) interest_amount
                     , d.amount debt_amount
                     , d.id
                     , d.currency
                  from crd_debt d
                     , acc_entry e
                 where d.oper_id          = l_oper_id
                   and d.id               = e.macros_id
                   and e.account_id       = d.account_id
                   and e.transaction_type = 'TRNT1003'
                 group by
                       d.amount
                     , d.id
                     , d.currency
               )
         group by currency;
    exception
        when no_data_found then
            l_total_amount := 0;
            select min(currency)
              into l_currency
              from crd_debt
             where oper_id = l_oper_id;
    end;

    l_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'RESULT_AMOUNT_NAME'
        );

    opr_api_shared_data_pkg.set_amount(
        i_name              => l_amount_name
        , i_amount          => l_total_amount
        , i_currency        => l_currency
    );
end;

procedure calc_accrued_amount
is
    l_amount_name               com_api_type_pkg.t_name;
    l_oper_id                   com_api_type_pkg.t_long_id;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_total_amount              com_api_type_pkg.t_money;
begin
    l_oper_id := opr_api_shared_data_pkg.get_operation().original_id;

    begin
        select nvl(sum(interest_amount + debt_amount), 0)
             , currency
          into l_total_amount
             , l_currency
          from (
                select nvl(sum(e.amount),0) interest_amount
                     , d.amount debt_amount
                     , d.id
                     , d.currency
                  from crd_debt d
                     , acc_entry e
                 where d.oper_id          = l_oper_id
                   and d.id               = e.macros_id(+)
                   and d.account_id       = e.account_id(+)
                   and e.transaction_type(+) = 'TRNT1003'
                 group by
                       d.amount
                     , d.id
                     , d.currency
               )
         group by currency;
    exception
        when no_data_found then
            l_total_amount := 0;
            select min(currency)
              into l_currency
              from crd_debt
             where oper_id = l_oper_id;
    end;

    l_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'RESULT_AMOUNT_NAME'
        );

    opr_api_shared_data_pkg.set_amount(
        i_name              => l_amount_name
        , i_amount          => l_total_amount
        , i_currency        => l_currency
    );
end calc_accrued_amount;

procedure credit_clearance
is
    l_account                       acc_api_type_pkg.t_account_rec;
    l_credit_amount                 com_api_type_pkg.t_money;
    l_over_amount                   com_api_type_pkg.t_money;
    l_amount_name                   com_api_type_pkg.t_name;
    l_issuer                        opr_api_type_pkg.t_oper_part_rec;
begin
    opr_api_shared_data_pkg.get_account(
        i_name         => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec  => l_account
    );

    l_issuer := opr_api_shared_data_pkg.get_participant(
                    i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER
                );

    crd_debt_pkg.credit_clearance(
        i_account                     => l_account
      , i_operation                   => opr_api_shared_data_pkg.get_operation()
      , i_macros_type_id              => opr_api_shared_data_pkg.get_param_num(i_name => 'MACROS_TYPE')
      , i_credit_bunch_type_id        => opr_api_shared_data_pkg.get_param_num(i_name => 'CREDIT_BUNCH_TYPE')
      , i_over_bunch_type_id          => opr_api_shared_data_pkg.get_param_num(i_name => 'OVERLIMIT_BUNCH_TYPE')
      , i_card_id                     => l_issuer.card_id
      , i_card_type_id                => l_issuer.card_type_id
      , i_service_id                  => null
      , i_detailed_entities_array_id  => opr_api_shared_data_pkg.get_param_num(
                                             i_name       => 'DETAILED_ENTITIES_ARRAY_ID'
                                           , i_mask_error => com_api_const_pkg.TRUE
                                         )
      , o_over_amount                 => l_over_amount
      , o_credit_amount               => l_credit_amount
    );

    if l_over_amount is not null then
        l_amount_name := opr_api_shared_data_pkg.get_param_char(
                             i_name       => 'OVERLIMIT_AMOUNT_NAME'
                           , i_mask_error => com_api_const_pkg.TRUE
                         );
        if l_amount_name is not null then
            opr_api_shared_data_pkg.set_amount(
                i_name     => l_amount_name
              , i_amount   => l_over_amount
              , i_currency => l_account.currency
            );
        end if;
    end if;

    if l_credit_amount is not null then
        l_amount_name := opr_api_shared_data_pkg.get_param_char(
                             i_name       => 'OVERDRAFT_AMOUNT_NAME'
                           , i_mask_error => com_api_const_pkg.TRUE
                         );
        if l_amount_name is not null then
            opr_api_shared_data_pkg.set_amount(
                i_name     => l_amount_name
              , i_amount   => l_credit_amount
              , i_currency => l_account.currency
            );
        end if;
    end if;
end credit_clearance;

procedure credit_payment
is
    l_macros_type                   com_api_type_pkg.t_tiny_id;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_prev_date                     date;
    l_next_date                     date;
    l_is_new                        com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_operation                     opr_api_type_pkg.t_oper_rec;
    l_iss_participant               opr_api_type_pkg.t_oper_part_rec;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_eff_date                      date;
    l_interest_calc_start_date      com_api_type_pkg.t_dict_value;
    l_param_tab                     com_api_type_pkg.t_param_tab;
    l_remainder_amount              com_api_type_pkg.t_money;
    l_allow_dpp_acceleration        com_api_type_pkg.t_boolean;
    i_detailed_entities_array_id    com_api_type_pkg.t_short_id;
begin
    l_macros_type     := opr_api_shared_data_pkg.get_param_num('MACROS_TYPE');
    l_operation       := opr_api_shared_data_pkg.get_operation;
    l_iss_participant := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER);

    i_detailed_entities_array_id := rul_api_param_pkg.get_param_num(
                                        i_name        => 'DETAILED_ENTITIES_ARRAY_ID'
                                      , io_params     => opr_api_shared_data_pkg.g_params
                                      , i_mask_error  => com_api_const_pkg.TRUE
                                    );

    crd_debt_pkg.set_detailed_entity_types(
        i_detailed_entities_array_id  =>  i_detailed_entities_array_id
    );

    opr_api_shared_data_pkg.get_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account.account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => l_account.split_hash
          , i_eff_date          => com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_account.inst_id)
          , i_mask_error        => com_api_const_pkg.TRUE
        );

    if l_service_id is null then
        trc_log_pkg.debug(
            i_text          => 'Credit service not found on account [#1]'
          , i_env_param1    => l_account.account_id
        );
    else
        acc_api_entry_pkg.flush_job;

        -- Checking if it is allowed to accelarate active DPPs in case when payment is greater than TAD
        l_allow_dpp_acceleration :=
            nvl(
                opr_api_shared_data_pkg.get_param_num(
                    i_name         => 'ALLOW_DPP_ACCELERATION'
                  , i_mask_error   => com_api_const_pkg.TRUE
                  , i_error_value  => null
                )
              , com_api_const_pkg.FALSE
            );

        for r in (
            select *
              from (
                select
                    e.balance
                    , m.id macros_id
                    , m.amount
                    , m.posting_date
                    , e.sttl_day
                    , c.product_id
                    , e.split_hash
                from
                    acc_macros m
                    , acc_entry e
                    , acc_account a
                    , prd_contract c
                where
                    m.macros_type_id = l_macros_type
                    and m.entity_type = 'ENTTOPER'
                    and m.object_id = l_operation.id
                    and e.macros_id = m.id
    --                    and e.balance_type = 'BLTP1010' --ledger
                    and m.account_id = a.id
                    and a.contract_id = c.id
                order by
                    e.posting_order desc
              )
             where rownum = 1
        ) loop
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type    => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => l_account.account_id
              , i_split_hash    => r.split_hash
              , o_prev_date     => l_prev_date
              , o_next_date     => l_next_date
            );

            if l_next_date is not null then
                l_is_new := com_api_type_pkg.TRUE;
            end if;

            crd_api_payment_pkg.create_payment(
                i_macros_id     => r.macros_id
              , i_oper_id       => l_operation.id
              , i_is_reversal   => l_operation.is_reversal
              , i_original_id   => l_operation.original_id
              , i_oper_date     => l_operation.oper_date
              , i_currency      => l_account.currency
              , i_amount        => r.amount
              , i_account_id    => l_account.account_id
              , i_card_id       => l_iss_participant.card_id
              , i_posting_date  => r.posting_date
              , i_sttl_day      => r.sttl_day
              , i_inst_id       => l_account.inst_id
              , i_agent_id      => l_account.agent_id
              , i_product_id    => r.product_id
              , i_is_new        => l_is_new
              , i_split_hash    => r.split_hash
            );

            l_interest_calc_start_date :=
                prd_api_product_pkg.get_attr_value_char(
                    i_product_id    => r.product_id
                  , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => l_account.account_id
                  , i_attr_name     => crd_api_const_pkg.INTEREST_CALC_START_DATE
                  , i_split_hash    => r.split_hash
                  , i_service_id    => l_service_id
                  , i_params        => l_param_tab
                  , i_eff_date      => r.posting_date
                  , i_inst_id       => l_account.inst_id
                );

            case l_interest_calc_start_date
                when crd_api_const_pkg.INTEREST_CALC_DATE_POSTING
                then l_eff_date := r.posting_date;

                when crd_api_const_pkg.INTEREST_CALC_DATE_TRANSACTION
                then l_eff_date := l_operation.oper_date;

                when crd_api_const_pkg.INTEREST_CALC_DATE_SETTLEMENT then

                    begin
                        select sttl_date
                          into l_eff_date
                          from (
                                select sttl_date
                                  from com_settlement_day
                                 where sttl_day = r.sttl_day
                                   and inst_id in (l_account.inst_id, ost_api_const_pkg.DEFAULT_INST)
                                 order by inst_id
                               )
                         where rownum = 1;
                    exception
                        when no_data_found then
                            l_eff_date := trunc(r.posting_date);
                    end;

                else l_eff_date := r.posting_date;
            end case;

            l_eff_date := crd_interest_pkg.get_interest_start_date(
                              i_product_id   => r.product_id
                            , i_account_id   => l_account.account_id
                            , i_split_hash   => r.split_hash
                            , i_service_id   => l_service_id
                            , i_param_tab    => l_param_tab
                            , i_posting_date => r.posting_date
                            , i_eff_date     => l_eff_date
                            , i_inst_id      => l_account.inst_id
                          );

            -- If MAD calculation algorithm is defined, implement some specific actions
            crd_api_algo_proc_pkg.process_mad_when_payment(
                i_account_id        => l_account.account_id
              , i_split_hash        => r.split_hash
              , i_inst_id           => l_account.inst_id
              , i_product_id        => r.product_id
              , i_service_id        => l_service_id
              , i_eff_date          => l_eff_date
              , i_payment_amount    => r.amount
            );

            crd_payment_pkg.apply_payment(
                i_payment_id        => r.macros_id
              , i_eff_date          => l_eff_date
              , i_split_hash        => r.split_hash
              , o_remainder_amount  => l_remainder_amount
            );

            if  l_allow_dpp_acceleration = com_api_const_pkg.TRUE and l_remainder_amount > 0 then
                -- DPP registering operation can't contain this rule <Credit payment> to avoid recursion
                if l_operation.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER then
                    com_api_error_pkg.raise_error(
                        i_error      => 'CRD_IMPOSSIBLE_TO_APPLY_PAYMENT_FOR_OPERATION'
                      , i_env_param1 => r.macros_id
                      , i_env_param2 => l_account.account_id
                      , i_env_param3 => l_remainder_amount
                      , i_env_param4 => dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER
                    );
                else
                    dpp_api_payment_plan_pkg.accelerate_dpps(
                        i_account_id      => l_account.account_id
                      , i_payment_amount  => l_remainder_amount
                    );
                end if;
            end if;
        end loop;
    end if;
end credit_payment;

procedure calc_part_interest_return
is
    l_object_id                     com_api_type_pkg.t_long_id;
    l_last_invoice_id               com_api_type_pkg.t_medium_id;
    l_entity_type                   com_api_type_pkg.t_name;
    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    l_current_interest              com_api_type_pkg.t_money;
    l_recalc_interest               com_api_type_pkg.t_money;
    l_currency                      com_api_type_pkg.t_curr_code;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_event_date                    date;
    l_mad_payment_date              date;
    l_mad_payment_sum               com_api_type_pkg.t_money;
    l_alg_return_part_interest      com_api_type_pkg.t_dict_value;
begin
    l_result_amount_name := evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_split_hash  := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');

    l_test_mode :=
        nvl(
            evt_api_shared_data_pkg.get_param_char(
                i_name        => 'ATTR_MISS_TESTMODE'
              , i_mask_error  => com_api_const_pkg.TRUE
              , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
            )
          , fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
        );

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_last_invoice_id :=
            crd_invoice_pkg.get_last_invoice(
                i_account_id    => l_object_id
              , i_split_hash    => l_split_hash
            ).id;
        -- Get algorithm return part interest ACIR
        begin
            l_alg_return_part_interest :=
                nvl(
                    prd_api_product_pkg.get_attr_value_char(
                        i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => l_object_id
                      , i_attr_name     => crd_api_const_pkg.ALGORITHM_CALC_RTRN_INTEREST
                      , i_eff_date      => l_event_date
                      , i_split_hash    => l_split_hash
                    )
                  , crd_api_const_pkg.ALGORITHM_INTER_RTRN_EXCLUDE
                );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then
                    trc_log_pkg.debug('Attribute value [CRD_ALGORITHM_CALC_RETURN_INTEREST_PART] not defined. Set default algorithm = ICEDBLNC');
                    l_alg_return_part_interest := crd_api_const_pkg.ALGORITHM_INTER_RTRN_EXCLUDE;
                else
                    raise;
                end if;
        end;

        if l_alg_return_part_interest = crd_api_const_pkg.ALGORITHM_INTER_RTRN_NDAYDUE then
            begin
                crd_utl_pkg.get_mad_payment_data(
                    i_invoice_id       => l_last_invoice_id
                  , o_mad_payment_date => l_mad_payment_date
                  , o_mad_payment_sum  => l_mad_payment_sum
                );

                crd_interest_pkg.recalc_interest_on_fix_period(
                    i_invoice_id               => l_last_invoice_id
                  , i_interest_calc_end_date   => l_mad_payment_date
                  , o_recalculation_interest   => l_recalc_interest
                  , o_current_interest         => l_current_interest
                  , o_currency                 => l_currency
                );

                if l_recalc_interest > l_current_interest then
                    l_result_amount.amount := l_recalc_interest - l_current_interest;
                elsif l_recalc_interest <= l_current_interest then
                    l_result_amount.amount := l_current_interest - l_recalc_interest;
                else
                    l_result_amount.amount := 0;
                end if;

                l_result_amount.currency := nvl(l_currency, com_api_const_pkg.UNDEFINED_CURRENCY);
            exception
                when com_api_error_pkg.e_application_error then
                    if l_test_mode = fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE then
                        raise com_api_error_pkg.e_stop_execute_rule_set;
                    elsif l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                        raise;
                    else
                        l_result_amount.amount   := 0;
                        l_result_amount.currency := com_api_const_pkg.UNDEFINED_CURRENCY;
                    end if;
            end;

        else
            l_result_amount.amount   := 0;
            l_result_amount.currency := com_api_const_pkg.UNDEFINED_CURRENCY;
        end if;

    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;

    evt_api_shared_data_pkg.set_amount(
        i_name      => l_result_amount_name
      , i_amount    => l_result_amount.amount
      , i_currency  => l_result_amount.currency
    );
end calc_part_interest_return;

procedure calculate_credit_overlimit_fee
is
    DEFAULT_AMOUNT_FEE              constant com_api_type_pkg.t_money := 0;
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    l_overlimit_fee_type            com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_fee_id                        com_api_type_pkg.t_long_id;
    l_product_id                    com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_fee_currency_type             com_api_type_pkg.t_dict_value;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
    l_oper_date                     date;
    l_forced_processing             com_api_type_pkg.t_boolean;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_avl_balance                   com_api_type_pkg.t_money;
    l_overlimit_fee_base            com_api_type_pkg.t_money;
    l_credit_limit_value            com_api_type_pkg.t_money;
    l_credit_limit_counter          com_api_type_pkg.t_long_id;
    l_over_limit_value              com_api_type_pkg.t_money;
    l_limit_id                      com_api_type_pkg.t_long_id;
    l_over_limit_id                 com_api_type_pkg.t_long_id;  -- fee!
    l_split_hash                    com_api_type_pkg.t_tiny_id;
begin
    l_entity_type := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');

    if l_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD, acc_api_const_pkg.ENTITY_TYPE_ACCOUNT) then

        l_amount_name := opr_api_shared_data_pkg.get_param_char('BASE_AMOUNT_NAME');

        opr_api_shared_data_pkg.get_amount(
            i_name          => l_amount_name
            , o_amount      => l_amount.amount
            , o_currency    => l_amount.currency
        );

        l_overlimit_fee_type := opr_api_shared_data_pkg.get_param_char('OVERLIMIT_FEE_TYPE');
        l_account_name       := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
        l_party_type         := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
        l_fee_currency_type  := opr_api_shared_data_pkg.get_param_char(
                                    i_name        => 'FEE_CURRENCY_TYPE'
                                  , i_mask_error  => com_api_const_pkg.TRUE
                                  , i_error_value => fcl_api_const_pkg.FEE_CURRENCY_TYPE_FEE
                                );
        l_forced_processing := opr_api_shared_data_pkg.get_operation().forced_processing;

        l_object_id := opr_api_shared_data_pkg.get_object_id (
            i_entity_type     => l_entity_type
            , i_account_name  => l_account_name
            , i_party_type    => l_party_type
            , o_inst_id       => l_inst_id
        );

        l_inst_id :=
            opr_api_shared_data_pkg.get_participant(
                i_participant_type    => l_party_type
            ).inst_id;

        l_product_id := prd_api_product_pkg.get_product_id (
            i_entity_type  => l_entity_type
            , i_object_id  => l_object_id
        );

        l_test_mode := opr_api_shared_data_pkg.get_param_char(
            i_name        => 'ATTR_MISS_TESTMODE'
          , i_mask_error  => com_api_const_pkg.TRUE
          , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
        );

        opr_api_shared_data_pkg.get_date(
            i_name      => com_api_const_pkg.DATE_PURPOSE_OPERATION
          , o_date      => l_oper_date
        );

        l_eff_date_name :=
            opr_api_shared_data_pkg.get_param_char(
                i_name          => 'EFFECTIVE_DATE'
              , i_mask_error    => com_api_type_pkg.TRUE
              , i_error_value   => null
            );

        if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
            l_eff_date :=
                com_api_sttl_day_pkg.get_open_sttl_date (
                    i_inst_id => l_inst_id
                );
        elsif l_eff_date_name is not null then
            opr_api_shared_data_pkg.get_date (
                i_name      => l_eff_date_name
              , o_date      => l_eff_date
            );
        else
            l_eff_date := com_api_sttl_day_pkg.get_sysdate;
        end if;

        begin
            l_split_hash := com_api_hash_pkg.get_split_hash(l_entity_type, l_object_id);

            if nvl(l_forced_processing, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then

                l_fee_id := prd_api_product_pkg.get_fee_id (
                    i_product_id     => l_product_id
                    , i_entity_type  => l_entity_type
                    , i_object_id    => l_object_id
                    , i_fee_type     => l_overlimit_fee_type
                    , i_params       => opr_api_shared_data_pkg.g_params
                    , i_eff_date     => l_eff_date
                    , i_inst_id      => l_inst_id
                );
            else

                l_service_id := prd_api_service_pkg.get_active_service_id(
                    i_entity_type => l_entity_type
                  , i_object_id   => l_object_id
                  , i_attr_name   => prd_api_attribute_pkg.get_attr_name(i_object_type => l_overlimit_fee_type)
                  , i_split_hash  => l_split_hash
                  , i_eff_date    => l_eff_date
                  , i_last_active => com_api_type_pkg.TRUE
                );

                l_fee_id := prd_api_product_pkg.get_fee_id (
                    i_product_id     => l_product_id
                    , i_entity_type  => l_entity_type
                    , i_object_id    => l_object_id
                    , i_fee_type     => l_overlimit_fee_type
                    , i_params       => opr_api_shared_data_pkg.g_params
                    , i_service_id   => l_service_id
                    , i_eff_date     => l_eff_date
                    , i_inst_id      => l_inst_id
                );
            end if;

        exception
            when com_api_error_pkg.e_application_error then
                trc_log_pkg.debug (
                    i_text           => 'Error when define fee [#1] for overlimit fee type [#3]'
                    , i_env_param1   => com_api_error_pkg.get_last_error
                    , i_env_param3   => l_overlimit_fee_type
                    , i_entity_type  => l_entity_type
                    , i_object_id    => l_object_id
                );
        end;

        if l_fee_id is not null then

            begin
                if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then

                    select sum(acc_api_balance_pkg.get_aval_balance_amount_only(
                                   i_account_id => a.id
                               )
                           )
                      into l_avl_balance
                      from acc_account_object ao
                         , prd_service_object so
                         , prd_service s
                         , acc_account a
                     where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and ao.object_id = l_object_id
                       and so.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       and so.object_id = ao.account_id
                       and s.id = so.service_id
                       and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                       and a.id = ao.account_id
                       and a.currency = l_amount.currency
                       and a.status != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED;

                elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then

                    select acc_api_balance_pkg.get_aval_balance_amount_only(
                               i_account_id => a.id
                           )
                      into l_avl_balance
                      from acc_account a
                         , prd_service_object so
                         , prd_service s
                     where a.id = l_object_id
                       and a.currency = l_amount.currency
                       and a.status != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
                       and so.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       and so.object_id = a.id
                       and s.id = so.service_id
                       and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;

                end if;

                l_limit_id := prd_api_product_pkg.get_attr_value_number(
                                  i_entity_type  => l_entity_type
                                , i_object_id    => l_object_id
                                , i_attr_name    => case l_entity_type
                                                        when iss_api_const_pkg.ENTITY_TYPE_CARD
                                                            then iss_api_const_pkg.ATTR_CARD_SPEND_CREDIT_LIMIT
                                                        when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                            then acc_api_const_pkg.ATTR_ACCOUNT_CREDIT_LIMIT
                                                        else null
                                                    end
                                , i_eff_date     => l_eff_date
                                , i_inst_id      => l_inst_id
                              );

                fcl_api_limit_pkg.get_limit_value(
                    i_limit_id    => l_limit_id
                  , o_sum_value   => l_credit_limit_value
                  , o_count_value => l_credit_limit_counter
                );

                l_over_limit_id := prd_api_product_pkg.get_attr_value_number(
                                       i_entity_type  => l_entity_type
                                     , i_object_id    => l_object_id
                                     , i_attr_name    => case l_entity_type
                                                             when iss_api_const_pkg.ENTITY_TYPE_CARD
                                                                 then iss_api_const_pkg.ATTR_CARD_CREDIT_OVERLIMIT
                                                             when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                 then acc_api_const_pkg.ATTR_ACCOUNT_CREDIT_OVERLIMIT
                                                             else null
                                                         end
                                     , i_eff_date     => l_eff_date
                                     , i_inst_id      => l_inst_id
                                   );

                l_over_limit_value := trunc(
                                          fcl_api_fee_pkg.get_fee_amount(
                                              i_fee_id         => l_over_limit_id
                                            , i_base_amount    => l_credit_limit_value
                                            , i_base_count     => 1
                                            , io_base_currency => l_amount.currency
                                            , i_eff_date       => l_eff_date
                                          )
                                      );

            exception
                when com_api_error_pkg.e_application_error then

                    trc_log_pkg.debug (
                        i_text           => 'Error when defined limits [#1]'
                        , i_env_param1   => com_api_error_pkg.get_last_error
                        , i_entity_type  => l_entity_type
                        , i_object_id    => l_object_id
                    );

                    l_avl_balance        := null;
                    l_over_limit_value   := null;

            end;

            if l_avl_balance between 0 and l_over_limit_value
                and l_over_limit_value <> 0
            then

                l_overlimit_fee_base := l_over_limit_value - l_avl_balance;

                if l_fee_currency_type = fcl_api_const_pkg.FEE_CURRENCY_TYPE_BASE then
                    l_result_amount.currency := l_amount.currency;
                end if;

                fcl_api_fee_pkg.get_fee_amount(
                    i_fee_id            => l_fee_id
                  , i_base_amount       => l_overlimit_fee_base
                  , i_base_currency     => l_amount.currency
                  , i_entity_type       => l_entity_type
                  , i_object_id         => l_object_id
                  , i_eff_date          => l_eff_date
                  , io_fee_currency     => l_result_amount.currency
                  , o_fee_amount        => l_result_amount.amount
                  , i_oper_date         => l_oper_date
                );

                l_result_amount.amount := round(l_result_amount.amount);

            elsif l_avl_balance < 0
                  and l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
            then

                com_api_error_pkg.raise_error(
                    i_error         => 'OVERLIMIT'
                  , i_env_param1    => com_api_i18n_pkg.get_text(
                                           i_table_name  => 'PRD_ATTRIBUTE'
                                         , i_column_name => 'LABEL'
                                         , i_object_id   => prd_api_attribute_pkg.get_attribute(
                                                                i_attr_name => case l_entity_type
                                                                                   when iss_api_const_pkg.ENTITY_TYPE_CARD
                                                                                       then iss_api_const_pkg.ATTR_CARD_CREDIT_OVERLIMIT
                                                                                   when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                                       then acc_api_const_pkg.ATTR_ACCOUNT_CREDIT_OVERLIMIT
                                                                                   else null
                                                                               end
                                                            ).id
                                       )
                  , i_env_param2    => l_entity_type
                  , i_env_param3    => l_over_limit_value
                  , i_env_param4    => 1
                );

            end if;

        end if;

    end if;

    l_result_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'RESULT_AMOUNT_NAME'
          , i_mask_error  => com_api_type_pkg.TRUE
          , i_error_value => l_overlimit_fee_type
        );

    if l_result_amount.amount is not null then
        opr_api_shared_data_pkg.set_amount(
            i_name      => nvl(l_result_amount_name, l_overlimit_fee_type)
          , i_amount    => l_result_amount.amount
          , i_currency  => l_result_amount.currency
        );
    else
        opr_api_shared_data_pkg.set_amount(
            i_name      => nvl(l_result_amount_name, l_overlimit_fee_type)
          , i_amount    => DEFAULT_AMOUNT_FEE
          , i_currency  => l_amount.currency
        );
    end if;
end calculate_credit_overlimit_fee;

procedure lending_clearance
is
    l_account               acc_api_type_pkg.t_account_rec;
    l_operation             opr_api_type_pkg.t_oper_rec;
    l_amount_name           com_api_type_pkg.t_name;
begin
    opr_api_shared_data_pkg.get_account(
        i_name           => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec    => l_account
    );

    l_operation := opr_api_shared_data_pkg.get_operation();

    crd_debt_pkg.lending_clearance(
        i_account        => l_account
      , i_operation      => l_operation
      , i_macros_type_id => opr_api_shared_data_pkg.get_param_num(i_name => 'MACROS_TYPE')
      , i_bunch_type_id  => opr_api_shared_data_pkg.get_param_num(i_name => 'LENDING_BUNCH_TYPE')
      , i_service_id     => null
    );

    l_amount_name := opr_api_shared_data_pkg.get_param_char(
                         i_name       => 'LENDING_AMOUNT_NAME'
                       , i_mask_error => com_api_const_pkg.TRUE
                     );
    if l_amount_name is not null then
        opr_api_shared_data_pkg.set_amount(
            i_name     => l_amount_name
          , i_amount   => l_operation.oper_amount
          , i_currency => l_account.currency
        );
    end if;
end;

procedure lending_payment is
    l_macros_type           com_api_type_pkg.t_tiny_id;
    l_account               acc_api_type_pkg.t_account_rec;
    l_service_id            com_api_type_pkg.t_short_id;
    l_operation             opr_api_type_pkg.t_oper_rec;
    l_bunch_id              com_api_type_pkg.t_long_id;
    l_lending_bunch_type_id com_api_type_pkg.t_tiny_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_amount_name           com_api_type_pkg.t_name;
    l_account_name          com_api_type_pkg.t_name;

    l_repayment_amount      com_api_type_pkg.t_money;
    l_credit_limit          com_api_type_pkg.t_money;
    l_total_outstanding     com_api_type_pkg.t_money;
    l_invoice               crd_api_type_pkg.t_invoice_rec;
    l_lending_balance       com_api_type_pkg.t_amount_rec;
    l_amount                com_api_type_pkg.t_money;
    l_from_id               com_api_type_pkg.t_long_id;
    l_till_id               com_api_type_pkg.t_long_id;
    l_settl_date            date;
    l_sysdate               date  := com_api_sttl_day_pkg.get_sysdate();
    l_date_from             date;
begin
    l_macros_type            := opr_api_shared_data_pkg.get_param_num('MACROS_TYPE');
    l_lending_bunch_type_id  := opr_api_shared_data_pkg.get_param_num('LENDING_BUNCH_TYPE');
    l_operation              := opr_api_shared_data_pkg.get_operation;
    l_account_name           := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');

    opr_api_shared_data_pkg.get_account(
        i_name         => l_account_name
      , o_account_rec  => l_account
    );
    trc_log_pkg.debug(
        i_text       => 'lending_payment: macros_type=[#1], lending_bunch_type_id=[#2],account_name=[#3], oper_id=[#4]'
      , i_env_param1 => l_macros_type
      , i_env_param2 => l_lending_bunch_type_id
      , i_env_param3 => l_account_name
      , i_env_param4 => l_operation.id
    );

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type      => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id        => l_account.account_id
          , i_attr_name        => null
          , i_service_type_id  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash       => l_account.split_hash
          , i_eff_date         => com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_account.inst_id)
          , i_mask_error       => com_api_const_pkg.TRUE
        );

    if l_service_id is null then
        trc_log_pkg.debug(
            i_text          => 'Credit service not found on account [#1]'
          , i_env_param1    => l_account.account_id
        );
    else
        l_repayment_amount := l_operation.oper_amount;

        l_settl_date  := trunc(com_api_sttl_day_pkg.get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND;
        l_till_id := com_api_id_pkg.get_till_id(l_settl_date);

        l_invoice :=
            crd_invoice_pkg.get_last_invoice(
                i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id   => l_account.account_id
              , i_split_hash  => l_account.split_hash
              , i_mask_error  => com_api_const_pkg.TRUE
            );

        if l_invoice.id is null or l_invoice.exceed_limit is null then
            l_credit_limit :=
                acc_api_balance_pkg.get_balance_amount(
                    i_account_id   => l_account.account_id
                  , i_balance_type => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED  -- 'BLTP1001'
                  , i_date         => l_sysdate
                  , i_date_type    => com_api_const_pkg.DATE_PURPOSE_BANK
                  , i_mask_error   => com_api_const_pkg.TRUE
                ).amount;
        else
            l_credit_limit := l_invoice.exceed_limit;
            l_from_id      := com_api_id_pkg.get_from_id(l_invoice.invoice_date);
        end if;

        l_lending_balance :=
            acc_api_balance_pkg.get_balance_amount(
                i_account_id   => l_account.account_id
              , i_balance_type => crd_api_const_pkg.BALANCE_TYPE_LENDING
            );

        if l_from_id is null then
            select o.start_date
              into l_date_from
              from prd_service_object o
             where o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and o.object_id       = l_account.account_id
               and o.service_id      = l_service_id
               and (o.end_date is null or o.end_date > l_sysdate);

             l_from_id := com_api_id_pkg.get_from_id(l_date_from);
        end if;

        acc_api_entry_pkg.flush_job;

        for r in (
            select e.balance
                 , m.id macros_id
              from acc_macros m
                 , acc_entry e
             where m.macros_type_id = l_macros_type
               and m.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and m.object_id      = l_operation.id
               and e.macros_id      = m.id
               and e.balance_type   = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and rownum           = 1
        ) loop
            trc_log_pkg.debug(
                i_text       => 'settl_date= [#1]. from_id=[#2], till_id=[#3]'
              , i_env_param1 => to_char(l_settl_date, com_api_const_pkg.LOG_DATE_FORMAT)
              , i_env_param2 => to_char(l_from_id, com_api_const_pkg.XML_FLOAT_FORMAT)
              , i_env_param3 => to_char(l_till_id, com_api_const_pkg.XML_FLOAT_FORMAT)
            );

            -- Get total outstanding
            select nvl(sum(nvl(b.amount, 0)), 0)
              into l_total_outstanding
              from (select d.id debt_id
                      from crd_debt d
                     where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account.account_id
                       and d.split_hash = l_account.split_hash
                       and d.id between l_from_id and l_till_id
                     union
                    select d.id debt_id
                      from crd_debt d
                     where decode(d.is_new, 1, d.account_id, null) = l_account.account_id
                       and d.split_hash = l_account.split_hash
                       and d.id between l_from_id and l_till_id
                 ) d
                 , crd_debt_balance b
             where b.debt_id    = d.debt_id
               and b.split_hash = l_account.split_hash
               and b.balance_type not in ( acc_api_const_pkg.BALANCE_TYPE_LEDGER, crd_api_const_pkg.BALANCE_TYPE_LENDING)
               and b.id between l_from_id and l_till_id;

            -- Calculate amount for put bunch
            if nvl(l_repayment_amount, 0) <= nvl(l_lending_balance.amount, 0) then
                trc_log_pkg.debug('l_repayment_amount <= l_lending_balance.amount');
                l_amount := l_repayment_amount;

            elsif nvl(l_lending_balance.amount, 0) < nvl(l_repayment_amount, 0) and nvl(l_repayment_amount, 0) <= nvl(l_total_outstanding, 0) then
                trc_log_pkg.debug('l_lending_balance.amount < l_repayment_amount and l_repayment_amount <= l_total_outstanding');
                l_amount := l_lending_balance.amount;

            elsif nvl(l_repayment_amount, 0) > nvl(l_total_outstanding, 0) then
                trc_log_pkg.debug('l_repayment_amount > l_total_outstanding');
                l_amount := l_lending_balance.amount + l_repayment_amount - l_total_outstanding;
            end if;

            trc_log_pkg.debug(
                i_text       => 'credit limit=[#1], repayment_amount=[#2], lending_balance.amount=[#3], total_outstanding=[#4], amount=[#5]'
              , i_env_param1 => to_char(l_credit_limit,           com_api_const_pkg.XML_FLOAT_FORMAT)
              , i_env_param2 => to_char(l_repayment_amount,       com_api_const_pkg.XML_FLOAT_FORMAT)
              , i_env_param3 => to_char(l_lending_balance.amount, com_api_const_pkg.XML_FLOAT_FORMAT)
              , i_env_param4 => to_char(l_total_outstanding,      com_api_const_pkg.XML_FLOAT_FORMAT)
              , i_env_param5 => to_char(l_amount,                 com_api_const_pkg.XML_FLOAT_FORMAT)
            );

            acc_api_entry_pkg.put_bunch(
                o_bunch_id       => l_bunch_id
              , i_bunch_type_id  => l_lending_bunch_type_id
              , i_macros_id      => r.macros_id
              , i_amount         => l_amount
              , i_currency       => l_account.currency
              , i_account_type   => l_account.account_type
              , i_account_id     => l_account.account_id
              , i_param_tab      => l_param_tab
            );

            if l_amount_name is not null then
                opr_api_shared_data_pkg.set_amount(
                    i_name     => l_amount_name
                  , i_amount   => l_operation.oper_amount
                  , i_currency => l_account.currency
                );
            end if;

            acc_api_entry_pkg.flush_job;
        end loop;
    end if;
end lending_payment;

procedure reset_aging_period
is
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_date                    date;
    l_invoice                       crd_api_type_pkg.t_invoice_rec;
begin
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');

    if l_entity_type != acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;

    l_invoice :=
        crd_invoice_pkg.get_last_invoice(
            i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => evt_api_shared_data_pkg.get_param_num('OBJECT_ID')
          , i_split_hash   => evt_api_shared_data_pkg.get_param_num('SPLIT_HASH')
          , i_mask_error   => com_api_const_pkg.TRUE
        );

    if  l_invoice.id is not null
        and crd_api_algo_proc_pkg.check_reset_aging(
                io_invoice    => l_invoice
              , i_eff_date    => l_event_date
              , i_event_type  => evt_api_shared_data_pkg.get_param_char('EVENT_TYPE')
            ) = com_api_const_pkg.TRUE
    then
        if l_invoice.aging_period > 0 then
            trc_log_pkg.debug(
                i_text         => 'Aging reset from [#1]'
              , i_env_param1   => l_invoice.aging_period
            );

            l_invoice.aging_period := 0;
            crd_invoice_pkg.update_invoice_aging(
                i_invoice_id   => l_invoice.id
              , i_aging_period => l_invoice.aging_period
            );

            crd_overdue_pkg.update_debt_aging(
                i_account_id   => l_invoice.account_id
              , i_split_hash   => l_invoice.split_hash
              , i_aging_period => l_invoice.aging_period
            );

            crd_invoice_pkg.add_aging_history(
                i_invoice      => l_invoice
              , i_eff_date     => l_event_date
            );
        end if;

        -- It is necessary to remove cycle counter to differ 2 cases:
        -- a) aging cycle counter is reset from this rule on processing some event (MAD or TAD
        --    repayment events, non-overdue event), the counter is removed;
        -- b) aging cycle counter is switched by process Switch counters, its next_date is null,
        --    but the counter is NOT removed.
        fcl_api_cycle_pkg.remove_cycle_counter(
            i_cycle_type  => crd_api_const_pkg.AGING_PERIOD_CYCLE_TYPE
          , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => l_invoice.account_id
          , i_split_hash  => l_invoice.split_hash
        );
    end if;
end reset_aging_period;

procedure load_invoice_data is
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_event_date                    date;
    l_account_id                    com_api_type_pkg.t_long_id;
    l_order                         pmo_api_type_pkg.t_payment_order_rec;
    l_invoice_id                    com_api_type_pkg.t_medium_id;
    l_service_id                    com_api_type_pkg.t_short_id;
begin
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_split_hash  := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');

    if l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        l_invoice_id := l_object_id;
    elsif l_entity_type in (acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER) then
        if l_entity_type = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER then
            l_order :=
                pmo_api_order_pkg.get_order(
                    i_order_id          => l_object_id
                  , i_mask_error        => com_api_const_pkg.TRUE
                );

            trc_log_pkg.debug(
                i_text       => 'load_invoice_params; payment order [#1], pmo_order.object_id [#2],  pmo_order.entity_type [#3]'
              , i_env_param1 => l_order.id
              , i_env_param2 => l_order.object_id
              , i_env_param3 => l_order.entity_type
            );

            if l_order.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                l_account_id := l_order.object_id;
            end if;
        elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            l_account_id := l_object_id;
        end if;

        l_service_id :=
            crd_api_service_pkg.get_active_service(
                i_account_id => l_account_id
              , i_eff_date   => l_event_date
              , i_split_hash => l_split_hash
              , i_mask_error => com_api_const_pkg.TRUE
            );

        trc_log_pkg.debug(
            i_text       => 'load_invoice_params; credit service [#1] for account [#2]'
          , i_env_param1 => l_service_id
          , i_env_param2 => l_account_id
        );

        if l_service_id is not null then
            l_invoice_id :=
                crd_invoice_pkg.get_last_invoice(
                    i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id   => l_account_id
                  , i_split_hash  => l_split_hash
                  , i_mask_error  => com_api_const_pkg.TRUE
                ).id;
        end if;
    end if;

    if l_invoice_id is not null then
        rul_api_shared_data_pkg.load_invoice_params(
            i_invoice_id => l_invoice_id
          , io_params    => evt_api_shared_data_pkg.g_params
        );
    end if;
end load_invoice_data;

procedure credit_balance_transfer
is
    LOG_PREFIX  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.credit_balance_transfer: ';
    l_bunch_id           com_api_type_pkg.t_long_id;
    l_macros_type        com_api_type_pkg.t_tiny_id;
    l_event_type         com_api_type_pkg.t_dict_value;
    l_eff_date           date;
    l_account            acc_api_type_pkg.t_account_rec;
    l_oper_id            com_api_type_pkg.t_long_id;
    l_debt_id            com_api_type_pkg.t_long_id;
    l_param_tab          com_api_type_pkg.t_param_tab;
    l_amount             com_api_type_pkg.t_money;
begin
    l_macros_type := opr_api_shared_data_pkg.get_param_num(i_name => 'MACROS_TYPE');
    l_event_type  := opr_api_shared_data_pkg.get_param_char(i_name => 'EVENT_TYPE');
    l_oper_id     := opr_api_shared_data_pkg.get_operation().id;

    for r in (
        select * from (
            select v.balance
                 , v.amount  as macros_amount
                 , a.id      as account_id
                 , a.currency
                 , a.account_type
                 , a.inst_id
                 , a.split_hash
                 , d.id      as debt_id
                 , db.amount as debt_amount
                 , db.balance_type
                 , bt.bunch_type_id
                 , d.macros_type_id
              from (
                  -- Posted amount by the macros of operation OPTP1035 (Credit balance transfer)
                  -- or Cash withdrawal (in the case of Credit balance rollbacking)
                  select m.id as macros_id
                       , m.account_id
                       , m.amount
                       , m.posting_date
                       , e.balance
                       , e.sttl_day
                       , e.split_hash
                       , row_number() over (order by e.posting_order desc) as rn
                    from acc_macros    m
                    join acc_entry     e    on e.macros_id   = m.id
                   where m.macros_type_id = l_macros_type
                     and m.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                     and m.object_id      = l_oper_id
              ) v
              join acc_account          a    on a.id            = v.account_id
              join crd_debt             dc   on dc.id           = v.macros_id
              join crd_debt             d    on d.oper_id       = dc.original_id
                                            and d.split_hash    = dc.split_hash
              join crd_debt_balance     db   on db.debt_id      = d.id
                                            and db.id          >= trunc(d.id, -10)
                                            and db.split_hash   = d.split_hash
              join crd_event_bunch_type bt   on bt.balance_type = db.balance_type
                                            and bt.inst_id      = d.inst_id
             where v.rn          = 1
               and db.amount     > 0
               and bt.event_type = l_event_type
               and bt.bunch_type_id is not null
          order by d.fee_type nulls first
                 , d.id
        ) where rownum = 1
    ) loop
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'debt_id [#1], macros amount [#2], balance_type [#3]'
                                       || ', balance (entry) [#4], crd_debt_balance.amount [#5], bunch_type_id [#6]'
          , i_env_param1 => r.debt_id
          , i_env_param2 => r.macros_amount
          , i_env_param3 => r.balance_type
          , i_env_param4 => r.balance
          , i_env_param5 => r.debt_amount
          , i_env_param6 => r.bunch_type_id
        );

        l_eff_date := coalesce(l_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => r.inst_id));

        acc_api_entry_pkg.put_bunch(
            o_bunch_id          => l_bunch_id
          , i_bunch_type_id     => r.bunch_type_id
          , i_macros_id         => r.debt_id
          , i_amount            => r.debt_amount
          , i_currency          => r.currency
          , i_account_type      => r.account_type
          , i_account_id        => r.account_id
          , i_posting_date      => l_eff_date
          , i_macros_type_id    => r.macros_type_id
          , i_param_tab         => l_param_tab
        );

        if l_amount is null then
            l_amount := r.macros_amount;
        end if;
        l_amount := l_amount - r.debt_amount;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'bunch with ID [#1], macros type ID [#2]; unposted macros amount [#3]'
          , i_env_param1 => l_bunch_id
          , i_env_param2 => r.macros_type_id
          , i_env_param3 => l_amount
        );

        l_debt_id            := r.debt_id;
        l_account.account_id := r.account_id;
        l_account.split_hash := r.split_hash;
        l_account.inst_id    := r.inst_id;
    end loop;

    if l_debt_id is not null then
        crd_debt_pkg.change_debt(
            i_debt_id          => l_debt_id
          , i_eff_date         => l_eff_date
          , i_account_id       => l_account.account_id
          , i_inst_id          => l_account.inst_id
          , i_split_hash       => l_account.split_hash
          , i_event_type       => l_event_type
          , i_forced_interest  => com_api_const_pkg.TRUE
          , o_unpaid_debt      => l_amount
        );
    end if;
end credit_balance_transfer;

procedure revert_interest
is
    LOG_PREFIX  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.revert_interest: ';
    l_operation          opr_api_type_pkg.t_oper_rec;
    l_issuer             opr_api_type_pkg.t_oper_part_rec;
    l_account            acc_api_type_pkg.t_account_rec;
    l_macros_id          com_api_type_pkg.t_long_id;
    l_bunch_id           com_api_type_pkg.t_long_id;
    l_interest_amount    com_api_type_pkg.t_money;
begin
    l_operation := opr_api_shared_data_pkg.get_operation();

    opr_api_operation_pkg.get_participant(
        i_oper_id            => l_operation.id
      , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
      , o_participant        => l_issuer
    );

    -- Calculate charged interest for original operation relative to the current (l_operation) reversal
    select nvl(sum(e.amount), 0)
      into l_interest_amount
      from opr_operation        op
         , acc_macros           m
         , acc_bunch            b
         , acc_entry            e
     where op.id              = l_operation.original_id
       and op.is_reversal     = com_api_const_pkg.FALSE
       and m.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and m.object_id        = op.id
       and b.macros_id        = m.id
       and b.bunch_type_id   in (select ebt.bunch_type_id
                                   from crd_event_bunch_type ebt
                                  where ebt.event_type = crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
                                    and ebt.inst_id    = l_issuer.inst_id)
       and e.bunch_id         = b.id
       and e.status           = acc_api_const_pkg.ENTRY_STATUS_POSTED;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'l_interest_amount [#1]'
      , i_env_param1  => l_interest_amount
    );

    opr_api_shared_data_pkg.get_account(
        i_name        => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec => l_account
    );

    if l_interest_amount > 0 then
        -- Create one more credit payment to cancel charged interest and associate it with the reversal
        -- in addition to main reversal credit payment (that cancel the original operation)
        acc_api_entry_pkg.put_macros(
            o_macros_id         => l_macros_id
          , o_bunch_id          => l_bunch_id
          , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id         => l_operation.id
          , i_macros_type_id    => opr_api_shared_data_pkg.get_param_num('MACROS_TYPE')
          , i_amount            => l_interest_amount
          , i_currency          => l_account.currency
          , i_account_id        => l_account.account_id
          , i_posting_date      => l_operation.host_date
          , i_param_tab         => opr_api_shared_data_pkg.g_params
        );

        crd_api_payment_pkg.create_payment(
            i_macros_id         => l_macros_id
          , i_oper_id           => l_operation.id
          , i_is_reversal       => l_operation.is_reversal
          , i_original_id       => l_operation.original_id
          , i_oper_date         => l_operation.oper_date
          , i_currency          => l_account.currency
          , i_amount            => l_interest_amount
          , i_account_id        => l_account.account_id
          , i_card_id           => l_issuer.card_id
          , i_posting_date      => l_operation.host_date
          , i_sttl_day          => com_api_sttl_day_pkg.get_open_sttl_day(i_inst_id => l_issuer.inst_id)
          , i_inst_id           => l_account.inst_id
          , i_agent_id          => l_account.agent_id
          , i_product_id        => prd_api_product_pkg.get_product_id(
                                       i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                     , i_object_id    => l_account.account_id
                                     , i_eff_date     => l_operation.host_date
                                     , i_inst_id      => l_issuer.inst_id
                                   )
          , i_is_new            => com_api_const_pkg.TRUE
          , i_split_hash        => l_account.split_hash
        );

        crd_payment_pkg.apply_payment(
            i_payment_id        => l_macros_id
          , i_eff_date          => l_operation.host_date
          , i_split_hash        => l_account.split_hash
          , o_remainder_amount  => l_interest_amount
        );
    end if;
end revert_interest;

end;
/
