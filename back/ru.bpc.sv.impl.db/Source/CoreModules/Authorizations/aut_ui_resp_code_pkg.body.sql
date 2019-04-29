create or replace package body aut_ui_resp_code_pkg is
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
) is
begin
    o_id := aut_resp_code_seq.nextval;
    o_seqnum := 1;

    insert into aut_resp_code_vw (
        id
        , seqnum
        , resp_code
        , is_reversal
        , proc_type
        , auth_status
        , proc_mode
        , status_reason
        , oper_type
        , msg_type
        , priority
        , is_completed
        , sttl_type
        , oper_reason
    ) values (
        o_id
        , o_seqnum
        , i_resp_code
        , i_is_reversal
        , i_proc_type
        , i_auth_status
        , i_proc_mode
        , i_status_reason
        , i_oper_type
        , i_msg_type
        , i_priority
        , i_is_completed
        , i_sttl_type
        , i_oper_reason
    );

end;

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
) is
begin
    update
        aut_resp_code_vw
    set
        seqnum = io_seqnum
        , resp_code     = i_resp_code
        , is_reversal   = i_is_reversal
        , proc_type     = i_proc_type
        , auth_status   = i_auth_status
        , proc_mode     = i_proc_mode
        , status_reason = i_status_reason
        , oper_type     = i_oper_type
        , msg_type      = i_msg_type
        , priority      = i_priority
        , is_completed  = i_is_completed
        , sttl_type     = i_sttl_type
        , oper_reason   = i_oper_reason
    where
        id = i_id;

    io_seqnum := io_seqnum + 1;

end;

procedure remove_resp_code (
    i_id                        in com_api_type_pkg.t_tiny_id
    , i_seqnum                  in com_api_type_pkg.t_seqnum
) is
begin
    update
        aut_resp_code_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;

    delete from
        aut_resp_code_vw
    where
        id = i_id;
end;

end;
/
