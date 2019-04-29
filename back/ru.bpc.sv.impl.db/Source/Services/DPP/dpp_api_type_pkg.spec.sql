create or replace package dpp_api_type_pkg is
/*********************************************************
 *  API of types for DPP module   <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 07.09.2011 <br />
 *  Module: DPP_API_TYPE_PKG <br />
 *  @headcom
 **********************************************************/

type t_dpp_program is record (
    instalment_count             com_api_type_pkg.t_tiny_id
  , instalment_amount            com_api_type_pkg.t_money
  , main_cycle_id                com_api_type_pkg.t_short_id
  , first_cycle_id               com_api_type_pkg.t_short_id
  , fee_id                       com_api_type_pkg.t_short_id
  , calc_algorithm               com_api_type_pkg.t_dict_value
  , fixed_instalment             com_api_type_pkg.t_tiny_id
  , fixed_amount                 com_api_type_pkg.t_money
  , accel_fee_id                 com_api_type_pkg.t_short_id
  , min_early_repayment          com_api_type_pkg.t_short_id
  , cancel_fee_id                com_api_type_pkg.t_short_id
  , dpp_limit                    com_api_type_pkg.t_short_id
  , oper_date                    date
  , oper_amount                  com_api_type_pkg.t_money
  , oper_currency                com_api_type_pkg.t_curr_code
  , account_id                   com_api_type_pkg.t_medium_id
  , macros_type_id               com_api_type_pkg.t_tiny_id
  , macros_intr_type_id          com_api_type_pkg.t_tiny_id
  , repay_macros_type_id         com_api_type_pkg.t_tiny_id
  , inst_id                      com_api_type_pkg.t_inst_id
  , split_hash                   com_api_type_pkg.t_tiny_id
  , dpp_amount                   com_api_type_pkg.t_money
  , dpp_currency                 com_api_type_pkg.t_curr_code
  , card_id                      com_api_type_pkg.t_medium_id
  , percent_rate                 com_api_type_pkg.t_money
  , status                       com_api_type_pkg.t_dict_value
  , dpp_id                       com_api_type_pkg.t_long_id
  , oper_id                      com_api_type_pkg.t_long_id
  , reg_oper_id                  com_api_type_pkg.t_long_id
  , posting_date                 date
  , product_id                   com_api_type_pkg.t_short_id
  , oper_type                    com_api_type_pkg.t_dict_value
  , cancel_m_type_id             com_api_type_pkg.t_tiny_id
  , cancel_m_intr_type_id        com_api_type_pkg.t_tiny_id
  , acceleration_reason          com_api_type_pkg.t_dict_value
  , rate_algorithm               com_api_type_pkg.t_dict_value
  , credit_macros_type           com_api_type_pkg.t_tiny_id
  , credit_macros_intr_type      com_api_type_pkg.t_tiny_id
  , credit_repay_macros_type     com_api_type_pkg.t_tiny_id
  , cancel_credit_m_type         com_api_type_pkg.t_tiny_id
  , cancel_intr_credit_m_type    com_api_type_pkg.t_tiny_id
  , instalment_wo_interest       com_api_type_pkg.t_money
  , acceleration_type            com_api_type_pkg.t_dict_value
);

type t_dpp_instalment is record (
    id                           com_api_type_pkg.t_long_id
  , instalment_date              date
  , amount                       com_api_type_pkg.t_money
  , interest                     com_api_type_pkg.t_money
  , repayment                    com_api_type_pkg.t_money
  , is_posted                    com_api_type_pkg.t_boolean
  , macros_id                    com_api_type_pkg.t_long_id
  , need_acceleration            com_api_type_pkg.t_boolean
  , acceleration_type            com_api_type_pkg.t_dict_value
  , split_hash                   com_api_type_pkg.t_tiny_id
  , period_days_count            com_api_type_pkg.t_tiny_id
  , fee_id                       com_api_type_pkg.t_short_id
  , acceleration_reason          com_api_type_pkg.t_dict_value
  , period_percent_rate          com_api_type_pkg.t_money
);

type t_dpp_instalment_tab is table of t_dpp_instalment index by binary_integer;

type t_dpp is record (
    id                       com_api_type_pkg.t_long_id
  , oper_id                  com_api_type_pkg.t_long_id
  , account_id               com_api_type_pkg.t_medium_id
  , card_id                  com_api_type_pkg.t_medium_id
  , product_id               com_api_type_pkg.t_short_id
  , oper_date                date
  , oper_amount              com_api_type_pkg.t_money
  , oper_currency            com_api_type_pkg.t_curr_code
  , dpp_amount               com_api_type_pkg.t_money
  , dpp_currency             com_api_type_pkg.t_curr_code
  , interest_amount          com_api_type_pkg.t_money
  , status                   com_api_type_pkg.t_dict_value
  , instalment_amount        com_api_type_pkg.t_money
  , instalment_total         com_api_type_pkg.t_tiny_id
  , instalment_billed        com_api_type_pkg.t_tiny_id
  , next_instalment_date     date
  , debt_balance             com_api_type_pkg.t_money
  , inst_id                  com_api_type_pkg.t_inst_id
  , split_hash               com_api_type_pkg.t_tiny_id
  , reg_oper_id              com_api_type_pkg.t_long_id
  , posting_date             date
  , oper_type                com_api_type_pkg.t_dict_value
  , dpp_algorithm            com_api_type_pkg.t_dict_value
);

type t_dpp_tab is table of t_dpp index by binary_integer;

end;
/
