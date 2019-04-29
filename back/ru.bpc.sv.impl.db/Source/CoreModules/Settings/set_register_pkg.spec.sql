create or replace package set_register_pkg as

type t_param_rec is record (
    name                        com_api_type_pkg.t_name
  , module_code                 com_api_type_pkg.t_module_code
  , lowest_level                com_api_type_pkg.t_dict_value
  , default_value               com_api_type_pkg.t_name
  , data_type                   com_api_type_pkg.t_dict_value
  , lov_id                      com_api_type_pkg.t_tiny_id
  , display_order               com_api_type_pkg.t_tiny_id
);
        
procedure register_parameter(
    i_parameter         in      t_param_rec
  , i_group_name        in      com_api_type_pkg.t_name             default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_short_desc        in      com_api_type_pkg.t_short_desc       default null
  , i_full_desc         in      com_api_type_pkg.t_full_desc        default null
);
    
procedure register_parameter(
    i_name              in      com_api_type_pkg.t_name
  , i_module_code       in      com_api_type_pkg.t_module_code
  , i_lowest_level      in      com_api_type_pkg.t_dict_value       default null
  , i_default_value     in      com_api_type_pkg.t_name             default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
  , i_lov_id            in      com_api_type_pkg.t_tiny_id          default null
  , i_group_name        in      com_api_type_pkg.t_name             default null
  , i_display_order     in      com_api_type_pkg.t_tiny_id          default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_short_desc        in      com_api_type_pkg.t_short_desc       default null
  , i_full_desc         in      com_api_type_pkg.t_full_desc        default null
);
    
procedure unregister_parameter(
    i_param_name        in      com_api_type_pkg.t_name
);
    
procedure register_param_desc(
    i_param_name        in      com_api_type_pkg.t_name
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc        default null
);
    
end;
/