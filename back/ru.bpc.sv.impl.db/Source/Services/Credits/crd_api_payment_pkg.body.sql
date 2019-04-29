create or replace package body crd_api_payment_pkg as

procedure create_payment(
    i_macros_id         in      com_api_type_pkg.t_long_id
  , i_oper_id           in      com_api_type_pkg.t_long_id
  , i_is_reversal       in      com_api_type_pkg.t_boolean
  , i_original_id       in      com_api_type_pkg.t_long_id
  , i_oper_date         in      date
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_amount            in      com_api_type_pkg.t_money
  , i_account_id        in      com_api_type_pkg.t_medium_id
  , i_card_id           in      com_api_type_pkg.t_medium_id
  , i_posting_date      in      date
  , i_sttl_day          in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_is_new            in      com_api_type_pkg.t_boolean
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) is
    l_service_id                com_api_type_pkg.t_short_id;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_bunch_id                  com_api_type_pkg.t_long_id;
    l_bunch_type_id             com_api_type_pkg.t_tiny_id;
    l_account_type              com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug('Create payment: macros id ['||i_macros_id||'] account id ['||i_account_id||'] split hash ['||i_split_hash||']');

    l_service_id :=
        crd_api_service_pkg.get_active_service(
            i_account_id        => i_account_id
          , i_eff_date          => i_posting_date
          , i_split_hash        => i_split_hash
        );

    rul_api_param_pkg.set_param(
        i_name     => 'CARD_TYPE_ID'
      , io_params  => l_param_tab
      , i_value    => iss_api_card_pkg.get_card(i_card_id => i_card_id).card_type_id
    );

    if l_service_id is null then
        trc_log_pkg.debug('No active credit service');
        begin
            select e.bunch_type_id
              into l_bunch_type_id
              from crd_event_bunch_type e
             where e.inst_id      = i_inst_id
               and e.event_type   = crd_api_const_pkg.OVERPAYMENT_EVENT
               and rownum         = 1;

            trc_log_pkg.debug('create_payment: l_bunch_type_id='||l_bunch_type_id);

            select account_type
              into l_account_type
              from acc_account
             where id = i_account_id;

            acc_api_entry_pkg.put_bunch (
                o_bunch_id          => l_bunch_id
              , i_bunch_type_id     => l_bunch_type_id
              , i_macros_id         => i_macros_id
              , i_amount            => i_amount
              , i_currency          => i_currency
              , i_account_type      => l_account_type
              , i_account_id        => i_account_id
              , i_posting_date      => i_posting_date
              , i_param_tab         => l_param_tab
            );
            trc_log_pkg.debug('create_payment: l_bunch_id='||l_bunch_id);

            acc_api_entry_pkg.flush_job;
        exception
            when no_data_found then
                null;
        end;

        return;
    end if;

    insert into crd_payment(
        id
      , oper_id
      , is_reversal
      , original_oper_id
      , account_id
      , card_id
      , product_id
      , posting_date
      , sttl_day
      , currency
      , amount
      , pay_amount
      , is_new
      , status
      , inst_id
      , agent_id
      , split_hash
    ) values (
        i_macros_id
      , i_oper_id
      , i_is_reversal
      , i_original_id
      , i_account_id
      , i_card_id
      , i_product_id
      , i_posting_date
      , i_sttl_day
      , i_currency
      , i_amount
      , i_amount
      , i_is_new
      , crd_api_const_pkg.PAYMENT_STATUS_ACTIVE
      , i_inst_id
      , i_agent_id
      , i_split_hash
    );
end create_payment;

procedure create_dpp_payment(
    i_macros_id         in      com_api_type_pkg.t_long_id
  , i_oper_id           in      com_api_type_pkg.t_long_id
  , i_is_reversal       in      com_api_type_pkg.t_boolean
  , i_original_id       in      com_api_type_pkg.t_long_id
  , i_oper_date         in      date
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_amount            in      com_api_type_pkg.t_money
  , i_account_id        in      com_api_type_pkg.t_medium_id
  , i_card_id           in      com_api_type_pkg.t_medium_id
  , i_posting_date      in      date
  , i_sttl_day          in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_is_new            in      com_api_type_pkg.t_boolean
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) is
    l_service_id                com_api_type_pkg.t_short_id;
    l_eff_date                  date;
    l_interest_calc_start_date  com_api_type_pkg.t_dict_value;
    l_param_tab                 com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug('Create dpp payment: macros id ['||i_macros_id||'] account id ['||i_account_id||'] split hash ['||i_split_hash||']');

    l_service_id :=
        crd_api_service_pkg.get_active_service(
            i_account_id        => i_account_id
          , i_eff_date          => i_posting_date
          , i_split_hash        => i_split_hash
        );

    if l_service_id is null then
        trc_log_pkg.debug('No active credit service');
        return;
    end if;

    insert into crd_payment(
        id
      , oper_id
      , is_reversal
      , original_oper_id
      , account_id
      , card_id
      , product_id
      , posting_date
      , sttl_day
      , currency
      , amount
      , pay_amount
      , is_new
      , status
      , inst_id
      , agent_id
      , split_hash
    ) values (
        i_macros_id
      , i_oper_id
      , i_is_reversal
      , i_original_id
      , i_account_id
      , i_card_id
      , i_product_id
      , i_posting_date
      , i_sttl_day
      , i_currency
      , i_amount
      , i_amount
      , i_is_new
      , crd_api_const_pkg.PAYMENT_STATUS_ACTIVE
      , i_inst_id
      , i_agent_id
      , i_split_hash
    );

    l_interest_calc_start_date :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id    => i_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_attr_name     => crd_api_const_pkg.INTEREST_CALC_START_DATE
          , i_service_id    => l_service_id
          , i_split_hash    => i_split_hash
          , i_params        => l_param_tab
          , i_eff_date      => i_posting_date
          , i_inst_id       => i_inst_id
        );

    case l_interest_calc_start_date
        when crd_api_const_pkg.INTEREST_CALC_DATE_POSTING
        then l_eff_date := i_posting_date;

        when crd_api_const_pkg.INTEREST_CALC_DATE_TRANSACTION
        then l_eff_date := i_oper_date;

        else l_eff_date := trunc(i_posting_date) + 1;

    end case;

    l_eff_date := crd_interest_pkg.get_interest_start_date(
                      i_product_id   => i_product_id
                    , i_account_id   => i_account_id
                    , i_split_hash   => i_split_hash
                    , i_service_id   => l_service_id
                    , i_param_tab    => l_param_tab
                    , i_posting_date => i_posting_date
                    , i_eff_date     => l_eff_date
                    , i_inst_id      => i_inst_id
                  );


    crd_payment_pkg.apply_dpp_payment(
        i_payment_id        => i_macros_id
      , i_eff_date          => l_eff_date
      , i_split_hash        => i_split_hash
    );
end create_dpp_payment;

end;
/
