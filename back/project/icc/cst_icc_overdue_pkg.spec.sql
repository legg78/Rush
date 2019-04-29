create or replace package cst_icc_overdue_pkg as
/*********************************************************
*  API for overdue <br />
*  Created by  Y. Kolodkina(kolodkina@bpcbt.com)  at 18.10.2016 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: cst_icc_overdue_pkg <br />
*  @headcom
**********************************************************/

function check_account_in_overdue(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
)return com_api_type_pkg.t_boolean;

end;
/
