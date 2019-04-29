create or replace package evt_api_shared_data_pkg is
/*********************************************************
 *  API for shared data of events <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 10.05.2011 <br />
 *  Module: EVT_API_SHARED_DATA_PKG  <br />
 *  @headcom
 **********************************************************/

    g_amounts               com_api_type_pkg.t_amount_by_name_tab;
    g_currencies            com_api_type_pkg.t_currency_by_name_tab;
    g_accounts              acc_api_type_pkg.t_account_by_name_tab;
    g_dates                 com_api_type_pkg.t_date_by_name_tab;
    g_params                com_api_type_pkg.t_param_tab;

procedure clear_shared_data;

function get_param_num (
    i_name              in com_api_type_pkg.t_name
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_name := null
) return number;

function get_param_date (
    i_name              in com_api_type_pkg.t_name
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_name := null
) return date;

function get_param_char (
    i_name              in com_api_type_pkg.t_name
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_name;

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in com_api_type_pkg.t_name
);

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in number
);

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in date
);

procedure set_amount (
    i_name              in com_api_type_pkg.t_name
    , i_amount          in com_api_type_pkg.t_money
    , i_currency        in com_api_type_pkg.t_curr_code
);

procedure get_amount (
    i_name              in com_api_type_pkg.t_name
    , o_amount          out com_api_type_pkg.t_money
    , o_currency        out com_api_type_pkg.t_curr_code
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_amount    in com_api_type_pkg.t_money := null
    , i_error_currency  in com_api_type_pkg.t_curr_code := null
);

procedure set_account (
    i_name              in com_api_type_pkg.t_name
  , i_account_rec       in acc_api_type_pkg.t_account_rec
);

procedure get_account (
    i_name              in     com_api_type_pkg.t_name
  , o_account_rec          out acc_api_type_pkg.t_account_rec
  , i_mask_error        in     com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
  , i_error_value       in     com_api_type_pkg.t_account_id  := null
);

procedure set_date (
    i_name              in com_api_type_pkg.t_name
    , i_date            in date
);

procedure get_date (
    i_name              in com_api_type_pkg.t_name
    , o_date            out date
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in date := null
);

procedure set_currency (
    i_name              in com_api_type_pkg.t_name
    , i_currency        in com_api_type_pkg.t_curr_code
);

procedure get_currency (
    i_name              in com_api_type_pkg.t_name
    , o_currency        out com_api_type_pkg.t_curr_code
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_curr_code := null
);

procedure load_event_params;

procedure load_event_customer_params;

procedure load_event_contract_params;

end;
/
