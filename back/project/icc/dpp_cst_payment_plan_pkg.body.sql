create or replace package body dpp_cst_payment_plan_pkg as
/*********************************************************
*  API for deffered payment plans (DPP) <br />
*  Created by  Y. Kolodkina(kolodkina@bpcbt.com)  at 18.10.2016 <br />
*  Module: dpp_cst_payment_plan_pkg <br />
*  @headcom
**********************************************************/

ACCOUNT_CREDIT_LIMIT            constant com_api_type_pkg.t_dict_value := 'LMTP5101';
INTEREST_TO_CHECK_MAD           constant com_api_type_pkg.t_dict_value := 'FETP5005';
INTEREST_TO_CHECK_DPP_AMOUNT    constant com_api_type_pkg.t_dict_value := 'FETP5007';
MIN_AMOUNT_MONTHLY_INSTALMENT   constant com_api_type_pkg.t_dict_value := 'FETP5006';

procedure check_dpp_before_register(
    i_account_id            in     com_api_type_pkg.t_account_id
  , i_dpp_algorithm         in     com_api_type_pkg.t_dict_value
  , i_instalment_count      in     com_api_type_pkg.t_tiny_id
  , i_instalment_amount     in     com_api_type_pkg.t_money
  , i_fee_id                in     com_api_type_pkg.t_money
  , i_dpp_amount            in     com_api_type_pkg.t_money
  , i_dpp_currency          in     com_api_type_pkg.t_curr_code
  , i_macros_id             in     com_api_type_pkg.t_long_id
  , i_oper_id               in     com_api_type_pkg.t_long_id
  , i_param_tab             in     com_api_type_pkg.t_param_tab
  , i_service_id            in     com_api_type_pkg.t_short_id
  , i_product_id            in     com_api_type_pkg.t_short_id
  , i_split_hash            in     com_api_type_pkg.t_tiny_id
  , i_account_type          in     com_api_type_pkg.t_dict_value
  , i_card_id               in     com_api_type_pkg.t_medium_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_oper_amount           in     com_api_type_pkg.t_money
  , i_oper_currency         in     com_api_type_pkg.t_curr_code
  , i_eff_date              in     date
) is
    l_invoice_id        com_api_type_pkg.t_medium_id;
    l_min_amount_due    com_api_type_pkg.t_money := 0;
    l_instalments_mad   com_api_type_pkg.t_money := 0;
    l_credit_limit      com_api_type_pkg.t_money := 0;
    l_credit_limit_curr com_api_type_pkg.t_curr_code;
    l_fee_id            com_api_type_pkg.t_long_id;
    l_fee_amount        com_api_type_pkg.t_money := 0;
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_credit_service_id com_api_type_pkg.t_short_id;
    l_oper_currency     com_api_type_pkg.t_curr_code;
begin
    trc_log_pkg.debug('dpp_cst_payment_plan_pkg.check_dpp_before_register Start');

    l_param_tab     := i_param_tab;
    l_oper_currency := i_oper_currency;

    -- 1. MAD (MAD of credit service + MAD of instalment) < 20% of the account credit limit (value of % defined in the product)
    l_invoice_id :=
        crd_invoice_pkg.get_last_invoice_id(
            i_account_id   => i_account_id
          , i_split_hash   => i_split_hash
          , i_mask_error   => com_api_const_pkg.TRUE
        );

    if l_invoice_id is not null then
        select min_amount_due
          into l_min_amount_due
          from crd_invoice
         where id = l_invoice_id;
    end if;
    trc_log_pkg.debug('[crd_invoice] l_min_amount_due [' || l_min_amount_due || ']');

    -- DPP instalments MAD.
    -- Sum of all DPP instalment payments by the account that should be paid on their next payment periods
    select nvl(sum(instl_amount), 0)
      into l_instalments_mad
      from (
          select i.dpp_id
               , min(i.instalment_amount)
                     keep (dense_rank first order by i.instalment_number, i.id)
                 as instl_amount -- next instalment payment amount that should be paid
            from dpp_payment_plan p
               , dpp_instalment   i
           where i.dpp_id     = p.id
             and p.account_id = i_account_id
             and p.status     = dpp_api_const_pkg.DPP_OPERATION_ACTIVE
             and i.macros_id is null
        group by i.dpp_id
      );
    trc_log_pkg.debug('l_instalments_mad [' || l_instalments_mad || ']');

    l_min_amount_due := l_min_amount_due + l_instalments_mad;

    trc_log_pkg.debug('l_min_amount_due [' || l_min_amount_due || ']');

    -- account credit limit
    fcl_api_limit_pkg.switch_limit_counter(
        i_limit_type        => ACCOUNT_CREDIT_LIMIT
      , i_product_id        => i_product_id
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_params            => l_param_tab
      , i_sum_value         => 0
      , i_currency          => null
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_inst_id           => i_inst_id
      , i_switch_limit      => com_api_const_pkg.NONE
      , o_sum_value         => l_credit_limit
      , o_currency          => l_credit_limit_curr
      , i_service_id        => i_service_id
    );

    -- value of % defined in the product
    l_fee_id :=
        prd_api_product_pkg.get_fee_id (
            i_product_id    => i_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_fee_type      => INTEREST_TO_CHECK_MAD
          , i_params        => l_param_tab
          , i_service_id    => i_service_id
          , i_eff_date      => i_eff_date
          , i_split_hash    => i_split_hash
          , i_inst_id       => i_inst_id
        );

    l_fee_amount :=
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_fee_id
          , i_base_amount       => l_credit_limit
          , io_base_currency    => l_oper_currency
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
        );
    trc_log_pkg.debug('l_fee_amount [' ||l_fee_amount || ']');

    trc_log_pkg.debug('Check 1: l_min_amount_due ['||l_min_amount_due||'], l_fee_amount['||l_fee_amount||']');

    if l_min_amount_due >= l_fee_amount then
        com_api_error_pkg.raise_error(
            i_error      => 'CST_ICC_MAD_MORE_THAT_CREDIT_LIMIT'
          , i_env_param1 => l_min_amount_due
          , i_env_param2 => l_fee_amount
          , i_env_param3 => INTEREST_TO_CHECK_MAD
        );
    end if;

    -- 2. Total instalment amount (principal + calculated interest +applied fee) <= 50% of the account credit limit (value of % defined in the product)
    -- value of % defined in the product
    l_fee_id :=
        prd_api_product_pkg.get_fee_id (
            i_product_id    => i_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_fee_type      => INTEREST_TO_CHECK_DPP_AMOUNT
          , i_params        => l_param_tab
          , i_service_id    => i_service_id
          , i_eff_date      => i_eff_date
          , i_split_hash    => i_split_hash
          , i_inst_id       => i_inst_id
        );

    l_fee_amount :=
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_fee_id
          , i_base_amount       => l_credit_limit
          , io_base_currency    => l_oper_currency
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
        );

    trc_log_pkg.debug('Check 2: i_dpp_amount [' || i_dpp_amount || '], l_fee_amount[' || l_fee_amount || ']');
    if i_dpp_amount > l_fee_amount then

        com_api_error_pkg.raise_error(
            i_error      => 'CST_ICC_DPP_AMOUNT_MORE_THAT_CREDIT_LIMIT'
          , i_env_param1 => i_dpp_amount
          , i_env_param2 => l_fee_amount
          , i_env_param3 => INTEREST_TO_CHECK_DPP_AMOUNT
        );
    end if;

    -- 3. Amount of operation (or TAD of ICC or non-ICC credit card) has to be higher than minimum value, defined in the product
    l_credit_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => i_split_hash
          , i_eff_date          => i_eff_date
          , i_inst_id           => i_inst_id
        );

    l_fee_id :=
        prd_api_product_pkg.get_fee_id (
            i_product_id    => i_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_fee_type      => crd_api_const_pkg.MINIMUM_MAD_FEE_TYPE
          , i_params        => l_param_tab
          , i_service_id    => l_credit_service_id
          , i_eff_date      => i_eff_date
          , i_split_hash    => i_split_hash
          , i_inst_id       => i_inst_id
        );

    l_fee_amount :=
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_fee_id
          , i_base_amount       => 0
          , io_base_currency    => l_oper_currency
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
        );

    trc_log_pkg.debug('Check 3: i_oper_amount ['||i_oper_amount||'], l_fee_amount['||l_fee_amount||']');

    if i_oper_amount < l_fee_amount then
        com_api_error_pkg.raise_error(
            i_error      => 'CST_ICC_MIN_MAD_LESS_MAD'
          , i_env_param1 => i_oper_amount
          , i_env_param2 => l_fee_amount
          , i_env_param3 => crd_api_const_pkg.MINIMUM_MAD_FEE_TYPE
        );
    end if;

    -- 4. Amount of monthly instalment has to be higher than minimum value, defined in the product
    l_fee_id :=
        prd_api_product_pkg.get_fee_id (
            i_product_id    => i_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_fee_type      => MIN_AMOUNT_MONTHLY_INSTALMENT
          , i_params        => l_param_tab
          , i_service_id    => i_service_id
          , i_eff_date      => i_eff_date
          , i_split_hash    => i_split_hash
          , i_inst_id       => i_inst_id
        );

    l_fee_amount :=
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_fee_id
          , i_base_amount       => 0
          , io_base_currency    => l_oper_currency
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
        );

    trc_log_pkg.debug('Check 4: i_instalment_amount ['||i_instalment_amount||'], l_fee_amount['||l_fee_amount||']');

    if nvl(i_instalment_amount, 0) < l_fee_amount then
        com_api_error_pkg.raise_error(
            i_error      => 'CST_ICC_INSTALMENT_AMOUNT_LESS_MIN_VALUE'
          , i_env_param1 => i_instalment_amount
          , i_env_param2 => l_fee_amount
          , i_env_param3 => MIN_AMOUNT_MONTHLY_INSTALMENT
        );
    end if;

    trc_log_pkg.debug('dpp_cst_payment_plan_pkg.check_dpp_before_register End');
end check_dpp_before_register;

procedure dpp_amount_postprocess(
    i_account_id            in     com_api_type_pkg.t_account_id
  , i_macros_id             in     com_api_type_pkg.t_long_id
  , io_dpp_amount           in out com_api_type_pkg.t_money
  , io_dpp_currency         in out com_api_type_pkg.t_curr_code
) is
begin
    null;
end;

procedure cancel_dpp_postprocess(
    i_dpp                   in     dpp_api_type_pkg.t_dpp
  , i_eff_date              in     date
) is
begin
    null;
end;

procedure accelerate_dpp_postprocess(
    i_dpp                   in     dpp_api_type_pkg.t_dpp
  , i_eff_date              in     date
) is
begin
    null;
end;

procedure get_dpp_credit_bunch_types(
    i_dpp                   in     dpp_api_type_pkg.t_dpp
  , o_credit_bunch_type_id     out com_api_type_pkg.t_tiny_id
  , o_intr_bunch_type_id       out com_api_type_pkg.t_tiny_id
  , o_over_bunch_type_id       out com_api_type_pkg.t_tiny_id
) is
begin
    o_credit_bunch_type_id := 1021;
    o_intr_bunch_type_id   := o_credit_bunch_type_id;
    o_over_bunch_type_id   := 1022;
end;

end;
/
