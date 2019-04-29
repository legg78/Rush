create or replace package body opr_api_rule_proc_pkg is
/*********************************************************
 *  API for operation rules processing <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 13.09.2011 <br />
 *  Module: OPR_API_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

-- refactored

g_card_status_tab                   com_api_type_pkg.t_dict_tab;
g_card_state_tab                    com_api_type_pkg.t_dict_tab;
g_card_status_loaded                com_api_type_pkg.t_boolean;

procedure post_macros is
    l_macros_id                     com_api_type_pkg.t_long_id;
    l_bunch_id                      com_api_type_pkg.t_long_id;
    l_macros_type                   com_api_type_pkg.t_tiny_id;
    l_date_name                     com_api_type_pkg.t_name;
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount_purpose                com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_date                          date;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_account                       acc_api_type_pkg.t_account_rec;
begin
    l_macros_type := opr_api_shared_data_pkg.get_param_num('MACROS_TYPE');
    opr_api_shared_data_pkg.set_param(
        i_name  => 'MACROS_TYPE'
      , i_value => to_number(null)
    );

    l_date_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name           => 'DATE_NAME'
          , i_mask_error   => com_api_const_pkg.TRUE
          , i_error_value  => null
        );

    if l_date_name is not null then
        opr_api_shared_data_pkg.get_date(
            i_name    => l_date_name
          , o_date    => l_date
        );
        opr_api_shared_data_pkg.set_date (
            i_name    => com_api_const_pkg.DATE_PURPOSE_MACROS
          , i_date    => l_date
        );
    end if;

    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    opr_api_shared_data_pkg.get_account(
        i_name            => l_account_name
      , o_account_rec     => l_account
    );

    l_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME');
    opr_api_shared_data_pkg.get_amount(
        i_name            => l_amount_name
      , o_amount          => l_amount.amount
      , o_currency        => l_amount.currency
      , o_conversion_rate => l_amount.conversion_rate
      , o_rate_type       => l_amount.rate_type
    );

    l_amount_purpose :=
        opr_api_shared_data_pkg.get_param_char(
            i_name         => 'AMOUNT_PURPOSE'
          , i_mask_error   => com_api_const_pkg.TRUE
          , i_error_value  => null
        );

    opr_api_shared_data_pkg.set_param(
        i_name  => 'AMOUNT_PURPOSE'
      , i_value => to_char(null)
    );

    if l_amount_purpose is null then
        if (
            opr_api_shared_data_pkg.get_operation().oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
            and l_amount_name = com_api_const_pkg.AMOUNT_PURPOSE_ACCOUNT
            and substr(opr_api_shared_data_pkg.get_operation().oper_reason, 1, 4) = fcl_api_const_pkg.FEE_TYPE_STATUS_KEY
        ) then
            l_amount_purpose := opr_api_shared_data_pkg.get_operation().oper_reason;
        else
            l_amount_purpose := l_amount_name;
        end if;
    end if;

    opr_api_shared_data_pkg.set_account(
        i_name             => com_api_const_pkg.ACCOUNT_PURPOSE_MACROS
      , i_account_rec      => l_account
    );

    opr_api_shared_data_pkg.set_amount(
        i_name             => com_api_const_pkg.AMOUNT_PURPOSE_MACROS
      , i_amount           => l_amount.amount
      , i_currency         => l_amount.currency
      , i_conversion_rate  => l_amount.conversion_rate
      , i_rate_type        => l_amount.rate_type
    );

    acc_api_entry_pkg.put_macros(
        o_macros_id        => l_macros_id
      , o_bunch_id         => l_bunch_id
      , i_entity_type      => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id        => opr_api_shared_data_pkg.get_operation().id
      , i_macros_type_id   => l_macros_type
      , i_amount_tab       => opr_api_shared_data_pkg.g_amounts
      , i_account_tab      => opr_api_shared_data_pkg.g_accounts
      , i_date_tab         => opr_api_shared_data_pkg.g_dates
      , i_amount_name      => l_amount_name
      , i_account_name     => l_account_name
      , i_amount_purpose   => nvl(l_amount_purpose, l_amount_name)
      , i_param_tab        => opr_api_shared_data_pkg.g_params
    );
end post_macros;

procedure post_macros_two_account
is
    l_macros_id                     com_api_type_pkg.t_long_id;
    l_bunch_id                      com_api_type_pkg.t_long_id;
    l_macros_type                   com_api_type_pkg.t_tiny_id;
    l_date_name                     com_api_type_pkg.t_name;
    l_date                          date;
    l_src_amount_name               com_api_type_pkg.t_name;
    l_src_amount                    com_api_type_pkg.t_amount_rec;
    l_src_account                   acc_api_type_pkg.t_account_rec;
    l_dst_amount                    com_api_type_pkg.t_amount_rec;
    l_dst_account                   acc_api_type_pkg.t_account_rec;
    l_amounts                       com_api_type_pkg.t_amount_by_name_tab;
    l_accounts                      acc_api_type_pkg.t_account_by_name_tab;
    l_dates                         com_api_type_pkg.t_date_by_name_tab;
begin
    l_macros_type := opr_api_shared_data_pkg.get_param_num('MACROS_TYPE');

    l_date_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name         => 'DATE_NAME'
          , i_mask_error   => com_api_const_pkg.TRUE
          , i_error_value  => null
        );
    if l_date_name is not null then
        opr_api_shared_data_pkg.get_date(
            i_name  => l_date_name
          , o_date  => l_date
        );
    end if;

    opr_api_shared_data_pkg.get_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('SOURCE_ACCOUNT_NAME')
      , o_account_rec       => l_src_account
    );

    l_src_amount_name := opr_api_shared_data_pkg.get_param_char('SOURCE_AMOUNT_NAME');

    opr_api_shared_data_pkg.get_amount(
        i_name            => l_src_amount_name
      , o_amount          => l_src_amount.amount
      , o_currency        => l_src_amount.currency
    );

    opr_api_shared_data_pkg.get_account(
        i_name            => opr_api_shared_data_pkg.get_param_char('DESTINATION_ACCOUNT_NAME')
      , o_account_rec     => l_dst_account
    );

    opr_api_shared_data_pkg.get_amount(
        i_name            => nvl(opr_api_shared_data_pkg.get_param_char('DESTINATION_AMOUNT_NAME'), l_src_amount_name)
      , o_amount          => l_dst_amount.amount
      , o_currency        => l_dst_amount.currency
    );

    rul_api_param_pkg.set_account(
        i_name            => com_api_const_pkg.ACCOUNT_PURPOSE_SOURCE
      , i_account_rec     => l_src_account
      , io_account_tab    => l_accounts
    );

    rul_api_param_pkg.set_account(
        i_name            => com_api_const_pkg.ACCOUNT_PURPOSE_DESTINATION
      , i_account_rec     => l_dst_account
      , io_account_tab    => l_accounts
    );

    rul_api_param_pkg.set_amount(
        i_name            => com_api_const_pkg.AMOUNT_PURPOSE_SOURCE
      , i_amount          => l_src_amount.amount
      , i_currency        => l_src_amount.currency
      , i_conversion_rate => l_src_amount.conversion_rate
      , io_amount_tab     => l_amounts
    );

    rul_api_param_pkg.set_amount(
        i_name            => com_api_const_pkg.AMOUNT_PURPOSE_DESTINATION
      , i_amount          => l_dst_amount.amount
      , i_currency        => l_dst_amount.currency
      , i_conversion_rate => l_dst_amount.conversion_rate
      , io_amount_tab     => l_amounts
    );

    rul_api_param_pkg.set_date(
        i_name            => com_api_const_pkg.DATE_PURPOSE_MACROS
      , i_date            => l_date
      , io_date_tab       => l_dates
    );

    trc_log_pkg.debug(
        i_text        => 'Going to post macros [#1]'
      , i_env_param1  => l_macros_type
    );

    acc_api_entry_pkg.put_macros (
        o_macros_id       => l_macros_id
      , o_bunch_id        => l_bunch_id
      , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id       => opr_api_shared_data_pkg.get_operation().id
      , i_macros_type_id  => l_macros_type
      , i_amount_tab      => l_amounts
      , i_account_tab     => l_accounts
      , i_date_tab        => l_dates
      , i_amount_name     => com_api_const_pkg.AMOUNT_PURPOSE_SOURCE
      , i_account_name    => com_api_const_pkg.ACCOUNT_PURPOSE_SOURCE
      , i_amount_purpose  => l_src_amount_name
      , i_param_tab       => opr_api_shared_data_pkg.g_params
    );

    trc_log_pkg.debug(
        i_text        => 'Macros posted [#1]'
      , i_env_param1  => l_macros_id
    );
end;

procedure get_account_balance_amount is
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_balance_type                  com_api_type_pkg.t_name;
    l_need_lock                     com_api_type_pkg.t_boolean;
    l_balances                      com_api_type_pkg.t_amount_by_name_tab;
    l_balance_amount                com_api_type_pkg.t_money;
begin
    acc_api_entry_pkg.flush_job;

    opr_api_shared_data_pkg.get_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );

    l_need_lock := nvl(opr_api_shared_data_pkg.get_param_num (
        i_name                  => 'NEED_LOCK'
        , i_mask_error          => com_api_const_pkg.TRUE
        , i_error_value         => com_api_const_pkg.FALSE
    ), com_api_const_pkg.FALSE);

    l_balance_type := opr_api_shared_data_pkg.get_param_char('BALANCE_TYPE');

    acc_api_balance_pkg.get_account_balances (
        i_account_id        => l_account.account_id
        , o_balances        => l_balances
        , o_balance         => l_balance_amount
        , i_lock_balances   => l_need_lock
    );

    if l_balances.exists(l_balance_type) then
        l_amount := l_balances(l_balance_type);
    else
        l_amount.amount     := 0;
        l_amount.currency   := l_account.currency;
    end if;

    opr_api_shared_data_pkg.set_amount(
        i_name                      => nvl(opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME'), l_balance_type)
        , i_amount                  => l_amount.amount
        , i_currency                => l_amount.currency
    );
end;

procedure get_account_aval (
    i_account_id                    in com_api_type_pkg.t_account_id
    , o_amount                      out com_api_type_pkg.t_money
    , i_need_lock                   in com_api_type_pkg.t_boolean
) is
    l_balances                      com_api_type_pkg.t_amount_by_name_tab;
    l_balance_type                  com_api_type_pkg.t_dict_value;
begin
    acc_api_entry_pkg.flush_job;

    acc_api_balance_pkg.get_account_balances (
        i_account_id        => i_account_id
        , o_balances        => l_balances
        , o_balance         => o_amount
        , i_lock_balances   => i_need_lock
    );

    l_balance_type := l_balances.first;
    loop
        exit when l_balance_type is null;

        opr_api_shared_data_pkg.set_amount(
            i_name        => l_balance_type
            , i_amount    => l_balances(l_balance_type).amount
            , i_currency  => l_balances(l_balance_type).currency
        );

        l_balance_type := l_balances.next(l_balance_type);
    end loop;
end;

procedure get_account_balance is
    l_account                       acc_api_type_pkg.t_account_rec;
    l_amount                        com_api_type_pkg.t_money;
    l_amount_name                   com_api_type_pkg.t_name;
    l_need_lock                     com_api_type_pkg.t_boolean;
begin
    opr_api_shared_data_pkg.get_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );

    l_need_lock := nvl(opr_api_shared_data_pkg.get_param_num (
        i_name                  => 'NEED_LOCK'
        , i_mask_error          => com_api_const_pkg.TRUE
        , i_error_value         => com_api_const_pkg.FALSE
    ), com_api_const_pkg.FALSE);

    get_account_aval (
        i_account_id        => l_account.account_id
        , o_amount          => l_amount
        , i_need_lock       => l_need_lock
    );

    l_amount_name := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'AMOUNT_NAME'
        , i_mask_error   => com_api_const_pkg.TRUE
        , i_error_value  => null
    );

    if l_amount_name is not null then
        opr_api_shared_data_pkg.set_amount(
            i_name        => l_amount_name
            , i_amount    => l_amount
            , i_currency  => l_account.currency
        );
    end if;
end;

procedure check_account_balance is

    l_account                       acc_api_type_pkg.t_account_rec;
    l_amount                        com_api_type_pkg.t_money;
    l_amount_name                   com_api_type_pkg.t_name;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_reason                        com_api_type_pkg.t_dict_value;
    l_need_lock                     com_api_type_pkg.t_boolean;

begin
    opr_api_shared_data_pkg.get_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );

    l_need_lock := nvl(opr_api_shared_data_pkg.get_param_num (
        i_name                  => 'NEED_LOCK'
        , i_mask_error          => com_api_const_pkg.TRUE
        , i_error_value         => com_api_const_pkg.FALSE
    ), com_api_const_pkg.FALSE);

    get_account_aval(
        i_account_id    => l_account.account_id
      , o_amount        => l_amount
      , i_need_lock     => l_need_lock
    );

    if l_amount < 0 then
        l_event_type :=
            opr_api_shared_data_pkg.get_param_char(
                i_name          => 'EVENT_TYPE'
              , i_mask_error    => com_api_const_pkg.TRUE
            );

        if l_event_type is not null then
            evt_api_event_pkg.register_event(
                i_event_type        => l_event_type
              , i_eff_date          => opr_api_shared_data_pkg.get_operation().host_date
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => l_account.account_id
              , i_inst_id           => l_account.inst_id
              , i_split_hash        => com_api_hash_pkg.get_split_hash(acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, l_account.account_id)
              , i_param_tab         => opr_api_shared_data_pkg.g_params
            );
        end if;

        l_reason := opr_api_shared_data_pkg.get_param_char('RESP_CODE', com_api_const_pkg.TRUE, aup_api_const_pkg.RESP_CODE_UNSUFFICIENT_FUNDS);

        opr_api_shared_data_pkg.rollback_process (
            i_id        => opr_api_shared_data_pkg.get_operation().id
            , i_status  => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
            , i_reason  => nvl(l_reason, aup_api_const_pkg.RESP_CODE_UNSUFFICIENT_FUNDS)
        );

    else
        l_amount_name := opr_api_shared_data_pkg.get_param_char(
            i_name           => 'AMOUNT_NAME'
            , i_mask_error   => com_api_const_pkg.TRUE
            , i_error_value  => com_api_const_pkg.AMOUNT_PURPOSE_ACCOUNT_AVAIL
        );

        opr_api_shared_data_pkg.set_amount(
            i_name        => l_amount_name
            , i_amount    => l_amount
            , i_currency  => l_account.currency
        );
    end if;
end;

procedure cancel_processing
is
    l_selector              com_api_type_pkg.t_name;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_entry_status          com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text           => 'Going to cancel processing [#1]'
        , i_env_param1   => opr_api_shared_data_pkg.get_operation().id
        , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    l_selector := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'OPERATION_SELECTOR'
        , i_mask_error   => com_api_const_pkg.TRUE
        , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
    );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
        i_selector => l_selector
    );

    l_entry_status := opr_api_shared_data_pkg.get_param_char(
            i_name           => 'ENTRY_STATUS'
            , i_mask_error   => com_api_const_pkg.TRUE
            , i_error_value  => acc_api_const_pkg.ENTRY_STATUS_CANCELED
    );
    l_entry_status := nvl(l_entry_status, acc_api_const_pkg.ENTRY_STATUS_CANCELED);

    acc_api_entry_pkg.cancel_processing (
        i_entity_type      => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_object_id      => l_oper_id
        , i_macros_status  => null
        , i_entry_status   => l_entry_status
    );

    fcl_api_limit_pkg.rollback_limit_counters (
        i_source_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_source_object_id  => l_oper_id
    );
end cancel_processing;

procedure load_transaction_data
is
    l_selector              com_api_type_pkg.t_name;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_id                    com_api_type_pkg.t_long_id;

    l_transaction_type      com_api_type_pkg.t_name;
    l_macros_type           com_api_type_pkg.t_tiny_id;
    l_error_mode            com_api_type_pkg.t_name;
    l_amount_purpose        com_api_type_pkg.t_name;

    l_debit_amount          com_api_type_pkg.t_amount_rec;
    l_debit_account         acc_api_type_pkg.t_account_rec;
    l_credit_amount         com_api_type_pkg.t_amount_rec;
    l_credit_account        acc_api_type_pkg.t_account_rec;

    l_debit_amount_name     com_api_type_pkg.t_name;
    l_debit_account_name    com_api_type_pkg.t_name;
    l_credit_amount_name    com_api_type_pkg.t_name;
    l_credit_account_name   com_api_type_pkg.t_name;
begin
    acc_api_entry_pkg.flush_job;

    l_id := opr_api_shared_data_pkg.get_operation().id;

    l_selector := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'OPERATION_SELECTOR'
        , i_mask_error   => com_api_const_pkg.TRUE
        , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
    );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
        i_selector => l_selector
    );

    l_macros_type := opr_api_shared_data_pkg.get_param_num(
        i_name           => 'MACROS_TYPE'
        , i_mask_error   => com_api_const_pkg.TRUE
        , i_error_value  => null
    );

    l_transaction_type := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'TRANSACTION_TYPE'
        , i_mask_error   => com_api_const_pkg.FALSE
    );

    l_amount_purpose := opr_api_shared_data_pkg.get_param_char(
        i_name          => 'AMOUNT_PURPOSE'
        , i_mask_error  => com_api_const_pkg.TRUE
    );

    select
          debit_amount
        , debit_currency
        , debit_id
        , debit_split_hash
        , debit_account_type
        , debit_account_number
        , debit_account_currency
        , debit_inst_id
        , debit_agent_id
        , debit_status
        , debit_contract_id
        , debit_customer_id
        , debit_scheme_id
        , credit_amount
        , credit_currency
        , credit_id
        , credit_split_hash
        , credit_account_type
        , credit_account_number
        , credit_account_currency
        , credit_inst_id
        , credit_agent_id
        , credit_status
        , credit_contract_id
        , credit_customer_id
        , credit_scheme_id
    into  l_debit_amount.amount
        , l_debit_amount.currency
        , l_debit_account.account_id
        , l_debit_account.split_hash
        , l_debit_account.account_type
        , l_debit_account.account_number
        , l_debit_account.currency
        , l_debit_account.inst_id
        , l_debit_account.agent_id
        , l_debit_account.status
        , l_debit_account.contract_id
        , l_debit_account.customer_id
        , l_debit_account.scheme_id
        , l_credit_amount.amount
        , l_credit_amount.currency
        , l_credit_account.account_id
        , l_credit_account.split_hash
        , l_credit_account.account_type
        , l_credit_account.account_number
        , l_credit_account.currency
        , l_credit_account.inst_id
        , l_credit_account.agent_id
        , l_credit_account.status
        , l_credit_account.contract_id
        , l_credit_account.customer_id
        , l_credit_account.scheme_id
     from (
        select
              min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  n.amount,         null)) debit_amount
            , min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  n.currency,       null)) debit_currency
            , min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  a.id,             null)) debit_id
            , min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  a.split_hash,     null)) debit_split_hash
            , min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  a.account_type,   null)) debit_account_type
            , min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  a.account_number, null)) debit_account_number
            , min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  a.currency,       null)) debit_account_currency
            , min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  a.inst_id,        null)) debit_inst_id
            , min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  a.agent_id,       null)) debit_agent_id
            , min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  a.status,         null)) debit_status
            , min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  a.contract_id,    null)) debit_contract_id
            , min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  a.customer_id,    null)) debit_customer_id
            , min(decode(n.balance_impact, com_api_const_pkg.DEBIT,  a.scheme_id,      null)) debit_scheme_id
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, n.amount,         null)) credit_amount
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, n.currency,       null)) credit_currency
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, a.id,             null)) credit_id
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, a.split_hash,     null)) credit_split_hash
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, a.account_type,   null)) credit_account_type
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, a.account_number, null)) credit_account_number
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, a.currency,       null)) credit_account_currency
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, a.inst_id,        null)) credit_inst_id
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, a.agent_id,       null)) credit_agent_id
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, a.status,         null)) credit_status
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, a.contract_id,    null)) credit_contract_id
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, a.customer_id,    null)) credit_customer_id
            , min(decode(n.balance_impact, com_api_const_pkg.CREDIT, a.scheme_id,      null)) credit_scheme_id
        from ( select e.amount
                    , e.currency
                    , e.transaction_id
                    , e.account_id
                    , e.balance_impact 
                 from acc_entry e
                    , acc_macros m
                where m.object_id        = l_oper_id
                  and m.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  and m.macros_type_id   = nvl(l_macros_type, m.macros_type_id)
                  and m.id               = e.macros_id
                  and e.transaction_type = nvl(l_transaction_type, e.transaction_type)
                  and e.status          != acc_api_const_pkg.ENTRY_STATUS_CANCELED
                  and (m.amount_purpose  = l_amount_purpose or l_amount_purpose is null)
               union all
               select e.amount
                    , e.currency
                    , e.transaction_id
                    , e.account_id
                    , e.balance_impact 
                 from acc_entry_buffer e
                    , acc_macros m
                where m.object_id        = l_oper_id
                  and m.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  and m.macros_type_id   = nvl(l_macros_type, m.macros_type_id)
                  and m.id               = e.macros_id
                  and e.transaction_type = nvl(l_transaction_type, e.transaction_type)
                  and e.status          != acc_api_const_pkg.ENTRY_STATUS_CANCELED
                  and (m.amount_purpose  = l_amount_purpose or l_amount_purpose is null)
              ) n
            , acc_account a
        where n.account_id = a.id
        group by n.transaction_id
    );

    l_debit_amount_name := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'DEBIT_AMOUNT_NAME'
        , i_mask_error   => com_api_const_pkg.FALSE
        , i_error_value  => null
    );
    l_debit_account_name := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'DEBIT_ACCOUNT_NAME'
        , i_mask_error   => com_api_const_pkg.FALSE
        , i_error_value  => null
    );
    l_credit_amount_name := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'CREDIT_AMOUNT_NAME'
        , i_mask_error   => com_api_const_pkg.FALSE
        , i_error_value  => null
    );
    l_credit_account_name := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'CREDIT_ACCOUNT_NAME'
        , i_mask_error   => com_api_const_pkg.FALSE
        , i_error_value  => null
    );

    if l_debit_amount_name is not null and l_debit_amount.amount is not null then
        opr_api_shared_data_pkg.set_amount(
            i_name        => l_debit_amount_name
            , i_amount    => l_debit_amount.amount
            , i_currency  => l_debit_amount.currency
        );
    end if;

    if l_debit_account_name is not null and l_debit_account.account_id is not null then
        opr_api_shared_data_pkg.set_account(
            i_name          => l_debit_account_name
            , i_account_rec => l_debit_account
        );

        if l_debit_account_name = com_api_const_pkg.ACCOUNT_PURPOSE_MERCHANT then
            update
                opr_participant
            set
                account_id              = l_debit_account.account_id
                , account_number        = l_debit_account.account_number
                , customer_id           = (select customer_id from acc_account where id = l_debit_account.account_id)
                , account_type          = l_debit_account.account_type
            where
                oper_id                 = l_id
                and participant_type    = com_api_const_pkg.PARTICIPANT_ACQUIRER;
        end if;
    end if;

    if l_credit_amount_name is not null and l_credit_amount.amount is not null then
        opr_api_shared_data_pkg.set_amount(
            i_name        => l_credit_amount_name
            , i_amount    => l_credit_amount.amount
            , i_currency  => l_credit_amount.currency
        );
    end if;

    if l_credit_account_name is not null and l_credit_account.account_id is not null then
        opr_api_shared_data_pkg.set_account(
            i_name          => l_credit_account_name
            , i_account_rec => l_credit_account
        );

        if l_credit_account_name = com_api_const_pkg.ACCOUNT_PURPOSE_MERCHANT then
            update
                opr_participant
            set
                account_id              = l_credit_account.account_id
                , account_number        = l_credit_account.account_number
                , customer_id           = (select customer_id from acc_account where id = l_credit_account.account_id)
                , account_type          = l_credit_account.account_type
            where
                oper_id                 = l_id
                and participant_type    = com_api_const_pkg.PARTICIPANT_ACQUIRER;
        end if;
    end if;

exception
    when no_data_found then
        l_error_mode := opr_api_shared_data_pkg.get_param_char(
            i_name           => 'NO_DATA_FOUND_MODE'
            , i_mask_error   => com_api_const_pkg.TRUE
            , i_error_value  => null
        );

        if l_error_mode in (opr_api_const_pkg.NDF_MODE_STOP_OPERATION
                          , opr_api_const_pkg.NDF_MODE_STOP_RULE_SET)
        then
            trc_log_pkg.debug(
                i_text         => 'TRANSACTION_IS_NOT_FOUND'
                , i_env_param1 => l_oper_id
                , i_env_param2 => l_macros_type
                , i_env_param3 => l_transaction_type
            );
            case l_error_mode
                when opr_api_const_pkg.NDF_MODE_STOP_OPERATION then
                    raise com_api_error_pkg.e_stop_process_operation;
                when opr_api_const_pkg.NDF_MODE_STOP_RULE_SET  then
                    raise com_api_error_pkg.e_stop_execute_rule_set;
            end case;
        elsif l_error_mode = opr_api_const_pkg.NDF_MODE_CONTINUE_OPERATION
        then
            trc_log_pkg.debug(
                i_text         => 'TRANSACTION_IS_NOT_FOUND'
                , i_env_param1 => l_oper_id
                , i_env_param2 => l_macros_type
                , i_env_param3 => l_transaction_type
            );
        else
            opr_api_shared_data_pkg.rollback_process (
                i_id         => l_oper_id
              , i_status     => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
              , i_reason     => aup_api_const_pkg.RESP_CODE_ERROR
            );
            com_api_error_pkg.raise_error(
                i_error      => 'TRANSACTION_IS_NOT_FOUND'
                , i_env_param1 => l_oper_id
                , i_env_param2 => l_macros_type
                , i_env_param3 => l_transaction_type
            );
        end if;

    when too_many_rows then
        trc_log_pkg.error(
            i_text       => 'TOO_MANY_TRANSACTION_FOUND'
          , i_env_param1 => l_oper_id
          , i_env_param2 => l_macros_type
          , i_env_param3 => l_transaction_type
          , i_env_param4 => l_amount_purpose
        );
end load_transaction_data;

procedure load_operation_amount is

    l_selector              com_api_type_pkg.t_name;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_amount_name           com_api_type_pkg.t_name;
    l_result_amount_name    com_api_type_pkg.t_name;
    l_result_amount         com_api_type_pkg.t_amount_rec;

begin
    l_selector := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'OPERATION_SELECTOR'
        , i_mask_error   => com_api_const_pkg.TRUE
        , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
    );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
        i_selector => l_selector
    );

    l_amount_name := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'AMOUNT_NAME'
        , i_mask_error   => com_api_const_pkg.FALSE
    );

    for rec in (
        select
            *
        from
            opr_operation_participant_vw o
        where
            id = l_oper_id
    ) loop
        case l_amount_name
            when com_api_const_pkg.AMOUNT_PURPOSE_OPER_ACTUAL then
                l_result_amount.amount := rec.oper_amount;
                l_result_amount.currency := rec.oper_currency;

            when com_api_const_pkg.AMOUNT_PURPOSE_OPER_REQUEST then
                l_result_amount.amount := rec.oper_request_amount;
                l_result_amount.currency := rec.oper_currency;

            when com_api_const_pkg.AMOUNT_PURPOSE_OPER_SURCHARGE then
                l_result_amount.amount := rec.oper_surcharge_amount;
                l_result_amount.currency := rec.oper_currency;

            when com_api_const_pkg.AMOUNT_PURPOSE_OPER_CASHBACK then
                l_result_amount.amount := rec.oper_cashback_amount;
                l_result_amount.currency := rec.oper_currency;

            when com_api_const_pkg.AMOUNT_PURPOSE_OPER_REPLACE then
                l_result_amount.amount := rec.oper_replacement_amount;
                l_result_amount.currency := rec.oper_currency;

            when com_api_const_pkg.AMOUNT_PURPOSE_SETTLEMENT then
                l_result_amount.amount := rec.sttl_amount;
                l_result_amount.currency := rec.sttl_currency;

            else
                trc_log_pkg.debug(
                    i_text          => 'Loading of amount [#1] for oper_id[#2] from opr_additional_amount.'
                  , i_env_param1    => l_amount_name
                  , i_env_param2    => l_oper_id
                );

                opr_api_additional_amount_pkg.get_amount(
                    i_oper_id     => l_oper_id
                  , i_amount_type => l_amount_name
                  , o_amount      => l_result_amount.amount
                  , o_currency    => l_result_amount.currency
                );
        end case;

        l_result_amount_name := nvl(opr_api_shared_data_pkg.get_param_char(
            i_name           => 'RESULT_AMOUNT_NAME'
            , i_mask_error   => com_api_const_pkg.TRUE
            , i_error_value  => l_amount_name
        ), l_amount_name);

        opr_api_shared_data_pkg.set_amount(
            i_name        => l_result_amount_name
            , i_amount    => l_result_amount.amount
            , i_currency  => l_result_amount.currency
        );
    end loop;
end;

procedure load_operation_accounts is

    l_selector              com_api_type_pkg.t_name;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_account               acc_api_type_pkg.t_account_rec;

begin
    l_selector := opr_api_shared_data_pkg.get_param_char(
                      i_name         => 'OPERATION_SELECTOR'
                    , i_mask_error   => com_api_const_pkg.TRUE
                    , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                  );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id  := opr_api_shared_data_pkg.get_operation_id (
                      i_selector     => l_selector
                  );

    for rec in (
        select m.amount_purpose
             , m.amount
             , m.currency
             , m.account_purpose
             , a.id              as account_id
             , a.split_hash
             , a.account_type
             , a.account_number
             , a.currency        as account_currency
             , a.inst_id
             , a.agent_id
             , a.status
             , a.contract_id
             , a.customer_id
             , a.scheme_id
          from acc_macros m
             , acc_account a
         where m.object_id   = l_oper_id
           and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and a.id          = m.account_id
    ) loop
        if rec.amount_purpose is not null then
            opr_api_shared_data_pkg.set_amount(
                i_name          => rec.amount_purpose
              , i_amount        => rec.amount
              , i_currency      => rec.currency
            );
        end if;

        if rec.account_purpose is not null then
            l_account.account_id     := rec.account_id;
            l_account.split_hash     := rec.split_hash;
            l_account.account_type   := rec.account_type;
            l_account.account_number := rec.account_number;
            l_account.currency       := rec.account_currency;
            l_account.inst_id        := rec.inst_id;
            l_account.agent_id       := rec.agent_id;
            l_account.status         := rec.status;
            l_account.contract_id    := rec.contract_id;
            l_account.customer_id    := rec.customer_id;
            l_account.scheme_id      := rec.scheme_id;

            opr_api_shared_data_pkg.set_account(
                i_name          => rec.account_purpose
              , i_account_rec   => l_account
            );
        end if;
    end loop;

    for rec in (
        select *
          from opr_operation_participant_vw o
         where id = l_oper_id
    ) loop
        opr_api_shared_data_pkg.set_amount(
            i_name              => com_api_const_pkg.AMOUNT_PURPOSE_OPER_ACTUAL
          , i_amount            => rec.oper_amount
          , i_currency          => rec.oper_currency
        );
        opr_api_shared_data_pkg.set_amount(
            i_name              => com_api_const_pkg.AMOUNT_PURPOSE_OPER_REQUEST
          , i_amount            => rec.oper_request_amount
          , i_currency          => rec.oper_currency
        );
        opr_api_shared_data_pkg.set_amount(
            i_name              => com_api_const_pkg.AMOUNT_PURPOSE_OPER_SURCHARGE
          , i_amount            => rec.oper_surcharge_amount
          , i_currency          => rec.oper_currency
        );
        opr_api_shared_data_pkg.set_amount(
            i_name              => com_api_const_pkg.AMOUNT_PURPOSE_OPER_CASHBACK
          , i_amount            => rec.oper_cashback_amount
          , i_currency          => rec.oper_currency
        );
        opr_api_shared_data_pkg.set_amount(
            i_name              => com_api_const_pkg.AMOUNT_PURPOSE_OPER_REPLACE
          , i_amount            => rec.oper_replacement_amount
          , i_currency          => rec.oper_currency
        );
        if rec.sttl_amount is not null then
            opr_api_shared_data_pkg.set_amount(
                i_name          => com_api_const_pkg.AMOUNT_PURPOSE_SETTLEMENT
              , i_amount        => rec.sttl_amount
              , i_currency      => rec.sttl_currency
            );
        end if;

        acc_api_account_pkg.get_account_info (
            i_account_id        => rec.account_id
          , o_account_rec       => l_account
        );
        if l_account.account_id is not null then
            opr_api_shared_data_pkg.set_account(
                i_name          => com_api_const_pkg.ACCOUNT_PURPOSE_CARD
              , i_account_rec   => l_account
            );
        end if;

        acc_api_account_pkg.get_account_info (
            i_account_id        => rec.acq_account_id
          , o_account_rec       => l_account
        );
        if l_account.account_id is not null then
            opr_api_shared_data_pkg.set_account(
                i_name          => com_api_const_pkg.ACCOUNT_PURPOSE_MERCHANT
              , i_account_rec   => l_account
            );
        end if;

        acc_api_account_pkg.get_account_info (
            i_account_id        => rec.dst_account_id
          , o_account_rec       => l_account
        );
        if l_account.account_id is not null then
            opr_api_shared_data_pkg.set_account(
                i_name          => com_api_const_pkg.ACCOUNT_PURPOSE_DESTINATION
              , i_account_rec   => l_account
            );
        end if;
    end loop;
end load_operation_accounts;

procedure calculate_fee_reversal is

    l_original_amount_name          com_api_type_pkg.t_name;
    l_reversal_amount_name          com_api_type_pkg.t_name;
    l_original_fee_amount_name      com_api_type_pkg.t_name;
    l_replacement_fee_amount_name   com_api_type_pkg.t_name;
    l_result_amount_name            com_api_type_pkg.t_name;

    l_original_amount               com_api_type_pkg.t_amount_rec;
    l_reversal_amount               com_api_type_pkg.t_amount_rec;
    l_original_fee_amount           com_api_type_pkg.t_amount_rec;
    l_replacement_fee_amount        com_api_type_pkg.t_amount_rec;
    l_result_amount                 com_api_type_pkg.t_amount_rec;

begin
    l_original_amount_name := opr_api_shared_data_pkg.get_param_char('ORIGINAL_AMOUNT_NAME');
    l_reversal_amount_name := opr_api_shared_data_pkg.get_param_char('REVERSAL_AMOUNT_NAME');
    l_original_fee_amount_name := opr_api_shared_data_pkg.get_param_char('ORIGINAL_FEE_AMOUNT_NAME');
    l_replacement_fee_amount_name := opr_api_shared_data_pkg.get_param_char('REPLACEMENT_FEE_AMOUNT_NAME');
    l_result_amount_name := opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_original_amount_name
        , o_amount    => l_original_amount.amount
        , o_currency  => l_original_amount.currency
    );

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_reversal_amount_name
        , o_amount    => l_reversal_amount.amount
        , o_currency  => l_reversal_amount.currency
    );

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_original_fee_amount_name
        , o_amount    => l_original_fee_amount.amount
        , o_currency  => l_original_fee_amount.currency
    );

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_replacement_fee_amount_name
        , o_amount    => l_replacement_fee_amount.amount
        , o_currency  => l_replacement_fee_amount.currency
    );

    if (
        l_original_amount.amount = l_reversal_amount.amount
        and l_original_amount.currency = l_reversal_amount.currency
    ) then  -- full reversal - reversing full amount of original fee
        l_result_amount := l_original_fee_amount;

    else   -- partial reversal - reversing difference between original fee and replacement fee
        if l_original_fee_amount.currency = l_replacement_fee_amount.currency then
            l_result_amount := l_original_fee_amount;
            l_result_amount.amount := greatest(l_result_amount.amount - l_replacement_fee_amount.amount, 0);
        else
            com_api_error_pkg.raise_error(
                i_error         => 'ATTEMPT_TO_SUBTRACT_DIFFERENT_CURRENCY'
                , i_env_param1  => l_original_fee_amount.currency
                , i_env_param2  => l_replacement_fee_amount.currency
            );
        end if;
    end if;

    opr_api_shared_data_pkg.set_amount(
        i_name        => l_result_amount_name
        , i_amount    => l_result_amount.amount
        , i_currency  => l_result_amount.currency
    );
end;

-- not refactored


procedure check_balance_positive is
    l_account                acc_api_type_pkg.t_account_rec;
    l_balance_type           com_api_type_pkg.t_dict_value;
    l_amount                 com_api_type_pkg.t_amount_rec;
    l_amount_name            com_api_type_pkg.t_name;
    l_reason                 com_api_type_pkg.t_dict_value;
    l_withdrawal_amount_name com_api_type_pkg.t_name;
    l_withdrawal_amount      com_api_type_pkg.t_amount_rec;
    l_miss_testmode          com_api_type_pkg.t_dict_value;
begin
    opr_api_shared_data_pkg.get_account(
        i_name            => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec     => l_account
    );

    l_balance_type  := opr_api_shared_data_pkg.get_param_char('BALANCE_TYPE');

    l_amount_name := opr_api_shared_data_pkg.get_param_char(
                         i_name         => 'AMOUNT_NAME'
                       , i_mask_error   => com_api_const_pkg.TRUE
                       , i_error_value  => l_balance_type
                     );

    l_amount      := acc_api_balance_pkg.get_balance_amount(
                         i_account_id    => l_account.account_id
                       , i_balance_type  => l_balance_type
                       , i_mask_error    => com_api_const_pkg.FALSE
                       , i_lock_balance  => com_api_const_pkg.FALSE
                     );

    opr_api_shared_data_pkg.set_amount(
        i_name      => l_amount_name
      , i_amount    => l_amount.amount
      , i_currency  => l_amount.currency
    );

    l_withdrawal_amount_name := opr_api_shared_data_pkg.get_param_char(
                                    i_name        => 'AMOUNT_NAME_#1'
                                  , i_mask_error  => com_api_const_pkg.TRUE
                                );

    if l_withdrawal_amount_name is not null then
        opr_api_shared_data_pkg.get_amount(
            i_name      => l_withdrawal_amount_name
          , o_amount    => l_withdrawal_amount.amount
          , o_currency  => l_withdrawal_amount.currency
        );

        if l_amount.currency = l_withdrawal_amount.currency then
            l_amount.amount := l_amount.amount - l_withdrawal_amount.amount;
        else
            com_api_error_pkg.raise_error(
                i_error       => 'ATTEMPT_TO_ADD_DIFFERENT_CURRENCY'
              , i_env_param1  => l_amount.currency
              , i_env_param2  => l_withdrawal_amount.currency
            );
        end if;
    end if;

    if l_amount.amount <= 0 then
        l_miss_testmode := nvl(opr_api_shared_data_pkg.get_param_char(
                                   i_name        => 'ATTR_MISS_TESTMODE'
                                 , i_mask_error  => com_api_const_pkg.TRUE
                                 , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                               )
                             , fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                           );

        if l_miss_testmode in (fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE) then
            raise com_api_error_pkg.e_stop_execute_rule_set;

        -- Forbid to call rollback_process if amount is zero for backward compatibility
        elsif l_miss_testmode != fcl_api_const_pkg.ATTR_MISS_IGNORE
              and
              l_amount.amount != 0
        then
            l_reason := opr_api_shared_data_pkg.get_param_char(
                            i_name        => 'RESP_CODE'
                          , i_mask_error  => com_api_const_pkg.TRUE
                          , i_error_value => aup_api_const_pkg.RESP_CODE_UNSUFFICIENT_FUNDS
                        );
            opr_api_shared_data_pkg.rollback_process(
                i_id     => opr_api_shared_data_pkg.get_operation().id
              , i_status => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
              , i_reason => l_reason
            );
        end if;
    end if;
end;

procedure check_amount_positive is
    l_amount         com_api_type_pkg.t_amount_rec;
    l_reason         com_api_type_pkg.t_dict_value;
    l_miss_testmode  com_api_type_pkg.t_dict_value;
begin
    opr_api_shared_data_pkg.get_amount(
        i_name        => opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME')
      , o_amount      => l_amount.amount
      , o_currency    => l_amount.currency
    );

    if l_amount.amount <= 0 then
        l_miss_testmode := nvl(opr_api_shared_data_pkg.get_param_char(
                                   i_name        => 'ATTR_MISS_TESTMODE'
                                 , i_mask_error  => com_api_const_pkg.TRUE
                                 , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                               )
                             , fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                           );

        if l_miss_testmode in (fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE) then
            raise com_api_error_pkg.e_stop_execute_rule_set;

        -- Forbid to call rollback_process if amount is zero for backward compatibility
        elsif l_miss_testmode != fcl_api_const_pkg.ATTR_MISS_IGNORE
              and
              l_amount.amount != 0
        then
            l_reason := opr_api_shared_data_pkg.get_param_char(
                            i_name        => 'RESP_CODE'
                          , i_mask_error  => com_api_const_pkg.TRUE
                          , i_error_value => aup_api_const_pkg.RESP_CODE_UNSUFFICIENT_FUNDS
                        );
            opr_api_shared_data_pkg.rollback_process(
                i_id     => opr_api_shared_data_pkg.get_operation().id
              , i_status => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
              , i_reason => l_reason
            );
        end if;
    end if;
end;

procedure conditional_fee_calculation is
    l_fee_type                      com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;

    l_result_amount_name            com_api_type_pkg.t_name;
    l_result_amount                 com_api_type_pkg.t_amount_rec;

    l_object_id                     com_api_type_pkg.t_long_id;
    l_fee_id                        com_api_type_pkg.t_long_id;
    l_product_id                    com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;

    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
begin
    l_fee_type :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'FEE_TYPE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type   := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');

    l_test_mode := 
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'ATTR_MISS_TESTMODE'
          , i_mask_error  => com_api_const_pkg.TRUE
          , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
        );

    if opr_api_shared_data_pkg.get_operation().oper_request_amount = 0 then
        l_fee_type := nvl(l_fee_type, opr_api_shared_data_pkg.get_operation().oper_reason);

        if substr(l_fee_type, 1, 4) != fcl_api_const_pkg.FEE_TYPE_STATUS_KEY then
            com_api_error_pkg.raise_error(
                i_error       => 'WRONG_FEE_TYPE_SPECIFIED'
              , i_env_param1  => opr_api_shared_data_pkg.get_operation().oper_type
              , i_env_param2  => l_fee_type
            );
        end if;

        l_object_id :=
            opr_api_shared_data_pkg.get_object_id(
                io_entity_type  => l_entity_type
              , i_account_name  => l_account_name
              , i_party_type    => l_party_type
              , o_inst_id       => l_inst_id
            );
        l_product_id :=
            prd_api_product_pkg.get_product_id(
                i_entity_type   => l_entity_type
              , i_object_id     => l_object_id
            );
        l_eff_date_name :=
            opr_api_shared_data_pkg.get_param_char(
                i_name          => 'EFFECTIVE_DATE'
              , i_mask_error    => com_api_const_pkg.TRUE
              , i_error_value   => null
            );

        if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
            l_eff_date := 
                com_api_sttl_day_pkg.get_open_sttl_date(
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
            l_fee_id :=
                prd_api_product_pkg.get_fee_id(
                    i_product_id   => l_product_id
                  , i_entity_type  => l_entity_type
                  , i_object_id    => l_object_id
                  , i_fee_type     => l_fee_type
                  , i_params       => opr_api_shared_data_pkg.g_params
                  , i_eff_date     => l_eff_date
                  , i_inst_id      => l_inst_id
                );

            l_result_amount.currency := null;

            l_result_amount.amount := round(
                fcl_api_fee_pkg.get_fee_amount(
                    i_fee_id          => l_fee_id
                  , i_base_amount     => 0
                  , io_base_currency  => l_result_amount.currency
                  , i_entity_type     => l_entity_type
                  , i_object_id       => l_object_id
                )
            );
        exception
            when others then
                if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE and com_api_error_pkg.get_last_error = 'FEE_NOT_DEFINED'
                   and l_test_mode = fcl_api_const_pkg.ATTR_MISS_ZERO_VALUE
                then
                    l_result_amount.amount := 0;
                    l_result_amount.currency := com_api_const_pkg.UNDEFINED_CURRENCY;
                else
                    raise;
                end if;
        end;

        l_result_amount_name :=
            opr_api_shared_data_pkg.get_param_char(
                i_name         => 'RESULT_AMOUNT_NAME'
              , i_mask_error   => com_api_const_pkg.TRUE
              , i_error_value  => l_fee_type
            );

        opr_api_shared_data_pkg.set_amount(
            i_name      => nvl(l_result_amount_name, l_fee_type)
          , i_amount    => l_result_amount.amount
          , i_currency  => l_result_amount.currency
        );

        opr_api_shared_data_pkg.set_amount(
            i_name      => com_api_const_pkg.AMOUNT_PURPOSE_OPER_ACTUAL
          , i_amount    => l_result_amount.amount
          , i_currency  => l_result_amount.currency
        );
    end if;
end conditional_fee_calculation;

procedure calculate_fee
is
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    l_fee_type                      com_api_type_pkg.t_name;
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
begin
    l_amount_name := opr_api_shared_data_pkg.get_param_char('BASE_AMOUNT_NAME');

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_amount_name
      , o_amount      => l_amount.amount
      , o_currency    => l_amount.currency
    );

    l_fee_type          := opr_api_shared_data_pkg.get_param_char('FEE_TYPE');
    l_entity_type       := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name      := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type        := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_fee_currency_type := opr_api_shared_data_pkg.get_param_char(
                               i_name        => 'FEE_CURRENCY_TYPE'
                             , i_mask_error  => com_api_const_pkg.TRUE
                             , i_error_value => fcl_api_const_pkg.FEE_CURRENCY_TYPE_FEE
                           );
    l_forced_processing := opr_api_shared_data_pkg.get_operation().forced_processing;

    l_object_id         := opr_api_shared_data_pkg.get_object_id(
                               i_entity_type   => l_entity_type
                             , i_account_name  => l_account_name
                             , i_party_type    => l_party_type
                             , o_inst_id       => l_inst_id
                           );
    l_test_mode         := opr_api_shared_data_pkg.get_param_char(
                               i_name        => 'ATTR_MISS_TESTMODE'
                             , i_mask_error  => com_api_const_pkg.TRUE
                             , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                           );
    l_inst_id :=
        opr_api_shared_data_pkg.get_participant(
            i_participant_type    => l_party_type
        ).inst_id;

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type  => l_entity_type
          , i_object_id  => l_object_id
        );

    opr_api_shared_data_pkg.get_date(
        i_name      => com_api_const_pkg.DATE_PURPOSE_OPERATION
      , o_date      => l_oper_date
    );

    l_eff_date_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'EFFECTIVE_DATE'
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => null
        );

    if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_eff_date :=
            com_api_sttl_day_pkg.get_open_sttl_date(
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
        if nvl(l_forced_processing, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            l_fee_id :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id   => l_product_id
                  , i_entity_type  => l_entity_type
                  , i_object_id    => l_object_id
                  , i_fee_type     => l_fee_type
                  , i_params       => opr_api_shared_data_pkg.g_params
                  , i_eff_date     => l_eff_date
                  , i_inst_id      => l_inst_id
                );
        else
            l_service_id :=
                prd_api_service_pkg.get_active_service_id(
                    i_entity_type    => l_entity_type
                  , i_object_id      => l_object_id
                  , i_attr_type      => l_fee_type
                  , i_eff_date       => l_eff_date
                );
            l_fee_id :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id     => l_product_id
                  , i_entity_type  => l_entity_type
                  , i_object_id    => l_object_id
                  , i_fee_type     => l_fee_type
                  , i_params       => opr_api_shared_data_pkg.g_params
                  , i_service_id   => l_service_id
                  , i_eff_date     => l_eff_date
                  , i_inst_id      => l_inst_id
                );
        end if;

        if l_fee_currency_type = fcl_api_const_pkg.FEE_CURRENCY_TYPE_BASE then
            l_result_amount.currency := l_amount.currency;
        end if;

        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_fee_id
          , i_base_amount       => abs(l_amount.amount)
          , i_base_currency     => l_amount.currency
          , i_entity_type       => l_entity_type
          , i_object_id         => l_object_id
          , i_eff_date          => l_eff_date
          , io_fee_currency     => l_result_amount.currency
          , o_fee_amount        => l_result_amount.amount
          , i_oper_date         => l_oper_date
        );
        l_result_amount.amount := round(l_result_amount.amount);
    exception
        when others then
            if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
               and com_api_error_pkg.get_last_error in ('FEE_NOT_DEFINED', 'NO_APPLICABLE_CONDITION', 'PRD_NO_ACTIVE_SERVICE')
               and l_test_mode = fcl_api_const_pkg.ATTR_MISS_ZERO_VALUE
            then
                l_result_amount.amount := 0;
                l_result_amount.currency := com_api_const_pkg.UNDEFINED_CURRENCY;
            else
                raise;
            end if;
    end;

    l_result_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'RESULT_AMOUNT_NAME'
          , i_mask_error  => com_api_const_pkg.TRUE
          , i_error_value => l_fee_type
        );

    opr_api_shared_data_pkg.set_param(
        i_name  => 'RESULT_AMOUNT_NAME'
      , i_value => to_char(null)
    );

    opr_api_shared_data_pkg.set_amount(
        i_name      => nvl(l_result_amount_name, l_fee_type)
      , i_amount    => l_result_amount.amount
      , i_currency  => l_result_amount.currency
    );
end calculate_fee;

procedure reset_limit_counter
is
    l_limit_type                    com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_seq_number                    com_api_type_pkg.t_tiny_id;
    l_expir_date                    date;
begin
    l_limit_type    := opr_api_shared_data_pkg.get_param_char('LIMIT_TYPE');
    l_entity_type   := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name  := opr_api_shared_data_pkg.get_param_char(
                           i_name          => 'ACCOUNT_NAME'
                         , i_mask_error  => com_api_const_pkg.TRUE
                       );
    l_party_type    := opr_api_shared_data_pkg.get_param_char(
                           i_name          => 'PARTY_TYPE'
                         , i_mask_error  => com_api_const_pkg.TRUE
                       );
    l_object_id     := opr_api_shared_data_pkg.get_object_id(
                           i_entity_type   => l_entity_type
                         , i_account_name  => l_account_name
                         , i_party_type    => l_party_type
                         , o_inst_id       => l_inst_id
                       );
    trc_log_pkg.debug(
        i_text         => 'Going to reset counter [#1][#2][#3]'
      , i_env_param1   => l_limit_type
      , i_env_param2   => l_entity_type
      , i_env_param3   => l_object_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    fcl_api_limit_pkg.zero_limit_counter(
        i_limit_type   => l_limit_type
      , i_entity_type  => l_entity_type
      , i_object_id    => l_object_id
    );

    if l_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD) then
        l_seq_number := opr_api_shared_data_pkg.get_participant(l_party_type).card_seq_number;
        l_expir_date := opr_api_shared_data_pkg.get_participant(l_party_type).card_expir_date;

        l_object_id := iss_api_card_instance_pkg.get_card_instance_id(
                           i_card_id     => l_object_id
                         , i_seq_number  => l_seq_number
                         , i_expir_date  => l_expir_date
                         , i_state       => iss_api_const_pkg.CARD_STATE_ACTIVE
                         , i_raise_error => com_api_const_pkg.TRUE
                       );

        evt_api_event_pkg.register_event(
            i_event_type   => iss_api_const_pkg.EVENT_TYPE_ZERO_WRONGPIN_LIMIT
          , i_eff_date     => opr_api_shared_data_pkg.get_operation().host_date
          , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id    => l_object_id
          , i_inst_id      => l_inst_id
          , i_split_hash   => null
          , i_param_tab    => opr_api_shared_data_pkg.g_params
        );
    end if;
end reset_limit_counter;

procedure switch_limit_counter
is
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_limit_amount                  com_api_type_pkg.t_amount_rec;
    l_limit_type                    com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_product_id                    com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_check_overlimit               com_api_type_pkg.t_boolean;
    l_switch_limit                  com_api_type_pkg.t_boolean;
    l_reason                        com_api_type_pkg.t_dict_value;
    l_def_reason                    com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_count_curr                    com_api_type_pkg.t_long_id;
    l_count_limit                   com_api_type_pkg.t_long_id;
    l_sum_value                     com_api_type_pkg.t_money;
    l_sum_limit                     com_api_type_pkg.t_money;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
    l_forced_processing             com_api_type_pkg.t_boolean;
    l_service_id                    com_api_type_pkg.t_short_id;
begin
    l_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'AMOUNT_NAME'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    if l_amount_name is not null then
        opr_api_shared_data_pkg.get_amount(
            i_name      => l_amount_name
          , o_amount    => l_amount.amount
          , o_currency  => l_amount.currency
        );
    end if;

    l_limit_type        := opr_api_shared_data_pkg.get_param_char('LIMIT_TYPE');
    l_entity_type       := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_check_overlimit   := opr_api_shared_data_pkg.get_param_num('CHECK_OVERLIMIT');
    l_switch_limit      := opr_api_shared_data_pkg.get_param_num('SWITCH_LIMIT');
    l_forced_processing := opr_api_shared_data_pkg.get_operation().forced_processing;

    l_account_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'ACCOUNT_NAME'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    l_party_type :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'PARTY_TYPE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    if nvl(l_party_type, com_api_const_pkg.PARTICIPANT_ISSUER) = com_api_const_pkg.PARTICIPANT_ISSUER then
        l_def_reason := aup_api_const_pkg.RESP_CODE_LIMIT_EXCEEDED;
    else
        l_def_reason := aut_api_const_pkg.AUTH_REASON_DST_LIMIT_EXCEED;
    end if;

    l_reason :=
        opr_api_shared_data_pkg.get_param_char(
            i_name      => 'RESP_CODE'
          , i_mask_error  => com_api_const_pkg.TRUE
          , i_error_value => l_def_reason
        );

    l_object_id :=
        opr_api_shared_data_pkg.get_object_id(
            i_entity_type   => l_entity_type
          , i_account_name  => l_account_name
          , i_party_type    => l_party_type
          , o_inst_id       => l_inst_id
        );

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
        );

    l_test_mode :=
        opr_api_shared_data_pkg.get_param_char(
            i_name         => 'ATTR_MISS_TESTMODE'
          , i_mask_error   => com_api_const_pkg.TRUE
          , i_error_value  => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
        );

    l_eff_date_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name         => 'EFFECTIVE_DATE'
          , i_mask_error   => com_api_const_pkg.TRUE
          , i_error_value  => null
        );

    if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_eff_date :=
            com_api_sttl_day_pkg.get_open_sttl_date(
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
        if nvl(l_forced_processing, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            fcl_api_limit_pkg.switch_limit_counter(
                i_limit_type            => l_limit_type
              , i_product_id            => l_product_id
              , i_entity_type           => l_entity_type
              , i_object_id             => l_object_id
              , i_params                => opr_api_shared_data_pkg.g_params
              , i_count_value           => opr_api_shared_data_pkg.get_operation().oper_count
              , i_eff_date              => l_eff_date
              , i_sum_value             => l_amount.amount
              , i_currency              => l_amount.currency
              , i_inst_id               => l_inst_id
              , i_check_overlimit       => l_check_overlimit
              , i_switch_limit          => l_switch_limit
              , i_source_entity_type    => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_source_object_id      => opr_api_shared_data_pkg.get_operation().id
              , o_count_curr            => l_count_curr
              , o_count_limit           => l_count_limit
              , o_currency              => l_limit_amount.currency
              , o_sum_value             => l_sum_value
              , o_sum_limit             => l_sum_limit
              , o_sum_curr              => l_limit_amount.amount
              , i_test_mode             => l_test_mode
              , i_use_base_currency     => com_api_const_pkg.FALSE
            );
        else
            l_service_id :=
                prd_api_service_pkg.get_active_service_id(
                    i_entity_type    => l_entity_type
                  , i_object_id      => l_object_id
                  , i_attr_type      => l_limit_type
                  , i_eff_date       => l_eff_date
                );

            fcl_api_limit_pkg.switch_limit_counter(
                i_limit_type            => l_limit_type
              , i_product_id            => l_product_id
              , i_entity_type           => l_entity_type
              , i_object_id             => l_object_id
              , i_params                => opr_api_shared_data_pkg.g_params
              , i_count_value           => opr_api_shared_data_pkg.get_operation().oper_count
              , i_eff_date              => l_eff_date
              , i_sum_value             => l_amount.amount
              , i_currency              => l_amount.currency
              , i_inst_id               => l_inst_id
              , i_check_overlimit       => l_check_overlimit
              , i_switch_limit          => l_switch_limit
              , i_source_entity_type    => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_source_object_id      => opr_api_shared_data_pkg.get_operation().id
              , o_count_curr            => l_count_curr
              , o_count_limit           => l_count_limit
              , o_currency              => l_limit_amount.currency
              , o_sum_value             => l_sum_value
              , o_sum_limit             => l_sum_limit
              , o_sum_curr              => l_limit_amount.amount
              , i_service_id            => l_service_id
              , i_test_mode             => l_test_mode
              , i_use_base_currency     => com_api_const_pkg.FALSE
            );
        end if;

        opr_api_shared_data_pkg.set_amount(
            i_name      => l_limit_type
          , i_amount    => l_limit_amount.amount
          , i_currency  => l_limit_amount.currency
        );
    exception
        when others then
            if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
                and com_api_error_pkg.get_last_error = 'OVERLIMIT' then

                l_event_type :=
                    opr_api_shared_data_pkg.get_param_char(
                        i_name          => 'EVENT_TYPE'
                      , i_mask_error    => com_api_const_pkg.TRUE
                    );

                if l_event_type is not null then
                    evt_api_event_pkg.register_event(
                        i_event_type        => l_event_type
                      , i_eff_date          => opr_api_shared_data_pkg.get_operation().host_date
                      , i_entity_type       => l_entity_type
                      , i_object_id         => l_object_id
                      , i_inst_id           => l_inst_id
                      , i_split_hash        => com_api_hash_pkg.get_split_hash(l_entity_type, l_object_id)
                      , i_param_tab         => opr_api_shared_data_pkg.g_params
                    );
                end if;

                opr_api_shared_data_pkg.rollback_process (
                    i_id      => opr_api_shared_data_pkg.get_operation().id
                  , i_status  => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                  , i_reason  => l_reason
                );

            else
                raise;
            end if;
    end;
end switch_limit_counter;

procedure get_limit_remainder
is
    l_amount_name              com_api_type_pkg.t_name;
    l_amount                   com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_limit_type                    com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_product_id                    com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_last_reset_date               date;
    l_count_curr                    com_api_type_pkg.t_long_id;
    l_count_limit                   com_api_type_pkg.t_long_id;
    l_sum_limit                     com_api_type_pkg.t_money;
    l_sum_curr                      com_api_type_pkg.t_money;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
begin
    l_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'AMOUNT_NAME'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    if l_amount_name is not null then
        opr_api_shared_data_pkg.get_amount(
            i_name        => l_amount_name
          , o_amount      => l_amount.amount
          , o_currency    => l_amount.currency
        );
    else
        l_amount.amount := 0;
    end if;

    l_limit_type  := opr_api_shared_data_pkg.get_param_char('LIMIT_TYPE');
    l_entity_type := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');

    l_account_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'ACCOUNT_NAME'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    l_party_type :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'PARTY_TYPE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    l_object_id :=
        opr_api_shared_data_pkg.get_object_id(
            i_entity_type   => l_entity_type
          , i_account_name  => l_account_name
          , i_party_type    => l_party_type
          , o_inst_id       => l_inst_id
        );

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
        );

    l_eff_date_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'EFFECTIVE_DATE'
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => null
        );

    if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_eff_date :=
            com_api_sttl_day_pkg.get_open_sttl_date(
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

    fcl_api_limit_pkg.get_limit_counter (
        i_limit_type        => l_limit_type
      , i_product_id        => l_product_id
      , i_entity_type       => l_entity_type
      , i_object_id         => l_object_id
      , i_params            => opr_api_shared_data_pkg.g_params
      , io_currency         => l_amount.currency
      , o_last_reset_date   => l_last_reset_date
      , o_count_curr        => l_count_curr
      , o_count_limit       => l_count_limit
      , o_sum_limit         => l_sum_limit
      , o_sum_curr          => l_sum_curr
      , i_eff_date          => l_eff_date
    );

    l_result_amount_name := opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    opr_api_shared_data_pkg.set_amount(
        i_name      => l_result_amount_name
      , i_amount    => greatest(0, (l_sum_limit - l_sum_curr))
      , i_currency  => l_amount.currency
    );
end get_limit_remainder;

procedure switch_cycle
is
    l_base_date_name                com_api_type_pkg.t_name;
    l_base_date                     date;
    l_result_date_name              com_api_type_pkg.t_name;
    l_result_date                   date;
    l_cycle_type                    com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_product_id                    com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
    l_forced_processing             com_api_type_pkg.t_boolean;
    l_service_id                    com_api_type_pkg.t_short_id;
begin
    l_base_date_name := opr_api_shared_data_pkg.get_param_char('BASE_DATE_NAME');
    if l_base_date_name is not null then
        opr_api_shared_data_pkg.get_date(
            i_name  => l_base_date_name
          , o_date  => l_base_date
        );
    end if;

    l_cycle_type        := opr_api_shared_data_pkg.get_param_char('CYCLE_TYPE');
    l_entity_type       := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name      := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type        := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_forced_processing := opr_api_shared_data_pkg.get_operation().forced_processing;
    l_object_id         := opr_api_shared_data_pkg.get_object_id(
                               i_entity_type   => l_entity_type
                             , i_account_name  => l_account_name
                             , i_party_type    => l_party_type
                             , o_inst_id       => l_inst_id
                           );
    l_product_id        := prd_api_product_pkg.get_product_id(
                               i_entity_type   => l_entity_type
                             , i_object_id     => l_object_id
                           );
    l_test_mode         := opr_api_shared_data_pkg.get_param_char(
                               i_name          => 'ATTR_MISS_TESTMODE'
                             , i_mask_error    => com_api_const_pkg.TRUE
                             , i_error_value   => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                           );
    l_eff_date_name     := opr_api_shared_data_pkg.get_param_char(
                               i_name          => 'EFFECTIVE_DATE'
                             , i_mask_error    => com_api_const_pkg.TRUE
                             , i_error_value   => null
                           );

    if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_eff_date :=
            com_api_sttl_day_pkg.get_open_sttl_date(
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

    if nvl(l_forced_processing, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then

        fcl_api_cycle_pkg.switch_cycle(
            i_cycle_type       => l_cycle_type
          , i_product_id       => l_product_id
          , i_entity_type      => l_entity_type
          , i_object_id        => l_object_id
          , i_params           => opr_api_shared_data_pkg.g_params
          , i_start_date       => l_base_date
          , i_eff_date         => l_eff_date
          , o_new_finish_date  => l_result_date
          , i_test_mode        => l_test_mode
        );
    else
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type  => l_entity_type
              , i_object_id    => l_object_id
              , i_attr_type    => l_cycle_type
              , i_eff_date     => l_eff_date
            );

        fcl_api_cycle_pkg.switch_cycle(
            i_cycle_type       => l_cycle_type
          , i_product_id       => l_product_id
          , i_entity_type      => l_entity_type
          , i_object_id        => l_object_id
          , i_params           => opr_api_shared_data_pkg.g_params
          , i_start_date       => l_base_date
          , i_eff_date         => l_eff_date
          , i_service_id       => l_service_id
          , o_new_finish_date  => l_result_date
          , i_test_mode        => l_test_mode
        );
    end if;

    l_result_date_name := opr_api_shared_data_pkg.get_param_char('RESULT_DATE_NAME');

    opr_api_shared_data_pkg.set_date(
        i_name  => l_result_date_name
      , i_date  => l_result_date
    );
end switch_cycle;

procedure calculate_cycle_date
is
    l_base_date_name                com_api_type_pkg.t_name;
    l_base_date                     date;
    l_result_date_name              com_api_type_pkg.t_name;
    l_result_date                   date;
    l_cycle_type                    com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_cycle_id                      com_api_type_pkg.t_long_id;
    l_product_id                    com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
    l_forced_processing             com_api_type_pkg.t_boolean;
    l_service_id                    com_api_type_pkg.t_short_id;
begin
    l_base_date_name := opr_api_shared_data_pkg.get_param_char('BASE_DATE_NAME');

    opr_api_shared_data_pkg.get_date (
        i_name    => l_base_date_name
        , o_date  => l_base_date
    );

    l_cycle_type        := opr_api_shared_data_pkg.get_param_char('CYCLE_TYPE');
    l_entity_type       := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name      := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type        := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_forced_processing := opr_api_shared_data_pkg.get_operation().forced_processing;

    l_object_id :=
        opr_api_shared_data_pkg.get_object_id(
            i_entity_type   => l_entity_type
          , i_account_name  => l_account_name
          , i_party_type    => l_party_type
          , o_inst_id       => l_inst_id
        );

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
        );

    l_eff_date_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'EFFECTIVE_DATE'
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => null
        );

    if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_eff_date :=
            com_api_sttl_day_pkg.get_open_sttl_date(
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

    if nvl(l_forced_processing, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type    => l_entity_type
              , i_object_id      => l_object_id
              , i_attr_type      => l_cycle_type
              , i_eff_date       => l_eff_date
            );
    end if;

    l_cycle_id :=
        prd_api_product_pkg.get_cycle_id (
            i_product_id    => l_product_id
          , i_entity_type   => l_entity_type
          , i_object_id     => l_object_id
          , i_cycle_type    => l_cycle_type
          , i_params        => opr_api_shared_data_pkg.g_params
          , i_service_id    => l_service_id
          , i_eff_date      => l_eff_date
          , i_inst_id       => l_inst_id
        );

    l_result_date :=
        fcl_api_cycle_pkg.calc_next_date (
            i_cycle_id      => l_cycle_id
          , i_start_date    => l_base_date
        );

    l_result_date_name := opr_api_shared_data_pkg.get_param_char('RESULT_DATE_NAME');

    opr_api_shared_data_pkg.set_date (
        i_name      => l_result_date_name
      , i_date      => l_result_date
    );
end calculate_cycle_date;

procedure select_object_account
is
    l_algo_id                       com_api_type_pkg.t_tiny_id;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_dict_value;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_account_number                com_api_type_pkg.t_account_number;
    l_iso_type                      com_api_type_pkg.t_dict_value;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_participant_rec               opr_api_type_pkg.t_oper_part_rec;
    l_resp_code                     com_api_type_pkg.t_dict_value;
    l_card_number                   com_api_type_pkg.t_card_number;
    l_iss_inst_id                   com_api_type_pkg.t_inst_id;
    l_iss_network_id                com_api_type_pkg.t_tiny_id;
    l_card_inst_id                  com_api_type_pkg.t_inst_id;
    l_card_network_id               com_api_type_pkg.t_tiny_id;
    l_card_type_id                  com_api_type_pkg.t_tiny_id;
    l_country_code                  com_api_type_pkg.t_country_code;
    l_bin_currency                  com_api_type_pkg.t_curr_code;
    l_sttl_currency                 com_api_type_pkg.t_curr_code;

    l_event_type                    com_api_type_pkg.t_dict_value;
    l_rate_type                     com_api_type_pkg.t_dict_value;
begin
    l_algo_id      := opr_api_shared_data_pkg.get_param_num('ALGORITHM');
    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type   := opr_api_shared_data_pkg.get_param_char(
                          i_name          => 'PARTY_TYPE'
                        , i_mask_error    => com_api_const_pkg.TRUE
                        , i_error_value   => com_api_const_pkg.PARTICIPANT_ISSUER
                      );
    l_party_type := nvl(l_party_type, com_api_const_pkg.PARTICIPANT_ISSUER);

    l_resp_code  := opr_api_shared_data_pkg.get_param_char('RESP_CODE');

    l_rate_type  := opr_api_shared_data_pkg.get_param_char(
        i_name       => 'RATE_TYPE'
      , i_mask_error => com_api_const_pkg.TRUE
    );

    l_event_type := opr_api_shared_data_pkg.get_param_char(
        i_name       => 'EVENT_TYPE'
      , i_mask_error => com_api_const_pkg.TRUE
    );

    l_participant_rec := opr_api_shared_data_pkg.get_participant(i_participant_type => l_party_type);

    if l_participant_rec.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT then
        select_operation_account;
    else
        l_object_id :=
            opr_api_shared_data_pkg.get_object_id(
                i_entity_type     => l_entity_type
              , i_account_name    => l_account_name
              , i_party_type      => l_party_type
              , o_account_number  => l_account_number
            );

        l_oper_id := opr_api_shared_data_pkg.get_operation().id;

        l_iso_type := opr_api_shared_data_pkg.get_participant(l_party_type).account_type;
        if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
            l_iso_type := nvl(opr_api_shared_data_pkg.get_participant(l_party_type).account_type, 'ACCT0000');
        end if;

        l_card_number := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).card_number;
        if l_card_number is not null then  -- if PARTICIPANT_ISSUER is used
            iss_api_bin_pkg.get_bin_info(
                i_card_number      => l_card_number
              , o_iss_inst_id      => l_iss_inst_id
              , o_iss_network_id   => l_iss_network_id
              , o_card_inst_id     => l_card_inst_id
              , o_card_network_id  => l_card_network_id
              , o_card_type        => l_card_type_id
              , o_card_country     => l_country_code
              , o_bin_currency     => l_bin_currency
              , o_sttl_currency    => l_sttl_currency
            );
        end if;

        begin
            acc_api_selection_pkg.get_account(
                o_account_id              => l_account.account_id
              , o_account_number          => l_account.account_number
              , o_inst_id                 => l_account.inst_id
              , o_agent_id                => l_account.agent_id
              , o_currency                => l_account.currency
              , o_account_type            => l_account.account_type
              , o_contract_id             => l_account.contract_id
              , o_customer_id             => l_account.customer_id
              , o_scheme_id               => l_account.scheme_id
              , o_split_hash              => l_account.split_hash
              , i_selection_id            => l_algo_id
              , i_entity_type             => l_entity_type
              , i_object_id               => l_object_id
              , i_account_number          => l_account_number
              , i_oper_type               => opr_api_shared_data_pkg.get_operation().oper_type
              , i_iso_type                => l_iso_type
              , i_oper_currency           => opr_api_shared_data_pkg.get_operation().oper_currency
              , i_sttl_currency           => opr_api_shared_data_pkg.get_operation().sttl_currency
              , i_bin_currency            => l_bin_currency
              , i_party_type              => l_party_type
              , i_msg_type                => opr_api_shared_data_pkg.get_operation().msg_type
              , i_is_forced_processing    => opr_api_shared_data_pkg.get_operation().forced_processing
              , i_terminal_type           => opr_api_shared_data_pkg.get_operation().terminal_type
              , i_oper_amount             => opr_api_shared_data_pkg.get_operation().oper_amount
              , i_rate_type               => l_rate_type
              , i_params                  => opr_api_shared_data_pkg.g_params
            );
        exception
            when others then
                trc_log_pkg.debug(
                    i_text         => 'Error when selecting account [#1][#2][#3]'
                  , i_env_param1   => sqlcode
                  , i_env_param2   => com_api_error_pkg.get_last_error
                  , i_env_param3   => sqlerrm
                  , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id    => l_oper_id
                );

                if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
                    if com_api_error_pkg.get_last_error in ('ACCOUNT_BY_ALGORITHM_NOT_FOUND'
                                                          , 'ACC_SELECTION_ALGORITHM_NOT_DEFINED'
                                                          , 'ILLEGAL_ACCOUNT_ALGORITHM_STEP')
                    then

                        if l_event_type is not null then
                            evt_api_event_pkg.register_event_autonomous(
                                i_event_type        => l_event_type
                              , i_eff_date          => opr_api_shared_data_pkg.get_operation().host_date
                              , i_entity_type       => l_entity_type
                              , i_object_id         => l_object_id
                              , i_inst_id           => l_participant_rec.inst_id
                              , i_split_hash        => com_api_hash_pkg.get_split_hash(l_entity_type, l_object_id)
                              , i_param_tab         => opr_api_shared_data_pkg.g_params
                            );
                        end if;

                        opr_api_shared_data_pkg.rollback_process(
                            i_id       => l_oper_id
                          , i_status   => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                          , i_reason   => l_resp_code
                        );
                    else
                        raise;
                    end if;
                else
                    raise;
                end if;
        end;

        opr_api_shared_data_pkg.set_account(
            i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
          , i_account_rec       => l_account
        );

        update opr_participant
           set account_id              = l_account.account_id
             , account_number          = l_account.account_number
         where oper_id                 = l_oper_id
           and participant_type        = l_party_type;

        l_participant_rec.account_number := l_account.account_number;
        l_participant_rec.account_id     := l_account.account_id;
        opr_api_shared_data_pkg.set_participant(l_participant_rec);

        rul_api_shared_data_pkg.load_account_params(
            i_account_id    => l_account.account_id
          , io_params       => opr_api_shared_data_pkg.g_params
          , i_usage         => com_api_const_pkg.FLEXIBLE_FIELD_PROC_OPER
        );
    end if;
end select_object_account;

procedure select_auth_account
is
    l_account                       acc_api_type_pkg.t_account_rec;
    l_macros_type                   com_api_type_pkg.t_tiny_id;
    l_operation                     opr_api_type_pkg.t_oper_rec;
begin
    l_macros_type := opr_api_shared_data_pkg.get_param_char('MACROS_TYPE');
    l_operation   := opr_api_shared_data_pkg.get_operation;

    trc_log_pkg.debug(
        i_text            => 'Going to find authorization account by macros [#1][#2]'
      , i_env_param1      => l_operation.id
      , i_env_param2      => l_macros_type
      , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id       => l_operation.id
    );

    begin
        select a.id
             , a.account_number
             , a.currency
             , a.account_type
             , a.inst_id
             , a.agent_id
             , a.contract_id
             , a.customer_id
             , a.split_hash
          into l_account.account_id
             , l_account.account_number
             , l_account.currency
             , l_account.account_type
             , l_account.inst_id
             , l_account.agent_id
             , l_account.contract_id
             , l_account.customer_id
             , l_account.split_hash
          from acc_macros m
             , acc_account a
         where m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and m.object_id = l_operation.id
           and m.macros_type_id = l_macros_type
           and m.account_id = a.id;
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error occured [#1][#2][#3]'
              , i_env_param1  => l_operation.id
              , i_env_param2  => l_macros_type
              , i_env_param3  => sqlerrm
            );
    end;

    opr_api_shared_data_pkg.set_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , i_account_rec       => l_account
    );
end select_auth_account;

procedure select_operation_account
is
    l_party_type                    com_api_type_pkg.t_dict_value;
    l_participant                   opr_api_type_pkg.t_oper_part_rec;
    l_account                       acc_api_type_pkg.t_account_rec;
begin
    l_party_type :=
        nvl(
            opr_api_shared_data_pkg.get_param_char(
                i_name        => 'PARTY_TYPE'
              , i_mask_error  => com_api_const_pkg.TRUE
              , i_error_value => com_api_const_pkg.PARTICIPANT_ISSUER
            )
          , com_api_const_pkg.PARTICIPANT_ISSUER
        );

    case
        when l_party_type in (com_api_const_pkg.PARTICIPANT_ISSUER
                            , com_api_const_pkg.PARTICIPANT_DEST
                            , com_api_const_pkg.PARTICIPANT_ACQUIRER
                            , com_api_const_pkg.PARTICIPANT_LOYALTY
                            , com_api_const_pkg.PARTICIPANT_INSTITUTION)
        then
            l_participant := opr_api_shared_data_pkg.get_participant(l_party_type);
        else
            com_api_error_pkg.raise_error(
                i_error       => 'AUTH_ENTITY_NOT_AVAILABLE'
              , i_env_param1  => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_env_param2  => null
              , i_env_param3  => l_party_type
            );
    end case;

    trc_log_pkg.debug(
        i_text         => 'Going to find account [#1][#2]'
      , i_env_param1   => l_participant.account_number
      , i_env_param2   => l_participant.inst_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    begin
        l_account := acc_api_account_pkg.get_account(
                         i_account_id     => l_participant.account_id
                       , i_account_number => l_participant.account_number
                       , i_inst_id        => l_participant.inst_id
                       , i_mask_error     => com_api_const_pkg.FALSE
                     );
    exception
        when com_api_error_pkg.e_application_error then
            opr_api_shared_data_pkg.rollback_process(
                i_id      => opr_api_shared_data_pkg.get_operation().id
              , i_status  => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
              , i_reason  => aup_api_const_pkg.RESP_CODE_CANT_GET_ACCOUNT
            );
    end;

    if acc_api_selection_pkg.check_account_restricted(
           i_oper_type             => opr_api_shared_data_pkg.get_operation().oper_type
         , i_inst_id               => l_account.inst_id
         , i_account_type          => l_account.account_type
         , i_account_status        => l_account.status
         , i_party_type            => l_party_type
         , i_msg_type              => opr_api_shared_data_pkg.get_operation().msg_type
         , i_is_forced_processing  => opr_api_shared_data_pkg.get_operation().forced_processing
       ) = com_api_const_pkg.TRUE
    then
        opr_api_shared_data_pkg.rollback_process(
            i_id     => opr_api_shared_data_pkg.get_operation().id
          , i_status => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason => aup_api_const_pkg.RESP_CODE_ACCOUNT_RESTRICTED
        );
    end if;

    opr_api_shared_data_pkg.set_account(
        i_name         => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , i_account_rec  => l_account
    );
end select_operation_account;

procedure select_merchant_account
is
    l_account                   acc_api_type_pkg.t_account_rec;
    l_oper_id                   com_api_type_pkg.t_long_id;
    l_acq_participant           opr_api_type_pkg.t_oper_part_rec;
begin
    acq_api_account_scheme_pkg.get_acq_account(
        i_merchant_id    => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ACQUIRER).merchant_id
      , i_terminal_id    => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ACQUIRER).terminal_id
      , i_currency       => opr_api_shared_data_pkg.get_operation().oper_currency
      , i_oper_type      => opr_api_shared_data_pkg.get_operation().oper_type
      , i_reason         => opr_api_shared_data_pkg.get_operation().oper_reason
      , i_sttl_type      => opr_api_shared_data_pkg.get_operation().sttl_type
      , i_terminal_type  => opr_api_shared_data_pkg.get_operation().terminal_type
      , i_oper_sign      => 1
      , i_scheme_id      => opr_api_shared_data_pkg.get_param_char('ACCOUNT_SCHEME_ID')
      , o_account        => l_account
    );

    opr_api_shared_data_pkg.set_account(
        i_name           => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , i_account_rec    => l_account
    );

    l_oper_id := opr_api_shared_data_pkg.get_operation().id;

    update opr_participant
       set account_id       = l_account.account_id
         , account_number   = l_account.account_number
         , customer_id      = l_account.customer_id
         , account_type     = l_account.account_type
     where oper_id          = l_oper_id
       and participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER;

    l_acq_participant := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ACQUIRER);
    l_acq_participant.account_number := l_account.account_number;
    l_acq_participant.account_id     := l_account.account_id;
    opr_api_shared_data_pkg.set_participant(l_acq_participant);
end;

procedure set_account_balance_amount is
    l_amount_name                   com_api_type_pkg.t_dict_value;
    l_result_amount_name            com_api_type_pkg.t_dict_value;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_amount_algorithm              com_api_type_pkg.t_dict_value;
    l_balance_type                  com_api_type_pkg.t_dict_value;
    l_macros_type                   com_api_type_pkg.t_tiny_id;
    l_balance_amount                com_api_type_pkg.t_amount_rec;
    l_macros_id                     com_api_type_pkg.t_long_id;
    l_bunch_id                      com_api_type_pkg.t_long_id;
    l_balance_impact                com_api_type_pkg.t_sign;

    l_param_tab                     com_api_type_pkg.t_param_tab;
begin
    opr_api_shared_data_pkg.get_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );

    l_amount_algorithm := opr_api_shared_data_pkg.get_param_char(
        i_name              => 'OPER_AMOUNT_ALGORITHM'
        , i_mask_error      => com_api_const_pkg.TRUE
        , i_error_value     => nvl(opr_api_shared_data_pkg.get_operation().oper_amount_algorithm, opr_api_const_pkg.OPER_AMOUNT_ALG_REQUESTED)
    );
    l_amount_algorithm := nvl(l_amount_algorithm, nvl(opr_api_shared_data_pkg.get_operation().oper_amount_algorithm, opr_api_const_pkg.OPER_AMOUNT_ALG_REQUESTED));

    l_balance_type := opr_api_shared_data_pkg.get_param_char(
        i_name              => 'BALANCE_TYPE'
        , i_mask_error      => com_api_const_pkg.TRUE
        , i_error_value     => null
    );
    if l_balance_type is null then
        if substr(opr_api_shared_data_pkg.get_operation().oper_reason, 1, 4) = acc_api_const_pkg.BALANCE_TYPE_KEY then
            l_balance_type := opr_api_shared_data_pkg.get_operation().oper_reason;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'WRONG_BALANCE_TYPE_SPECIFIED'
                , i_env_param1  => opr_api_shared_data_pkg.get_operation().oper_type
                , i_env_param2  => opr_api_shared_data_pkg.get_operation().oper_reason
            );
        end if;
    end if;

    l_macros_type := opr_api_shared_data_pkg.get_param_num (
        i_name                  => 'MACROS_TYPE'
        , i_mask_error          => com_api_const_pkg.TRUE
        , i_error_value         => null
    );
    if l_macros_type is null then
        l_macros_type := acc_api_balance_pkg.get_update_macros_type (
            i_inst_id           => l_account.inst_id
            , i_account_type    => l_account.account_type
            , i_balance_type    => l_balance_type
            , i_raise_error     => com_api_const_pkg.TRUE
        );
    end if;

    l_balance_impact := opr_api_shared_data_pkg.get_param_num (
        i_name                  => 'BALANCE_IMPACT'
        , i_mask_error          => com_api_const_pkg.TRUE
        , i_error_value         => com_api_type_pkg.CREDIT
    );
    l_balance_impact := nvl(l_balance_impact, com_api_type_pkg.CREDIT);

    l_amount_name := opr_api_shared_data_pkg.get_param_char(
        i_name              => 'AMOUNT_NAME'
        , i_mask_error      => com_api_const_pkg.TRUE
        , i_error_value     => com_api_const_pkg.AMOUNT_PURPOSE_OPER_REQUEST
    );
    l_amount_name := nvl(l_amount_name, com_api_const_pkg.AMOUNT_PURPOSE_OPER_REQUEST);

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_amount_name
        , o_amount    => l_amount.amount
        , o_currency  => l_amount.currency
    );

    if l_amount_algorithm = opr_api_const_pkg.OPER_AMOUNT_ALG_AVAL then
        l_balance_amount := acc_api_balance_pkg.get_balance_amount (
            i_account_id        => l_account.account_id
            , i_balance_type    => l_balance_type
            , i_mask_error      => com_api_const_pkg.FALSE
            , i_lock_balance    => com_api_const_pkg.TRUE
        );

        if l_balance_amount.currency = l_amount.currency then
            l_amount.amount := l_amount.amount - l_balance_amount.amount;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'BALANCE_OF_DIFFERENT_CURRENCY'
                , i_env_param1  => l_account.account_id
                , i_env_param2  => l_balance_type
                , i_env_param3  => l_balance_amount.currency
                , i_env_param4  => l_amount.currency
            );
        end if;
    end if;

    l_result_amount_name := opr_api_shared_data_pkg.get_param_char(
        i_name              => 'RESULT_AMOUNT_NAME'
        , i_mask_error      => com_api_const_pkg.TRUE
        , i_error_value     => com_api_const_pkg.AMOUNT_PURPOSE_OPER_ACTUAL
    );
    l_result_amount_name := nvl(l_result_amount_name, com_api_const_pkg.AMOUNT_PURPOSE_OPER_ACTUAL);

    rul_api_param_pkg.set_param (
        i_name       => 'CARD_TYPE_ID'
        , io_params  => l_param_tab
        , i_value    => opr_api_shared_data_pkg.get_participant(
                        i_participant_type    => com_api_const_pkg.PARTICIPANT_ISSUER
                        ).card_type_id
    );

    acc_api_entry_pkg.put_macros (
        o_macros_id         => l_macros_id
        , o_bunch_id        => l_bunch_id
        , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_object_id       => opr_api_shared_data_pkg.get_operation().id
        , i_macros_type_id  => l_macros_type
        , i_amount          => l_balance_impact * l_amount.amount
        , i_currency        => l_amount.currency
        , i_account_type    => l_account.account_type
        , i_account_id      => l_account.account_id
        , i_posting_date    => get_sysdate
        , i_amount_purpose  => l_result_amount_name
        , i_fee_id          => null
        , i_fee_tier_id     => null
        , i_fee_mod_id      => null
        , i_details_data    => null
        , i_param_tab       => l_param_tab
    );

    opr_api_shared_data_pkg.set_amount(
        i_name        => l_result_amount_name
        , i_amount    => l_amount.amount
        , i_currency  => l_amount.currency
    );
end;

procedure add_amount is

    l_first_amount_name             com_api_type_pkg.t_name;
    l_second_amount_name            com_api_type_pkg.t_name;
    l_first_amount                  com_api_type_pkg.t_amount_rec;
    l_second_amount                 com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_result_amount                 com_api_type_pkg.t_amount_rec;

begin
    l_first_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME_#1');
    l_second_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME_#2');
    l_result_amount_name := opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_first_amount_name
        , o_amount    => l_first_amount.amount
        , o_currency  => l_first_amount.currency
    );

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_second_amount_name
        , o_amount    => l_second_amount.amount
        , o_currency  => l_second_amount.currency
    );

    if l_first_amount.currency = l_second_amount.currency or l_second_amount.amount = 0 then
        l_result_amount.currency := l_first_amount.currency;
        l_result_amount.amount := l_first_amount.amount + l_second_amount.amount;

        opr_api_shared_data_pkg.set_amount(
            i_name        => l_result_amount_name
            , i_amount    => l_result_amount.amount
            , i_currency  => l_result_amount.currency
        );
    else
        com_api_error_pkg.raise_error(
            i_error         => 'ATTEMPT_TO_ADD_DIFFERENT_CURRENCY'
            , i_env_param1  => l_first_amount.currency
            , i_env_param2  => l_second_amount.currency
        );
    end if;
end;

procedure subtract_amount is

    l_first_amount_name             com_api_type_pkg.t_name;
    l_second_amount_name            com_api_type_pkg.t_name;
    l_first_amount                  com_api_type_pkg.t_amount_rec;
    l_second_amount                 com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_result_amount                 com_api_type_pkg.t_amount_rec;

begin
    l_first_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME_#1');
    l_second_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME_#2');
    l_result_amount_name := opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_first_amount_name
        , o_amount    => l_first_amount.amount
        , o_currency  => l_first_amount.currency
    );

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_second_amount_name
        , o_amount    => l_second_amount.amount
        , o_currency  => l_second_amount.currency
    );

    if l_first_amount.currency = l_second_amount.currency then
        l_result_amount.currency := l_first_amount.currency;
        l_result_amount.amount := l_first_amount.amount - l_second_amount.amount;

        opr_api_shared_data_pkg.set_amount(
            i_name        => l_result_amount_name
            , i_amount    => l_result_amount.amount
            , i_currency  => l_result_amount.currency
        );
    else
        com_api_error_pkg.raise_error(
            i_error         => 'ATTEMPT_TO_SUBTRACT_DIFFERENT_CURRENCY'
            , i_env_param1  => l_first_amount.currency
            , i_env_param2  => l_second_amount.currency
        );
    end if;
end;

procedure assign_amount is

    l_source_amount_name            com_api_type_pkg.t_name;
    l_source_amount                 com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;

begin
    l_source_amount_name := opr_api_shared_data_pkg.get_param_char('SOURCE_AMOUNT_NAME');
    l_result_amount_name := opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_source_amount_name
        , o_amount    => l_source_amount.amount
        , o_currency  => l_source_amount.currency
    );

    opr_api_shared_data_pkg.set_amount(
        i_name        => l_result_amount_name
        , i_amount    => l_source_amount.amount
        , i_currency  => l_source_amount.currency
    );
end;

procedure select_amount_to_post_account is

    l_account                       acc_api_type_pkg.t_account_rec;
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    l_rate_type                     com_api_type_pkg.t_dict_value;
    l_result_rate_type              com_api_type_pkg.t_dict_value;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
    l_conversion_type               com_api_type_pkg.t_dict_value;

begin
    opr_api_shared_data_pkg.get_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );

    l_amount_name := opr_api_shared_data_pkg.get_param_char(
        i_name              => 'PRIMARY_ASSIGN_AMOUNT'
        , i_mask_error      => com_api_const_pkg.TRUE
        , i_error_value     => null
    );

    if l_amount_name is not null then
        opr_api_shared_data_pkg.get_amount(
            i_name              => l_amount_name
            , o_amount          => l_amount.amount
            , o_currency        => l_amount.currency
            , i_mask_error      => com_api_const_pkg.TRUE
            , i_error_amount    => null
            , i_error_currency  => com_api_const_pkg.UNDEFINED_CURRENCY
        );

        if l_amount.currency = l_account.currency then
            l_result_amount := l_amount;
        end if;
    end if;

    if l_result_amount.amount is null then
        l_amount_name := opr_api_shared_data_pkg.get_param_char(
            i_name              => 'SECONDARY_ASSIGN_AMOUNT'
            , i_mask_error      => com_api_const_pkg.TRUE
            , i_error_value     => null
        );

        opr_api_shared_data_pkg.set_param(
            i_name  => 'SECONDARY_ASSIGN_AMOUNT'
          , i_value => to_char(null)
        );

        if l_amount_name is not null then
            opr_api_shared_data_pkg.get_amount(
                i_name              => l_amount_name
                , o_amount          => l_amount.amount
                , o_currency        => l_amount.currency
                , i_mask_error      => com_api_const_pkg.TRUE
                , i_error_amount    => null
                , i_error_currency  => com_api_const_pkg.UNDEFINED_CURRENCY
            );

            if l_amount.currency = l_account.currency then
                l_result_amount := l_amount;
            end if;
        end if;
    end if;

    l_rate_type := opr_api_shared_data_pkg.get_param_char(
        i_name              => 'RATE_TYPE'
        , i_mask_error      => com_api_const_pkg.FALSE
    );

    l_result_rate_type := opr_api_shared_data_pkg.get_param_char(
        i_name              => 'RESULT_RATE_TYPE'
        , i_mask_error      => com_api_const_pkg.TRUE
    );

    if l_result_rate_type is not null and l_rate_type is null then
        l_rate_type := l_result_rate_type;

        trc_log_pkg.debug(
            i_text          => 'RATE_TYPE value was changed to RESULT_RATE_TYPE param value[#1]'
          , i_env_param1    => l_rate_type
        );
    end if;

    l_eff_date_name := opr_api_shared_data_pkg.get_param_char('EFFECTIVE_DATE');

    if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_eff_date := com_api_sttl_day_pkg.get_open_sttl_date(
            i_inst_id       => l_account.inst_id
        );
    else
        opr_api_shared_data_pkg.get_date(
            i_name          => l_eff_date_name
            , o_date        => l_eff_date
        );
    end if;

    l_conversion_type := opr_api_shared_data_pkg.get_param_char(
        i_name              => 'CONVERSION_TYPE'
        , i_mask_error      => com_api_const_pkg.TRUE
    );

    if l_result_amount.amount is null then
        l_amount_name := opr_api_shared_data_pkg.get_param_char(
            i_name              => 'PRIMARY_CONVERT_AMOUNT'
            , i_mask_error      => com_api_const_pkg.TRUE
            , i_error_value     => null
        );

        if l_amount_name is not null then
            opr_api_shared_data_pkg.get_amount(
                i_name              => l_amount_name
                , o_amount          => l_amount.amount
                , o_currency        => l_amount.currency
                , i_mask_error      => com_api_const_pkg.TRUE
                , i_error_amount    => null
                , i_error_currency  => com_api_const_pkg.UNDEFINED_CURRENCY
            );

            if nvl(l_amount.currency, com_api_const_pkg.UNDEFINED_CURRENCY) not in (
                   com_api_const_pkg.UNDEFINED_CURRENCY
                 , com_api_const_pkg.ZERO_CURRENCY
               )
            then
                l_result_amount.currency := l_account.currency;

                l_result_amount.amount := com_api_rate_pkg.convert_amount (
                    i_src_amount            => l_amount.amount
                    , i_src_currency        => l_amount.currency
                    , i_dst_currency        => l_result_amount.currency
                    , i_rate_type           => l_rate_type
                    , i_inst_id             => l_account.inst_id
                    , i_eff_date            => l_eff_date
                    , i_mask_exception      => com_api_const_pkg.TRUE
                    , i_conversion_type     => l_conversion_type
                    , o_conversion_rate     => l_result_amount.conversion_rate
                );
            end if;
        end if;
    end if;

    if l_result_amount.amount is null then
        l_amount_name := opr_api_shared_data_pkg.get_param_char(
            i_name              => 'SECONDARY_CONVERT_AMOUNT'
            , i_mask_error      => com_api_const_pkg.TRUE
            , i_error_value     => null
        );

        if l_amount_name is not null then
            opr_api_shared_data_pkg.get_amount(
                i_name              => l_amount_name
                , o_amount          => l_amount.amount
                , o_currency        => l_amount.currency
                , i_mask_error      => com_api_const_pkg.TRUE
                , i_error_amount    => null
                , i_error_currency  => com_api_const_pkg.UNDEFINED_CURRENCY
            );

            if nvl(l_amount.currency, com_api_const_pkg.UNDEFINED_CURRENCY) not in (
                   com_api_const_pkg.UNDEFINED_CURRENCY
                 , com_api_const_pkg.ZERO_CURRENCY
               )
            then
                l_result_amount.currency := l_account.currency;

                l_result_amount.amount := com_api_rate_pkg.convert_amount (
                    i_src_amount            => l_amount.amount
                    , i_src_currency        => l_amount.currency
                    , i_dst_currency        => l_result_amount.currency
                    , i_rate_type           => l_rate_type
                    , i_inst_id             => l_account.inst_id
                    , i_eff_date            => l_eff_date
                    , i_mask_exception      => com_api_const_pkg.TRUE
                    , i_conversion_type     => l_conversion_type
                    , o_conversion_rate     => l_result_amount.conversion_rate
                );
            end if;
        end if;
    end if;

    if l_result_amount.amount is not null then
        opr_api_shared_data_pkg.set_amount(
            i_name                      => opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME')
            , i_amount                  => l_result_amount.amount
            , i_currency                => l_result_amount.currency
            , i_conversion_rate         => l_result_amount.conversion_rate
            , i_rate_type               => l_rate_type
        );
    else
        opr_api_shared_data_pkg.rollback_process (
            i_id     => opr_api_shared_data_pkg.get_operation().id
          , i_status => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason => aup_api_const_pkg.RESP_CODE_CANT_GET_AMOUNT
        );
    end if;
end;

/*
 * Procedure converts an amount to another currency.
 * AMOUNT_NAME         defines an amount record that contains source amount value and currency
 * CURRENCY            1st priority destination currency
 * ACCOUNT_NAME        defines an account that is used to define institution
                       and currency (2nd priority, if CURRENCY is not defined)
 * BASE_AMOUNT_NAME    3rd priority currency (if CURRENCY and ACCOUNT_NAME aren't defined),
                       amount value is not used
 * PARTY_TYPE          is used to define institution if an account is not defined by ACCOUNT_NAME
 * RESULT_AMOUNT_NAME  is used as outgoing parameter to store destination (converted) amount
 */
procedure convert_amount is

    l_account_name                  com_api_type_pkg.t_name;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_base_amount_name              com_api_type_pkg.t_name;
    l_base_amount                   com_api_type_pkg.t_amount_rec;
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    l_rate_type                     com_api_type_pkg.t_dict_value;
    l_result_rate_type              com_api_type_pkg.t_dict_value;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
    l_currency                      com_api_type_pkg.t_curr_code;
    l_conversion_type               com_api_type_pkg.t_dict_value;
    l_party_type                    com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;

begin
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME', com_api_const_pkg.TRUE);

    if l_account_name is not null then
        opr_api_shared_data_pkg.get_account(
            i_name              => l_account_name
          , o_account_rec       => l_account
        );

        l_inst_id := l_account.inst_id;
    else
        l_party_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE', com_api_const_pkg.TRUE);

        if l_party_type is not null then
            l_inst_id := opr_api_shared_data_pkg.get_participant(i_participant_type => l_party_type).inst_id;
        end if;
    end if;

    l_currency :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'CURRENCY'
            , i_mask_error  => com_api_const_pkg.TRUE
        );

    l_base_amount_name := opr_api_shared_data_pkg.get_param_char('BASE_AMOUNT_NAME');

    if l_base_amount_name is not null then
        opr_api_shared_data_pkg.get_amount(
            i_name          => l_base_amount_name
            , o_amount      => l_base_amount.amount
            , o_currency    => l_base_amount.currency
        );
    end if;

    l_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME');

    if l_amount_name is not null then
        opr_api_shared_data_pkg.get_amount(
            i_name          => l_amount_name
            , o_amount      => l_amount.amount
            , o_currency    => l_amount.currency
        );
    end if;

    l_result_amount.currency := coalesce(l_currency, l_account.currency, l_base_amount.currency);

    if l_amount.currency = l_result_amount.currency then
        l_result_amount := l_amount;
    end if;

    if nvl(l_result_amount.currency, com_api_const_pkg.UNDEFINED_CURRENCY) not in (
           com_api_const_pkg.UNDEFINED_CURRENCY
         , com_api_const_pkg.ZERO_CURRENCY
       )
       and l_result_amount.amount is null
    then

        l_rate_type := opr_api_shared_data_pkg.get_param_char(
            i_name              => 'RATE_TYPE'
            , i_mask_error      => com_api_const_pkg.FALSE
        );

        l_result_rate_type := opr_api_shared_data_pkg.get_param_char(
            i_name              => 'RESULT_RATE_TYPE'
            , i_mask_error      => com_api_const_pkg.TRUE
        );

        if l_result_rate_type is not null and l_rate_type is null then
            l_rate_type := l_result_rate_type;

            trc_log_pkg.debug(
                i_text          => 'RATE_TYPE value was changed to RESULT_RATE_TYPE param value[#1]'
              , i_env_param1    => l_rate_type
            );
        end if;

        l_conversion_type := opr_api_shared_data_pkg.get_param_char(
            i_name              => 'CONVERSION_TYPE'
            , i_mask_error      => com_api_const_pkg.TRUE
        );

        l_eff_date_name :=
            opr_api_shared_data_pkg.get_param_char(
                i_name              => 'EFFECTIVE_DATE'
              , i_mask_error        => com_api_const_pkg.TRUE
              , i_error_value       => com_api_const_pkg.DATE_PURPOSE_PROCESSING
            );

        trc_log_pkg.debug('l_eff_date_name = ['||l_eff_date_name||']');

        if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
            l_eff_date := com_api_sttl_day_pkg.get_open_sttl_date(
                i_inst_id       => l_inst_id
            );
        elsif l_eff_date_name is not null then
            opr_api_shared_data_pkg.get_date(
                i_name          => l_eff_date_name
              , o_date          => l_eff_date
              , i_mask_error    => com_api_const_pkg.TRUE
              , i_error_value   => com_api_sttl_day_pkg.get_sysdate
            );
        else
            l_eff_date := com_api_sttl_day_pkg.get_sysdate;
        end if;

        l_result_amount.amount := round(
            com_api_rate_pkg.convert_amount (
                i_src_amount            => l_amount.amount
                , i_src_currency        => l_amount.currency
                , i_dst_currency        => l_result_amount.currency
                , i_rate_type           => l_rate_type
                , i_inst_id             => l_inst_id
                , i_eff_date            => l_eff_date
                , i_mask_exception      => com_api_const_pkg.TRUE
                , i_conversion_type     => l_conversion_type
                , o_conversion_rate     => l_result_amount.conversion_rate
            ));
    end if;

    if l_result_amount.amount is not null then
        opr_api_shared_data_pkg.set_amount(
            i_name                      => opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME')
            , i_amount                  => l_result_amount.amount
            , i_currency                => l_result_amount.currency
            , i_conversion_rate         => l_result_amount.conversion_rate
            , i_rate_type               => l_rate_type
        );
    else
        opr_api_shared_data_pkg.rollback_process (
            i_id         => opr_api_shared_data_pkg.get_operation().id
          , i_status     => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason => aup_api_const_pkg.RESP_CODE_CANT_GET_AMOUNT
        );
    end if;
end;

procedure set_amount is

    l_account                       acc_api_type_pkg.t_account_rec;
    l_amount                        com_api_type_pkg.t_money;
    l_currency                      com_api_type_pkg.t_curr_code;

begin
    opr_api_shared_data_pkg.get_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );
    l_currency := opr_api_shared_data_pkg.get_param_char(
        i_name          => 'CURRENCY'
        , i_mask_error  => com_api_const_pkg.TRUE
    );


    l_amount := opr_api_shared_data_pkg.get_param_num('AMOUNT');

    opr_api_shared_data_pkg.set_amount(
        i_name        => opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME')
        , i_amount    => l_amount
        , i_currency  => nvl(l_currency, l_account.currency)
    );
end;


procedure unhold_auth is
    l_reason                        com_api_type_pkg.t_name;
    l_selector                      com_api_type_pkg.t_dict_value;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_resp                          com_api_type_pkg.t_dict_value;
    l_rollback_limits               com_api_type_pkg.t_boolean;
    l_total_amount                  com_api_type_pkg.t_money;
    l_external_auth_id              com_api_type_pkg.t_attr_name;
begin
    l_reason := opr_api_shared_data_pkg.get_param_char('STATUS_REASON');

    l_selector := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'OPERATION_SELECTOR'
        , i_mask_error   => com_api_const_pkg.TRUE
        , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
    );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_rollback_limits := opr_api_shared_data_pkg.get_param_num (
        i_name          => 'ROLLBACK_LIMITS'
        , i_mask_error  => com_api_const_pkg.TRUE
    );
    l_rollback_limits := nvl(l_rollback_limits, com_api_const_pkg.TRUE);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
        i_selector => l_selector
    );

    begin
        select o.total_amount
             , a.external_auth_id
          into l_total_amount
             , l_external_auth_id
          from opr_operation o
             , aut_auth a
         where o.id    = l_oper_id
           and a.id(+) = o.id;
    exception
        when no_data_found then
            l_total_amount     := null;
            l_external_auth_id := null;
    end;

    if l_total_amount is not null then
        for a in (
                  select a.id
                    from aut_auth a
                   where a.trace_number    = l_external_auth_id
                     and a.is_incremental  = com_api_const_pkg.TRUE
                     and a.id             != l_oper_id
        ) loop
            begin
                aut_api_process_pkg.unhold (
                    i_id              => a.id
                  , i_reason          => nvl(l_reason, aut_api_const_pkg.AUTH_REASON_UNHOLD_PRESENT)
                  , i_rollback_limits => l_rollback_limits
                );
            exception
                when others then
                    if (
                        com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
                        or com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
                    ) then
                        case com_api_error_pkg.get_last_error
                           when 'AUTH_ALREADY_UNHOLDED' then l_resp := null;
                           when 'AUTH_CANT_BE_UNHOLDED' then l_resp := aup_api_const_pkg.RESP_CODE_CANCEL_NOT_ALLOWED;
                           when 'AUTH_NOT_FOUND'        then l_resp := aup_api_const_pkg.RESP_CODE_NO_ORIGINAL_OPER;
                           else raise;
                        end case;

                        if l_resp in (aup_api_const_pkg.RESP_CODE_NO_ORIGINAL_OPER, aup_api_const_pkg.RESP_CODE_CANCEL_NOT_ALLOWED) and
                           l_selector in (opr_api_const_pkg.OPER_SELECTOR_MATCHING, opr_api_const_pkg.OPER_SELECTOR_ORIGINAL)
                        then
                            null;
                        elsif l_resp is not null then
                            opr_api_shared_data_pkg.rollback_process (
                                i_id            => opr_api_shared_data_pkg.get_operation_id(opr_api_const_pkg.OPER_SELECTOR_CURRENT)
                              , i_status        => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                              , i_reason        => l_resp
                            );
                        end if;
                    else
                        raise;
                    end if;
            end;
        end loop;
    end if; 

    begin
        aut_api_process_pkg.unhold (
            i_id              => l_oper_id
          , i_reason          => nvl(l_reason, aut_api_const_pkg.AUTH_REASON_UNHOLD_PRESENT)
          , i_rollback_limits => l_rollback_limits
        );
    exception
        when others then
            if (
                com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
                or com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            ) then
                case com_api_error_pkg.get_last_error
                   when 'AUTH_ALREADY_UNHOLDED' then l_resp := null;
                   when 'AUTH_CANT_BE_UNHOLDED' then l_resp := aup_api_const_pkg.RESP_CODE_CANCEL_NOT_ALLOWED;
                   when 'AUTH_NOT_FOUND'        then l_resp := aup_api_const_pkg.RESP_CODE_NO_ORIGINAL_OPER;
                   else raise;
                end case;

                if l_resp in (aup_api_const_pkg.RESP_CODE_NO_ORIGINAL_OPER, aup_api_const_pkg.RESP_CODE_CANCEL_NOT_ALLOWED) and
                   l_selector in (opr_api_const_pkg.OPER_SELECTOR_MATCHING, opr_api_const_pkg.OPER_SELECTOR_ORIGINAL)
                then
                    null;
                elsif l_resp is not null then
                    opr_api_shared_data_pkg.rollback_process (
                        i_id            => opr_api_shared_data_pkg.get_operation_id(opr_api_const_pkg.OPER_SELECTOR_CURRENT)
                      , i_status        => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                      , i_reason        => l_resp
                    );
                end if;
            else
                raise;
            end if;
    end;
end;

procedure unhold_macros is
    l_macros_type               com_api_type_pkg.t_tiny_id;
begin
    l_macros_type := opr_api_shared_data_pkg.get_param_num('MACROS_TYPE');

    acc_api_entry_pkg.cancel_processing (
        i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id         => opr_api_shared_data_pkg.get_operation().id
      , i_macros_status     => acc_api_const_pkg.MACROS_STATUS_HOLDED
      , i_macros_type       => l_macros_type
    );

    opr_api_shared_data_pkg.set_date (
        i_name              => com_api_const_pkg.DATE_PURPOSE_UNHOLD
      , i_date              => null
    );
end;

procedure unhold_auth_partial
is
    l_reason                        com_api_type_pkg.t_name;
    l_selector                      com_api_type_pkg.t_dict_value;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_original_oper_id              com_api_type_pkg.t_long_id;
    l_resp                          com_api_type_pkg.t_dict_value;
    l_rollback_limits               com_api_type_pkg.t_boolean;
begin
    l_reason := opr_api_shared_data_pkg.get_param_char('STATUS_REASON');

    l_selector := opr_api_shared_data_pkg.get_param_char(
                      i_name         => 'OPERATION_SELECTOR'
                    , i_mask_error   => com_api_const_pkg.TRUE
                    , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                  );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_rollback_limits := opr_api_shared_data_pkg.get_param_num(
                             i_name        => 'ROLLBACK_LIMITS'
                           , i_mask_error  => com_api_const_pkg.TRUE
                         );
    l_rollback_limits := nvl(l_rollback_limits, com_api_const_pkg.TRUE);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id(i_selector => l_selector);

    l_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME');
    opr_api_shared_data_pkg.get_amount(
        i_name        => l_amount_name
      , o_amount      => l_amount.amount
      , o_currency    => l_amount.currency
    );

    if l_selector = opr_api_const_pkg.OPER_SELECTOR_MATCHING then
        l_original_oper_id := opr_api_shared_data_pkg.get_operation_id(
                                  i_selector => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                              );
    end if;

    begin
        aut_api_process_pkg.unhold_partial(
            i_id               => l_oper_id
          , i_reason           => nvl(l_reason, aut_api_const_pkg.AUTH_REASON_UNHOLD_PRESENT)
          , i_rollback_limits  => l_rollback_limits
          , i_amount           => l_amount
          , i_original_oper_id => l_original_oper_id
        );
    exception
        when others then
            if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
               or
               com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            then
                case com_api_error_pkg.get_last_error
                    when 'AUTH_ALREADY_UNHOLDED' then l_resp := null;
                    when 'AUTH_CANT_BE_UNHOLDED' then l_resp := aup_api_const_pkg.RESP_CODE_CANCEL_NOT_ALLOWED;
                    when 'AUTH_NOT_FOUND'        then l_resp := aup_api_const_pkg.RESP_CODE_NO_ORIGINAL_OPER;
                                                 else raise;
                end case;

                if  l_resp = aup_api_const_pkg.RESP_CODE_NO_ORIGINAL_OPER
                    and
                    l_selector in (opr_api_const_pkg.OPER_SELECTOR_MATCHING
                                 , opr_api_const_pkg.OPER_SELECTOR_ORIGINAL)
                then
                    null;
                elsif l_resp is not null then
                    opr_api_shared_data_pkg.rollback_process(
                        i_id            => opr_api_shared_data_pkg.get_operation_id(
                                               i_selector => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                                           )
                      , i_status        => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                      , i_reason        => l_resp
                    );
                end if;
            else
                raise;
            end if;
    end;
end;

procedure insurance_payment is
    l_customer_id                   com_api_type_pkg.t_medium_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_oper_date                     date;
    l_event_date                    date;
    l_order_id                      com_api_type_pkg.t_long_id;

    l_product_id                    com_api_type_pkg.t_short_id;
    l_cycle_id                      com_api_type_pkg.t_short_id;

    l_account_id                    com_api_type_pkg.t_account_id;

    l_purpose_id                    com_api_type_pkg.t_short_id;
    l_account_rec                   acc_api_type_pkg.t_account_rec;
    l_inst_id                       com_api_type_pkg.t_inst_id;
begin
    l_customer_id := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).customer_id;
    l_oper_date := opr_api_shared_data_pkg.get_operation().oper_date;

    -- get service with account
    begin
        select
            o.service_id
            , c.product_id
            , o.object_id
            , c.inst_id
        into
            l_service_id
            , l_product_id
            , l_account_id
            , l_inst_id
        from
            prd_contract_vw c
            , prd_product p
            , prd_service_object o
            , prd_service s
        where
            c.customer_id = l_customer_id
            and c.contract_type = 'CNTPINSR'
            and p.id = c.product_id
            and o.contract_id = c.id
            and o.status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
            and o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            and s.id = o.service_id
            and s.service_type_id = ins_api_const_pkg.INS_COMPANY_STTL_SERVICE_TYPE
            and rownum < 2;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'SERVICE_NOT_FOUND'
            );
    end;

    acc_api_account_pkg.get_account_info (
        i_account_id     => l_account_id
        , o_account_rec  => l_account_rec
    );

    -- calc event date
    l_cycle_id := prd_api_product_pkg.get_cycle_id (
        i_product_id     => l_product_id
        , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
        , i_object_id    => l_account_id
        , i_cycle_type   => lty_api_const_pkg.LOYALTY_EXPIRE_CYCLE_TYPE
        , i_params       => opr_api_shared_data_pkg.g_params
        , i_service_id   => l_service_id
        , i_eff_date     => l_oper_date
        , i_inst_id      => l_inst_id
    );

    fcl_api_cycle_pkg.calc_next_date (
        i_cycle_id      => l_cycle_id
        , i_start_date  => l_oper_date
        , i_forward     => com_api_const_pkg.TRUE
        , o_next_date   => l_event_date
    );

    -- get payment purpose
    l_purpose_id := prd_api_product_pkg.get_attr_value_number (
        i_product_id     => l_product_id
        , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
        , i_object_id    => l_account_id
        , i_attr_name    => 'INS_PAYMENT_PURPOSE'
        , i_params       => opr_api_shared_data_pkg.g_params
        , i_service_id   => l_service_id
        , i_eff_date     => l_oper_date
        , i_inst_id      => l_inst_id
    );

    -- find/create payment order
    begin
        select
            t.id
        into
            l_order_id
        from
            pmo_order_vw t
        where
            t.customer_id = l_customer_id
            and t.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            and t.object_id = l_account_id
            and t.purpose_id = l_purpose_id
            and t.status = pmo_api_const_pkg.PMO_STATUS_PREPARATION
            and t.event_date = l_event_date;
    exception
        when no_data_found then
            pmo_api_order_pkg.add_order (
                o_id                 => l_order_id
              , i_customer_id        => l_customer_id
              , i_entity_type        => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id          => l_account_id
              , i_purpose_id         => 0
              , i_template_id        => null
              , i_amount             => null
              , i_currency           => l_account_rec.currency
              , i_event_date         => l_event_date
              , i_status             => pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
              , i_inst_id            => l_account_rec.inst_id
              , i_attempt_count      => 0
              , i_is_prepared_order  => com_api_const_pkg.FALSE
            );

    end;

    -- link operation
    pmo_api_order_pkg.add_order_detail (
        i_order_id       => l_order_id
        , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );
end;

procedure write_trace is
    l_msg               com_api_type_pkg.t_text;
begin
    l_msg := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'TEXT'
        , i_mask_error   => com_api_const_pkg.TRUE
        , i_error_value  => null
    );

    trc_log_pkg.debug(
        i_text          => nvl(l_msg, 'Event occurred') || ' [#1][#2][#3][#4]'
        , i_env_param1  => opr_api_shared_data_pkg.get_operation().id
        , i_env_param2  => opr_api_shared_data_pkg.get_operation().oper_date
        , i_env_param3  => opr_api_shared_data_pkg.get_operation().oper_amount
        , i_env_param4  => opr_api_shared_data_pkg.get_operation().oper_currency
    );
end;

procedure get_object_account_balance
is
    l_currency                      com_api_type_pkg.t_curr_code;
    l_rate_type                     com_api_type_pkg.t_dict_value;
    l_amount                        com_api_type_pkg.t_money;
    l_amount_name                   com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_dict_value;
begin
    l_rate_type    := opr_api_shared_data_pkg.get_param_char('RATE_TYPE');
    l_currency     := opr_api_shared_data_pkg.get_param_char('CURRENCY');
    l_currency     := nvl(l_currency, opr_api_shared_data_pkg.get_operation().oper_currency);
    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type   := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');

    l_object_id :=
        opr_api_shared_data_pkg.get_object_id(
            i_entity_type   => l_entity_type
          , i_account_name  => l_account_name
          , i_party_type    => l_party_type
        );

    acc_api_balance_pkg.get_object_accounts_balance(
        i_object_id       => l_object_id
      , i_entity_type     => l_entity_type
      , i_currency        => l_currency
      , i_rate_type       => l_rate_type
      , i_conversion_type => null
      , o_available       => l_amount
    );

    l_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name         => 'AMOUNT_NAME'
          , i_mask_error   => com_api_const_pkg.TRUE
          , i_error_value  => com_api_const_pkg.AMOUNT_PURPOSE_ACCOUNT_AVAIL
        );

    opr_api_shared_data_pkg.set_amount(
        i_name      => l_amount_name
      , i_amount    => l_amount
      , i_currency  => l_currency
    );
end;

procedure check_object_account_balance
is
    l_currency                      com_api_type_pkg.t_curr_code;
    l_rate_type                     com_api_type_pkg.t_dict_value;
    l_conversion_type               com_api_type_pkg.t_dict_value;
    l_amount                        com_api_type_pkg.t_money;
    l_amount_name                   com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_party_type                    com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;
begin
    l_rate_type       := opr_api_shared_data_pkg.get_param_char('RATE_TYPE');
    l_currency        := opr_api_shared_data_pkg.get_param_char('CURRENCY');
    l_currency        := nvl(l_currency, opr_api_shared_data_pkg.get_operation().oper_currency);
    l_entity_type     := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name    := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type      := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_conversion_type := opr_api_shared_data_pkg.get_param_char('CONVERSION_TYPE');

    l_object_id :=
        opr_api_shared_data_pkg.get_object_id(
            i_entity_type   => l_entity_type
          , i_account_name  => l_account_name
          , i_party_type    => l_party_type
          , o_inst_id       => l_inst_id
        );

    acc_api_balance_pkg.get_object_accounts_balance(
        i_object_id       => l_object_id
      , i_entity_type     => l_entity_type
      , i_currency        => l_currency
      , i_rate_type       => l_rate_type
      , i_conversion_type => l_conversion_type
      , o_available       => l_amount
    );

    if l_amount < 0 then
        opr_api_shared_data_pkg.rollback_process(
            i_id         => opr_api_shared_data_pkg.get_operation().id
          , i_status     => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason     => opr_api_shared_data_pkg.get_param_char( 'RESP_CODE' )
        );

    else
        l_amount_name :=
            opr_api_shared_data_pkg.get_param_char(
                i_name         => 'AMOUNT_NAME'
              , i_mask_error   => com_api_const_pkg.TRUE
              , i_error_value  => com_api_const_pkg.AMOUNT_PURPOSE_ACCOUNT_AVAIL
            );

        opr_api_shared_data_pkg.set_amount(
            i_name      => l_amount_name
          , i_amount    => l_amount
          , i_currency  => l_currency
        );
    end if;
end check_object_account_balance;

procedure calculate_oper_actual_amount
is
    l_account                       acc_api_type_pkg.t_account_rec;
    l_amount                        com_api_type_pkg.t_money;
    l_oper_amount_algorithm         com_api_type_pkg.t_dict_value;
begin
    l_oper_amount_algorithm := nvl(opr_api_shared_data_pkg.get_operation().oper_amount_algorithm
                                 , opr_api_const_pkg.OPER_AMOUNT_ALG_REQUESTED);

    if l_oper_amount_algorithm = opr_api_const_pkg.OPER_AMOUNT_ALG_AVAL then
        opr_api_shared_data_pkg.get_account(
            i_name        => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
          , o_account_rec => l_account
        );

        get_account_aval(
            i_account_id  => l_account.account_id
          , o_amount      => l_amount
          , i_need_lock   => com_api_const_pkg.TRUE
        );

        opr_api_shared_data_pkg.set_amount(
            i_name        => com_api_const_pkg.AMOUNT_PURPOSE_OPER_ACTUAL
          , i_amount      => l_amount
          , i_currency    => l_account.currency
        );
    end if;
end;

procedure load_customer_data
is
    l_party_type        com_api_type_pkg.t_dict_value;
begin
    l_party_type := opr_api_shared_data_pkg.get_param_char(i_name => 'PARTY_TYPE');

    opr_api_shared_data_pkg.load_customer_params(i_party_type => l_party_type);
end load_customer_data;

procedure generate_document_by_order is
begin
    null;
end generate_document_by_order;

procedure completion_check
is
    l_original_id                   com_api_type_pkg.t_long_id;
    l_reason                        com_api_type_pkg.t_dict_value;
    l_test_mode                     com_api_type_pkg.t_dict_value;
begin
    l_original_id := opr_api_shared_data_pkg.get_operation().original_id;
    l_test_mode := opr_api_shared_data_pkg.get_param_char(
        i_name        => 'ATTR_MISS_TESTMODE'
      , i_mask_error  => com_api_const_pkg.TRUE
      , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
    );
    l_test_mode := nvl(l_test_mode, fcl_api_const_pkg.ATTR_MISS_RISE_ERROR);

    for original in (
        select o.oper_amount
             , o.oper_currency
             , o.oper_date
             , p.terminal_id
          from opr_operation o
             , opr_participant p
         where p.oper_id = o.id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and o.id = l_original_id
    ) loop
        begin
            opr_api_check_pkg.completion_check(
                i_terminal_id        => original.terminal_id
              , i_original_date      => original.oper_date
              , i_oper_date          => opr_api_shared_data_pkg.get_operation().oper_date
              , i_original_currency  => original.oper_currency
              , i_original_amount    => original.oper_amount
              , i_oper_currency      => opr_api_shared_data_pkg.get_operation().oper_currency
              , i_oper_amount        => opr_api_shared_data_pkg.get_operation().oper_amount
              , o_reason             => l_reason
            );

            if l_reason != aup_api_const_pkg.RESP_CODE_OK
               and l_test_mode in (fcl_api_const_pkg.ATTR_MISS_RISE_ERROR, fcl_api_const_pkg.ATTR_MISS_PROHIBITIVE_VALUE)
            then
                opr_api_shared_data_pkg.rollback_process(
                    i_id      => opr_api_shared_data_pkg.get_operation().id
                  , i_status  => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                  , i_reason  => l_reason
                );
            end if;
        exception
            when others then
                if      com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
                    and com_api_error_pkg.get_last_error in ('FEE_NOT_DEFINED', 'CYCLE_NOT_DEFINED')
                    and l_test_mode in (fcl_api_const_pkg.ATTR_MISS_IGNORE
                                      , fcl_api_const_pkg.ATTR_MISS_UNBOUNDED_VALUE
                                      , fcl_api_const_pkg.ATTR_MISS_ZERO_VALUE)
                then
                    null;
                else
                    raise;
                end if;
        end;
        return;
    end loop;

    opr_api_shared_data_pkg.rollback_process(
        i_id      => opr_api_shared_data_pkg.get_operation().id
      , i_status  => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
      , i_reason  => aup_api_const_pkg.RESP_CODE_PREAUTH_NOT_FOUND
    );
end completion_check;

procedure activate_card is
begin
    iss_api_card_pkg.activate_card(
        i_card_instance_id  => opr_api_shared_data_pkg.g_auth.card_instance_id
      , i_initial_status    => opr_api_shared_data_pkg.get_param_char('INITIAL_CARD_STATUS')
      , i_status            => opr_api_shared_data_pkg.get_param_char('CARD_STATUS')
      , i_params            => opr_api_shared_data_pkg.g_params
    );
end;

procedure deactivate_card
is
    l_result_status                 com_api_type_pkg.t_name;
begin
    l_result_status := opr_api_shared_data_pkg.get_param_char('CARD_STATUS');

    iss_api_card_pkg.deactivate_card(
        i_card_instance_id  => opr_api_shared_data_pkg.g_auth.card_instance_id
      , i_status            => l_result_status
    );
end;

procedure count_wrong_pin_attempt
is
    l_result_status                 com_api_type_pkg.t_name;
    l_limit_type                    com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_product_id                    com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_count_curr                    com_api_type_pkg.t_long_id;
    l_count_limit                   com_api_type_pkg.t_long_id;
    l_sum_value                     com_api_type_pkg.t_money;
    l_sum_limit                     com_api_type_pkg.t_money;
    l_sum_curr                      com_api_type_pkg.t_money;
    l_currency                      com_api_type_pkg.t_curr_code;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
    l_reason                        com_api_type_pkg.t_dict_value;
begin
    if opr_api_shared_data_pkg.g_auth.crdh_auth_method != 'F2280001' then
        trc_log_pkg.debug(
            i_text => 'Current operation not by PIN : ' || opr_api_shared_data_pkg.g_auth.crdh_auth_method
        );
        return;
    end if;

    l_limit_type  := opr_api_shared_data_pkg.get_param_char('LIMIT_TYPE');
    l_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD;

    l_account_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'ACCOUNT_NAME'
          , i_mask_error    => com_api_const_pkg.TRUE
        );

    l_party_type :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'PARTY_TYPE'
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => com_api_const_pkg.PARTICIPANT_ISSUER
        );

    l_object_id :=
        opr_api_shared_data_pkg.get_object_id(
            i_entity_type   => l_entity_type
          , i_account_name  => l_account_name
          , i_party_type    => l_party_type
          , o_inst_id       => l_inst_id
        );

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type   => l_entity_type
          , i_object_id     => l_object_id
        );

    l_test_mode :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'ATTR_MISS_TESTMODE'
          , i_mask_error  => com_api_const_pkg.TRUE
          , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
        );

    l_eff_date_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'EFFECTIVE_DATE'
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => null
        );

    if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_eff_date :=
            com_api_sttl_day_pkg.get_open_sttl_date(
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

    l_reason := opr_api_shared_data_pkg.get_param_char(
                    i_name         => 'RESP_CODE'
                  , i_mask_error   => com_api_const_pkg.TRUE
                  , i_error_value  => aup_api_const_pkg.RESP_CODE_OK
                );
    begin
        fcl_api_limit_pkg.switch_limit_counter (
            i_limit_type            => l_limit_type
          , i_product_id            => l_product_id
          , i_entity_type           => l_entity_type
          , i_object_id             => l_object_id
          , i_params                => opr_api_shared_data_pkg.g_params
          , i_count_value           => 1
          , i_sum_value             => 0
          , i_currency              => com_api_const_pkg.UNDEFINED_CURRENCY
          , o_count_curr            => l_count_curr
          , o_count_limit           => l_count_limit
          , o_currency              => l_currency
          , o_sum_value             => l_sum_value
          , o_sum_limit             => l_sum_limit
          , o_sum_curr              => l_sum_curr
          , i_inst_id               => l_inst_id
          , i_check_overlimit       => com_api_const_pkg.TRUE
          , i_test_mode             => l_test_mode
          , i_eff_date              => l_eff_date
        );

        trc_log_pkg.debug('Current value: '||l_count_curr||', Limit value: '||l_count_limit);

        if l_count_curr = l_count_limit then
            l_result_status := opr_api_shared_data_pkg.get_param_char('CARD_STATUS');

            evt_api_status_pkg.change_status(
                i_initiator      => evt_api_const_pkg.INITIATOR_CLIENT
              , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id      => opr_api_shared_data_pkg.g_auth.card_instance_id
              , i_new_status     => l_result_status
              , i_reason         => null
              , o_status         => l_result_status
              , i_params         => opr_api_shared_data_pkg.g_params
              , i_raise_error    => com_api_const_pkg.TRUE
            );
        end if;

    exception
        when others then
            if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE and com_api_error_pkg.get_last_error = 'OVERLIMIT' then
                l_result_status := opr_api_shared_data_pkg.get_param_char('CARD_STATUS');

                evt_api_status_pkg.change_status(
                    i_initiator      => evt_api_const_pkg.INITIATOR_CLIENT
                  , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                  , i_object_id      => opr_api_shared_data_pkg.g_auth.card_instance_id
                  , i_new_status     => l_result_status
                  , i_reason         => null
                  , o_status         => l_result_status
                  , i_params         => opr_api_shared_data_pkg.g_params
                  , i_raise_error    => com_api_const_pkg.TRUE
                );

                opr_api_shared_data_pkg.stop_process (
                    i_id      => opr_api_shared_data_pkg.g_auth.id
                  , i_status  => opr_api_shared_data_pkg.get_operation().status
                  , i_reason  => l_reason
                );

            else
                raise;
            end if;
    end;
end count_wrong_pin_attempt;

procedure load_payment_order_data is
    l_payment_order_id        com_api_type_pkg.t_long_id;
begin
    if opr_api_shared_data_pkg.get_operation().payment_order_id is not null then
        for rec in (
            select p.param_name
                 , d.param_value
              from pmo_order_data d
                 , pmo_parameter p
             where d.order_id = l_payment_order_id
               and d.param_id = p.id
        ) loop
            opr_api_shared_data_pkg.set_param(
                i_name    => rec.param_name
              , i_value   => rec.param_value
            );
        end loop;

        for rec in (
            select o.purpose_id
              from pmo_order o
             where o.id = l_payment_order_id
        ) loop
            opr_api_shared_data_pkg.set_param(
                i_name    => 'PURPOSE_ID'
              , i_value   => rec.purpose_id
            );
        end loop;
    end if;
end load_payment_order_data;

procedure set_payment_order_status
is
    l_status            com_api_type_pkg.t_dict_value;
begin
    l_status := opr_api_shared_data_pkg.get_param_char('PAYMENT_ORDER_STATUS');

    pmo_api_order_pkg.set_order_status(
        i_order_id      => opr_api_shared_data_pkg.get_operation().payment_order_id
      , i_status        => l_status
    );
end;

procedure select_participant_contract
 is
    l_contract_type         com_api_type_pkg.t_dict_value;
    l_participant_type      com_api_type_pkg.t_dict_value;
    l_oper_participant      opr_api_type_pkg.t_oper_part_rec;
begin
    l_contract_type    := opr_api_shared_data_pkg.get_param_char('CONTRACT_TYPE');
    l_participant_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');

    l_oper_participant := opr_api_shared_data_pkg.get_participant(l_participant_type);

    trc_log_pkg.debug('select_participant_contract: customer_id='||l_oper_participant.customer_id||', l_contract_type='||l_contract_type);

    select id
      into l_oper_participant.contract_id
      from prd_contract
     where customer_id = l_oper_participant.customer_id
       and contract_type = l_contract_type
       and end_date is null;

    opr_api_shared_data_pkg.set_participant(l_oper_participant);
exception
    when no_data_found then
        trc_log_pkg.debug('select_participant_contract: contract not found');
        null;
end;

procedure add_aggregator_participant
is
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_account               acc_api_type_pkg.t_account_rec;
    l_payment_host_id       com_api_type_pkg.t_tiny_id;
begin
    l_payment_host_id := opr_api_shared_data_pkg.get_operation().payment_host_id;
    opr_api_shared_data_pkg.set_param (
        i_name      => 'PAYMENT_HOST_ID'
      , i_value     => l_payment_host_id
    );

    prd_api_customer_pkg.find_customer(
        i_acq_inst_id           => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ACQUIRER).inst_id
      , i_host_id               => l_payment_host_id
      , o_customer_id           => l_customer_id
    );

    begin
        select id
             , account_number
             , inst_id
             , agent_id
             , currency
             , account_type
             , contract_id
             , customer_id
             , split_hash
          into l_account.account_id
             , l_account.account_number
             , l_account.inst_id
             , l_account.agent_id
             , l_account.currency
             , l_account.account_type
             , l_account.contract_id
             , l_account.customer_id
             , l_account.split_hash
          from acc_account
         where customer_id = l_customer_id
           and account_type = 'ACTP1402'
           and status != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED;
    exception
        when no_data_found then
            opr_api_shared_data_pkg.rollback_process (
                i_id       => opr_api_shared_data_pkg.get_operation().id
              , i_status   => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
              , i_reason   => aut_api_const_pkg.AUTH_REASON_NO_SELECT_ACCT
            );
    end;

    opr_api_shared_data_pkg.set_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , i_account_rec       => l_account
    );

    opr_api_create_pkg.add_participant(
        i_oper_id               => opr_api_shared_data_pkg.get_operation().id
      , i_msg_type              => opr_api_shared_data_pkg.get_operation().msg_type
      , i_oper_type             => opr_api_shared_data_pkg.get_operation().oper_type
      , i_participant_type      => com_api_const_pkg.PARTICIPANT_AGGREGATOR
      , i_inst_id               => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ACQUIRER).inst_id
      , i_customer_id           => l_customer_id
      , i_account_id            => l_account.account_id
      , i_account_number        => l_account.account_number
      , i_account_type          => l_account.account_type
      , i_without_checks        => com_api_const_pkg.TRUE
    );
end;

procedure register_event is
    l_event_type            com_api_type_pkg.t_dict_value;
    l_party_type            com_api_type_pkg.t_dict_value;
    l_entity_type           com_api_type_pkg.t_dict_value;
    l_account_name          com_api_type_pkg.t_dict_value;
    l_object_id             com_api_type_pkg.t_long_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_evt_obj_status        com_api_type_pkg.t_dict_value;
begin
    l_event_type := opr_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_party_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_entity_type := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE', com_api_const_pkg.TRUE, opr_api_const_pkg.ENTITY_TYPE_OPERATION);
    l_entity_type := nvl(l_entity_type, opr_api_const_pkg.ENTITY_TYPE_OPERATION);
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME', com_api_const_pkg.TRUE, NULL);
    l_evt_obj_status := opr_api_shared_data_pkg.get_param_char('EVENT_OBJECT_STATUS', com_api_const_pkg.TRUE, NULL);

    if l_entity_type != opr_api_const_pkg.ENTITY_TYPE_OPERATION then
        l_object_id :=
            opr_api_shared_data_pkg.get_object_id(
                i_entity_type     => l_entity_type
              , i_account_name  => l_account_name
              , i_party_type    => l_party_type
              , o_inst_id       => l_inst_id
            );
    else
        l_object_id := opr_api_shared_data_pkg.get_operation().id;
    end if;

    evt_api_event_pkg.register_event (
        i_event_type    => l_event_type
      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
      , i_entity_type   => l_entity_type
      , i_object_id     => l_object_id
      , i_inst_id       => opr_api_shared_data_pkg.get_participant(l_party_type).inst_id
      , i_split_hash    => opr_api_shared_data_pkg.get_participant(l_party_type).split_hash
      , i_param_tab     => opr_api_shared_data_pkg.g_params
      , i_status        => l_evt_obj_status
    );
end;

procedure make_notification is
    l_event_type        com_api_type_pkg.t_dict_value;
    l_party_type        com_api_type_pkg.t_dict_value;
    l_mask_error        com_api_type_pkg.t_boolean;
    l_entity_type       com_api_type_pkg.t_dict_value;
    l_account_name      com_api_type_pkg.t_name;
    l_src_object_id     com_api_type_pkg.t_long_id;
    l_address_name      com_api_type_pkg.t_full_desc;
    l_delivery_address  com_api_type_pkg.t_full_desc;
begin
    l_account_name := opr_api_shared_data_pkg.get_param_char(
        i_name          => 'ACCOUNT_NAME'
      , i_mask_error    => com_api_const_pkg.TRUE
    );

    l_entity_type := opr_api_shared_data_pkg.get_param_char(
        i_name          => 'ENTITY_TYPE'
      , i_mask_error    => com_api_const_pkg.TRUE
    );

    l_address_name := opr_api_shared_data_pkg.get_param_char(
        i_name          => 'DELIVERY_ADDRESS'
      , i_mask_error    => com_api_const_pkg.TRUE
    );

    if l_address_name is not null then
        l_delivery_address := opr_api_shared_data_pkg.get_param_char(
            i_name          => l_address_name
          , i_mask_error    => com_api_const_pkg.TRUE
        );
    end if;

    l_event_type := opr_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_party_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_mask_error := evt_api_shared_data_pkg.get_param_num('MASK_ERROR', com_api_const_pkg.TRUE, com_api_const_pkg.TRUE);

    l_src_object_id := opr_api_shared_data_pkg.get_object_id(
        i_entity_type   => l_entity_type
      , i_account_name  => l_account_name
      , i_party_type    => l_party_type
    );

    ntf_api_notification_pkg.make_notification_param(
        i_inst_id             => opr_api_shared_data_pkg.get_participant(l_party_type).inst_id
      , i_event_type          => l_event_type
      , i_entity_type         => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id           => opr_api_shared_data_pkg.get_operation().id
      , i_eff_date            => opr_api_shared_data_pkg.get_operation().oper_date
      , i_notify_party_type   => nvl(l_party_type, com_api_const_pkg.PARTICIPANT_ISSUER)
      , i_src_entity_type     => l_entity_type
      , i_src_object_id       => l_src_object_id
      , i_delivery_address    => l_delivery_address
      , i_param_tab           => opr_api_shared_data_pkg.g_params
    );

exception
    when others then
        if nvl(l_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text        => 'Make notification error intercepted: [#1]'
              , i_env_param1  => sqlerrm
            );
        else
            raise;
        end if;
end;

/**************************************************
 * Obsolete. Do not use.
 **************************************************/
procedure make_notification_by_account is
    l_event_type        com_api_type_pkg.t_dict_value;
    l_party_type        com_api_type_pkg.t_dict_value;
    l_mask_error        com_api_type_pkg.t_boolean;
    l_account_name      com_api_type_pkg.t_name;
    l_src_object_id     com_api_type_pkg.t_long_id;
    l_card_category     com_api_type_pkg.t_dict_value;
begin
    l_account_name := opr_api_shared_data_pkg.get_param_char(
        i_name          => 'ACCOUNT_NAME'
      , i_mask_error    => com_api_const_pkg.TRUE
    );
    l_event_type := opr_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_party_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_mask_error := evt_api_shared_data_pkg.get_param_num(
        i_name          => 'MASK_ERROR'
        , i_mask_error  => com_api_const_pkg.TRUE
    );
    l_mask_error := nvl(l_mask_error, com_api_const_pkg.TRUE);

    l_src_object_id := opr_api_shared_data_pkg.get_object_id(
        i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_account_name  => l_account_name
      , i_party_type    => l_party_type
    );

    l_card_category := opr_api_shared_data_pkg.get_param_char(
        i_name        => 'CARD_CATEGORY'
      , i_mask_error  => com_api_const_pkg.TRUE
    );

    for card in (
        select
            distinct c.id
        from
            iss_card c
            , iss_card_instance i
            , acc_account_object o
        where
            o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
            and o.account_id = l_src_object_id
            and o.object_id = c.id
            and (c.category = l_card_category or l_card_category is null)
            and i.card_id = c.id
            and i.state = iss_api_const_pkg.CARD_STATE_ACTIVE
    ) loop
        ntf_api_notification_pkg.make_notification (
            i_inst_id              => opr_api_shared_data_pkg.get_participant(l_party_type).inst_id
            , i_event_type         => l_event_type
            , i_entity_type        => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            , i_object_id          => opr_api_shared_data_pkg.get_operation().id
            , i_eff_date           => opr_api_shared_data_pkg.get_operation().oper_date
            , i_notify_party_type  => nvl(l_party_type, com_api_const_pkg.PARTICIPANT_ISSUER)
            , i_src_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD
            , i_src_object_id      => card.id
        );
    end loop;

exception
    when others then
        if l_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text        => 'Make notification error intercepted: [#1]'
              , i_env_param1  => sqlerrm
            );
        else
            raise;
        end if;

end;

procedure add_notification is
    l_party_type        com_api_type_pkg.t_dict_value := com_api_const_pkg.PARTICIPANT_ISSUER;
    l_auth_id           com_api_type_pkg.t_long_id;
    l_mobile            com_api_type_pkg.t_full_desc;
    l_delivery_address  com_api_type_pkg.t_full_desc;
    l_card_id           com_api_type_pkg.t_medium_id;
    l_product_id        com_api_type_pkg.t_short_id;
    l_cardholder_id     com_api_type_pkg.t_medium_id;
    l_customer_id       com_api_type_pkg.t_medium_id;
    l_contract_id       com_api_type_pkg.t_medium_id;
    l_person_id         com_api_type_pkg.t_medium_id;
    l_contact_id        com_api_type_pkg.t_medium_id;
    l_contact_object_id com_api_type_pkg.t_long_id;

    l_service_id        com_api_type_pkg.t_short_id;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_is_actived        com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE;
    l_contact_type      com_api_type_pkg.t_dict_value;

    l_scheme            com_api_type_pkg.t_tiny_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_sysdate           date;
    l_using_custom_object com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_count             com_api_type_pkg.t_count := 0;
    l_tag_value         com_api_type_pkg.t_name;
    l_postponed_event   evt_api_type_pkg.t_postponed_event;
    l_service_type_id   com_api_type_pkg.t_short_id;
begin
    l_sysdate      := com_api_sttl_day_pkg.get_sysdate;
    l_auth_id      := opr_api_shared_data_pkg.get_operation().id;
    l_card_id      := opr_api_shared_data_pkg.get_participant(l_party_type).card_id;
    l_inst_id      := opr_api_shared_data_pkg.get_participant(l_party_type).inst_id;
    l_contact_type := opr_api_shared_data_pkg.get_param_char('CONTACT_TYPE', com_api_const_pkg.TRUE);
    l_contact_type := nvl(l_contact_type, com_api_const_pkg.CONTACT_TYPE_NOTIFICATION);
    l_service_type_id := opr_api_shared_data_pkg.get_param_num('SERVICE_TYPE_ID', com_api_type_pkg.TRUE);
    l_service_type_id := nvl(l_service_type_id, ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE);

    select min(decode(tag_id, 96, tag_value, 8705, tag_value, null)) mobile
      into l_mobile
      from aup_tag_value
     where tag_id in ('96', '8705')
       and auth_id = l_auth_id
       and seq_number = 1;

    l_tag_value := aup_api_tag_pkg.get_tag_value(l_auth_id, ntf_api_const_pkg.TAG_USING_CUSTOM_EVENT);
    
    if l_tag_value is null then
        l_using_custom_object := nvl(opr_api_shared_data_pkg.get_param_num('USING_CUSTOM_OBJECT', com_api_const_pkg.TRUE), com_api_const_pkg.FALSE);
    else
        l_using_custom_object := to_number(l_tag_value);
    end if;

    -- get cardholder
    select t.product_id
         , c.cardholder_id
         , t.customer_id
         , c.contract_id
         , h.person_id
      into l_product_id
         , l_cardholder_id
         , l_customer_id
         , l_contract_id
         , l_person_id
      from iss_card c
         , iss_cardholder h
         , prd_contract t
     where c.id = l_card_id
       and t.id = c.contract_id
       and h.id = c.cardholder_id;

    -- get active service
    begin
        select o.service_id
          into l_service_id
          from prd_service_object o
             , prd_service s
         where o.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
           and o.object_id       = l_card_id
           and o.service_id      = s.id
            and s.service_type_id = l_service_type_id
           and o.status          = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
           and rownum            = 1;
    exception
        when no_data_found then
            select min(p.service_id)
              into l_service_id
              from prd_product_service p
                 , prd_service s
             where p.product_id     = l_product_id
               and nvl(p.max_count, 0) > 0
               and s.id             = p.service_id
                    and s.service_type_id = l_service_type_id;

            if l_service_id is not null then
                prd_ui_service_pkg.set_service_object (
                    i_service_id            => l_service_id
                  , i_contract_id           => l_contract_id
                  , i_entity_type           => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_object_id             => l_card_id
                  , i_start_date            => get_sysdate
                  , i_end_date              => null
                  , i_inst_id               => l_inst_id
                  , i_params                => opr_api_shared_data_pkg.g_params
                  , i_need_postponed_event  => com_api_type_pkg.TRUE
                  , o_postponed_event       => l_postponed_event
                );
                l_is_actived := com_api_const_pkg.FALSE;

                trc_log_pkg.debug(
                    i_text        => 'add service object l_card_id [#1], l_contract_id [#2], l_service_type_id [#3]'
                  , i_env_param1  => l_card_id
                  , i_env_param2  => l_contract_id
                  , i_env_param3  => l_service_type_id
                );
            else
                trc_log_pkg.debug(
                    i_text       => 'service object NOT added, because service does not exist on product l_card_id [#1], l_contract_id [#2], l_product_id[#3]'
                  , i_env_param1 => l_card_id
                  , i_env_param2 => l_contract_id
                  , i_env_param3 => l_product_id
                );
            end if;
    end;

    -- check NOTIFICATION_SCHEME for customer
    l_scheme := prd_api_product_pkg.get_attr_value_number (
                    i_product_id    => l_product_id
                  , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , i_object_id     => l_customer_id
                  , i_attr_name     => 'NOTIFICATION_SCHEME'
                  , i_params        => l_param_tab
                  , i_inst_id       => l_inst_id
                );

    if (l_using_custom_object = com_api_const_pkg.TRUE) then
        -- save a few mobile numbers in ntf_custom_*
        ntf_api_custom_pkg.add_custom_events(
            i_mobile                => l_mobile
          , i_card_id               => l_card_id
          , i_customer_id           => l_customer_id
          , i_scheme_notification   => l_scheme
        );
    else
        -- save one mobile number in contact data
        select min(c.commun_address)
             , min(b.id)
             , min(a.id)
          into l_delivery_address
             , l_contact_object_id
             , l_contact_id
          from com_contact a
             , com_contact_object b
             , com_contact_data c
         where b.object_id     = l_cardholder_id
           and b.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
           and b.contact_type  = l_contact_type
           and b.contact_id    = a.id
           and c.contact_id    = a.id
           and c.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
           and (c.end_date is null or c.end_date > l_sysdate);

        trc_log_pkg.debug(
            i_text        => 'l_contact_object_id [#1], l_contact_id [#2]'
          , i_env_param1  => l_contact_object_id
          , i_env_param2  => l_contact_id
        );

        trc_log_pkg.debug(
            i_text        => 'l_delivery_address [#1], l_mobile [#2]'
          , i_env_param1  => l_delivery_address
          , i_env_param2  => l_mobile
        );

        if nvl(l_delivery_address, '0') != nvl(l_mobile, '0') then
            if l_is_actived = com_api_const_pkg.TRUE then
                -- deactivation delivery address
                evt_api_event_pkg.register_event (
                    i_event_type   => opr_api_const_pkg.EVENT_DEACTIVE_DELIVERY_ADDR
                  , i_eff_date     => opr_api_shared_data_pkg.get_operation().host_date
                  , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                  , i_object_id    => l_cardholder_id
                  , i_inst_id      => l_inst_id
                  , i_split_hash   => com_api_hash_pkg.get_split_hash(iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER, l_cardholder_id)
                  , i_param_tab    => opr_api_shared_data_pkg.g_params
                );
                l_delivery_address := null;
            end if;

            if l_contact_id is null then
                com_api_contact_pkg.add_contact (
                    o_id              => l_contact_id
                  , i_preferred_lang  => get_user_lang
                  , i_job_title       => null
                  , i_person_id       => l_person_id
                  , i_inst_id         => l_inst_id
                );
            end if;

            if l_contact_object_id is null then
                com_api_contact_pkg.add_contact_object (
                    o_contact_object_id => l_contact_object_id
                  , i_contact_id        => l_contact_id
                  , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                  , i_object_id         => l_cardholder_id
                  , i_contact_type      => l_contact_type
                );
            end if;

            if l_delivery_address is null then
                if l_mobile is not null then
                    select count(1)
                      into l_count
                      from com_contact_data d
                     where d.commun_method  = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                       and d.commun_address = l_mobile
                       and d.contact_id     = l_contact_id
                       and (d.end_date is null or d.end_date > l_sysdate);

                    if l_count = 0 then
                        com_api_contact_pkg.add_contact_data (
                            i_contact_id      => l_contact_id
                          , i_commun_method   => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                          , i_commun_address  => l_mobile
            , i_start_date      => opr_api_shared_data_pkg.get_operation().host_date
                        );
                    end if;
                end if;
            elsif l_delivery_address is not null then
                com_api_contact_pkg.modify_contact_data (
                    i_contact_id      => l_contact_id
                  , i_commun_method   => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                  , i_commun_address  => l_delivery_address
                , i_start_date      => opr_api_shared_data_pkg.get_operation().host_date
                );
            end if;

            -- activation delivery address
            evt_api_event_pkg.register_event (
                i_event_type   => opr_api_const_pkg.EVENT_ACTIVE_DELIVERY_ADDR
              , i_eff_date     => opr_api_shared_data_pkg.get_operation().host_date
              , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
              , i_object_id    => l_cardholder_id
              , i_inst_id      => l_inst_id
              , i_split_hash   => com_api_hash_pkg.get_split_hash(iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER, l_cardholder_id)
              , i_param_tab    => opr_api_shared_data_pkg.g_params
            );
        end if;
    end if;

    if l_is_actived = com_api_const_pkg.FALSE then
        evt_api_event_pkg.register_postponed_event(
            i_postponed_event  => l_postponed_event
        );
    end if;

end add_notification;

procedure remove_notification is
    l_party_type        com_api_type_pkg.t_dict_value := com_api_const_pkg.PARTICIPANT_ISSUER;
    l_card_id           com_api_type_pkg.t_medium_id;
    l_service_id        com_api_type_pkg.t_short_id;
    l_product_id        com_api_type_pkg.t_short_id;
    l_customer_id       com_api_type_pkg.t_medium_id;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_scheme            com_api_type_pkg.t_tiny_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
begin
    l_card_id := opr_api_shared_data_pkg.get_participant(l_party_type).card_id;

    begin
        select o.service_id
          into l_service_id
          from prd_service_object o
             , prd_service s
         where o.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
           and o.object_id       = l_card_id
           and o.service_id      = s.id
           and s.service_type_id = ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
           and o.status          = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
           and rownum            = 1;

        prd_api_service_pkg.change_service_object (
            i_service_id    => l_service_id
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => l_card_id
          , i_params        => opr_api_shared_data_pkg.g_params
          , i_status        => prd_api_const_pkg.SERVICE_OBJECT_STATUS_INACTIVE
        );

    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text       => 'PRD_NO_ACTIVE_SERVICE'
              , i_env_param1 => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_env_param2 => l_card_id
              , i_env_param3 => null
              , i_env_param4 => get_sysdate
            );
        return;
    end;

    select t.product_id
         , t.customer_id
         , c.inst_id
      into l_product_id
         , l_customer_id
         , l_inst_id
      from iss_card c
         , iss_cardholder h
         , prd_contract t
     where c.id = l_card_id
       and t.id = c.contract_id
       and h.id = c.cardholder_id;

    -- check NOTIFICATION_SCHEME for customer
    l_scheme := prd_api_product_pkg.get_attr_value_number (
                    i_product_id    => l_product_id
                  , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , i_object_id     => l_customer_id
                  , i_attr_name     => 'NOTIFICATION_SCHEME'
                  , i_params        => l_param_tab
                  , i_inst_id       => l_inst_id
                );

    for ce in (
        select ce.id
          from ntf_custom_event_vw ce
             , ntf_scheme_event_vw se
             , ntf_custom_object   eo
         where se.scheme_id = l_scheme
           and case
                   when ce.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                      then iss_api_cardholder_pkg.get_cardholder_by_card(i_card_id => l_card_id)
                   when ce.entity_type = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      then iss_api_card_pkg.get_customer_id(i_card_id => l_card_id)
                   else -1
               end = ce.object_id
           and nvl(ce.end_date, get_sysdate + 1) > get_sysdate
           and ce.start_date     < get_sysdate
           and ce.event_type     = se.event_type
           and (ce.contact_type  = se.event_type or ce.contact_type is null)
           and ce.id             = eo.custom_event_id
           and ce.status        != ntf_api_const_pkg.STATUS_DO_NOT_SEND
           and eo.object_id      = l_card_id
    ) loop
        ntf_api_custom_pkg.deactivate_custom_event(ce.id);
    end loop;

end remove_notification;

procedure change_object_status
is
    l_entity_type                   com_api_type_pkg.t_name;
    l_orig_entity_type              com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_oper_reason                   com_api_type_pkg.t_dict_value;
    l_seq_number                    com_api_type_pkg.t_tiny_id;
    l_expir_date                    date;
    l_initiator                     com_api_type_pkg.t_dict_value;
begin
    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name := opr_api_shared_data_pkg.get_param_char(
                          i_name       => 'ACCOUNT_NAME'
                        , i_mask_error => com_api_const_pkg.TRUE
                      );
    l_party_type   := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_initiator    := nvl(opr_api_shared_data_pkg.get_param_char('INITIATOR'), evt_api_const_pkg.INITIATOR_CLIENT);

    l_object_id    := opr_api_shared_data_pkg.get_object_id(
                          io_entity_type  => l_entity_type
                        , i_account_name  => l_account_name
                        , i_party_type    => l_party_type
                        , o_inst_id       => l_inst_id
                      );
    l_oper_reason := coalesce(
                         opr_api_shared_data_pkg.get_operation().oper_reason
                       , opr_api_shared_data_pkg.get_param_char('OPER_REASON')
                     );
    trc_log_pkg.debug('l_object_id [' || l_object_id || '], l_oper_reason [' || l_oper_reason || ']');

    if l_oper_reason like 'CSTS%' then
        if l_entity_type != iss_api_const_pkg.ENTITY_TYPE_CARD then
            com_api_error_pkg.raise_error(
                i_error       => 'EVENT_TYPE_NOT_CORRESPOND_TO_ENTITY_TYPE'
              , i_env_param1  => l_oper_reason
              , i_env_param2  => l_entity_type
            );
        end if;

        l_seq_number := opr_api_shared_data_pkg.get_participant(l_party_type).card_seq_number;
        l_expir_date := opr_api_shared_data_pkg.get_participant(l_party_type).card_expir_date;

        begin
            l_object_id := iss_api_card_instance_pkg.get_card_instance_id(
                               i_card_id     => l_object_id
                             , i_seq_number  => l_seq_number
                             , i_expir_date  => l_expir_date
                             , i_state       => iss_api_const_pkg.CARD_STATE_ACTIVE
                             , i_raise_error => com_api_const_pkg.TRUE
                           );
        exception
            when com_api_error_pkg.e_application_error then
                opr_api_shared_data_pkg.rollback_process(
                    i_id      => opr_api_shared_data_pkg.get_operation().id
                  , i_status  => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                  , i_reason  => aup_api_const_pkg.RESP_CODE_ERROR
                );
        end;

        begin
            evt_api_status_pkg.change_status(
                i_initiator      => l_initiator
              , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id      => l_object_id
              , i_new_status     => l_oper_reason
              , i_inst_id        => l_inst_id
              , i_reason         => null
              , o_status         => l_oper_reason
              , i_eff_date       => opr_api_shared_data_pkg.get_operation().oper_date
              , i_params         => opr_api_shared_data_pkg.g_params
              , i_raise_error    => com_api_const_pkg.TRUE
            );
        exception
            when no_data_found or too_many_rows or com_api_error_pkg.e_application_error then
                if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE and com_api_error_pkg.get_last_error = 'ILLEGAL_STATUS_COMBINATION' then
                    opr_api_shared_data_pkg.rollback_process(
                        i_id      => opr_api_shared_data_pkg.get_operation().id
                      , i_status  => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                      , i_reason  => aup_api_const_pkg.RESP_CODE_SERVICE_NOT_ALLOWED
                    );
                else
                    opr_api_shared_data_pkg.rollback_process(
                        i_id      => opr_api_shared_data_pkg.get_operation().id
                      , i_status  => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                      , i_reason  => aup_api_const_pkg.RESP_CODE_ERROR
                    );
                end if;
        end;

    elsif l_oper_reason like 'TRMS%' then
        if l_entity_type != acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
            com_api_error_pkg.raise_error(
                i_error       => 'EVENT_TYPE_NOT_CORRESPOND_TO_ENTITY_TYPE'
              , i_env_param1  => l_oper_reason
              , i_env_param2  => l_entity_type
            );
        end if;

        evt_api_status_pkg.change_status(
            i_initiator      => l_initiator
          , i_entity_type    => l_entity_type
          , i_object_id      => l_object_id
          , i_new_status     => l_oper_reason
          , i_reason         => null
          , i_inst_id        => l_inst_id
          , o_status         => l_oper_reason
          , i_params         => opr_api_shared_data_pkg.g_params
          , i_raise_error    => com_api_const_pkg.TRUE
        );

    elsif l_oper_reason like 'MRCS%' then
        if l_entity_type != acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            com_api_error_pkg.raise_error(
                i_error       => 'EVENT_TYPE_NOT_CORRESPOND_TO_ENTITY_TYPE'
              , i_env_param1  => l_oper_reason
              , i_env_param2  => l_entity_type
            );
        end if;

        evt_api_status_pkg.change_status(
            i_initiator      => l_initiator
          , i_entity_type    => l_entity_type
          , i_object_id      => l_object_id
          , i_new_status     => l_oper_reason
          , i_reason         => null
          , i_inst_id        => l_inst_id
          , o_status         => l_oper_reason
          , i_params         => opr_api_shared_data_pkg.g_params
          , i_raise_error    => com_api_const_pkg.TRUE
        );

    elsif l_oper_reason like 'ACST%' then
        if l_entity_type != acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            com_api_error_pkg.raise_error(
                i_error       => 'EVENT_TYPE_NOT_CORRESPOND_TO_ENTITY_TYPE'
              , i_env_param1  => l_oper_reason
              , i_env_param2  => l_entity_type
            );
        end if;

        evt_api_status_pkg.change_status(
            i_initiator      => l_initiator
          , i_entity_type    => l_entity_type
          , i_object_id      => l_object_id
          , i_new_status     => l_oper_reason
          , i_inst_id        => l_inst_id
          , i_reason         => null
          , o_status         => l_oper_reason
          , i_params         => opr_api_shared_data_pkg.g_params
          , i_raise_error    => com_api_const_pkg.TRUE
        );

    else
        begin
            select entity_type
              into l_orig_entity_type
              from evt_event_type
             where event_type = l_oper_reason;
        exception
            when no_data_found then
                null;
        end;

        trc_log_pkg.debug('l_orig_entity_type [' || l_orig_entity_type || ']');

        if l_orig_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE and l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then

            l_seq_number := opr_api_shared_data_pkg.get_participant(l_party_type).card_seq_number;
            l_expir_date := opr_api_shared_data_pkg.get_participant(l_party_type).card_expir_date;

            select max(id)
                 , iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              into l_object_id
                 , l_entity_type
              from iss_card_instance
             where card_id = l_object_id
               and (l_expir_date is null or trunc(nvl(l_expir_date, expir_date), 'MON') = trunc(expir_date, 'MON'))
               and (l_seq_number is null or seq_number = l_seq_number);

            if l_object_id is null then
                com_api_error_pkg.raise_error(
                    i_error      => 'UNABLE_CHANGE_STATUS_OF_EXPIRED_CARD'
                  , i_env_param1 => l_entity_type
                  , i_env_param2 => l_object_id
                );
            end if;

        elsif l_orig_entity_type is null or l_orig_entity_type != l_entity_type then
            com_api_error_pkg.raise_error(
                i_error       => 'EVENT_TYPE_NOT_CORRESPOND_TO_ENTITY_TYPE'
              , i_env_param1  => l_oper_reason
              , i_env_param2  => l_entity_type
            );
        end if;

        evt_api_status_pkg.change_status(
            i_event_type   => l_oper_reason
          , i_initiator    => l_initiator
          , i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
          , i_inst_id      => l_inst_id
          , i_reason       => null
          , i_params       => opr_api_shared_data_pkg.g_params
        );
    end if;
end change_object_status;

procedure set_limit_object
is
    l_entity_type                   com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_limit_id                      com_api_type_pkg.t_long_id;
    l_value_id                      com_api_type_pkg.t_long_id;
    l_attr_name                     com_api_type_pkg.t_name;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_cycle_id                      com_api_type_pkg.t_long_id;
    l_definition_level              com_api_type_pkg.t_dict_value;
    l_limit_type                    com_api_type_pkg.t_dict_value;
    l_cycle_type                    com_api_type_pkg.t_dict_value;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
begin
    l_entity_type   := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name  := opr_api_shared_data_pkg.get_param_char(i_name => 'ACCOUNT_NAME', i_mask_error => com_api_const_pkg.TRUE);
    l_party_type    := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_limit_type    := opr_api_shared_data_pkg.get_param_char(
                           i_name          => 'LIMIT_TYPE'
                         , i_mask_error    => com_api_const_pkg.TRUE
                         , i_error_value   => opr_api_shared_data_pkg.get_operation().oper_reason
                       );

    if l_limit_type is null and opr_api_shared_data_pkg.get_operation().oper_reason like 'LMT%' then
        l_limit_type := opr_api_shared_data_pkg.get_operation().oper_reason;
    end if;

    trc_log_pkg.debug(
        i_text       => 'l_limit_type [#1]'
      , i_env_param1 => l_limit_type
    );

    begin
        select cycle_type
          into l_cycle_type
          from fcl_limit_type
         where limit_type = l_limit_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'LIMIT_TYPE_NOT_EXIST'
            );
    end;

    l_object_id :=
        opr_api_shared_data_pkg.get_object_id(
            io_entity_type  => l_entity_type
          , i_account_name  => l_account_name
          , i_party_type    => l_party_type
          , o_inst_id       => l_inst_id
        );

    select a.attr_name
         , b.service_id
         , d.product_id
         , a.definition_level
      into l_attr_name
         , l_service_id
         , l_product_id
         , l_definition_level
      from prd_attribute a
         , prd_service_object b
         , prd_service c
         , prd_contract d
     where a.object_type = l_limit_type
       and a.service_type_id = c.service_type_id
       and c.id = b.service_id
       and b.entity_type = l_entity_type
       and b.object_id = l_object_id
       and b.status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
       and b.contract_id = d.id;

    l_eff_date_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'EFFECTIVE_DATE'
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => null
        );

    if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_eff_date :=
            com_api_sttl_day_pkg.get_open_sttl_date(
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

    if l_definition_level = prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_PRODUCT and l_cycle_type is not null
    then
        l_limit_id :=
            prd_api_product_pkg.get_limit_id(
                i_product_id     => l_product_id
              , i_entity_type    => l_entity_type
              , i_object_id      => l_object_id
              , i_limit_type     => l_limit_type
              , i_params         => opr_api_shared_data_pkg.g_params
              , i_service_id     => l_service_id
              , i_eff_date       => l_eff_date
              , i_inst_id        => l_inst_id
            );

        select min(cycle_id)
          into l_cycle_id
          from fcl_limit_vw
         where id = l_limit_id;
    end if;

    fcl_ui_limit_pkg.add_limit(
        i_limit_type      => l_limit_type
      , i_cycle_id        => l_cycle_id
      , i_count_limit     => opr_api_shared_data_pkg.get_operation().oper_count
      , i_sum_limit       => opr_api_shared_data_pkg.get_operation().oper_amount
      , i_currency        => opr_api_shared_data_pkg.get_operation().oper_currency
      , i_posting_method  => acc_api_const_pkg.POSTING_METHOD_IMMEDIATE
      , i_inst_id         => l_inst_id
      , i_limit_base      => null
      , i_limit_rate      => null
      , i_is_custom       => com_api_const_pkg.FALSE
      , o_limit_id        => l_limit_id
    );

    l_value_id := null;
    prd_ui_attribute_value_pkg.set_attr_value_limit (
        io_attr_value_id    => l_value_id
      , i_service_id        => l_service_id
      , i_entity_type       => l_entity_type
      , i_object_id         => l_object_id
      , i_attr_name         => l_attr_name
      , i_mod_id            => null
      , i_start_date        => l_eff_date
      , i_end_date          => null
      , i_limit_id          => l_limit_id
      , i_check_start_date  => com_api_const_pkg.FALSE
    );

exception
    when no_data_found or com_api_error_pkg.e_application_error then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            trc_log_pkg.error(
                i_text       => 'PRD_NO_ACTIVE_SERVICE'
              , i_env_param1 => l_entity_type
              , i_env_param2 => l_object_id
              , i_env_param3 => l_limit_type
              , i_env_param4 => get_sysdate
            );
        end if;

        opr_api_shared_data_pkg.rollback_process(
            i_id => opr_api_shared_data_pkg.get_operation().id
          , i_status => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason => aup_api_const_pkg.RESP_CODE_ERROR
        );
end set_limit_object;

procedure load_object_data
is
    l_entity_type                   com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_participant                   opr_api_type_pkg.t_oper_part_rec;
    l_full_set                      com_api_type_pkg.t_boolean;
begin
    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_full_set     := nvl(
                          opr_api_shared_data_pkg.get_param_num(
                              i_name        => 'FULL_SET'
                            , i_mask_error  => com_api_const_pkg.TRUE
                            , i_error_value => com_api_const_pkg.FALSE
                          )
                        , com_api_const_pkg.FALSE
                      );
    l_account_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'ACCOUNT_NAME'
          , i_mask_error    => case l_entity_type
                                   when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                   then com_api_const_pkg.FALSE
                                   else com_api_const_pkg.TRUE
                               end
        );

    l_party_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');

    l_object_id :=
        opr_api_shared_data_pkg.get_object_id(
            i_entity_type     => l_entity_type
          , i_account_name    => l_account_name
          , i_party_type      => l_party_type
          , o_inst_id         => l_inst_id
        );

    case l_entity_type
        when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            rul_api_shared_data_pkg.load_account_params(
                i_account_id    => l_object_id
              , io_params       => opr_api_shared_data_pkg.g_params
            );
        when iss_api_const_pkg.ENTITY_TYPE_CARD then
            l_participant := opr_api_shared_data_pkg.get_participant(l_party_type);

            if l_full_set = com_api_const_pkg.TRUE then
                opr_api_shared_data_pkg.load_card_bin_info(
                    i_party_type => l_party_type
                );
            end if;

            if  l_party_type in (com_api_const_pkg.PARTICIPANT_ISSUER
                               , com_api_const_pkg.PARTICIPANT_DEST)
                and l_participant.card_id is null
                and l_participant.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                and l_participant.card_expir_date is not null
            then
                trc_log_pkg.debug(
                    i_text       => 'A foreign card detected, card parameters from the participant [#1] will be used'
                  , i_env_param1 => l_party_type
                );
            else
                rul_api_shared_data_pkg.load_card_params(
                    i_card_id   => l_object_id
                  , io_params   => opr_api_shared_data_pkg.g_params
                );
            end if;
        when prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            rul_api_shared_data_pkg.load_customer_params(
                i_customer_id   => l_object_id
              , io_params       => opr_api_shared_data_pkg.g_params
            );
        when prd_api_const_pkg.ENTITY_TYPE_CONTRACT then
            rul_api_shared_data_pkg.load_contract_params(
                i_contract_id   => l_object_id
              , io_params       => opr_api_shared_data_pkg.g_params
            );
        when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
            rul_api_shared_data_pkg.load_terminal_params(
                i_terminal_id   => l_object_id
              , io_params       => opr_api_shared_data_pkg.g_params
              , i_full_set      => l_full_set
            );
        when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            rul_api_shared_data_pkg.load_merchant_params(
                i_merchant_id   => l_object_id
              , io_params       => opr_api_shared_data_pkg.g_params
            );
        else
            null;
    end case;

    rul_api_shared_data_pkg.load_flexible_fields(
        i_entity_type => l_entity_type
      , i_object_id   => l_object_id
      , i_usage       => com_api_const_pkg.FLEXIBLE_FIELD_PROC_OPER
      , io_params     => opr_api_shared_data_pkg.g_params
    );
end load_object_data;

procedure collect_p2p_tags is
    l_party_type        com_api_type_pkg.t_dict_value;
    l_customer_id       com_api_type_pkg.t_medium_id;
    l_sysdate           date;
begin
    l_sysdate    := com_api_sttl_day_pkg.get_sysdate;

    l_party_type := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'PARTY_TYPE'
        , i_mask_error   => com_api_const_pkg.TRUE
        , i_error_value  => com_api_const_pkg.PARTICIPANT_ISSUER
    );

    l_customer_id := opr_api_shared_data_pkg.get_participant(l_party_type).customer_id;

    for cust in (
        select
            com_ui_object_pkg.get_object_desc(c.entity_type, c.object_id, get_user_lang) customer_name
            , a.street
            , a.city
            , a.region
            , a.country
            , a.postal_code
            , ( select
                    c1.commun_address
                from
                    com_contact a
                    , com_contact_object b
                    , com_contact_data c1
                where
                    b.object_id = l_customer_id
                    and b.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                    and b.contact_id = a.id
                    and c1.contact_id = a.id
                    and c1.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                    and (c1.end_date is null or c1.end_date > l_sysdate)
                    and rownum < 2
            ) phone
        from
            prd_customer c
            , ( select
                    ca.id
                    , ca.lang
                    , ca.country
                    , ca.region
                    , ca.city
                    , ca.street
                    , ca.house
                    , ca.apartment
                    , ca.postal_code
                    , ca.region_code
                    , ob.object_id
                    , row_number() over (partition by ob.object_id order by decode(ca.lang, get_user_lang, 1, 'LANGENG', 2, 3)) rn
                from
                    com_address_vw ca
                    , com_address_object_vw ob
                where
                    ca.id = ob.address_id
                    and ob.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
            ) a
        where
            c.id = l_customer_id
            and a.object_id(+) = c.id
            and a.rn(+) = 1
    ) loop
        opr_api_shared_data_pkg.set_param (
            i_name     => 'CUSTOMER_NAME'
            , i_value  => cust.customer_name
        );
        opr_api_shared_data_pkg.set_param (
            i_name     => 'SENDER_STREET'
            , i_value  => cust.street
        );
        opr_api_shared_data_pkg.set_param (
            i_name     => 'SENDER_COUNTRY'
            , i_value  => cust.city
        );
        opr_api_shared_data_pkg.set_param (
            i_name     => 'SENDER_STATE'
            , i_value  => cust.region
        );
        opr_api_shared_data_pkg.set_param (
            i_name     => 'SENDER_COUNTRY'
            , i_value  => cust.country
        );
        opr_api_shared_data_pkg.set_param (
            i_name     => 'SENDER_POSTCODE'
            , i_value  => cust.postal_code
        );
        opr_api_shared_data_pkg.set_param (
            i_name     => 'SENDER_PHONE'
            , i_value  => cust.phone
        );
    end loop;
end;

procedure get_provider_account
is
    l_account       acc_api_type_pkg.t_account_rec;
    l_direction     com_api_type_pkg.t_tiny_id;
    l_participant   opr_api_type_pkg.t_oper_part_rec;
    l_account_name  com_api_type_pkg.t_name;
begin
    l_participant.participant_type  := com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER;
    l_participant.oper_id           := opr_api_shared_data_pkg.get_operation().id;

    l_account_name := opr_api_shared_data_pkg.get_param_char(
        i_name          => 'ACCOUNT_NAME'
      , i_mask_error    => com_api_const_pkg.TRUE
    );

    l_direction := opr_api_shared_data_pkg.get_param_num (
        i_name  => 'DIRECTION'
    );

    trc_log_pkg.debug(
        i_text          => 'operation [#1], direction [#2]'
      , i_env_param1    => l_participant.oper_id
      , i_env_param2    => l_direction
    );

    begin
        select c.id
             , c.contract_id
             , c.inst_id
             , c.split_hash
             , i.network_id
          into l_participant.customer_id
             , l_participant.contract_id
             , l_participant.inst_id
             , l_participant.split_hash
             , l_participant.network_id
          from opr_operation o
             , (
                   select id
                        , case
                              when l_direction = com_api_const_pkg.DIRECTION_OUTCOME
                              then purpose_id
                              else nvl(in_purpose_id, purpose_id)
                          end as purpose_id
                     from pmo_order
               ) po
             , pmo_purpose pp
             , prd_customer c
             , ost_institution i
         where o.id               = l_participant.oper_id
           and po.id              = o.payment_order_id
           and pp.id              = po.purpose_id
           and c.ext_object_id    = pp.provider_id
           and c.ext_entity_type  = pmo_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER
           and i.id               = c.inst_id;

    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'CUSTOMER_NOT_FOUND'
            );
    end;

    trc_log_pkg.debug(
        i_text          => 'customer_id [#1], contract_id [#2]'
      , i_env_param1    => l_participant.customer_id
      , i_env_param2    => l_participant.contract_id
    );

    if l_account_name is not null then
        begin
            select ac.id
                 , ac.split_hash
                 , ac.account_type
                 , ac.account_number
                 , ac.currency
                 , ac.inst_id
                 , ac.agent_id
                 , ac.status
                 , ac.contract_id
                 , ac.customer_id
                 , ac.scheme_id
              into l_account.account_id
                 , l_account.split_hash
                 , l_account.account_type
                 , l_account.account_number
                 , l_account.currency
                 , l_account.inst_id
                 , l_account.agent_id
                 , l_account.status
                 , l_account.contract_id
                 , l_account.customer_id
                 , l_account.scheme_id
              from opr_participant p
                 , acc_account ac
             where p.oper_id          = l_participant.oper_id
               and p.participant_type = com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER
               and ac.account_number  = p.account_number
               and ac.inst_id         = p.inst_id;

             l_participant.account_id       := l_account.account_id;
             l_participant.account_type     := l_account.account_type;
             l_participant.account_number   := l_account.account_number;
             l_participant.account_currency := l_account.currency;

        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text  => 'Account is not found'
                );
        end;

        opr_api_shared_data_pkg.set_account(
            i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
          , i_account_rec       => l_account
        );
    end if;

    opr_api_shared_data_pkg.set_participant(
        i_oper_participant  => l_participant
    );
end get_provider_account;

procedure rollback_limit_counter
is
    l_selector              com_api_type_pkg.t_name;
    l_limit_type            com_api_type_pkg.t_dict_value;
    l_amount_name           com_api_type_pkg.t_name;
    l_account_name          com_api_type_pkg.t_name;
    l_party_type            com_api_type_pkg.t_name;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_object_id             com_api_type_pkg.t_long_id;
    l_product_id            com_api_type_pkg.t_short_id;
    l_entity_type           com_api_type_pkg.t_dict_value;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_amount                com_api_type_pkg.t_amount_rec;
begin
    trc_log_pkg.debug(
        i_text  => 'rollback_limit_counter STARTED'
    );

    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type  := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_limit_type  := opr_api_shared_data_pkg.get_param_char('LIMIT_TYPE');

    l_object_id :=
        opr_api_shared_data_pkg.get_object_id(
            i_entity_type     => l_entity_type
          , i_account_name  => l_account_name
          , i_party_type    => l_party_type
          , o_inst_id       => l_inst_id
        );
    l_selector :=
        opr_api_shared_data_pkg.get_param_char(
            i_name           => 'OPERATION_SELECTOR'
          , i_mask_error   => com_api_const_pkg.TRUE
          , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
        );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id(i_selector => l_selector);

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type  => l_entity_type
          , i_object_id  => l_object_id
        );
    l_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'AMOUNT_NAME'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    if l_amount_name is not null then
        opr_api_shared_data_pkg.get_amount(
            i_name      => l_amount_name
          , o_amount    => l_amount.amount
          , o_currency  => l_amount.currency
        );
    end if;

    fcl_api_limit_pkg.rollback_limit_counter(
        i_limit_type        => l_limit_type
      , i_product_id        => l_product_id
      , i_entity_type       => l_entity_type
      , i_object_id         => l_object_id
      , i_params            => opr_api_shared_data_pkg.g_params
      , i_sum_value         => l_amount.amount
      , i_currency          => l_amount.currency
      , i_inst_id           => l_inst_id
      , i_source_object_id  => l_oper_id
    );

    trc_log_pkg.debug(
        i_text        => 'rollback_limit_counter FINISHED [#1]'
      , i_env_param1  => l_object_id
    );
end rollback_limit_counter;

procedure proportional_amount
is
    l_multiplier_amount_name   com_api_type_pkg.t_name;
    l_dividend_amount_name     com_api_type_pkg.t_name;
    l_divisor_amount_name      com_api_type_pkg.t_name;
    l_result_amount_name       com_api_type_pkg.t_name;
    l_multiplier_amount        com_api_type_pkg.t_amount_rec;
    l_divident_amount          com_api_type_pkg.t_amount_rec;
    l_divisor_amount           com_api_type_pkg.t_amount_rec;
    l_result_amount            com_api_type_pkg.t_amount_rec;
begin
    l_multiplier_amount_name := opr_api_shared_data_pkg.get_param_char('MULTIPLIER_AMOUNT_NAME');
    l_dividend_amount_name   := opr_api_shared_data_pkg.get_param_char('DIVIDEND_AMOUNT_NAME');
    l_divisor_amount_name    := opr_api_shared_data_pkg.get_param_char('DIVISOR_AMOUNT_NAME');
    l_result_amount_name     := opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_multiplier_amount_name
        , o_amount    => l_multiplier_amount.amount
        , o_currency  => l_multiplier_amount.currency
    );

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_dividend_amount_name
        , o_amount    => l_divident_amount.amount
        , o_currency  => l_divident_amount.currency
    );

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_divisor_amount_name
        , o_amount    => l_divisor_amount.amount
        , o_currency  => l_divisor_amount.currency
    );

    if l_divisor_amount.amount = 0 then
        com_api_error_pkg.raise_error(
            i_error  => 'DIVISOR_IS_ZERO_FOR_PROPORTIONAL_AMOUNT'
        );
    end if;

    if l_multiplier_amount.currency = l_divisor_amount.currency
      or l_multiplier_amount.amount = 0
      or l_divident_amount.amount   = 0
    then
        l_result_amount.currency := l_divident_amount.currency;
        l_result_amount.amount := round(l_multiplier_amount.amount * l_divident_amount.amount / l_divisor_amount.amount);

        opr_api_shared_data_pkg.set_amount(
            i_name        => l_result_amount_name
            , i_amount    => l_result_amount.amount
            , i_currency  => l_result_amount.currency
        );
    else
        com_api_error_pkg.raise_error(
            i_error         => 'USE_DIFFERENT_CURRENCY_FOR_PROPORTIONAL_AMOUNT'
            , i_env_param1  => l_divident_amount.currency
            , i_env_param2  => l_divisor_amount.currency
        );
    end if;
end;

procedure create_collection_only
is
    l_iss_inst_id          com_api_type_pkg.t_inst_id;
    l_iss_network_id       com_api_type_pkg.t_tiny_id;
    l_card_inst_id         com_api_type_pkg.t_inst_id;
    l_card_network_id      com_api_type_pkg.t_tiny_id;
    l_card_type            com_api_type_pkg.t_tiny_id;
    l_card_country         com_api_type_pkg.t_country_code;
    l_bin_currency         com_api_type_pkg.t_curr_code;
    l_sttl_currency        com_api_type_pkg.t_curr_code;
    l_use_merchant_address com_api_type_pkg.t_boolean;
begin
    iss_api_bin_pkg.get_bin_info(
        i_card_number         => opr_api_shared_data_pkg.g_auth.card_number
      , o_iss_inst_id         => l_iss_inst_id
      , o_iss_network_id      => l_iss_network_id
      , o_card_inst_id        => l_card_inst_id
      , o_card_network_id     => l_card_network_id
      , o_card_type           => l_card_type
      , o_card_country        => l_card_country
      , o_bin_currency        => l_bin_currency
      , o_sttl_currency       => l_sttl_currency
    );

    if l_card_network_id = cmp_api_const_pkg.MC_NETWORK
       and mcw_api_fin_pkg.is_collection_allow(
               i_card_num       => opr_api_shared_data_pkg.g_auth.card_number
             , i_network_id     => l_card_network_id
             , i_inst_id        => l_card_inst_id
             , i_card_type      => l_card_type
           ) = com_api_const_pkg.TRUE
    then
        l_use_merchant_address := nvl(opr_api_shared_data_pkg.get_param_num('USE_MERCHANT_ADDRESS'), com_api_const_pkg.FALSE);

        if l_use_merchant_address = com_api_const_pkg.TRUE then
        -- Change merchant address in auth to merchant address from DB
            begin
                select substr(upper(a.street), 1, 31)
                     , substr(upper(a.city), 1, 31)
                     , cn.name
                     , cn.code
                     , a.postal_code
                  into opr_api_shared_data_pkg.g_auth.merchant_street
                     , opr_api_shared_data_pkg.g_auth.merchant_city
                     , opr_api_shared_data_pkg.g_auth.merchant_region
                     , opr_api_shared_data_pkg.g_auth.merchant_country
                     , opr_api_shared_data_pkg.g_auth.merchant_postcode
                  from acq_terminal t
                     , com_address a
                     , com_address_object ao
                     , com_country cn
                 where t.terminal_number = opr_api_shared_data_pkg.g_auth.terminal_number
                   and t.inst_id = opr_api_shared_data_pkg.g_auth.acq_inst_id
                   and a.id = ao.address_id
                   and ao.object_id = t.merchant_id
                   and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and ao.address_type = 'ADTPBSNA'
                   and a.lang = com_api_const_pkg.LANGUAGE_ENGLISH
                   and cn.code = a.country;
            exception
                when no_data_found then
                    null;
            end;
        end if;

        mcw_api_fin_pkg.create_from_auth(
            i_auth_rec        => opr_api_shared_data_pkg.g_auth
          , i_id              => opr_api_shared_data_pkg.g_auth.id
          , i_inst_id         => ost_api_institution_pkg.get_network_inst_id(l_card_network_id)
          , i_network_id      => l_card_network_id
          , i_collection_only => com_api_const_pkg.TRUE
        );
         trc_log_pkg.debug(i_text          => 'Created MC collection');

    elsif l_card_network_id = cmp_api_const_pkg.VISA_NETWORK
        and vis_api_fin_message_pkg.is_collection_allow (
                i_network_id   => l_card_network_id
              , i_inst_id      => l_card_inst_id
              , i_mcc          => opr_api_shared_data_pkg.g_auth.mcc
            ) = com_api_const_pkg.TRUE
    then
        vis_api_fin_message_pkg.process_auth(
            i_auth_rec          => opr_api_shared_data_pkg.g_auth
          , io_fin_mess_id      => opr_api_shared_data_pkg.g_auth.id
          , i_inst_id           => ost_api_institution_pkg.get_network_inst_id(l_card_network_id)
          , i_network_id        => l_card_network_id
          , i_collect_only      => com_api_const_pkg.TRUE
        );

        trc_log_pkg.debug(i_text          => 'Created VISA collection');

    else
        trc_log_pkg.debug(i_text          => 'No collection created');
    end if;
end create_collection_only;

procedure get_bin_currency is
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type             com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_country_code;
    l_bin_currency          com_api_type_pkg.t_curr_code;
    l_sttl_currency         com_api_type_pkg.t_curr_code;
    l_party_type            com_api_type_pkg.t_dict_value;
    l_result_amount_name    com_api_type_pkg.t_name;
    l_card_number           com_api_type_pkg.t_card_number;
begin

    l_party_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');

    l_card_number := opr_api_shared_data_pkg.get_participant(l_party_type).card_number;

    iss_api_bin_pkg.get_bin_info (
        i_card_number          => l_card_number
        , o_iss_inst_id        => l_iss_inst_id
        , o_iss_network_id     => l_iss_network_id
        , o_card_inst_id       => l_card_inst_id
        , o_card_network_id    => l_card_network_id
        , o_card_type          => l_card_type
        , o_card_country       => l_card_country
        , o_bin_currency       => l_bin_currency
        , o_sttl_currency      => l_sttl_currency
    );

    l_result_amount_name     := opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME', com_api_const_pkg.TRUE, com_api_const_pkg.AMOUNT_PURPOSE_BIN);

    opr_api_shared_data_pkg.set_amount(
        i_name        => l_result_amount_name
        , i_amount    => 0
        , i_currency  => l_bin_currency
    );

end;

procedure check_reversal_amount is
    l_original_id               com_api_type_pkg.t_long_id;
    l_count                     pls_integer;
    l_amount                    com_api_type_pkg.t_money;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_amount_name               com_api_type_pkg.t_name;

begin
    l_original_id := opr_api_shared_data_pkg.get_operation().original_id;

    l_amount_name := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'AMOUNT_NAME'
        , i_mask_error   => com_api_const_pkg.FALSE
    );
    trc_log_pkg.debug(i_text => 'l_amount_name = ' || l_amount_name);

    select count(1)
      into l_count
      from opr_operation
     where original_id = l_original_id
       and is_reversal = com_api_const_pkg.TRUE
       and status in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD, opr_api_const_pkg.OPERATION_STATUS_MANUAL);

    l_currency := opr_api_shared_data_pkg.get_operation().oper_currency;
    if l_count > 0 then
        l_amount := 0;
        trc_log_pkg.debug(i_text => 'Reversal already exists. Count of reversal = ' || l_count);
    else
        l_amount := opr_api_shared_data_pkg.get_operation().oper_amount;
        trc_log_pkg.debug(i_text => 'Reversal is not exists.');
    end if;

    opr_api_shared_data_pkg.set_amount(
        i_name        => l_amount_name
        , i_amount    => l_amount
        , i_currency  => l_currency
    );

end;

/*
 * This rule is used to save some amount to amounts of found operation's authorization.
 */
procedure save_amount_to_auth_amounts
is
    l_oper_id               com_api_type_pkg.t_long_id;
    l_amount_name           com_api_type_pkg.t_name;
    l_amount_rec            com_api_type_pkg.t_amount_rec;
    l_amounts               com_api_type_pkg.t_raw_data;
    l_selector              com_api_type_pkg.t_dict_value;
begin
    -- Searching for destination operation by using SELECTOR,
    -- passed amount should be stored to AMOUNTS field of linked authorization
    l_selector := opr_api_shared_data_pkg.get_param_char(
                      i_name        => 'OPERATION_SELECTOR'
                    , i_mask_error  => com_api_const_pkg.TRUE
                    , i_error_value => opr_api_const_pkg.OPER_SELECTOR_ORIGINAL
                  );

    l_oper_id := opr_api_shared_data_pkg.get_operation_id(i_selector => l_selector);
    trc_log_pkg.debug('l_oper_id [' || l_oper_id || ']');

    l_amount_name := opr_api_shared_data_pkg.get_param_char(i_name => 'AMOUNT_NAME');
    if l_amount_name is not null then
        opr_api_shared_data_pkg.get_amount(
            i_name     => l_amount_name
          , o_amount   => l_amount_rec.amount
          , o_currency => l_amount_rec.currency
        );
    end if;

    if l_amount_rec.amount is null then
        trc_log_pkg.debug('Amount is empty, skip saving it to amounts');
    else
        aup_api_process_pkg.get_amounts(
            i_auth_id => l_oper_id
          , o_amounts => l_amounts
        );
        l_amounts := l_amounts
                  || aup_api_process_pkg.serialize_auth_amount(
                         i_amount_type => l_amount_name
                       , i_amount_rec  => l_amount_rec
                     );
        trc_log_pkg.debug('l_amounts [' || substr(l_amounts, 1, 3900) || ']');
        aup_api_process_pkg.save_amounts(
            i_auth_id => l_oper_id
          , i_amounts => l_amounts
        );
        trc_log_pkg.debug('Amount added to amounts of authorization [' || l_oper_id || ']');
    end if;
end save_amount_to_auth_amounts;

procedure calculate_unhold_date
is
    l_base_date_name                com_api_type_pkg.t_name;
    l_base_date                     date;
    l_result_date                   date;
    l_cycle_type                    com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_cycle_id                      com_api_type_pkg.t_long_id;
    l_product_id                    com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_selector                      com_api_type_pkg.t_dict_value;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_oper_status                   com_api_type_pkg.t_dict_value;
    l_count                         pls_integer;
begin
    l_base_date_name := opr_api_shared_data_pkg.get_param_char('BASE_DATE_NAME');

    opr_api_shared_data_pkg.get_date(
        i_name     => l_base_date_name
      , o_date     => l_base_date
    );

    l_cycle_type   := opr_api_shared_data_pkg.get_param_char('CYCLE_TYPE');
    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name := opr_api_shared_data_pkg.get_param_char(
                          i_name        => 'ACCOUNT_NAME'
                        , i_mask_error  => com_api_const_pkg.TRUE
                        , i_error_value => null
                      );
    l_party_type   := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');

    l_selector     := opr_api_shared_data_pkg.get_param_char(
                          i_name        => 'OPERATION_SELECTOR'
                        , i_mask_error  => com_api_const_pkg.TRUE
                        , i_error_value => opr_api_const_pkg.OPER_SELECTOR_ORIGINAL
                      );

    l_oper_id      := opr_api_shared_data_pkg.get_operation_id(
                          i_selector => l_selector
                      );
    trc_log_pkg.debug('l_oper_id [' || l_oper_id || ']');

    l_oper_status  := opr_api_shared_data_pkg.get_param_char(
                          i_name        => 'OPERATION_STATUS'
                        , i_mask_error  => com_api_const_pkg.TRUE
                        , i_error_value => null
                      );

    select count(1)
      into l_count
      from opr_operation
     where id = l_oper_id
       and (status = l_oper_status or l_oper_status is null);

    if l_count > 0 then
        l_object_id     := opr_api_shared_data_pkg.get_object_id(
                               i_entity_type  => l_entity_type
                             , i_account_name => l_account_name
                             , i_party_type   => l_party_type
                             , o_inst_id      => l_inst_id
                           );

        l_product_id    := prd_api_product_pkg.get_product_id(
                               i_entity_type  => l_entity_type
                             , i_object_id    => l_object_id
                           );

        l_eff_date_name := opr_api_shared_data_pkg.get_param_char(
                               i_name         => 'EFFECTIVE_DATE'
                             , i_mask_error   => com_api_const_pkg.TRUE
                             , i_error_value  => null
                           );

        if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
            l_eff_date  := com_api_sttl_day_pkg.get_open_sttl_date(
                               i_inst_id => l_inst_id
                           );

        elsif l_eff_date_name is not null then
            opr_api_shared_data_pkg.get_date(
                i_name  => l_eff_date_name
              , o_date  => l_eff_date
            );

        else
            l_eff_date  := com_api_sttl_day_pkg.get_sysdate;

        end if;

        l_service_id  := prd_api_service_pkg.get_active_service_id(
                             i_entity_type => l_entity_type
                           , i_object_id   => l_object_id
                           , i_attr_type   => l_cycle_type
                           , i_eff_date    => l_eff_date
                         );
        l_cycle_id    := prd_api_product_pkg.get_cycle_id (
                             i_product_id    => l_product_id
                           , i_entity_type   => l_entity_type
                           , i_object_id     => l_object_id
                           , i_cycle_type    => l_cycle_type
                           , i_params        => opr_api_shared_data_pkg.g_params
                           , i_service_id    => l_service_id
                           , i_eff_date      => l_eff_date
                           , i_inst_id       => l_inst_id
                         );
        l_result_date := fcl_api_cycle_pkg.calc_next_date (
                             i_cycle_id      => l_cycle_id
                           , i_start_date    => l_base_date
                         );
        opr_api_shared_data_pkg.set_date(
            i_name      => com_api_const_pkg.DATE_PURPOSE_UNHOLD
          , i_date      => l_result_date
        );
    end if;
end calculate_unhold_date;

procedure add_institution_participant is
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_member_id             com_api_type_pkg.t_tiny_id;
    l_inst_id               com_api_type_pkg.t_tiny_id;
    l_host_inst_id          com_api_type_pkg.t_tiny_id;
    l_network_id            com_api_type_pkg.t_tiny_id;
    l_party_type            com_api_type_pkg.t_name;
    l_customer_number       com_api_type_pkg.t_name;
    l_participant_rec       opr_api_type_pkg.t_oper_part_rec;
begin
    l_party_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_network_id := opr_api_shared_data_pkg.get_param_char('NETWORK_ID');

    l_inst_id    := opr_api_shared_data_pkg.get_participant(
                        i_participant_type    => l_party_type
                    ).inst_id;

    l_member_id  := net_api_network_pkg.get_member_id(
                        i_inst_id             => l_inst_id
                      , i_network_id          => l_network_id
                      , i_participant_type    => l_party_type
                    );

    l_host_id    :=  net_api_network_pkg.get_host_id(
                        i_inst_id             => l_inst_id
                      , i_network_id          => l_network_id
                      , i_participant_type    => l_party_type
                    );

    net_api_network_pkg.get_host_info(
        i_member_id          => l_host_id
      , i_participant_type   => l_party_type
      , o_inst_id            => l_host_inst_id
      , o_network_id         => l_network_id
    );

    prd_api_customer_pkg.find_customer(
        i_acq_inst_id           => l_host_inst_id
      , i_host_id               => l_member_id
      , o_customer_id           => l_customer_id
    );

    l_customer_number := prd_api_customer_pkg.get_customer_number(i_customer_id => l_customer_id);

    opr_api_create_pkg.add_participant(
        i_oper_id               => opr_api_shared_data_pkg.get_operation().id
      , i_msg_type              => opr_api_shared_data_pkg.get_operation().msg_type
      , i_oper_type             => opr_api_shared_data_pkg.get_operation().oper_type
      , i_participant_type      => com_api_const_pkg.PARTICIPANT_INSTITUTION
      , i_client_id_type        => opr_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER
      , i_client_id_value       => l_customer_number
      , i_inst_id               => l_host_inst_id
      , i_network_id            => l_network_id
      , i_customer_id           => l_customer_id
      , i_without_checks        => com_api_const_pkg.TRUE
    );

    l_participant_rec.oper_id          := opr_api_shared_data_pkg.get_operation().id;
    l_participant_rec.participant_type := com_api_const_pkg.PARTICIPANT_INSTITUTION;
    l_participant_rec.client_id_type   := opr_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER;
    l_participant_rec.client_id_value  := l_customer_number;
    l_participant_rec.inst_id          := l_host_inst_id;
    l_participant_rec.network_id       := l_network_id;
    l_participant_rec.customer_id      := l_customer_id;

    opr_api_shared_data_pkg.set_participant(l_participant_rec);

    trc_log_pkg.debug(
        i_text          => 'Added participant with parameters: [#1], [#2], [#3], [#4], [#5]'
        , i_env_param1  => l_participant_rec.participant_type
        , i_env_param2  => l_participant_rec.client_id_type
        , i_env_param3  => l_customer_number
        , i_env_param4  => l_participant_rec.inst_id
        , i_env_param5  => l_participant_rec.network_id
        , i_env_param6  => l_participant_rec.customer_id
    );

exception
    when others then
        opr_api_shared_data_pkg.rollback_process (
            i_id       => opr_api_shared_data_pkg.get_operation().id
          , i_status   => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason   => aut_api_const_pkg.AUTH_REASON_NO_SELECT_ACCT
        );
end;

procedure calculate_fee_turnover is

    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    l_fee_type                      com_api_type_pkg.t_name;
    l_limit_type                    com_api_type_pkg.t_name;
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
    l_split_hash                    com_api_type_pkg.t_tiny_id;

    l_forced_processing             com_api_type_pkg.t_boolean;
    l_service_id                    com_api_type_pkg.t_short_id;

    l_amount_for_tier               com_api_type_pkg.t_money;
    l_count_for_tier                com_api_type_pkg.t_long_id;

    l_attr_name                     com_api_type_pkg.t_name;
begin
    l_amount_name := opr_api_shared_data_pkg.get_param_char('BASE_AMOUNT_NAME');

    opr_api_shared_data_pkg.get_amount(
        i_name          => l_amount_name
        , o_amount      => l_amount.amount
        , o_currency    => l_amount.currency
    );

    l_limit_type        := opr_api_shared_data_pkg.get_param_char('LIMIT_TYPE');
    l_fee_type          := opr_api_shared_data_pkg.get_param_char('FEE_TYPE');
    l_entity_type       := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name      := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type        := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_fee_currency_type := opr_api_shared_data_pkg.get_param_char('FEE_CURRENCY_TYPE', com_api_const_pkg.TRUE, fcl_api_const_pkg.FEE_CURRENCY_TYPE_FEE);
    l_forced_processing := opr_api_shared_data_pkg.get_operation().forced_processing;

    l_object_id := opr_api_shared_data_pkg.get_object_id(
        i_entity_type     => l_entity_type
        , i_account_name  => l_account_name
        , i_party_type    => l_party_type
        , o_inst_id       => l_inst_id
    );

    l_split_hash    := opr_api_shared_data_pkg.get_participant(i_participant_type   => l_party_type).split_hash;

    l_product_id := prd_api_product_pkg.get_product_id(
        i_entity_type  => l_entity_type
        , i_object_id  => l_object_id
    );

    l_test_mode := opr_api_shared_data_pkg.get_param_char(
        i_name        => 'ATTR_MISS_TESTMODE'
      , i_mask_error  => com_api_const_pkg.TRUE
      , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
    );

    l_eff_date_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'EFFECTIVE_DATE'
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => null
        );

    if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_eff_date :=
            com_api_sttl_day_pkg.get_open_sttl_date(
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
        if nvl(l_forced_processing, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then

            l_fee_id := prd_api_product_pkg.get_fee_id (
                i_product_id     => l_product_id
                , i_entity_type  => l_entity_type
                , i_object_id    => l_object_id
                , i_fee_type     => l_fee_type
                , i_params       => opr_api_shared_data_pkg.g_params
                , i_eff_date     => l_eff_date
                , i_split_hash   => l_split_hash
            );

        else
            select attr_name
              into l_attr_name
              from prd_attribute
             where object_type = l_fee_type;

            l_service_id :=
                prd_api_service_pkg.get_active_service_id(
                    i_entity_type => l_entity_type
                  , i_object_id   => l_object_id
                  , i_attr_name   => l_attr_name
                  , i_split_hash  => l_split_hash
                  , i_eff_date    => l_eff_date
                  , i_last_active => com_api_const_pkg.TRUE
                );

            l_fee_id :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id   => l_product_id
                  , i_entity_type  => l_entity_type
                  , i_object_id    => l_object_id
                  , i_fee_type     => l_fee_type
                  , i_params       => opr_api_shared_data_pkg.g_params
                  , i_service_id   => l_service_id
                  , i_eff_date     => l_eff_date
                );
        end if;

        if l_fee_currency_type = fcl_api_const_pkg.FEE_CURRENCY_TYPE_BASE then
            l_result_amount.currency := l_amount.currency;
        end if;

        begin
            select nvl(prev_count_value, 0)
                 , nvl(prev_sum_value, 0)
              into l_count_for_tier
                 , l_amount_for_tier
              from fcl_limit_counter
             where object_id = l_object_id
               and entity_type = l_entity_type
               and limit_type = l_limit_type;

        exception
            when no_data_found then
                l_count_for_tier    := 0;
                l_amount_for_tier   := 0;
        end;

        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_fee_id
          , i_base_amount       => abs(l_amount.amount)
          , i_base_currency     => l_amount.currency
          , i_entity_type       => l_entity_type
          , i_object_id         => l_object_id
          , io_fee_currency     => l_result_amount.currency
          , o_fee_amount        => l_result_amount.amount
          , i_tier_amount       => l_amount_for_tier
          , i_tier_count        => l_count_for_tier
        );
        l_result_amount.amount := round(l_result_amount.amount);
    exception
        when others then
            if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
               and com_api_error_pkg.get_last_error in ('FEE_NOT_DEFINED', 'NO_APPLICABLE_CONDITION')
               and l_test_mode = fcl_api_const_pkg.ATTR_MISS_ZERO_VALUE
            then
                l_result_amount.amount := 0;
                l_result_amount.currency := com_api_const_pkg.UNDEFINED_CURRENCY;
            else
                raise;
            end if;
    end;

    l_result_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'RESULT_AMOUNT_NAME'
          , i_mask_error  => com_api_const_pkg.TRUE
          , i_error_value => l_fee_type
        );

    opr_api_shared_data_pkg.set_amount(
        i_name        => nvl(l_result_amount_name, l_fee_type)
        , i_amount    => l_result_amount.amount
        , i_currency  => l_result_amount.currency
    );
end;

procedure pin_activation is
    l_source_status                 com_api_type_pkg.t_name;
    l_result_status                 com_api_type_pkg.t_name;
begin
    l_source_status := opr_api_shared_data_pkg.get_param_char('INITIAL_CARD_STATUS');
    l_result_status := opr_api_shared_data_pkg.get_param_char('CARD_STATUS');
    trc_log_pkg.debug('l_source_status [' || l_source_status || '], l_result_status [' || l_result_status ||
                      '], pin_presence [' || opr_api_shared_data_pkg.g_auth.pin_presence || ']');

    if opr_api_shared_data_pkg.g_auth.pin_presence = 'PINP0001' then

        iss_api_card_pkg.activate_card (
            i_card_instance_id  => opr_api_shared_data_pkg.g_auth.card_instance_id
            , i_initial_status  => l_source_status
            , i_status          => l_result_status
        );

    end if;
end;

procedure set_fee_object
is
    l_entity_type                   com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_fee_id                        com_api_type_pkg.t_long_id;
    l_limit_id                      com_api_type_pkg.t_long_id;
    l_value_id                      com_api_type_pkg.t_long_id;
    l_attr_name                     com_api_type_pkg.t_name;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_cycle_id                      com_api_type_pkg.t_long_id;
    l_definition_level              com_api_type_pkg.t_dict_value;
    l_fee_type                      com_api_type_pkg.t_dict_value;
    l_cycle_type                    com_api_type_pkg.t_dict_value;
    l_limit_type                    com_api_type_pkg.t_dict_value;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
    l_seqnum                        com_api_type_pkg.t_seqnum;
    l_cycle_type_set                com_api_type_pkg.t_dict_value;
    l_cycle_set_prev_date           date;
    l_cycle_set_end_date            date;
begin
    l_entity_type      := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name     := opr_api_shared_data_pkg.get_param_char(i_name => 'ACCOUNT_NAME', i_mask_error => com_api_const_pkg.TRUE);
    l_party_type       := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_fee_type         := opr_api_shared_data_pkg.get_param_char('FEE_TYPE');
    l_cycle_type_set   := opr_api_shared_data_pkg.get_param_char(i_name => 'CYCLE_TYPE', i_mask_error => com_api_const_pkg.TRUE);
    begin
        select cycle_type
             , limit_type
          into l_cycle_type
             , l_limit_type
          from fcl_fee_type
         where fee_type = l_fee_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'FEE_TYPE_NOT_FOUND'
              , i_env_param1  => l_fee_type
            );
    end;

    l_object_id :=
        opr_api_shared_data_pkg.get_object_id(
            io_entity_type  => l_entity_type
          , i_account_name  => l_account_name
          , i_party_type    => l_party_type
          , o_inst_id       => l_inst_id
        );

    select a.attr_name
         , b.service_id
         , d.product_id
         , a.definition_level
      into l_attr_name
         , l_service_id
         , l_product_id
         , l_definition_level
      from prd_attribute a
         , prd_service_object b
         , prd_service c
         , prd_contract d
     where a.object_type = l_fee_type
       and a.service_type_id = c.service_type_id
       and c.id = b.service_id
       and b.entity_type = l_entity_type
       and b.object_id = l_object_id
       and b.status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
       and b.contract_id = d.id;

    l_eff_date_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'EFFECTIVE_DATE'
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => null
        );

    if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_eff_date :=
            com_api_sttl_day_pkg.get_open_sttl_date(
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

    if  l_definition_level = prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_PRODUCT
        and (l_cycle_type is not null or l_limit_type is not null)
    then
        l_fee_id :=
            prd_api_product_pkg.get_fee_id(
                i_product_id     => l_product_id
              , i_entity_type    => l_entity_type
              , i_object_id      => l_object_id
              , i_fee_type       => l_fee_type
              , i_params         => opr_api_shared_data_pkg.g_params
              , i_service_id     => l_service_id
              , i_eff_date       => l_eff_date
          );

        select min(cycle_id)
             , min(limit_id)
          into l_cycle_id
             , l_limit_id
          from fcl_fee_vw
         where id = l_fee_id;
    end if;

    if l_cycle_type_set is not null then
        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type  => l_cycle_type_set
          , i_entity_type => l_entity_type
          , i_object_id   => l_object_id
          , i_add_counter => com_api_const_pkg.FALSE
          , o_prev_date   => l_cycle_set_prev_date
          , o_next_date   => l_cycle_set_end_date
        );

        if nvl(l_cycle_set_end_date, l_eff_date) <= l_eff_date then
            com_api_error_pkg.raise_error(
                i_error      => 'CYCLE_NOT_DEFINED'
              , i_env_param1 => l_cycle_type_set
              , i_env_param2 => l_product_id
              , i_env_param3 => l_object_id
              , i_env_param4 => l_entity_type
              , i_env_param5 => l_eff_date
            );
        end if;

    end if;

    fcl_ui_fee_pkg.add_fee(
        i_fee_type       => l_fee_type
      , i_currency       => opr_api_shared_data_pkg.get_operation().oper_currency
      , i_fee_rate_calc  => fcl_api_const_pkg.FEE_RATE_FIXED_VALUE
      , i_fee_base_calc  => fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT
      , i_limit_id       => l_limit_id
      , i_cycle_id       => l_cycle_id
      , i_inst_id        => l_inst_id
      , o_fee_id         => l_fee_id
      , o_seqnum         => l_seqnum
    );

    fcl_ui_fee_pkg.add_fee_tier(
        i_fee_id          => l_fee_id
      , i_fixed_rate      => opr_api_shared_data_pkg.get_operation().oper_amount
      , i_percent_rate    => null
      , i_min_value       => 0
      , i_max_value       => 0
      , i_length_type     => l_cycle_type
      , i_sum_threshold   => 0
      , i_count_threshold => 0
      , o_fee_tier_id     => l_value_id
      , o_seqnum          => l_seqnum
    );

    l_value_id := null;
    prd_ui_attribute_value_pkg.set_attr_value_fee(
        io_attr_value_id    => l_value_id
      , i_service_id        => l_service_id
      , i_entity_type       => l_entity_type
      , i_object_id         => l_object_id
      , i_attr_name         => l_attr_name
      , i_mod_id            => null
      , i_start_date        => l_eff_date
      , i_end_date          => l_cycle_set_end_date
      , i_fee_id            => l_fee_id
      , i_check_start_date  => com_api_const_pkg.FALSE
    );

exception
    when no_data_found or com_api_error_pkg.e_application_error then
        opr_api_shared_data_pkg.rollback_process (
            i_id => opr_api_shared_data_pkg.get_operation().id
          , i_status => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason => aup_api_const_pkg.RESP_CODE_ERROR
        );
end;

procedure register_card_token is
    l_token             com_api_type_pkg.t_card_number;
    l_auth_id           com_api_type_pkg.t_long_id;
    l_wallet_provider   com_api_type_pkg.t_dict_value;
    l_iss_part          opr_api_type_pkg.t_oper_part_rec;
begin
    l_auth_id := opr_api_shared_data_pkg.get_operation().id;

    select min(decode(tag_id, 8753, tag_value, null))
      into l_token
      from aup_tag_value
     where tag_id in ('8753')
       and auth_id = l_auth_id
       and seq_number = 1;

    if l_token is not null then
        l_wallet_provider :=
            aup_api_tag_pkg.get_tag_value(
                i_auth_id => l_auth_id
              , i_tag_id  => aup_api_const_pkg.TAG_WALLET_PROVIDER
            );

        if l_wallet_provider is not null then
            l_wallet_provider := iss_api_const_pkg.WALLET_PROVIDER_KEY || l_wallet_provider;
        end if;

        l_iss_part := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER);
        iss_api_card_token_pkg.add_token(
            i_token_id          => null
          , i_card_id           => l_iss_part.card_id
          , i_card_instance_id  => nvl(
                                       opr_api_shared_data_pkg.g_auth.card_instance_id
                                     , l_iss_part.card_instance_id
                                   )
          , i_token             => l_token
          , i_split_hash        => null
          , i_init_oper_id      => l_auth_id
          , i_wallet_provider   => l_wallet_provider
        );
    else
        trc_log_pkg.debug(
            i_text          => 'Token not found in operation [#1]'
            , i_env_param1  => l_auth_id
        );
    end if;
end;

procedure split_terminal_revenue is
    l_macros_id             com_api_type_pkg.t_long_id;
    l_bunch_id              com_api_type_pkg.t_long_id;
    l_db_macros_type        com_api_type_pkg.t_tiny_id;
    l_cr_macros_type        com_api_type_pkg.t_tiny_id;
    l_inst_id               com_api_type_pkg.t_tiny_id;
    l_account_name          com_api_type_pkg.t_name;
    l_term_account          acc_api_type_pkg.t_account_rec;
    l_terminal_id           com_api_type_pkg.t_short_id;
    l_cust_account          acc_api_type_pkg.t_account_rec;
    l_amount_name           com_api_type_pkg.t_name;
    l_amount                com_api_type_pkg.t_amount_rec;
    l_fee_amount            com_api_type_pkg.t_money;
    l_fee_amount_cust       com_api_type_pkg.t_money;
    l_fee_amount_term       com_api_type_pkg.t_money;
    l_params                com_api_type_pkg.t_param_tab;
    l_rate_type             com_api_type_pkg.t_dict_value;
    l_conversion_type       com_api_type_pkg.t_dict_value;
    l_fee_type              com_api_type_pkg.t_name;
    l_fee_id                com_api_type_pkg.t_medium_id;
    l_date_name             com_api_type_pkg.t_dict_value;
    l_date                  date;
begin
    l_params      := opr_api_shared_data_pkg.g_params;
    l_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME');
    opr_api_shared_data_pkg.get_amount(
        i_name      => l_amount_name
      , o_amount    => l_amount.amount
      , o_currency  => l_amount.currency
    );
    l_date_name := opr_api_shared_data_pkg.get_param_char('DATE_NAME', com_api_const_pkg.TRUE);
    if l_date_name is not null then
        opr_api_shared_data_pkg.get_date(
            i_name          => l_date_name
          , o_date          => l_date
        );
    end if;

    l_fee_type        := opr_api_shared_data_pkg.get_param_char('FEE_TYPE');
    l_rate_type       := opr_api_shared_data_pkg.get_param_char('RATE_TYPE');
    l_conversion_type := opr_api_shared_data_pkg.get_param_char('CONVERSION_TYPE', com_api_const_pkg.TRUE);
    l_db_macros_type  := opr_api_shared_data_pkg.get_param_num('DEBIT_MACROS_TYPE');
    l_cr_macros_type  := opr_api_shared_data_pkg.get_param_num('CREDIT_MACROS_TYPE');
    l_account_name    := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    opr_api_shared_data_pkg.get_account(
        i_name              => l_account_name
      , o_account_rec       => l_term_account
    );
    l_terminal_id    := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ACQUIRER).terminal_id;
    l_inst_id        := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ACQUIRER).inst_id;

    rul_api_param_pkg.set_param(
        i_name      => 'TERMINAL_ID'
      , i_value     => l_terminal_id
      , io_params   => l_params
    );

    for r in (
        select distinct
               r.customer_id
             , r.account_id
          from acq_revenue_sharing r
         where r.terminal_id = l_terminal_id
           and r.fee_type    = l_fee_type
           and r.inst_id     = l_inst_id
    )
    loop
        rul_api_param_pkg.set_param(
            i_name      => 'CUSTOMER_ID'
          , i_value     => r.customer_id
          , io_params   => l_params
        );

        rul_api_param_pkg.set_param(
            i_name      => 'ACCOUNT_ID'
          , i_value     => r.account_id
          , io_params   => l_params
        );

        acq_api_revenue_sharing_pkg.get_fee_id(
            i_customer_id => r.customer_id
          , i_terminal_id => l_terminal_id
          , i_account_id  => r.account_id
          , i_fee_type    => l_fee_type
          , i_inst_id     => l_inst_id
          , i_params      => l_params
          , i_raise_error => com_api_const_pkg.TRUE
          , o_fee_id      => l_fee_id
          , i_eff_date    => l_date
        );

        if l_fee_id is not null then
            l_fee_amount :=
                round(
                    fcl_api_fee_pkg.get_fee_amount(
                        i_fee_id          => l_fee_id
                      , i_base_amount     => l_amount.amount
                      , io_base_currency  => l_amount.currency
                    )
                );

            if l_fee_amount <> 0 then
                -- convert amount
                if l_amount.currency = l_term_account.currency then
                    l_fee_amount_term := l_fee_amount;
                else
                    l_fee_amount_term :=
                        round(
                            com_api_rate_pkg.convert_amount(
                                i_src_amount      => l_fee_amount
                              , i_src_currency    => l_amount.currency
                              , i_dst_currency    => l_term_account.currency
                              , i_rate_type       => l_rate_type
                              , i_inst_id         => l_inst_id
                              , i_eff_date        => l_date
                              , i_conversion_type => l_conversion_type
                            )
                        );
                end if;

                acc_api_entry_pkg.put_macros(
                    o_macros_id       => l_macros_id
                  , o_bunch_id        => l_bunch_id
                  , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id       => opr_api_shared_data_pkg.get_operation().id
                  , i_macros_type_id  => l_db_macros_type
                  , i_amount          => l_fee_amount_term
                  , i_currency        => l_term_account.currency
                  , i_account_type    => l_term_account.account_type
                  , i_account_id      => l_term_account.account_id
                  , i_posting_date    => l_date
                  , i_param_tab       => l_params
                );

                l_cust_account :=
                    acc_api_account_pkg.get_account(
                        i_account_id     => r.account_id
                      , i_mask_error     => com_api_const_pkg.FALSE
                    );

                -- convert amount
                if l_amount.currency = l_cust_account.currency then
                    l_fee_amount_cust := l_fee_amount;
                else
                    l_fee_amount_cust :=
                        round(
                            com_api_rate_pkg.convert_amount(
                                i_src_amount      => l_fee_amount
                              , i_src_currency    => l_amount.currency
                              , i_dst_currency    => l_cust_account.currency
                              , i_rate_type       => l_rate_type
                              , i_inst_id         => l_inst_id
                              , i_eff_date        => l_date
                              , i_conversion_type => l_conversion_type
                            )
                        );
                end if;

                acc_api_entry_pkg.put_macros(
                    o_macros_id       => l_macros_id
                  , o_bunch_id        => l_bunch_id
                  , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id       => opr_api_shared_data_pkg.get_operation().id
                  , i_macros_type_id  => l_cr_macros_type
                  , i_amount          => l_fee_amount_cust
                  , i_currency        => l_cust_account.currency
                  , i_account_type    => l_cust_account.account_type
                  , i_account_id      => l_cust_account.account_id
                  , i_posting_date    => l_date
                  , i_param_tab       => l_params
                );
            end if;
        end if;
    end loop;

end;

procedure create_tie_fin_message is
l_fin_id                        com_api_type_pkg.t_long_id;
begin
    if opr_api_shared_data_pkg.g_auth.id is not null then
        select (
            select
                id
            from
                tie_fin
            where
                id = opr_api_shared_data_pkg.g_auth.id
        )
        into
            l_fin_id
        from
            dual;

        if l_fin_id is not null then
            trc_log_pkg.debug(
                i_text          => 'Outgoing Tieto message for operation [#1] already present with id [#2]'
                , i_env_param1    => opr_api_shared_data_pkg.g_auth.id
                , i_env_param2    => l_fin_id
            );
        else
            tie_api_fin_pkg.create_from_auth (
                i_auth_rec  => opr_api_shared_data_pkg.g_auth
                , i_oper_rec  => opr_api_shared_data_pkg.g_operation
                , i_iss_part_rec  => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER)
            );
        end if;
    end if;
end create_tie_fin_message;

procedure register_pin_offset is
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_seq_number                    com_api_type_pkg.t_tiny_id;
    l_expir_date                    date;
    l_auth                          aut_api_type_pkg.t_auth_rec;
    l_pin_offset                    com_api_type_pkg.t_cmid;
    l_pvv                           com_api_type_pkg.t_tiny_id;
    l_perso_method                  prs_api_type_pkg.t_perso_method_rec;
    l_perso_method_id               com_api_type_pkg.t_tiny_id;

    procedure get_pin_offset is
        l_length                    com_api_type_pkg.t_tiny_id;
        l_start_pos                 com_api_type_pkg.t_tiny_id := 1;
    begin
        trc_log_pkg.debug(
            i_text => 'register_pin_offset [' || l_auth.addl_data || ']'
        );

        begin
            l_length     := to_number(trim(substr(l_auth.addl_data, l_start_pos, 3)));
            l_start_pos  := l_start_pos + 3;
            l_pin_offset := trim(substr(l_auth.addl_data, l_start_pos, l_length));
        exception
            when com_api_error_pkg.e_invalid_number then
                com_api_error_pkg.raise_error(
                    i_error       => 'ACI_ERROR_WRONG_VALUE'
                  , i_env_param1  => l_start_pos
                  , i_env_param2  => nvl(l_length, 2)
                  , i_env_param3  => l_auth.addl_data
                );
        end;
    end get_pin_offset;
begin
    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');

    l_account_name := opr_api_shared_data_pkg.get_param_char(
                          i_name          => 'ACCOUNT_NAME'
                        , i_mask_error    => com_api_const_pkg.TRUE
                      );

    l_party_type   := opr_api_shared_data_pkg.get_param_char(
                          i_name          => 'PARTY_TYPE'
                        , i_mask_error    => com_api_const_pkg.TRUE
                      );

    l_object_id    := opr_api_shared_data_pkg.get_object_id(
                          i_entity_type   => l_entity_type
                        , i_account_name  => l_account_name
                        , i_party_type    => l_party_type
                        , o_inst_id       => l_inst_id
                      );

    opr_api_shared_data_pkg.load_auth(
        i_id           => opr_api_shared_data_pkg.get_operation().id
      , io_auth        => l_auth
    );

    trc_log_pkg.debug(
        i_text         => 'Going to register pin offset [#1][#2]'
      , i_env_param1   => l_entity_type
      , i_env_param2   => l_object_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    if l_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD) then
        l_seq_number  := opr_api_shared_data_pkg.get_participant(l_party_type).card_seq_number;
        l_expir_date  := opr_api_shared_data_pkg.get_participant(l_party_type).card_expir_date;

        l_object_id   := iss_api_card_instance_pkg.get_card_instance_id (
                             i_card_id      => l_object_id
                           , i_seq_number   => l_seq_number
                           , i_expir_date   => l_expir_date
                           , i_state        => iss_api_const_pkg.CARD_STATE_ACTIVE
                           , i_raise_error  => com_api_const_pkg.TRUE
                         );

        get_pin_offset;

        -- get perso params
        begin
            select perso_method_id
              into l_perso_method_id
              from iss_card_instance
             where id = l_object_id;
        exception
            when no_data_found then
                l_perso_method_id := null;
        end;
        l_perso_method := prs_api_method_pkg.get_perso_method (
            i_inst_id            => l_inst_id
          , i_perso_method_id    => l_perso_method_id
        );
        if l_perso_method.pin_verify_method in (prs_api_const_pkg.PIN_VERIFIC_METHOD_IBM_3624, prs_api_const_pkg.PIN_VERIFIC_METHOD_COMBINED) then
            begin
                iss_api_card_instance_pkg.register_pin_offset (
                    i_card_instance_id  => l_object_id
                  , i_pin_offset        => l_pin_offset
                  , i_pin_block         => null
                  , i_change_id         => opr_api_shared_data_pkg.get_operation().id
                  , i_pvk_index         => null
                );
            exception
                when others then
                    com_api_error_pkg.raise_error (
                        i_error         => 'ERROR_REGISTER_PIN_OFFSET'
                      , i_env_param1    => l_object_id
                      , i_env_param2    => l_seq_number
                      , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_event_id      => opr_api_shared_data_pkg.get_operation().id
                    );
            end;
        else
            l_pvv := to_number(l_pin_offset);

            begin
                iss_api_card_instance_pkg.register_pvv(
                    i_card_instance_id  => l_object_id
                  , i_pvv               => l_pvv
                  , i_pin_block         => null
                  , i_change_id         => opr_api_shared_data_pkg.get_operation().id
                  , i_pvk_index         => null
                );
            exception
                when others then
                    com_api_error_pkg.raise_error(
                        i_error         => 'ERROR_REGISTER_PIN_OFFSET'
                      , i_env_param1    => l_object_id
                      , i_env_param2    => l_seq_number
                      , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_event_id      => opr_api_shared_data_pkg.get_operation().id
                    );
            end;
        end if;

        evt_api_event_pkg.register_event(
            i_event_type   => iss_api_const_pkg.EVENT_PIN_OFFSET_REGISTERED
          , i_eff_date     => opr_api_shared_data_pkg.get_operation().host_date
          , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id    => l_object_id
          , i_inst_id      => l_inst_id
          , i_split_hash   => null
          , i_param_tab    => opr_api_shared_data_pkg.g_params
        );
    end if;
end register_pin_offset;

procedure select_inst_gl_account is
    l_party_type                    com_api_type_pkg.t_dict_value;
    l_account_currency              com_api_type_pkg.t_dict_value;
    l_account_type                  com_api_type_pkg.t_dict_value;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_participant_rec               opr_api_type_pkg.t_oper_part_rec;
begin
    l_party_type   := opr_api_shared_data_pkg.get_param_char(
                          i_name          => 'PARTY_TYPE'
                        , i_mask_error    => com_api_const_pkg.TRUE
                        , i_error_value   => com_api_const_pkg.PARTICIPANT_ISSUER
                      );
    l_party_type       := nvl(l_party_type, com_api_const_pkg.PARTICIPANT_ISSUER);

    l_account_currency := opr_api_shared_data_pkg.get_param_char('ACCOUNT_CURRENCY');
    l_account_type     := opr_api_shared_data_pkg.get_param_char('ACCOUNT_TYPE');

    l_inst_id          := opr_api_shared_data_pkg.get_participant(l_party_type).inst_id;
    l_participant_rec  := opr_api_shared_data_pkg.get_participant(i_participant_type => l_party_type);

    trc_log_pkg.debug(
        i_text          => 'select_gl_account l_party_type [#1], l_account_type [#2], l_account_currency [#3], l_inst_id [#4]'
        , i_env_param1  => l_party_type
        , i_env_param2  => l_account_type
        , i_env_param3  => l_account_currency
        , i_env_param4  => l_inst_id
    );

    begin
        select a.account_number
          into l_account.account_number
          from acc_gl_account_mvw a
         where a.entity_id    = l_inst_id
           and a.entity_type  = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
           and a.account_type = l_account_type
           and a.currency     = l_account_currency;

        trc_log_pkg.debug(
            i_text          => 'Found account [#1]'
            , i_env_param1  => l_account.account_number
        );
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error             => 'ACCOUNT_NOT_FOUND'
              , i_env_param1        => l_inst_id
              , i_env_param2        => l_account_type
              , i_env_param3        => l_account_currency
            );
    end;

    l_account :=
        acc_api_account_pkg.get_account(
            i_account_id        => null
          , i_account_number    => l_account.account_number
          , i_inst_id           => l_inst_id
          , i_mask_error        => com_api_const_pkg.FALSE
        );

    trc_log_pkg.debug(
        i_text          => 'Found account_id [#1]'
        , i_env_param1  => l_account.account_id
    );


    l_oper_id := opr_api_shared_data_pkg.get_operation().id;

    opr_api_shared_data_pkg.set_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , i_account_rec       => l_account
    );

    update opr_participant
       set account_id              = l_account.account_id
         , account_number          = l_account.account_number
     where oper_id                 = l_oper_id
       and participant_type        = l_party_type;

    l_participant_rec.account_number := l_account.account_number;
    l_participant_rec.account_id     := l_account.account_id;
    opr_api_shared_data_pkg.set_participant(l_participant_rec);

end;

procedure attach_mobile_service is
    l_party_type        com_api_type_pkg.t_dict_value := com_api_const_pkg.PARTICIPANT_ISSUER;
    l_card_id           com_api_type_pkg.t_medium_id;
    l_product_id        com_api_type_pkg.t_short_id;
    l_contract_id       com_api_type_pkg.t_medium_id;
    l_service_id        com_api_type_pkg.t_short_id;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_sysdate           date;
begin
    l_sysdate      := com_api_sttl_day_pkg.get_sysdate;
    l_card_id      := opr_api_shared_data_pkg.get_participant(l_party_type).card_id;
    l_inst_id      := opr_api_shared_data_pkg.get_participant(l_party_type).inst_id;

    select c.contract_id
         , cn.product_id
      into l_contract_id
         , l_product_id
      from iss_card c
         , prd_contract cn
     where c.id  = l_card_id
       and cn.id = c.contract_id;

    select min(s.id)
      into l_service_id
      from prd_product_service ps
         , prd_service s
     where ps.product_id = l_product_id
       and ps.service_id = s.id
       and nvl(ps.max_count, 0) > 0
       and s.service_type_id  = iss_api_const_pkg.SERVICE_TYPE_MOBILE_PAYMENT;

    if l_service_id is null then
        com_api_error_pkg.raise_error(
            i_error        => 'SERVICE_NOT_FOUND_ON_PRODUCT'
          , i_env_param1   => iss_api_const_pkg.SERVICE_TYPE_MOBILE_PAYMENT
          , i_env_param2   => l_product_id
        );
    else
        prd_ui_service_pkg.set_service_object (
            i_service_id   => l_service_id
          , i_contract_id  => l_contract_id
          , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id    => l_card_id
          , i_start_date   => l_sysdate
          , i_end_date     => null
          , i_inst_id      => l_inst_id
          , i_params       => opr_api_shared_data_pkg.g_params
        );

        trc_log_pkg.debug(
            i_text        => 'Service object added: l_card_id [#1], l_contract_id [#2], l_service_id [#3]'
          , i_env_param1  => l_card_id
          , i_env_param2  => l_contract_id
          , i_env_param3  => l_service_id
        );

    end if;

end;

procedure detach_mobile_service is
    l_party_type        com_api_type_pkg.t_dict_value := com_api_const_pkg.PARTICIPANT_ISSUER;
    l_card_id           com_api_type_pkg.t_medium_id;
    l_service_id        com_api_type_pkg.t_short_id;
    l_sysdate           date := get_sysdate;
begin
    l_card_id := opr_api_shared_data_pkg.get_participant(l_party_type).card_id;

    begin
        select o.service_id
          into l_service_id
          from prd_service_object o
             , prd_service s
         where o.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
           and o.object_id       = l_card_id
           and o.service_id      = s.id
           and s.service_type_id = iss_api_const_pkg.SERVICE_TYPE_MOBILE_PAYMENT
           and o.status          = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
           and rownum            = 1;

        prd_api_service_pkg.change_service_object (
            i_service_id   => l_service_id
          , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id    => l_card_id
          , i_params       => opr_api_shared_data_pkg.g_params
          , i_status       => prd_api_const_pkg.SERVICE_OBJECT_STATUS_INACTIVE
        );

    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text       => 'PRD_NO_ACTIVE_SERVICE'
              , i_env_param1 => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_env_param2 => l_card_id
              , i_env_param3 => null
              , i_env_param4 => l_sysdate
            );
    end;

end;

procedure remove_cycle_counter is
    l_params                        com_api_type_pkg.t_param_tab;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_cycle_type                    com_api_type_pkg.t_dict_value;
    l_party_type                    com_api_type_pkg.t_name;

begin
    l_params := opr_api_shared_data_pkg.g_params;

    l_account_name := rul_api_param_pkg.get_param_char(
                          i_name     => 'ACCOUNT_NAME'
                        , io_params  => l_params
                      );
    l_entity_type := rul_api_param_pkg.get_param_char(
                         i_name     => 'ENTITY_TYPE'
                       , io_params  => l_params
                     );
    l_cycle_type := rul_api_param_pkg.get_param_char(
                        i_name        => 'CYCLE_TYPE'
                      , io_params     => l_params
                      , i_mask_error  => com_api_const_pkg.TRUE
                    );
    l_party_type := opr_api_shared_data_pkg.get_param_char(
                        i_name  => 'PARTY_TYPE'
                    );

    l_object_id := opr_api_shared_data_pkg.get_object_id(
                       i_entity_type   => l_entity_type
                     , i_account_name  => l_account_name
                     , i_party_type    => l_party_type
                   );

    case l_entity_type
    when iss_api_const_pkg.ENTITY_TYPE_CARD then
        for instance in (
            select id
                 , split_hash
              from iss_card_instance
             where card_id = l_object_id
        ) loop
            fcl_api_cycle_pkg.remove_cycle_counter(
                i_cycle_type   => l_cycle_type
              , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id    => instance.id
              , i_split_hash   => instance.split_hash
            );
        end loop;

    when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        for card in (
            select card_id
                 , split_hash
              from iss_card_instance
             where id = l_object_id
        ) loop
            fcl_api_cycle_pkg.remove_cycle_counter(
                i_cycle_type   => l_cycle_type
              , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id    => card.card_id
              , i_split_hash   => card.split_hash
            );
        end loop;

    when crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        begin
            select entity_type
              into l_entity_type
              from evt_event_type
             where event_type = l_cycle_type;

            if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                select account_id
                  into l_object_id
                  from crd_invoice
                 where id = l_object_id;

            else
                l_entity_type := crd_api_const_pkg.ENTITY_TYPE_INVOICE;
            end if;

        exception
            when no_data_found then
                null;
        end;

    else
        null;
    end case;

    fcl_api_cycle_pkg.remove_cycle_counter(
        i_cycle_type        => l_cycle_type
      , i_entity_type       => l_entity_type
      , i_object_id         => l_object_id
    );

end remove_cycle_counter;

/*
 * Obsolete rule, do not use it since it is based on copying removed collection g_oper_params into g_params.
 */
procedure union_shared_param_tables is
    l_object_id                     com_api_type_pkg.t_long_id;
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_inst_id                       com_api_type_pkg.t_inst_id;
begin
    l_entity_type       := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_party_type        := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_account_name      := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');

    if l_account_name is not null then
        l_object_id :=
            opr_api_shared_data_pkg.get_object_id(
                i_entity_type    => l_entity_type
              , i_account_name => l_account_name
              , i_party_type   => l_party_type
              , o_inst_id      => l_inst_id
            );
    end if;

    if l_object_id is not null then
        rul_api_param_pkg.set_param(
            i_name      => 'OBJECT_ID'
          , i_value     => l_object_id
          , io_params   => opr_api_shared_data_pkg.g_params
        );
    else 
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT) || '.union_shared_param_tables: OBJECT_ID is null'
        );
    end if;
end union_shared_param_tables;

procedure change_account_status is
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_oper_date                     date;
    l_account_id                    com_api_type_pkg.t_medium_id;
    l_party_type                    com_api_type_pkg.t_dict_value;
begin
    l_entity_type := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type  := opr_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_oper_date   := opr_api_shared_data_pkg.get_param_date('OPER_DATE');
    l_party_type  := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_account_id  := opr_api_shared_data_pkg.get_participant(l_party_type).account_id;

    evt_api_status_pkg.change_status(
        i_event_type     => l_event_type
      , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type    => l_entity_type
      , i_object_id      => l_account_id
      , i_reason         => l_event_type
      , i_eff_date       => l_oper_date
      , i_params         => opr_api_shared_data_pkg.g_params
      , i_register_event => com_api_const_pkg.FALSE
    );
end change_account_status;

procedure select_merchant_account_by_pan
is
    l_party_type          com_api_type_pkg.t_dict_value;
    l_card_number         com_api_type_pkg.t_card_number;
    l_merchant_id         com_api_type_pkg.t_short_id;
    l_account             acc_api_type_pkg.t_account_rec;
begin
    l_party_type  := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_card_number := opr_api_shared_data_pkg.get_participant(l_party_type).card_number;

    acq_api_merchant_pkg.get_merchant(
        i_inst_id               => null
      , i_merchant_card_number  => l_card_number
      , o_merchant_id           => l_merchant_id
    );

    trc_log_pkg.debug(
        i_text        => 'Merchant got [#1][#2]'
      , i_env_param1  => iss_api_card_pkg.get_card_mask(l_card_number)
      , i_env_param2  => l_merchant_id
    );

    acq_api_account_scheme_pkg.get_acq_account(
        i_merchant_id    => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ACQUIRER).merchant_id
      , i_terminal_id    => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ACQUIRER).terminal_id
      , i_currency       => opr_api_shared_data_pkg.get_operation().oper_currency
      , i_oper_type      => opr_api_shared_data_pkg.get_operation().oper_type
      , i_reason         => opr_api_shared_data_pkg.get_operation().oper_reason
      , i_sttl_type      => opr_api_shared_data_pkg.get_operation().sttl_type
      , i_terminal_type  => opr_api_shared_data_pkg.get_operation().terminal_type
      , i_oper_sign      => 1
      , i_scheme_id      => opr_api_shared_data_pkg.get_param_char('ACCOUNT_SCHEME_ID')
      , o_account        => l_account
    );

    opr_api_shared_data_pkg.set_account(
        i_name           => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , i_account_rec    => l_account
    );
end select_merchant_account_by_pan;

procedure change_dependent_object_status is
    l_params                        com_api_type_pkg.t_param_tab;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_party_type                    com_api_type_pkg.t_dict_value;
    l_oper_date                     date;
    l_object_id                     com_api_type_pkg.t_medium_id;
    l_dependent_entity_type         com_api_type_pkg.t_dict_value;
    l_dependent_object_id           com_api_type_pkg.t_medium_tab;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
begin
    l_params := opr_api_shared_data_pkg.g_params;

    l_entity_type := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type  := opr_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_party_type  := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_oper_date   := opr_api_shared_data_pkg.get_param_date('OPER_DATE');

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_object_id  := opr_api_shared_data_pkg.get_participant(l_party_type).account_id;
    end if;

    l_split_hash := com_api_hash_pkg.get_split_hash(
                        i_entity_type => l_entity_type
                      , i_object_id   => l_object_id
                      , i_mask_error  => com_api_const_pkg.FALSE
                    );

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_dependent_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE;
        select i.id
          bulk collect into l_dependent_object_id
          from acc_account_object a
             , iss_card           c
             , iss_card_instance  i
         where a.account_id       = l_object_id
           and a.split_hash       = l_split_hash
           and a.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARD
           and c.id               = a.object_id
           and c.id               = i.card_id
           and i.state            = iss_api_const_pkg.CARD_STATE_ACTIVE;
    end if;

    if l_dependent_object_id.count > 0 then
        for rec_id in l_dependent_object_id.first..l_dependent_object_id.last
        loop
            evt_api_status_pkg.change_status(
                i_event_type     => l_event_type
              , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type    => l_dependent_entity_type
              , i_object_id      => l_dependent_object_id(rec_id)
              , i_reason         => l_event_type
              , i_eff_date       => l_oper_date
              , i_params         => l_params
              , i_register_event => com_api_const_pkg.FALSE
            );
        end loop;
    end if;
end change_dependent_object_status;

-- This rule is used for tokenized us-on-us operations, 
-- which came as two operations: them-on-us and us-on-them. 
-- For us-on-them operation is needed to find own merchant also.
procedure get_own_merchant is
    l_merchant         acq_api_type_pkg.t_merchant;
    l_inst_id          com_api_type_pkg.t_inst_id;
    l_merchant_number  com_api_type_pkg.t_merchant_number;
    l_acq_part         opr_api_type_pkg.t_oper_part_rec;
begin
    l_inst_id := opr_api_shared_data_pkg.get_param_num('INST_ID', i_mask_error => com_api_const_pkg.TRUE);
    if l_inst_id is null then
        l_inst_id :=
            opr_api_shared_data_pkg.get_participant(
                i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
            ).inst_id;
    end if;

    l_merchant_number := opr_api_shared_data_pkg.get_operation().merchant_number;

    l_merchant :=
        acq_api_merchant_pkg.get_merchant(
            i_inst_id         => l_inst_id
          , i_merchant_number => l_merchant_number
          , i_mask_error      => com_api_const_pkg.FALSE
        );

    trc_log_pkg.debug(
        i_text          => 'Merchant got [#1][#2]'
      , i_env_param1    => l_merchant_number
      , i_env_param2    => l_merchant.id
    );

    if l_merchant.id is not null then

        l_acq_part := opr_api_shared_data_pkg.get_participant(i_participant_type => com_api_const_pkg.PARTICIPANT_ACQUIRER);
        l_acq_part.merchant_id := l_merchant.id;

        opr_api_shared_data_pkg.set_participant(i_oper_participant => l_acq_part);

        update opr_participant o
           set merchant_id        = l_merchant.id
         where oper_id            = l_acq_part.oper_id
           and o.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER;

    end if;
end get_own_merchant;

procedure update_card_token is
    l_token             com_api_type_pkg.t_card_number;
    l_auth_id           com_api_type_pkg.t_long_id;  
    l_token_id          com_api_type_pkg.t_medium_id;
    l_token_status      com_api_type_pkg.t_dict_value;
begin
  
    l_auth_id      := opr_api_shared_data_pkg.get_operation().id;
    l_token_status := opr_api_shared_data_pkg.get_param_char('TOKEN_STATUS');

    select min(decode(tag_id, 8753, tag_value, null))
      into l_token
      from aup_tag_value
     where tag_id in ('8753')
       and auth_id = l_auth_id;

    if l_token is not null then      
        l_token_id := iss_api_card_token_pkg.get_token_id(l_token);
        
        if l_token_id is not null then        
            iss_api_card_token_pkg.change_token_status(
                i_token_id           => l_token_id
              , i_status             => l_token_status 
              , i_close_sess_file_id => case l_token_status
                                            when iss_api_const_pkg.CARD_TOKEN_STATUS_DEACTIVATED then
                                                opr_api_shared_data_pkg.get_operation().incom_sess_file_id
                                            else
                                                null
                                        end
              , i_init_oper_id => l_auth_id
            );
        else
            trc_log_pkg.debug(
                i_text          => 'Can''t finde id for token [#1]'
              , i_env_param1  => l_token
            );
        end if;
    else
        trc_log_pkg.debug(
            i_text          => 'Token not found in operation [#1]'
          , i_env_param1    => l_auth_id
        );
    end if;  
end update_card_token;
    
procedure update_token_pan is
    l_token             com_api_type_pkg.t_card_number;
    l_auth_id           com_api_type_pkg.t_long_id;  
begin
    l_auth_id := opr_api_shared_data_pkg.get_operation().id;

    select min(decode(tag_id, 8753, tag_value, null))
      into l_token
      from aup_tag_value
     where tag_id in ('8753')
       and auth_id = l_auth_id;  
       
    if l_token is not null then      
              
        iss_api_card_token_pkg.relink_token(
            i_card_instance_id => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).card_instance_id
        );

    else
        trc_log_pkg.debug(
            i_text          => 'Token not found in operation [#1]'
          , i_env_param1    => l_auth_id
        );
    end if;           
end update_token_pan;

procedure check_object_status is
    ARRAY_INVALID_CARD_STATUSES  constant com_api_type_pkg.t_short_id    := 10000104;
    ARRAY_INVALID_CARD_STATES    constant com_api_type_pkg.t_short_id    := 10000105;

    l_entity_type                         com_api_type_pkg.t_name;
    l_is_blocked_card                     com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE;
    l_card_id                             com_api_type_pkg.t_medium_id;
    l_card_status                         com_api_type_pkg.t_dict_value;
    l_card_state                          com_api_type_pkg.t_dict_value;
begin
    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        if g_card_status_loaded is null then
            select ae.element_value
              bulk collect into g_card_status_tab
              from com_array_element ae
             where ae.array_id = ARRAY_INVALID_CARD_STATUSES;

            select ae.element_value
              bulk collect into g_card_state_tab
              from com_array_element ae
             where ae.array_id = ARRAY_INVALID_CARD_STATES;

            g_card_status_loaded := com_api_const_pkg.TRUE;
        end if;

        l_card_id := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).card_id;

        if l_card_id is not null then
            l_card_status := opr_api_shared_data_pkg.get_param_char('LAST_CARD_STATUS');
            l_card_state  := opr_api_shared_data_pkg.get_param_char('LAST_CARD_STATE');

            if l_card_status    is not null
               and l_card_state is not null
            then
                for i in 1 .. g_card_status_tab.count loop
                    if l_card_status = g_card_status_tab(i) then
                        l_is_blocked_card := com_api_type_pkg.TRUE;
                        exit;
                    end if;
                end loop;

                if l_is_blocked_card = com_api_type_pkg.FALSE then
                    for i in 1 .. g_card_state_tab.count loop
                        if l_card_state = g_card_state_tab(i) then
                            l_is_blocked_card := com_api_type_pkg.TRUE;
                            exit;
                        end if;
                    end loop;
                end if;
            else
                trc_log_pkg.debug(
                    i_text        => 'check_object_status: Last card instance is not found or Invalid card status. Card id [#1], Status [#2], State [#3]'
                  , i_env_param1  => l_card_id
                  , i_env_param2  => l_card_status
                  , i_env_param3  => l_card_state
                );
            end if;

            if l_is_blocked_card  = com_api_type_pkg.TRUE
               or l_card_status  is null
               or l_card_state   is null
            then
                opr_api_shared_data_pkg.rollback_process (
                    i_id         => opr_api_shared_data_pkg.g_auth.id
                  , i_status     => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                  , i_reason     => aup_api_const_pkg.RESP_CODE_WRONG_CARD_STATE
                );

                com_api_error_pkg.raise_error(
                    i_error      => 'OPERATION_HAS_INVALID_CARD_STATUS'
                  , i_env_param1 => opr_api_shared_data_pkg.g_auth.id
                  , i_env_param2 => opr_api_shared_data_pkg.g_auth.card_id
                  , i_env_param3 => l_card_status
                  , i_env_param4 => l_card_state
                );
            end if;
        end if;
    end if;

end check_object_status;

procedure register_oper_in_order is
    l_eff_date                      date;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_order_id                      com_api_type_pkg.t_long_id;
    l_template_id                   com_api_type_pkg.t_long_id;
    l_party_type                    com_api_type_pkg.t_dict_value;
    l_participant                   opr_api_type_pkg.t_oper_part_rec;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_account_name                  com_api_type_pkg.t_dict_value;
    l_purpose_id                    com_api_type_pkg.t_short_id;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_short_id;
    l_customer_id                   com_api_type_pkg.t_medium_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_amount_rec                    com_api_type_pkg.t_amount_rec;
    l_param_tab                     com_api_type_pkg.t_param_tab;
begin
    l_purpose_id    :=
        opr_api_shared_data_pkg.get_param_num(
            i_name          => 'PAYMENT_PURPOSE'
          , i_mask_error    => com_api_const_pkg.FALSE
        );

    l_party_type    :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'PARTY_TYPE'
          , i_mask_error    => com_api_const_pkg.FALSE
        );

    l_eff_date_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'EFFECTIVE_DATE'
          , i_mask_error    => com_api_const_pkg.FALSE
        );

    l_entity_type   :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'ENTITY_TYPE'
          , i_mask_error    => com_api_const_pkg.FALSE
        );

    l_account_name  :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'ACCOUNT_NAME'
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => null
        );

    opr_api_shared_data_pkg.get_date(
        i_name     => l_eff_date_name
      , o_date     => l_eff_date
    );

    l_participant   :=
        opr_api_shared_data_pkg.get_participant(
            i_participant_type => l_party_type
        );

    l_object_id     :=
        opr_api_shared_data_pkg.get_object_id(
            i_entity_type   => l_entity_type
          , i_account_name  => l_account_name
          , i_party_type    => l_party_type
          , o_inst_id       => l_inst_id
        );

    l_customer_id   :=
        coalesce(
            l_participant.customer_id
          , prd_api_customer_pkg.get_customer_id(
                i_entity_type    => l_entity_type
              , i_object_id      => l_object_id
              , i_inst_id        => l_inst_id
              , i_mask_error     => com_api_const_pkg.FALSE
            )
        );

    l_split_hash    :=
        com_api_hash_pkg.get_split_hash(
            i_entity_type   => l_entity_type
          , i_object_id     => l_object_id
        );

    begin
      select t.id
        into l_template_id
        from pmo_order t
           , pmo_schedule s
       where t.customer_id  = l_customer_id
         and s.entity_type  = l_entity_type
         and s.object_id    = l_object_id
         and s.order_id     = t.id
         and t.purpose_id   = l_purpose_id
         and t.templ_status in (
                                 pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD
                               , pmo_api_const_pkg.PAYMENT_TMPL_STATUS_SUSP
                               )
         and t.is_template  = com_api_const_pkg.TRUE
         and rownum = 1;

    exception
        when no_data_found then
            null;
    end;

    if l_template_id is null then
        trc_log_pkg.debug(
            i_text  => 'Template not found merchant_id = ' || l_participant.merchant_id || ', customer_id = ' || l_participant.customer_id
        );

        return;
    end if;

    -- find/create payment order
    begin

      select t.id
        into l_order_id
        from pmo_order t
       where t.status       = pmo_api_const_pkg.PMO_STATUS_PREPARATION
         and t.event_date   = l_eff_date
         and t.template_id  = l_template_id;

        trc_log_pkg.debug(
            i_text  => 'Found order order_id = ' || l_order_id
        );

    exception
        when no_data_found then

            l_amount_rec.amount     := null;
            l_amount_rec.currency   := opr_api_shared_data_pkg.get_operation().oper_currency;

            pmo_api_order_pkg.add_order_with_params(
                io_payment_order_id     => l_order_id
              , i_entity_type           => l_entity_type
              , i_object_id             => l_object_id
              , i_customer_id           => l_customer_id
              , i_split_hash            => l_split_hash
              , i_purpose_id            => l_purpose_id
              , i_template_id           => l_template_id
              , i_amount_rec            => l_amount_rec
              , i_eff_date              => l_eff_date
              , i_order_status          => pmo_api_const_pkg.PMO_STATUS_PREPARATION
              , i_inst_id               => l_participant.inst_id
              , i_attempt_count         => 0
              , i_payment_order_number  => null
              , i_expiration_date       => null
              , i_register_event        => com_api_const_pkg.TRUE
              , i_is_prepared_order     => com_api_type_pkg.TRUE
              , i_param_tab             => l_param_tab
            );

            trc_log_pkg.debug(
                i_text  => 'Created order order_id = ' || l_order_id
            );
    end;

    -- link operation
    pmo_api_order_pkg.add_order_detail(
        i_order_id       => l_order_id
        , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );
end register_oper_in_order;

procedure select_rate_type is
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_product_id                    com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_party_type                    com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_merchant_rate                 com_api_type_pkg.t_dict_value;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_eff_date                      date;
begin

    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_party_type   := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');

    if l_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
        and l_party_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then

        l_object_id :=
            opr_api_shared_data_pkg.get_object_id(
                io_entity_type => l_entity_type
              , i_account_name => l_account_name
              , i_party_type   => l_party_type
              , o_inst_id      => l_inst_id
            );

        l_eff_date_name :=
            opr_api_shared_data_pkg.get_param_char(
                i_name        => 'EFFECTIVE_DATE'
              , i_mask_error  => com_api_const_pkg.TRUE
              , i_error_value => null
            );

        if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
            l_eff_date :=
                com_api_sttl_day_pkg.get_open_sttl_date(
                    i_inst_id => l_inst_id
                );
        elsif l_eff_date_name is not null then
            opr_api_shared_data_pkg.get_date(
                i_name        => l_eff_date_name
              , o_date        => l_eff_date
            );
        else
            l_eff_date := com_api_sttl_day_pkg.get_sysdate;
        end if;

        l_product_id :=
            prd_api_product_pkg.get_product_id(
                i_entity_type  => l_entity_type
              , i_object_id    => l_object_id
            );

        l_split_hash :=
            com_api_hash_pkg.get_split_hash(
                i_entity_type  => l_entity_type
              , i_object_id    => l_object_id
          );

        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type  => l_entity_type
              , i_object_id    => l_object_id
              , i_attr_name    => 'MERCHANT_EXCHANGE_RATE_TYPE'
              , i_eff_date     => l_eff_date
            );

        if l_service_id is not null then
            l_merchant_rate := prd_api_product_pkg.get_attr_value_char(
                 i_product_id  => l_product_id
               , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               , i_object_id   => l_object_id
               , i_attr_name   => 'MERCHANT_EXCHANGE_RATE_TYPE'
               , i_params      => opr_api_shared_data_pkg.g_params
               , i_service_id  => l_service_id
               , i_eff_date    => l_eff_date
               , i_split_hash  => l_split_hash
               , i_inst_id     => l_inst_id
            );

            if l_merchant_rate is not null then
                 opr_api_shared_data_pkg.set_param(
                      i_name   => 'RESULT_RATE_TYPE'
                    , i_value  => l_merchant_rate
                    );
            end if;
        end if;
    end if;

end select_rate_type;

procedure prepare_document
is
    l_party_type                    com_api_type_pkg.t_dict_value;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_resend                        com_api_type_pkg.t_boolean;
    l_document_type                 com_api_type_pkg.t_dict_value;
    l_start_date                    date;
    l_end_date                      date;

    l_auth_id                       com_api_type_pkg.t_long_id;
    l_document_id                   com_api_type_pkg.t_long_id;
    l_object_id                     com_api_type_pkg.t_long_id;

    l_seqnum                        com_api_type_pkg.t_seqnum;
    l_inst_id                       com_api_type_pkg.t_inst_id;

begin
    l_party_type     := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_entity_type    := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type     := opr_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_resend         := nvl(opr_api_shared_data_pkg.get_param_num('RESEND'), com_api_const_pkg.FALSE);
    l_document_type  := opr_api_shared_data_pkg.get_param_char('DOCUMENT_TYPE');

    l_object_id      := opr_api_shared_data_pkg.get_object_id(
                            i_entity_type   => l_entity_type
                          , i_account_name  => null
                          , i_party_type    => l_party_type
                          , o_inst_id       => l_inst_id
                        );

    l_auth_id        := opr_api_shared_data_pkg.get_operation().id;

    l_start_date     := to_date(aup_api_tag_pkg.get_tag_value(
                                    i_auth_id        => l_auth_id
                                  , i_tag_reference  => 'DF8E37'
                                )
                          , prs_api_const_pkg.ISSUE_DATE_FORMAT
                        );

    l_end_date       := to_date(aup_api_tag_pkg.get_tag_value(
                                    i_auth_id        => l_auth_id
                                  , i_tag_reference  => 'DF8E38'
                                )
                          , prs_api_const_pkg.ISSUE_DATE_FORMAT
                        );

    if l_start_date is null then
        l_start_date := trunc(nvl(l_start_date, com_api_sttl_day_pkg.get_sysdate));
    end if;

    if l_end_date is null then
        l_end_date   := nvl(trunc(l_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    end if;

    if l_resend = com_api_const_pkg.TRUE then
        select max(d.id)
          into l_document_id
          from rpt_document d
         where d.entity_type   = l_entity_type
           and d.object_id     = l_object_id
           and d.document_type = l_document_type
           and d.status        = rpt_api_const_pkg.DOCUMENT_STATUS_CREATED
           and d.start_date    = l_start_date
           and d.end_date      = l_end_date;
    end if;

    if (l_document_id is null and l_resend = com_api_const_pkg.TRUE) or l_resend = com_api_const_pkg.FALSE then
        rpt_api_document_pkg.add_document(
            io_document_id   => l_document_id
          , o_seqnum         => l_seqnum
          , i_content_type   => rpt_api_const_pkg.CONTENT_TYPE_PRINT_FORM
          , i_document_type  => l_document_type
          , i_entity_type    => l_entity_type
          , i_object_id      => l_object_id
          , i_inst_id        => l_inst_id
          , i_start_date     => l_start_date
          , i_end_date       => l_end_date
          , i_status         => rpt_api_const_pkg.DOCUMENT_STATUS_PREPARATION
        );
    end if;

    evt_api_event_pkg.register_event(
        i_event_type   => l_event_type
      , i_eff_date     => opr_api_shared_data_pkg.get_operation().host_date
      , i_entity_type  => rpt_api_const_pkg.ENTITY_TYPE_DOCUMENT
      , i_object_id    => l_document_id
      , i_inst_id      => l_inst_id
      , i_split_hash   => null
      , i_param_tab    => opr_api_shared_data_pkg.g_params
    );

end prepare_document;

end opr_api_rule_proc_pkg;
/
