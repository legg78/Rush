create or replace package cst_woo_stmt_api_report_pkg is
/************************************************************
* Reports for Credit module <br />
* Created by Aman Weerasinghe(weerasinghe@bpcbt.com) at 01.06.2016  <br />
* Last changed by $Author: Renat Shayukov $  <br />
* $LastChangedDate::  27.07.2017#$ <br />
* Revision: $LastChangedRevision: $ <br />
* Module: cst_woo_stmt_api_report_pkg <br />
* @headcom
************************************************************/

function get_bann_filename (
    i_mess_id    in  com_api_type_pkg.t_text
  , i_lang       in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name;

function get_bann_mess (
    i_mess_id    in  com_api_type_pkg.t_text
  , i_lang       in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_text;
   
function get_address_string (
    i_customer_id in com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_text;

function get_lty_points_name (
    i_card_id  in com_api_type_pkg.t_medium_id
  , i_date     in date default get_sysdate
) return com_api_type_pkg.t_text;

function format_amount(
    i_amount         in com_api_type_pkg.t_money
  , i_curr_code      in com_api_type_pkg.t_curr_code
  , i_mask_curr_code in com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_use_separator  in com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_mask_error     in com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name;

function get_project_interest(
    i_debt_id           in  com_api_type_pkg.t_long_id
  , i_invoice_id        in  com_api_type_pkg.t_medium_id
  , i_split_hash        in  com_api_type_pkg.t_tiny_id
  , i_end_date          in  date
  , i_include_overdraft in  com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_include_overdue   in  com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_round             in  com_api_type_pkg.t_tiny_id default 0
)
return com_api_type_pkg.t_money;

function get_cash_limit_value(
    i_account_id  in  com_api_type_pkg.t_account_id
  , i_split_hash  in  com_api_type_pkg.t_tiny_id
  , i_inst_id     in  com_api_type_pkg.t_inst_id
  , i_date        in  date default get_sysdate
)
return com_api_type_pkg.t_money;

/* 
 * This function returns day of month for the due date
 * It's very simplified version! Only for current settings of Woori bank.
 */
function get_due_day(
    i_account_id  in  com_api_type_pkg.t_account_id
  , i_eff_date    in  date default get_sysdate
  , i_due_date    in  date
) return com_api_type_pkg.t_tiny_id;

procedure run_report (
    o_xml             out clob
  , i_lang         in     com_api_type_pkg.t_dict_value
  , i_object_id    in     com_api_type_pkg.t_medium_id
);    

end cst_woo_stmt_api_report_pkg;
/
