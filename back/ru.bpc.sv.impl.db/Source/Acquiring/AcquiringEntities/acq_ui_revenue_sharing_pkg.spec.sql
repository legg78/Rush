create or replace package acq_ui_revenue_sharing_pkg as

procedure add_revenue_sharing(
    o_revenue_sharing_id           out  com_api_type_pkg.t_medium_id
  , o_seqnum                       out  com_api_type_pkg.t_seqnum
  , i_terminal_id               in      com_api_type_pkg.t_short_id
  , i_customer_id               in      com_api_type_pkg.t_medium_id
  , i_account_id                in      com_api_type_pkg.t_account_id
  , i_provider_id               in      com_api_type_pkg.t_short_id
  , i_inst_id                   in      com_api_type_pkg.t_inst_id  default null
  , i_mod_id                    in      com_api_type_pkg.t_tiny_id
  , i_purpose_id                in      com_api_type_pkg.t_short_id
  , i_service_id                in      com_api_type_pkg.t_short_id
  , i_fee_type                  in      com_api_type_pkg.t_dict_value
  , i_fee_id                    in      com_api_type_pkg.t_short_id
);

procedure modify_revenue_sharing(
    i_revenue_sharing_id        in      com_api_type_pkg.t_medium_id
  , io_seqnum                   in out  com_api_type_pkg.t_seqnum
  , i_terminal_id               in      com_api_type_pkg.t_short_id
  , i_customer_id               in      com_api_type_pkg.t_medium_id
  , i_account_id                in      com_api_type_pkg.t_account_id
  , i_provider_id               in      com_api_type_pkg.t_short_id
  , i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_mod_id                    in      com_api_type_pkg.t_tiny_id
  , i_purpose_id                in      com_api_type_pkg.t_short_id
  , i_service_id                in      com_api_type_pkg.t_short_id
  , i_fee_type                  in      com_api_type_pkg.t_dict_value
  , i_fee_id                    in      com_api_type_pkg.t_short_id
);

procedure modify_revenue_sharing(
    i_revenue_sharing_id        in      com_api_type_pkg.t_medium_id
  , io_seqnum                   in out  com_api_type_pkg.t_seqnum
  , i_fee_type                  in      com_api_type_pkg.t_dict_value
  , i_fee_id                    in      com_api_type_pkg.t_short_id
);

procedure remove_revenue_sharing(
    i_revenue_sharing_id        in      com_api_type_pkg.t_medium_id
  , i_seqnum                    in      com_api_type_pkg.t_seqnum
);

end;
/
