create or replace package aut_ui_resp_code_pkg is
/************************************************************
 * Authorizations resp codes<br />
 * Created by Kopachev D.(kopachev@bpcbt.com)  at 19.03.2010  <br />
 * Last changed by $Author: krukov $  <br />
 * $LastChangedDate:: 2011-09-26 19:32:51 +0400#$ <br />
 * Revision: $LastChangedRevision: 10879 $ <br />
 * Module: AUT_UI_RESP_CODE_PKG <br />
 * @headcom
 ************************************************************/
procedure add_resp_code (
    o_id                        out com_api_type_pkg.t_tiny_id
    , o_seqnum                  out com_api_type_pkg.t_seqnum
    , i_resp_code               in com_api_type_pkg.t_dict_value
    , i_is_reversal             in com_api_type_pkg.t_boolean
    , i_proc_type               in com_api_type_pkg.t_dict_value
    , i_auth_status             in com_api_type_pkg.t_dict_value
    , i_proc_mode               in com_api_type_pkg.t_dict_value
    , i_status_reason           in com_api_type_pkg.t_dict_value
    , i_oper_type               in com_api_type_pkg.t_dict_value
    , i_oper_reason             in com_api_type_pkg.t_dict_value
    , i_msg_type                in com_api_type_pkg.t_dict_value
    , i_priority                in com_api_type_pkg.t_tiny_id
    , i_is_completed            in com_api_type_pkg.t_dict_value
    , i_sttl_type               in com_api_type_pkg.t_dict_value
);

procedure modify_resp_code (
    i_id                        in com_api_type_pkg.t_tiny_id
    , io_seqnum                 in out com_api_type_pkg.t_seqnum
    , i_resp_code               in com_api_type_pkg.t_dict_value
    , i_is_reversal             in com_api_type_pkg.t_boolean
    , i_proc_type               in com_api_type_pkg.t_dict_value
    , i_auth_status             in com_api_type_pkg.t_dict_value
    , i_proc_mode               in com_api_type_pkg.t_dict_value
    , i_status_reason           in com_api_type_pkg.t_dict_value
    , i_oper_type               in com_api_type_pkg.t_dict_value
    , i_oper_reason             in com_api_type_pkg.t_dict_value
    , i_msg_type                in com_api_type_pkg.t_dict_value
    , i_priority                in com_api_type_pkg.t_tiny_id
    , i_is_completed            in com_api_type_pkg.t_dict_value
    , i_sttl_type               in com_api_type_pkg.t_dict_value
);

procedure remove_resp_code (
    i_id                        in com_api_type_pkg.t_tiny_id
    , i_seqnum                  in com_api_type_pkg.t_seqnum
);

end;
/
