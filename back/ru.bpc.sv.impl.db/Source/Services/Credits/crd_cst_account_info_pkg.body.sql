create or replace package body crd_cst_account_info_pkg as
/************************************************************
* UI specific procedures for a credit service <br />
* Created by Kolodkina Y.(kolodkina@bpcbt.com) at 30.03.2015 <br />
* Last changed by $Author$ <br />
* $LastChangedDate$ <br />
* Module: CRD_CST_ACCOUNT_INFO_PKG <br />
* @headcom
************************************************************/

function get_add_parameters (
    i_account_id     in  com_api_type_pkg.t_account_id
  , i_product_id     in  com_api_type_pkg.t_short_id    default null
  , i_service_id     in  com_api_type_pkg.t_short_id    default null
  , i_split_hash     in  com_api_type_pkg.t_tiny_id     default null
  , i_inst_id        in  com_api_type_pkg.t_inst_id     default null
  , i_param_tab      in  com_api_type_pkg.t_param_tab   
) return com_api_type_pkg.t_lob_data
is
begin
    return null;
end;

end;
/
