create or replace package com_api_error_pkg as

/*********************************************************
*  UI for exception handling <br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 12.04.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: com_api_error_pkg <br />
*  @headcom
**********************************************************/

    FATAL_ERROR            constant number := -20999;

    APPL_ERROR             constant number := -20001;

    e_application_error exception;
    PRAGMA EXCEPTION_INIT(e_application_error, -20001);

    e_fatal_error exception;
    PRAGMA EXCEPTION_INIT(e_fatal_error, -20999);

    e_stop_execute_rule_set exception;
    PRAGMA EXCEPTION_INIT(e_stop_execute_rule_set, -20010);

    e_stop_process_operation exception;
    PRAGMA EXCEPTION_INIT(e_stop_process_operation, -20011);

    e_rollback_execute_rule_set exception;
    PRAGMA EXCEPTION_INIT(e_rollback_execute_rule_set, -20012);

    e_rollback_process_operation exception;
    PRAGMA EXCEPTION_INIT(e_rollback_process_operation, -20013);

    e_stop_appl_processing exception;
    PRAGMA EXCEPTION_INIT(e_stop_appl_processing , -20014);

    e_rollback_process_stage exception;
    PRAGMA EXCEPTION_INIT(e_rollback_process_stage, -20015);

    e_stop_process_stage exception;
    PRAGMA EXCEPTION_INIT(e_stop_process_stage, -20016);

    e_stop_cycle_repetition exception;
    PRAGMA EXCEPTION_INIT(e_stop_cycle_repetition, -25001);

    e_resource_busy exception;
    PRAGMA EXCEPTION_INIT(e_resource_busy, -54);

    e_deadlock_detected exception;
    PRAGMA EXCEPTION_INIT(e_deadlock_detected, -60);

    e_invalid_number exception;
    PRAGMA EXCEPTION_INIT(e_invalid_number, -1722);

    e_value_error exception;
    PRAGMA EXCEPTION_INIT(e_value_error, -6502);

    e_savepoint_never_established exception;
    PRAGMA EXCEPTION_INIT(e_savepoint_never_established, -1086);

    e_sequence_does_not_exist exception;
    PRAGMA EXCEPTION_INIT(e_sequence_does_not_exist, -2289);

    e_connect_by_loop exception;
    PRAGMA EXCEPTION_INIT(e_connect_by_loop, -01436);

    e_dml_errors exception;
    PRAGMA EXCEPTION_INIT(e_dml_errors, -24381);

    e_external_library_not_found exception;
    PRAGMA EXCEPTION_INIT(e_external_library_not_found, -6520);

    e_fetched_value_is_null exception;
    PRAGMA EXCEPTION_INIT(e_fetched_value_is_null, -1405);

    e_password_expired exception;
    PRAGMA EXCEPTION_INIT(e_password_expired, -20017);

    e_invalid_year exception;
    PRAGMA EXCEPTION_INIT(e_invalid_year, -1841);

    e_need_original_record exception;
    PRAGMA EXCEPTION_INIT(e_need_original_record, -20018);

    procedure raise_error(
        i_error             in      com_api_type_pkg.t_name
      , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
      , i_env_param2        in      com_api_type_pkg.t_name             default null
      , i_env_param3        in      com_api_type_pkg.t_name             default null
      , i_env_param4        in      com_api_type_pkg.t_name             default null
      , i_env_param5        in      com_api_type_pkg.t_name             default null
      , i_env_param6        in      com_api_type_pkg.t_name             default null
      , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
      , i_object_id         in      com_api_type_pkg.t_long_id          default null
      , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
      , i_mask_error        in      com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
      , i_container_id      in      com_api_type_pkg.t_short_id         default null
    );

    procedure raise_fatal_error(
        i_error             in      com_api_type_pkg.t_name
      , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
      , i_env_param2        in      com_api_type_pkg.t_name             default null
      , i_env_param3        in      com_api_type_pkg.t_name             default null
      , i_env_param4        in      com_api_type_pkg.t_name             default null
      , i_env_param5        in      com_api_type_pkg.t_name             default null
      , i_env_param6        in      com_api_type_pkg.t_name             default null
      , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
      , i_object_id         in      com_api_type_pkg.t_long_id          default null
      , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
      , i_container_id      in      com_api_type_pkg.t_short_id         default null
    );

    function is_application_error (
        code            in number
    ) return com_api_type_pkg.t_boolean;

    function is_fatal_error (
        code            in number
    ) return com_api_type_pkg.t_boolean;

    function get_last_error_id return com_api_type_pkg.t_long_id;

    function get_last_error return com_api_type_pkg.t_name;

    function get_last_message return com_api_type_pkg.t_text;

    function get_last_trace_text return com_api_type_pkg.t_text;

    function get_error_code(
        i_error_code        in      com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_name;

    procedure set_mask_error (
        i_mask_error        in      com_api_type_pkg.t_boolean
    );

    function get_mask_error return com_api_type_pkg.t_boolean;

end com_api_error_pkg;
/
