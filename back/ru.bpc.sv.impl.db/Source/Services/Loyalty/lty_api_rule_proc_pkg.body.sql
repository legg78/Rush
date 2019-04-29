create or replace package body lty_api_rule_proc_pkg is
/*********************************************************
*  Loyalty points rules processing <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 10.07.2016 <br />
*  Module: LTY_API_RULE_PROC_PKG <br />
*  @headcom
**********************************************************/

procedure get_macros_type_id(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
  , i_oper_date           in     date
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , io_macros_type_id     in out com_api_type_pkg.t_long_id
  , o_create_operation       out com_api_type_pkg.t_boolean
)
is
    l_service_id                 com_api_type_pkg.t_short_id;
    l_attr_name                  com_api_type_pkg.t_name;
begin
    l_attr_name  := prd_api_attribute_pkg.get_attribute(
                        i_attr_id     => opr_api_shared_data_pkg.get_param_num('PRODUCT_ATTRIBUTE')
                      , i_mask_error  => com_api_type_pkg.TRUE
                    ).attr_name;
    if l_attr_name is not null then
        l_service_id := prd_api_service_pkg.get_active_service_id(
                            i_entity_type => i_entity_type
                          , i_object_id   => i_object_id
                          , i_attr_name   => l_attr_name
                          , i_split_hash  => i_split_hash
                          , i_eff_date    => i_oper_date
                          , i_mask_error  => com_api_type_pkg.TRUE
                          , i_inst_id     => i_inst_id
                        );

        if l_service_id is not null then
            io_macros_type_id   := prd_api_product_pkg.get_attr_value_number(
                                       i_entity_type  => i_entity_type
                                     , i_object_id    => i_object_id
                                     , i_attr_name    => l_attr_name
                                     , i_service_id   => l_service_id
                                     , i_eff_date     => i_oper_date
                                     , i_split_hash   => i_split_hash
                                     , i_inst_id      => i_inst_id
                                   );

            o_create_operation  := com_api_type_pkg.TRUE;
        else
            o_create_operation  := com_api_type_pkg.FALSE;
        end if;
    else
        o_create_operation  := com_api_type_pkg.TRUE;
    end if;
end get_macros_type_id;

procedure create_bonus_auth
is
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    l_result_account                acc_api_type_pkg.t_account_rec;
    l_start_date_name               com_api_type_pkg.t_dict_value;
    l_expire_date_name              com_api_type_pkg.t_dict_value;
    l_macros_type_id                com_api_type_pkg.t_long_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_create_operation              com_api_type_pkg.t_boolean     := com_api_type_pkg.TRUE;
    l_oper_date                     date;
    l_start_date                    date;
    l_end_date                      date;
begin
    l_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME');

    opr_api_shared_data_pkg.get_amount(
        i_name      => l_amount_name
      , o_amount    => l_amount.amount
      , o_currency  => l_amount.currency
    );

    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type   := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');

    l_object_id := opr_api_shared_data_pkg.get_object_id(
                       i_entity_type   =>  l_entity_type
                     , i_account_name  =>  l_account_name
                     , i_party_type    =>  l_party_type
                     , o_inst_id       =>  l_inst_id
                   );

    l_macros_type_id := opr_api_shared_data_pkg.get_param_num('MACROS_TYPE');
    l_oper_date      := opr_api_shared_data_pkg.get_operation().oper_date;
    l_split_hash     := opr_api_shared_data_pkg.get_participant(l_party_type).split_hash;

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        get_macros_type_id(
            i_entity_type       => l_entity_type
          , i_object_id         => l_object_id
          , i_split_hash        => l_split_hash
          , i_oper_date         => l_oper_date
          , i_inst_id           => l_inst_id
          , io_macros_type_id   => l_macros_type_id
          , o_create_operation  => l_create_operation
        );
    end if;

    if l_create_operation = com_api_type_pkg.TRUE then
        lty_api_bonus_pkg.create_bonus(
            i_entity_type       => l_entity_type
          , i_object_id         => l_object_id
          , i_oper_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_oper_id           => opr_api_shared_data_pkg.get_operation().id
          , i_oper_date         => l_oper_date
          , i_oper_amount       => opr_api_shared_data_pkg.get_operation().oper_amount
          , i_oper_currency     => opr_api_shared_data_pkg.get_operation().oper_currency
          , i_split_hash        => l_split_hash
          , i_macros_type       => l_macros_type_id
          , i_inst_id           => l_inst_id
          , i_rate_type         => opr_api_shared_data_pkg.get_param_char('RATE_TYPE')
          , i_conversion_type   => opr_api_shared_data_pkg.get_param_char('CONVERSION_TYPE')
          , i_param_tab         => opr_api_shared_data_pkg.g_params
          , o_result_amount     => l_result_amount
          , o_result_account    => l_result_account
          , o_start_date        => l_start_date
          , o_expire_date       => l_end_date
        );

        l_amount_name := opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

        opr_api_shared_data_pkg.set_amount(
            i_name      => l_amount_name
          , i_amount    => l_result_amount.amount
          , i_currency  => l_result_amount.currency
        );

        opr_api_shared_data_pkg.set_account(
            i_name        => opr_api_shared_data_pkg.get_param_char('RESULT_ACCOUNT_NAME')
          , i_account_rec => l_result_account
        );

        l_start_date_name  := opr_api_shared_data_pkg.get_param_char('START_DATE_NAME');
        l_expire_date_name := opr_api_shared_data_pkg.get_param_char('EXPIRE_DATE_NAME');

        opr_api_shared_data_pkg.set_date(
            i_name    => l_start_date_name
          , i_date    => l_start_date
        );

        opr_api_shared_data_pkg.set_date(
            i_name    => l_expire_date_name
          , i_date    => l_end_date
        );

        trc_log_pkg.debug(
            i_text  => 'Loyalty points have been saved'
        );
    end if;
end create_bonus_auth;

procedure create_bonus_oper
is
    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_fee_type                      com_api_type_pkg.t_dict_value;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    l_result_account                acc_api_type_pkg.t_account_rec;
    l_start_date_name               com_api_type_pkg.t_dict_value;
    l_expire_date_name              com_api_type_pkg.t_dict_value;
    l_macros_type_id                com_api_type_pkg.t_long_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_create_operation              com_api_type_pkg.t_boolean     := com_api_type_pkg.TRUE;
    l_oper_date                     date;
    l_start_date                    date;
    l_expire_date                   date;
begin
    l_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME');

    opr_api_shared_data_pkg.get_amount(
        i_name      => l_amount_name
      , o_amount    => l_amount.amount
      , o_currency  => l_amount.currency
    );

    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type   := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');

    l_object_id    := opr_api_shared_data_pkg.get_object_id(
                          i_entity_type   => l_entity_type
                        , i_account_name  => l_account_name
                        , i_party_type    => l_party_type
                        , o_inst_id       => l_inst_id
                      );

    l_fee_type :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'FEE_TYPE'
          , i_mask_error  => com_api_const_pkg.TRUE
          , i_error_value => null
        );

    if  l_fee_type is null
        and
        opr_api_shared_data_pkg.get_operation().oper_reason like fcl_api_const_pkg.FEE_TYPE_STATUS_KEY || '%'
    then
        l_fee_type := opr_api_shared_data_pkg.get_operation().oper_reason;
    end if;

    l_test_mode :=
        nvl(
            opr_api_shared_data_pkg.get_param_char(
                i_name        => 'ATTR_MISS_TESTMODE'
              , i_mask_error  => com_api_const_pkg.TRUE
              , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
            )
          , fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
        );

    l_macros_type_id := opr_api_shared_data_pkg.get_param_num('MACROS_TYPE');
    l_oper_date      := opr_api_shared_data_pkg.get_operation().oper_date;
    l_split_hash     := opr_api_shared_data_pkg.get_participant(l_party_type).split_hash;

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        get_macros_type_id(
            i_entity_type       => l_entity_type
          , i_object_id         => l_object_id
          , i_split_hash        => l_split_hash
          , i_oper_date         => l_oper_date
          , i_inst_id           => l_inst_id
          , io_macros_type_id   => l_macros_type_id
          , o_create_operation  => l_create_operation
        );
    end if;

    if l_create_operation = com_api_type_pkg.TRUE then
        lty_api_bonus_pkg.create_bonus(
            i_entity_type       => l_entity_type
          , i_object_id         => l_object_id
          , i_oper_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_oper_id           => opr_api_shared_data_pkg.get_operation().id
          , i_oper_date         => l_oper_date
          , i_oper_amount       => l_amount.amount
          , i_oper_currency     => l_amount.currency
          , i_split_hash        => l_split_hash
          , i_macros_type       => l_macros_type_id
          , i_inst_id           => l_inst_id
          , i_rate_type         => opr_api_shared_data_pkg.get_param_char('RATE_TYPE')
          , i_conversion_type   => opr_api_shared_data_pkg.get_param_char('CONVERSION_TYPE')
          , i_fee_type          => l_fee_type
          , i_param_tab         => opr_api_shared_data_pkg.g_params
          , i_test_mode         => l_test_mode
          , o_result_amount     => l_result_amount
          , o_result_account    => l_result_account
          , o_start_date        => l_start_date
          , o_expire_date       => l_expire_date
        );

        l_amount_name := opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');

        opr_api_shared_data_pkg.set_amount(
            i_name        => l_amount_name
          , i_amount      => l_result_amount.amount
          , i_currency    => l_result_amount.currency
        );

        opr_api_shared_data_pkg.set_account(
            i_name        => opr_api_shared_data_pkg.get_param_char('RESULT_ACCOUNT_NAME')
          , i_account_rec => l_result_account
        );

        l_start_date_name  := opr_api_shared_data_pkg.get_param_char('START_DATE_NAME');
        l_expire_date_name := opr_api_shared_data_pkg.get_param_char('EXPIRE_DATE_NAME');

        opr_api_shared_data_pkg.set_date(
            i_name  => l_start_date_name
          , i_date  => l_start_date
        );

        opr_api_shared_data_pkg.set_date(
            i_name  => l_expire_date_name
          , i_date  => l_expire_date
        );
    end if;
end create_bonus_oper;

procedure spend_bonus_oper
is
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_selector                      com_api_type_pkg.t_name;
    l_original_id                   com_api_type_pkg.t_long_id;
    l_macros_type_id                com_api_type_pkg.t_long_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_create_operation              com_api_type_pkg.t_boolean     := com_api_type_pkg.TRUE;
    l_oper_date                     date;
begin
    l_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME');

    opr_api_shared_data_pkg.get_amount(
        i_name      => l_amount_name
      , o_amount    => l_amount.amount
      , o_currency  => l_amount.currency
    );

    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type   := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id    := opr_api_shared_data_pkg.get_object_id(
                          i_entity_type  => l_entity_type
                        , i_account_name => l_account_name
                        , i_party_type   => l_party_type
                        , o_inst_id      => l_inst_id
                      );

    l_selector :=
        opr_api_shared_data_pkg.get_param_char(
            i_name         => 'OPERATION_SELECTOR'
          , i_mask_error   => com_api_const_pkg.TRUE
          , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
        );

    if l_selector is not null then
        l_original_id := opr_api_shared_data_pkg.get_operation_id(i_selector => l_selector);
    end if;

    l_macros_type_id := opr_api_shared_data_pkg.get_param_num('MACROS_TYPE');
    l_oper_date      := opr_api_shared_data_pkg.get_operation().oper_date;
    l_split_hash     := opr_api_shared_data_pkg.get_participant(l_party_type).split_hash;

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        get_macros_type_id(
            i_entity_type       => l_entity_type
          , i_object_id         => l_object_id
          , i_split_hash        => l_split_hash
          , i_oper_date         => l_oper_date
          , i_inst_id           => l_inst_id
          , io_macros_type_id   => l_macros_type_id
          , o_create_operation  => l_create_operation
        );
    end if;

    if l_create_operation = com_api_type_pkg.TRUE then
        begin
            lty_api_bonus_pkg.spend_bonus(
                i_entity_type       => l_entity_type
              , i_object_id         => l_object_id
              , i_oper_date         => l_oper_date
              , i_oper_amount       => l_amount.amount
              , i_oper_currency     => l_amount.currency
              , i_split_hash        => l_split_hash
              , i_inst_id           => l_inst_id
              , i_oper_id           => opr_api_shared_data_pkg.get_operation().id
              , i_original_id       => l_original_id
              , i_macros_type       => l_macros_type_id
              , i_rate_type         => opr_api_shared_data_pkg.get_param_char('RATE_TYPE')
              , i_conversion_type   => opr_api_shared_data_pkg.get_param_char('CONVERSION_TYPE')
              , i_param_tab         => opr_api_shared_data_pkg.g_params
            );
        exception
            when com_api_error_pkg.e_application_error then
                opr_api_shared_data_pkg.rollback_process(
                    i_id      => opr_api_shared_data_pkg.get_operation().id
                  , i_status  => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                  , i_reason  => aup_api_const_pkg.RESP_CODE_UNSUFFICIENT_FUNDS
                );
        end;
    end if;
end spend_bonus_oper;

procedure switch_limit_reward_bonuses
is
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_limit_type                    com_api_type_pkg.t_dict_value;
    l_fee_type                      com_api_type_pkg.t_dict_value;
    l_account_name                  com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_product_id                    com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_sum_limit                     com_api_type_pkg.t_money;
    l_new_limit                     com_api_type_pkg.t_money;
    l_current_limit                 com_api_type_pkg.t_money;
    l_fee_amount                    com_api_type_pkg.t_money;
    l_fee_id                        com_api_type_pkg.t_short_id;
    l_eff_date                      date;
    l_service_id                    com_api_type_pkg.t_short_id;
begin
    l_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'AMOUNT_NAME'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    if l_amount_name is not null then
        opr_api_shared_data_pkg.get_amount(
            i_name       => l_amount_name
          , o_amount     => l_amount.amount
          , o_currency   => l_amount.currency
        );
    end if;

    l_party_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');

    l_entity_type :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'ENTITY_TYPE'
          , i_mask_error  => com_api_const_pkg.FALSE
        );

    l_limit_type :=
        case l_entity_type
            when iss_api_const_pkg.ENTITY_TYPE_CARD        then lty_api_const_pkg.LOYALTY_LIMIT_REWARD_CARD
            when com_api_const_pkg.ENTITY_TYPE_CUSTOMER    then lty_api_const_pkg.LOYALTY_LIMIT_REWARD_CUSTOMER
            when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT     then lty_api_const_pkg.LOYALTY_LIMIT_REWARD_ACCOUNT
            when acq_api_const_pkg.ENTITY_TYPE_MERCHANT    then lty_api_const_pkg.LOYALTY_LIMIT_REWARD_MERCHANT
        end;

    l_fee_type :=
        case l_entity_type
            when iss_api_const_pkg.ENTITY_TYPE_CARD        then lty_api_const_pkg.LOYALTY_REWARD_FEE_TYPE_CARD
            when com_api_const_pkg.ENTITY_TYPE_CUSTOMER    then lty_api_const_pkg.LOYALTY_REWARD_FEE_TYPE_CUST
            when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT     then lty_api_const_pkg.LOYALTY_REWARD_FEE_TYPE_ACCT
            when acq_api_const_pkg.ENTITY_TYPE_MERCHANT    then lty_api_const_pkg.LOYALTY_REWARD_FEE_TYPE_MERCH
        end;

    l_account_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'RESULT_ACCOUNT_NAME'
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
            i_entity_type   => l_entity_type
          , i_object_id     => l_object_id
        );

    l_eff_date := com_api_sttl_day_pkg.get_sysdate;

    l_current_limit :=
        fcl_api_limit_pkg.get_limit_sum_curr(
            i_limit_type      => l_limit_type
          , i_entity_type     => l_entity_type
          , i_object_id       => l_object_id
          , i_limit_id        => null
          , i_mask_error      => null
          , i_split_hash      => null
        );
    l_sum_limit :=
        fcl_api_limit_pkg.get_sum_limit(
            i_limit_type      => l_limit_type
          , i_entity_type     => l_entity_type
          , i_object_id       => l_object_id
          , i_split_hash      => null
          , i_mask_error      => null
        );

    if l_amount.amount + l_current_limit >= l_sum_limit then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type     => l_entity_type
              , i_object_id       => l_object_id
              , i_attr_type       => l_limit_type
              , i_eff_date        => l_eff_date
            );

        l_new_limit := l_current_limit + l_amount.amount - l_sum_limit * trunc((l_current_limit + l_amount.amount) / l_sum_limit);

        fcl_api_limit_pkg.set_limit_counter(
            i_limit_type          => l_limit_type
          , i_entity_type         => l_entity_type
          , i_object_id           => l_object_id
          , i_count_value         => null
          , i_sum_value           => l_new_limit
          , i_eff_date            => l_eff_date
          , i_split_hash          => null
        );

        l_fee_id :=
            prd_api_product_pkg.get_fee_id(
                i_product_id      => l_product_id
              , i_entity_type     => l_entity_type
              , i_object_id       => l_object_id
              , i_fee_type        => l_fee_type
              , i_params          => opr_api_shared_data_pkg.g_params
              , i_service_id      => l_service_id
              , i_eff_date        => l_eff_date
              , i_inst_id         => l_inst_id
            );

        l_fee_amount :=
            fcl_api_fee_pkg.get_fee_amount(
                i_fee_id          => l_fee_id
              , i_base_amount     => l_sum_limit
              , io_base_currency  => l_amount.currency
              , i_entity_type     => l_entity_type
              , i_object_id       => l_object_id
              , i_eff_date        => l_eff_date
              , i_split_hash      => null
            );

        l_fee_amount := l_fee_amount * trunc((l_current_limit + l_amount.amount) / l_sum_limit);


        l_amount_name :=
            opr_api_shared_data_pkg.get_param_char(
                i_name        => 'RESULT_AMOUNT_NAME'
              , i_mask_error  => com_api_const_pkg.FALSE
            );

        opr_api_shared_data_pkg.set_amount(
            i_name      => l_amount_name
          , i_amount    => l_fee_amount
          , i_currency  => l_amount.currency
        );

    else
        fcl_api_limit_pkg.set_limit_counter(
            i_limit_type          => l_limit_type
          , i_entity_type         => l_entity_type
          , i_object_id           => l_object_id
          , i_count_value         => null
          , i_sum_value           => l_amount.amount + l_current_limit
          , i_eff_date            => l_eff_date
          , i_split_hash          => null
        );
    end if;
end switch_limit_reward_bonuses;

procedure lottery_ticket_registration
is
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_entity_type                   com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_sum_limit                     com_api_type_pkg.t_money;
    l_current_limit                 com_api_type_pkg.t_money;
    l_sum_value                     com_api_type_pkg.t_money;
    l_new_limit                     com_api_type_pkg.t_money;
    l_limit_currency                com_api_type_pkg.t_curr_code;
    l_rate_type                     com_api_type_pkg.t_dict_value;
    l_eff_date                      date;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_lottery_ticket_id             com_api_type_pkg.t_long_id;
    l_seqnum                        com_api_type_pkg.t_seqnum;
    l_limit_type                    com_api_type_pkg.t_dict_value;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
begin
    -- Incoming: Participant type, Entity type (card, customer), Amount name, currency rate type
    l_amount_name   :=
        opr_api_shared_data_pkg.get_param_char(
            i_name            => 'AMOUNT_NAME'
          , i_mask_error      => com_api_const_pkg.TRUE
        );

    if l_amount_name is not null then
        opr_api_shared_data_pkg.get_amount (
            i_name                => l_amount_name
            , o_amount            => l_amount.amount
            , o_currency          => l_amount.currency
        );
    end if;

    l_entity_type   := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_name  := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type    := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_eff_date      := com_api_sttl_day_pkg.get_sysdate;
    l_rate_type     := opr_api_shared_data_pkg.get_param_char('RATE_TYPE');

    l_object_id     :=
        opr_api_shared_data_pkg.get_object_id (
            io_entity_type    => l_entity_type
            , i_account_name  => l_account_name
            , i_party_type    => l_party_type
            , o_inst_id       => l_inst_id
        );
    l_split_hash    := com_api_hash_pkg.get_split_hash(l_entity_type, l_object_id);

    begin
        if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
            l_limit_type := lty_api_const_pkg.LOTTERY_TICKET_THRESHOLD;
            l_service_id := prd_api_service_pkg.get_active_service_id(
                i_entity_type      => l_entity_type
              , i_object_id        => l_object_id
              , i_attr_name        => null
              , i_service_type_id  => lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID
              , i_eff_date         => l_eff_date
              , i_mask_error       => com_api_const_pkg.TRUE
              , i_inst_id          => l_inst_id
            );
        elsif l_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            l_limit_type := lty_api_const_pkg.LOTTERY_TICKET_THRESHOLD_CUST;
            l_service_id := prd_api_service_pkg.get_active_service_id(
                i_entity_type      => l_entity_type
              , i_object_id        => l_object_id
              , i_attr_name        => null
              , i_service_type_id  => lty_api_const_pkg.LOYALTY_SERVICE_CUST_TYPE_ID
              , i_eff_date         => l_eff_date
              , i_mask_error       => com_api_const_pkg.TRUE
              , i_inst_id          => l_inst_id
            );
        else
            l_service_id := null;
        end if;
    exception
        when com_api_error_pkg.e_application_error then
            l_service_id := null;
    end;

    if l_service_id is not null then
        l_limit_currency :=
            fcl_api_limit_pkg.get_limit_currency(
                i_limit_type      => l_limit_type
              , i_entity_type     => l_entity_type
              , i_object_id       => l_object_id
              , i_split_hash      => l_split_hash
              , i_mask_error      => null
            );
        l_current_limit :=
            fcl_api_limit_pkg.get_limit_sum_curr(
                i_limit_type      => l_limit_type
              , i_entity_type     => l_entity_type
              , i_object_id       => l_object_id
              , i_limit_id        => null
              , i_mask_error      => null
              , i_split_hash      => l_split_hash
            );
        begin
            l_sum_limit     :=
                fcl_api_limit_pkg.get_sum_limit(
                    i_limit_type      => l_limit_type
                  , i_entity_type     => l_entity_type
                  , i_object_id       => l_object_id
                  , i_split_hash      => l_split_hash
                  , i_mask_error      => null
                );
        exception
            when com_api_error_pkg.e_application_error then
                l_sum_limit := -1;
        end;

        if l_limit_currency is not null and l_limit_currency != l_amount.currency then
            l_sum_value := round(
                com_api_rate_pkg.convert_amount(
                    i_src_amount        => l_amount.amount
                  , i_src_currency      => l_amount.currency       -- incoming currency
                  , i_dst_currency      => l_limit_currency        -- currency of limit
                  , i_rate_type         => l_rate_type
                  , i_inst_id           => l_inst_id
                  , i_eff_date          => l_eff_date
                ));
        end if;

        if l_sum_limit = -1 then
            fcl_api_limit_pkg.set_limit_counter(
                i_limit_type          => l_limit_type
              , i_entity_type         => l_entity_type
              , i_object_id           => l_object_id
              , i_count_value         => null
              , i_sum_value           => l_sum_value + l_current_limit
              , i_eff_date            => l_eff_date
              , i_split_hash          => null
            );
            -- Register lottery ticket
            lty_api_lottery_tickets_pkg.add_lottery_ticket(
                o_id                  => l_lottery_ticket_id
              , o_seqnum              => l_seqnum
              , i_entity_type         => l_entity_type
              , i_object_id           => l_object_id
              , i_registration_date   => l_eff_date
              , i_status              => lty_api_const_pkg.LOTTERY_TICKET_ACTIVE
              , i_inst_id             => l_inst_id
            );

            evt_api_event_pkg.register_event(
                i_event_type          => lty_api_const_pkg.LOTTERY_TICKET_CREATION_EVENT
              , i_eff_date            => opr_api_shared_data_pkg.get_operation().host_date
              , i_entity_type         => lty_api_const_pkg.ENTITY_TYPE_LOTTERY_TICKET
              , i_object_id           => l_lottery_ticket_id
              , i_inst_id             => l_inst_id
              , i_split_hash          => l_split_hash
              , i_param_tab           => opr_api_shared_data_pkg.g_params
            );
        elsif l_sum_value + l_current_limit >= l_sum_limit then
            l_new_limit     := (l_current_limit + l_sum_value) - l_sum_limit * trunc((l_current_limit + l_sum_value) / l_sum_limit);

            fcl_api_limit_pkg.set_limit_counter(
                i_limit_type          => l_limit_type
              , i_entity_type         => l_entity_type
              , i_object_id           => l_object_id
              , i_count_value         => null
              , i_sum_value           => l_new_limit
              , i_eff_date            => l_eff_date
              , i_split_hash          => l_split_hash
            );
            -- Register lottery tickets
            for i in 1..floor((l_sum_value + l_current_limit) / l_sum_limit) loop
                lty_api_lottery_tickets_pkg.add_lottery_ticket(
                    o_id                  => l_lottery_ticket_id
                  , o_seqnum              => l_seqnum
                  , i_entity_type         => l_entity_type
                  , i_object_id           => l_object_id
                  , i_registration_date   => l_eff_date
                  , i_status              => lty_api_const_pkg.LOTTERY_TICKET_ACTIVE
                  , i_inst_id             => l_inst_id
                );
                evt_api_event_pkg.register_event(
                    i_event_type          => lty_api_const_pkg.LOTTERY_TICKET_CREATION_EVENT
                  , i_eff_date            => opr_api_shared_data_pkg.get_operation().host_date
                  , i_entity_type         => lty_api_const_pkg.ENTITY_TYPE_LOTTERY_TICKET
                  , i_object_id           => l_lottery_ticket_id
                  , i_inst_id             => l_inst_id
                  , i_split_hash          => l_split_hash
                  , i_param_tab           => opr_api_shared_data_pkg.g_params
                );
            end loop;
        else
            fcl_api_limit_pkg.set_limit_counter(
                i_limit_type          => l_limit_type
              , i_entity_type         => l_entity_type
              , i_object_id           => l_object_id
              , i_count_value         => null
              , i_sum_value           => l_sum_value + l_current_limit
              , i_eff_date            => l_eff_date
              , i_split_hash          => l_split_hash
            );
        end if;
    end if;
end lottery_ticket_registration;

procedure check_lty_account
is
    l_params                com_api_type_pkg.t_param_tab;
    l_object_id             com_api_type_pkg.t_long_id;
    l_entity_type           com_api_type_pkg.t_dict_value;
    l_event_date            date;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_service_id            com_api_type_pkg.t_short_id;
    l_account_type          com_api_type_pkg.t_dict_value;
    l_account_currency      com_api_type_pkg.t_curr_code;
    l_product_id            com_api_type_pkg.t_short_id;
    l_customer_id           com_api_type_pkg.t_long_id;
    l_account_id            com_api_type_pkg.t_long_id;
    l_agent_id              com_api_type_pkg.t_agent_id;
    l_contract_id           com_api_type_pkg.t_medium_id;
    l_customer_number       com_api_type_pkg.t_name;
    l_account_number        com_api_type_pkg.t_account_number;
    l_account_object_id     com_api_type_pkg.t_long_id;
    l_account_service_id    com_api_type_pkg.t_short_id;
    l_service_type_id       com_api_type_pkg.t_short_id;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id     := rul_api_param_pkg.get_param_num ('OBJECT_ID',    l_params);
    l_entity_type   := rul_api_param_pkg.get_param_char('ENTITY_TYPE',  l_params);
    l_split_hash    := rul_api_param_pkg.get_param_num ('SPLIT_HASH',   l_params);
    l_inst_id       := rul_api_param_pkg.get_param_num ('INST_ID',      l_params);
    l_event_date    := rul_api_param_pkg.get_param_date('EVENT_DATE',   l_params);
    l_contract_id   := rul_api_param_pkg.get_param_num ('CONTRACT_ID',  l_params);

    if l_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD) then
        select c.customer_id
             , t.agent_id
             , s.customer_number
          into l_customer_id
             , l_agent_id
             , l_customer_number
          from iss_card c
             , prd_contract t
             , prd_customer s
         where c.id          = l_object_id
           and c.contract_id = t.id
           and c.customer_id = s.id;

    elsif l_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CUSTOMER) then
        select c.agent_id
             , c.contract_number
          into l_agent_id
             , l_customer_number
          from prd_contract c
         where c.id = l_contract_id;

        l_customer_id := l_object_id;

    elsif l_entity_type in (acc_api_const_pkg.ENTITY_TYPE_ACCOUNT) then
        select a.customer_id
             , a.agent_id
             , c.customer_number
          into l_customer_id
             , l_agent_id
             , l_customer_number
          from acc_account a
             , prd_customer c
         where a.id = l_object_id
           and a.customer_id = c.id;

    elsif l_entity_type in (acq_api_const_pkg.ENTITY_TYPE_MERCHANT) then
        select t.customer_id
             , t.agent_id
             , s.customer_number
          into l_customer_id
             , l_agent_id
             , l_customer_number
          from acq_merchant m
             , prd_contract t
             , prd_customer s
         where m.id          = l_object_id
           and m.contract_id = t.id
           and t.customer_id = s.id;
    else
        com_api_error_pkg.raise_error(
            i_error       => 'UNKNOWN_ENTITY_TYPE'
          , i_env_param1  => l_entity_type
        );
    end if;

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
        );

    l_service_type_id :=
        lty_api_bonus_pkg.get_service_type_id(
            i_entity_type  => l_entity_type
        );

    -- get service
    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type      => l_entity_type
          , i_object_id        => l_object_id
          , i_attr_name        => null
          , i_service_type_id  => l_service_type_id
          , i_eff_date         => l_event_date
          , i_mask_error       => com_api_const_pkg.FALSE
          , i_inst_id          => l_inst_id
        );

    -- get account type and currency
    l_account_type :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id   => l_product_id
          , i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
          , i_attr_name    => lty_api_bonus_pkg.decode_attr_name(
                                  i_attr_name    => lty_api_const_pkg.LOYALTY_ATTR_ACC_TYPE
                                , i_entity_type  => l_entity_type
                              )
          , i_params       => l_params
          , i_service_id   => l_service_id
          , i_eff_date     => l_event_date
          , i_inst_id      => l_inst_id
        );
    l_account_currency :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id   => l_product_id
          , i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
          , i_attr_name    => lty_api_bonus_pkg.decode_attr_name(
                                  i_attr_name    => lty_api_const_pkg.LOYALTY_ATTR_ACC_CURR
                                , i_entity_type  => l_entity_type
                              )
          , i_params       => l_params
          , i_service_id   => l_service_id
          , i_eff_date     => l_event_date
          , i_inst_id      => l_inst_id
        );

    -- check if account exists
    begin
        select acc.id
          into l_account_id
          from acc_account_object o
             , acc_account acc
         where o.account_id      = acc.id
           and o.entity_type     = l_entity_type
           and o.object_id       = l_object_id
           and acc.account_type  = l_account_type
           and acc.currency      = l_account_currency
           and acc.status       != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED;
    exception
        when no_data_found then
            null;
    end;

    -- need to be created
    if l_account_id is null then
        acc_api_account_pkg.create_account(
            o_id                  => l_account_id
          , io_split_hash         => l_split_hash
          , i_account_type        => l_account_type
          , io_account_number     => l_account_number
          , i_currency            => l_account_currency
          , i_inst_id             => l_inst_id
          , i_agent_id            => l_agent_id
          , i_status              => acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
          , i_contract_id         => l_contract_id
          , i_customer_id         => l_customer_id
          , i_customer_number     => l_customer_number
        );

        -- attach service to account
        begin
            select t.service_id
              into l_account_service_id
              from acc_product_account_type t
             where t.product_id      = l_product_id
               and t.account_type    = l_account_type
               and (t.currency       = l_account_currency or t.currency is null);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'SERVICE_NOT_FOUND_ON_PRODUCT'
                  , i_env_param2 => l_product_id
                );
        end;

        prd_ui_service_pkg.set_service_object(
            i_service_id   => l_account_service_id
          , i_contract_id  => l_contract_id
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => l_account_id
          , i_start_date   => l_event_date
          , i_end_date     => null
          , i_inst_id      => l_inst_id
          , i_params       => l_params
        );
        trc_log_pkg.debug(
            i_text       => 'loyalty account created: l_account_type [#1], l_account_currency [#2]'
                         || ', l_account_id [#3], l_entity_type [#4], l_object_id [#5]'
          , i_env_param1 => l_account_type
          , i_env_param2 => l_account_currency
          , i_env_param3 => l_account_id
          , i_env_param4 => l_entity_type
          , i_env_param5 => l_object_id
        );
    end if;

    -- check link to object
    begin
        select account_id
          into l_account_id
          from acc_account_object o
         where o.object_id   = l_object_id
           and o.entity_type = l_entity_type
           and o.account_id  = l_account_id;
    exception
        when no_data_found then
            acc_api_account_pkg.add_account_object(
                i_account_id        => l_account_id
              , i_entity_type       => l_entity_type
              , i_object_id         => l_object_id
              , o_account_object_id => l_account_object_id
            );
    end;
end check_lty_account;

procedure get_account_balance
is
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_event_date                    date;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_balance_type                  com_api_type_pkg.t_name;
    l_balances                      com_api_type_pkg.t_amount_by_name_tab;
    l_balance_amount                com_api_type_pkg.t_money;
    l_amount                        com_api_type_pkg.t_amount_rec;
begin
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_inst_id     := evt_api_shared_data_pkg.get_param_num('INST_ID');

    lty_api_bonus_pkg.get_lty_account(
        i_entity_type => l_entity_type
      , i_object_id   => l_object_id
      , i_inst_id     => l_inst_id
      , i_eff_date    => l_event_date
      , i_mask_error  => com_api_const_pkg.FALSE
      , o_account     => l_account
    ); 

    l_balance_type := evt_api_shared_data_pkg.get_param_char('BALANCE_TYPE');

    acc_api_balance_pkg.get_account_balances(
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

    evt_api_shared_data_pkg.set_amount(
        i_name      => nvl(evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME'), l_balance_type)
      , i_amount    => l_amount.amount
      , i_currency  => l_amount.currency
    );

    evt_api_shared_data_pkg.set_account(
        i_name         => evt_api_shared_data_pkg.get_param_char(
                              i_name         => 'RESULT_ACCOUNT_NAME'
                            , i_mask_error   => com_api_const_pkg.FALSE
                            , i_error_value  => null
                          )
      , i_account_rec  => l_account
    );
end get_account_balance;

procedure calculate_lty_points
is
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_event_date                    date;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_fee_id                        com_api_type_pkg.t_short_id;
    l_fee_amount                    com_api_type_pkg.t_money;
begin
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_inst_id     := evt_api_shared_data_pkg.get_param_num('INST_ID');

    lty_api_bonus_pkg.get_lty_account_info(
        i_entity_type  => l_entity_type
      , i_object_id    => l_object_id
      , i_inst_id      => l_inst_id
      , i_eff_date     => l_event_date
      , i_mask_error   => com_api_const_pkg.FALSE
      , o_account      => l_account
      , o_service_id   => l_service_id
      , o_product_id   => l_product_id
    );

    l_fee_id :=
        prd_api_product_pkg.get_fee_id(
            i_product_id   => l_product_id
          , i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
          , i_fee_type     => evt_api_shared_data_pkg.get_param_char('FEE_TYPE')
          , i_params       => evt_api_shared_data_pkg.g_params
          , i_service_id   => l_service_id
          , i_eff_date     => l_event_date
          , i_inst_id      => l_inst_id
          , i_mask_error   => com_api_const_pkg.TRUE
        );
    trc_log_pkg.debug(
        i_text       => 'l_fee_id [' || l_fee_id || ']'
    );

    l_fee_amount :=
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id          => l_fee_id
          , i_base_amount     => 0
          , io_base_currency  => l_account.currency
          , i_entity_type     => l_entity_type
          , i_object_id       => l_object_id
          , i_eff_date        => l_event_date
          , i_split_hash      => com_api_hash_pkg.get_split_hash(
                                     i_entity_type  => l_entity_type
                                   , i_object_id    => l_object_id
                                 )
        );
    trc_log_pkg.debug(
        i_text       => 'l_fee_amount [' || l_fee_amount || ']'
    );

    evt_api_shared_data_pkg.set_amount(
        i_name      => evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME')
      , i_amount    => l_fee_amount
      , i_currency  => l_account.currency
    );

    evt_api_shared_data_pkg.set_account(
        i_name         => evt_api_shared_data_pkg.get_param_char(
                              i_name         => 'RESULT_ACCOUNT_NAME'
                            , i_mask_error   => com_api_const_pkg.FALSE
                            , i_error_value  => null
                          )
      , i_account_rec  => l_account
    );
end calculate_lty_points;

procedure move_bonus_oper 
as
    l_amount_name                com_api_type_pkg.t_name;
    l_amount                     com_api_type_pkg.t_amount_rec;
    l_src_account_name           com_api_type_pkg.t_name;
    l_src_account                acc_api_type_pkg.t_account_rec;
    l_dst_account_name           com_api_type_pkg.t_name;
    l_dst_account                acc_api_type_pkg.t_account_rec;
begin
    l_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME');
    opr_api_shared_data_pkg.get_amount(
        i_name      => l_amount_name
      , o_amount    => l_amount.amount
      , o_currency  => l_amount.currency
    );
    
    l_src_account_name := opr_api_shared_data_pkg.get_param_char('SOURCE_ACCOUNT_NAME');
    opr_api_shared_data_pkg.get_account(
        i_name              => l_src_account_name
      , o_account_rec       => l_src_account
    );
    
    l_dst_account_name := opr_api_shared_data_pkg.get_param_char('DESTINATION_ACCOUNT_NAME');
    opr_api_shared_data_pkg.get_account(
        i_name              => l_dst_account_name
      , o_account_rec       => l_dst_account
    );
    
    lty_api_bonus_pkg.move_bonus(
        i_src_account            => l_src_account
      , i_dst_account            => l_dst_account
      , i_oper_id                => opr_api_shared_data_pkg.get_operation().id
      , i_oper_date              => opr_api_shared_data_pkg.get_operation().oper_date
      , i_oper_amount            => l_amount.amount
      , i_oper_currency          => l_amount.currency
      , i_debit_macros_type      => opr_api_shared_data_pkg.get_param_num('DEBIT_MACROS_TYPE')
      , i_credit_macros_type     => opr_api_shared_data_pkg.get_param_num('CREDIT_MACROS_TYPE')
      , i_rate_type              => opr_api_shared_data_pkg.get_param_char('RATE_TYPE')
      , i_conversion_type        => opr_api_shared_data_pkg.get_param_char('CONVERSION_TYPE')
      , i_param_tab              => opr_api_shared_data_pkg.g_params
    );
end move_bonus_oper;

procedure spend_operation as
    l_oper_id                   com_api_type_pkg.t_long_id;
    l_check_direction           com_api_type_pkg.t_boolean;
    l_amount_name               com_api_type_pkg.t_name;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_merchant_id               com_api_type_pkg.t_medium_id;
    l_reward                    com_api_type_pkg.t_money;
    l_oper_amount               com_api_type_pkg.t_money;
    l_reward_oper_amount        com_api_type_pkg.t_money;
    l_fee_id                    com_api_type_pkg.t_short_id;
    l_fee_amount                com_api_type_pkg.t_money;
    l_eff_date                  date;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_card_number               com_api_type_pkg.t_card_number;
begin
    l_oper_id         := opr_api_shared_data_pkg.get_operation().id;
    l_oper_amount     := opr_api_shared_data_pkg.get_operation().oper_amount;
    l_check_direction := 
        nvl(
            opr_api_shared_data_pkg.get_param_num('CHECK_DIRECTION', i_mask_error => com_api_const_pkg.TRUE)
          , com_api_const_pkg.TRUE
        );
    l_eff_date    := opr_api_shared_data_pkg.get_operation().oper_date;
    l_merchant_id := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ACQUIRER).merchant_id;
    l_inst_id     := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ACQUIRER).inst_id;
    l_card_number := 
        iss_api_token_pkg.encode_card_number(
            i_card_number => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
        );
    
    select nvl(sum(o.oper_amount),0) as oper_amount
      into l_reward_oper_amount
      from opr_operation o
         , acc_macros m
     where m.entity_type       = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and m.object_id         = o.id
       and m.macros_type_id    = lty_api_const_pkg.LTY_RWRD_ENROLL_MACROS_TYPE_ID
       and o.id in (select id from lty_spent_operation where spent_oper_id = l_oper_id);
       
    trc_log_pkg.debug(
        i_text       => 'l_reward_oper_amount [' || l_reward_oper_amount || ']'
    );
    
    if l_check_direction = com_api_const_pkg.TRUE then
        begin
            l_fee_id :=
                prd_api_product_pkg.get_fee_id(
                    i_product_id      => prd_api_product_pkg.get_product_id(
                                             i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                           , i_object_id   => l_merchant_id
                                           , i_eff_date    => l_eff_date
                                           , i_inst_id     => l_inst_id
                                         )
                  , i_entity_type     => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                  , i_object_id       => l_merchant_id
                  , i_fee_type        => lty_api_const_pkg.LTY_MRCH_RWRD_RDMPT_FEE_TYPE
                  , i_params          => opr_api_shared_data_pkg.g_params
                  , i_eff_date        => l_eff_date
                  , i_split_hash      => l_split_hash
                  , i_inst_id         => l_inst_id
                  , i_mask_error      => com_api_const_pkg.TRUE
                );
            
            trc_log_pkg.debug(
                i_text       => 'l_fee_id [' || l_fee_id || ']'
            );
            
            if l_fee_id is not null then
                l_fee_amount :=
                    fcl_api_fee_pkg.get_fee_amount(
                        i_fee_id          => l_fee_id
                      , i_base_amount     => 0
                      , io_base_currency  => l_currency
                      , i_entity_type     => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                      , i_object_id       => l_merchant_id
                      , i_eff_date        => l_eff_date
                      , i_split_hash      => l_split_hash
                    );
               trc_log_pkg.debug(
                   i_text       => 'l_fee_amount [' || l_fee_amount || ']'
               );
            end if;
        exception
            when com_api_error_pkg.e_application_error then
                null;
        end;
        
        if l_fee_amount is not null and l_reward_oper_amount < l_fee_amount then
            opr_api_shared_data_pkg.rollback_process(
                i_id      => opr_api_shared_data_pkg.get_operation().id
              , i_status  => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
              , i_reason  => aup_api_const_pkg.RESP_CODE_UNSUFFICIENT_FUNDS
            );
        end if;
    end if;
    
    select nvl(sum(m.amount),0) as reward_amount
      into l_reward
      from opr_operation o
         , opr_participant a
         , opr_participant i
         , acc_macros m
         , opr_card ci 
     where a.oper_id           = o.id
       and a.participant_type  = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and i.oper_id           = o.id
       and i.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER
       and ci.oper_id          = o.id
       and ci.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and m.entity_type       = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and m.object_id         = o.id
       and m.macros_type_id    = lty_api_const_pkg.LTY_RWRD_ENROLL_MACROS_TYPE_ID
       and a.merchant_id       = l_merchant_id
       and reverse(ci.card_number) like reverse(l_card_number)
       and o.id not in (select id from lty_spent_operation where spent_oper_id = l_oper_id);
    
    -- consider the rest of bonuses for chosen operations
    l_reward := l_reward + greatest(l_reward_oper_amount - l_oper_amount,0);
    
    l_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'RESULT_AMOUNT_NAME'
        );

    opr_api_shared_data_pkg.set_amount(
        i_name            => l_amount_name
      , i_amount          => l_reward
      , i_currency        => opr_api_shared_data_pkg.get_operation().oper_currency
    );
end spend_operation;

end lty_api_rule_proc_pkg;
/
