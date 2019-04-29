create or replace package dpp_cst_payment_plan_pkg as
/*********************************************************
*  API for deffered payment plans (DPP) <br />
*  Created by  Y. Kolodkina(kolodkina@bpcbt.com)  at 18.10.2016 <br />
*  Module: dpp_cst_payment_plan_pkg <br />
*  @headcom
**********************************************************/

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
);

procedure dpp_amount_postprocess(
    i_account_id            in     com_api_type_pkg.t_account_id
  , i_macros_id             in     com_api_type_pkg.t_long_id
  , io_dpp_amount           in out com_api_type_pkg.t_money
  , io_dpp_currency         in out com_api_type_pkg.t_curr_code
);

procedure cancel_dpp_postprocess(
    i_dpp                   in     dpp_api_type_pkg.t_dpp
  , i_eff_date              in     date
);

procedure accelerate_dpp_postprocess(
    i_dpp                   in     dpp_api_type_pkg.t_dpp
  , i_eff_date              in     date
);

procedure get_dpp_credit_bunch_types(
    i_dpp                   in     dpp_api_type_pkg.t_dpp
  , o_credit_bunch_type_id     out com_api_type_pkg.t_tiny_id
  , o_intr_bunch_type_id       out com_api_type_pkg.t_tiny_id
  , o_over_bunch_type_id       out com_api_type_pkg.t_tiny_id
);

end;
/
