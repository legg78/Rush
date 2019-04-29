create or replace package body cst_lvp_evt_rule_proc_pkg is

/*********************************************************
 *  API for event rule processing for Lienviet bank <br />
 *  Created by ChauHuynh(huynh@bpcbt.com) at 26.09.2017 <br />
 *  Module: CST_LVP_EVT_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

procedure change_card_status is
    l_params                        com_api_type_pkg.t_param_tab;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_event_date                    date;
    l_inst_id                       com_api_type_pkg.t_inst_id;

begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := rul_api_param_pkg.get_param_num ('OBJECT_ID',   l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_split_hash  := rul_api_param_pkg.get_param_num ('SPLIT_HASH',  l_params);
    l_event_type  := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_const_pkg.TRUE);
    l_event_date  := get_sysdate;

    trc_log_pkg.debug(
        i_text => 'cst_lvp_evt_rule_proc_pkg.change_card_status: l_entity_type=' || l_entity_type || ', l_event_type=' || l_event_type
    );    

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        for rec in (
            select i.id
              from acc_account_object o
                 , iss_card c
                 , iss_card_instance i
             where o.account_id   = l_object_id
               and o.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
               and o.object_id = c.id
               and c.id = i.card_id
               and i.state = iss_api_const_pkg.CARD_STATE_ACTIVE
        )loop
            evt_api_status_pkg.change_status(
                i_event_type     => l_event_type
              , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id      => rec.id
              , i_inst_id        => l_inst_id
              , i_reason         => null
              , i_eff_date       => l_event_date
              , i_params         => l_params
              , i_register_event => com_api_const_pkg.TRUE
            );
        end loop;
    end if;

end change_card_status;

procedure set_debt_aging_level is
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_params                        com_api_type_pkg.t_param_tab;
    l_debt_level                    com_api_type_pkg.t_tiny_id;
    l_object_id                     com_api_type_pkg.t_long_id;
begin
    l_event_type  := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

    trc_log_pkg.debug(
        i_text => ' account :' || l_object_id 
    );

    case l_event_type
        when crd_api_const_pkg.OVERDUE_DATE_CYCLE_TYPE
        then rul_api_param_pkg.set_param(
                 i_name      => 'DEBT_LEVEL'
               , i_value     => 1
               , io_params   => l_params
             );
        when crd_api_const_pkg.ZERO_PERIOD_CYCLE
        then rul_api_param_pkg.set_param(
                 i_name      => 'DEBT_LEVEL'
               , i_value     => 2
               , io_params   => l_params
             );
        when crd_api_const_pkg.AGING_3_EVENT -- EVNT1013
        then rul_api_param_pkg.set_param(
                 i_name      => 'DEBT_LEVEL'
               , i_value     => 3
               , io_params   => l_params
             );
        when crd_api_const_pkg.AGING_6_EVENT -- EVNT1023
        then rul_api_param_pkg.set_param(
                 i_name      => 'DEBT_LEVEL'
               , i_value     => 4
               , io_params   => l_params
             );
        when crd_api_const_pkg.AGING_12_EVENT -- EVNT1029
        then rul_api_param_pkg.set_param(
                 i_name      => 'DEBT_LEVEL'
               , i_value     => 5
               , io_params   => l_params
             );
        else
            l_debt_level := cst_lvp_com_pkg.get_debt_level(i_account_id => l_object_id);
            trc_log_pkg.debug(
                i_text => 'Get original debt level account :' || l_object_id || ' debt level:' || l_debt_level
            );
            rul_api_param_pkg.set_param(
                i_name      => 'DEBT_LEVEL'
              , i_value     => l_debt_level
              , io_params   => l_params
            );
    end case;

end set_debt_aging_level;


procedure get_abs_acct_balance_amount
is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_account_balance_amount: ';
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_balance_type                  com_api_type_pkg.t_name;
    l_need_lock                     com_api_type_pkg.t_boolean;
    l_balances                      com_api_type_pkg.t_amount_by_name_tab;
    l_balance_amount                com_api_type_pkg.t_money;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_account_id                    com_api_type_pkg.t_medium_id;
    l_result_amount_name            com_api_type_pkg.t_name;
begin
    acc_api_entry_pkg.flush_job;

    l_result_amount_name := evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');
    l_balance_type       := evt_api_shared_data_pkg.get_param_char('BALANCE_TYPE');
    l_need_lock :=
        nvl(
            evt_api_shared_data_pkg.get_param_num(
                i_name          => 'NEED_LOCK'
              , i_mask_error    => com_api_const_pkg.TRUE
              , i_error_value   => com_api_const_pkg.FALSE
            )
          , com_api_const_pkg.FALSE
        );

    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_entity_type [#1], l_object_id [#2]'
      , i_env_param1 => l_entity_type
      , i_env_param2 => l_object_id
    );

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        select max(a.account_id)
          into l_account_id
          from acc_account_object a
             , iss_card_instance  i
         where a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and a.object_id   = i.card_id
           and i.id          = l_object_id;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'found by acc_account_object l_account_id [#1]'
          , i_env_param1 => l_account_id
        );

    elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_account_id := l_object_id;

    elsif l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        select account_id
          into l_account_id
          from crd_invoice
         where id = l_object_id;
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'found by invoice: l_account_id [#1]'
          , i_env_param1 => l_account_id
        );

    else
        select max(account_id)
          into l_account_id
          from acc_account_object
         where entity_type = l_entity_type
           and object_id   = l_object_id;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'found by acc_account_object l_account_id [#1]'
          , i_env_param1 => l_account_id
        );
    end if;

    l_account := acc_api_account_pkg.get_account(
                     i_account_id => l_account_id
                   , i_mask_error => com_api_const_pkg.FALSE
                 );

    acc_api_balance_pkg.get_account_balances(
        i_account_id      => l_account.account_id
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

    evt_api_shared_data_pkg.set_amount(
        i_name      => nvl(evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME'), l_balance_type)
      , i_amount    => abs(l_amount.amount)
      , i_currency  => l_amount.currency
    );
end get_abs_acct_balance_amount;


procedure get_available_balance_amount
is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_available_balance_amount: ';
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_balance_amount                com_api_type_pkg.t_money;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_account_id                    com_api_type_pkg.t_medium_id;
    l_result_amount_name            com_api_type_pkg.t_name;
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

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        select max(a.account_id)
          into l_account_id
          from acc_account_object a
             , iss_card_instance  i
         where a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and a.object_id   = i.card_id
           and i.id          = l_object_id;
           
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'found by acc_account_object l_account_id [#1]'
          , i_env_param1 => l_account_id
        );           
    elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_account_id := l_object_id;
        
    elsif l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        select account_id
          into l_account_id
          from crd_invoice
         where id = l_object_id;
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'found by invoice: l_account_id [#1]'
          , i_env_param1 => l_account_id
        ); 
    else
        select max(account_id)
          into l_account_id
          from acc_account_object
         where entity_type = l_entity_type
           and object_id   = l_object_id;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'found by acc_account_object l_account_id [#1]'
          , i_env_param1 => l_account_id
        );
    end if;

    l_amount :=
        acc_api_balance_pkg.get_aval_balance_amount(
            i_account_id      => l_account_id
        );

    evt_api_shared_data_pkg.set_amount(
        i_name      => evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME')
      , i_amount    => l_amount.amount
      , i_currency  => l_amount.currency
    );
end get_available_balance_amount;


procedure get_original_debt_level
is
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_params                        com_api_type_pkg.t_param_tab;
    
    l_last_invoice_id               com_api_type_pkg.t_medium_id;
    l_invoice_aging                 com_api_type_pkg.t_tiny_id;
    l_debt_level                    com_api_type_pkg.t_tiny_id;
    l_due_date                      date;
begin
    l_event_type  := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

    l_debt_level := cst_lvp_com_pkg.get_debt_level(i_account_id => l_object_id);

    trc_log_pkg.debug('Debt level :' || l_debt_level);

    if (l_event_type = crd_api_const_pkg.TAD_REPAYMENT_EVENT) or
       (l_event_type = crd_api_const_pkg.MAD_REPAYMENT_EVENT and l_debt_level <= 2)
    then
        rul_api_param_pkg.set_param(
            i_name      => 'DEBT_LEVEL'
          , i_value     => l_debt_level
          , io_params   => l_params
        );
    end if;

end get_original_debt_level;


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

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        select max(a.account_id)
          into l_account_id
          from acc_account_object a
             , iss_card_instance  i
         where a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and a.object_id   = i.card_id
           and i.id          = l_object_id;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'found by acc_account_object l_account_id [#1]'
          , i_env_param1 => l_account_id
        );

    elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_account_id := l_object_id;

    elsif l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        l_account_id :=
            crd_invoice_pkg.get_invoice(
                i_invoice_id  => l_object_id
              , i_mask_error  => com_api_const_pkg.TRUE
            ).account_id;
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'found by invoice: l_account_id [#1]'
          , i_env_param1 => l_account_id
        );

    else
        select max(account_id)
          into l_account_id
          from acc_account_object
         where entity_type = l_entity_type
           and object_id   = l_object_id;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'found by acc_account_object l_account_id [#1]'
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

procedure get_invoice_interest_amount
is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_invoice_interest_amount: ';
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_invoice                       crd_api_type_pkg.t_invoice_rec;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_amount                        com_api_type_pkg.t_money;
    l_result_amount_name            com_api_type_pkg.t_name;

begin

    l_result_amount_name := evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_entity_type [#1], l_object_id [#2]'
      , i_env_param1 => l_entity_type
      , i_env_param2 => l_object_id
    );

    if l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then

        l_invoice :=
            crd_invoice_pkg.get_invoice(
                i_invoice_id  => l_object_id
              , i_mask_error  => com_api_const_pkg.FALSE
            );

        l_account :=
            acc_api_account_pkg.get_account(
                i_account_id => l_invoice.account_id
              , i_mask_error => com_api_const_pkg.FALSE
            );

    else
        com_api_error_pkg.raise_error(
            i_error       => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1  => l_entity_type
        );
    end if;

    select interest_amount
      into l_amount
      from crd_invoice
     where id = l_invoice.id;

    evt_api_shared_data_pkg.set_amount(
        i_name      => l_result_amount_name
      , i_amount    => l_amount
      , i_currency  => l_account.currency
    );

end get_invoice_interest_amount;

procedure check_direct_debit_paid is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.check_direct_debit_paid: ';
    l_params                        com_api_type_pkg.t_param_tab;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_account_id                    com_api_type_pkg.t_medium_id;
    l_order_id                      com_api_type_pkg.t_long_id;
    l_sysdate                       date;
begin
    l_params      := evt_api_shared_data_pkg.g_params;
    l_sysdate     := com_api_sttl_day_pkg.get_sysdate;

    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_entity_type [#1], l_object_id [#2]'
      , i_env_param1 => l_entity_type
      , i_env_param2 => l_object_id
    );

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_account_id := l_object_id;
    else
        select max(account_id)
          into l_account_id
          from acc_account_object
         where entity_type = l_entity_type
           and object_id   = l_object_id;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'found by acc_account_object l_account_id [#1]'
          , i_env_param1 => l_account_id
        );
    end if;
    
    begin
        select o.id
          into l_order_id
          from (
                select o.id
                  from pmo_order o
                 where o.status       = pmo_api_const_pkg.PMO_STATUS_WAIT_CONFIRM
                   and o.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                   and o.object_id    = l_account_id
                   and o.amount       > 0
                 order by o.event_date desc
               ) o
         where rownum = 1;
    exception
        when no_data_found then
            l_order_id := null;
    end;
    
    if l_order_id is not null then
        for eo in (select a.id
                     from evt_event_object a
                        , pmo_order        o
                    where decode(a.status, 'EVST0001', a.procedure_name, null) = 'CST_LVP_PRC_OUTGOING_PKG.PROCESS_EXPORT_CBS'
                      and o.id              = l_order_id
                      and a.object_id       = o.id
                      and a.entity_type     = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                      and a.eff_date       <= l_sysdate)
        loop
            evt_api_event_pkg.process_event_object(
                i_event_object_id       => eo.id
            );
        end loop;
        pmo_api_order_pkg.set_order_status(
            i_order_id              => l_order_id
          , i_status                => cst_lvp_const_pkg.PMO_STATUS_NOT_PAID
        );
    end if;

end check_direct_debit_paid;

procedure set_acc_debt_level as
begin
    cst_lvp_debt_level_pkg.set_acc_debt_level(
        i_account_id    => evt_api_shared_data_pkg.get_param_num('OBJECT_ID')
      , i_debt_level    => evt_api_shared_data_pkg.get_param_char('CST_LVP_DEBT_LEVEL')
      , i_eff_date      => evt_api_shared_data_pkg.get_param_date('EVENT_DATE')
      , i_reason_event  => evt_api_shared_data_pkg.get_param_char('EVENT_TYPE')
      , i_force         => evt_api_shared_data_pkg.get_param_num(
                               i_name       => 'CST_LVP_FORCE'
                             , i_mask_error => com_api_const_pkg.TRUE
                           )
    );
end;

procedure incr_acc_debt_level as
begin
    cst_lvp_debt_level_pkg.incr_acc_debt_level(
        i_account_id    => evt_api_shared_data_pkg.get_param_num('OBJECT_ID')
      , i_eff_date      => evt_api_shared_data_pkg.get_param_date('EVENT_DATE')
      , i_reason_event  => evt_api_shared_data_pkg.get_param_char('EVENT_TYPE')
    );
end;

procedure decr_acc_debt_level as
begin
    cst_lvp_debt_level_pkg.decr_acc_debt_level(
        i_account_id    => evt_api_shared_data_pkg.get_param_num('OBJECT_ID')
      , i_eff_date      => evt_api_shared_data_pkg.get_param_date('EVENT_DATE')
      , i_reason_event  => evt_api_shared_data_pkg.get_param_char('EVENT_TYPE')
    );
end;

end cst_lvp_evt_rule_proc_pkg;
/
