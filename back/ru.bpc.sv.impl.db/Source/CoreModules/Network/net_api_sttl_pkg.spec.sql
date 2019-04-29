create or replace package net_api_sttl_pkg is 

    procedure get_sttl_type (
    	i_iss_inst_id               in com_api_type_pkg.t_inst_id
    	, i_acq_inst_id             in com_api_type_pkg.t_inst_id
    	, i_card_inst_id            in com_api_type_pkg.t_inst_id
    	, i_iss_network_id          in com_api_type_pkg.t_tiny_id
    	, i_acq_network_id          in com_api_type_pkg.t_tiny_id
    	, i_card_network_id         in com_api_type_pkg.t_tiny_id
        , i_acq_inst_bin            in com_api_type_pkg.t_rrn
        , o_sttl_type               out com_api_type_pkg.t_dict_value
        , o_match_status            out com_api_type_pkg.t_dict_value
        , i_mask_error              in com_api_type_pkg.t_boolean                       := com_api_const_pkg.FALSE
        , i_error_value             in com_api_type_pkg.t_dict_value                    := null
        , i_params                  in com_api_type_pkg.t_param_tab
        , i_oper_type               in com_api_type_pkg.t_dict_value                    default null
    );
    
    procedure get_sttl_type (
        i_iss_inst_id               in com_api_type_pkg.t_inst_id
        , i_acq_inst_id             in com_api_type_pkg.t_inst_id
        , i_card_inst_id            in com_api_type_pkg.t_inst_id
        , i_iss_network_id          in com_api_type_pkg.t_tiny_id
        , i_acq_network_id          in com_api_type_pkg.t_tiny_id
        , i_card_network_id         in com_api_type_pkg.t_tiny_id
        , i_acq_inst_bin            in com_api_type_pkg.t_rrn
        , o_sttl_type               out com_api_type_pkg.t_dict_value
        , o_match_status            out com_api_type_pkg.t_dict_value
        , i_mask_error              in com_api_type_pkg.t_boolean                       := com_api_const_pkg.FALSE
        , i_error_value             in com_api_type_pkg.t_dict_value                    := null
        , i_oper_type               in com_api_type_pkg.t_dict_value                    default null
    );

end;
/
