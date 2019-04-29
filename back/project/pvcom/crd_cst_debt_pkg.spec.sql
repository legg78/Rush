create or replace package crd_cst_debt_pkg as
/************************************************************
* Manipulatons with debts and its interests <br />
* Created by Madan B.(madan@bpcbt.com) at 26.03.2014 <br />
* Module: CRD_CST_DEBT_PKG <br />
* @headcom
************************************************************/

/***********************************************************************
 * Loads additional debt's parameters.
 * @param i_debt_id        ID of a debt for a client's account
 * @param i_account_id     ID of a client's account
 * @param i_product_id     ID of a product
 * @param i_service_id     ID of a service
 * @param i_split_hash     Split hash value
 * @param io_param_tab     Parameters of a debt
 *
 ***********************************************************************/
procedure load_debt_param (
    i_debt_id           in            com_api_type_pkg.t_long_id      default null
  , i_account_id        in            com_api_type_pkg.t_long_id
  , i_product_id        in            com_api_type_pkg.t_short_id
  , i_service_id        in            com_api_type_pkg.t_short_id     default null
  , i_split_hash        in            com_api_type_pkg.t_tiny_id      default null
  , io_param_tab        in out nocopy com_api_type_pkg.t_param_tab
);

function get_oper_type(
    i_debt_id           in      com_api_type_pkg.t_long_id      default null
  , i_oper_id           in      com_api_type_pkg.t_long_id      default null
  , i_oper_type         in      com_api_type_pkg.t_dict_value
  , i_balance_type      in      com_api_type_pkg.t_dict_value
  , i_macros_type_id    in      com_api_type_pkg.t_tiny_id      default null
) return com_api_type_pkg.t_tiny_id;

function get_oper_name(
    i_oper_type         in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name;

function get_oper_descr(
    i_debt_id           in      com_api_type_pkg.t_long_id      default null
  , i_oper_id           in      com_api_type_pkg.t_long_id      default null
  , i_oper_type         in      com_api_type_pkg.t_dict_value
  , i_oper_date         in      date
  , i_merchant_city     in      com_api_type_pkg.t_name
  , i_merchant_street   in      com_api_type_pkg.t_name
  , i_oper_type_n       in      com_api_type_pkg.t_tiny_id
  , i_lang              in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name;

procedure debt_postprocess(
    i_debt_id           in      com_api_type_pkg.t_long_id
);

end;
/
