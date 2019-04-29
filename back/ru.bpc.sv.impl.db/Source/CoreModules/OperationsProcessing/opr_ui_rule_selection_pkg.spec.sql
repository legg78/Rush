create or replace package opr_ui_rule_selection_pkg is

    procedure add (
        o_id                    out com_api_type_pkg.t_short_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_msg_type            in com_api_type_pkg.t_dict_value
        , i_proc_stage          in com_api_type_pkg.t_dict_value
        , i_sttl_type           in com_api_type_pkg.t_dict_value
        , i_oper_type           in com_api_type_pkg.t_dict_value
        , i_oper_reason         in com_api_type_pkg.t_dict_value
        , i_is_reversal         in com_api_type_pkg.t_dict_value
        , i_iss_inst_id         in com_api_type_pkg.t_dict_value
        , i_acq_inst_id         in com_api_type_pkg.t_dict_value
        , i_terminal_type       in com_api_type_pkg.t_dict_value
        , i_oper_currency       in com_api_type_pkg.t_curr_code
        , i_account_currency    in com_api_type_pkg.t_curr_code
        , i_sttl_currency       in com_api_type_pkg.t_curr_code
        , i_mod_id              in com_api_type_pkg.t_tiny_id
        , i_rule_set_id         in com_api_type_pkg.t_tiny_id
        , i_exec_order          in com_api_type_pkg.t_tiny_id
    );

    procedure modify (
        i_id                    in com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_msg_type            in com_api_type_pkg.t_dict_value
        , i_proc_stage          in com_api_type_pkg.t_dict_value
        , i_sttl_type           in com_api_type_pkg.t_dict_value
        , i_oper_type           in com_api_type_pkg.t_dict_value
        , i_oper_reason         in com_api_type_pkg.t_dict_value
        , i_is_reversal         in com_api_type_pkg.t_dict_value
        , i_iss_inst_id         in com_api_type_pkg.t_dict_value
        , i_acq_inst_id         in com_api_type_pkg.t_dict_value
        , i_terminal_type       in com_api_type_pkg.t_dict_value
        , i_oper_currency       in com_api_type_pkg.t_curr_code
        , i_account_currency    in com_api_type_pkg.t_curr_code
        , i_sttl_currency       in com_api_type_pkg.t_curr_code
        , i_mod_id              in com_api_type_pkg.t_tiny_id
        , i_rule_set_id         in com_api_type_pkg.t_tiny_id
        , i_exec_order          in com_api_type_pkg.t_tiny_id
    );

    procedure remove (
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );

end; 
/
