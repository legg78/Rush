create or replace package acq_api_account_scheme_pkg as
/*********************************************************
 *  API for Address in application <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 17.11.2010 <br />
 *  Module: acq_api_account_scheme_pkg <br />
 *  @headcom
 **********************************************************/

procedure get_acq_account(
    i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_terminal_id       in      com_api_type_pkg.t_short_id
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_oper_type         in      com_api_type_pkg.t_dict_value
  , i_reason            in      com_api_type_pkg.t_dict_value
  , i_sttl_type         in      com_api_type_pkg.t_dict_value
  , i_terminal_type     in      com_api_type_pkg.t_dict_value
  , i_oper_sign         in      com_api_type_pkg.t_sign
  , i_scheme_id         in      com_api_type_pkg.t_tiny_id        default null
  , o_account              out  acc_api_type_pkg.t_account_rec
);

end;
/
