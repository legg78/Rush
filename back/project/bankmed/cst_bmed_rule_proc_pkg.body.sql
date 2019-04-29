create or replace package body cst_bmed_rule_proc_pkg as

procedure get_macros_type_id(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
  , i_oper_date           in     date
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , o_macros_type_id         out com_api_type_pkg.t_long_id
  , o_is_active_service      out com_api_type_pkg.t_boolean
)
is
    l_service_id                 com_api_type_pkg.t_short_id;
    l_attr_name                  com_api_type_pkg.t_name;
begin
    l_attr_name  := prd_api_attribute_pkg.get_attribute(
                        i_attr_id     => opr_api_shared_data_pkg.get_param_num('PRODUCT_ATTRIBUTE')
                    ).attr_name;

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
        o_macros_type_id    := prd_api_product_pkg.get_attr_value_number(
                                   i_entity_type  => i_entity_type
                                 , i_object_id    => i_object_id
                                 , i_attr_name    => l_attr_name
                                 , i_service_id   => l_service_id
                                 , i_eff_date     => i_oper_date
                                 , i_split_hash   => i_split_hash
                                 , i_inst_id      => i_inst_id
                               );

        o_is_active_service := com_api_type_pkg.TRUE;
    else
        o_is_active_service := com_api_type_pkg.FALSE;
    end if;
end get_macros_type_id;

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
    l_main_macros_type_id           com_api_type_pkg.t_long_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_is_active_service             com_api_type_pkg.t_boolean     := com_api_type_pkg.TRUE;
    l_oper_date                     date;
    l_start_date                    date;
    l_expire_date                   date;
    l_macros_id                     com_api_type_pkg.t_long_id;
    l_bunch_id                      com_api_type_pkg.t_long_id;
    l_account                       acc_api_type_pkg.t_account_rec;
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

    opr_api_shared_data_pkg.get_account(
        i_name              => l_account_name
      , o_account_rec       => l_account
    );

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
          , o_macros_type_id    => l_main_macros_type_id
          , o_is_active_service => l_is_active_service
        );
    end if;

    if l_is_active_service = com_api_type_pkg.TRUE then
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
        
        if l_main_macros_type_id is not null then
        -- Add entries to GL account an main account
            if l_amount.currency = l_result_amount.currency then
                l_result_amount := l_amount;
            else
                l_result_amount.amount :=
                    com_api_rate_pkg.convert_amount(
                        i_src_amount      => l_result_amount.amount
                      , i_src_currency    => l_result_amount.currency
                      , i_dst_currency    => l_amount.currency
                      , i_rate_type       => opr_api_shared_data_pkg.get_param_char('RATE_TYPE')
                      , i_inst_id         => l_inst_id
                      , i_eff_date        => l_oper_date
                      , i_conversion_type => opr_api_shared_data_pkg.get_param_char('CONVERSION_TYPE')
                    );
                l_result_amount.currency := l_amount.currency;
            end if;
            acc_api_entry_pkg.put_macros (
                o_macros_id       => l_macros_id
              , o_bunch_id        => l_bunch_id
              , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id       => opr_api_shared_data_pkg.get_operation().id
              , i_macros_type_id  => l_main_macros_type_id
              , i_amount          => l_result_amount.amount
              , i_currency        => l_result_amount.currency
              , i_account_type    => l_account.account_type
              , i_account_id      => l_account.account_id
              , i_posting_date    => l_oper_date
              , i_fee_id          => null
              , i_param_tab       => opr_api_shared_data_pkg.g_params
            );
            acc_api_entry_pkg.flush_job;

            trc_log_pkg.debug('spent_bonus: macros_id [' || l_macros_id || ']');

            l_result_account := l_account;
        end if;

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

procedure add_link_account
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_link_account: ';
    l_object_id                 com_api_type_pkg.t_long_id;
    l_entity_type               com_api_type_pkg.t_dict_value;
    l_account_id                com_api_type_pkg.t_account_id;
    l_account_link_id           com_api_type_pkg.t_medium_id;
begin
    l_object_id             := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type           := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_account_id            := evt_api_shared_data_pkg.get_param_num('ACCOUNT_ID');

    if  l_account_id is not null then
        acc_api_account_pkg.add_account_link(
            i_account_id      => l_account_id
          , i_object_id       => l_object_id
          , i_entity_type     => l_entity_type
          , i_description     => null
          , o_account_link_id => l_account_link_id
        );
    else
        trc_log_pkg.debug (
            i_text        => LOG_PREFIX || 'not set linked account for entity [#1] object [#2] '
          , i_env_param1  => l_entity_type
          , i_env_param2  => l_object_id
        );
    end if;
end add_link_account;

end cst_bmed_rule_proc_pkg;
/
