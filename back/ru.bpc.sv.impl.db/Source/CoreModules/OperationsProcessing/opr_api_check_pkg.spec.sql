create or replace package opr_api_check_pkg is

    procedure load_cache;
    
    procedure get_checks (
        i_msg_type              in com_api_type_pkg.t_dict_value
        , i_oper_type           in com_api_type_pkg.t_dict_value
        , i_party_type          in com_api_type_pkg.t_dict_value
        , i_inst_id             in com_api_type_pkg.t_dict_value
        , i_network_id          in com_api_type_pkg.t_dict_value
        , o_checks              out com_api_type_pkg.t_dict_tab
    );

    procedure completion_check (
        i_terminal_id                   in com_api_type_pkg.t_short_id
        , i_original_date               in date
        , i_oper_date                   in date
        , i_original_currency           in com_api_type_pkg.t_curr_code
        , i_original_amount             in com_api_type_pkg.t_money
        , i_oper_currency               in com_api_type_pkg.t_curr_code
        , i_oper_amount                 in com_api_type_pkg.t_money
        , o_reason                      out com_api_type_pkg.t_dict_value
    );

end;
/
