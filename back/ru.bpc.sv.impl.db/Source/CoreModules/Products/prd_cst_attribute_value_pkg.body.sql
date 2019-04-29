create or replace package body prd_cst_attribute_value_pkg is

function get_effective_date (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
) return date is
begin
    trc_log_pkg.debug(
        i_text          => 'prd_cst_attribute_value_pkg.get_effective_date dummy'
    );
    return null;
end;

function get_effective_date (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
) return date is
begin
    trc_log_pkg.debug(
        i_text          => 'prd_cst_attribute_value_pkg.get_effective_date dummy'
    );
    return null;
end;

function get_effective_date (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
) return date is
begin
    trc_log_pkg.debug(
        i_text          => 'prd_cst_attribute_value_pkg.get_effective_date dummy'
    );
    return null;
end;

function get_effective_date (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
) return date is
begin
    trc_log_pkg.debug(
        i_text          => 'prd_cst_attribute_value_pkg.get_effective_date dummy'
    );
    return null;
end;

end prd_cst_attribute_value_pkg;
/