create or replace package h2h_api_fin_message_pkg as
/*********************************************************
 *  Host-to-host financial messages API <br />
 *  Created by Gerbeev I.(gerbeev@bpcbt.com)  at 22.06.2018 <br />
 *  Module: H2H_API_FIN_MESSAGE_PKG <br />
 *  @headcom
 **********************************************************/

function message_exists(
    i_fin_id                in            com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

function put_file(
    i_file_rec              in             h2h_api_type_pkg.t_h2h_file_rec
) return com_api_type_pkg.t_long_id;

procedure create_operation(
    i_fin_rec               in             h2h_api_type_pkg.t_h2h_clearing_rec
  , i_host_id                              com_api_type_pkg.t_tiny_id             default null
  , i_standard_id                          com_api_type_pkg.t_tiny_id             default null
  , io_tag_value_tab        in out nocopy  h2h_api_type_pkg.t_h2h_tag_value_tab
  , o_resp_code                out         com_api_type_pkg.t_dict_value
);

function put_message(
    i_fin_rec               in             h2h_api_type_pkg.t_h2h_fin_message_rec
) return com_api_type_pkg.t_long_id;

function put_message(
    i_fin_rec               in             h2h_api_type_pkg.t_h2h_clearing_rec
) return com_api_type_pkg.t_long_id;

function get_message(
    i_fin_id                in             com_api_type_pkg.t_long_id
  , i_mask_error            in             com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return h2h_api_type_pkg.t_h2h_fin_message_rec;

function get_message(
    i_oper_id               in             com_api_type_pkg.t_long_id
  , i_mask_error            in             com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return h2h_api_type_pkg.t_h2h_fin_message_rec;

procedure validate_message(
    i_fin_rec               in             h2h_api_type_pkg.t_h2h_clearing_rec
);

procedure update_status(
    i_fin_id                in             com_api_type_pkg.t_long_id
  , i_status                in             com_api_type_pkg.t_dict_value
);

end;
/
