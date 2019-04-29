create or replace package opr_api_shared_data_pkg is
/********************************************************* 
 *  Operation shared data<br />
 *  Created by Khougaev A.(khougaev@bpcbt.com) at 21.08.2009 <br />
 *  Module:  OPR_API_SHARED_DATA_PKG  <br />
 *  @headcom
 **********************************************************/

g_amounts               com_api_type_pkg.t_amount_by_name_tab;
g_currencies            com_api_type_pkg.t_currency_by_name_tab;
g_accounts              acc_api_type_pkg.t_account_by_name_tab;
g_dates                 com_api_type_pkg.t_date_by_name_tab;
g_params                com_api_type_pkg.t_param_tab;
-- from auth
g_auth                  aut_api_type_pkg.t_auth_rec;
g_operation             opr_api_type_pkg.t_oper_rec;
g_iss_participant       opr_api_type_pkg.t_oper_part_rec;
g_acq_participant       opr_api_type_pkg.t_oper_part_rec;
g_dst_participant       opr_api_type_pkg.t_oper_part_rec;
g_agg_participant       opr_api_type_pkg.t_oper_part_rec;
g_spr_participant       opr_api_type_pkg.t_oper_part_rec;
g_lty_participant       opr_api_type_pkg.t_oper_part_rec;
g_inst_participant      opr_api_type_pkg.t_oper_part_rec;

procedure clear_shared_data;

/*
 * Stash/save current values of some global variables into local variables for private storing.
 */
procedure stash_shared_data;

/*
 * Replace current values of some global variables with saved earlier values of local variables.
 */
procedure restore_shared_data;

procedure clear_params;

procedure collect_global_oper_params;

function get_param_num(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name           default null
) return number;

function get_param_date(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name           default null
) return date;

function get_param_char(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name           default null
) return com_api_type_pkg.t_name;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            com_api_type_pkg.t_name
);

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            number
);

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            date
);

procedure set_amount(
    i_name                in            com_api_type_pkg.t_name
  , i_amount              in            com_api_type_pkg.t_money
  , i_currency            in            com_api_type_pkg.t_curr_code
  , i_conversion_rate     in            com_api_type_pkg.t_rate           default null
  , i_rate_type           in            com_api_type_pkg.t_dict_value     default null
);

procedure get_amount(
    i_name                in            com_api_type_pkg.t_name
  , o_amount                 out        com_api_type_pkg.t_money
  , o_currency               out        com_api_type_pkg.t_curr_code
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_amount        in            com_api_type_pkg.t_money          default null
  , i_error_currency      in            com_api_type_pkg.t_curr_code      default null
);

procedure get_amount(
    i_name                in            com_api_type_pkg.t_name
  , o_amount                 out        com_api_type_pkg.t_money
  , o_currency               out        com_api_type_pkg.t_curr_code
  , o_conversion_rate        out        com_api_type_pkg.t_rate
  , o_rate_type              out        com_api_type_pkg.t_dict_value
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_amount        in            com_api_type_pkg.t_money          default null
  , i_error_currency      in            com_api_type_pkg.t_curr_code      default null
);

procedure set_account(
    i_name                in            com_api_type_pkg.t_name
  , i_account_rec         in            acc_api_type_pkg.t_account_rec
);

procedure get_account(
    i_name                in            com_api_type_pkg.t_name
  , o_account_rec            out        acc_api_type_pkg.t_account_rec
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_account_id     default null
);

procedure set_date(
    i_name                in            com_api_type_pkg.t_name
  , i_date                in            date
);

procedure get_date(
    i_name                in            com_api_type_pkg.t_name
  , o_date                   out        date
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_value         in            date                              default null
);

procedure set_currency(
    i_name                in            com_api_type_pkg.t_name
  , i_currency            in            com_api_type_pkg.t_curr_code
);

procedure get_currency(
    i_name                in            com_api_type_pkg.t_name
  , o_currency               out        com_api_type_pkg.t_curr_code
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_curr_code      default null
);

procedure collect_oper_params;

procedure put_oper_params;

function get_object_id(
     io_entity_type       in out        com_api_type_pkg.t_dict_value
   , i_account_name       in            com_api_type_pkg.t_name
   , i_party_type         in            com_api_type_pkg.t_dict_value
   , o_inst_id               out        com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_long_id;

function get_object_id(
    i_entity_type         in            com_api_type_pkg.t_dict_value
  , i_account_name        in            com_api_type_pkg.t_name
  , i_party_type          in            com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_long_id;

function get_object_id(
    i_entity_type         in            com_api_type_pkg.t_dict_value
  , i_account_name        in            com_api_type_pkg.t_name
  , i_party_type          in            com_api_type_pkg.t_dict_value
  , o_inst_id                out        com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_long_id;

function get_object_id(
    i_entity_type         in            com_api_type_pkg.t_dict_value
  , i_account_name        in            com_api_type_pkg.t_name
  , i_party_type          in            com_api_type_pkg.t_dict_value
  , o_account_number         out        com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_long_id;

function get_operation return opr_api_type_pkg.t_oper_rec;

procedure set_participant(
    i_oper_participant    in            opr_api_type_pkg.t_oper_part_rec
);

function get_participant(
    i_participant_type    in            com_api_type_pkg.t_dict_value
) return opr_api_type_pkg.t_oper_part_rec;

procedure set_operation(
    i_operation           in            opr_api_type_pkg.t_oper_rec
);

procedure set_operation_proc_stage(
    i_id                  in            com_api_type_pkg.t_long_id
  , i_proc_stage          in            com_api_type_pkg.t_dict_value
);

procedure set_operation_status(
    i_id                  in            com_api_type_pkg.t_long_id
  , i_status              in            com_api_type_pkg.t_dict_value
);

procedure set_operation_reason(
    i_id                  in            com_api_type_pkg.t_long_id
  , i_reason              in            com_api_type_pkg.t_dict_value
);

procedure load_card_params;

procedure load_account_params;

procedure load_terminal_params;

procedure load_merchant_params;

procedure load_customer_params(
    i_party_type          in            com_api_type_pkg.t_dict_value
);

procedure stop_process(
    i_id                  in            com_api_type_pkg.t_long_id
  , i_status              in            com_api_type_pkg.t_dict_value
  , i_reason              in            com_api_type_pkg.t_dict_value     default null
);

procedure rollback_process(
    i_id                  in            com_api_type_pkg.t_long_id
  , i_status              in            com_api_type_pkg.t_dict_value
  , i_reason              in            com_api_type_pkg.t_dict_value
);

procedure collect_auth_params(
    i_id                  in            com_api_type_pkg.t_long_id
  , io_params             in out nocopy com_api_type_pkg.t_param_tab
);

procedure collect_auth_params;

procedure load_auth(
    i_id                  in            com_api_type_pkg.t_long_id
  , io_auth               in out nocopy aut_api_type_pkg.t_auth_rec
);

procedure put_auth_params;

function get_returning_resp_code return com_api_type_pkg.t_dict_value;

function get_operation_id(
    i_selector            in            com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_long_id;

procedure stop_stage;

procedure rollback_stage;

procedure load_card_bin_info(
    i_party_type          in            com_api_type_pkg.t_dict_value
);

function get_amounts return com_api_type_pkg.t_amount_by_name_tab;

end;
/
