create or replace package rcn_prc_import_pkg as

procedure process_cbs_batch(
    i_oper_tab          in      rcn_recon_msg_tpt
  , i_param_tab         in      com_param_map_tpt
);

procedure process_atm_batch(
    i_oper_tab          in      rcn_atm_recon_msg_tpt
  , i_param_tab         in      com_param_map_tpt
);

procedure process_host_batch(
    i_oper_tab          in      rcn_host_recon_msg_tpt
  , i_param_tab         in      com_param_map_tpt
);

procedure posting_not_recon_host_oper(
    i_recon_event_type  in      com_api_type_pkg.t_dict_value
  , i_oper_status       in      com_api_type_pkg.t_dict_value
);

procedure process_srvp_batch(
    i_order_tab         in      rcn_srvp_msg_tpt
  , i_param_tab         in      com_param_map_tpt
);

end;
/
