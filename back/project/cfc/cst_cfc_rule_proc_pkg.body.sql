create or replace package body cst_cfc_rule_proc_pkg as
/*********************************************************
*  CFC custom API of the operation rules <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 14.11.2017 <br />
*  Module: CST_CFC_RULE_PROC_PKG <br />
*  @headcom
**********************************************************/

procedure save_additional_auth_tags is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.save_additional_auth_tags: ';

    l_operation_rec     opr_api_type_pkg.t_oper_rec;
    l_party_type        com_api_type_pkg.t_dict_value;
    l_party_iss_rec     opr_api_type_pkg.t_oper_part_rec;
    l_party_dst_rec     opr_api_type_pkg.t_oper_part_rec;

    l_tag_idx           com_api_type_pkg.t_count        := 0;
    l_tags_tab          aup_api_type_pkg.t_aup_tag_tab;
    l_customer_number   com_api_type_pkg.t_name;

    l_oper_type         com_api_type_pkg.t_dict_value;
    l_id_type           com_api_type_pkg.t_dict_value;
    l_id_number         com_api_type_pkg.t_name;
    l_customer_name     com_api_type_pkg.t_text;
    l_customer_birthday com_api_type_pkg.t_name;
    l_dst_customer_name com_api_type_pkg.t_text;

    l_auth_data         aut_api_type_pkg.t_auth_rec;
    l_iss_customer_id   com_api_type_pkg.t_medium_id;
    l_dst_customer_id   com_api_type_pkg.t_medium_id;
begin

    l_operation_rec := opr_api_shared_data_pkg.get_operation;
    l_oper_type     := opr_api_shared_data_pkg.get_param_char(
                           i_name => 'OPER_TYPE'
                       );

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - oper_id [#1] oper_type [#2] oper_type_param [#3]'
      , i_env_param1 => l_operation_rec.id
      , i_env_param2 => l_operation_rec.oper_type
      , i_env_param3 => l_oper_type
    );

    if l_operation_rec.oper_type = l_oper_type then
        l_auth_data:=
            aut_api_auth_pkg.get_auth(
                i_id           => l_operation_rec.id
              , i_mask_error   => com_api_const_pkg.TRUE
            );
        if l_auth_data.id is null then
            l_auth_data.id := l_operation_rec.id;
            aut_api_auth_pkg.save_auth(i_auth => l_auth_data);
        end if;

        l_party_type     := com_api_const_pkg.PARTICIPANT_ISSUER;
        l_party_iss_rec  := opr_api_shared_data_pkg.get_participant(l_party_type);

        if l_party_iss_rec.oper_id is not null then
            l_id_type := opr_api_shared_data_pkg.get_param_char(
                             i_name => 'ID_TYPE'
                         );
            select customer_id
              into l_iss_customer_id
              from (
                    select 1 as rnk, i.customer_id
                      from iss_card i
                     where i.id = l_party_iss_rec.card_id
                     union all
                    select 2 as rnk, a.customer_id
                      from acc_account a
                     where a.id = l_party_iss_rec.account_id
                     order by
                           rnk
                   )
             where rownum = 1;

            select pc.customer_number
                 , io.id_number
                 , decode(pc.entity_type, com_api_const_pkg.ENTITY_TYPE_PERSON,
                          com_ui_person_pkg.get_person_name(
                              i_person_id => pc.object_id
                          ),
                                          com_api_const_pkg.ENTITY_TYPE_COMPANY,
                          com_ui_company_pkg.get_company_name(
                              i_company_id => pc.object_id
                          ),
                          null
                   )
                 , decode(pc.entity_type, com_api_const_pkg.ENTITY_TYPE_PERSON,
                          to_char(
                              com_ui_person_pkg.get_birthday(
                                  i_person_id => pc.object_id
                              )
                            , cst_cfc_api_const_pkg.CST_DATE_FORMAT
                          ),
                          null
                   )
              into l_customer_number
                 , l_id_number
                 , l_customer_name
                 , l_customer_birthday
              from prd_customer pc
                 , com_id_object io
             where pc.id = l_iss_customer_id
               and pc.entity_type = io.entity_type(+)
               and pc.object_id   = io.object_id(+)
               and l_id_type      = io.id_type(+);

            if l_customer_number is not null then
                l_tag_idx                           := l_tags_tab.count + 1;
                l_tags_tab(l_tag_idx).tag_id        := cst_cfc_api_const_pkg.CST_CUSTOMER_ID_TAG;
                l_tags_tab(l_tag_idx).tag_value     := l_customer_number;
                l_tags_tab(l_tag_idx).seq_number    := 1;
            end if;

        end if;

        l_party_type     := com_api_const_pkg.PARTICIPANT_DEST;
        l_party_dst_rec  := opr_api_shared_data_pkg.get_participant(l_party_type);

        if l_party_dst_rec.oper_id is not null then
            select customer_id
              into l_dst_customer_id
              from (
                    select 1 as rnk, i.customer_id
                      from acc_account_object ao
                         , iss_card i
                     where ao.account_id  = l_party_dst_rec.account_id
                       and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and i.id           = ao.object_id
                     union all
                    select 2 as rnk, a.customer_id
                      from acc_account a
                     where a.id = l_party_iss_rec.account_id
                     order by
                           rnk
                   )
             where rownum = 1;

            select decode(pc.entity_type, com_api_const_pkg.ENTITY_TYPE_PERSON,
                          com_ui_person_pkg.get_person_name(
                              i_person_id => pc.object_id
                          ),
                                          com_api_const_pkg.ENTITY_TYPE_COMPANY,
                          com_ui_company_pkg.get_company_name(
                              i_company_id => pc.object_id
                          ),
                          null
                   )
              into l_dst_customer_name
              from prd_customer pc
             where pc.id = l_dst_customer_id;
        end if;

        if l_id_number is not null then
            l_tag_idx                           := l_tags_tab.count + 1;
            l_tags_tab(l_tag_idx).tag_id        := cst_cfc_api_const_pkg.CST_NATIONAL_ID_TAG;
            l_tags_tab(l_tag_idx).tag_value     := l_id_number;
            l_tags_tab(l_tag_idx).seq_number    := 1;
        end if;

        if l_customer_name is not null then
            l_tag_idx                           := l_tags_tab.count + 1;
            l_tags_tab(l_tag_idx).tag_id        := aup_api_tag_pkg.find_tag_by_reference(
                                                       i_reference  => 'CUSTOMER_NAME'
                                                   );
            l_tags_tab(l_tag_idx).tag_value     := l_customer_name;
            l_tags_tab(l_tag_idx).seq_number    := 1;
        end if;

        if l_customer_birthday is not null then
            l_tag_idx                           := l_tags_tab.count + 1;
            l_tags_tab(l_tag_idx).tag_id        := aup_api_tag_pkg.find_tag_by_reference(
                                                       i_reference  => 'SENDER_DATE_OF_BIRTH'
                                                   );
            l_tags_tab(l_tag_idx).tag_value     := l_customer_birthday;
            l_tags_tab(l_tag_idx).seq_number    := 1;
        end if;

        if l_dst_customer_name is not null then
            l_tag_idx                           := l_tags_tab.count + 1;
            l_tags_tab(l_tag_idx).tag_id        := cst_cfc_api_const_pkg.CST_ACCOUNT_HOLDER_NAME_TAG;
            l_tags_tab(l_tag_idx).tag_value     := l_dst_customer_name;
            l_tags_tab(l_tag_idx).seq_number    := 1;
        end if;

        if l_tags_tab.count > 0 then
            aup_api_tag_pkg.save_tag(
                i_auth_id => l_auth_data.id
              , i_tags    => l_tags_tab
            );
        else
            com_api_error_pkg.raise_error(
                i_error => 'AUP_TAG_NOT_FOUND'
            );
        end if;
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finished success'
    );
end save_additional_auth_tags;

procedure process_revised_bucket is
    l_params         com_api_type_pkg.t_param_tab;
    l_event_type     com_api_type_pkg.t_dict_value;
    l_cycle_type     com_api_type_pkg.t_dict_value;
    l_count          com_api_type_pkg.t_long_id := 0;
    l_id             com_api_type_pkg.t_long_id := 0;
    l_account_id     com_api_type_pkg.t_long_id;
    l_entity_type    com_api_type_pkg.t_dict_value;
    l_prev_date      date;
    l_next_date      date;
    l_split_hash     com_api_type_pkg.t_tiny_id;
    l_sysdate        date := get_sysdate();
    l_expir_date     date;
    l_inst_id        com_api_type_pkg.t_inst_id;
    l_customer_id    com_api_type_pkg.t_medium_id;
    l_revised_bucket com_api_type_pkg.t_byte_char;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_type  := rul_api_param_pkg.get_param_char('EVENT_TYPE', l_params);

    select min(a.object_type)
      into l_cycle_type
      from prd_attribute a
     where a.attr_name = cst_cfc_api_const_pkg.CST_CFC_REVISED_BUCKET_PERIOD
       and entity_type = fcl_api_const_pkg.ENTITY_TYPE_CYCLE;

    if l_event_type  != l_cycle_type
    or l_entity_type != acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        trc_log_pkg.debug(
            i_text       => 'process_revised_bucket: event_type [#1], entity_type [#2], cycle_type [#3], do nothing'
          , i_env_param1 => l_event_type
          , i_env_param2 => l_entity_type
          , i_env_param3 => l_cycle_type
        );

        return;
    end if;

    l_account_id := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);

    select a.customer_id
         , a.inst_id
         , a.split_hash
      into l_customer_id
         , l_inst_id
         , l_split_hash
      from acc_account a
     where a.id = l_account_id;

    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type  => l_cycle_type
      , i_entity_type => l_entity_type
      , i_object_id   => l_account_id
      , i_split_hash  => l_split_hash
      , i_add_counter => com_api_const_pkg.FALSE
      , o_prev_date   => l_prev_date
      , o_next_date   => l_next_date
    );

    select count(1)
      into l_count
      from scr_bucket b
     where b.account_id  = l_account_id
       and b.customer_id = l_customer_id
       and (b.eff_date   = trunc(l_prev_date) or l_prev_date is null)
       and b.expir_date  = trunc(l_next_date);

    if l_count = 0 then
        l_expir_date :=
            fcl_api_cycle_pkg.calc_next_date(
                i_cycle_type   => l_cycle_type
              , i_entity_type  => l_entity_type
              , i_object_id    => l_account_id
              , i_split_hash   => l_split_hash
              , i_start_date   => l_next_date
              , i_eff_date     => l_sysdate
              , i_inst_id      => l_inst_id
              , i_raise_error  => com_api_type_pkg.TRUE
            );

        l_revised_bucket :=
            prd_api_product_pkg.get_attr_value_char(
                i_entity_type       => l_entity_type
              , i_object_id         => l_account_id
              , i_attr_name         => cst_cfc_api_const_pkg.CST_CFC_REVISED_BUCKET_VALUE
              , i_service_id        => null
              , i_eff_date          => l_next_date
              , i_split_hash        => l_split_hash
              , i_inst_id           => l_inst_id
              , i_mask_error        => com_api_const_pkg.TRUE
              , i_use_default_value => com_api_const_pkg.FALSE
              , i_default_value     => null
            );

        scr_api_external_pkg.add_bucket(
            io_id            => l_id
          , i_account_id     => l_account_id
          , i_customer_id    => l_customer_id
          , i_revised_bucket => l_revised_bucket
          , i_eff_date       => trunc(l_next_date)
          , i_expir_date     => trunc(l_expir_date)
          , i_valid_period   => null
          , i_reason         => null
          , i_user_id        => get_user_id
        );
        trc_log_pkg.debug(
            i_text       => 'process_revised_bucket: scr_bucket added, account_id [#1] revised_bucket [#2], eff_date [#3], expir_date  [#4]'
          , i_env_param1 => l_account_id
          , i_env_param2 => l_revised_bucket
          , i_env_param3 => trunc(l_next_date)
          , i_env_param4 => trunc(l_expir_date)
        );
   else
        trc_log_pkg.debug(
            i_text       => 'process_revised_bucket: scr_bucket already exists, account_id [#1] revised_bucket [#2], eff_date [#3], expir_date  [#4]'
          , i_env_param1 => l_account_id
          , i_env_param2 => l_revised_bucket
          , i_env_param3 => trunc(l_next_date)
          , i_env_param4 => trunc(l_expir_date)
        );
   end if;
end;

procedure get_remaining_payment_amount
is
    l_account               acc_api_type_pkg.t_account_rec;
    l_amount                com_api_type_pkg.t_amount_rec;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_result_amount_name    com_api_type_pkg.t_name;
begin

    l_oper_id := opr_api_shared_data_pkg.get_operation().id;

    opr_api_shared_data_pkg.get_account (
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );

    l_result_amount_name := opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    begin
        select sum(pay_amount)
             , currency
          into l_amount.amount
             , l_amount.currency
          from crd_payment
         where pay_amount > 0
           and status =  crd_api_const_pkg.PAYMENT_STATUS_ACTIVE
           and account_id = l_account.account_id
           and oper_id = l_oper_id
      group by currency;
    exception
        when no_data_found then
            l_amount.amount := 0;
            l_amount.currency := l_account.currency;
    end;

    opr_api_shared_data_pkg.set_amount (
        i_name          => l_result_amount_name
      , i_amount        => l_amount.amount
      , i_currency      => l_amount.currency
    );

    trc_log_pkg.debug(
        i_text          => lower($$PLSQL_UNIT) || '.get_remaining_payment_amount: oper_id=[#1]'
                                               || ', l_result_amount_name=[#2], amount=[#3], currency=[#4]'
      , i_env_param1    => l_oper_id
      , i_env_param2    => l_result_amount_name
      , i_env_param3    => l_amount.amount
      , i_env_param4    => l_amount.currency
    );
end get_remaining_payment_amount;

procedure get_spent_own_funds
is
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_macros_type                   com_api_type_pkg.t_tiny_id;
    l_selector                      com_api_type_pkg.t_name;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_count                         com_api_type_pkg.t_long_id;
begin
    l_macros_type := opr_api_shared_data_pkg.get_param_num('MACROS_TYPE');

    l_selector := opr_api_shared_data_pkg.get_param_char (
                      i_name         => 'OPERATION_SELECTOR'
                    , i_mask_error   => com_api_type_pkg.TRUE
                    , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                  );

    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id(i_selector => l_selector);

    l_result_amount_name := opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    trc_log_pkg.debug (
        i_text         => lower($$PLSQL_UNIT) || '.get_spent_own_funds: oper_id=[#1], macros_type_id=[#2], result_amount_name=[#3]'
      , i_env_param1   => l_oper_id
      , i_env_param2   => l_macros_type
      , i_env_param3   => l_result_amount_name
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => l_oper_id
    );

    select nvl(sum(greatest(0, nvl(cd.amount, 0) - nvl(cd.debt_amount, 0))), 0)
         , max(cd.currency)
         , count(*)
      into l_amount.amount
         , l_amount.currency
         , l_count
      from crd_debt cd
     where cd.oper_id = l_oper_id
       and cd.macros_type_id = l_macros_type;

    trc_log_pkg.debug (
        i_text         => lower($$PLSQL_UNIT) || '.get_spent_own_funds: Amount=[#1], currency=[#2], debts count=[#3]'
      , i_env_param1   => l_amount.amount
      , i_env_param2   => l_amount.currency
      , i_env_param3   => l_count
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => l_oper_id
    );

    opr_api_shared_data_pkg.set_amount (
        i_name      => l_result_amount_name
      , i_amount    => l_amount.amount
      , i_currency  => l_amount.currency
    );
end get_spent_own_funds;

procedure get_oper_debt_amount
is
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_macros_type                   com_api_type_pkg.t_tiny_id;
    l_selector                      com_api_type_pkg.t_name;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_count                         com_api_type_pkg.t_long_id;
begin
    l_macros_type := opr_api_shared_data_pkg.get_param_num('MACROS_TYPE');

    l_selector := opr_api_shared_data_pkg.get_param_char (
                      i_name         => 'OPERATION_SELECTOR'
                    , i_mask_error   => com_api_type_pkg.TRUE
                    , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                  );

    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id  := opr_api_shared_data_pkg.get_operation_id(i_selector => l_selector);

    l_result_amount_name := opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    trc_log_pkg.debug (
        i_text         => lower($$PLSQL_UNIT) || '.get_oper_debt_amount: oper_id=[#1], macros_type_id=[#2], result_amount_name=[#3]'
      , i_env_param1   => l_oper_id
      , i_env_param2   => l_macros_type
      , i_env_param3   => l_result_amount_name
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => l_oper_id
    );

    select nvl(sum(cd.debt_amount), 0)
         , max(cd.currency)
         , count(*)
      into l_amount.amount
         , l_amount.currency
         , l_count
      from crd_debt cd
     where cd.oper_id = l_oper_id
       and cd.macros_type_id = l_macros_type;

    trc_log_pkg.debug (
        i_text         => lower($$PLSQL_UNIT) || '.get_oper_debt_amount: Amount=[#1], currency=[#2], debts count=[#3]'
      , i_env_param1   => l_amount.amount
      , i_env_param2   => l_amount.currency
      , i_env_param3   => l_count
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => l_oper_id
    );

    opr_api_shared_data_pkg.set_amount (
        i_name      => l_result_amount_name
      , i_amount    => l_amount.amount
      , i_currency  => l_amount.currency
    );
end get_oper_debt_amount;

procedure set_absolute_amount is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_absolute_amount: ';
    l_source_amount_name            com_api_type_pkg.t_name;
    l_source_amount                 com_api_type_pkg.t_amount_rec;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_account_id                    com_api_type_pkg.t_medium_id;
begin
    l_source_amount_name := evt_api_shared_data_pkg.get_param_char('SOURCE_AMOUNT_NAME');
    l_entity_type        := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');

    if l_entity_type <> acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        trc_log_pkg.error(
            i_text        => 'NOT_SUPPORTED_ENTITY_TYPE'
          , i_env_param1  => l_entity_type
        );
    else
        l_account_id := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

        l_source_amount := acc_api_balance_pkg.get_balance_amount (
                               i_account_id    => l_account_id
                             , i_balance_type  => l_source_amount_name
                             , i_mask_error    => com_api_type_pkg.TRUE
                             , i_lock_balance  => com_api_type_pkg.FALSE
                           );

        evt_api_shared_data_pkg.set_amount(
            i_name      => l_source_amount_name
          , i_amount    => abs(l_source_amount.amount)
          , i_currency  => l_source_amount.currency
        );
    end if;

    trc_log_pkg.debug (
        i_text         => LOG_PREFIX || 'l_source_amount_name=[#1], l_entity_type=[#2], l_account_id=[#3]'
      , i_env_param1   => l_source_amount_name
      , i_env_param2   => l_entity_type
      , i_env_param3   => l_account_id
    );
end set_absolute_amount;

procedure get_account_balance_amount is
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_balance_type                  com_api_type_pkg.t_name;
    l_balances                      com_api_type_pkg.t_amount_by_name_tab;
    l_balance_amount                com_api_type_pkg.t_money;
begin

    opr_api_shared_data_pkg.get_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );

    l_balance_type := opr_api_shared_data_pkg.get_param_char('BALANCE_TYPE');

    acc_api_balance_pkg.get_account_balances (
        i_account_id      => l_account.account_id
      , o_balances        => l_balances
      , o_balance         => l_balance_amount
      , i_lock_balances   => com_api_const_pkg.FALSE
    );

    if l_balances.exists(l_balance_type) then
        l_amount := l_balances(l_balance_type);
    else
        l_amount.amount     := 0;
        l_amount.currency   := l_account.currency;
    end if;

    opr_api_shared_data_pkg.set_amount (
        i_name      => nvl(opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME'), l_balance_type)
      , i_amount    => abs(l_amount.amount)
      , i_currency  => l_amount.currency
    );
end get_account_balance_amount;

procedure add_amount is
    l_first_amount_name             com_api_type_pkg.t_name;
    l_second_amount_name            com_api_type_pkg.t_name;
    l_first_amount                  com_api_type_pkg.t_amount_rec;
    l_second_amount                 com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_amount: ';
begin
    l_first_amount_name := evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME_#1');
    l_second_amount_name := evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME_#2');
    l_result_amount_name := evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    evt_api_shared_data_pkg.get_amount(
        i_name          => l_first_amount_name
      , o_amount        => l_first_amount.amount
      , o_currency      => l_first_amount.currency
      , i_mask_error    => com_api_const_pkg.TRUE
    );

    evt_api_shared_data_pkg.get_amount(
        i_name          => l_second_amount_name
      , o_amount        => l_second_amount.amount
      , o_currency      => l_second_amount.currency
      , i_mask_error    => com_api_const_pkg.TRUE
    );

    if l_first_amount.currency = l_second_amount.currency or l_second_amount.amount = 0 then
        l_result_amount.currency := l_first_amount.currency;
        l_result_amount.amount := l_first_amount.amount + l_second_amount.amount;

        evt_api_shared_data_pkg.set_amount (
            i_name      => l_result_amount_name
          , i_amount    => l_result_amount.amount
          , i_currency  => l_result_amount.currency
        );
    else
        com_api_error_pkg.raise_error (
            i_error       => 'ATTEMPT_TO_ADD_DIFFERENT_CURRENCY'
          , i_env_param1  => l_first_amount.currency
          , i_env_param2  => l_second_amount.currency
        );
    end if;
end add_amount;

/*
 * Rule changes repayment priorities of new (uninvoiced) debts using priorities configurated for balance Overdue.
 */
procedure change_repay_priority
is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_repay_priority';
    l_account_id           com_api_type_pkg.t_account_id;
    l_split_hash           com_api_type_pkg.t_tiny_id;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_eff_date             date;
    l_param_tab            com_api_type_pkg.t_param_tab;
    l_service_id           com_api_type_pkg.t_short_id;
    l_product_id           com_api_type_pkg.t_short_id;
    l_invoice              crd_api_type_pkg.t_invoice_rec;
    l_debt_id_tab          com_api_type_pkg.t_long_tab;
    l_repay_priority_tab   com_api_type_pkg.t_short_tab;
    l_count                com_api_type_pkg.t_count := 0;
begin
    if evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE') != acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE')
        );
    end if;

    l_account_id := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_split_hash := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');
    l_inst_id    := evt_api_shared_data_pkg.get_param_num('INST_ID');
    l_eff_date   := com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id);

    l_service_id :=
        crd_api_service_pkg.get_active_service(
            i_account_id  => l_account_id
          , i_eff_date    => l_eff_date
          , i_split_hash  => l_split_hash
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << l_account_id [#1], l_split_hash [#2], l_service_id [#3], l_eff_date [#4]'
      , i_env_param1 => l_account_id
      , i_env_param2 => l_split_hash
      , i_env_param3 => l_service_id
      , i_env_param4 => to_char(l_eff_date, com_api_const_pkg.XML_DATE_FORMAT)
    );

    -- This check can be made optional (using parameter-flag of the rule)
    -- because it is not necessary on processing event OVERDUE (fact of overdue is already checked)
    l_invoice :=
        crd_invoice_pkg.get_last_invoice(
            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => l_account_id
          , i_split_hash  => l_split_hash
          , i_mask_error  => com_api_const_pkg.FALSE -- this rule can't be called for account w/o invoices
        );
    if l_invoice.is_mad_paid = com_api_const_pkg.TRUE and l_eff_date < l_invoice.penalty_date then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' >> overdue is NOT detected, SKIP processing the rule; '
                                       || 'invoice_id [#1], is_mad_paid [#2], penalty_date [#3]'
          , i_env_param1 => l_invoice.id
          , i_env_param2 => l_invoice.is_mad_paid
          , i_env_param3 => l_invoice.penalty_date
        );
    else
        for debt in ( -- only un-invoiced debts
            select d.id
              from crd_debt d
             where decode(d.is_new, 1, d.account_id, null) = l_account_id
               and d.account_id = l_account_id
               and d.split_hash = l_split_hash
               and d.inst_id    = l_inst_id
        ) loop
            l_debt_id_tab(l_debt_id_tab.count() + 1) := debt.id;

            l_param_tab.delete();

            crd_debt_pkg.load_debt_param(
                i_debt_id     => debt.id
              , i_split_hash  => l_split_hash
              , io_param_tab  => l_param_tab
              , o_product_id  => l_product_id
            );
            rul_api_param_pkg.set_param(
                i_value       => crd_api_const_pkg.BALANCE_TYPE_OVERDUE
              , i_name        => 'BALANCE_TYPE'
              , io_params     => l_param_tab
            );

            l_repay_priority_tab(l_repay_priority_tab.count() + 1) :=
                prd_api_product_pkg.get_attr_value_number(
                    i_product_id   => l_product_id
                  , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id    => l_account_id
                  , i_attr_name    => crd_api_const_pkg.REPAYMENT_PRIORITY
                  , i_split_hash   => l_split_hash
                  , i_service_id   => l_service_id
                  , i_params       => l_param_tab
                  , i_eff_date     => l_eff_date
                  , i_inst_id      => l_inst_id
                );

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ': debt.id [#1], l_repay_priority_tab[#3] = #2'
              , i_env_param1 => debt.id
              , i_env_param2 => l_repay_priority_tab(l_repay_priority_tab.count())
              , i_env_param3 => l_repay_priority_tab.count()
            );
        end loop;

        forall i in l_debt_id_tab.first .. l_debt_id_tab.last
            update crd_debt_balance b
               set b.repay_priority = l_repay_priority_tab(i)
             where b.debt_id    = l_debt_id_tab(i)
               and b.split_hash = l_split_hash
               and b.amount > 0
               and b.balance_type in (crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT);

        if trc_config_pkg.get_trace_conf().trace_level >= trc_config_pkg.DEBUG then
            for i in l_debt_id_tab.first .. l_debt_id_tab.last loop
                l_count := l_count + sql%bulk_rowcount(i);
            end loop;

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ' >> records were updated: #1'
              , i_env_param1 => l_count
            );
        end if;
    end if; -- check whether it is overdue
end change_repay_priority;

function get_cus_account_status
return com_api_type_pkg.t_dict_value
is
    l_account       acc_api_type_pkg.t_account_rec;
    l_acc_status    com_api_type_pkg.t_dict_value;
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_cus_account_status: ';
begin
    opr_api_shared_data_pkg.get_account(
        i_name              => com_api_const_pkg.ACCOUNT_PURPOSE_CARD -- 'ACPR0001'
      , o_account_rec       => l_account
      , i_mask_error        => com_api_type_pkg.TRUE
      , i_error_value       => null
    );

    if l_account.status is null and l_account.account_id is not null then
        select status
          into l_acc_status
          from acc_account
         where id = l_account.account_id;
    end if;

    trc_log_pkg.debug (
        i_text         => LOG_PREFIX || 'account_id [#1], return account status [#2]'
      , i_env_param1   => l_account.account_id
      , i_env_param2   => nvl(l_account.status, l_acc_status)
    );

    return nvl(l_account.status, l_acc_status);

end get_cus_account_status;

procedure calc_accrued_interest_amount is
    l_amount_name               com_api_type_pkg.t_name;
    l_oper_id                   com_api_type_pkg.t_long_id;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_total_amount              com_api_type_pkg.t_money;
    l_tran_type                 com_api_type_pkg.t_dict_value;
begin

    l_oper_id := opr_api_shared_data_pkg.get_operation().original_id;
    l_tran_type := opr_api_shared_data_pkg.get_param_char(
                       i_name   => 'TRANSACTION_TYPE'
                   );
    begin
        select sum(nvl(e.amount, 0)) interest_amount
             , d.currency
          into l_total_amount
             , l_currency
          from crd_debt d
             , acc_entry e
         where d.oper_id        = l_oper_id
           and d.id             = e.macros_id
           and e.account_id     = d.account_id
           and case
                   when l_tran_type is null then
                       e.transaction_type
                   when l_tran_type in ('TRNT1003', 'TRNT1005') then
                       l_tran_type
               end = e.transaction_type
         group by
               d.currency;
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
      , i_amount            => l_total_amount
      , i_currency          => l_currency
    );
end;


function check_card_activation
return com_api_type_pkg.t_count
is
    l_result                    com_api_type_pkg.t_count  default 0;
    l_card_instance_id          com_api_type_pkg.t_long_id;
    l_oper_id                   com_api_type_pkg.t_long_id;
begin

    l_oper_id := opr_api_shared_data_pkg.get_operation().id;

    select card_instance_id
      into l_card_instance_id
      from opr_participant
     where oper_id          = l_oper_id
       and participant_type = com_api_const_pkg.PARTICIPANT_ISSUER;

    select count(1)
      into l_result
      from evt_status_log
     where object_id    = l_card_instance_id
       and entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
       and event_type   = iss_api_const_pkg.EVENT_TYPE_CARD_ACTIVATION;

    trc_log_pkg.debug (
        i_text          => 'Card [#1] activation [#2]'
      , i_env_param1    => l_card_instance_id
      , i_env_param2    => l_result
    );

    return l_result;
exception
    when no_data_found then
        return l_result;
end check_card_activation;

procedure credit_balance_payment
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
    l_balance_amount                com_api_type_pkg.t_money;
    i_detailed_entities_array_id    com_api_type_pkg.t_short_id;

    l_balance_type                  com_api_type_pkg.t_dict_value;
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

    trc_log_pkg.debug(
        i_text          => 'credit_balance_payment oper_amount [#1] -  oper_reason [#2]'
      , i_env_param1    => l_operation.oper_amount
      , i_env_param2    => l_operation.oper_reason
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

    l_balance_type  :=
        case l_operation.oper_reason
            when cst_cfc_api_const_pkg.CR_ADJ_OVERDRAFT_BAL         then acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT
            when cst_cfc_api_const_pkg.CR_ADJ_OVERDUE_BAL           then acc_api_const_pkg.BALANCE_TYPE_OVERDUE
            when cst_cfc_api_const_pkg.CR_ADJ_INTEREST_BAL          then crd_api_const_pkg.BALANCE_TYPE_INTEREST
            when cst_cfc_api_const_pkg.CR_ADJ_OVERDUE_INTEREST_BAL  then acc_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
            when cst_cfc_api_const_pkg.CR_ADJ_FEE_BAL               then acc_api_const_pkg.BALANCE_TYPE_FEES
        end;

    l_balance_amount :=
        cst_cfc_com_pkg.get_balance_amount(
            i_account_id   => l_account.account_id
          , i_balance_type => l_balance_type);

    if l_service_id is null then
        trc_log_pkg.debug(
            i_text          => 'Credit service not found on account [#1]'
          , i_env_param1    => l_account.account_id
        );
    elsif (l_operation.oper_amount > l_balance_amount) then

        com_api_error_pkg.raise_error(
            i_error      => 'PAYMENT_AMOUNT_EXCEEDS_DEBT_AMOUNT'
          , i_env_param1 => l_operation.oper_amount
          , i_env_param2 => l_balance_amount
        );
        return;
    else

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
                    m.macros_type_id = l_macros_type
                    and m.entity_type = 'ENTTOPER'
                    and m.object_id = l_operation.id
                    and e.macros_id = m.id
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

            crd_cst_cfc_payment_pkg.apply_balance_payment(
                i_payment_id        => r.macros_id
              , i_balance_type      => l_balance_type
              , i_eff_date          => l_eff_date
              , i_split_hash        => r.split_hash
              , o_remainder_amount  => l_balance_amount
            );

        end loop;
    end if;
end credit_balance_payment;

end cst_cfc_rule_proc_pkg;
/
