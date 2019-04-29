create or replace package pmo_api_param_function_pkg as
/************************************************************
 * Functions are used for calculation real values of <br />
 * payment order parameters. Like rules, they use <br />
 * shared caches to get incoming parameters. All <br />
 * necessary cache data should be loaded before usage <br />
 * of these functions. Functions always return value <br />
 * of type com_api_type_pkg.t_param_value.<br />
 * Created by Gerbeev I.(gerbeev@bpc.ru) at 11.04.2018  <br />
 * Last changed by $Author: gerbeev $ <br />
 * $LastChangedDate:: 2018-04-11 11:00:00 +0400#$ <br />
 * Revision: $LastChangedRevision: $ <br />
 * Module: pmo_api_param_function_pkg <br />
 * @headcom
 ************************************************************/

g_order_params          com_api_type_pkg.t_param_tab;
g_invoice               crd_api_type_pkg.t_invoice_rec;

procedure load_order_params(
    i_order_id          in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
);

function get_due_date
return com_api_type_pkg.t_short_desc;

function get_mad
return com_api_type_pkg.t_short_desc;

function get_account_number
return com_api_type_pkg.t_short_desc;

function get_card_number
return com_api_type_pkg.t_short_desc;

function get_purpose_text
return com_api_type_pkg.t_short_desc;

end pmo_api_param_function_pkg;
/
