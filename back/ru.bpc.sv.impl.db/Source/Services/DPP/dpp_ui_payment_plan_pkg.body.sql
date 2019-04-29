create or replace package body dpp_ui_payment_plan_pkg as
/*********************************************************
*  User interface for instalment plan (DPP). <br />
*  Created by  E. Kryukov(krukov@bpc.ru)  at 07.09.2011 <br />
*  Module: DPP_UI_PAYMENT_PLAN_PKG <br />
*  @headcom
**********************************************************/

procedure accelerate_dpp(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
  , i_new_count               in     com_api_type_pkg.t_tiny_id            default null
  , i_payment_amount          in     com_api_type_pkg.t_money              default null
  , i_acceleration_type       in     com_api_type_pkg.t_dict_value
) is
begin
    dpp_api_payment_plan_pkg.accelerate_dpp(
        i_dpp_id            => i_dpp_id
      , i_new_count         => i_new_count
      , i_payment_amount    => i_payment_amount
      , i_acceleration_type => i_acceleration_type
    );
end;

procedure cancel_dpp(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
) is
begin
    dpp_api_payment_plan_pkg.cancel_dpp(i_dpp_id  => i_dpp_id);
end;

procedure register_dpp(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_instalment_count        in     com_api_type_pkg.t_tiny_id
  , i_fee_id                  in     com_api_type_pkg.t_money
  , i_dpp_amount              in     com_api_type_pkg.t_money
  , i_dpp_currency            in     com_api_type_pkg.t_curr_code          default null
  , i_macros_id               in     com_api_type_pkg.t_long_id
  , i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_dpp_algorithm           in     com_api_type_pkg.t_dict_value         default null
) is
    l_param_tab                      com_api_type_pkg.t_param_tab;
    l_currency                       com_api_type_pkg.t_curr_code;
begin
    if i_dpp_currency is null then
        select currency into l_currency from acc_account where id = i_account_id;
    else
        l_currency  := i_dpp_currency;
    end if;

    dpp_api_payment_plan_pkg.register_dpp(
        i_account_id        => i_account_id
      , i_dpp_algorithm     => i_dpp_algorithm
      , i_instalment_count  => i_instalment_count
      , i_instalment_amount => null
      , i_fee_id            => i_fee_id
      , i_dpp_amount        => i_dpp_amount
      , i_dpp_currency      => l_currency
      , i_macros_id         => i_macros_id
      , i_oper_id           => i_oper_id
      , i_param_tab         => l_param_tab
    );
end;

procedure get_dpp_amount(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_macros_id               in     com_api_type_pkg.t_long_id
  , o_dpp_amount                 out com_api_type_pkg.t_money
  , o_dpp_currency               out com_api_type_pkg.t_curr_code
) is
begin
    dpp_api_payment_plan_pkg.get_dpp_amount(
        i_account_id    => i_account_id
      , i_macros_id     => i_macros_id
      , o_dpp_amount    => o_dpp_amount
      , o_dpp_currency  => o_dpp_currency
    );
end;

function get_amount_to_cancel(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
  , i_inst_id                 in     com_api_type_pkg.t_inst_id            default null
  , i_eff_date                in     date                                  default null
  , i_rest_amount             in     com_api_type_pkg.t_money              default null
  , i_fee_id                  in     com_api_type_pkg.t_short_id           default null
  , i_last_bill_date          in     date                                  default null
) return com_api_type_pkg.t_money is
    l_amount                         com_api_type_pkg.t_money;
    l_interest_amount                com_api_type_pkg.t_money;
begin
        dpp_api_payment_plan_pkg.get_amount_to_cancel(
            i_dpp_id            => i_dpp_id
          , i_inst_id           => i_inst_id
          , i_eff_date          => i_eff_date
          , i_rest_amount       => i_rest_amount
          , i_fee_id            => i_fee_id
          , i_last_bill_date    => i_last_bill_date
          , o_amount            => l_amount
          , o_interest_amount   => l_interest_amount
        );
    return l_amount;
end;

/*
 * Calculate instalment payments for some specified fee ID.
 */
procedure calculate_dpp(
    i_dpp_amount              in     com_api_type_pkg.t_money
  , i_fee_id                  in     com_api_type_pkg.t_short_id
  , i_instalment_count        in     com_api_type_pkg.t_tiny_id            default null
  , i_instalment_period       in     com_api_type_pkg.t_tiny_id            default null
  , i_instalment_amount       in     com_api_type_pkg.t_money              default null
  , i_first_instalment_date   in     date                                  default null
  , i_calc_algorithm          in     com_api_type_pkg.t_dict_value         default null
  , i_inst_id                 in     com_api_type_pkg.t_inst_id            default null
  , i_first_cycle_id          in     com_api_type_pkg.t_short_id           default null
  , i_main_cycle_id           in     com_api_type_pkg.t_short_id           default null
  , o_dpp                        out dpp_api_type_pkg.t_dpp_program
  , o_instalments                out dpp_api_type_pkg.t_dpp_instalment_tab
) is
begin
    com_api_dictionary_pkg.check_article(
        i_dict  => dpp_api_const_pkg.DPP_ALGORITHM_KEY
      , i_code  => i_calc_algorithm
    );

    o_dpp.instalment_count    := nvl(i_instalment_count, 0);
    o_dpp.instalment_amount   := nvl(i_instalment_amount, 0);
    o_dpp.dpp_amount          := nvl(i_dpp_amount, 0);
    o_dpp.fee_id              := i_fee_id;
    o_dpp.calc_algorithm      := i_calc_algorithm;
    o_dpp.inst_id             := i_inst_id;
    o_dpp.first_cycle_id      := i_first_cycle_id;
    o_dpp.main_cycle_id       := i_main_cycle_id;

    dpp_api_payment_plan_pkg.calc_instalments(
        io_dpp                => o_dpp
      , i_first_amount        => 0
      , io_instalments        => o_instalments
      , i_first_payment_date  => i_first_instalment_date
    );
end calculate_dpp;

/*
 * Calculate instalment payments for specified merchant using interest rate from fee
 * dpp_api_const_pkg.ATTR_MERCHANT_FEE_ID of service "Deferred payment plan (merchant)".
 */
procedure calculate_dpp(
    i_dpp_amount              in     com_api_type_pkg.t_money
  , i_instalment_count        in     com_api_type_pkg.t_tiny_id            default null
  , i_instalment_amount       in     com_api_type_pkg.t_money              default null
  , i_instalment_period       in     com_api_type_pkg.t_tiny_id            default null
  , i_first_instalment_date   in     date                                  default null
  , i_interest_amount         in     com_api_type_pkg.t_money              default null
  , i_calc_algorithm          in     com_api_type_pkg.t_dict_value         default null
  , i_merchant_number         in     com_api_type_pkg.t_merchant_number    default null
  , i_inst_id                 in     com_api_type_pkg.t_inst_id            default null
  , o_installment_plan           out clob
) is
    l_merchant                       acq_api_type_pkg.t_merchant;
    l_params                         com_api_type_pkg.t_param_tab;
    l_eff_date                       date;
    l_service_id                     com_api_type_pkg.t_short_id;
    l_fee_id                         com_api_type_pkg.t_short_id;
    l_dpp                            dpp_api_type_pkg.t_dpp_program;
    l_instalments                    dpp_api_type_pkg.t_dpp_instalment_tab;
begin
    l_eff_date := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);

    l_merchant :=
        acq_api_merchant_pkg.get_merchant(
            i_inst_id          => i_inst_id
          , i_merchant_number  => i_merchant_number
          , i_mask_error       => com_api_const_pkg.FALSE
        );

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type      => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , i_object_id        => l_merchant.id
          , i_attr_name        => null
          , i_service_type_id  => dpp_api_const_pkg.DPP_MERCHANT_SERVICE_TYPE_ID
          , i_split_hash       => l_merchant.split_hash
          , i_eff_date         => l_eff_date
          , i_inst_id          => i_inst_id
        );

    l_fee_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id   => l_merchant.product_id
          , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , i_object_id    => l_merchant.id
          , i_attr_name    => dpp_api_const_pkg.ATTR_MERCHANT_FEE_ID
          , i_params       => l_params
          , i_service_id   => l_service_id
          , i_eff_date     => l_eff_date
          , i_split_hash   => l_merchant.split_hash
          , i_inst_id      => i_inst_id
        );

    calculate_dpp(
        i_dpp_amount             => i_dpp_amount
      , i_fee_id                 => l_fee_id
      , i_instalment_count       => i_instalment_count
      , i_instalment_amount      => i_instalment_amount
      , i_first_instalment_date  => i_first_instalment_date
      , i_calc_algorithm         => i_calc_algorithm
      , i_inst_id                => i_inst_id
      , o_dpp                    => l_dpp
      , o_instalments            => l_instalments
    );

    o_installment_plan :=
        '<installment_plan><transaction_amount>' || to_char(i_dpp_amount, com_api_const_pkg.XML_NUMBER_FORMAT) || '</transaction_amount>'
     || '<installments_count>'     || to_char(l_dpp.instalment_count, com_api_const_pkg.XML_NUMBER_FORMAT) || '</installments_count>'
     || '<fixed_payment_amount>'   || to_char(l_dpp.instalment_amount, com_api_const_pkg.XML_NUMBER_FORMAT) || '</fixed_payment_amount>'
     || '<installment_period>'     || to_char(i_instalment_period, com_api_const_pkg.XML_NUMBER_FORMAT) || '</installment_period>'
     || '<first_installment_date>' || to_char(i_first_instalment_date, com_api_const_pkg.XML_DATE_FORMAT) || '</first_installment_date>'
     || '<interest_rate>'          || to_char(dpp_api_payment_plan_pkg.get_year_percent_in_fraction(i_fee_id => l_fee_id)
                                            , com_api_const_pkg.XML_NUMBER_FORMAT) || '</interest_rate>'
     || '<installment_algorithm>'  || i_calc_algorithm || '</installment_algorithm>'
     || '<installments>';

    for i in 1 .. l_dpp.instalment_count loop
        o_installment_plan :=
            o_installment_plan
            || '<installment>'
            || '<number>'   || to_char(i, com_api_const_pkg.XML_NUMBER_FORMAT) || '</number>'
            || '<date>'     || to_char(l_instalments(i).instalment_date, com_api_const_pkg.XML_DATE_FORMAT) || '</date>'
            || '<amount>'   || to_char(l_instalments(i).amount, com_api_const_pkg.XML_NUMBER_FORMAT) || '</amount>'
            || '<installment_amount>' || to_char(l_instalments(i).amount, com_api_const_pkg.XML_NUMBER_FORMAT) || '</installment_amount>'
            || '<interest>' || to_char(l_instalments(i).interest, com_api_const_pkg.XML_NUMBER_FORMAT) || '</interest>'
            || '</installment>';
    end loop;

    o_installment_plan := o_installment_plan || '</installments></installment_plan>';

end calculate_dpp;

/*
 * Calculate instalment payments for specified account.
 */
procedure calculate_dpp(
    i_dpp_amount              in     com_api_type_pkg.t_money
  , i_fee_id                  in     com_api_type_pkg.t_short_id
  , i_first_instalment_date   in     date                                  default null
  , io_instalment_count       in out com_api_type_pkg.t_tiny_id
  , io_instalment_amount      in out com_api_type_pkg.t_money
  , io_calc_algorithm         in out com_api_type_pkg.t_dict_value
  , i_account_number          in     com_api_type_pkg.t_account_number
  , i_account_id              in     com_api_type_pkg.t_medium_id
  , i_inst_id                 in     com_api_type_pkg.t_inst_id            default null
  , o_interest_rate              out com_api_type_pkg.t_money
  , o_instalments                out sys_refcursor
) is
    l_account                        acc_api_type_pkg.t_account_rec;
    l_eff_date                       date;
    l_dpp_service_id                 com_api_type_pkg.t_short_id;
    l_fee_id                         com_api_type_pkg.t_short_id;
    l_params                         com_api_type_pkg.t_param_tab;
    l_product_id                     com_api_type_pkg.t_short_id;
    l_dpp                            dpp_api_type_pkg.t_dpp_program;
    l_instalments                    dpp_api_type_pkg.t_dpp_instalment_tab;
    l_instalments_tpt                dpp_instalment_tpt;
    l_first_cycle_id                 com_api_type_pkg.t_short_id;
    l_main_cycle_id                  com_api_type_pkg.t_short_id;
begin
    l_eff_date := com_api_sttl_day_pkg.get_sysdate();
    l_account :=
        acc_api_account_pkg.get_account(
            i_account_id     => i_account_id
          , i_account_number => i_account_number
          , i_inst_id        => i_inst_id
          , i_mask_error     => com_api_const_pkg.FALSE
        );

    if l_account.status in (acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
                          , acc_api_const_pkg.ACCOUNT_STATUS_DEBT_RESTRUCT)
    then
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_ACCOUNT_STATUS'
          , i_env_param1 => l_account.status
        );
    end if;

    l_dpp_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id       => l_account.account_id
          , i_attr_name       => null
          , i_service_type_id => dpp_api_const_pkg.DPP_SERVICE_TYPE_ID
          , i_split_hash      => l_account.split_hash
          , i_eff_date        => l_eff_date
          , i_last_active     => null
          , i_mask_error      => com_api_type_pkg.TRUE
          , i_inst_id         => i_inst_id
        );

    if l_dpp_service_id is null then
        com_api_error_pkg.raise_error(
            i_error        => 'DPP_SERVICE_NOT_FOUND'
          , i_env_param2   => l_account.account_id
        );
    end if;

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => l_account.account_id
          , i_eff_date    => l_eff_date
          , i_inst_id     => i_inst_id
        );

    l_fee_id := i_fee_id;
    if l_fee_id is null then
        l_fee_id :=
            prd_api_product_pkg.get_attr_value_number(
                i_product_id   => l_product_id
              , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => l_account.account_id
              , i_attr_name    => dpp_api_const_pkg.ATTR_FEE_ID
              , i_params       => l_params
              , i_service_id   => l_dpp_service_id
              , i_eff_date     => l_eff_date
              , i_split_hash   => l_account.split_hash
              , i_inst_id      => i_inst_id
            );
    end if;

    if i_first_instalment_date is null then
        l_first_cycle_id :=
            prd_api_product_pkg.get_attr_value_number(
                i_product_id   => l_product_id
              , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => l_account.account_id
              , i_attr_name    => dpp_api_const_pkg.ATTR_FIRST_CYCLE_ID
              , i_params       => l_params
              , i_service_id   => l_dpp_service_id
              , i_eff_date     => l_eff_date
              , i_split_hash   => l_account.split_hash
              , i_inst_id      => i_inst_id
            );
    end if;

    l_main_cycle_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id   => l_product_id
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => l_account.account_id
          , i_attr_name    => dpp_api_const_pkg.ATTR_MAIN_CYCLE_ID
          , i_params       => l_params
          , i_service_id   => l_dpp_service_id
          , i_eff_date     => l_eff_date
          , i_split_hash   => l_account.split_hash
          , i_inst_id      => i_inst_id
        );

    calculate_dpp(
        i_dpp_amount            => i_dpp_amount
      , i_fee_id                => l_fee_id
      , i_instalment_count      => io_instalment_count
      , i_instalment_amount     => io_instalment_amount
      , i_first_instalment_date => i_first_instalment_date
      , i_calc_algorithm        => io_calc_algorithm
      , i_inst_id               => i_inst_id
      , i_first_cycle_id        => l_first_cycle_id
      , i_main_cycle_id         => l_main_cycle_id
      , o_dpp                   => l_dpp
      , o_instalments           => l_instalments
    );

    io_instalment_count := l_instalments.count;
    o_interest_rate     := dpp_api_payment_plan_pkg.get_year_percent_in_fraction(i_fee_id => l_fee_id);

    io_instalment_amount := l_dpp.instalment_amount;
    l_instalments_tpt := new dpp_instalment_tpt();

    if l_instalments.count > 0 then
        for i in l_instalments.first .. l_instalments.last loop
            l_instalments_tpt.extend();

            l_instalments_tpt(l_instalments_tpt.last) :=
                new dpp_instalment_tpr(
                        l_instalments(i).id
                      , l_instalments(i).instalment_date
                      , l_instalments(i).amount
                      , l_instalments(i).interest
                      , l_instalments(i).repayment
                      , l_instalments(i).is_posted
                      , l_instalments(i).macros_id
                      , l_instalments(i).need_acceleration
                      , l_instalments(i).acceleration_type
                      , l_instalments(i).split_hash
                      , l_instalments(i).period_days_count
                      , l_instalments(i).fee_id
                      , l_instalments(i).acceleration_reason
                    );
        end loop;
    end if;

    open o_instalments for
    select row_number() over(order by i.instalment_date) as instalment_number
         , i.instalment_date
         , i.amount
         , i.interest
      from table(cast(l_instalments_tpt as dpp_instalment_tpt)) i
     order by
           i.instalment_date
    ;
end calculate_dpp;

end;
/
