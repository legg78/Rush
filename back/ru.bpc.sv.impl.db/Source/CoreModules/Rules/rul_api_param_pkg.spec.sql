create or replace package rul_api_param_pkg is
/*********************************************************
 *  Rules - Parameter API  <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 19.03.2010 <br />
 *  Module: RUL_API_PARAM_PKG <br />
 *  @headcom
 **********************************************************/

procedure init_param_cache;

procedure clear_params (
    io_params           in out nocopy com_api_type_pkg.t_param_tab
);

function serialize_params (
    i_params                in com_api_type_pkg.t_param_tab
) return varchar2;

function get_param_num (
    i_name              in com_api_type_pkg.t_name
    , io_params         in com_api_type_pkg.t_param_tab
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_param_value := null
) return number;

function get_param_date (
    i_name              in com_api_type_pkg.t_name
    , io_params         in com_api_type_pkg.t_param_tab
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_param_value := null
) return date;

function get_param_char (
    i_name              in com_api_type_pkg.t_name
    , io_params         in com_api_type_pkg.t_param_tab
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_param_value := null
) return com_api_type_pkg.t_param_value;

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in com_api_type_pkg.t_param_value
    , io_params         in out nocopy com_api_type_pkg.t_param_tab
); 

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in number
    , io_params         in out nocopy com_api_type_pkg.t_param_tab
); 

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in date
    , io_params         in out nocopy com_api_type_pkg.t_param_tab
); 

procedure set_amount (
    i_name              in com_api_type_pkg.t_name
    , i_amount          in com_api_type_pkg.t_money
    , i_currency        in com_api_type_pkg.t_curr_code
    , i_conversion_rate in com_api_type_pkg.t_rate          default null
    , i_rate_type       in com_api_type_pkg.t_dict_value    default null
    , io_amount_tab     in out com_api_type_pkg.t_amount_by_name_tab
);

procedure get_amount (
    i_name              in com_api_type_pkg.t_name
    , o_amount          out com_api_type_pkg.t_money
    , o_currency        out com_api_type_pkg.t_curr_code
    , io_amount_tab     in com_api_type_pkg.t_amount_by_name_tab
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_amount    in com_api_type_pkg.t_money := null
    , i_error_currency  in com_api_type_pkg.t_curr_code := null
);

procedure get_amount (
    i_name                  in      com_api_type_pkg.t_name
  , o_amount                   out  com_api_type_pkg.t_money
  , o_currency                 out  com_api_type_pkg.t_curr_code
  , o_conversion_rate          out  com_api_type_pkg.t_rate
  , o_rate_type                out  com_api_type_pkg.t_dict_value
  , io_amount_tab           in      com_api_type_pkg.t_amount_by_name_tab
  , i_mask_error            in      com_api_type_pkg.t_boolean              := com_api_type_pkg.FALSE
  , i_error_amount          in      com_api_type_pkg.t_money                := null
  , i_error_currency        in      com_api_type_pkg.t_curr_code            := null
);

procedure set_account (
    i_name              in     com_api_type_pkg.t_name
  , i_account_rec       in     acc_api_type_pkg.t_account_rec
  , io_account_tab      in out acc_api_type_pkg.t_account_by_name_tab
);

procedure get_account (
    i_name              in     com_api_type_pkg.t_name
  , o_account_rec          out acc_api_type_pkg.t_account_rec
  , io_account_tab      in     acc_api_type_pkg.t_account_by_name_tab
  , i_mask_error        in     com_api_type_pkg.t_boolean              := com_api_type_pkg.FALSE
  , i_error_value       in     com_api_type_pkg.t_account_id           := null
);

procedure set_date (
    i_name              in com_api_type_pkg.t_name
    , i_date            in date
    , io_date_tab       in out com_api_type_pkg.t_date_by_name_tab
);

procedure get_date (
    i_name              in com_api_type_pkg.t_name
    , o_date            out date
    , io_date_tab       in com_api_type_pkg.t_date_by_name_tab
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in date := null
);

procedure set_currency (
    i_name              in com_api_type_pkg.t_name
    , i_currency        in com_api_type_pkg.t_curr_code
    , io_currency_tab   in out com_api_type_pkg.t_currency_by_name_tab
);

procedure get_currency (
    i_name              in com_api_type_pkg.t_name
    , o_currency        out com_api_type_pkg.t_curr_code
    , io_currency_tab   in com_api_type_pkg.t_currency_by_name_tab
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_curr_code := null
);

end;
/
