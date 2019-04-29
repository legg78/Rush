create or replace package acq_api_revenue_sharing_pkg is

procedure get_fee_id (
    i_customer_id               in  com_api_type_pkg.t_medium_id    default null
    , i_provider_id             in  com_api_type_pkg.t_short_id     default null
    , i_terminal_id             in  com_api_type_pkg.t_short_id     default null
    , i_account_id              in  com_api_type_pkg.t_medium_id    default null
    , i_service_id              in  com_api_type_pkg.t_short_id     default null
    , i_purpose_id              in  com_api_type_pkg.t_short_id     default null
    , i_fee_type                in  com_api_type_pkg.t_dict_value   default null
    , i_inst_id                 in  com_api_type_pkg.t_inst_id      default null
    , i_params                  in  com_api_type_pkg.t_param_tab
    , i_raise_error             in  com_api_type_pkg.t_boolean      := com_api_const_pkg.TRUE
    , o_fee_id                  out com_api_type_pkg.t_medium_id
    , i_eff_date                in  date                            default null
);

end;
/
