create or replace package dsp_ui_list_condition_pkg as

procedure add_condition(
    o_id              out    com_api_type_pkg.t_tiny_id
  , i_init_rule       in     com_api_type_pkg.t_agent_id
  , i_gen_rule        in     com_api_type_pkg.t_agent_id
  , i_func_order      in     com_api_type_pkg.t_agent_id
  , i_mod_id          in     com_api_type_pkg.t_tiny_id
  , i_is_online       in     com_api_type_pkg.t_boolean
  , i_name            in     com_api_type_pkg.t_name
  , i_lang            in     com_api_type_pkg.t_dict_value
);

procedure modify_condition(
    i_id              in     com_api_type_pkg.t_tiny_id
  , i_init_rule       in     com_api_type_pkg.t_agent_id
  , i_gen_rule        in     com_api_type_pkg.t_agent_id
  , i_func_order      in     com_api_type_pkg.t_agent_id
  , i_mod_id          in     com_api_type_pkg.t_tiny_id
  , i_is_online       in     com_api_type_pkg.t_boolean
  , i_name            in     com_api_type_pkg.t_name
  , i_lang            in     com_api_type_pkg.t_dict_value
);

procedure remove_condition(
    i_id      in     com_api_type_pkg.t_tiny_id
);

end dsp_ui_list_condition_pkg;
/
