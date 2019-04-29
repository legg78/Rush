create or replace package rcn_ui_reconciliation_pkg is

procedure add_condition(
    o_id                       out com_api_type_pkg.t_tiny_id
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_recon_type            in     com_api_type_pkg.t_dict_value
  , i_cond_type             in     com_api_type_pkg.t_dict_value
  , i_name                  in     com_api_type_pkg.t_name
  , i_condition             in     com_api_type_pkg.t_param_value
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_provider_id           in     com_api_type_pkg.t_short_id      default null
  , i_purpose_id            in     com_api_type_pkg.t_short_id      default null
);

procedure modify_condition(
    i_id                    in     com_api_type_pkg.t_tiny_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
  , i_recon_type            in     com_api_type_pkg.t_dict_value
  , i_cond_type             in     com_api_type_pkg.t_dict_value
  , i_name                  in     com_api_type_pkg.t_name
  , i_condition             in     com_api_type_pkg.t_param_value
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_provider_id           in     com_api_type_pkg.t_short_id      default null
  , i_purpose_id            in     com_api_type_pkg.t_short_id      default null
);

procedure remove_match_condition(
    i_id                    in     com_api_type_pkg.t_tiny_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
);

procedure modify_reconciliation(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_recon_status          in     com_api_type_pkg.t_dict_value
);

procedure modify_reconciliation_atm(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_recon_status          in     com_api_type_pkg.t_dict_value
);

procedure modify_reconciliation_host(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_recon_status          in     com_api_type_pkg.t_dict_value
);

procedure add_recon_parameter(
    o_id                       out com_api_type_pkg.t_long_id
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_provider_id           in     com_api_type_pkg.t_short_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_param_id              in     com_api_type_pkg.t_short_id
);

procedure modify_recon_parameter(
    i_id                    in     com_api_type_pkg.t_long_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_provider_id           in     com_api_type_pkg.t_short_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_param_id              in     com_api_type_pkg.t_short_id
);

procedure remove_recon_parameter(
    i_id                    in     com_api_type_pkg.t_short_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
);

procedure modify_msg_recon_status(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_recon_status          in     com_api_type_pkg.t_dict_value
);

procedure modify_message(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_recon_status          in     com_api_type_pkg.t_dict_value
  , i_module                in     com_api_type_pkg.t_attr_name
);

end;
/
