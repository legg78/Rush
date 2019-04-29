create or replace package cmn_api_standard_pkg as

function get_current_version(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
) return com_api_type_pkg.t_tiny_id
result_cache;

function get_current_version(
    i_network_id   in      com_api_type_pkg.t_tiny_id default null
) return com_api_type_pkg.t_tiny_id
result_cache;

procedure get_param_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default null
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , o_param_value          out  varchar2
);

procedure get_param_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default null
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , o_param_value          out  date
);

procedure get_param_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default null
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , o_param_value          out  number
);

function get_varchar_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default null
  , i_param_tab         in      com_api_type_pkg.t_param_tab
) return varchar2;

function get_date_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default null
  , i_param_tab         in      com_api_type_pkg.t_param_tab
) return date;

function get_number_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default null
  , i_param_tab         in      com_api_type_pkg.t_param_tab
) return number;

procedure get_prd_attr_value_number(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_host_id           in      com_api_type_pkg.t_tiny_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id      default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default get_sysdate
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_use_default_value in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_default_value     in      number                          default null
  , o_param_value          out  number
);

function find_value_owner(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_value_char        in      com_api_type_pkg.t_name
  , i_mask_error        in      com_api_type_pkg.t_boolean      := com_api_type_pkg.FALSE
  , i_masked_level      in      com_api_type_pkg.t_tiny_id      := null
) return com_api_type_pkg.t_inst_id;

function find_value_owner(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_value_number      in      number
  , i_mask_error        in      com_api_type_pkg.t_boolean      := com_api_type_pkg.FALSE
  , i_masked_level      in      com_api_type_pkg.t_tiny_id      := null
) return com_api_type_pkg.t_inst_id;

function find_value_owner(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_value_date        in      date
  , i_mask_error        in      com_api_type_pkg.t_boolean      := com_api_type_pkg.FALSE
  , i_masked_level      in      com_api_type_pkg.t_tiny_id      := null
) return com_api_type_pkg.t_inst_id;

function verify_version (
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_version_number    in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean;                            -- 1 - version equal or higher; 0 - version less

end;
/
