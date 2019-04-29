create or replace package nbc_api_fin_message_pkg as

function put_message (
    i_fin_rec               in nbc_api_type_pkg.t_nbc_fin_mes_rec
) return com_api_type_pkg.t_long_id;

procedure process_auth (
    i_auth_rec              in aut_api_type_pkg.t_auth_rec
    , i_inst_id             in com_api_type_pkg.t_inst_id 
    , i_network_id          in com_api_type_pkg.t_tiny_id 
    , i_status              in com_api_type_pkg.t_dict_value default null
    , io_fin_mess_id        in out com_api_type_pkg.t_long_id
);

procedure enum_messages_for_upload (
    o_fin_cur               in out sys_refcursor
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_participant_type    in com_api_type_pkg.t_dict_value     
);

function estimate_messages_for_upload (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_participant_type    in com_api_type_pkg.t_dict_value        
) return number;

procedure change_dispute_result (
    i_id                    in com_api_type_pkg.t_long_id
    , i_result              in com_api_type_pkg.t_dict_value
); 

procedure set_ibft_participant_type(
    i_auth_rec              in            aut_api_type_pkg.t_auth_rec
  , i_inst_id               in            com_api_type_pkg.t_inst_id
  , i_host_id               in            com_api_type_pkg.t_tiny_id
  , i_standard_id           in            com_api_type_pkg.t_tiny_id
  , io_fin_rec              in out nocopy nbc_api_type_pkg.t_nbc_fin_mes_rec
  , i_bank_code             in            com_api_type_pkg.t_name
  , i_iss_inst_code_by_pan  in            com_api_type_pkg.t_name
  , i_party_algo            in            com_api_type_pkg.t_dict_value  
);

end nbc_api_fin_message_pkg;
/
