create or replace package lty_api_bonus_pkg as
/*********************************************************
 *  API for loyalty bonus <br />
 *  Created by Kopachev D.(kopachev@bpc.ru)  at 18.11.2009 <br />
 *  Module: lty_api_bonus_pkg <br />
 *  @headcom
 **********************************************************/

function get_service_type_id(
    i_entity_type      in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_short_id;

function get_fee_type(
    i_entity_type      in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value;

function get_start_cycle_type(
    i_entity_type      in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value;

function get_expire_cycle_type(
    i_entity_type      in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value;

function decode_attr_name(
    i_attr_name        in     com_api_type_pkg.t_name
  , i_entity_type      in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name;

procedure create_bonus (
    i_entity_type      in     com_api_type_pkg.t_dict_value
  , i_object_id        in     com_api_type_pkg.t_long_id
  , i_oper_entity_type in     com_api_type_pkg.t_dict_value
  , i_oper_id          in     com_api_type_pkg.t_long_id
  , i_oper_date        in     date
  , i_oper_amount      in     com_api_type_pkg.t_money
  , i_oper_currency    in     com_api_type_pkg.t_curr_code
  , i_macros_type      in     com_api_type_pkg.t_long_id
  , i_split_hash       in     com_api_type_pkg.t_tiny_id
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_rate_type        in     com_api_type_pkg.t_dict_value
  , i_conversion_type  in     com_api_type_pkg.t_dict_value    default null
  , i_fee_type         in     com_api_type_pkg.t_dict_value    default null
  , i_param_tab        in     com_api_type_pkg.t_param_tab
  , i_test_mode        in     com_api_type_pkg.t_dict_value    default null
  , o_result_amount       out com_api_type_pkg.t_amount_rec
  , o_result_account      out acc_api_type_pkg.t_account_rec
  , o_start_date          out date
  , o_expire_date         out date
);

procedure spend_bonus (
    i_entity_type      in     com_api_type_pkg.t_dict_value
  , i_object_id        in     com_api_type_pkg.t_long_id
  , i_oper_date        in     date
  , i_oper_amount      in     com_api_type_pkg.t_money
  , i_oper_currency    in     com_api_type_pkg.t_curr_code
  , i_split_hash       in     com_api_type_pkg.t_tiny_id
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_oper_id          in     com_api_type_pkg.t_long_id
  , i_original_id      in     com_api_type_pkg.t_long_id       default null
  , i_macros_type      in     com_api_type_pkg.t_long_id
  , i_rate_type        in     com_api_type_pkg.t_dict_value
  , i_conversion_type  in     com_api_type_pkg.t_dict_value    default null
  , i_param_tab        in     com_api_type_pkg.t_param_tab
);

procedure get_lty_account_info(
    i_entity_type      in     com_api_type_pkg.t_dict_value
  , i_object_id        in     com_api_type_pkg.t_long_id
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_eff_date         in     date
  , i_mask_error       in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , o_account             out acc_api_type_pkg.t_account_rec
  , o_service_id          out com_api_type_pkg.t_short_id
  , o_product_id          out com_api_type_pkg.t_short_id
);

procedure get_lty_account(
    i_entity_type      in     com_api_type_pkg.t_dict_value
  , i_object_id        in     com_api_type_pkg.t_long_id
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_eff_date         in     date
  , i_mask_error       in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , o_account             out acc_api_type_pkg.t_account_rec
);

procedure move_bonus(
    i_src_account            in     acc_api_type_pkg.t_account_rec
  , i_dst_account            in     acc_api_type_pkg.t_account_rec
  , i_oper_id                in     com_api_type_pkg.t_long_id
  , i_oper_date              in     date
  , i_oper_amount            in     com_api_type_pkg.t_money
  , i_oper_currency          in     com_api_type_pkg.t_curr_code
  , i_debit_macros_type      in     com_api_type_pkg.t_long_id
  , i_credit_macros_type     in     com_api_type_pkg.t_long_id
  , i_rate_type              in     com_api_type_pkg.t_dict_value
  , i_conversion_type        in     com_api_type_pkg.t_dict_value    default null
  , i_param_tab              in     com_api_type_pkg.t_param_tab
);

end;
/
