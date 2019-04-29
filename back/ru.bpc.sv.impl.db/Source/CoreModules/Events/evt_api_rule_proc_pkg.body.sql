create or replace package body evt_api_rule_proc_pkg is
/*********************************************************
 *  API for event rule processing <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com) at 26.08.2011 <br />
 *  Module: EVT_API_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

procedure calculate_fee
is
    l_base_amount                   com_api_type_pkg.t_amount_rec;
    l_tier_amount                   com_api_type_pkg.t_amount_rec;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    l_fee_type                      com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_fee_id                        com_api_type_pkg.t_long_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_event_date                    date;
    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_service_type_id               com_api_type_pkg.t_short_id;
    l_start_date                    date;
    l_end_date                      date;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_dpp                           dpp_api_type_pkg.t_dpp;
begin
    l_fee_type    := evt_api_shared_data_pkg.get_param_char('FEE_TYPE');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_split_hash  := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');

    if l_entity_type = crd_api_const_pkg.ENTITY_TYPE_DEBT then
        select acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
             , account_id
             , inst_id
          into l_entity_type
             , l_object_id
             , l_inst_id
          from crd_debt
         where id = l_object_id;

    elsif l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        select iss_api_const_pkg.ENTITY_TYPE_CARD
             , card_id
             , inst_id
          into l_entity_type
             , l_object_id
             , l_inst_id
          from iss_card_instance
         where id = l_object_id;

    elsif l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        select acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
             , account_id
             , inst_id
          into l_entity_type
             , l_object_id
             , l_inst_id
          from crd_invoice
         where id = l_object_id;

    elsif l_entity_type = dpp_api_const_pkg.ENTITY_TYPE_PAYMENT_PLAN then
        -- Use instalment account because there is no services/attributes for entity type <Instalment plan>
        l_dpp := dpp_api_payment_plan_pkg.get_dpp(
                     i_dpp_id     => l_object_id
                   , i_mask_error => com_api_const_pkg.FALSE
                 );
        l_entity_type := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
        l_object_id   := l_dpp.account_id;
        l_inst_id     := l_dpp.inst_id;
    end if;

    l_test_mode :=
        nvl(
            evt_api_shared_data_pkg.get_param_char(
                i_name        => 'ATTR_MISS_TESTMODE'
              , i_mask_error  => com_api_const_pkg.TRUE
              , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
            )
          , fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
        );

    begin
        -- checking for servicing fee
        begin
            select a.service_type_id
              into l_service_type_id
              from prd_attribute a
                 , prd_service_type s
             where a.object_type = l_fee_type
               and a.service_type_id = s.id
               and a.id = s.service_fee;

            select trunc(least(l_event_date, nvl(o.end_date, l_event_date)))
                 , nvl(c.prev_date, nvl(trunc(o.start_date), l_event_date))
              into l_end_date
                 , l_start_date
              from prd_service_object o
                 , prd_service s
                 , fcl_cycle_counter c
                 , fcl_fee_type t
             where o.service_id      = s.id
               and s.service_type_id = l_service_type_id
               and o.entity_type     = l_entity_type
               and o.object_id       = l_object_id
               and o.split_hash      = l_split_hash
               and c.entity_type     = o.entity_type
               and c.object_id       = o.object_id
               and c.split_hash      = o.split_hash
               and c.cycle_type      = t.cycle_type
               and t.fee_type        = l_fee_type
               and l_event_date between nvl(c.prev_date, nvl(trunc(o.start_date), l_event_date))
                                    and nvl(o.end_date, trunc(l_event_date) +1 )
               and rownum = 1;

        exception
            when no_data_found then
                trc_log_pkg.debug('Not servicing fee');
        end;

        l_fee_id :=
            prd_api_product_pkg.get_fee_id(
                i_product_id   => prd_api_product_pkg.get_product_id(
                                      i_entity_type  => l_entity_type
                                    , i_object_id    => l_object_id
                                  )
              , i_entity_type  => l_entity_type
              , i_object_id    => l_object_id
              , i_fee_type     => l_fee_type
              , i_params       => evt_api_shared_data_pkg.g_params
              , i_eff_date     => l_event_date
              , i_split_hash   => l_split_hash
              , i_inst_id      => l_inst_id
            );
        if evt_api_shared_data_pkg.get_param_char('BASE_AMOUNT_NAME', com_api_const_pkg.TRUE) is not null then
            evt_api_shared_data_pkg.get_amount(
                i_name             => evt_api_shared_data_pkg.get_param_char('BASE_AMOUNT_NAME')
              , i_mask_error       => com_api_const_pkg.TRUE
              , o_amount           => l_base_amount.amount
              , o_currency         => l_base_amount.currency
            );
        end if;

        if evt_api_shared_data_pkg.get_param_char('TIER_AMOUNT_NAME', com_api_const_pkg.TRUE) is not null then
            evt_api_shared_data_pkg.get_amount(
                i_name             => evt_api_shared_data_pkg.get_param_char('TIER_AMOUNT_NAME')
              , i_mask_error       => com_api_const_pkg.TRUE
              , o_amount           => l_tier_amount.amount
              , o_currency         => l_tier_amount.currency
            );
        end if;

        l_result_amount.amount :=
            round(
                fcl_api_fee_pkg.get_fee_amount(
                    i_fee_id          => l_fee_id
                  , i_base_amount     => nvl(abs(l_base_amount.amount), 0)
                  , io_base_currency  => l_result_amount.currency  -- base, tier and result amounts are of the same currency
                  , i_entity_type     => l_entity_type
                  , i_object_id       => l_object_id
                  , i_split_hash      => l_split_hash
                  , i_start_date      => l_start_date
                  , i_end_date        => l_end_date
                  , i_tier_amount     => l_tier_amount.amount      -- if empty then use l_base_amount instead of l_tier_amount within "get_fee_amount"
                )
            );

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

    evt_api_shared_data_pkg.set_amount(
        i_name      => evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME')
      , i_amount    => l_result_amount.amount
      , i_currency  => l_result_amount.currency
    );
exception
    when com_api_error_pkg.e_fatal_error then
        raise;
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error != 'PRD_NO_ACTIVE_SERVICE' then
            raise;
        end if;
end calculate_fee;

procedure calculate_fee_turnover
is
    l_result_amount_name            com_api_type_pkg.t_name;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    l_fee_type                      com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_fee_id                        com_api_type_pkg.t_long_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_event_date                    date;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_service_type_id               com_api_type_pkg.t_short_id;
    l_start_date                    date;
    l_end_date                      date;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_amount_for_tier               com_api_type_pkg.t_money;
    l_count_for_tier                com_api_type_pkg.t_long_id;
    l_limit_type                    com_api_type_pkg.t_name;
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.calculate_fee_turnover: ';
begin
    l_fee_type           := evt_api_shared_data_pkg.get_param_char('FEE_TYPE');
    l_result_amount_name := evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');
    l_entity_type        := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id          := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_event_date         := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_split_hash         := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');
    l_limit_type         := evt_api_shared_data_pkg.get_param_char('LIMIT_TYPE');

    if l_entity_type = crd_api_const_pkg.ENTITY_TYPE_DEBT then

        select acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
             , account_id
             , inst_id
          into l_entity_type
             , l_object_id
             , l_inst_id
          from crd_debt
         where id = l_object_id;

    elsif l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then

        select iss_api_const_pkg.ENTITY_TYPE_CARD
             , card_id
             , inst_id
          into l_entity_type
             , l_object_id
             , l_inst_id
          from iss_card_instance
         where id = l_object_id;

    end if;

    l_product_id := prd_api_product_pkg.get_product_id (
        i_entity_type  => l_entity_type
      , i_object_id  => l_object_id
    );

    l_test_mode :=
        nvl(
            evt_api_shared_data_pkg.get_param_char(
                i_name        => 'ATTR_MISS_TESTMODE'
              , i_mask_error  => com_api_const_pkg.TRUE
              , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
            )
          , fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
        );

    begin
        -- checking for servicing fee
        begin
            select a.service_type_id
              into l_service_type_id
              from prd_attribute a
                 , prd_service_type s
             where a.object_type = l_fee_type
               and a.service_type_id = s.id
               and a.id = s.service_fee;

            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'l_service_type_id=' || l_service_type_id
            );

            select trunc(least(l_event_date, nvl(o.end_date, l_event_date)))
                 , nvl(c.prev_date, nvl(trunc(o.start_date), l_event_date))
              into l_end_date
                 , l_start_date
              from prd_service_object o
                 , prd_service s
                 , fcl_cycle_counter c
                 , fcl_fee_type t
            where o.service_id      = s.id
               and s.service_type_id = l_service_type_id
               and o.entity_type     = l_entity_type
               and o.object_id       = l_object_id
               and o.split_hash      = l_split_hash
               and c.entity_type     = o.entity_type
               and c.object_id       = o.object_id
               and c.split_hash      = o.split_hash
               and c.cycle_type      = t.cycle_type
               and t.fee_type        = l_fee_type
               and l_event_date between nvl(c.prev_date, nvl(trunc(o.start_date), l_event_date)) and nvl(o.end_date, trunc(l_event_date)+1)
               and rownum = 1;

            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'Calculating  l_end_date=' || l_end_date || ' l_start_date=' || l_start_date
            );
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || 'Not servicing fee'
                );
        end;

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

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_count_for_tier=' || l_count_for_tier || ' l_amount_for_tier=' || l_amount_for_tier
        );

        l_fee_id :=
            prd_api_product_pkg.get_fee_id(
                i_product_id   => l_product_id
              , i_entity_type  => l_entity_type
              , i_object_id    => l_object_id
              , i_fee_type     => l_fee_type
              , i_params       => evt_api_shared_data_pkg.g_params
              , i_eff_date     => l_event_date
              , i_split_hash   => l_split_hash
              , i_inst_id      => l_inst_id
            );

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_fee_id=' || l_fee_id
        );

        l_result_amount.amount :=
            round(fcl_api_fee_pkg.get_fee_amount(
                      i_fee_id            => l_fee_id
                    , i_base_amount       => l_amount_for_tier
                    , i_entity_type       => l_entity_type
                    , i_object_id         => l_object_id
                    , io_base_currency    => l_result_amount.currency
                    , i_split_hash        => l_split_hash
                    , i_start_date        => l_start_date
                    , i_end_date          => l_end_date
                    , i_tier_amount       => l_amount_for_tier
                    , i_tier_count        => l_count_for_tier
                  )
            );

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'amount=' || l_result_amount.amount
        );

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

    evt_api_shared_data_pkg.set_amount (
        i_name      => l_result_amount_name
      , i_amount    => l_result_amount.amount
      , i_currency  => l_result_amount.currency
    );

exception
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error != 'PRD_NO_ACTIVE_SERVICE' then
            raise;
        end if;
end;

procedure reset_limit_counter
is
    l_params                        com_api_type_pkg.t_param_tab;
    l_limit_type                    com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_limit_type  := rul_api_param_pkg.get_param_char('LIMIT_TYPE', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);

    trc_log_pkg.debug (
        i_text           => 'Going to reset counter [#1][#2][#3]'
        , i_env_param1   => l_limit_type
        , i_env_param2   => l_entity_type
        , i_env_param3   => l_object_id
    );

    fcl_api_limit_pkg.zero_limit_counter (
        i_limit_type     => l_limit_type
        , i_entity_type  => l_entity_type
        , i_object_id    => l_object_id
    );
end;

procedure switch_limit_counter is

    l_params                        com_api_type_pkg.t_param_tab;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_event_date                    date;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_count_value                   com_api_type_pkg.t_long_id;
    l_sum_value                     com_api_type_pkg.t_amount_rec;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_limit_type                    com_api_type_pkg.t_dict_value;
    l_count_value_name              com_api_type_pkg.t_name;
    l_sum_value_name                com_api_type_pkg.t_name;
    l_check_overlimit               com_api_type_pkg.t_boolean;
    l_switch_limit                  com_api_type_pkg.t_boolean;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_test_mode                     com_api_type_pkg.t_dict_value;

begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_limit_type := rul_api_param_pkg.get_param_char('LIMIT_TYPE', l_params);
    l_count_value_name := rul_api_param_pkg.get_param_char('COUNT_VALUE_NAME', l_params, com_api_const_pkg.TRUE);
    l_check_overlimit := evt_api_shared_data_pkg.get_param_num('CHECK_OVERLIMIT');
    l_switch_limit := evt_api_shared_data_pkg.get_param_num('SWITCH_LIMIT');
    l_inst_id := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_const_pkg.TRUE);

    l_sum_value_name :=
        evt_api_shared_data_pkg.get_param_char(
            i_name          => 'SUM_VALUE_NAME'
          , i_mask_error    => com_api_const_pkg.TRUE
        );

    if l_sum_value_name is not null then
        evt_api_shared_data_pkg.get_amount(
            i_name          => l_sum_value_name
          , o_amount        => l_sum_value.amount
          , o_currency      => l_sum_value.currency
        );
    end if;

    if l_count_value_name is not null then
        l_count_value := rul_api_param_pkg.get_param_num(upper(l_count_value_name), l_params);
    end if;

    l_object_id := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_date := rul_api_param_pkg.get_param_date('EVENT_DATE', l_params);
    l_split_hash := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);

    l_product_id := prd_api_product_pkg.get_product_id (
        i_entity_type  => l_entity_type
        , i_object_id  => l_object_id
    );

    select nvl(l_count_value, nvl2(l_sum_value.amount, 1, 0)) into l_count_value from dual;

    l_test_mode := nvl(
                       evt_api_shared_data_pkg.get_param_char(
                           i_name        => 'ATTR_MISS_TESTMODE'
                         , i_mask_error  => com_api_const_pkg.TRUE
                         , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                       )
                     , fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                   );

    fcl_api_limit_pkg.switch_limit_counter (
        i_limit_type         => l_limit_type
        , i_product_id       => l_product_id
        , i_entity_type      => l_entity_type
        , i_object_id        => l_object_id
        , i_params           => l_params
        , i_count_value      => l_count_value
        , i_sum_value        => nvl(l_sum_value.amount, 0)
        , i_currency         => l_sum_value.currency
        , i_eff_date         => l_event_date
        , i_split_hash       => l_split_hash
        , i_inst_id          => l_inst_id
        , i_check_overlimit  => l_check_overlimit
        , i_switch_limit     => l_switch_limit
        , i_test_mode        => l_test_mode
    );
exception
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error != 'PRD_NO_ACTIVE_SERVICE' then
            raise;
        end if;
end;

procedure get_limit_counter
is
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
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
        evt_api_shared_data_pkg.get_param_char(
            i_name        => 'BASE_AMOUNT_NAME'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    if l_amount_name is not null then
        evt_api_shared_data_pkg.get_amount(
            i_name      => l_amount_name
          , o_amount    => l_amount.amount
          , o_currency  => l_amount.currency
        );
    end if;

    l_eff_date_name :=
        evt_api_shared_data_pkg.get_param_char(
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
        evt_api_shared_data_pkg.get_date(
            i_name  => l_eff_date_name
          , o_date  => l_eff_date
        );
    else
        l_eff_date := com_api_sttl_day_pkg.get_sysdate();
    end if;

    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

    fcl_api_limit_pkg.get_limit_counter(
        i_limit_type        => evt_api_shared_data_pkg.get_param_char('LIMIT_TYPE')
      , i_product_id        => prd_api_product_pkg.get_product_id(
                                   i_entity_type  => l_entity_type
                                 , i_object_id    => l_object_id
                               )
      , i_entity_type       => l_entity_type
      , i_object_id         => l_object_id
      , i_params            => evt_api_shared_data_pkg.g_params
      , i_eff_date          => l_eff_date
      , io_currency         => l_amount.currency
      , o_last_reset_date   => l_last_reset_date
      , o_count_curr        => l_count_curr
      , o_count_limit       => l_count_limit
      , o_sum_limit         => l_sum_limit
      , o_sum_curr          => l_sum_curr
    );

    trc_log_pkg.debug(
        i_text         => 'Limit counter: l_sum_limit [#1], l_sum_curr [#2]'
      , i_env_param1   => l_sum_limit
      , i_env_param2   => l_sum_curr
    );

    -- Mandatory outgoing amount contains current limit counter value
    evt_api_shared_data_pkg.set_amount(
        i_name      => evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME') -- mandatory parameter
      , i_amount    => nvl(l_sum_curr, 0)
      , i_currency  => l_amount.currency
    );

    -- Optional outgoing amoint contains a remainder of the limit counter
    l_amount_name :=
        evt_api_shared_data_pkg.get_param_char(
            i_name        => 'REMAINDER_AMOUNT_NAME'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    if l_amount_name is not null then
        evt_api_shared_data_pkg.set_amount(
            i_name      => l_amount_name
          , i_amount    => greatest(0, (l_sum_limit - l_sum_curr))
          , i_currency  => l_amount.currency
        );
    end if;
end get_limit_counter;

procedure switch_cycle
is
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
    l_card_id                       com_api_type_pkg.t_medium_id;
    l_cycle_id                      com_api_type_pkg.t_short_id;
    l_cycle_entity_type             com_api_type_pkg.t_dict_value;
    l_payment_order                 pmo_api_type_pkg.t_payment_order_rec;
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

    case when l_entity_type in (crd_api_const_pkg.ENTITY_TYPE_DEBT, crd_api_const_pkg.ENTITY_TYPE_INVOICE)
         then
             if l_entity_type = crd_api_const_pkg.ENTITY_TYPE_DEBT then
                 select account_id
                   into l_account_id
                   from crd_debt
                  where id = l_object_id;
             else
                 select account_id
                   into l_account_id
                   from crd_invoice
                  where id = l_object_id;
             end if;
             l_product_id :=
                 prd_api_product_pkg.get_product_id(
                     i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                   , i_object_id    => l_account_id
                 );

             select service_type_id
               into l_service_type_id
               from prd_attribute
              where object_type = l_cycle_type;

             l_service_id :=
                 prd_api_service_pkg.get_active_service_id(
                     i_entity_type         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                   , i_object_id           => l_account_id
                   , i_attr_name           => null
                   , i_service_type_id     => l_service_type_id
                   , i_split_hash          => l_split_hash
                   , i_eff_date            => l_event_date
                   , i_inst_id             => l_inst_id
                 );

         when l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
         then
             l_product_id :=
                 prd_api_product_pkg.get_product_id (
                     i_entity_type  => l_entity_type
                     , i_object_id  => l_object_id
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

             begin
                 select entity_type
                   into l_cycle_entity_type
                   from evt_event_type
                  where event_type  = l_cycle_type;
             exception
                when no_data_found then
                    null;
             end;

             if l_cycle_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
                 l_object_id := iss_api_card_instance_pkg.get_card_instance_id(i_card_id => l_object_id);

                 l_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE;
             end if;

         when l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
         then
             select card_id
               into l_card_id
               from iss_card_instance
              where id = l_object_id;

             l_product_id :=
                 prd_api_product_pkg.get_product_id (
                     i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
                     , i_object_id  => l_card_id
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

             begin
                 select entity_type
                   into l_cycle_entity_type
                   from evt_event_type
                  where event_type  = l_cycle_type;
             exception
                when no_data_found then
                    null;
             end;

             if l_cycle_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
                 l_object_id := l_card_id;

                 l_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD;
             end if;

         when l_entity_type = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
         then
             l_payment_order := pmo_api_order_pkg.get_order(i_order_id => l_object_id);
             l_object_id     := l_payment_order.object_id;
             l_entity_type   := l_payment_order.entity_type;

             l_product_id :=
                 prd_api_product_pkg.get_product_id(
                     i_entity_type  => l_entity_type
                   , i_object_id    => l_object_id
                 );
         else
             l_product_id :=
                 prd_api_product_pkg.get_product_id(
                     i_entity_type  => l_entity_type
                   , i_object_id    => l_object_id
                 );
    end case;

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
end switch_cycle;

procedure create_operation
is
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_event_date                    date;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_customer_id                   com_api_type_pkg.t_medium_id;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_operation                     opr_api_type_pkg.t_oper_rec;
    l_oper_amount_name              com_api_type_pkg.t_name;
    l_oper_amount                   com_api_type_pkg.t_money;
    l_oper_currency                 com_api_type_pkg.t_curr_code;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_oper_type                     com_api_type_pkg.t_dict_value;
    l_oper_status                   com_api_type_pkg.t_dict_value;
    l_oper_reason                   com_api_type_pkg.t_dict_value;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_card_id                       com_api_type_pkg.t_medium_id;
    l_card_number                   com_api_type_pkg.t_card_number;
    l_merchant_id                   com_api_type_pkg.t_short_id;
    l_terminal_id                   com_api_type_pkg.t_short_id;
    l_terminal_number               com_api_type_pkg.t_terminal_number;
    l_terminal_type                 com_api_type_pkg.t_dict_value;
    l_merchant_number               com_api_type_pkg.t_merchant_number;
    l_merchant_name                 com_api_type_pkg.t_name;
    l_merchant_street               com_api_type_pkg.t_name;
    l_merchant_city                 com_api_type_pkg.t_name;
    l_merchant_country              com_api_type_pkg.t_country_code;
    l_merchant_postcode             com_api_type_pkg.t_postal_code;
    l_original_id                   com_api_type_pkg.t_long_id;
    l_participant_type              com_api_type_pkg.t_dict_value;
    l_forced_creating               com_api_type_pkg.t_boolean;
    l_process_operation             com_api_type_pkg.t_boolean;
    l_host_date                     date;
    l_account_name                  com_api_type_pkg.t_name;
    l_dpp                           dpp_api_type_pkg.t_dpp;

    procedure define_merchant
    is
    begin
        for rec in (
            select m.inst_id
                 , m.merchant_number
                 , m.merchant_name
                 , t.customer_id
              from acq_merchant_vw m
                 , prd_contract t
             where m.id = l_merchant_id
               and t.id = m.contract_id
        ) loop
            if l_inst_id is null then
                l_inst_id := rec.inst_id;
            end if;
            l_merchant_number := rec.merchant_number;
            l_merchant_name   := rec.merchant_name;
            l_customer_id     := rec.customer_id;
        end loop;

        for rec in (
            select a.street merchant_street
                 , a.city merchant_city
                 , a.country merchant_country
                 , a.postal_code merchant_postcode
              from com_address_vw a
             where a.id   = acq_api_merchant_pkg.get_merchant_address_id(
                                i_merchant_id => l_merchant_id
                            )
               and a.lang = com_ui_user_env_pkg.get_user_lang
        ) loop
            l_merchant_street   := rec.merchant_street;
            l_merchant_city     := rec.merchant_city;
            l_merchant_country  := rec.merchant_country;
            l_merchant_postcode := rec.merchant_postcode;
        end loop;
    end define_merchant;

begin
    l_host_date         := com_api_sttl_day_pkg.get_sysdate();

    l_object_id         := evt_api_shared_data_pkg.get_param_num ('OBJECT_ID');
    l_entity_type       := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type        := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_event_date        := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_inst_id           := evt_api_shared_data_pkg.get_param_num ('INST_ID');
    l_split_hash        := evt_api_shared_data_pkg.get_param_num ('SPLIT_HASH');
    l_oper_amount_name  := evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME');
    l_oper_type         := evt_api_shared_data_pkg.get_param_char('OPER_TYPE');
    l_oper_status       := evt_api_shared_data_pkg.get_param_char('OPERATION_STATUS');
    l_account_name      := evt_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');

    l_original_id       :=
        evt_api_shared_data_pkg.get_param_num(
            i_name          => 'ORIGINAL_ID'
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => null
        );

    l_oper_reason       :=
        nvl(
            evt_api_shared_data_pkg.get_param_char(
                i_name          => 'OPER_REASON'
              , i_mask_error    => com_api_const_pkg.TRUE
              , i_error_value   => l_oper_amount_name
            )
          , l_oper_amount_name
        );

    l_participant_type  :=
        evt_api_shared_data_pkg.get_param_char(
            i_name          => 'PARTY_TYPE'
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => com_api_const_pkg.PARTICIPANT_ISSUER
        );

    l_forced_creating   :=
        nvl(
            evt_api_shared_data_pkg.get_param_num(
                i_name         => 'FORCED_CREATING'
              , i_mask_error   => com_api_const_pkg.TRUE
              , i_error_value  => com_api_const_pkg.FALSE
            )
          , com_api_const_pkg.FALSE
        );

    evt_api_shared_data_pkg.get_amount(
        i_name         => l_oper_amount_name
      , o_amount       => l_oper_amount
      , o_currency     => l_oper_currency
    );

    evt_api_shared_data_pkg.get_account(
        i_name         => l_account_name
      , o_account_rec  => l_account
      , i_mask_error   => com_api_const_pkg.TRUE
    );

    case l_entity_type
        when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            begin
                if l_account.account_id is null then
                    l_account :=
                        acc_api_account_pkg.get_account(
                            i_account_id => l_object_id
                          , i_mask_error => com_api_const_pkg.FALSE
                        );
                end if;
                l_customer_id := l_account.customer_id;
            exception
                when com_api_error_pkg.e_application_error then
                    return;
            end;

        when prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            l_customer_id := l_object_id;

        when iss_api_const_pkg.ENTITY_TYPE_CARD then
            begin
                select c.id
                     , c.customer_id
                     , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
                  into l_card_id
                     , l_customer_id
                     , l_card_number
                  from iss_card c
                     , iss_card_number cn
                 where c.id = cn.card_id
                   and c.id = l_object_id;
            exception
                when no_data_found then
                    return;
            end;

        when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            begin
                select a.id
                     , a.customer_id
                     , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
                  into l_card_id
                     , l_customer_id
                     , l_card_number
                  from iss_card a
                     , iss_card_instance b
                     , iss_card_number cn
                 where a.id = b.card_id
                   and a.id = cn.card_id
                   and b.id = l_object_id;
            exception
                when no_data_found then
                    return;
            end;

        when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            l_merchant_id := l_object_id;

            define_merchant;

        when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
            l_terminal_id := l_object_id;

            for rec in (
                select t.inst_id
                     , t.terminal_number
                     , t.terminal_type
                     , m.id merchant_id
                  from acq_terminal_vw t
                     , acq_merchant m
                 where t.id          = l_terminal_id
                   and t.merchant_id = m.id
            ) loop
                if l_inst_id is null then
                    l_inst_id := rec.inst_id;
                end if;
                l_terminal_number := rec.terminal_number;
                l_terminal_type   := rec.terminal_type;
                l_merchant_id     := rec.merchant_id;
            end loop;

            define_merchant;

        when crd_api_const_pkg.ENTITY_TYPE_DEBT then
            begin
                select a.account_number
                     , a.customer_id
                     , a.id
                     , d.oper_id
                  into l_account.account_number
                     , l_customer_id
                     , l_account.account_id
                     , l_original_id
                  from acc_account a
                     , crd_debt d
                 where d.id = l_object_id
                   and a.id = d.account_id;
            exception
                when no_data_found then
                    return;
            end;

        when crd_api_const_pkg.ENTITY_TYPE_INVOICE then
            begin
                select a.account_number
                     , a.customer_id
                     , a.id
                  into l_account.account_number
                     , l_customer_id
                     , l_account.account_id
                  from acc_account a
                     , crd_invoice i
                 where i.id = l_object_id
                   and a.id = i.account_id;
            exception
                when no_data_found then
                    return;
            end;

        when dpp_api_const_pkg.ENTITY_TYPE_PAYMENT_PLAN then
            l_dpp :=
                dpp_api_payment_plan_pkg.get_dpp(
                    i_dpp_id     => l_object_id
                  , i_mask_error => com_api_const_pkg.TRUE
                );
            l_account :=
                acc_api_account_pkg.get_account(
                    i_account_id => l_dpp.account_id
                  , i_mask_error => com_api_const_pkg.TRUE
                );
            l_customer_id := l_account.customer_id;
            l_card_id     := l_dpp.card_id;

        else
            com_api_error_pkg.raise_error(
                i_error       => 'EVNT_WRONG_ENTITY_TYPE'
              , i_env_param1  => l_event_type
              , i_env_param2  => l_inst_id
              , i_env_param3  => l_entity_type
            );
    end case;

    if l_oper_amount > 0 or l_forced_creating = com_api_const_pkg.TRUE then
        opr_api_create_pkg.create_operation(
            io_oper_id             => l_oper_id
          , i_session_id           => get_session_id
          , i_original_id          => l_original_id
          , i_status               => nvl(l_oper_status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY)
          , i_sttl_type            => opr_api_const_pkg.SETTLEMENT_INTERNAL
          , i_msg_type             => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
          , i_oper_type            => l_oper_type
          , i_oper_reason          => l_oper_reason
          , i_oper_count           => 1
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_oper_request_amount  => l_oper_amount
          , i_is_reversal          => com_api_const_pkg.FALSE
          , i_oper_date            => l_event_date
          , i_host_date            => l_host_date
          , i_merchant_number      => l_merchant_number
          , i_merchant_name        => l_merchant_name
          , i_merchant_street      => l_merchant_street
          , i_merchant_city        => l_merchant_city
          , i_merchant_country     => l_merchant_country
          , i_merchant_postcode    => l_merchant_postcode
          , i_terminal_number      => l_terminal_number
          , i_terminal_type        => l_terminal_type
        );

        opr_api_create_pkg.add_participant(
            i_oper_id              => l_oper_id
          , i_msg_type             => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
          , i_oper_type            => l_oper_type
          , i_oper_reason          => l_oper_reason
          , i_participant_type     => nvl(l_participant_type, com_api_const_pkg.PARTICIPANT_ISSUER)
          , i_host_date            => l_host_date
          , i_inst_id              => l_inst_id
          , i_network_id           => ost_api_institution_pkg.get_inst_network(i_inst_id=> l_inst_id)
          , i_customer_id          => l_customer_id
          , i_card_id              => l_card_id
          , i_card_number          => l_card_number
          , i_card_mask            => iss_api_card_pkg.get_card_mask(l_card_number)
          , i_account_id           => l_account.account_id
          , i_account_number       => l_account.account_number
          , i_account_currency     => l_account.currency
          , i_account_type         => l_account.account_type
          , i_merchant_number      => l_merchant_number
          , i_merchant_id          => l_merchant_id
          , i_terminal_number      => l_terminal_number
          , i_terminal_id          => l_terminal_id
          , i_split_hash           => l_split_hash
          , i_without_checks       => com_api_const_pkg.TRUE
        );

        l_process_operation :=
            nvl(
                evt_api_shared_data_pkg.get_param_num(
                    i_name         => 'PROCESS_OPERATION'
                  , i_mask_error   => com_api_const_pkg.TRUE
                  , i_error_value  => com_api_const_pkg.FALSE
                )
              , com_api_const_pkg.FALSE
            );

        if l_process_operation = com_api_const_pkg.TRUE then
            -- After processing the operation should not be in status "No rules selected"
            opr_api_process_pkg.process_operation(
                i_operation_id => l_oper_id
              , i_commit_work  => com_api_const_pkg.FALSE
            );
            opr_api_operation_pkg.get_operation(
                i_oper_id      => l_oper_id
              , o_operation    => l_operation
            );
            if l_operation.status in (opr_api_const_pkg.OPERATION_STATUS_NO_RULES) then
                com_api_error_pkg.raise_error(
                    i_error        => 'ERROR_PROCESSING_OPERATION'
                  , i_env_param1   => l_oper_id
                  , i_env_param2   => null
                  , i_env_param3   => l_operation.status
                  , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id    => l_oper_id
                );
            end if;
        end if;
    end if;
end create_operation;

procedure write_trace is
    l_msg               com_api_type_pkg.t_text;
begin
    l_msg := evt_api_shared_data_pkg.get_param_char (
        i_name           => 'TEXT'
        , i_mask_error   => com_api_const_pkg.TRUE
        , i_error_value  => null
    );

    trc_log_pkg.debug (
        i_text          => nvl(l_msg, 'Event occurred') || ' [#1][#2][#3][#4][#5]'
        , i_env_param1  => evt_api_shared_data_pkg.get_param_char('EVENT_TYPE')
        , i_env_param2  => evt_api_shared_data_pkg.get_param_date('EVENT_DATE')
        , i_env_param3  => evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE')
        , i_env_param4  => evt_api_shared_data_pkg.get_param_num('OBJECT_ID')
        , i_env_param5  => evt_api_shared_data_pkg.get_param_num('INST_ID')
    );
end;

procedure check_sttl_day_holiday is
    l_mask_error        com_api_type_pkg.t_boolean;
    l_sttl_date         date;
    l_inst_id           com_api_type_pkg.t_inst_id;
begin
    l_mask_error := evt_api_shared_data_pkg.get_param_num('MASK_ERROR');
    l_sttl_date := evt_api_shared_data_pkg.get_param_date('OPENED_STTL_DATE');
    l_inst_id := evt_api_shared_data_pkg.get_param_num('INST_ID');

    if to_char(l_sttl_date, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') in ('SAT','SUN') then
        if l_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.warn (
                i_text          => 'STTL_DAY_NOT_BUSINESS'
                , i_env_param1  => to_char(l_sttl_date, com_api_const_pkg.DATE_FORMAT)
                , i_env_param2  => l_inst_id
            );
        else
            com_api_error_pkg.raise_error (
                i_error         => 'STTL_DAY_NOT_BUSINESS'
                , i_env_param1  => to_char(l_sttl_date, com_api_const_pkg.DATE_FORMAT)
                , i_env_param2  => l_inst_id
            );
        end if;
    end if;
end;

procedure check_sttl_day_exist is
    l_mask_error        com_api_type_pkg.t_boolean;
    l_sttl_date         date;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_count             pls_integer;
begin
    l_mask_error := evt_api_shared_data_pkg.get_param_num('MASK_ERROR');
    l_sttl_date := evt_api_shared_data_pkg.get_param_date('OPENED_STTL_DATE');
    l_inst_id := evt_api_shared_data_pkg.get_param_num('INST_ID');

    select
        count(*)
    into
        l_count
    from
        com_settlement_day_vw
    where
        trunc(sttl_date) = trunc(l_sttl_date)
        and inst_id = l_inst_id;

    if l_count > 0 then
        if l_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.warn (
                i_text          => 'DUPLICATE_STTL_DAY'
                , i_env_param1  => to_char(l_sttl_date, com_api_const_pkg.DATE_FORMAT)
                , i_env_param2  => l_inst_id
            );
        else
            com_api_error_pkg.raise_error (
                i_error         => 'DUPLICATE_STTL_DAY'
                , i_env_param1  => to_char(l_sttl_date, com_api_const_pkg.DATE_FORMAT)
                , i_env_param2  => l_inst_id
            );
        end if;
    end if;
end;

procedure find_untreated_entry is
    l_mask_error        com_api_type_pkg.t_boolean;
    l_sttl_date         date;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_count             pls_integer;
begin
    l_mask_error := evt_api_shared_data_pkg.get_param_num('MASK_ERROR');
    l_sttl_date := evt_api_shared_data_pkg.get_param_date('CLOSED_STTL_DATE');
    l_inst_id := evt_api_shared_data_pkg.get_param_num('INST_ID');

    select
        count(*)
    into
        l_count
    from(
        select
            1
        from
            acc_entry_buffer_vw
        where
            status in (acc_api_const_pkg.ENTRY_SOURCE_BUFFER, acc_api_const_pkg.ENTRY_SOURCE_EXCEPTION)
            and rownum = 1
    );

    if l_count > 0 then
        if l_mask_error = com_api_const_pkg.TRUE then
            -- In the bottom left untreated lockable entries
            trc_log_pkg.warn (
                i_text          => 'EXISTS_UNTREATED_ENTRIES'
                , i_env_param1  => to_char(l_sttl_date, com_api_const_pkg.DATE_FORMAT)
                , i_env_param2  => l_inst_id
            );
        else
            com_api_error_pkg.raise_error (
                i_error         => 'EXISTS_UNTREATED_ENTRIES'
                , i_env_param1  => to_char(l_sttl_date, com_api_const_pkg.DATE_FORMAT)
                , i_env_param2  => l_inst_id
            );
        end if;
    end if;
end;

procedure check_process is
    l_mask_error        com_api_type_pkg.t_boolean;
    l_sttl_date         date;
    l_process_id        com_api_type_pkg.t_short_id;
    l_count             pls_integer;
begin
    l_mask_error := evt_api_shared_data_pkg.get_param_num('MASK_ERROR');
    l_process_id := evt_api_shared_data_pkg.get_param_num('PROCESS_ID');
    l_sttl_date := evt_api_shared_data_pkg.get_param_date('CLOSED_STTL_DATE');

    select
        count(*)
    into
        l_count
    from
        prc_session_vw s
    where
        s.process_id = l_process_id
        and s.sttl_date = l_sttl_date
        and s.result_code = prc_api_const_pkg.PROCESS_RESULT_SUCCESS;

    if l_count = 0 then
        if l_mask_error = com_api_const_pkg.TRUE then
            -- Not found the successful completion of processes
            trc_log_pkg.warn (
                i_text          => 'PROCESS_RESULT_SUCCESS_NOT_FOUND'
                , i_env_param1  => to_char(l_sttl_date, com_api_const_pkg.DATE_FORMAT)
                , i_env_param2  => l_process_id
            );
        else
            com_api_error_pkg.raise_error (
                i_error         => 'PROCESS_RESULT_SUCCESS_NOT_FOUND'
                , i_env_param1  => to_char(l_sttl_date, com_api_const_pkg.DATE_FORMAT)
                , i_env_param2  => l_process_id
            );
        end if;
    end if;
end;

procedure check_rate is
    l_mask_error        com_api_type_pkg.t_boolean;
    l_sttl_date         date;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_result            number;
begin
    l_mask_error := evt_api_shared_data_pkg.get_param_num('MASK_ERROR');
    l_sttl_date := evt_api_shared_data_pkg.get_param_date('OPENED_STTL_DATE');
    l_inst_id := evt_api_shared_data_pkg.get_param_num('INST_ID');

    for r in (
        select
            rate_type
            , src_currency
            , dst_currency
        from
            com_rate_pair
        where
            inst_id = l_inst_id
            and req_regular_reg = com_api_const_pkg.TRUE
    ) loop
        l_result := com_api_rate_pkg.get_rate (
            i_src_currency       => r.src_currency
            , i_dst_currency     => r.dst_currency
            , i_rate_type        => r.rate_type
            , i_inst_id          => l_inst_id
            , i_eff_date         => l_sttl_date
            , i_mask_exception   => l_mask_error
        );
    end loop;
end;

procedure send_notification is
    l_object_id                     com_api_type_pkg.t_long_id;
    l_event_date                    date;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_mask_error                    com_api_type_pkg.t_boolean;
    l_party_type                    com_api_type_pkg.t_dict_value;
    l_src_entity_type               com_api_type_pkg.t_dict_value;
    l_src_object_id                 com_api_type_pkg.t_long_id;
    l_card_type_id                  com_api_type_pkg.t_tiny_id;
    l_param_tab                     com_api_type_pkg.t_param_tab;
    l_card_rec                      iss_api_type_pkg.t_card_rec;
begin

    l_object_id    := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type  := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type   := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_event_date   := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_inst_id      := evt_api_shared_data_pkg.get_param_num('INST_ID');

    if l_entity_type in ('ENTTCARD', 'ENTTCINS') then
        l_card_type_id := evt_api_shared_data_pkg.get_param_num('CARD_TYPE_ID');

        -- to pass to the make notifcation
        rul_api_param_pkg.set_param (
            i_name              => 'CARD_TYPE_ID'
          , io_params           => l_param_tab
          , i_value             => l_card_type_id
        );
    end if;

    l_mask_error   := evt_api_shared_data_pkg.get_param_num(
        i_name                => 'MASK_ERROR'
      , i_mask_error          => com_api_const_pkg.TRUE
      , i_error_value         => com_api_const_pkg.TRUE
    );
    l_party_type := evt_api_shared_data_pkg.get_param_char('PARTY_TYPE', com_api_const_pkg.TRUE);

    l_src_entity_type    := evt_api_shared_data_pkg.get_param_char(
                                  i_name       => 'SRC_ENTITY_TYPE'
                                , i_mask_error => com_api_const_pkg.TRUE
                              );
    l_src_object_id      := evt_api_shared_data_pkg.get_param_num(
                                  i_name       => 'SRC_OBJECT_ID'
                                , i_mask_error => com_api_const_pkg.TRUE
                              );

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE and (l_src_entity_type is null or l_src_object_id is null) then
        l_card_rec := iss_api_card_pkg.get_card(i_card_instance_id  => l_object_id);

        l_src_object_id   := l_card_rec.id;

        l_src_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD;
    end if;

    begin
        ntf_api_notification_pkg.make_notification_param(
            i_inst_id               => l_inst_id
            , i_event_type          => l_event_type
            , i_entity_type         => l_entity_type
            , i_object_id           => l_object_id
            , i_eff_date            => l_event_date
            , i_param_tab           => l_param_tab
            , i_urgency_level       => null
            , i_notify_party_type   => l_party_type
            , i_src_entity_type     => l_src_entity_type
            , i_src_object_id       => l_src_object_id
        );
    exception
        when others then
            if nvl(l_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
                trc_log_pkg.debug (
                    i_text         => 'Make notification error intercepted: [#1]'
                    , i_env_param1  => sqlerrm
                );
            else
                raise;
            end if;
    end;

end;

procedure send_user_notification is
    l_object_id                     com_api_type_pkg.t_long_id;
    l_event_date                    date;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_mask_error                    com_api_type_pkg.t_boolean;
begin

    l_object_id := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_event_date := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_inst_id := evt_api_shared_data_pkg.get_param_num('INST_ID');
    l_mask_error := evt_api_shared_data_pkg.get_param_num('MASK_ERROR', com_api_const_pkg.TRUE, com_api_const_pkg.TRUE);

    begin
        ntf_api_notification_pkg.make_user_notification (
            i_inst_id        => l_inst_id
            , i_event_type   => l_event_type
            , i_entity_type  => l_entity_type
            , i_object_id    => l_object_id
            , i_eff_date     => l_event_date
        );
    exception
        when others then
            if nvl(l_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
                trc_log_pkg.debug (
                    i_text         => 'Make notification error intercepted: [#1]'
                    , i_env_param1  => sqlerrm
                );
            else
                raise;
            end if;
    end;
end;

procedure set_host_status is
    l_entity_type  com_api_type_pkg.t_dict_value;
    l_object_id    com_api_type_pkg.t_long_id;
    l_params       com_api_type_pkg.t_param_tab;
    l_event_type   com_api_type_pkg.t_dict_value;
    l_host_id      com_api_type_pkg.t_long_id;

begin
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_event_type  := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        begin
            select m.id
              into l_host_id
              from acc_account a
                 , prd_customer c
                 , net_member m
             where c.id              = a.customer_id
               and c.ext_entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
               and c.ext_object_id   = m.inst_id
               and a.id              = l_object_id;
        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text       => 'HOST_BY_ACCOUNT_NOT_FOUND'
                  , i_env_param1  => l_entity_type
                  , i_env_param2  => l_object_id
                );
                return;
        end;
    end if;

    l_params := evt_api_shared_data_pkg.g_params;
    evt_api_status_pkg.change_status(
        i_event_type   => l_event_type
      , i_initiator    => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id    => l_host_id
      , i_reason       => null
      , i_eff_date     => get_sysdate
      , i_params       => l_params
    );
end;

procedure remove_cycle_counter is
    l_params                        com_api_type_pkg.t_param_tab;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_cycle_type                    com_api_type_pkg.t_dict_value;

begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id := rul_api_param_pkg.get_param_num ('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_split_hash := rul_api_param_pkg.get_param_num ('SPLIT_HASH', l_params);
    l_cycle_type := rul_api_param_pkg.get_param_char (
        i_name          => 'CYCLE_TYPE'
        , io_params     => l_params
        , i_mask_error  => com_api_const_pkg.TRUE
    );

    case l_entity_type
    when iss_api_const_pkg.ENTITY_TYPE_CARD then
        for instance in (
            select
                id
                , split_hash
            from
                iss_card_instance
            where
                card_id = l_object_id
        ) loop
            fcl_api_cycle_pkg.remove_cycle_counter (
                i_cycle_type     => l_cycle_type
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
            fcl_api_cycle_pkg.remove_cycle_counter (
                i_cycle_type     => l_cycle_type
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
                     , split_hash
                  into l_object_id
                     , l_split_hash
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
      , i_split_hash        => l_split_hash
    );

end;

procedure change_object_status is
    l_params                        com_api_type_pkg.t_param_tab;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_object_id_tab                 com_api_type_pkg.t_long_tab;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_entity_object_type            com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_event_object_type             com_api_type_pkg.t_dict_value;
    l_event_date                    date;
    l_inst_id                       com_api_type_pkg.t_inst_id;

begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := rul_api_param_pkg.get_param_num ('OBJECT_ID',   l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_type  := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_const_pkg.TRUE);

    l_event_object_type    := evt_api_shared_data_pkg.get_param_char(
                                  i_name       => 'EVENT_OBJECT_TYPE'
                                , i_mask_error => com_api_const_pkg.TRUE
                              );
    l_entity_object_type   := evt_api_shared_data_pkg.get_param_char(
                                  i_name       => 'ENTITY_OBJECT_TYPE'
                                , i_mask_error => com_api_const_pkg.TRUE
                              );

    case
        when l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE
        then
            select account_id
                 , acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              into l_object_id
                 , l_entity_type
              from crd_invoice
             where id = l_object_id;
        when l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
        then
            select id
                 , iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              into l_object_id
                 , l_entity_type
              from iss_card_instance
             where id = iss_api_card_instance_pkg.get_card_instance_id (i_card_id => l_object_id) ;
        else
             null;
    end case;

    case
        when l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
         and l_entity_object_type in (iss_api_const_pkg.ENTITY_TYPE_CARD, iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE)
         and l_event_object_type is not null
        then
            select ci.id
              bulk collect
              into l_object_id_tab
              from acc_account_object ao
                 , iss_card_instance ci
             where ao.account_id  = l_object_id
               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and ci.id          = iss_api_card_instance_pkg.get_card_instance_id (i_card_id => ao.object_id);
            l_entity_object_type := iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE;
        else
            null;
    end case;

    evt_api_status_pkg.change_status(
        i_event_type     => l_event_type
      , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type    => l_entity_type
      , i_object_id      => l_object_id
      , i_inst_id        => l_inst_id
      , i_reason         => null
      , i_eff_date       => l_event_date
      , i_params         => l_params
      , i_register_event => com_api_const_pkg.FALSE
    );

    if l_object_id_tab.count > 0 then
        for i in l_object_id_tab.first .. l_object_id_tab.last
        loop
            evt_api_status_pkg.change_status(
                i_event_type     => l_event_object_type
              , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type    => l_entity_object_type
              , i_object_id      => l_object_id_tab(i)
              , i_inst_id        => l_inst_id
              , i_reason         => null
              , i_eff_date       => l_event_date
              , i_params         => l_params
              , i_register_event => com_api_const_pkg.FALSE
            );
        end loop;
    end if;

end change_object_status;

procedure close_service is
    l_params                        com_api_type_pkg.t_param_tab;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_orig_entity_type              com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_check_cnt                     com_api_type_pkg.t_count := 0;
    l_event_date                    date;
    l_service_id                    com_api_type_pkg.t_medium_id;

begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := rul_api_param_pkg.get_param_num ('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_inst_id     := evt_api_shared_data_pkg.get_param_num('INST_ID');
    l_split_hash  := rul_api_param_pkg.get_param_num ('SPLIT_HASH', l_params);
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_service_id  := evt_api_shared_data_pkg.get_param_num(
        i_name        => 'SERVICE_ID'
      , i_mask_error => com_api_const_pkg.TRUE
    );
    l_orig_entity_type := l_entity_type;

    case l_entity_type
        when iss_api_const_pkg.ENTITY_TYPE_CARD then
            select
                count(id)
            into
                l_check_cnt
            from
                iss_card_instance
            where
                card_id = l_object_id
                and state != iss_api_const_pkg.CARD_STATE_CLOSED
                and rownum = 1;

            if l_check_cnt != 0 and l_service_id is null then
                l_entity_type := null;
            end if;

        when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            select
                min(i.card_id)
            into
                l_object_id
            from
                iss_card_instance i
            where
                i.id = l_object_id
                and not exists (
                    select
                        1
                    from
                        iss_card_instance x
                    where
                        x.card_id = i.card_id
                        and x.state != iss_api_const_pkg.CARD_STATE_CLOSED
                );

            l_entity_type :=
                case
                    when l_object_id is not null
                    then iss_api_const_pkg.ENTITY_TYPE_CARD
                    else null
                end;
        else
            trc_log_pkg.debug (
                i_text        => 'Entity transformation isn''t required for entity [#1]'
              , i_env_param1  => l_entity_type
            );
    end case;

    if l_entity_type is not null then
        prd_api_service_pkg.check_service_is_attached(
            i_service_id  => l_service_id
          , i_entity_type => l_entity_type
          , i_object_id   => l_object_id
          , i_event_date  => l_event_date
        );

        prd_api_service_pkg.close_service (
            i_entity_type   => l_entity_type
          , i_object_id     => l_object_id
          , i_inst_id       => l_inst_id
          , i_split_hash    => l_split_hash
          , i_service_id    => l_service_id
          , i_params        => evt_api_shared_data_pkg.g_params
        );

        trc_log_pkg.debug(
            i_text       => 'Closed [#1] for ([#2] : [#3])'
          , i_env_param1 => l_service_id
          , i_env_param2 => l_entity_type
          , i_env_param3 => l_object_id
        );
    end if;

    -- Closing, if necessary
    case l_entity_type
        when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            begin
                -- Check and close merchant with identifier is stored in evt_api_shared_data_pkg.g_params->OBJECT_ID
                acq_api_merchant_pkg.close_merchant(
                    i_mask_error  => com_api_const_pkg.FALSE -- enable to raise MERCHANT_NOT_FOUND
                );

            exception
                when com_api_error_pkg.e_application_error then
                    null;
            end;
        else
            trc_log_pkg.debug (
                i_text        => 'It is not available to close service/entity for [#1]'
              , i_env_param1  => l_orig_entity_type
            );
    end case;

end close_service;


procedure change_prev_instance_status
is
    l_secondary_event_type      com_api_type_pkg.t_dict_value;
    l_object_id                 com_api_type_pkg.t_long_id;
    l_entity_type               com_api_type_pkg.t_dict_value;
    l_instance_id               com_api_type_pkg.t_medium_id;
    l_event_type                com_api_type_pkg.t_dict_value;
    l_register_event            com_api_type_pkg.t_boolean;
    l_card_id                   com_api_type_pkg.t_medium_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
begin
    l_secondary_event_type  := evt_api_shared_data_pkg.get_param_char('SECONDARY_EVENT_TYPE');
    l_object_id             := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type           := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type            := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_register_event        := evt_api_shared_data_pkg.get_param_num('REGISTER_EVENT');
    l_inst_id               := evt_api_shared_data_pkg.get_param_num('INST_ID', com_api_const_pkg.TRUE);

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        begin
            select preceding_card_instance_id
              into l_instance_id
              from iss_card_instance
             where id = (select max(id) from iss_card_instance where card_id = l_object_id);

            l_card_id := l_object_id;

            if l_instance_id is not null then
               select min(id) keep (dense_rank first order by seq_number desc)
                 into l_instance_id
                 from iss_card_instance
                where card_id = l_card_id
                  and id     != l_instance_id;
            end if;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'CARD_NOT_FOUND'
                );
        end;

    elsif l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        begin
            select i.preceding_card_instance_id
              into l_instance_id
              from iss_card_instance i
             where id       = l_object_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'CARD_INSTANCE_NOT_FOUND'
                  , i_env_param1    => l_object_id
                );
        end;

    else
        com_api_error_pkg.raise_error(
            i_error         => 'EVNT_WRONG_ENTITY_TYPE'
        );
    end if;

    if l_instance_id is not null then
        evt_api_status_pkg.change_status(
            i_event_type     => l_secondary_event_type
          , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id      => l_instance_id
          , i_inst_id        => l_inst_id
          , i_reason         => l_event_type
          , i_params         => evt_api_shared_data_pkg.g_params
          , i_register_event => l_register_event
        );
    end if;

end change_prev_instance_status;

procedure init_limit_counter
is
    l_mask_error        com_api_type_pkg.t_boolean;
    l_limit_type        com_api_type_pkg.t_dict_value;
    l_event_date        date;
    l_params            com_api_type_pkg.t_param_tab;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_object_id         com_api_type_pkg.t_long_id;
    l_entity_type       com_api_type_pkg.t_dict_value;
    l_inst_id           com_api_type_pkg.t_inst_id;

    l_limit_id          com_api_type_pkg.t_long_id;
    l_product_id        com_api_type_pkg.t_short_id;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id     := rul_api_param_pkg.get_param_num ('OBJECT_ID',    l_params);
    l_entity_type   := rul_api_param_pkg.get_param_char('ENTITY_TYPE',  l_params);
    l_split_hash    := rul_api_param_pkg.get_param_num ('SPLIT_HASH',   l_params);
    l_inst_id       := rul_api_param_pkg.get_param_num ('INST_ID',      l_params);
    l_event_date    := rul_api_param_pkg.get_param_date('EVENT_DATE',   l_params);
    l_limit_type    := rul_api_param_pkg.get_param_char('LIMIT_TYPE',   l_params);
    --l_mask_error    := rul_api_param_pkg.get_param_num ('MASK_ERROR',   l_params);

    l_mask_error :=
        nvl(
            evt_api_shared_data_pkg.get_param_num(
                i_name         => 'MASK_ERROR'
              , i_mask_error   => com_api_const_pkg.TRUE
              , i_error_value  => com_api_const_pkg.FALSE
            )
          , com_api_const_pkg.FALSE
        );


    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type   => l_entity_type
          , i_object_id     => l_object_id
          , i_eff_date      => l_event_date
        );

    begin
        l_limit_id  :=
            prd_api_product_pkg.get_limit_id(
                i_product_id    => l_product_id
              , i_entity_type   => l_entity_type
              , i_object_id     => l_object_id
              , i_limit_type    => l_limit_type
              , i_params        => l_params
              , i_eff_date      => l_event_date
              , i_split_hash    => l_split_hash
              , i_inst_id       => l_inst_id
            );
    exception
        when com_api_error_pkg.e_application_error then
            if  com_api_error_pkg.get_last_error in (
                    'PRD_NO_ACTIVE_SERVICE'
                  , 'LIMIT_NOT_DEFINED'
                  , 'FEE_NOT_DEFINED'
                )
                and l_mask_error = com_api_const_pkg.TRUE
            then
                l_limit_id := null;
                trc_log_pkg.warn(
                    i_text          => 'Error [#1] has been masked'
                  , i_env_param1    => com_api_error_pkg.get_last_error
                );
            else
                raise;
            end if;
    end;

    if l_limit_id is not null then
        fcl_api_limit_pkg.add_limit_counter(
            i_limit_type    => l_limit_type
          , i_entity_type   => l_entity_type
          , i_object_id     => l_object_id
          , i_eff_date      => l_event_date
          , i_split_hash    => l_split_hash
          , i_inst_id       => l_inst_id
        );
    end if;
end init_limit_counter;

procedure get_account_balance_amount
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
begin
    acc_api_entry_pkg.flush_job;

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
      , i_amount    => l_amount.amount
      , i_currency  => l_amount.currency
    );
end get_account_balance_amount;

procedure deactive_delivery_address
is
    l_params                        com_api_type_pkg.t_param_tab;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_date                    date;
    l_sysdate                       date;
    l_contact_type                  com_api_type_pkg.t_dict_value;
begin
    l_params  := evt_api_shared_data_pkg.g_params;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    l_object_id    := rul_api_param_pkg.get_param_num ('OBJECT_ID', l_params);
    l_entity_type  := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_date   := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_contact_type := evt_api_shared_data_pkg.get_param_char('CONTACT_TYPE', com_api_const_pkg.TRUE);
    l_contact_type := nvl(l_contact_type, com_api_const_pkg.CONTACT_TYPE_NOTIFICATION);

    for c in (
        select c.commun_address
             , c.commun_method
             , c.contact_id
             , c.start_date
          from com_contact a
             , com_contact_object b
             , com_contact_data c
         where b.object_id = l_object_id
           and b.entity_type = l_entity_type
           and b.contact_type = l_contact_type
           and b.contact_id = a.id
           and c.contact_id = a.id
           and c.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
           and (c.end_date is null or c.end_date > l_sysdate)
    ) loop
        com_api_contact_pkg.modify_contact_data (
            i_contact_id     => c.contact_id
          , i_commun_method  => c.commun_method
          , i_commun_address => c.commun_address
          , i_start_date     => c.start_date
          , i_end_date       => l_event_date
        );
    end loop;

end deactive_delivery_address;

procedure close_account
is
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_event_date                    date;
    l_account_id                    com_api_type_pkg.t_medium_id;
begin
    l_object_id   := evt_api_shared_data_pkg.get_param_num ('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_inst_id     := evt_api_shared_data_pkg.get_param_num ('INST_ID');
    l_split_hash  := evt_api_shared_data_pkg.get_param_num ('SPLIT_HASH');
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then

        l_account_id := l_object_id;

        if l_inst_id is null then
            l_inst_id := acc_api_account_pkg.get_account(i_account_id => l_account_id).inst_id;
        end if;

        -- Closing cards
        for cur in (
            select o.entity_type
                 , o.object_id
                 , i.inst_id
                 , i.split_hash
                 , i.id card_instance_id
              from acc_account_object o
                 , iss_card_instance  i
             where o.account_id  = l_account_id
               and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and i.card_id     = o.object_id
               and i.state      != iss_api_const_pkg.CARD_STATE_CLOSED
        ) loop
            iss_api_card_pkg.deactivate_card(
                i_card_instance_id  => cur.card_instance_id
              , i_status            => null
            );

            prd_api_service_pkg.close_service(
                i_entity_type => cur.entity_type
              , i_object_id   => cur.object_id
              , i_inst_id     => cur.inst_id
              , i_split_hash  => cur.split_hash
              , i_eff_date    => l_event_date
              , i_params      => evt_api_shared_data_pkg.g_params
            );
        end loop;

        -- Close account and deactivate its services
        acc_api_account_pkg.set_account_status(
            i_account_id  => l_account_id
          , i_status      => acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
        );

        prd_api_service_pkg.close_service(
            i_entity_type => l_entity_type
          , i_object_id   => l_account_id
          , i_inst_id     => l_inst_id
          , i_split_hash  => l_split_hash
          , i_eff_date    => l_event_date
          , i_params      => evt_api_shared_data_pkg.g_params
        );

        acc_api_account_pkg.close_balance(
            i_account_id  => l_account_id
        );

    else
        com_api_error_pkg.raise_error(
            i_error       => 'ACCOUNT_NOT_FOUND'
          , i_env_param1  => l_object_id
          , i_env_param2  => l_entity_type
        );
    end if;
end close_account;

procedure reset_cycle_counter is

    l_params                        com_api_type_pkg.t_param_tab;
    l_cycle_type                    com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;

begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_cycle_type  := rul_api_param_pkg.get_param_char('CYCLE_TYPE', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_split_hash  := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);

    trc_log_pkg.debug (
        i_text           => 'Going to reset cycle counter [#1][#2][#3][#4]'
        , i_env_param1   => l_cycle_type
        , i_env_param2   => l_entity_type
        , i_env_param3   => l_object_id
        , i_env_param4   => l_split_hash
    );

    fcl_api_cycle_pkg.reset_cycle_counter(
        i_cycle_type     => l_cycle_type
      , i_entity_type    => l_entity_type
      , i_object_id      => l_object_id
      , i_split_hash     => l_split_hash
    );
end;

procedure add_transmission_data is

    l_params                        com_api_type_pkg.t_param_tab;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_event_date                    date;

begin

    l_params := evt_api_shared_data_pkg.g_params;

    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_split_hash  := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');

    trc_log_pkg.debug (
        i_text           => 'add_transmission_data entity_type[#1] object_id[#2] split_hash[#3] event_date[#4]'
        , i_env_param1   => l_entity_type
        , i_env_param2   => l_object_id
        , i_env_param3   => l_split_hash
        , i_env_param4   => l_event_date
    );

    insert into itf_data_transmission(
        id
      , entity_type
      , object_id
      , eff_date
      , is_sent
      , is_received
    )
    values(
        itf_data_transmission_seq.nextval
      , l_entity_type
      , l_object_id
      , l_event_date
      , com_api_const_pkg.FALSE
      , com_api_const_pkg.FALSE
    );

exception
    when dup_val_on_index then
        trc_log_pkg.debug (
            i_text           => 'add_transmission_data entity_type[#1] object_id[#2] - value is present already'
            , i_env_param1   => l_entity_type
            , i_env_param2   => l_object_id
        );
end add_transmission_data;

procedure switch_cycle_birthday is

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
    l_cycle_id                      com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_birthday                      date;
    l_is_person                     com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE;
    l_prev_date                     date;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_date  := rul_api_param_pkg.get_param_date('EVENT_DATE', l_params);
    l_split_hash  := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);
    l_cycle_type  := lty_api_const_pkg.LOYALTY_BIRTHDAY_CYCLE_TYPE;
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_const_pkg.TRUE);

    l_test_mode :=
        evt_api_shared_data_pkg.get_param_char(
            i_name        => 'ATTR_MISS_TESTMODE'
          , i_mask_error  => com_api_const_pkg.TRUE
          , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
        );
    l_test_mode := nvl(l_test_mode, fcl_api_const_pkg.ATTR_MISS_RISE_ERROR);

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        begin
            select p.birthday
              into l_birthday
              from prd_customer c
                 , com_person p
             where c.id = iss_api_card_pkg.get_customer_id(i_card_id => l_object_id)
               and c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
               and p.id = c.object_id;
        exception
            when no_data_found then
                l_is_person := com_api_const_pkg.FALSE;
        end;
    elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        begin
            select p.birthday
              into l_birthday
              from prd_customer c
                 , com_person p
                 , acc_account a
             where a.id = l_object_id
               and c.id = a.customer_id
               and c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
               and p.id = c.object_id;
        exception
            when no_data_found then
                l_is_person := com_api_const_pkg.FALSE;
        end;
    end if;

    if l_is_person = com_api_const_pkg.TRUE then
        if l_birthday is null then
            if l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                com_api_error_pkg.raise_error(
                    i_error     => 'PERSON_BIRTHDAY_IS_EMPTY'
                );
            end if;
        else
            l_product_id :=
                prd_api_product_pkg.get_product_id(
                    i_entity_type  => l_entity_type
                  , i_object_id    => l_object_id
                );

            begin
                l_cycle_id :=
                    prd_api_product_pkg.get_cycle_id(
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

            l_next_date := l_birthday;

            loop
                l_prev_date := l_next_date;
                l_next_date := fcl_api_cycle_pkg.calc_next_date(
                                   i_cycle_id     => l_cycle_id
                                 , i_start_date   => l_prev_date
                                 , i_forward      => com_api_const_pkg.TRUE
                                 , i_raise_error  => com_api_const_pkg.FALSE
                               );
                exit when l_next_date >= com_api_sttl_day_pkg.get_sysdate or l_next_date is null;
            end loop;

            fcl_api_cycle_pkg.switch_cycle (
                i_cycle_type         => l_cycle_type
                , i_product_id       => l_product_id
                , i_entity_type      => l_entity_type
                , i_object_id        => l_object_id
                , i_params           => l_params
                , i_start_date       => nvl(l_prev_date, l_birthday)
                , i_eff_date         => l_event_date
                , i_split_hash       => l_split_hash
                , i_inst_id          => l_inst_id
                , i_service_id       => l_service_id
                , o_new_finish_date  => l_next_date
                , i_test_mode        => l_test_mode
                , i_cycle_id         => l_cycle_id
            );
        end if;
    end if;
exception
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error != 'PRD_NO_ACTIVE_SERVICE' then
            raise;
        end if;
end switch_cycle_birthday;

procedure change_card_delivery_status is
    l_params                 com_api_type_pkg.t_param_tab;
    l_object_id              com_api_type_pkg.t_long_id;
    l_entity_type            com_api_type_pkg.t_dict_value;
    l_split_hash             com_api_type_pkg.t_tiny_id;
    l_event_type             com_api_type_pkg.t_dict_value;
    l_inst_id                com_api_type_pkg.t_inst_id;
    l_old_status             com_api_type_pkg.t_dict_value;
    l_new_status             com_api_type_pkg.t_dict_value;
    l_initiator              com_api_type_pkg.t_dict_value;
    l_eff_date               date;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_split_hash  := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_const_pkg.TRUE);
    l_new_status  := rul_api_param_pkg.get_param_char('CARD_DELIVERY_STATUS', l_params);
    l_eff_date    := com_api_sttl_day_pkg.get_calc_date(
                         i_inst_id => l_inst_id
                     );
    l_initiator   := evt_api_const_pkg.INITIATOR_SYSTEM;
    l_event_type  := iss_api_const_pkg.EVENT_DELIVERY_STATUS_CHANGE;

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        l_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE;
        l_object_id :=
            iss_api_card_instance_pkg.get_card_instance_id(
                i_card_id => l_object_id
            );
    end if;

    l_old_status :=
        iss_api_card_instance_pkg.get_instance(
            i_id          => l_object_id
          , i_raise_error => com_api_const_pkg.TRUE
        ).delivery_status;
    l_old_status := nvl(l_old_status, iss_api_const_pkg.CARD_DELIVERY_STATUS_PERS);

    if l_old_status != l_new_status or l_new_status is null then
        begin
            select initiator
              into l_initiator
              from evt_status_map e
             where initial_status = l_old_status
               and result_status  = l_new_status
               and initiator      = l_initiator
               and event_type     = l_event_type
               and inst_id in (l_inst_id, ost_api_const_pkg.DEFAULT_INST)
               and rownum = 1;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'ILLEGAL_STATUS_COMBINATION'
                  , i_env_param1 => l_entity_type
                  , i_env_param2 => l_old_status
                  , i_env_param3 => l_new_status
                );
        end;

        update iss_card_instance
           set delivery_status = l_new_status
         where id = l_object_id;

        trc_log_pkg.debug('Change status to ' || l_new_status || ' for ' || get_article_text(l_entity_type) || ' ' || l_object_id);

        evt_api_status_pkg.add_status_log(
            i_event_type    => l_event_type
          , i_initiator     => l_initiator
          , i_entity_type   => l_entity_type
          , i_object_id     => l_object_id
          , i_reason        => l_event_type
          , i_status        => l_new_status
          , i_eff_date      => l_eff_date
        );

        evt_api_event_pkg.register_event(
            i_event_type   => l_event_type
          , i_eff_date     => l_eff_date
          , i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
          , i_inst_id      => l_inst_id
          , i_split_hash   => l_split_hash
          , i_param_tab    => l_params
        );
    else
        trc_log_pkg.debug(
            i_text        => 'Change of status is not required - old status[#1] new status[#2]'
          , i_env_param1  => l_old_status
          , i_env_param2  => l_new_status
        );
    end if;
end change_card_delivery_status;

procedure change_statmnt_delivery_status is
    l_params                 com_api_type_pkg.t_param_tab;
    l_object_id              com_api_type_pkg.t_long_id;
    l_entity_type            com_api_type_pkg.t_dict_value;
    l_split_hash             com_api_type_pkg.t_tiny_id;
    l_event_type             com_api_type_pkg.t_dict_value;
    l_inst_id                com_api_type_pkg.t_inst_id;
    l_new_status             com_api_type_pkg.t_dict_value;
    l_initiator              com_api_type_pkg.t_dict_value;
    l_eff_date               date;
    l_ntf_msg_id             com_api_type_pkg.t_long_id;
    l_ntf_msg_status         com_api_type_pkg.t_dict_value;
    l_reg_event              com_api_type_pkg.t_boolean;
    l_deliv_status           com_api_type_pkg.t_dict_value;
    l_prod_deliv_status      com_api_type_pkg.t_dict_value;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_split_hash  := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_const_pkg.TRUE);
    l_new_status  := rul_api_param_pkg.get_param_char('STATEMENT_DELIVERY_STATUS', l_params);
    l_reg_event   := nvl(
                         rul_api_param_pkg.get_param_num('REGISTER_EVENT_EQUAL_VALUES', l_params)
                       , com_api_const_pkg.FALSE
                     );

    l_deliv_status := rul_api_param_pkg.get_param_char('CRD_INVOICING_DELIVERY_STMTD', l_params);

    l_eff_date    := com_api_sttl_day_pkg.get_calc_date(
                         i_inst_id => l_inst_id
                     );
    l_initiator   := evt_api_const_pkg.INITIATOR_SYSTEM;
    l_event_type  := ntf_api_const_pkg.EVNT_CHNG_STTMT_DELIV_STATUS;

    -- find last invoices
    for r in (
        select invoice_id
             , account_id
          from (
              select crd_invoice_pkg.get_last_invoice_id(
                         i_account_id => ao.account_id
                       , i_split_hash => ao.split_hash
                       , i_mask_error => com_api_const_pkg.TRUE
                     ) as invoice_id
                     , account_id
                from (
                         select c.id as card_id
                           from iss_card c
                          where c.customer_id = l_object_id
                            and l_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                           union all
                         select c.id as card_id
                           from iss_card c
                          where c.cardholder_id = l_object_id
                            and l_entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                     ) c
                   , acc_account_object ao
                   , acc_account a
               where c.card_id      = ao.object_id
                 and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                 and ao.account_id  = a.id
          ) i
         where invoice_id is not null
    )
    loop
        trc_log_pkg.debug('found invoice ' || r.invoice_id || ' for account ' || r.account_id);

        if l_deliv_status is not null then
            l_prod_deliv_status := prd_api_product_pkg.get_attr_value_char(
                                       i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                     , i_object_id   => r.account_id
                                     , i_attr_name   => 'CRD_INVOICING_DELIVERY_STATEMENT_METHOD'
                                     , i_mask_error  => com_api_const_pkg.TRUE
                                   );
            trc_log_pkg.debug('delivery status ' || l_prod_deliv_status);
        end if;

        if l_deliv_status is null or l_deliv_status = l_prod_deliv_status
        then

            -- find message for invoice
            begin
                select id
                     , message_status
                  into l_ntf_msg_id
                     , l_ntf_msg_status
                  from (
                           select m.id, m.message_status
                             from ntf_message m
                            where m.object_id   = r.invoice_id
                              and m.entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE
                           order by m.delivery_date desc
                       )
                 where rownum = 1;
            exception
                when no_data_found then
                    l_ntf_msg_id     := null;
                    l_ntf_msg_status := null;
            end;

            if l_ntf_msg_id is not null then
                if l_ntf_msg_status != l_new_status then
                    begin
                        select initiator
                          into l_initiator
                          from evt_status_map e
                         where initial_status = l_ntf_msg_status
                           and result_status  = l_new_status
                           and initiator      = l_initiator
                           and event_type     = l_event_type
                           and inst_id in (l_inst_id, ost_api_const_pkg.DEFAULT_INST)
                           and rownum = 1;
                    exception
                        when no_data_found then
                            com_api_error_pkg.raise_error(
                                i_error      => 'ILLEGAL_STATUS_COMBINATION'
                              , i_env_param1 => l_entity_type
                              , i_env_param2 => l_ntf_msg_status
                              , i_env_param3 => l_new_status
                            );
                    end;

                    trc_log_pkg.debug('Change message status to ' || l_new_status || ' for message' || l_ntf_msg_id);

                    update ntf_message
                       set message_status = l_new_status
                     where id = l_ntf_msg_id;
                end if;

                if l_ntf_msg_status != l_new_status or l_reg_event = com_api_const_pkg.TRUE then
                    evt_api_event_pkg.register_event(
                        i_event_type   => l_event_type
                      , i_eff_date     => l_eff_date
                      , i_entity_type  => ntf_api_const_pkg.ENTITY_TYPE_NTF_MESSAGE
                      , i_object_id    => l_ntf_msg_id
                      , i_inst_id      => l_inst_id
                      , i_split_hash   => l_split_hash
                      , i_param_tab    => l_params
                    );
                end if;
            end if;
        end if;
    end loop;
end change_statmnt_delivery_status;

procedure split_terminal_revenue_cycled
is
    l_params                 com_api_type_pkg.t_param_tab;
    l_object_id              com_api_type_pkg.t_long_id;
    l_entity_type            com_api_type_pkg.t_dict_value;
    l_split_hash             com_api_type_pkg.t_tiny_id;
    l_event_type             com_api_type_pkg.t_dict_value;
    l_inst_id                com_api_type_pkg.t_inst_id;
    l_oper_type              com_api_type_pkg.t_dict_value;
    l_oper_type_to_create    com_api_type_pkg.t_dict_value;
    l_eff_date_name          com_api_type_pkg.t_dict_value;
    l_eff_date               date;
    l_date_beg               date;
    l_date_end               date;
    l_event_date             date;
    l_start_id               com_api_type_pkg.t_long_id;
    l_end_id                 com_api_type_pkg.t_long_id;
    l_rate_type              com_api_type_pkg.t_dict_value;
    l_conversion_type        com_api_type_pkg.t_dict_value;
    l_fee_type               com_api_type_pkg.t_name;
    l_fee_id                 com_api_type_pkg.t_medium_id;
    l_cust_account           acc_api_type_pkg.t_account_rec;
    l_amount_tab             com_api_type_pkg.t_money_tab;
    l_curr_code_tab          com_api_type_pkg.t_curr_code_tab;
    l_count_tab              com_api_type_pkg.t_count_tab;
    l_last_terminal_id       com_api_type_pkg.t_long_id;
    l_cust_oper_amount       com_api_type_pkg.t_money;
    l_cust_oper_count        com_api_type_pkg.t_count := 0;
    l_fee_amount             com_api_type_pkg.t_money;
    l_oper_id                com_api_type_pkg.t_long_id;
    l_merchant_street        com_api_type_pkg.t_name;
    l_merchant_city          com_api_type_pkg.t_name;
    l_merchant_country       com_api_type_pkg.t_country_code;
    l_merchant_postcode      com_api_type_pkg.t_postal_code;
    l_address_id             com_api_type_pkg.t_long_id;
    l_lang                   com_api_type_pkg.t_dict_value;
begin
    l_params              := evt_api_shared_data_pkg.g_params;
    l_event_date          := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_object_id           := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type         := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_type          := rul_api_param_pkg.get_param_char('EVENT_TYPE', l_params);
    l_split_hash          := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);
    l_inst_id             := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_const_pkg.TRUE);
    l_oper_type           := rul_api_param_pkg.get_param_char('OPER_TYPE', l_params);
    l_oper_type_to_create := rul_api_param_pkg.get_param_char('OPER_TYPE_TO_CREATE', l_params);
    l_eff_date_name       := rul_api_param_pkg.get_param_char('DATE_NAME', l_params);
    l_fee_type            := rul_api_param_pkg.get_param_char('FEE_TYPE', l_params);
    l_rate_type           := rul_api_param_pkg.get_param_char('RATE_TYPE', l_params);
    l_conversion_type     := rul_api_param_pkg.get_param_char('CONVERSION_TYPE', l_params, com_api_const_pkg.TRUE);

    if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_eff_date :=
            com_api_sttl_day_pkg.get_open_sttl_date(
                i_inst_id   => l_inst_id
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

    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type  => l_event_type
      , i_entity_type => l_entity_type
      , i_object_id   => l_object_id
      , i_split_hash  => l_split_hash
      , i_add_counter => com_api_const_pkg.FALSE
      , o_prev_date   => l_date_beg
      , o_next_date   => l_date_end
    );

    trc_log_pkg.debug('date period ' || to_char(l_date_beg, com_api_const_pkg.XML_DATETIME_FORMAT)
                            || ' - ' || to_char(l_date_end, com_api_const_pkg.XML_DATETIME_FORMAT));

    l_start_id   := com_api_id_pkg.get_from_id(l_date_beg);
    l_end_id     := com_api_id_pkg.get_till_id(l_date_end);

    trc_log_pkg.debug('id period ' || l_start_id || ' - ' || l_end_id);

    for r in
    (
        select distinct
               r.terminal_id
             , t.terminal_number
             , t.terminal_type
             , t.inst_id as term_inst_id
             , t.split_hash as term_split_hash
             , t.merchant_id
             , m.merchant_number
             , m.merchant_name
             , r.customer_id
             , r.account_id
             , a.account_number
             , a.inst_id
          from acq_terminal t
             , acq_merchant m
             , acq_revenue_sharing r
             , acc_account a
         where r.customer_id   = l_object_id
           and t.id            = r.terminal_id
           and r.fee_type      = l_fee_type
           and r.inst_id       = l_inst_id
           and t.merchant_id   = m.id
           and r.account_id    = a.id
         order by r.terminal_id, r.customer_id, r.account_id
    )
    loop
        trc_log_pkg.debug('revenue sharing for terminal ' || r.terminal_id ||
                          '; customer_id ' || r.customer_id|| '; account_id ' || r.account_id);
        l_cust_oper_amount := 0;
        l_cust_oper_count  := 0;
        l_oper_id := null;

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
        rul_api_param_pkg.set_param(
            i_name      => 'TERMINAL_ID'
          , i_value     => r.terminal_id
          , io_params   => l_params
        );
        acq_api_revenue_sharing_pkg.get_fee_id(
            i_customer_id => r.customer_id
          , i_terminal_id => r.terminal_id
          , i_account_id  => r.account_id
          , i_fee_type    => l_fee_type
          , i_inst_id     => l_inst_id
          , i_params      => l_params
          , i_raise_error => com_api_const_pkg.TRUE
          , o_fee_id      => l_fee_id
          , i_eff_date    => l_eff_date
        );

        if l_fee_id is not null then
            -- for each terminal get operations in each currency once
            if l_last_terminal_id <> r.terminal_id or l_last_terminal_id is null then
                select sum(o.oper_amount)
                     , o.oper_currency
                     , count(*)
                  bulk collect into
                       l_amount_tab
                     , l_curr_code_tab
                     , l_count_tab
                  from opr_participant p
                     , opr_operation o
                 where p.terminal_id      = r.terminal_id
                   and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                   and p.split_hash       = r.term_split_hash
                   and p.oper_id          = o.id
                   and (o.oper_type       = l_oper_type or l_oper_type is null)
                   and o.status           = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                   and o.oper_date between l_date_beg and l_date_end
                   and p.oper_id   between l_start_id and l_end_id
                 group by oper_currency;

                l_address_id := acq_api_merchant_pkg.get_merchant_address_id(
                                    i_merchant_id => r.merchant_id
                                );
                l_lang := com_ui_user_env_pkg.get_user_lang;
                for rec in (
                    select a.street merchant_street
                         , a.city merchant_city
                         , a.country merchant_country
                         , a.postal_code merchant_postcode
                      from com_address_vw a
                     where a.id = l_address_id
                       and a.lang = l_lang
                )
                loop
                    l_merchant_street := rec.merchant_street;
                    l_merchant_city := rec.merchant_city;
                    l_merchant_country := rec.merchant_country;
                    l_merchant_postcode := rec.merchant_postcode;
                end loop;

                l_last_terminal_id := r.terminal_id;
            end if;

            trc_log_pkg.debug('l_fee_id: ' || l_fee_id || ' l_amount_tab.count = ' || l_amount_tab.count);

            if l_amount_tab.count > 0 then
                l_cust_account :=
                    acc_api_account_pkg.get_account(
                        i_account_id     => r.account_id
                      , i_mask_error     => com_api_const_pkg.FALSE
                    );
                -- for each currency perform conversion in customer account currency
                for i in l_amount_tab.first .. l_amount_tab.last
                loop
                    trc_log_pkg.debug('oper_amount: ' || l_amount_tab(i) || ' ' || l_curr_code_tab(i));
                    l_cust_oper_count  := l_cust_oper_count + l_count_tab(i);
                    if l_curr_code_tab(i) = l_cust_account.currency then
                        l_cust_oper_amount := l_cust_oper_amount + l_amount_tab(i);
                    else
                        l_cust_oper_amount :=
                            l_cust_oper_amount
                          + round(
                                com_api_rate_pkg.convert_amount(
                                    i_src_amount      => l_amount_tab(i)
                                  , i_src_currency    => l_curr_code_tab(i)
                                  , i_dst_currency    => l_cust_account.currency
                                  , i_rate_type       => l_rate_type
                                  , i_inst_id         => l_inst_id
                                  , i_eff_date        => l_eff_date
                                  , i_conversion_type => l_conversion_type
                                )
                            );
                    end if;
                end loop;

                l_fee_amount := round(
                    fcl_api_fee_pkg.get_fee_amount(
                        i_fee_id          => l_fee_id
                      , i_base_amount     => l_cust_oper_amount
                      , i_base_count      => l_cust_oper_count
                      , io_base_currency  => l_cust_account.currency
                    )
                );
                trc_log_pkg.debug('l_fee_amount: ' || l_fee_amount);

                if l_fee_amount <> 0 then
                    opr_api_create_pkg.create_operation(
                        io_oper_id            => l_oper_id
                      , i_status              => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                      , i_sttl_type           => opr_api_const_pkg.SETTLEMENT_INTERNAL
                      , i_msg_type            => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                      , i_oper_type           => l_oper_type_to_create
                      , i_oper_amount         => l_fee_amount
                      , i_oper_currency       => l_cust_account.currency
                      , i_oper_request_amount => l_fee_amount
                      , i_is_reversal         => com_api_const_pkg.FALSE
                      , i_oper_date           => l_eff_date
                      , i_host_date           => l_event_date
                      , i_merchant_number     => r.merchant_number
                      , i_merchant_name       => r.merchant_name
                      , i_merchant_street     => l_merchant_street
                      , i_merchant_city       => l_merchant_city
                      , i_merchant_country    => l_merchant_country
                      , i_merchant_postcode   => l_merchant_postcode
                      , i_terminal_number     => r.terminal_number
                      , i_terminal_type       => r.terminal_type
                    );

                    opr_api_create_pkg.add_participant(
                        i_oper_id             => l_oper_id
                      , i_msg_type            => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                      , i_oper_type           => l_oper_type_to_create
                      , i_participant_type    => com_api_const_pkg.PARTICIPANT_ACQUIRER
                      , i_host_date           => l_event_date
                      , i_merchant_id         => r.merchant_id
                      , i_merchant_number     => r.merchant_number
                      , i_terminal_id         => r.terminal_id
                      , i_terminal_number     => r.terminal_number
                      , i_without_checks      => com_api_const_pkg.TRUE
                      , i_inst_id             => r.term_inst_id
                      , i_network_id          => ost_api_institution_pkg.get_inst_network(i_inst_id => r.term_inst_id)
                    );

                    opr_api_create_pkg.add_participant(
                        i_oper_id             => l_oper_id
                      , i_msg_type            => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                      , i_oper_type           => l_oper_type_to_create
                      , i_participant_type    => com_api_const_pkg.PARTICIPANT_DEST
                      , i_host_date           => l_event_date
                      , i_customer_id         => r.customer_id
                      , i_account_id          => r.account_id
                      , i_account_number      => r.account_number
                      , i_without_checks      => com_api_const_pkg.TRUE
                      , i_inst_id             => r.inst_id
                      , i_network_id          => ost_api_institution_pkg.get_inst_network(i_inst_id => r.inst_id)
                    );
                end if;
            end if;
        end if;
    end loop;
end split_terminal_revenue_cycled;

procedure gen_acq_min_amount_event is

    LOG_PREFIX               constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.gen_acq_min_amount_event: ';

    l_params                 com_api_type_pkg.t_param_tab;
    l_object_id              com_api_type_pkg.t_long_id;
    l_entity_type            com_api_type_pkg.t_dict_value;
    l_split_hash             com_api_type_pkg.t_tiny_id;
    l_event_type             com_api_type_pkg.t_dict_value;
    l_reg_event_type         com_api_type_pkg.t_dict_value;
    l_reg_entity_type        com_api_type_pkg.t_dict_value;
    l_reg_object_id          com_api_type_pkg.t_long_id;
    l_inst_id                com_api_type_pkg.t_inst_id;
    l_eff_date               date;

    l_reg_event_object_id    com_api_type_pkg.t_long_id;
    l_avl_acc_balance        com_api_type_pkg.t_money;
    l_threshold_amount       com_api_type_pkg.t_money;
    l_subscriber_name        com_api_type_pkg.t_name;

begin

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX ||'Start'
    );

    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_split_hash  := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_const_pkg.TRUE);
    l_eff_date    := com_api_sttl_day_pkg.get_calc_date(
                         i_inst_id => l_inst_id
                     );
    l_event_type  := rul_api_param_pkg.get_param_char('EVENT_TYPE', l_params);

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX ||'Inital params event_type [#1'
                      || '], inst_id [#2'
                      || '], eff_date [#3'
                      || '], split_hash [#4'
                      || ']'
      , i_env_param1  => l_event_type
      , i_env_param2  => l_inst_id
      , i_env_param3  => l_eff_date
      , i_env_param4  => l_split_hash
      , i_entity_type => l_entity_type
      , i_object_id   => l_object_id
    );

    if l_event_type = acc_api_const_pkg.EVENT_ENTRY_POSTING
        and l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ENTRY
    then

        l_reg_event_type  := acc_api_const_pkg.EVENT_MIN_THRESHOLD_OVERCOMING;
        l_reg_entity_type := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
        l_subscriber_name := ntf_api_const_pkg.ACC_THRESHOLD_OVER_NTF_PROC;

        select ae.account_id
             , e.id
             , trunc(
                   acc_api_balance_pkg.get_aval_balance_amount_only(
                       i_account_id => ae.account_id
                   ) / power(10, cr.exponent)
                 , 2
               )
             , prd_api_product_pkg.get_attr_value_number(
                   i_entity_type       => l_reg_entity_type
                 , i_object_id         => ae.account_id
                 , i_attr_name         => acq_api_const_pkg.ACQ_ACC_MIN_AMOUNT_THRESHOLD
                 , i_mask_error        => com_api_const_pkg.TRUE
               )
          into l_reg_object_id
             , l_reg_event_object_id
             , l_avl_acc_balance
             , l_threshold_amount
          from acc_entry ae
             , (select eo.id, eo.object_id
                  from evt_event ee
                     , evt_event_object eo
                 where eo.event_id = ee.id
                   and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
                   and ee.event_type = l_reg_event_type
                   and eo.entity_type = l_reg_entity_type
                   and eo.eff_date  <= l_eff_date
               ) e
             , acc_account a
             , com_currency cr
         where ae.id         = l_object_id
           and ae.account_id = e.object_id (+)
           and a.id          = ae.account_id
           and cr.code       = a.currency
           and rownum        = 1
        ;

        if l_threshold_amount is not null
            and l_reg_event_object_id is null
            and l_avl_acc_balance <= l_threshold_amount
        then

            evt_api_event_pkg.register_event(
                i_event_type   => l_reg_event_type
              , i_eff_date     => l_eff_date
              , i_entity_type  => l_reg_entity_type
              , i_object_id    => l_reg_object_id
              , i_inst_id      => l_inst_id
              , i_split_hash   => l_split_hash
              , i_param_tab    => l_params
            );

        elsif l_reg_event_object_id is not null
            and ((l_threshold_amount is not null and l_avl_acc_balance > l_threshold_amount)
                    or l_threshold_amount is null
                )
        then

            evt_api_event_pkg.process_event_object(
                i_event_object_id => l_reg_event_object_id
            );

            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'Changed of status of the having event object: event_type [#1'
                              || '], event_object_id [#2'
                              || ']'
              , i_env_param1  => l_reg_event_type
              , i_env_param2  => l_reg_event_object_id
            );

        else
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'Not require act'
            );
        end if;
    else

        com_api_error_pkg.raise_error(
            i_error      => 'EVENT_TYPE_NOT_SUPPORT_IN_PROC'
          , i_env_param1 => l_event_type
          , i_env_param2 => l_entity_type
          , i_env_param3 => replace(LOG_PREFIX, ': ')
        );

    end if;

end gen_acq_min_amount_event;

procedure calculate_facilitator_fee is

    l_object_id                     com_api_type_pkg.t_long_id;
    l_account_id                    com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_name;
    l_params                        com_api_type_pkg.t_param_tab;
    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    l_fee_type                      com_api_type_pkg.t_name;
    l_fee_id                        com_api_type_pkg.t_long_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_event_date                    date;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_service_type_id               com_api_type_pkg.t_short_id;
    l_start_date                    date;
    l_end_date                      date;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_original_id                   com_api_type_pkg.t_long_id;
    l_payment_order_id              com_api_type_pkg.t_long_id;
    l_provider_number               com_api_type_pkg.t_name;

begin
    l_params             := evt_api_shared_data_pkg.g_params;
    l_fee_type           := evt_api_shared_data_pkg.get_param_char('FEE_TYPE');
    l_result_amount_name := evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');
    l_entity_type        := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id          := evt_api_shared_data_pkg.get_param_num ('OBJECT_ID');
    l_event_date         := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_split_hash         := evt_api_shared_data_pkg.get_param_num ('SPLIT_HASH');

    l_test_mode :=
        nvl(
            evt_api_shared_data_pkg.get_param_char(
                i_name        => 'ATTR_MISS_TESTMODE'
              , i_mask_error  => com_api_const_pkg.TRUE
              , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
            )
          , fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
        );

    begin
        acc_api_entry_pkg.flush_job;

        if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ENTRY then
            l_original_id      := opr_api_shared_data_pkg.get_operation().id;
            l_payment_order_id := opr_api_shared_data_pkg.get_operation().payment_order_id;

            select account_id
              into l_account_id
              from (select ae.account_id
                      from acc_entry ae
                     where ae.id = l_object_id
                     union all
                    select ae.account_id
                      from acc_entry_buffer ae
                     where ae.id = l_object_id
                   );

            select object_id
              into l_object_id
              from acc_account_link
             where account_id  = l_account_id
               and entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and is_active   = com_api_const_pkg.TRUE;

            if l_payment_order_id is not null then

                select p.provider_number
                  into l_provider_number
                  from pmo_order    o
                     , pmo_purpose  s
                     , pmo_provider p
                 where o.id = l_payment_order_id
                   and s.id = o.purpose_id
                   and p.id = s.provider_id;

            end if;
        else
            l_account_id := 0;
            l_object_id  := 0;
        end if;
    exception
        when no_data_found then
            if l_test_mode = fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE then
                raise com_api_error_pkg.e_stop_execute_rule_set;
            elsif l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                raise;
            else
                l_account_id := 0;
                l_object_id  := 0;
            end if;
    end;

    if l_account_id != 0 and l_object_id != 0 then
        l_entity_type := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
        evt_api_shared_data_pkg.set_param(
            i_name      => 'OBJECT_ID'
          , i_value     => l_object_id
        );

        evt_api_shared_data_pkg.set_param(
            i_name      => 'ENTITY_TYPE'
          , i_value     => l_entity_type
        );

        evt_api_shared_data_pkg.set_param(
            i_name      => 'ORIGINAL_ID'
          , i_value     => l_original_id
        );

        rul_api_param_pkg.set_param(
            i_value     => l_provider_number
          , i_name      => 'SERVICE_PROVIDER_NUMBER'
          , io_params   => l_params
        );

        l_product_id  := prd_api_product_pkg.get_product_id (
            i_entity_type  => l_entity_type
            , i_object_id  => l_account_id
        );

        begin
            -- checking for servicing fee
            begin
                select a.service_type_id
                  into l_service_type_id
                  from prd_attribute a
                     , prd_service_type s
                 where a.object_type = l_fee_type
                   and a.service_type_id = s.id
                   and a.id = s.service_fee;

                select trunc(least(l_event_date, nvl(o.end_date, l_event_date)))
                     , nvl(c.prev_date, nvl(trunc(o.start_date), l_event_date))
                  into l_end_date
                     , l_start_date
                  from prd_service_object o
                     , prd_service s
                     , fcl_cycle_counter c
                     , fcl_fee_type t
                where o.service_id      = s.id
                   and s.service_type_id = l_service_type_id
                   and o.entity_type     = l_entity_type
                   and o.object_id       = l_account_id
                   and o.split_hash      = l_split_hash
                   and c.entity_type     = o.entity_type
                   and c.object_id       = o.object_id
                   and c.split_hash      = o.split_hash
                   and c.cycle_type      = t.cycle_type
                   and t.fee_type        = l_fee_type
                   and l_event_date between nvl(c.prev_date, nvl(trunc(o.start_date), l_event_date)) and nvl(o.end_date, trunc(l_event_date)+1)
                   and rownum = 1;

            exception
                when no_data_found then
                    trc_log_pkg.debug('Not servicing fee');
            end;

            l_fee_id :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id     => l_product_id
                    , i_entity_type  => l_entity_type
                    , i_object_id    => l_account_id
                    , i_fee_type     => l_fee_type
                    , i_params       => l_params
                    , i_eff_date     => l_event_date
                    , i_split_hash   => l_split_hash
                    , i_inst_id      => l_inst_id
                );

            l_result_amount.amount :=
                round(
                    fcl_api_fee_pkg.get_fee_amount (
                        i_fee_id            => l_fee_id
                        , i_base_amount     => 0
                        , io_base_currency  => l_result_amount.currency
                        , i_entity_type     => l_entity_type
                        , i_object_id       => l_account_id
                        , i_split_hash      => l_split_hash
                        , i_start_date      => l_start_date
                        , i_end_date        => l_end_date
                    )
                );

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

        evt_api_shared_data_pkg.set_amount (
            i_name        => l_result_amount_name
            , i_amount    => l_result_amount.amount
            , i_currency  => l_result_amount.currency
        );
    end if;
exception
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error != 'PRD_NO_ACTIVE_SERVICE' then
            raise;
        end if;
    when others then
        trc_log_pkg.debug('error executing calculate_facilitator_fee: '||sqlerrm);
        raise;
end calculate_facilitator_fee;

procedure fill_flexible_mcc_list
is
    l_object_id                     com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_name;
    l_params                        com_api_type_pkg.t_param_tab;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_event_date                    date;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_mcc_str                       com_api_type_pkg.t_name;
    l_mcc_tab                       com_api_type_pkg.t_mcc_tab;

    procedure append(
        i_mcc   com_api_type_pkg.t_mcc
    )
    is
    begin
        if ',' || l_mcc_str || ',' not like '%,' || i_mcc || ',%' then
            if l_mcc_str is null then
                l_mcc_str := i_mcc;
            else
                l_mcc_str := l_mcc_str || ',' || i_mcc;
            end if;
        end if;
    exception when value_error then
        com_api_error_pkg.raise_error(
            i_error      => 'MCC_LIST_TOO_LONG'
          , i_env_param1 => length(l_mcc_str || ',' || i_mcc)
        );
    end;
begin
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_split_hash  := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type      => l_entity_type
          , i_object_id        => l_object_id
          , i_attr_name        => iss_api_const_pkg.ATTR_CARD_TEMP_CREDIT_LIMIT
          , i_eff_date         => l_event_date
          , i_mask_error       => com_api_const_pkg.FALSE
        );

    select mcc
      bulk collect into l_mcc_tab
      from com_mcc;

    if l_mcc_tab.count > 0 then
        for r in (
            select distinct v.mod_id
              from prd_attribute_value v
                 , prd_attribute a
                 , rul_mod m
             where v.entity_type = l_entity_type
               and v.object_id   = l_object_id
               and v.split_hash  = l_split_hash
               and v.service_id  = l_service_id
               and a.attr_name   = iss_api_const_pkg.ATTR_CARD_TEMP_CREDIT_LIMIT
               and a.id          = v.attr_id
               and v.mod_id      = m.id(+)
               and l_event_date between nvl(v.start_date, l_event_date) and nvl(v.end_date, trunc(l_event_date)+1)
               and v.mod_id is not null
        )
        loop
            for i in l_mcc_tab.first..l_mcc_tab.last loop
                rul_api_param_pkg.set_param(
                    i_name      => 'MCC'
                  , i_value     => l_mcc_tab(i)
                  , io_params   => l_params
                );
                if rul_api_mod_pkg.check_condition(
                       i_mod_id   => r.mod_id
                     , i_params   => l_params
                   ) = com_api_const_pkg.TRUE then
                   append(
                       i_mcc => l_mcc_tab(i)
                   );
                end if;
            end loop;
        end loop;
    end if;

    trc_log_pkg.debug(
        i_text => 'MCC list ' || l_mcc_str
    );

    com_api_flexible_data_pkg.set_flexible_value(
        i_field_name  => iss_api_const_pkg.FLX_TEMPORARY_LIMIT_MCC_LIST
      , i_entity_type => l_entity_type
      , i_object_id   => l_object_id
      , i_field_value => l_mcc_str
    );
end;

procedure get_available_balance_amount
is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_available_balance_amount: ';
    l_amount                        com_api_type_pkg.t_amount_rec;
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

    l_amount :=
        acc_api_balance_pkg.get_aval_balance_amount(
            i_account_id      => l_account_id
        );

    evt_api_shared_data_pkg.set_amount(
        i_name      => l_result_amount_name
      , i_amount    => l_amount.amount
      , i_currency  => l_amount.currency
    );

end get_available_balance_amount;

procedure get_absolute_amount is
    l_source_amount_name            com_api_type_pkg.t_name;
    l_source_amount                 com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;

begin

    l_source_amount_name := evt_api_shared_data_pkg.get_param_char('SOURCE_AMOUNT_NAME');
    l_result_amount_name := evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    evt_api_shared_data_pkg.get_amount(
        i_name      => l_source_amount_name
      , o_amount    => l_source_amount.amount
      , o_currency  => l_source_amount.currency
    );

    evt_api_shared_data_pkg.set_amount(
        i_name      => l_result_amount_name
      , i_amount    => abs(l_source_amount.amount)
      , i_currency  => l_source_amount.currency
    );

end get_absolute_amount;

procedure change_customer_account_status
is
    l_params                        com_api_type_pkg.t_param_tab;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_event_date                    date;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_customer_id                   com_api_type_pkg.t_medium_id;
    l_split_hash                    com_api_type_pkg.t_inst_id;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type  := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_inst_id     := evt_api_shared_data_pkg.get_param_num('INST_ID');
    l_split_hash  := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');

    case
        when l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
        then
            l_customer_id := l_object_id;
        when l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
        then
            l_customer_id := iss_api_card_pkg.get_customer_id(i_card_id => l_object_id);
        when l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
        then
            l_customer_id := iss_api_card_pkg.get_customer_id(i_card_id => iss_api_card_instance_pkg.get_instance(i_id => l_object_id).card_id);
        when l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
        then
            l_customer_id := prd_api_customer_pkg.get_customer_id(
                                 i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                               , i_object_id    => l_object_id
                               , i_inst_id      => l_inst_id
                               , i_mask_error   => com_api_const_pkg.TRUE
                             );
        else
             null;
    end case;

    for cur_acc in (select id
                      from acc_account
                     where customer_id  = l_customer_id
                       and status       = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
                       and inst_id      = l_inst_id
                       and split_hash   = l_split_hash)
    loop
        evt_api_status_pkg.change_status(
            i_event_type     => l_event_type
          , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id      => cur_acc.id
          , i_inst_id        => l_inst_id
          , i_reason         => null
          , i_eff_date       => l_event_date
          , i_params         => l_params
          , i_register_event => com_api_const_pkg.FALSE
        );
    end loop;
end change_customer_account_status;

procedure select_amount is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.select_amount: ';
    l_amount_selection_algorithm    com_api_type_pkg.t_name;
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount_name_1                 com_api_type_pkg.t_name;
    l_amount_name_2                 com_api_type_pkg.t_name;
    l_result_amount_name            com_api_type_pkg.t_name;

    l_amount                        com_api_type_pkg.t_amount_rec;
    l_amount_1                      com_api_type_pkg.t_amount_rec;
    l_amount_2                      com_api_type_pkg.t_amount_rec;
    l_result_amount                 com_api_type_pkg.t_amount_rec;

    l_rate_type                     com_api_type_pkg.t_dict_value;
    l_conversion_type               com_api_type_pkg.t_dict_value;
    l_amount_money_1_present        com_api_type_pkg.t_money;
    l_amount_money_2_present        com_api_type_pkg.t_money;
    l_inst_id                       com_api_type_pkg.t_inst_id;

    function get_present_amount(
        i_amount_source    in com_api_type_pkg.t_amount_rec
      , i_amount_dst       in com_api_type_pkg.t_amount_rec
      , i_rate_type        in com_api_type_pkg.t_dict_value
      , i_inst_id          in com_api_type_pkg.t_inst_id
      , i_conversion_type  in com_api_type_pkg.t_dict_value
      , i_param_name       in com_api_type_pkg.t_name         default null
    ) return com_api_type_pkg.t_money is
        LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.select_amount.get_present_amount: ';
        l_money_present              com_api_type_pkg.t_money;
        l_oper_date                  date;
    begin
        if i_amount_dst.currency = i_amount_source.currency then
                trc_log_pkg.debug(
                    i_text          => LOG_PREFIX || 'Source[#1] currency equals destination [#2]. No convertion.'
                  , i_env_param1    => i_param_name
                  , i_env_param2    => i_amount_dst.currency
                );

            return i_amount_source.amount;
        end if;

        l_oper_date := opr_api_shared_data_pkg.get_operation().oper_date;

        if l_oper_date is null then
            l_oper_date := com_api_sttl_day_pkg.get_sysdate;

            trc_log_pkg.debug(
                i_text          => LOG_PREFIX || 'Operation date is unindentified. Set to settlement date [#1].'
              , i_env_param1    => to_char(l_oper_date, 'dd.mm.yyyy hh24:mi:ss')
            );
        end if;

        if nvl(i_amount_source.currency
             , com_api_const_pkg.UNDEFINED_CURRENCY
           ) not in (com_api_const_pkg.UNDEFINED_CURRENCY
                   , com_api_const_pkg.ZERO_CURRENCY
                    ) then

            l_money_present := com_api_rate_pkg.convert_amount(
                                   i_src_amount         => i_amount_source.amount
                                 , i_src_currency       => i_amount_source.currency
                                 , i_dst_currency       => i_amount_dst.currency
                                 , i_rate_type          => i_rate_type
                                 , i_inst_id            => i_inst_id
                                 , i_eff_date           => l_oper_date
                                 , i_mask_exception     => com_api_const_pkg.TRUE
                                 , i_conversion_type    => i_conversion_type
                               );
        else
            com_api_error_pkg.raise_error(
                i_error       => 'CURRENCY_UNINDENTIFIED'
              , i_env_param1  => i_amount_source.currency
            );
        end if;

        return l_money_present;
    end get_present_amount;

begin
    l_amount_selection_algorithm := evt_api_shared_data_pkg.get_param_char('AMOUNT_SELECTION_ALGORITHM');
    l_amount_name                := evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME');
    l_amount_name_1              := evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME_#1');
    l_amount_name_2              := evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME_#2');
    l_inst_id                    := evt_api_shared_data_pkg.get_param_num('INST_ID');
    l_result_amount_name         := evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');
    l_rate_type                  := evt_api_shared_data_pkg.get_param_char('RATE_TYPE');

    evt_api_shared_data_pkg.get_amount(
        i_name        => l_amount_name
      , o_amount      => l_amount.amount
      , o_currency    => l_amount.currency
    );

    evt_api_shared_data_pkg.get_amount(
        i_name        => l_amount_name_1
      , o_amount      => l_amount_1.amount
      , o_currency    => l_amount_1.currency
    );

    if l_amount_name_2 is not null then
        evt_api_shared_data_pkg.get_amount(
            i_name        => l_amount_name_2
          , o_amount      => l_amount_2.amount
          , o_currency    => l_amount_2.currency
        );
    end if;

    l_conversion_type := evt_api_shared_data_pkg.get_param_char(
                             i_name          => 'CONVERSION_TYPE'
                           , i_mask_error    => com_api_const_pkg.TRUE
                         );

    if l_conversion_type is null then
        l_conversion_type := nvl(l_conversion_type, com_api_const_pkg.CONVERSION_TYPE_BUYING);

        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'CONVERSION_TYPE is null. Set to [#1].'
          , i_env_param1  => l_conversion_type
        );
    end if;

    l_amount_money_1_present := get_present_amount(
                                    i_amount_source        => l_amount_1
                                  , i_amount_dst           => l_amount
                                  , i_rate_type            => l_rate_type
                                  , i_inst_id              => l_inst_id
                                  , i_conversion_type      => l_conversion_type
                                  , i_param_name           => 'AMOUNT_NAME_#1'
                                );

    if l_amount_name_2 is not null then
        l_amount_money_2_present := get_present_amount(
                                        i_amount_source    => l_amount_2
                                      , i_amount_dst       => l_amount
                                      , i_rate_type        => l_rate_type
                                      , i_inst_id          => l_inst_id
                                      , i_conversion_type  => l_conversion_type
                                      , i_param_name       => 'AMOUNT_NAME_#2'
                                    );
    end if;

    if l_amount_selection_algorithm = evt_api_const_pkg.AMOUNT_SELECTION_ALGORITH_MIN then

        if l_amount.amount <= l_amount_money_1_present and l_amount.amount <= nvl(l_amount_money_2_present, l_amount.amount) then
            l_result_amount.amount   := l_amount.amount;
            l_result_amount.currency := l_amount.currency;

        elsif l_amount_money_1_present <= l_amount.amount and l_amount_money_1_present <= nvl(l_amount_money_2_present, l_amount_money_1_present) then
            l_result_amount.amount   := l_amount_1.amount;
            l_result_amount.currency := l_amount_1.currency;

        else
            l_result_amount.amount   := l_amount_2.amount;
            l_result_amount.currency := l_amount_2.currency;

        end if;

    else

        if l_amount.amount >= l_amount_money_1_present and l_amount.amount >= nvl(l_amount_money_2_present, l_amount.amount) then
            l_result_amount.amount   := l_amount.amount;
            l_result_amount.currency := l_amount.currency;

        elsif l_amount_money_1_present >= l_amount.amount and l_amount_money_1_present >= nvl(l_amount_money_2_present, l_amount_money_1_present) then
            l_result_amount.amount   := l_amount_1.amount;
            l_result_amount.currency := l_amount_1.currency;

        else
            l_result_amount.amount   := l_amount_2.amount;
            l_result_amount.currency := l_amount_2.currency;

        end if;

    end if;

    evt_api_shared_data_pkg.set_amount(
        i_name        => l_result_amount_name
      , i_amount      => l_result_amount.amount
      , i_currency    => l_result_amount.currency
    );
end select_amount;

procedure check_amount_positive is
    l_amount         com_api_type_pkg.t_amount_rec;
    l_reason         com_api_type_pkg.t_dict_value;
    l_miss_testmode  com_api_type_pkg.t_dict_value;
    l_event_id       com_api_type_pkg.t_long_id;
begin
    evt_api_shared_data_pkg.get_amount(
        i_name        => evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME')
      , o_amount      => l_amount.amount
      , o_currency    => l_amount.currency
    );

    if l_amount.amount <= 0 then
        l_miss_testmode := nvl(evt_api_shared_data_pkg.get_param_char(
                                   i_name        => 'ATTR_MISS_TESTMODE'
                                 , i_mask_error  => com_api_const_pkg.TRUE
                                 , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                               )
                             , fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                           );

        if l_miss_testmode = fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE then
            raise com_api_error_pkg.e_stop_execute_rule_set;

        elsif l_miss_testmode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
            l_event_id  := evt_api_shared_data_pkg.get_param_char('EVENT_ID');
            l_reason    := evt_api_shared_data_pkg.get_param_char(
                               i_name        => 'RESP_CODE'
                             , i_mask_error  => com_api_const_pkg.TRUE
                             , i_error_value => aup_api_const_pkg.RESP_CODE_UNSUFFICIENT_FUNDS
                           );

            trc_log_pkg.error(
                i_text        => 'ERROR_ROLLBACK_PROCESSING_EVENT'
              , i_env_param1  => l_event_id
              , i_env_param2  => l_reason
              , i_entity_type => evt_api_const_pkg.ENTITY_TYPE_EVENT
              , i_object_id   => l_event_id
            );
            raise com_api_error_pkg.e_rollback_execute_rule_set;
        end if;
    end if;
end check_amount_positive;

-- Obsolete. Do not use
procedure send_credit_due_notification is
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_send_preliminary_if_mad_paid  com_api_type_pkg.t_boolean    := com_api_const_pkg.FALSE;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_miss_testmode                 com_api_type_pkg.t_dict_value;

    l_due_date                      date;
    l_min_amount_due                com_api_type_pkg.t_money;
    l_total_amount_due              com_api_type_pkg.t_money;
    l_is_mad_payed                  com_api_type_pkg.t_boolean;
    l_last_invoice_id               com_api_type_pkg.t_long_id;

    l_account_rec                   acc_api_type_pkg.t_account_rec;
    l_entity_type                   com_api_type_pkg.t_dict_value;
begin

    l_inst_id                       := evt_api_shared_data_pkg.get_param_num('INST_ID');
    l_event_type                    := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_object_id                     := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_send_preliminary_if_mad_paid  := evt_api_shared_data_pkg.get_param_num('IS_MAD_PAID');
    l_entity_type                   := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');

    l_miss_testmode                 := nvl(evt_api_shared_data_pkg.get_param_char(
                                               i_name        => 'ATTR_MISS_TESTMODE'
                                             , i_mask_error  => com_api_const_pkg.TRUE
                                             , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                                           )
                                         , fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                                       );

    if l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        select account_id
          into l_object_id
          from crd_invoice
         where id = l_object_id;
    end if;

    l_account_rec := acc_api_account_pkg.get_account(
                         i_account_id    => l_object_id
                       , i_inst_id       => l_inst_id
                       , i_mask_error    => com_api_const_pkg.FALSE
                     );

    if l_account_rec.account_type <> acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
       and l_miss_testmode = fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE then

        trc_log_pkg.debug(
            i_text       => 'Account[#1] is not a [#2] type instance.'
          , i_env_param1 => l_account_rec.account_id
          , i_env_param2 => acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
        );

        raise com_api_error_pkg.e_stop_execute_rule_set;
    end if;

    l_last_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                             i_account_id    => l_account_rec.account_id
                           , i_split_hash    => l_account_rec.split_hash
                           , i_mask_error    => com_api_const_pkg.FALSE
                         );

    select is_mad_paid
      into l_is_mad_payed
      from crd_invoice
     where id = l_last_invoice_id;

    if not(l_event_type = ntf_api_const_pkg.CYTP_SEND_POSTERIOR_DUE_MESS
           or(l_event_type = ntf_api_const_pkg.CYTP_SEND_PRELIMINARY_DUE_MESS
              and((l_send_preliminary_if_mad_paid = com_api_const_pkg.FALSE
                   and l_is_mad_payed = com_api_const_pkg.FALSE)
                  or l_send_preliminary_if_mad_paid = com_api_const_pkg.TRUE
              )
           )
       )then

        trc_log_pkg.info(
            i_text => 'MAD was already paid.'
        );

        raise com_api_error_pkg.e_stop_execute_rule_set;
    end if;
end send_credit_due_notification;

procedure add_oper_stage
is
    l_entity_type          com_api_type_pkg.t_dict_value;
    l_object_id            com_api_type_pkg.t_long_id;
    l_split_hash           com_api_type_pkg.t_long_id;
    l_cnt                  com_api_type_pkg.t_long_id;
    l_proc_stage           com_api_type_pkg.t_dict_value;
begin
    l_proc_stage   := evt_api_shared_data_pkg.get_param_char('OPER_STAGE');
    l_entity_type  := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id    := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_split_hash   := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');

    if l_entity_type != opr_api_const_pkg.ENTITY_TYPE_OPERATION then
        com_api_error_pkg.raise_error(
            i_error       => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1  => l_entity_type
          , i_env_param2  => l_object_id
        );
    end if;

    -- to prevent exception when double fail
    select count(*)
      into l_cnt
      from opr_oper_stage
     where oper_id    = l_object_id
       and proc_stage = l_proc_stage;

    if l_cnt > 0 then
        trc_log_pkg.debug(
            i_text       => 'add_oper_stage: stage [#1] is alredy added for operation [#2]'
          , i_env_param1 => l_proc_stage
          , i_env_param2 => l_object_id
        );
    else
        insert into opr_oper_stage(
            oper_id
          , proc_stage
          , exec_order
          , status
          , split_hash
        )
        select o.id
             , s.proc_stage
             , s.exec_order
             , s.status
             , l_split_hash
          from opr_proc_stage s
             , opr_operation  o
         where s.parent_stage = s.proc_stage
           and s.proc_stage   = l_proc_stage
           and o.id           = l_object_id
           and (s.msg_type  = o.msg_type    or s.msg_type  = '%')
           and (s.sttl_type = o.sttl_type   or s.sttl_type = '%')
           and (s.oper_type = o.oper_type   or s.oper_type = '%')
        ;
        trc_log_pkg.debug(
            i_text       => 'add_oper_stage: [#1] record inserted'
          , i_env_param1 => sql%rowcount
        );
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text       => 'add_oper_stage: failed with [#1]'
          , i_env_param1 => sqlerrm
        );
        raise;
end add_oper_stage;

procedure check_amount_not_positive is
    l_amount         com_api_type_pkg.t_amount_rec;
    l_reason         com_api_type_pkg.t_dict_value;
    l_miss_testmode  com_api_type_pkg.t_dict_value;
    l_event_id       com_api_type_pkg.t_long_id;
begin

    evt_api_shared_data_pkg.get_amount(
        i_name        => evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME')
      , o_amount      => l_amount.amount
      , o_currency    => l_amount.currency
    );

    if l_amount.amount > 0 then
        l_miss_testmode := nvl(evt_api_shared_data_pkg.get_param_char(
                                   i_name        => 'ATTR_MISS_TESTMODE'
                                 , i_mask_error  => com_api_const_pkg.TRUE
                                 , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                               )
                             , fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                           );

        if l_miss_testmode = fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE then
            raise com_api_error_pkg.e_stop_execute_rule_set;

        elsif l_miss_testmode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
            l_event_id  := evt_api_shared_data_pkg.get_param_char('EVENT_ID');
            l_reason    := evt_api_shared_data_pkg.get_param_char(
                               i_name        => 'RESP_CODE'
                             , i_mask_error  => com_api_const_pkg.TRUE
                             , i_error_value => aup_api_const_pkg.RESP_CODE_UNSUFFICIENT_FUNDS
                           );

            trc_log_pkg.error(
                i_text        => 'ERROR_ROLLBACK_PROCESSING_EVENT'
              , i_env_param1  => l_event_id
              , i_env_param2  => l_reason
              , i_entity_type => evt_api_const_pkg.ENTITY_TYPE_EVENT
              , i_object_id   => l_event_id
            );
            raise com_api_error_pkg.e_rollback_execute_rule_set;
        end if;
    end if;
end check_amount_not_positive;

procedure change_dependent_object_status is
    l_params                        com_api_type_pkg.t_param_tab;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_event_date                    date;
    l_split_hash                    com_api_type_pkg.t_inst_id;
    l_dependent_entity_type         com_api_type_pkg.t_dict_value;
    l_dependent_event_type          com_api_type_pkg.t_dict_value;
    l_dependent_object_id           num_tab_tpt;
    l_bound_object_id               com_api_type_pkg.t_medium_tab;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type  := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_split_hash  := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');

    l_dependent_entity_type := evt_api_shared_data_pkg.get_param_char(
                                   i_name         => 'ENTITY_TYPE_DEPENDENT'
                                 , i_mask_error   => com_api_const_pkg.TRUE
                               );

    l_dependent_event_type  := evt_api_shared_data_pkg.get_param_char(
                                   i_name         => 'EVENT_TYPE_DEPENDENT'
                                 , i_mask_error   => com_api_const_pkg.TRUE
                               );

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT and l_dependent_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD, iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE) then
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

    elsif l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD and l_dependent_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select account_id
          bulk collect into l_dependent_object_id
          from iss_card           c
             , acc_account_object a
             , acc_account        n
         where c.id           = l_object_id
           and c.split_hash   = l_split_hash
           and a.object_id    = c.id
           and a.split_hash   = c.split_hash
           and a.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
           and a.account_id   = n.id
           and n.status      <> acc_api_const_pkg.ACCOUNT_STATUS_CLOSED;

    elsif l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE and l_dependent_entity_type in (acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE) then
        select account_id
          bulk collect into l_dependent_object_id
          from iss_card_instance  i
             , acc_account_object a
             , acc_account        n
         where i.id           = l_object_id
           and i.split_hash   = l_split_hash
           and a.object_id    = i.card_id
           and a.split_hash   = i.split_hash
           and a.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
           and a.account_id   = n.id
           and n.status      <> acc_api_const_pkg.ACCOUNT_STATUS_CLOSED;

        if l_dependent_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            select c.id
              bulk collect into l_bound_object_id
              from acc_account_object o
                 , iss_card_instance  c
             where o.account_id  in (select column_value from table(cast(l_dependent_object_id as num_tab_tpt)))
               and o.object_id    = c.card_id
               and o.split_hash   = c.split_hash
               and c.state       <> iss_api_const_pkg.CARD_STATE_CLOSED
               and c.status      <> iss_api_const_pkg.CARD_STATUS_EXPIRY_OF_CARD;

            if l_bound_object_id.count > 0 then
                for rec_id in l_bound_object_id.first..l_bound_object_id.last
                loop
                    evt_api_status_pkg.change_status(
                        i_event_type     => l_dependent_event_type
                      , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
                      , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                      , i_object_id      => l_bound_object_id(rec_id)
                      , i_reason         => l_event_type
                      , i_eff_date       => l_event_date
                      , i_params         => l_params
                      , i_register_event => com_api_const_pkg.FALSE
                    );
                end loop;
            end if;

            l_dependent_entity_type := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
            l_dependent_event_type  := null;

        end if;

    end if;

    if l_dependent_object_id.count > 0 then
        for rec_id in l_dependent_object_id.first..l_dependent_object_id.last
        loop
            evt_api_status_pkg.change_status(
                i_event_type     => nvl(l_dependent_event_type, l_event_type)
              , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type    => l_dependent_entity_type
              , i_object_id      => l_dependent_object_id(rec_id)
              , i_reason         => l_event_type
              , i_eff_date       => l_event_date
              , i_params         => l_params
              , i_register_event => com_api_const_pkg.FALSE
            );
        end loop;
    end if;

end change_dependent_object_status;

procedure subtract_amount
is
    l_first_amount_name             com_api_type_pkg.t_name;
    l_second_amount_name            com_api_type_pkg.t_name;
    l_first_amount                  com_api_type_pkg.t_amount_rec;
    l_second_amount                 com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_result_amount                 com_api_type_pkg.t_amount_rec;

begin
    trc_log_pkg.debug(
        i_text => 'Subtract amount (event): start'
    );

    l_first_amount_name  := evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME_#1');
    l_second_amount_name := evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME_#2');
    l_result_amount_name := evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

    evt_api_shared_data_pkg.get_amount(
        i_name     => l_first_amount_name
      , o_amount   => l_first_amount.amount
      , o_currency => l_first_amount.currency
    );

    evt_api_shared_data_pkg.get_amount(
        i_name     => l_second_amount_name
      , o_amount   => l_second_amount.amount
      , o_currency => l_second_amount.currency
    );

    if l_first_amount.currency = l_second_amount.currency then
        l_result_amount.currency := l_first_amount.currency;
        l_result_amount.amount := l_first_amount.amount - l_second_amount.amount;

        evt_api_shared_data_pkg.set_amount (
            i_name     => l_result_amount_name
          , i_amount   => l_result_amount.amount
          , i_currency => l_result_amount.currency
        );
    else
        com_api_error_pkg.raise_error (
            i_error      => 'ATTEMPT_TO_SUBTRACT_DIFFERENT_CURRENCY'
          , i_env_param1 => l_first_amount.currency
          , i_env_param2 => l_second_amount.currency
        );
    end if;

    trc_log_pkg.debug(
        i_text       => 'Subtract amount (event): done, l_result_amount.amount [#1]'
      , i_env_param1 => l_result_amount.amount
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text       => 'Subtract amount (event): Raised ' || sqlerrm || ' with l_first_amount_name [#1], l_second_amount_name [#2], l_result_amount_name [#3]'
          , i_env_param1 => l_first_amount_name
          , i_env_param2 => l_second_amount_name
          , i_env_param3 => l_result_amount_name
        );
end subtract_amount;

procedure close_dependent_objects is
    l_object_id                     com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_event_date                    date;

    l_entity_object_type            com_api_type_pkg.t_dict_value;
    l_dependent_entity_type         com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;

    procedure close_dependent_account is
        l_account_cards_id          iss_api_type_pkg.t_card_tab;
        l_cards_id                  num_tab_tpt                         := num_tab_tpt();
        l_change_result_status      com_api_type_pkg.t_dict_value;
        l_params                    com_api_type_pkg.t_param_tab;
    begin
        l_account_cards_id := iss_api_card_pkg.get_card(
                                  i_account_id    => l_object_id
                                , i_state         => null
                              );

        if l_account_cards_id.count > 0 then

            for i in l_account_cards_id.first..l_account_cards_id.last loop
                l_cards_id.extend();
                l_cards_id(i) := l_account_cards_id(i).id;
            end loop;

            for rec_card_instance in (
                select card_instance_id
                     , count_card_accounts
                     , card_id
                  from (select ci.id                                       card_instance_id
                             , count(*) over(partition by ao.object_id)    count_card_accounts
                             , ci.card_id                                  card_id
                          from acc_account_object ao
                             , acc_account        acc
                             , iss_card_instance  ci
                         where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and (acc.status    = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
                               or acc.id      = l_object_id
                               )
                           and acc.id         = ao.account_id
                           and acc.inst_id    = l_inst_id
                           and acc.split_hash = l_split_hash
                           and ci.id          = iss_api_card_instance_pkg.get_card_instance_id(i_card_id => ao.object_id)
                           and ci.state      <> iss_api_const_pkg.CARD_STATE_CLOSED
                           and ao.object_id  in (select column_value from table(l_cards_id))
                       )
                ) loop

                      if rec_card_instance.count_card_accounts = 1 then
                          trc_log_pkg.debug(
                              i_text       => 'going to "close" dependent object: card_id[#1] card_instance_id[#2]'
                            , i_env_param1 => rec_card_instance.card_id
                            , i_env_param2 => rec_card_instance.card_instance_id
                          );

                          evt_api_status_pkg.change_status(
                              i_initiator         => evt_api_const_pkg.INITIATOR_SYSTEM
                            , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                            , i_object_id         => rec_card_instance.card_instance_id
                            , i_new_status        => iss_api_const_pkg.CARD_STATE_CLOSED
                            , i_reason            => l_event_type
                            , o_status            => l_change_result_status
                            , i_params            => l_params
                            , i_eff_date          => l_event_date
                            , i_register_event    => com_api_const_pkg.FALSE
                            , i_inst_id           => l_inst_id
                          );

                          prd_api_service_pkg.close_service(
                              i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD
                            , i_object_id      => rec_card_instance.card_id
                            , i_inst_id        => l_inst_id
                            , i_split_hash     => l_split_hash
                            , i_eff_date       => l_event_date
                            , i_params         => l_params
                          );

                      else
                          trc_log_pkg.debug(
                              i_text       => 'going not to "close" dependent object: card_id[#1] card_instance_id[#2]'
                            , i_env_param1 => rec_card_instance.card_id
                            , i_env_param2 => rec_card_instance.card_instance_id
                          );
                      end if;
                  end loop;
        end if;
    end;

    procedure close_dependent_card_instance is
        i_card_instance_id          com_api_type_pkg.t_long_id;
        l_account_cards_id          iss_api_type_pkg.t_card_tab;
    begin

        if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            i_card_instance_id := l_object_id;
        elsif l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
            i_card_instance_id := iss_api_card_instance_pkg.get_card_instance_id(i_card_id => l_object_id);
        end if;

        trc_log_pkg.debug(
            i_text       => 'processing card_instance[#1]'
          , i_env_param1 => i_card_instance_id
        );

        for rec_account in (
             select account_id
               from (select ci.id                                 card_instance_id
                          , acc.id                                account_id
                       from acc_account_object ao
                          , acc_account        acc
                          , iss_card_instance  ci
                      where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                        and acc.id         = ao.account_id
                        and ci.id          = iss_api_card_instance_pkg.get_card_instance_id(i_card_id => ao.object_id)
                        and ci.inst_id     = l_inst_id
                        and ci.split_hash  = l_split_hash
                        and acc.status     = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
                        and ci.state       = iss_api_const_pkg.CARD_STATE_CLOSED
              ) where card_instance_id = i_card_instance_id
        ) loop

            l_account_cards_id := iss_api_card_pkg.get_card(i_account_id => rec_account.account_id);

            if l_account_cards_id.count = 0 then

                trc_log_pkg.debug(
                    i_text       => 'going to "close" dependent object: account_id[#1]'
                  , i_env_param1 => rec_account.account_id
                );

                acc_api_account_pkg.close_account(i_account_id => rec_account.account_id);

            else

                trc_log_pkg.debug(
                    i_text       => 'going Not to "close" dependent object: account_id[#1]'
                  , i_env_param1 => rec_account.account_id
                );
            end if;
        end loop;
    end close_dependent_card_instance;

begin
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type  := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_inst_id     := evt_api_shared_data_pkg.get_param_num('INST_ID');
    l_split_hash  := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');

    l_entity_object_type    := evt_api_shared_data_pkg.get_param_char('ENTITY_OBJECT_TYPE');
    l_dependent_entity_type := evt_api_shared_data_pkg.get_param_char(
                                   i_name          => 'ENTITY_TYPE_DEPENDENT'
                                 , i_mask_error    => com_api_const_pkg.TRUE
                               );

    if l_entity_object_type = l_dependent_entity_type then
        trc_log_pkg.debug(
            i_text          => 'Parameter values for object[#1] and dependent[#2] entity types are equal'
          , i_env_param1    => l_entity_object_type
          , i_env_param2    => l_dependent_entity_type
        );
        return;
    end if;

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
        and l_dependent_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE, iss_api_const_pkg.ENTITY_TYPE_CARD) then

        close_dependent_account;

    elsif l_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE, iss_api_const_pkg.ENTITY_TYPE_CARD)
        and l_dependent_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then

        close_dependent_card_instance;

    else
        trc_log_pkg.debug(
            i_text          => 'Entry[#1], object[#2] and dependent[#3] object entity types are not compatible for this process'
          , i_env_param1    => l_entity_type
          , i_env_param2    => l_entity_object_type
          , i_env_param3    => l_dependent_entity_type
        );
    end if;

end close_dependent_objects;

procedure add_amount is
    l_first_amount_name             com_api_type_pkg.t_name;
    l_second_amount_name            com_api_type_pkg.t_name;
    l_first_amount                  com_api_type_pkg.t_amount_rec;
    l_second_amount                 com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
begin
    l_first_amount_name  := evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME_#1');
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

procedure close_card is
    l_object_id                     com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_date                    date;
    l_card_instance_id              com_api_type_pkg.t_long_id;
    l_card                          iss_api_type_pkg.t_card_rec;

begin
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_date  := nvl(evt_api_shared_data_pkg.get_param_date('EVENT_DATE'), com_api_sttl_day_pkg.get_sysdate);

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        l_card_instance_id := l_object_id;
        l_card             := iss_api_card_pkg.get_card(i_card_instance_id => l_card_instance_id);

    elsif l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        l_card_instance_id := iss_api_card_instance_pkg.get_card_instance_id(i_card_id => l_object_id);
        l_card             := iss_api_card_pkg.get_card(
                                  i_card_id    => l_object_id
                                , i_mask_error => com_api_const_pkg.FALSE
                              );
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;

    iss_api_card_pkg.deactivate_card(
        i_card_instance_id  => l_card_instance_id
      , i_status            => null
    );

    prd_api_service_pkg.close_service(
        i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id   => l_card.id
      , i_inst_id     => l_card.inst_id
      , i_split_hash  => l_card.split_hash
      , i_eff_date    => l_event_date
      , i_params      => evt_api_shared_data_pkg.g_params
    );

end close_card;

procedure close_contract is
    l_object_id                     com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_date                    date;
    l_contract                      prd_api_type_pkg.t_contract;

begin
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_date  := nvl(evt_api_shared_data_pkg.get_param_date('EVENT_DATE'), com_api_sttl_day_pkg.get_sysdate);

    if l_entity_type = com_api_const_pkg.ENTITY_TYPE_CONTRACT then

        l_contract := prd_api_contract_pkg.get_contract(i_contract_id => l_object_id);

        prd_api_contract_pkg.close_contract(
            i_contract_id => l_contract.id
          , i_inst_id     => l_contract.inst_id
          , i_end_date    => l_event_date
          , i_params      => evt_api_shared_data_pkg.g_params
        );

    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;
end close_contract;

procedure check_modifier
is
    l_condition_result    com_api_type_pkg.t_boolean;
begin
    l_condition_result :=
        rul_api_mod_pkg.check_condition(
            i_mod_id  => evt_api_shared_data_pkg.get_param_num('MOD_ID')
          , i_params  => evt_api_shared_data_pkg.g_params
        );

    if l_condition_result = com_api_const_pkg.TRUE then
        raise com_api_error_pkg.e_stop_execute_rule_set;
    end if;
end check_modifier;

end evt_api_rule_proc_pkg;
/
