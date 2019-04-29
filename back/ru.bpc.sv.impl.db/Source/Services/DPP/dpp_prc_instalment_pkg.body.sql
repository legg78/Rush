create or replace package body dpp_prc_instalment_pkg as
/*********************************************************
*  API for DPP instalments process <br />
*  Created by  E. Kryukov(krukov@bpc.ru)  at 07.09.2011 <br />
*  Module: DPP_PRC_INSTALMENT_PKG <br />
*  @headcom
**********************************************************/

procedure accelerate_by_usury_rate(
   i_dpp_id         in  com_api_type_pkg.t_long_id
 , i_account_id     in  com_api_type_pkg.t_medium_id
 , i_inst_id        in  com_api_type_pkg.t_inst_id
 , i_split_hash     in  com_api_type_pkg.t_tiny_id
 , i_product_id     in  com_api_type_pkg.t_short_id
) as
    l_eff_date            date;
    l_params              com_api_type_pkg.t_param_tab;
    l_fee_id_usury        com_api_type_pkg.t_short_id;
    l_fee_id              com_api_type_pkg.t_short_id;
    l_fee_id_to_check     com_api_type_pkg.t_short_id;
    l_percent_rate        com_api_type_pkg.t_money;
    l_percent_rate_usury  com_api_type_pkg.t_money;
    l_fee_count           com_api_type_pkg.t_count := 0;
    l_rate_algorithm      com_api_type_pkg.t_dict_value;
begin
    l_eff_date   := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);

    dpp_api_payment_plan_pkg.get_saved_attribute_value(
        i_attr_name => dpp_api_const_pkg.ATTR_FEE_ID
      , i_dpp_id    => i_dpp_id
      , o_value     => l_fee_id
    );

    dpp_api_payment_plan_pkg.get_saved_attribute_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_RATE_ALGORITHM
      , i_dpp_id     => i_dpp_id
      , o_value      => l_rate_algorithm
      , i_mask_error => com_api_const_pkg.TRUE
    );

    begin
        l_fee_id_usury :=
            prd_api_product_pkg.get_fee_id(
                i_product_id      => i_product_id
              , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id       => i_account_id
              , i_fee_type        => dpp_api_const_pkg.FEE_TYPE_USURY_RATE
              , i_params          => l_params
              , i_eff_date        => l_eff_date
              , i_split_hash      => i_split_hash
              , i_inst_id         => i_inst_id
              , i_mask_error      => com_api_const_pkg.TRUE
            );
    exception
        when com_api_error_pkg.e_application_error then
            l_fee_id_usury := null;
    end;

    l_percent_rate :=
        dpp_api_payment_plan_pkg.get_period_rate(
            i_fee_id          => l_fee_id
          , i_rate_algorithm  => l_rate_algorithm
        );

    if l_fee_id_usury is not null then
        l_percent_rate_usury :=
            dpp_api_payment_plan_pkg.get_period_rate(
                i_fee_id          => l_fee_id_usury
              , i_rate_algorithm  => dpp_api_const_pkg.DPP_RATE_ALGORITHM_EXPONENTIAL
            );
    end if;

    if l_fee_id_usury is null then
        l_fee_id_to_check := l_fee_id;
    elsif l_percent_rate_usury < l_percent_rate then
        l_fee_id_to_check := l_fee_id_usury;
    else
        l_fee_id_to_check := l_fee_id;
    end if;

    select count(case when nvl(i.fee_id, l_fee_id) != l_fee_id_to_check then com_api_const_pkg.TRUE end)
      into l_fee_count
      from dpp_instalment i
     where decode(i.macros_id, null, i.dpp_id, null) = i_dpp_id;

    trc_log_pkg.debug(
        i_text       => 'Usury rate check;'
                     || 'regular ' || l_percent_rate
                     || ' vs '
                     || 'usury ' || l_percent_rate_usury || '; '
                     || 'fee_count = ' || l_fee_count || '; '
                     || 'fee_id_to_check = ' || l_fee_id_to_check
    );

    if l_fee_count > 0 then
        dpp_api_payment_plan_pkg.accelerate_dpp(
            i_dpp_id                  => i_dpp_id
          , i_new_count               => l_fee_count
          , i_payment_amount          => 0
          , i_acceleration_type       => dpp_api_const_pkg.DPP_ACCELERT_NEW_INSTLMT_CNT
        );
    end if;
end accelerate_by_usury_rate;

procedure process(
    i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_credit_bunch_type_id   in     com_api_type_pkg.t_tiny_id  default dpp_api_const_pkg.BUNCH_TYPE_ID_OVERDRAFT_REGSTR
  , i_over_bunch_type_id     in     com_api_type_pkg.t_tiny_id  default dpp_api_const_pkg.BUNCH_TYPE_ID_OVERLIMIT_REGSTR
  , i_intr_bunch_type_id     in     com_api_type_pkg.t_tiny_id  default dpp_api_const_pkg.BUNCH_TYPE_ID_OVERDRAFT_REGSTR
  , i_lending_bunch_type_id  in     com_api_type_pkg.t_tiny_id  default null
) is
    BULK_LIMIT             constant com_api_type_pkg.t_short_id := 1000;
    l_sysdate                       date;
    l_estimated_count               com_api_type_pkg.t_long_id := 0;
    l_excepted_count                com_api_type_pkg.t_long_id := 0;
    l_processed_count               com_api_type_pkg.t_long_id := 0;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_macros_type_id                com_api_type_pkg.t_long_id;
    l_macros_intr_type_id           com_api_type_pkg.t_long_id;
    l_macros_id                     com_api_type_pkg.t_long_id;
    l_macros_intr_id                com_api_type_pkg.t_long_id;
    l_account_tab                   com_api_type_pkg.t_medium_tab;
    l_product_tab                   com_api_type_pkg.t_short_tab;
    l_dpp_currency_tab              com_api_type_pkg.t_curr_code_tab;
    l_dpp_id_tab                    com_api_type_pkg.t_long_tab;
    l_oper_id_tab                   com_api_type_pkg.t_long_tab;
    l_reg_oper_id_tab               com_api_type_pkg.t_long_tab;
    l_instalment_amount_tab         com_api_type_pkg.t_money_tab;
    l_interest_amount_tab           com_api_type_pkg.t_money_tab;
    l_account_type_tab              com_api_type_pkg.t_dict_tab;
    l_inst_tab                      com_api_type_pkg.t_tiny_tab;
    l_agent_tab                     com_api_type_pkg.t_short_tab;
    l_instalment_id_tab             com_api_type_pkg.t_long_tab;
    l_instalment_date_tab           com_api_type_pkg.t_date_tab;
    l_next_instalment_date_tab      com_api_type_pkg.t_date_tab;
    l_split_hash_tab                com_api_type_pkg.t_tiny_tab;
    l_card_tab                      com_api_type_pkg.t_medium_tab;
    l_posting_date_tab              com_api_type_pkg.t_date_tab;
    l_acc_currency_tab              com_api_type_pkg.t_curr_code_tab;
    l_customer_tab                  com_api_type_pkg.t_medium_tab;
    l_account_rec                   acc_api_type_pkg.t_account_rec;
    l_is_credit_account             com_api_type_pkg.t_boolean;

    l_ok_instalment_id_tab          com_api_type_pkg.t_long_tab;
    l_ok_dpp_id_tab                 com_api_type_pkg.t_long_tab;
    l_ok_next_date_tab              com_api_type_pkg.t_date_tab;
    l_ok_macros_id_tab              com_api_type_pkg.t_long_tab;
    l_ok_macros_intr_id_tab         com_api_type_pkg.t_long_tab;

    l_params                        com_api_type_pkg.t_param_tab;
    l_credit_account_rec            acc_api_type_pkg.t_account_rec;
    l_credit_macros_type_id         com_api_type_pkg.t_long_id;
    l_credit_macros_intr_type_id    com_api_type_pkg.t_long_id;
    l_payment_amount_tab            com_api_type_pkg.t_money_tab;
    l_repay_macros_type_id          com_api_type_pkg.t_money;
    l_credit_repay_macros_type_id   com_api_type_pkg.t_money;
    l_skip                          com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;

    cursor cu_current_dpp is
        select account_id
             , product_id
             , dpp_currency
             , id
             , oper_id
             , reg_oper_id
             , instalment_amount
             , interest_amount
             , account_type
             , inst_id
             , agent_id
             , instalment_id
             , next_instalment_date
             , split_hash
             , card_id
             , posting_date
             , acc_currency
             , customer_id
             , payment_amount
          from (
              select a.account_id
                   , a.product_id
                   , a.dpp_currency
                   , a.id
                   , a.oper_id
                   , a.reg_oper_id
                   , b.instalment_amount
                   , b.interest_amount
                   , d.account_type
                   , d.inst_id
                   , d.agent_id
                   , b.id instalment_id
                   , b.instalment_date
                   , lead(b.instalment_date) over (partition by b.dpp_id order by b.instalment_date) as next_instalment_date
                   , a.split_hash
                   , a.card_id
                   , a.posting_date
                   , d.currency acc_currency
                   , d.customer_id
                   , b.payment_amount
                from dpp_payment_plan a
                   , dpp_instalment b
                   , acc_account d
               where a.next_instalment_date <= l_sysdate
                 and decode(b.macros_id, null, b.dpp_id, null) = a.id
                 and (a.inst_id = i_inst_id
                      or
                      i_inst_id = ost_api_const_pkg.DEFAULT_INST
                      or
                      i_inst_id is null
                     )
                 and d.id = a.account_id
                 and a.split_hash in (select split_hash from com_api_split_map_vw)
                 and b.split_hash = a.split_hash
                 and d.split_hash = a.split_hash
          )
         where instalment_date <= l_sysdate
      order by account_id
             , id
             , instalment_date;

    cursor cu_instalments_count is
        select count(1)
          from dpp_payment_plan a
             , dpp_instalment b
         where b.instalment_date <= l_sysdate
           and b.dpp_id = a.id
           and (a.inst_id = i_inst_id
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
                or
                i_inst_id is null
               )
           and b.macros_id is null
           and a.split_hash in (select split_hash from com_api_split_map_vw)
           and b.split_hash = a.split_hash;

    cursor cu_payment_plans is
        select distinct
               a.id as dpp_id
             , a.account_id
             , a.inst_id
             , a.split_hash
             , a.product_id
          from dpp_payment_plan a
             , dpp_instalment b
         where b.instalment_date <= l_sysdate
           and b.dpp_id = a.id
           and (a.inst_id = i_inst_id
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
                or
                i_inst_id is null
               )
           and b.macros_id is null
           and a.split_hash in (select split_hash from com_api_split_map_vw)
           and b.split_hash = a.split_hash;

    function skip_instalments(
        i_account_id  in     com_api_type_pkg.t_account_id
      , i_product_id  in     com_api_type_pkg.t_short_id
      , i_eff_date    in     date
      , i_inst_id     in     com_api_type_pkg.t_inst_id
      , i_split_hash  in     com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_boolean
    is
        LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process->skip_instalments';
        l_fee_id        com_api_type_pkg.t_medium_id;
        l_fee_curr      com_api_type_pkg.t_curr_code;
        l_prev_date     date;
        l_next_date     date;
        l_params        com_api_type_pkg.t_param_tab;
        l_skip          com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
        l_start_date    date;
        l_end_date      date;
    begin
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' << i_account_id [#1], i_eff_date [#2], i_product_id [#3], i_inst_id [#4]'
          , i_env_param1 => i_account_id
          , i_env_param2 => i_eff_date
          , i_env_param3 => i_product_id
          , i_env_param4 => i_inst_id
        );

        prd_api_product_pkg.get_fee_id(
            i_product_id  => i_product_id
          , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => i_account_id
          , i_fee_type    => dpp_api_const_pkg.FEE_TYPE_HOLIDAY
          , i_params      => l_params
          , i_mask_error  => com_api_const_pkg.TRUE
          , i_split_hash  => i_split_hash
          , o_fee_id      => l_fee_id
          , o_start_date  => l_start_date
          , o_end_date    => l_end_date
        );
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ': l_fee_id [#1], l_start_date [#2], l_end_date [#3]'
          , i_env_param1 => l_fee_id
          , i_env_param2 => l_start_date
          , i_env_param3 => l_end_date
        );

        if l_fee_id is not null and i_eff_date between nvl(l_start_date, i_eff_date) and nvl(l_end_date, i_eff_date) then
            -- Zero-amount fee is used to determine if instalment holiday is active at the current date or not.
            -- Otherwise, it is necessary to start/switch/reset fee cycle counters,
            -- and fee will be charged on standard processing of Holiday cycle type.
            if  fcl_api_fee_pkg.get_fee_amount(
                    i_fee_id         => l_fee_id
                  , i_base_amount    => 0
                  , io_base_currency => l_fee_curr
                  , i_split_hash     => i_split_hash
                ) > 0
            then
                fcl_api_cycle_pkg.get_cycle_date(
                    i_cycle_type  => dpp_api_const_pkg.CYCLE_TYPE_HOLIDAY_FEE
                  , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id   => i_account_id
                  , i_add_counter => com_api_type_pkg.FALSE
                  , i_split_hash  => i_split_hash
                  , o_prev_date   => l_prev_date
                  , o_next_date   => l_next_date
                );

                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || ': l_prev_date [#1], l_next_date [#2]'
                  , i_env_param1 => l_prev_date
                  , i_env_param2 => l_next_date
                );

                if l_prev_date is null and l_next_date is null then
                    -- Holdiay is active for a first instalment of current account, next_date is set to current date
                    fcl_api_cycle_pkg.add_cycle_counter(
                        i_cycle_type   => dpp_api_const_pkg.CYCLE_TYPE_HOLIDAY_FEE
                      , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id    => i_account_id
                      , i_split_hash   => i_split_hash
                      , i_next_date    => i_eff_date
                      , i_inst_id      => i_inst_id
                    );
                else
                    case
                        -- Fee shouldn't be charged after end date of Instalment holiday fee
                        when l_next_date > l_end_date then
                            fcl_api_cycle_pkg.reset_cycle_counter(
                                i_cycle_type      => dpp_api_const_pkg.CYCLE_TYPE_HOLIDAY_FEE
                              , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id       => i_account_id
                              , i_split_hash      => i_split_hash
                            );
                        -- In the case when fee may be charged some times during Instalment holiday period,
                        -- it is needed to switch the cycle counter normally during this period
                        when l_prev_date is null or l_prev_date >= l_start_date then
                            fcl_api_cycle_pkg.switch_cycle(
                                i_cycle_type      => dpp_api_const_pkg.CYCLE_TYPE_HOLIDAY_FEE
                              , i_product_id      => i_product_id
                              , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id       => i_account_id
                              , i_params          => l_params
                              , i_split_hash      => i_split_hash
                              , o_new_finish_date => l_next_date
                            );
                        -- Cycle counter was created on previous period of Instalment holiday activity,
                        -- so both its dates should be ignored, current date should be set as its next_date
                        when l_prev_date < l_start_date then
                            fcl_api_cycle_pkg.add_cycle_counter(
                                i_cycle_type      => dpp_api_const_pkg.CYCLE_TYPE_HOLIDAY_FEE
                              , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id       => i_account_id
                              , i_split_hash      => i_split_hash
                              , i_next_date       => i_eff_date
                              , i_inst_id         => i_inst_id
                            );
                        else
                            null;
                    end case;
                end if;
            end if;

            l_skip := com_api_const_pkg.TRUE;

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ' >> l_skip [#1]'
              , i_env_param1 => l_skip
            );
        end if;

        return l_skip;
    end skip_instalments;

begin
    savepoint sp_dpp_process;

    l_sysdate := com_api_sttl_day_pkg.get_calc_date(i_inst_id);

    prc_api_stat_pkg.log_start;

    open cu_instalments_count;
    fetch cu_instalments_count into l_estimated_count;
    close cu_instalments_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    open cu_payment_plans;
    loop
        fetch cu_payment_plans bulk collect into
            l_dpp_id_tab
          , l_account_tab
          , l_inst_tab
          , l_split_hash_tab
          , l_product_tab
        limit BULK_LIMIT;

        for i in 1 .. l_dpp_id_tab.count loop
            accelerate_by_usury_rate(
                i_dpp_id         => l_dpp_id_tab(i)
              , i_account_id     => l_account_tab(i)
              , i_inst_id        => l_inst_tab(i)
              , i_split_hash     => l_split_hash_tab(i)
              , i_product_id     => l_product_tab(i)
            );
        end loop;
        exit when cu_payment_plans%notfound;
    end loop;
    close cu_payment_plans;

    l_account_rec.account_id := null;

    open cu_current_dpp;
    loop
        fetch cu_current_dpp bulk collect into
             l_account_tab
           , l_product_tab
           , l_dpp_currency_tab
           , l_dpp_id_tab
           , l_oper_id_tab
           , l_reg_oper_id_tab
           , l_instalment_amount_tab
           , l_interest_amount_tab
           , l_account_type_tab
           , l_inst_tab
           , l_agent_tab
           , l_instalment_id_tab
           , l_next_instalment_date_tab
           , l_split_hash_tab
           , l_card_tab
           , l_posting_date_tab
           , l_acc_currency_tab
           , l_customer_tab
           , l_payment_amount_tab
        limit BULK_LIMIT;

        for i in 1 .. l_account_tab.count loop
            l_processed_count   := l_processed_count + 1;

            if l_account_rec.account_id is null or l_account_rec.account_id != l_account_tab(i) then
                if l_account_rec.account_id is not null then
                    commit;
                end if;

                l_account_rec.account_id    := l_account_tab(i);
                l_account_rec.account_type  := l_account_type_tab(i);
                l_account_rec.currency      := l_acc_currency_tab(i);
                l_account_rec.split_hash    := l_split_hash_tab(i);
                l_account_rec.inst_id       := l_inst_tab(i);
                l_account_rec.agent_id      := l_agent_tab(i);
                l_account_rec.customer_id   := l_customer_tab(i);

                l_service_id :=
                    crd_api_service_pkg.get_active_service(
                        i_account_id          => l_account_rec.account_id
                      , i_split_hash          => l_split_hash_tab(i)
                      , i_eff_date            => l_sysdate
                      , i_mask_error          => com_api_const_pkg.TRUE
                    );

                l_is_credit_account  := com_api_type_pkg.to_bool(l_service_id is not null);
                l_credit_account_rec := null;

                -- This flag is true when all instalments of current account should NOT be charged
                l_skip := skip_instalments(
                              i_account_id => l_account_tab(i)
                            , i_product_id => l_product_tab(i)
                            , i_eff_date   => l_sysdate
                            , i_inst_id    => l_inst_tab(i)
                            , i_split_hash => l_split_hash_tab(i)
                          );
            end if;

            if l_skip = com_api_const_pkg.FALSE then

                savepoint sp_dpp_record;

                begin
                    dpp_api_payment_plan_pkg.get_saved_attribute_value(
                        i_attr_name  => dpp_api_const_pkg.ATTR_MACROS_TYPE_ID
                      , i_dpp_id     => l_dpp_id_tab(i)
                      , o_value      => l_macros_type_id
                    );

                    dpp_api_payment_plan_pkg.get_saved_attribute_value(
                        i_attr_name  => dpp_api_const_pkg.ATTR_MACROS_INTR_TYPE_ID
                      , i_dpp_id     => l_dpp_id_tab(i)
                      , o_value      => l_macros_intr_type_id
                    );

                    dpp_api_payment_plan_pkg.get_saved_attribute_value(
                        i_attr_name  => dpp_api_const_pkg.ATTR_CREDIT_MACROS_TYPE
                      , i_dpp_id     => l_dpp_id_tab(i)
                      , i_mask_error => com_api_const_pkg.TRUE
                      , o_value      => l_credit_macros_type_id
                    );

                    dpp_api_payment_plan_pkg.get_saved_attribute_value(
                        i_attr_name  => dpp_api_const_pkg.ATTR_CREDIT_MACROS_INTR_TYPE
                      , i_dpp_id     => l_dpp_id_tab(i)
                      , i_mask_error => com_api_const_pkg.TRUE
                      , o_value      => l_credit_macros_intr_type_id
                    );

                    dpp_api_payment_plan_pkg.get_saved_attribute_value(
                        i_attr_name  => dpp_api_const_pkg.ATTR_REPAY_MACROS_TYPE_ID
                      , i_dpp_id     => l_dpp_id_tab(i)
                      , i_mask_error => com_api_const_pkg.TRUE
                      , o_value      => l_repay_macros_type_id
                    );

                    dpp_api_payment_plan_pkg.get_saved_attribute_value(
                        i_attr_name  => dpp_api_const_pkg.ATTR_CREDIT_REPAY_MACROS_TYPE
                      , i_dpp_id     => l_dpp_id_tab(i)
                      , i_mask_error => com_api_const_pkg.TRUE
                      , o_value      => l_credit_repay_macros_type_id
                    );

                    -- For the case with separate an instalment account and a credit account,
                    -- it is needed to find one credit account by incoming instalment account <l_account_rec>
                    if  (   l_credit_macros_type_id       is not null
                         or l_credit_macros_intr_type_id  is not null
                         or l_credit_repay_macros_type_id is not null)
                        and l_credit_account_rec.account_id is null -- it is true on 1st DPP of current account only
                    then
                        if l_is_credit_account = com_api_const_pkg.TRUE then
                            -- In case of 2 accounts, current DPP account can't have Credit service
                            com_api_error_pkg.raise_error(
                                i_error      => 'DPP_ACCOUNT_CONTAINS_INSTALMENT_AND_CREDIT_SERVICES'
                            );
                        else
                            l_credit_account_rec := dpp_api_payment_plan_pkg.get_separate_credit_account(
                                                        i_account => l_account_rec
                                                    );
                            l_is_credit_account  := com_api_const_pkg.TRUE;
                        end if;
                    end if;

                    dpp_api_payment_plan_pkg.put_instalment_macros(
                        i_oper_id                     => l_oper_id_tab(i)
                      , i_reg_oper_id                 => l_reg_oper_id_tab(i)
                      , i_amount                      => l_instalment_amount_tab(i)
                      , i_interest_amount             => l_interest_amount_tab(i)
                      , i_repayment_amount            => l_payment_amount_tab(i)
                      , i_currency                    => l_dpp_currency_tab(i)
                      , i_account_rec                 => l_account_rec
                      , i_card_id                     => l_card_tab(i)
                      , i_credit_bunch_type_id        => i_credit_bunch_type_id
                      , i_over_bunch_type_id          => i_over_bunch_type_id
                      , i_intr_bunch_type_id          => i_intr_bunch_type_id
                      , i_lending_bunch_type_id       => i_lending_bunch_type_id
                      , i_posting_date                => l_posting_date_tab(i)
                      , i_eff_date                    => l_sysdate
                      , i_macros_type_id              => l_macros_type_id
                      , i_macros_intr_type_id         => l_macros_intr_type_id
                      , i_repay_macros_type_id        => l_repay_macros_type_id
                      , i_is_credit_account           => l_is_credit_account
                      , i_credit_account_rec          => l_credit_account_rec
                      , i_credit_macros_type_id       => l_credit_macros_type_id
                      , i_credit_macros_intr_type_id  => l_credit_macros_intr_type_id
                      , i_credit_repay_macros_type_id => l_credit_repay_macros_type_id
                      , o_macros_id                   => l_macros_id
                      , o_macros_intr_id              => l_macros_intr_id
                    );

                    l_ok_instalment_id_tab(l_ok_instalment_id_tab.count + 1)    := l_instalment_id_tab(i);
                    l_ok_dpp_id_tab(l_ok_dpp_id_tab.count + 1)                  := l_dpp_id_tab(i);
                    l_ok_next_date_tab(l_ok_next_date_tab.count + 1)            := l_next_instalment_date_tab(i);
                    l_ok_macros_id_tab(l_ok_macros_id_tab.count + 1)            := l_macros_id;
                    l_ok_macros_intr_id_tab(l_ok_macros_intr_id_tab.count + 1)  := l_macros_intr_id;

                    rul_api_shared_data_pkg.load_account_params(
                        i_account       => l_account_rec
                      , io_params       => l_params
                    );

                    rul_api_shared_data_pkg.load_card_params(
                        i_card_id       => l_card_tab(i)
                      , io_params       => l_params
                    );

                    rul_api_shared_data_pkg.load_customer_params(
                        i_customer_id   => l_customer_tab(i)
                      , io_params       => l_params
                    );

                    evt_api_event_pkg.register_event(
                        i_event_type    => dpp_api_const_pkg.EVENT_TYPE_INSTALMNT_DATE_COME
                      , i_eff_date      => l_sysdate
                      , i_entity_type   => dpp_api_const_pkg.ENTITY_TYPE_INSTALMENT
                      , i_object_id     => l_instalment_id_tab(i)
                      , i_inst_id       => l_inst_tab(i)
                      , i_split_hash    => l_split_hash_tab(i)
                      , i_param_tab     => l_params
                    );

                    -- Register the repayment event if the being charged instalment is the last one
                    if l_ok_next_date_tab(i) is null then
                        evt_api_event_pkg.register_event(
                            i_event_type    => dpp_api_const_pkg.EVENT_TYPE_REPAID
                          , i_eff_date      => l_sysdate
                          , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id     => l_reg_oper_id_tab(i)
                          , i_inst_id       => l_inst_tab(i)
                          , i_split_hash    => l_split_hash_tab(i)
                          , i_param_tab     => l_params
                        );
                    end if;

                    l_params.delete();

                exception
                    when others then
                        rollback to sp_dpp_record;

                        l_excepted_count := l_excepted_count + 1;
                        prc_api_stat_pkg.log_current(
                            i_current_count     => l_processed_count
                          , i_excepted_count    => l_excepted_count
                        );

                        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                            raise;
                        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                            com_api_error_pkg.raise_fatal_error(
                                i_error         => 'UNHANDLED_EXCEPTION'
                              , i_env_param1    => sqlerrm
                            );
                        end if;
                end;

                if mod(l_processed_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count     => l_processed_count
                      , i_excepted_count    => l_excepted_count
                    );
                end if;
            end if;
        end loop;

        forall i in 1 .. l_ok_instalment_id_tab.count
            update dpp_instalment
               set macros_id = l_ok_macros_id_tab(i)
                 , macros_intr_id = l_ok_macros_intr_id_tab(i)
             where id = l_ok_instalment_id_tab(i);

        forall i in 1 .. l_ok_dpp_id_tab.count
            update dpp_payment_plan
               set instalment_billed = instalment_billed + 1
                 , next_instalment_date = l_ok_next_date_tab(i)
                 , status = decode(l_ok_next_date_tab(i), null, dpp_api_const_pkg.DPP_OPERATION_PAID, status)
             where id = l_ok_dpp_id_tab(i);

        l_ok_instalment_id_tab.delete;
        l_ok_dpp_id_tab.delete;
        l_ok_next_date_tab.delete;
        l_ok_macros_id_tab.delete;

        exit when cu_current_dpp%notfound;
    end loop;

    close cu_current_dpp;

    prc_api_stat_pkg.log_end(
        i_processed_total => l_processed_count
      , i_excepted_total  => l_excepted_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to sp_dpp_process;

        if cu_instalments_count%isopen then
            close cu_instalments_count;
        end if;

        if cu_current_dpp%isopen then
            close cu_current_dpp;
        end if;

        prc_api_stat_pkg.log_end(
            i_processed_total   => l_processed_count
          , i_excepted_total    => l_excepted_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end process;

end;
/
