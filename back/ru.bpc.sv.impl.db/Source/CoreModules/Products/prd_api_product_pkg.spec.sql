create or replace package prd_api_product_pkg is
/*************************************************************
*  API for products <br />
*  Created by Kopachev D (kopachev@bpcbt.com)  at 25.11.2010 <br />
*  Module: PRD_API_PRODUCT_PKG  <br />
*  @headcom
**************************************************************/

type t_attribute_rec is record (
    attr_id                     com_api_type_pkg.t_short_id
  , data_type                   com_api_type_pkg.t_dict_value
  , entity_type                 com_api_type_pkg.t_dict_value
  , definition_level            com_api_type_pkg.t_dict_value
);

function get_attr_value_number (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_use_default_value in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_default_value     in      number                          default null
) return number;

function get_attr_value_date (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_use_default_value in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_default_value     in      date                            default null
) return date;

function get_attr_value_char (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_use_default_value in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_default_value     in      com_api_type_pkg.t_text         default null
) return varchar2;

procedure get_fees_mods(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , o_fees                 out  com_api_type_pkg.t_varchar2_tab
  , o_mods                 out  com_api_type_pkg.t_number_tab
);

function get_fee_id (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_short_id;

function get_fee_id(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_fee               in      fcl_api_type_pkg.t_fee
  , i_fee_tier          in      fcl_api_type_pkg.t_fee_tier_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_short_id;

procedure get_fee_id (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_fee_id               out  com_api_type_pkg.t_short_id
  , o_start_date           out  date
  , o_end_date             out  date
);

function get_cycle_id (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_short_id;

function get_limit_id (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id;

function get_limit_id (
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id;

function get_product_id(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date                            default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
) return com_api_type_pkg.t_short_id;

function get_product_type(
    i_product_id        in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_dict_value;

/**************************************************
 * @return product's number is generated by the custom name format
 ***************************************************/
function generate_product_number(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_eff_date          in      date                            default com_api_sttl_day_pkg.get_sysdate()
) return com_api_type_pkg.t_name;

/**************************************************
 * @return product's ID by the product's number and institute's ID
 ***************************************************/
function get_product_id(
    i_product_number    in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id;

function get_product_number(
    i_product_id        in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_name;

function get_product_contract_type(
    i_product_id        in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_dict_value;

function get_attr_value_number(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_product_id        in      com_api_type_pkg.t_short_id     default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_use_default_value in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_default_value     in      number                          default null
) return number;

function get_attr_value_char(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_use_default_value in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_default_value     in      com_api_type_pkg.t_text         default null
) return varchar2;

procedure get_fee_amount(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_base_amount       in      com_api_type_pkg.t_money
  , i_base_count        in      com_api_type_pkg.t_long_id      default 1
  , i_base_currency     in      com_api_type_pkg.t_curr_code
  , io_fee_currency     in out  com_api_type_pkg.t_curr_code
  , o_fee_amount           out  com_api_type_pkg.t_money
  , i_calc_period       in      com_api_type_pkg.t_tiny_id      default null
  , i_fee_included      in      com_api_type_pkg.t_boolean      default null
  , i_start_date        in      date                            default null
  , i_end_date          in      date                            default null
  , i_tier_amount       in      com_api_type_pkg.t_money        default null
  , i_tier_count        in      com_api_type_pkg.t_long_id      default null
  , i_oper_date         in      date                            default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
);

end prd_api_product_pkg;
/
