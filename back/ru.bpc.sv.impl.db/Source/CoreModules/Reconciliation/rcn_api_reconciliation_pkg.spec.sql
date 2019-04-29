create or replace package rcn_api_reconciliation_pkg is

procedure process(
    i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_recon_type                in      com_api_type_pkg.t_dict_value   default rcn_api_const_pkg.RECON_TYPE_COMMON
);

procedure process_mark_expired (
    i_inst_id                   in      com_api_type_pkg.t_inst_id
);

procedure process_atm_mark_expired (
    i_inst_id                   in      com_api_type_pkg.t_inst_id
);

procedure process_host_mark_expired(
    i_register_event            in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
  , i_inst_id                   in      com_api_type_pkg.t_inst_id
);

procedure process_atm(
    i_inst_id                   in      com_api_type_pkg.t_inst_id      default ost_api_const_pkg.DEFAULT_INST
);

procedure process_host(
    i_inst_id                   in      com_api_type_pkg.t_inst_id      default ost_api_const_pkg.DEFAULT_INST
  , i_recon_type                in      com_api_type_pkg.t_dict_value
  , i_register_event            in      com_api_type_pkg.t_boolean
  , i_msg_source                in      com_api_type_pkg.t_dict_value   default rcn_api_const_pkg.RECON_MSG_SOURCE_HOST
);

procedure process_srvp(
    i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_service_provider_id       in      com_api_type_pkg.t_short_id      default null
  , i_purpose_id                in      com_api_type_pkg.t_short_id      default null
  , i_recon_type                in      com_api_type_pkg.t_dict_value    default rcn_api_const_pkg.RECON_TYPE_SRVP
);

procedure process_srvp_mark_expired(
    i_inst_id                   in      com_api_type_pkg.t_inst_id
);

end;
/
