create or replace package cst_lvp_api_statement_pkg as

/************************************************************
* Reports for Credit module, LienVietPost Bank <br />
* $LastChangedDate::  17.01.2018#$ <br />
* Module: cst_lvb_stmt_api_report_pkg <br />
* @headcom
************************************************************/

function get_bann_filename (
    i_mess_id        in     com_api_type_pkg.t_text
  , i_lang           in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name;

function get_bann_mess (
    i_mess_id        in     com_api_type_pkg.t_text
  , i_lang           in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_text;
   
function get_address_string (
    i_customer_id    in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_text;

function get_lty_points_name (
    i_card_id        in     com_api_type_pkg.t_medium_id
  , i_date           in     date default get_sysdate
) return com_api_type_pkg.t_text;

function format_amount(
    i_amount         in     com_api_type_pkg.t_money
  , i_curr_code      in     com_api_type_pkg.t_curr_code
  , i_mask_curr_code in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_use_separator  in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_mask_error     in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name;

function get_cash_limit_value(
    i_account_id     in     com_api_type_pkg.t_account_id
  , i_split_hash     in     com_api_type_pkg.t_tiny_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
  , i_date           in     date default get_sysdate
) return com_api_type_pkg.t_money;

function get_customer_name(
    i_account_id     in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_name;

procedure run_report (
    o_xml               out clob
  , i_lang           in     com_api_type_pkg.t_dict_value
  , i_object_id      in     com_api_type_pkg.t_medium_id
);

procedure run_sms_report (
    o_xml               out clob
  , i_lang           in     com_api_type_pkg.t_dict_value
  , i_object_id      in     com_api_type_pkg.t_medium_id
);

end cst_lvp_api_statement_pkg;
/
