create or replace package crd_utl_pkg as

procedure generate_irr_payments(
    i_account_id            in     com_api_type_pkg.t_account_id
  , i_invoice_id            in     com_api_type_pkg.t_medium_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_product_id            in     com_api_type_pkg.t_short_id
  , i_service_id            in     com_api_type_pkg.t_short_id
  , i_eff_date              in     date                            default null
  , i_split_hash            in     com_api_type_pkg.t_tiny_id      default null
  , i_mandatory_amount_due  in     com_api_type_pkg.t_money
  , i_interest_amount       in     com_api_type_pkg.t_money
  , i_total_amount_due      in     com_api_type_pkg.t_money
  , o_payment_tab              out com_api_type_pkg.t_money_tab
);

function calculate_irr(
    i_account_id            in     com_api_type_pkg.t_account_id
  , i_invoice_id            in     com_api_type_pkg.t_medium_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_product_id            in     com_api_type_pkg.t_short_id
  , i_service_id            in     com_api_type_pkg.t_short_id
  , i_eff_date              in     date                            default null
  , i_split_hash            in     com_api_type_pkg.t_tiny_id      default null
  , i_mandatory_amount_due  in     com_api_type_pkg.t_money
  , i_interest_amount       in     com_api_type_pkg.t_money
  , i_total_amount_due      in     com_api_type_pkg.t_money
) return com_api_type_pkg.t_money;

function calculate_apr(
    i_irr                   in     com_api_type_pkg.t_money
) return com_api_type_pkg.t_money;

function get_credit_accounts(
    i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_split_hash            in     com_api_type_pkg.t_tiny_id
  , i_eff_date              in     date                             default null
  , i_excluded_account_id   in     com_api_type_pkg.t_account_id    default null
) return acc_api_type_pkg.t_account_tab;

procedure get_mad_payment_data(
    i_invoice_id            in     com_api_type_pkg.t_long_id
  , o_mad_payment_date         out date
  , o_mad_payment_sum          out com_api_type_pkg.t_money
);

end;
/
