create or replace package itf_prc_acquiring_pkg is

procedure process_merchant(
    i_inst_id                    in     com_api_type_pkg.t_inst_id
  , i_agent_id                   in     com_api_type_pkg.t_agent_id     default null
  , i_full_export                in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits              in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts            in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service            in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count                      in     com_api_type_pkg.t_medium_id    default null
  , i_lang                       in     com_api_type_pkg.t_dict_value   default null
  , i_replace_inst_id_by_number  in     com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
);

procedure process_terminal(
    i_inst_id                    in     com_api_type_pkg.t_inst_id
  , i_agent_id                   in     com_api_type_pkg.t_agent_id     default null
  , i_full_export                in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits              in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service            in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count                      in     com_api_type_pkg.t_medium_id    default null
  , i_lang                       in     com_api_type_pkg.t_dict_value   default null
  , i_replace_inst_id_by_number  in     com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
);

end;
/
