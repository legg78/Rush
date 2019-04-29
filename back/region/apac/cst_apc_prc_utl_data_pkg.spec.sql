create or replace package cst_apc_prc_utl_data_pkg as

procedure export_product (
    i_product_id            in     com_api_type_pkg.t_short_id
  , i_cst_update_mode       in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
);

procedure export_network (
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_cst_update_mode       in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
);

procedure export_settlement_mapping (
    i_cst_update_mode       in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_cst_delete_others     in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
);

procedure export_rule_set (
    i_cst_rule_set_id       in     com_api_type_pkg.t_tiny_id
  , i_cst_update_mode       in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
);

procedure export_event (
    i_event_type            in     com_api_type_pkg.t_dict_value
  , i_cst_update_mode       in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
);

procedure export_notifications (
    i_cst_ntf_scheme_id     in     com_api_type_pkg.t_tiny_id
  , i_cst_update_mode       in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
);

procedure export_macros_bunch_type (
    i_cst_macros_type_id    in     com_api_type_pkg.t_tiny_id
  , i_cst_update_mode       in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
);

procedure export_operation_template (
    i_cst_oper_template_id  in     com_api_type_pkg.t_short_id
  , i_cst_update_mode       in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
);

end cst_apc_prc_utl_data_pkg;
/
