create or replace package body dpp_cst_payment_plan_pkg as
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
) is
begin
    null;
end;

procedure dpp_amount_postprocess(
    i_account_id            in     com_api_type_pkg.t_account_id
  , i_macros_id             in     com_api_type_pkg.t_long_id
  , io_dpp_amount           in out com_api_type_pkg.t_money
  , io_dpp_currency         in out com_api_type_pkg.t_curr_code
) is
    l_eff_date                     date;
    l_account                      acc_api_type_pkg.t_account_rec;
    l_service_id                   com_api_type_pkg.t_short_id;
    l_param_tab                    com_api_type_pkg.t_param_tab;
    l_product_id                   com_api_type_pkg.t_short_id;
begin

    l_account     := acc_api_account_pkg.get_account(
                         i_account_id  => i_account_id
                       , i_mask_error  => com_api_const_pkg.FALSE
                     );
    l_eff_date    := com_api_sttl_day_pkg.get_calc_date(
                         i_inst_id     => l_account.inst_id
                     );
    l_service_id  := crd_api_service_pkg.get_active_service(
                         i_account_id  => i_account_id
                       , i_eff_date    => l_eff_date
                       , i_split_hash  => l_account.split_hash
                       , i_mask_error  => com_api_const_pkg.TRUE
                     );

    io_dpp_amount := 0;

    if l_service_id is null then
        select sum(e.balance_impact * e.amount)
          into io_dpp_amount
          from acc_entry e
         where e.macros_id  = i_macros_id
           and e.account_id = i_account_id
           and e.split_hash = l_account.split_hash
           and e.status     = acc_api_const_pkg.ENTRY_STATUS_POSTED;
    else
        select sum(db.amount)
          into io_dpp_amount
          from crd_debt_balance db
         where db.split_hash = l_account.split_hash
           and db.debt_id    = i_macros_id
           and db.balance_type in (acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT, acc_api_const_pkg.BALANCE_TYPE_OVERDUE);
    end if;
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
