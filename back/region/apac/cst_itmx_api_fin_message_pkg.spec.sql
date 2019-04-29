create or replace package cst_itmx_api_fin_message_pkg as
/*********************************************************
 *  API for ITMX financial message <br />
 *  Created by Zakharov M.(m.zakharov@bpcbt.com)  at 17.12.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: CST_ITMX_API_FIN_MESSAGE_PKG   <br />
 *  @headcom
 **********************************************************/

function estimate_fin_fraud_for_upload (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date default null
    , i_end_date            in date default null
) return number;

procedure enum_fin_msg_fraud_for_upload (
    o_fin_cur               in out sys_refcursor
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date default null
    , i_end_date            in date default null
) ;

procedure process_auth(
    i_auth_rec            in aut_api_type_pkg.t_auth_rec
  , i_inst_id             in com_api_type_pkg.t_inst_id     default null
  , i_network_id          in com_api_type_pkg.t_tiny_id     default null
  , i_collect_only        in com_api_type_pkg.t_boolean     default null
  , i_status              in com_api_type_pkg.t_dict_value  default null
  , io_fin_mess_id    in out com_api_type_pkg.t_long_id
);

function put_message (
    i_fin_rec               in cst_itmx_api_type_pkg.t_itmx_fin_mes_rec
) return com_api_type_pkg.t_long_id;

end cst_itmx_api_fin_message_pkg;
/
