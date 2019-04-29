create or replace package opr_ui_proc_stage_pkg is

    procedure add_proc_stage (
        o_id                       out com_api_type_pkg.t_short_id
        , i_msg_type            in     com_api_type_pkg.t_dict_value
        , i_sttl_type           in     com_api_type_pkg.t_dict_value
        , i_oper_type           in     com_api_type_pkg.t_dict_value
        , i_proc_stage          in     com_api_type_pkg.t_dict_value
        , i_exec_order          in     com_api_type_pkg.t_tiny_id
        , i_parent_stage        in     com_api_type_pkg.t_dict_value
        , i_split_method        in     com_api_type_pkg.t_dict_value
        , i_status              in     com_api_type_pkg.t_dict_value
        , i_lang                in     com_api_type_pkg.t_dict_value
        , i_name                in     com_api_type_pkg.t_name
        , i_description         in     com_api_type_pkg.t_full_desc
        , i_command             in     com_api_type_pkg.t_dict_value    default null
        , i_result_status       in     com_api_type_pkg.t_dict_value    default null
    );

    procedure modify_proc_stage (
        i_id                    in     com_api_type_pkg.t_short_id
        , i_msg_type            in     com_api_type_pkg.t_dict_value
        , i_sttl_type           in     com_api_type_pkg.t_dict_value
        , i_oper_type           in     com_api_type_pkg.t_dict_value
        , i_proc_stage          in     com_api_type_pkg.t_dict_value
        , i_exec_order          in     com_api_type_pkg.t_tiny_id
        , i_parent_stage        in     com_api_type_pkg.t_dict_value
        , i_split_method        in     com_api_type_pkg.t_dict_value
        , i_status              in     com_api_type_pkg.t_dict_value
        , i_lang                in     com_api_type_pkg.t_dict_value
        , i_name                in     com_api_type_pkg.t_name
        , i_description         in     com_api_type_pkg.t_full_desc
        , i_command             in     com_api_type_pkg.t_dict_value    default null
        , i_result_status       in     com_api_type_pkg.t_dict_value    default null
    );

    procedure remove_proc_stage (
        i_id                    in     com_api_type_pkg.t_short_id
    );

end;
/
