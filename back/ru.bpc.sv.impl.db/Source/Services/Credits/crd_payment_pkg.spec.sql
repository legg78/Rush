create or replace package crd_payment_pkg as

procedure apply_payment(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , o_remainder_amount     out  com_api_type_pkg.t_money
);

procedure apply_payment(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_oper_id           in      com_api_type_pkg.t_long_id
  , i_charge_interest   in      com_api_type_pkg.t_dict_value       default null
);

procedure apply_dpp_payment(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
);

procedure cancel_invoice(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_service_id        in      com_api_type_pkg.t_short_id
);

procedure apply_payments(
    i_account_id        in      com_api_type_pkg.t_medium_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
);

procedure cancel_payment(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , i_reversal_id       in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_reversal_amount   in      com_api_type_pkg.t_money
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
);

procedure enum_debt_order(
    o_cur_debts            out        sys_refcursor
  , i_account_id        in            com_api_type_pkg.t_account_id
  , i_split_hash        in            com_api_type_pkg.t_tiny_id
  , i_eff_date          in            date
  , i_product_id        in            com_api_type_pkg.t_long_id      default null
  , i_service_id        in            com_api_type_pkg.t_short_id     default null
  , i_inst_id           in            com_api_type_pkg.t_tiny_id      default null
  , i_original_oper_id  in            com_api_type_pkg.t_long_id      default null
);

function get_total_payment_amount(
    i_account_id        in            com_api_type_pkg.t_account_id
  , i_split_hash        in            com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money;

/*
 * Calculate total payments amount since date <i_since_date> and daily payments amount for date <i_payment_date>.
 */
procedure get_total_payments(
    i_account           in out nocopy acc_api_type_pkg.t_account_rec
  , i_since_date        in            date
  , i_payment_date      in            date
  , o_paid_amount          out        com_api_type_pkg.t_money
  , o_daily_paid_amount    out        com_api_type_pkg.t_money
);

end;
/
