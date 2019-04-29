create or replace package app_api_company_pkg as
/*********************************************************
*  Application - customer-company <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 17.09.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_COMPANY_PKG <br />
*  @headcom
**********************************************************/

/*
 *
 * @param i_appl_data_id
 * @param i_inst_id
 * @param io_appl_data
 * @param io_company_id
 */

procedure process_company(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , io_company_id          in out nocopy com_api_type_pkg.t_long_id
);

end app_api_company_pkg;
/
