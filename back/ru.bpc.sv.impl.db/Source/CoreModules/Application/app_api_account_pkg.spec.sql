create or replace package app_api_account_pkg as
/*********************************************************
*  Application - account <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 01.02.2011 <br />
*  Module: APP_API_ACCOUNT_PKG <br />
*  @headcom
**********************************************************/

procedure process_account(
    i_appl_data_id   in            com_api_type_pkg.t_long_id
  , i_inst_id        in            com_api_type_pkg.t_inst_id
  , i_agent_id       in            com_api_type_pkg.t_short_id
  , i_customer_id    in            com_api_type_pkg.t_medium_id
  , i_contract_id    in            com_api_type_pkg.t_medium_id
  , o_account_id    out            com_api_type_pkg.t_medium_id
);

procedure check_default_values(
    i_account_id     in            com_api_type_pkg.t_long_id
);

end;
/
