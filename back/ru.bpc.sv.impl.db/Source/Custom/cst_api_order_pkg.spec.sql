create or replace package cst_api_order_pkg as

procedure calc_order_amount(
    i_amount_algorithm      in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_eff_date              in      date
  , i_template_id           in      com_api_type_pkg.t_long_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , io_amount               in out  com_api_type_pkg.t_amount_rec
);

function check_min_max_amount(
    i_amount             in     com_api_type_pkg.t_money
  , i_currency           in     com_api_type_pkg.t_curr_code
  , i_purpose_id         in     com_api_type_pkg.t_short_id
  , i_payment_host_id    in     com_api_type_pkg.t_tiny_id
  , o_attr_present          out com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_boolean;

end;
/
