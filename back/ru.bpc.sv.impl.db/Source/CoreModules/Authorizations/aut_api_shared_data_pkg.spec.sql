create or replace package aut_api_shared_data_pkg is
/********************************************************* 
 *  API for shared data of authorization <br /> 
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 01.10.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module:  AUT_API_SHARED_DATA_PKG  <br /> 
 *  @headcom 
 **********************************************************/ 

    g_amounts                   com_api_type_pkg.t_amount_by_name_tab;
    g_currencies                com_api_type_pkg.t_currency_by_name_tab;
    g_accounts                  acc_api_type_pkg.t_account_by_name_tab;
    g_dates                     com_api_type_pkg.t_date_by_name_tab;
    g_params                    com_api_type_pkg.t_param_tab;

procedure clear_shared_data;

procedure clear_params;

function get_param_num (
    i_name                  in com_api_type_pkg.t_name
    , i_mask_error          in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value         in com_api_type_pkg.t_name := null
) return number;

function get_param_date (
    i_name                  in com_api_type_pkg.t_name
    , i_mask_error          in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value         in com_api_type_pkg.t_name := null
) return date;

function get_param_char (
    i_name                  in com_api_type_pkg.t_name
    , i_mask_error          in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value         in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_name;

procedure set_param (
    i_name                  in com_api_type_pkg.t_name
    , i_value               in com_api_type_pkg.t_name
);

procedure set_param (
    i_name                  in com_api_type_pkg.t_name
    , i_value               in number
);

procedure set_param (
    i_name                  in com_api_type_pkg.t_name
    , i_value               in date
);

procedure set_amount (
    i_name                  in com_api_type_pkg.t_name
    , i_amount              in com_api_type_pkg.t_money
    , i_currency            in com_api_type_pkg.t_curr_code
);

procedure get_amount (
    i_name                  in com_api_type_pkg.t_name
    , o_amount              out com_api_type_pkg.t_money
    , o_currency            out com_api_type_pkg.t_curr_code
    , i_mask_error          in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_amount        in com_api_type_pkg.t_money := null
    , i_error_currency      in com_api_type_pkg.t_curr_code := null
);

procedure set_account (
    i_name                  in com_api_type_pkg.t_name
  , i_account_rec           in acc_api_type_pkg.t_account_rec
);

procedure get_account (
    i_name                  in     com_api_type_pkg.t_name
  , o_account_rec              out acc_api_type_pkg.t_account_rec
  , i_mask_error            in     com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE
  , i_error_value           in     com_api_type_pkg.t_account_id := null
);

procedure set_date (
    i_name                  in com_api_type_pkg.t_name
    , i_date                in date
);

procedure get_date (
    i_name                  in com_api_type_pkg.t_name
    , o_date                out date
    , i_mask_error          in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value         in date := null
);

procedure set_currency (
    i_name                  in com_api_type_pkg.t_name
    , i_currency            in com_api_type_pkg.t_curr_code
);

procedure get_currency (
    i_name                  in com_api_type_pkg.t_name
    , o_currency            out com_api_type_pkg.t_curr_code
    , i_mask_error          in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value         in com_api_type_pkg.t_curr_code := null
);

/*procedure set_returning_resp_code (
    i_resp_code             in com_api_type_pkg.t_dict_value 
);

function get_returning_resp_code return com_api_type_pkg.t_dict_value;*/

function get_object_id (
    i_entity_type           in com_api_type_pkg.t_dict_value
    , i_account_name        in com_api_type_pkg.t_name
    , i_party_type          in com_api_type_pkg.t_dict_value
    , o_inst_id             out com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_long_id;

function get_object_id (
    i_entity_type           in com_api_type_pkg.t_dict_value
    , i_account_name        in com_api_type_pkg.t_name
    , i_party_type          in com_api_type_pkg.t_dict_value
    , o_account_number      out com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_long_id;

procedure load_card_params;

procedure load_account_params;

procedure load_terminal_params;

procedure load_merchant_params;

procedure load_customer_params (
    i_party_type        in com_api_type_pkg.t_dict_value
);

procedure stop_process (
    i_resp_code         in com_api_type_pkg.t_dict_value
    , i_status          in com_api_type_pkg.t_dict_value := null
);

procedure rollback_process (
    i_resp_code         in com_api_type_pkg.t_dict_value
    , i_status          in com_api_type_pkg.t_dict_value := null
    , i_reason          in com_api_type_pkg.t_dict_value := null
);

end;
/
