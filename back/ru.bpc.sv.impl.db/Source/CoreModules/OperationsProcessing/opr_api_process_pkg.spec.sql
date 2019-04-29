create or replace package opr_api_process_pkg is

procedure process_operations(
    i_stage               in            com_api_type_pkg.t_dict_value default opr_api_const_pkg.PROCESSING_STAGE_COMMON
  , i_process_container   in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id          in            com_api_type_pkg.t_long_id    default null
  , i_oper_filter         in            com_api_type_pkg.t_dict_value default null
);

procedure process_operation(
    i_operation_id        in            com_api_type_pkg.t_long_id
  , i_stage               in            com_api_type_pkg.t_dict_value default opr_api_const_pkg.PROCESSING_STAGE_COMMON
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_commit_work         in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_param_tab           in            com_param_map_tpt             default null
);

procedure process_rules(
    i_msg_type            in            com_api_type_pkg.t_dict_value
  , i_proc_stage          in            com_api_type_pkg.t_dict_value default opr_api_const_pkg.PROCESSING_STAGE_COMMON
  , i_sttl_type           in            com_api_type_pkg.t_dict_value
  , i_oper_type           in            com_api_type_pkg.t_dict_value
  , i_oper_reason         in            com_api_type_pkg.t_dict_value default null
  , i_is_reversal         in            com_api_type_pkg.t_boolean    default null
  , i_iss_inst_id         in            com_api_type_pkg.t_inst_id    default null
  , i_acq_inst_id         in            com_api_type_pkg.t_inst_id    default null
  , i_terminal_type       in            com_api_type_pkg.t_dict_value default null
  , i_oper_currency       in            com_api_type_pkg.t_curr_code  default null
  , i_account_currency    in            com_api_type_pkg.t_curr_code  default null
  , i_sttl_currency       in            com_api_type_pkg.t_curr_code  default null
  , i_proc_mode           in            com_api_type_pkg.t_dict_value default null
  , o_rules_count            out number
  , io_params             in out nocopy com_api_type_pkg.t_param_tab
);

-- You can run this method and see the result query for dynamic SQL.
function get_query_statement(
    i_count_query_only    in            com_api_type_pkg.t_boolean
  , i_stage               in            com_api_type_pkg.t_dict_value
  , i_operation_id        in            com_api_type_pkg.t_long_id
  , i_thread_number       in            com_api_type_pkg.t_tiny_id
  , i_process_container   in            com_api_type_pkg.t_boolean
  , i_session_id          in            com_api_type_pkg.t_long_id
  , i_statement           in            com_api_type_pkg.t_text
) return com_api_type_pkg.t_text;

end;
/
