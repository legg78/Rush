create or replace package app_ui_application_pkg as
/*********************************************************
*  Application - user interface <br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 09.09.2009 <br />
*  Module: APP_UI_APPLICATION_PKG <br />
*  @headcom
**********************************************************/

procedure document_save(
    i_appl_data_id           in     com_api_type_pkg.t_long_id
  , i_doc_source             in     clob
  , i_sign_source            in     clob
  , i_supervisor_sign_source in     clob
  , o_save_path                 out com_api_type_pkg.t_full_desc
);

procedure document_save(
    i_appl_id           in     com_api_type_pkg.t_long_id
  , i_document_type     in     com_api_type_pkg.t_dict_value
  , i_file_name         in     com_api_type_pkg.t_full_desc
  , o_save_path            out com_api_type_pkg.t_full_desc
  , o_file_name            out com_api_type_pkg.t_full_desc
  , i_add_history       in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_entity_type            in     com_api_type_pkg.t_dict_value  
  , i_object_id         in     com_api_type_pkg.t_long_id
);

procedure document_save(
    i_appl_id_tab       in     num_tab_tpt
  , i_document_type     in     com_api_type_pkg.t_dict_value
  , i_file_name         in     com_api_type_pkg.t_full_desc
  , o_save_path            out com_api_type_pkg.t_full_desc
  , o_file_name            out com_api_type_pkg.t_full_desc
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id_tab     in     num_tab_tpt
);

procedure documents_copy(
    i_appl_id_from      in     com_api_type_pkg.t_long_id
  , i_appl_id_to        in     com_api_type_pkg.t_long_id
  , i_add_history       in     com_api_type_pkg.t_boolean  default com_api_type_pkg.FALSE
);

-- Common method which add new application with its "app_data" records.
procedure add_application(
    i_context_mode      in      com_api_type_pkg.t_dict_value
  , io_appl_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_tiny_id
  , i_appl_type         in      com_api_type_pkg.t_dict_value
  , i_appl_number       in      com_api_type_pkg.t_name
  , i_flow_id           in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_appl_status       in      com_api_type_pkg.t_dict_value       default null
  , i_session_file_id   in      com_api_type_pkg.t_long_id          default null
  , i_file_rec_num      in      com_api_type_pkg.t_tiny_id          default null
  , i_customer_type     in      com_api_type_pkg.t_dict_value       default null
  , i_reject_code       in      com_api_type_pkg.t_dict_value       default null
  , i_user_id           in      com_api_type_pkg.t_short_id         default null
  , i_is_visible        in      com_api_type_pkg.t_boolean          default null
  , i_appl_prioritized  in      com_api_type_pkg.t_boolean          default null
  , i_customer_number   in      com_api_type_pkg.t_name             default null
  , i_appl_data         in      app_data_tpt
  , i_is_new            in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
);

-- This obsolete external method will be removed from the package specification
-- Now it is internal method only
procedure add_application(
    io_appl_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_tiny_id
  , i_appl_type         in      com_api_type_pkg.t_dict_value
  , i_appl_number       in      com_api_type_pkg.t_name
  , i_flow_id           in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_appl_status       in      com_api_type_pkg.t_dict_value       default null
  , i_session_file_id   in      com_api_type_pkg.t_long_id          default null
  , i_file_rec_num      in      com_api_type_pkg.t_tiny_id          default null
  , i_customer_type     in      com_api_type_pkg.t_dict_value       default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_reject_code       in      com_api_type_pkg.t_dict_value       default null
  , i_user_id           in      com_api_type_pkg.t_short_id         default null
  , i_is_visible        in      com_api_type_pkg.t_boolean          default null
  , i_appl_prioritized  in      com_api_type_pkg.t_boolean          default null
  , i_execution_mode    in      com_api_type_pkg.t_dict_value       default null
);

procedure modify_application(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , io_seqnum           in out  com_api_type_pkg.t_tiny_id
  , i_appl_status       in      com_api_type_pkg.t_dict_value
  , i_resp_sess_file_id in      com_api_type_pkg.t_long_id          default null
  , i_comments          in      com_api_type_pkg.t_full_desc        default null
  , i_change_action     in      com_api_type_pkg.t_name             default null
  , i_reject_code       in      com_api_type_pkg.t_dict_value       default null
  , i_event_type        in      com_api_type_pkg.t_dict_value       default null
  , i_user_id           in      com_api_type_pkg.t_short_id         default null
  , i_appl_prioritized  in      com_api_type_pkg.t_boolean          default null
  , i_skip_oper_process in      com_api_type_pkg.t_boolean          default null
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
);

procedure modify_application(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , io_seqnum           in out  com_api_type_pkg.t_tiny_id
  , i_reason_code       in      com_api_type_pkg.t_dict_value
  , i_resp_sess_file_id in      com_api_type_pkg.t_long_id          default null
  , i_comments          in      com_api_type_pkg.t_full_desc        default null
  , i_change_action     in      com_api_type_pkg.t_name             default null
  , i_event_type        in      com_api_type_pkg.t_dict_value       default null
  , i_user_id           in      com_api_type_pkg.t_short_id         default null
  , i_raise_error       in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , i_appl_prioritized  in      com_api_type_pkg.t_boolean          default null
  , i_skip_oper_process in      com_api_type_pkg.t_boolean          default null
);

procedure modify_application_data(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_appl_data         in      app_data_tpt
  , i_is_new            in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
);

procedure remove_application(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_seqnum            in      com_api_type_pkg.t_tiny_id
);

function get_next_appl_id return com_api_type_pkg.t_long_id;

function get_next_appl_data_id (
    i_appl_id           in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id;

procedure process_application(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_forced_processing in      com_api_type_pkg.t_boolean          default null
);

function get_xml (
    i_appl_id           in      com_api_type_pkg.t_long_id
) return clob;

function get_xml_with_id (
    i_appl_id           in      com_api_type_pkg.t_long_id
) return clob;

procedure main_handler(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , o_result               out  com_api_type_pkg.t_dict_value
);

-- This obsolete external method will be removed from the package specification
-- Now it is internal method only
procedure add_application_migrate(
    io_appl_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_tiny_id
  , i_appl_type         in      com_api_type_pkg.t_dict_value
  , i_appl_number       in      com_api_type_pkg.t_name
  , i_flow_id           in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_appl_status       in      com_api_type_pkg.t_dict_value       default null
  , i_session_file_id   in      com_api_type_pkg.t_long_id          default null
  , i_file_rec_num      in      com_api_type_pkg.t_tiny_id          default null
  , i_customer_type     in      com_api_type_pkg.t_dict_value       default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_appl_prioritized  in      com_api_type_pkg.t_boolean          default null
  , i_execution_mode    in      com_api_type_pkg.t_dict_value       default null
);

-- This obsolete external method will be removed from the package specification
-- Now it is internal method only
procedure modify_data_migrate(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_appl_data         in      app_data_tpt
  , i_is_new            in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
);

procedure get_application(
    i_appl_type         in      com_api_type_pkg.t_dict_value
  , i_appl_number       in      com_api_type_pkg.t_name
  , i_flow_id           in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_appl_status       in      com_api_type_pkg.t_dict_value       default null
  , i_customer_type     in      com_api_type_pkg.t_dict_value       default null
  , i_parent_id         in      com_api_type_pkg.t_long_id          default null
  , o_ref_cursor        out     sys_refcursor
);

function get_entity_data(
    i_entity_type            in     com_api_type_pkg.t_dict_value
  , i_object_id              in     com_api_type_pkg.t_medium_id
  , i_object_number          in     com_api_type_pkg.t_name
  , i_inst_id                in     com_api_type_pkg.t_medium_id
) return com_param_map_tpt pipelined;

function get_entity_data(
    i_entity_type            in     com_api_type_pkg.t_dict_value
  , i_object_type            in     com_api_type_pkg.t_dict_value
  , i_parent_entity_type     in     com_api_type_pkg.t_dict_value
  , i_parent_object_id       in     com_api_type_pkg.t_medium_id
  , i_inst_id                in     com_api_type_pkg.t_medium_id
  , i_parent_object_number   in     com_api_type_pkg.t_name         default null
  , i_seqnum                 in     com_api_type_pkg.t_tiny_id      default null
) return com_param_map_tpt pipelined;

end app_ui_application_pkg;
/
