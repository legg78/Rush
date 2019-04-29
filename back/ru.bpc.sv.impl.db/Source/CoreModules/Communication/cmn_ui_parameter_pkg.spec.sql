CREATE OR REPLACE package cmn_ui_parameter_pkg as

procedure add_parameter(
    o_param_id              out com_api_type_pkg.t_short_id
  , i_standard              in com_api_type_pkg.t_tiny_id
  , i_param_name            in com_api_type_pkg.t_name
  , i_entity_type           in com_api_type_pkg.t_dict_value
  , i_data_type             in com_api_type_pkg.t_dict_value
  , i_lov_id                in com_api_type_pkg.t_tiny_id
  , i_default_value_char    in com_api_type_pkg.t_name
  , i_default_value_num     in com_api_type_pkg.t_rate
  , i_default_value_date    in date
  , i_scale_id              in com_api_type_pkg.t_tiny_id
  , i_caption               in com_api_type_pkg.t_name
  , i_description           in com_api_type_pkg.t_full_desc        default null
  , i_lang                  in com_api_type_pkg.t_dict_value       default null
  , i_pattern               in com_api_type_pkg.t_short_desc
  , i_pattern_desc          in com_api_type_pkg.t_full_desc        default null
);

procedure modify_parameter(
    i_param_id              in com_api_type_pkg.t_short_id
  , i_entity_type           in com_api_type_pkg.t_dict_value
  , i_data_type             in com_api_type_pkg.t_dict_value
  , i_lov_id                in com_api_type_pkg.t_tiny_id
  , i_default_value_char    in com_api_type_pkg.t_name
  , i_default_value_num     in com_api_type_pkg.t_rate
  , i_default_value_date    in date
  , i_scale_id              in com_api_type_pkg.t_tiny_id
  , i_caption               in com_api_type_pkg.t_name
  , i_description           in com_api_type_pkg.t_full_desc        default null
  , i_lang                  in com_api_type_pkg.t_dict_value       default null
  , i_pattern               in com_api_type_pkg.t_short_desc
  , i_pattern_desc          in com_api_type_pkg.t_full_desc        default null 
);

procedure remove_parameter(
    i_param_id              in      com_api_type_pkg.t_short_id
);

end;
/
