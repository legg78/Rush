create or replace package cst_pvc_api_statement_pkg as
/************************************************************
 * Statements for PVCom Bank                                <br />
 * Created by ChauHuynh(huynh@bpcbt.com) at 24.08.2018    $ <br />
 * Module: CST_PVC_API_STATEMENT_PKG                        <br />
 * @headcom
 ************************************************************/

function get_bann_filename(
    i_message_id            in  com_api_type_pkg.t_text
  , i_lang                  in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name;

function get_bann_message(
    i_message_id            in  com_api_type_pkg.t_text
  , i_lang                  in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_text;

function format_amount(
    i_amount                in  com_api_type_pkg.t_money
  , i_curr_code             in  com_api_type_pkg.t_curr_code
  , i_mask_curr_code        in  com_api_type_pkg.t_boolean  default com_api_type_pkg.TRUE
  , i_use_separator         in  com_api_type_pkg.t_boolean  default com_api_type_pkg.TRUE
  , i_mask_error            in  com_api_type_pkg.t_boolean  default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name;

procedure run_report (
    o_xml                   out clob
  , i_lang                  in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_medium_id
  , i_entity_type           in  com_api_type_pkg.t_dict_value  default crd_api_const_pkg.ENTITY_TYPE_INVOICE
  , i_attachment_format_id  in  com_api_type_pkg.t_tiny_id     default null
);

end cst_pvc_api_statement_pkg;
/
