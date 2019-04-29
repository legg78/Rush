CREATE OR REPLACE package body cst_cab_rule_proc_pkg as
/*********************************************************
*  Cathay custom API of the operation/event rules <br />
*  Created by ChauHuynh (huynh@bpcbt.com) at 13.03.2019 <br />
*  Module: CST_CAB_RULE_PROC_PKG <br />
*  @headcom
**********************************************************/

procedure set_amount is
    l_currency                      com_api_type_pkg.t_curr_code;

begin
    l_currency := evt_api_shared_data_pkg.get_param_char (
        i_name          => 'CURRENCY'
      , i_mask_error    => com_api_type_pkg.TRUE
    );

     trc_log_pkg.debug (
            i_text              => 'cst_cab_rule_proc_pkg: ' || l_currency
     );       

    evt_api_shared_data_pkg.set_amount (
        i_name      => evt_api_shared_data_pkg.get_param_char('BASE_AMOUNT_NAME')
      , i_amount    => evt_api_shared_data_pkg.get_param_num('AMOUNT')
      , i_currency  => nvl(l_currency, cst_cab_api_const_pkg.CURRENCY_CODE_US_DOLLAR)
    );
end;

end cst_cab_rule_proc_pkg;
/
