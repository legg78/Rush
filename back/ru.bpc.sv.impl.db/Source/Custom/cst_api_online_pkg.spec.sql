create or replace package cst_api_online_pkg is

    function get_resp_code (
        i_error                     in com_api_type_pkg.t_name
        , i_msg_type                in com_api_type_pkg.t_dict_value
        , i_oper_type               in com_api_type_pkg.t_dict_value
        , i_oper_reason             in com_api_type_pkg.t_dict_value
        , i_participant_type        in com_api_type_pkg.t_dict_value
        , i_client_id_type          in com_api_type_pkg.t_dict_value
        , i_client_id_value         in com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_dict_value;

    function check_card_expire_date(
        i_oper_type                 in com_api_type_pkg.t_dict_value
        , i_host_date               in date
        , i_start_date              in date
        , i_expir_date              in date
        , i_resp_code               in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_dict_value;

end;
/
