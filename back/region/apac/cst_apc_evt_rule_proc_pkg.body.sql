create or replace package body cst_apc_evt_rule_proc_pkg is
/************************************************************
 * Event processing rules of APAC <br />
 * Created by Alalykin A. (alalykin@bpcbt.com) at 25.12.2018 <br />
 * Module: CST_APC_EVT_RULE_PROC_PKG <br />
 * @headcom
 ***********************************************************/

procedure set_skip_mad_date
is
    e_stop_rule                     exception;
    l_event_date                    date;
    l_prev_date                     date;
    l_next_date                     date;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_account_id                    com_api_type_pkg.t_account_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_mad_calc_algorithm            com_api_type_pkg.t_dict_value;
    l_new_account_skip_mad_window   com_api_type_pkg.t_tiny_id;
    l_invoice                       crd_api_type_pkg.t_invoice_rec;
begin
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_id  := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_split_hash  := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');
    l_inst_id     := evt_api_shared_data_pkg.get_param_num('INST_ID');

    if l_entity_type != acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;

    l_service_id :=
        crd_api_service_pkg.get_active_service(
            i_account_id   => l_account_id
          , i_eff_date     => l_event_date
          , i_split_hash   => l_split_hash
          , i_mask_error   => com_api_const_pkg.TRUE
        );
    if l_service_id is null then
        trc_log_pkg.info(
            i_text       => 'CRD_SKIPPING_MAD_IS_NOT_AVAILBLE'
          , i_env_param1 => 'credit service is not active'
        );
        raise e_stop_rule;
    end if;

    l_mad_calc_algorithm :=
        prd_api_product_pkg.get_attr_value_char(
            i_entity_type        => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id          => l_account_id
          , i_attr_name          => crd_api_const_pkg.MAD_CALCULATION_ALGORITHM
          , i_eff_date           => l_event_date
          , i_split_hash         => l_split_hash
          , i_inst_id            => l_inst_id
          , i_use_default_value  => com_api_const_pkg.TRUE
          , i_default_value      => crd_api_const_pkg.ALGORITHM_MAD_CALC_DEFAULT
        );

    if l_mad_calc_algorithm != cst_apc_const_pkg.ALGORITHM_MAD_CALC_TWO_MADS then
        trc_log_pkg.info(
            i_text       => 'CRD_SKIPPING_MAD_IS_NOT_AVAILBLE'
          , i_env_param1 => l_mad_calc_algorithm
        );
        raise e_stop_rule;
    end if;

    l_new_account_skip_mad_window :=
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type        => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id          => l_account_id
          , i_attr_name          => cst_apc_const_pkg.NEW_ACCOUNT_SKIP_MAD_WINDOW
          , i_service_id         => l_service_id
          , i_eff_date           => l_event_date
          , i_split_hash         => l_split_hash
          , i_inst_id            => l_inst_id
          , i_use_default_value  => com_api_const_pkg.TRUE
          , i_default_value      => null
        );

    if nvl(l_new_account_skip_mad_window, 0) <= 0 then
        trc_log_pkg.info(
            i_text       => 'CRD_SKIPPING_MAD_IS_NOT_AVAILBLE'
          , i_env_param1 => 'skipping MAD window is not defined'
        );
    else
        l_invoice :=
            crd_invoice_pkg.get_last_invoice(
                i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => l_account_id
              , i_split_hash   => l_split_hash
              , i_mask_error   => com_api_const_pkg.TRUE
            );

        if l_invoice.min_amount_due > 0 or l_invoice.total_amount_due > 0 then
            trc_log_pkg.info(
                i_text       => 'CRD_SKIPPING_MAD_IS_NOT_AVAILBLE'
              , i_env_param1 => 'invoice with non-zero MAD/TAD exists'
            );
        else
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type   => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
              , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => l_account_id
              , i_split_hash   => l_split_hash
              , i_add_counter  => com_api_const_pkg.FALSE
              , o_prev_date    => l_prev_date
              , o_next_date    => l_next_date
            );
            if l_event_date >= l_next_date - l_new_account_skip_mad_window then
                cst_apc_crd_algo_proc_pkg.set_skip_mad_date(
                    i_account_id       => l_account_id
                  , i_split_hash       => l_split_hash
                  , i_invoice_date     => l_next_date
                  , i_cycle_type       => null
                  , i_skip_mad_window  => l_new_account_skip_mad_window
                );
            else
                trc_log_pkg.info(
                    i_text       => 'CRD_SKIPPING_MAD_IS_NOT_AVAILBLE'
                  , i_env_param1 => 'out of skip MAD window [' || l_next_date - l_new_account_skip_mad_window
                                 || '; ' || l_next_date || ']'
                );
            end if;
        end if;
    end if;

exception
    when e_stop_rule then
        null;
end set_skip_mad_date;


procedure get_total_debt_amount
is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_total_debt_amount: ';
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_balance_amount                com_api_type_pkg.t_money;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_account_id                    com_api_type_pkg.t_medium_id;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_need_lock                     com_api_type_pkg.t_boolean;
    l_balances                      com_api_type_pkg.t_amount_by_name_tab;
    l_account                       acc_api_type_pkg.t_account_rec;
begin
    acc_api_entry_pkg.flush_job;

    l_result_amount_name := evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_entity_type [#1], l_object_id [#2]'
      , i_env_param1 => l_entity_type
      , i_env_param2 => l_object_id
    );

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_account_id := l_object_id;

    elsif l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        select max(a.account_id)
          into l_account_id
          from acc_account_object a
             , iss_card_instance  i
             , acc_account        aa
         where a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and a.object_id   = i.card_id
           and i.id            = l_object_id
           and aa.id           = a.id
           and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'l_account_id [#1] is found by card instance'
          , i_env_param1 => l_account_id
        );

    elsif l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        l_account_id :=
            crd_invoice_pkg.get_invoice(
                i_invoice_id  => l_object_id
              , i_mask_error  => com_api_const_pkg.TRUE
            ).account_id;
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'l_account_id [#1] is found by invoice'
          , i_env_param1 => l_account_id
        );

    else
        select max(account_id)
          into l_account_id
          from acc_account_object
         where entity_type = l_entity_type
           and object_id   = l_object_id;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'l_account_id [#1] is found by acc_account_object'
          , i_env_param1 => l_account_id
        );
    end if;

    l_account :=
        acc_api_account_pkg.get_account(
            i_account_id => l_account_id
          , i_mask_error => com_api_const_pkg.FALSE
        );

    l_need_lock :=
        nvl(
            opr_api_shared_data_pkg.get_param_num (
                i_name              => 'NEED_LOCK'
              , i_mask_error        => com_api_type_pkg.TRUE
              , i_error_value       => com_api_const_pkg.FALSE
            )
          , com_api_const_pkg.FALSE
        );

    acc_api_balance_pkg.get_account_balances (
        i_account_id        => l_account_id
      , o_balances          => l_balances
      , o_balance           => l_balance_amount
      , i_lock_balances     => l_need_lock
    );

    l_amount.amount     := 0;
    l_amount.currency   := l_account.currency;

    if l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT) then
        l_amount.amount := l_amount.amount + l_balances(crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT).amount;
    end if;
    if l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_INTEREST) then
        l_amount.amount := l_amount.amount + l_balances(crd_api_const_pkg.BALANCE_TYPE_INTEREST).amount;
    end if;
    if l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_OVERDUE) then
        l_amount.amount := l_amount.amount + l_balances(crd_api_const_pkg.BALANCE_TYPE_OVERDUE).amount;
    end if;
    if l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST) then
        l_amount.amount := l_amount.amount + l_balances(crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST).amount;
    end if;
    if l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_PENALTY) then
        l_amount.amount := l_amount.amount + l_balances(crd_api_const_pkg.BALANCE_TYPE_PENALTY).amount;
    end if;
    if l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_OVERLIMIT) then
        l_amount.amount := l_amount.amount + l_balances(crd_api_const_pkg.BALANCE_TYPE_OVERLIMIT).amount;
    end if;
    if l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_INTR_OVERLIMIT) then
        l_amount.amount := l_amount.amount + l_balances(crd_api_const_pkg.BALANCE_TYPE_INTR_OVERLIMIT).amount;
    end if;

    evt_api_shared_data_pkg.set_amount(
        i_name      => l_result_amount_name
      , i_amount    => l_amount.amount
      , i_currency  => l_amount.currency
    );

end get_total_debt_amount;


procedure switch_card_cycle
is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.switch_card_cycle: ';
    l_params                        com_api_type_pkg.t_param_tab;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_event_date                    date;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_next_date                     date;
    l_cycle_type                    com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_account_id                    com_api_type_pkg.t_medium_id;
    l_service_type_id               com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_count                         com_api_type_pkg.t_long_id;
    l_card_id                       com_api_type_pkg.t_medium_id;
    l_cycle_id                      com_api_type_pkg.t_short_id;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_date  := rul_api_param_pkg.get_param_date('EVENT_DATE', l_params);
    l_split_hash  := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);
    l_cycle_type  := rul_api_param_pkg.get_param_char('CYCLE_TYPE', l_params);
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_const_pkg.TRUE);

    l_test_mode :=
        evt_api_shared_data_pkg.get_param_char(
            i_name        => 'ATTR_MISS_TESTMODE'
          , i_mask_error  => com_api_const_pkg.TRUE
          , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
        );
    l_test_mode := nvl(l_test_mode, fcl_api_const_pkg.ATTR_MISS_RISE_ERROR);

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_entity_type [#1], l_object_id [#2]'
      , i_env_param1 => l_entity_type
      , i_env_param2 => l_object_id
    );

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        l_product_id :=
            prd_api_product_pkg.get_product_id (
                i_entity_type  => l_entity_type
              , i_object_id    => l_object_id
            );
        begin
            l_cycle_id :=
                prd_api_product_pkg.get_cycle_id (
                    i_product_id      => l_product_id
                  , i_entity_type     => l_entity_type
                  , i_object_id       => l_object_id
                  , i_cycle_type      => l_cycle_type
                  , i_params          => l_params
                  , i_service_id      => l_service_id
                  , i_split_hash      => nvl(l_split_hash, com_api_hash_pkg.get_split_hash(l_entity_type, l_object_id))
                  , i_eff_date        => nvl(l_event_date, com_api_sttl_day_pkg.get_sysdate)
                  , i_inst_id         => nvl(l_inst_id, ost_api_institution_pkg.get_object_inst_id(l_entity_type, l_object_id))
                );
        exception
            when no_data_found then
                if l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                    com_api_error_pkg.raise_error(
                        i_error     => 'ATTRIBUTE_NOT_FOUND'
                    );
                end if;
        end;

    elsif l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        select card_id
          into l_card_id
          from iss_card_instance
         where id = l_object_id;

        l_product_id :=
            prd_api_product_pkg.get_product_id (
                i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id    => l_card_id
            );

        begin
            l_cycle_id :=
                prd_api_product_pkg.get_cycle_id (
                    i_product_id      => l_product_id
                  , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_object_id       => l_card_id
                  , i_cycle_type      => l_cycle_type
                  , i_params          => l_params
                  , i_service_id      => l_service_id
                  , i_split_hash      => nvl(l_split_hash, com_api_hash_pkg.get_split_hash(iss_api_const_pkg.ENTITY_TYPE_CARD, l_card_id))
                  , i_eff_date        => nvl(l_event_date, com_api_sttl_day_pkg.get_sysdate)
                  , i_inst_id         => nvl(l_inst_id, ost_api_institution_pkg.get_object_inst_id(iss_api_const_pkg.ENTITY_TYPE_CARD, l_card_id))
                );
        exception
            when no_data_found then
                if l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                    com_api_error_pkg.raise_error(
                        i_error     => 'ATTRIBUTE_NOT_FOUND'
                    );
                end if;
        end;

        l_object_id := l_card_id;
        l_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD;

    else
        com_api_error_pkg.raise_error(
            i_error       => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1  => l_entity_type
        );
    end if;

    fcl_api_cycle_pkg.switch_cycle (
        i_cycle_type         => l_cycle_type
        , i_product_id       => l_product_id
        , i_entity_type      => l_entity_type
        , i_object_id        => l_object_id
        , i_params           => l_params
        , i_start_date       => l_event_date
        , i_eff_date         => l_event_date
        , i_split_hash       => l_split_hash
        , i_inst_id          => l_inst_id
        , i_service_id       => l_service_id
        , o_new_finish_date  => l_next_date
        , i_test_mode        => l_test_mode
        , i_cycle_id         => l_cycle_id
    );
exception
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error != 'PRD_NO_ACTIVE_SERVICE' then
            raise;
        end if;
end switch_card_cycle;


end cst_apc_evt_rule_proc_pkg;
/
