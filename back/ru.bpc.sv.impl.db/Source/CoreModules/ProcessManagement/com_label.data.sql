-- Errors
insert into com_label (id, name, label_type, module_code, env_variable) values (10004452, 'UNABLE_CHANGE_PROCESS_PARAMETER', 'ERROR', 'PRC', 'PROCESS_ID, CONTAINER_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003840, 'PARAM_ALREADY_EXISTS', 'ERROR', 'PRC', 'PARAM_ID, PROCESS_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003834, 'PROCESS_ERROR_OVERLIMIT', 'ERROR', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003816, 'SEMAPHORE_ALREADY_EXISTS', 'ERROR', 'PRC', 'ID, NAME')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003813, 'HOST_DEVICE_STANDARD_MISMATCH', 'ERROR', 'PRC', 'HOST_MEMBER_ID, HOST_STANDARD_ID, DEVICE_ID, STANDARD_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003812, 'PARAM_NOT_FOUND', 'ERROR', 'PRC', 'PARAM_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003399, 'PRC_CYCLIC_TREE_FOUND', 'ERROR', 'PRC', 'CONTAINER_PROCESS_ID, PROCESS_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003297, 'CONTAINER_EQUAL_TO_PROCESS', 'ERROR', 'PRC', 'CONTAINER_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010246, 'TOO_MANY_FILES_FOUND', 'ERROR', 'PRC', 'FILE_TYPE, FILE_PURPOSE, SESSION_ID, PROCESS_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010203, 'PARAMETER_ORDER_NOT_UNIQUE', 'ERROR', 'PRC', 'PROCESS_ID, DISPLAY_ORDER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009877, 'PROCESS_NAME_ALREADY_USED', 'ERROR', 'PRC', 'INST_ID, NAME')
/
insert into com_label (id, name, label_type, module_code) values (10002058, 'PROCESS_IS_EXTERNAL', 'FATAL', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10002147, 'PRC_BIND_PARAM_NOT_FOUND', 'ERROR', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10003130, 'FILE_PURPOSE_NOT_FOUND', 'ERROR', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008659, 'SESSION_NOT_FOUND', 'ERROR', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008660, 'FILE_ATTRIBUTE_NOT_FOUND', 'ERROR', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008761, 'PROCESS_STARTED', 'INFO', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008762, 'PROCESS_FINISHED', 'INFO', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008773, 'ENTITY_TYPE_NOT_SUPPORTED', 'ERROR', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10009746, 'PROCESS_ALREADY_USED', 'ERROR', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10009774, 'EXEC_ORDER_ALREADY_EXIST', 'ERROR', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10009775, 'PARAMETER_NAME_NOT_UNIQUE', 'ERROR', 'PRC')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010182, 'PROCEDURE_NAME_ALREADY_USED', 'ERROR', 'PRC', 'PROCEDURE_NAME')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010230, 'GROUP_PROCESS_ALREADY_EXISTS', 'ERROR', 'PRC', 'GROUP_ID, PROCESS_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003189, 'CANT_REMOVE_ACTIVE_SEMAPHORE', 'ERROR', 'PRC', 'GROUP_NAME')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003193, 'REMOVE_ACTIVE_CONTAINER', 'ERROR', 'PRC', 'PROCEDURE_LABEL, START_TIME, USER_NAME')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003194, 'REMOVE_SCHEDULE_CONTAINER', 'ERROR', 'PRC', 'PROCESS_ID, TASK_LABEL')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003282, 'NO_PERMISSION_TO_RUN_PROCESS', 'ERROR', 'PRC', 'PROCESS_ID, USER_NAME')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004377, 'PROCESS_IS_LOCKED', 'ERROR', 'PRC', 'SEMAPHORE_NAME')
/
-- Captions
insert into com_label (id, name, label_type, module_code) values (10000474, 'process.container_id', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000476, 'process.session_id', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000478, 'process.process_start_date', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000481, 'process.process_end_date', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000483, 'process.main_session_id', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000485, 'process.main_container_id', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000487, 'process.process_name', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000489, 'process.process_state', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000565, 'process.end_date', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000568, 'process.thread_number', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000569, 'process.trace_level', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000571, 'process.trace_text', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000572, 'process.trace_timestamp', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000573, 'process.user_id', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000580, 'process.start_time', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000583, 'process.current_time', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000585, 'process.end_time', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000587, 'process.estimated_count', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000588, 'process.current_count', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000590, 'process.processed_total', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000592, 'process.excepted_total', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000599, 'process.stat', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10000602, 'process.trace', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008086, 'process.procedure_name', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008087, 'process.roles', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008088, 'process.process', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008089, 'process.purpose', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008090, 'process.parallel_allowed', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008092, 'process.edit_container_process', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008093, 'process.every_hour', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008094, 'process.edit_process_parameter', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008095, 'process.schedule', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008097, 'process.every_minute', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008099, 'process.block_run', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008100, 'process.last_used', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008101, 'process.crc_offset', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008102, 'process.cron_string', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008104, 'process.repeat', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008105, 'process.error_threshold', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008107, 'process.edit_task', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008109, 'process.format', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008110, 'process.start', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008113, 'process.result_code', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008115, 'process.every_day', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008117, 'process.new_file', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008118, 'process.file', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008119, 'process.period_error_time', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008120, 'process.crc_position', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008121, 'process.edit_container', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008122, 'process.interval', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008123, 'process.crc_crlf', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008126, 'process.check_result', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008127, 'process.records_processed', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008128, 'process.role', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008130, 'process.format_version', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008132, 'process.upload_empty_file', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008133, 'process.start_date', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008135, 'process.saver_class', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008136, 'process.set_value', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008137, 'process.records_rejected', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008138, 'process.new_file_attribute', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008139, 'process.crc_algorithm', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008141, 'process.new_container', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008142, 'process.crc_header', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008143, 'process.every_month', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008144, 'process.edit_parameter', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008145, 'process.converter_class', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008146, 'process.delete_value', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008147, 'process.days_of_week', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008149, 'process.value_setup', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008150, 'process.semaphore_name', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008151, 'process.days_of_month', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008152, 'process.is_parallel', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008153, 'process.edit_file_attribute', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008154, 'process.container', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008155, 'process.edit_file', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008156, 'process.add_process_to_container', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008157, 'process.error_percent', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008158, 'process.new_task', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008160, 'process.task', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008161, 'process.monitoring', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008162, 'process.name_algorithm', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008164, 'process.file_attribute', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008166, 'process.name_mask', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008168, 'process.new_group', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008169, 'process.edit_process', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008170, 'process.default_value', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008171, 'process.xslt_source', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008172, 'process.edit_group', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008173, 'process.add_task', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008174, 'process.process_finished', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008175, 'process.add_param_to_process', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008176, 'process.new_parameter', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008177, 'process.container_process_id', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008178, 'process.exec_order', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008179, 'process.parallel', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008180, 'process.xsd_source', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008181, 'process.location', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008182, 'process.external', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008183, 'process.xml', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008184, 'process.new_process', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008185, 'process.error_active_time', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008186, 'process.encoding', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008958, 'process.add_container', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10008959, 'process.need_format', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10009314, 'process.process_logs', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10009315, 'process.records_excepted', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10009320, 'process.error_limit', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10009321, 'process.error_limit_abbr', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10009322, 'process.track_threshold', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code) values (10009323, 'process.track_threshold_abbr', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010824, 'process.is_active', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010927, 'process.file_type', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010928, 'process.processes', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010871, 'process.thread_count', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010872, 'process.hierarchy', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010873, 'process.launch_parameters', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003284, 'process.is_tar', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003285, 'process.is_zip', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003286, 'process.character_set', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003294, 'process.file_format', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003588, 'process.thread', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003589, 'process.user_sessions', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003720, 'process.containers', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003721, 'process.launch', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003722, 'process.launch_in_schedule', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003723, 'process.generate_incoming', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003724, 'process.start_schedule', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003725, 'process.stop_schedule', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003726, 'process.invoke', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003727, 'process.params', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003728, 'process.threads', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003729, 'process.process_groups', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003876, 'process.level', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003878, 'process.add_process_to_group', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004374, 'process.file_generation_error', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004381, 'process.update_table_every', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004383, 'process.seconds', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004454, 'process.progress', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004586, 'process.wrong_class_name', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004588, 'process.class_name', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004899, 'process.load_priority', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004900, 'process.signature_type', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004901, 'process.encryption_plugin', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004924, 'process.file_encryption_key', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004925, 'process.add_file_encryption_key', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004926, 'process.modify_file_encryption_key', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005030, 'PROCESS_IS_IN_PROGRESS', 'ERROR', 'PRC', 'PROCESS_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005031, 'process.month_sched_req', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005032, 'process.hour_sched_req', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005033, 'process.day_sched_req', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005034, 'process.minute_sched_req', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005035, 'process.dates_are_not_in_months', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005036, 'process.sched_not_executable', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005037, 'process.dates_are_not_in_month', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005041, 'process.ignore_file_errors', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005042, 'process.ignore_file_errors_desc', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005059, 'process.rejected_total', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005065, 'process.found_unprocessed_files', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005069, 'process.files_found', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005071, 'process.unpacking_file', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005073, 'process.files_extracted', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005075, 'process.opening_file', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005077, 'process.sig_verif_failed', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005079, 'process.ignore_file_errors_continue_upload', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005081, 'process.unprocessed_file_move_failed', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005083, 'process.no_sign_for_file', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005085, 'process.looking_for_files', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005087, 'process.incoming_files_result', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005144, 'process.file_moved_from_directory', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005142, 'process.download', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005377, 'process.encryption_type', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005379, 'process.folder_path', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005381, 'process.directory_changed_unencrypted', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005386, 'DIRECTORY_NOT_FOUND', 'ERROR', 'PRC', 'ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005421, 'process.parallel_degree', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005448, 'FILE_SAVER_ALREADY_USED', 'ERROR', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005460, 'process.source', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005461, 'process.new_file_saver', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005462, 'process.edit_file_saver', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005480, 'process.use_custom_value', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005539, 'msg.javax.faces.validator.LengthValidator.MAXIMUM', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005578, 'FILE_NAME_DUPLICATED_IN_SESSION', 'ERROR', 'PRC', 'FILE_NAME')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005580, 'FILE_NAME_ALREADY_EXIST', 'ERROR', 'PRC', 'FILE_NAME')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005623, 'process.is_file_name_unique', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009370, 'common.comments', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009371, 'common.save_patch_to_local_machine', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009373, 'common.commit_files', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009374, 'form.commit', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009375, 'msg.confirm_commit', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009376, 'msg.notify_commit', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009377, 'msg.notify_file_locked', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011782, 'process.is_file_required', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011521, 'SESSION_FILE_NOT_FOUND', 'ERROR', 'PRC', NULL)
/
delete com_label where id = 10003193
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011869, 'process.new_directory', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011872, 'process.edit_directory', 'CAPTION', 'PRC', NULL)
/
update com_label set env_variable = 'SESS_FILE_ID' where id = 10011521
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006932, 'CONTAINER_NOT_FOUND', 'ERROR', 'PRC', 'CONTAINER_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006934, 'CONTAINER_ELEMENT_DOES_NOT_EXIST', 'ERROR', 'PRC', 'CONTAINER_ID, ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005681, 'process.is_incoming', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005683, 'process.is_returned', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005685, 'process.is_invalid', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005713, 'process.central_proc_date', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005795, 'process.queue_name', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005822, 'process.time_wait', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005831, 'process.ws_err_code_0', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005833, 'process.ws_err_code_1', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005835, 'process.ws_err_code_2', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005837, 'process.ws_err_code_3', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005839, 'process.ws_err_code_4', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005841, 'process.ws_err_code_5', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005845, 'process.ws_err_code_6', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005847, 'process.ws_err_code_7', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005849, 'process.ws_err_code_8', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005851, 'process.ws_err_code_9', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005853, 'process.ws_err_code_10', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005855, 'process.ws_err_code_11', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005857, 'process.ws_err_code_12', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005859, 'process.ws_err_code_13', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005861, 'process.ws_err_code_14', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005863, 'process.ws_err_code_15', 'CAPTION', 'PRC', NULL)
/
update com_label set name='process.ws_err_code_100' where id = 10005835
/
update com_label set name='process.ws_err_code_101' where id= 10005837
/
update com_label set name='process.ws_err_code_102' where id= 10005839
/
update com_label set name='process.ws_err_code_103' where id= 10005841
/
update com_label set name='process.ws_err_code_104' where id=10005845
/
update com_label set name='process.ws_err_code_105' where id=10005847
/
update com_label set name='process.ws_err_code_106' where id=10005849
/
update com_label set name='process.ws_err_code_200' where id=10005851
/
update com_label set name='process.ws_err_code_201' where id=10005853
/
update com_label set name='process.ws_err_code_202' where id=10005855
/
update com_label set name='process.ws_err_code_400' where id=10005857
/
update com_label set name='process.ws_err_code_401' where id=10005859
/
update com_label set name='process.ws_err_code_402' where id=10005861
/
update com_label set name='process.ws_err_code_403' where id=10005863
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009472, 'process.ws_err_code_404', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009474, 'process.ws_err_code_405', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009476, 'process.ws_err_code_406', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009478, 'process.ws_err_code_407', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007033, 'process.stop_fatal_exc', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009515, 'process.ws_err_code_107', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009520, 'process.ws_err_code_408', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009534, 'TOO_LONG_STRING_FOR_FILE_RAW_DATA', 'ERROR', 'PRC', 'SESSION_FILE_ID, RECORD_NUMBER, LENGTH')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009547, 'FILE_NAME_ALGORITHM_IS_REQUIRED', 'ERROR', 'PRC', 'PROCESS_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009592, 'process.ws_err_code_204', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007043, 'PRC_IMPORT_FAILED', 'ERROR', 'PRC', 'SESSION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10012030, 'NO_ONE_PARAM_EXISTS', 'ERROR', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10012031, 'NO_ONE_GROUP_PARAM_EXISTS', 'ERROR', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code) values (10004241, 'process.interrupt_threads', 'CAPTION', 'PRC')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008489, 'process.is_cleanup_data', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011570, 'EVENT_TYPE_NOT_FOUND_FOR_FILE_SETS', 'ERROR', 'PRC', 'FILE_PURPOSE, STATUS')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007567, 'ERROR_ON_READING_FILE', 'ERROR', 'PRC', 'RECORD_NUMBER, FILE_NAME')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10002548, 'RUNNING_PROCESS_USES_MODIFIER', 'ERROR', 'PRC', 'PROCESS_ID')
/
update com_label set env_variable = 'PROCESS_ID, SID, SERIAL#, SESSION_ID, THREAD_NUMBER, CONTAINER_ID' where id = 10005030
/
update com_label set env_variable = 'ENTITY_TYPE' where id = 10008773
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008011, 'process.records_count', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014216, 'FILE_NAME_AND_FILE_LOCATION_ARE_NULL', 'ERROR', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013322, 'process.process_description', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013327, 'process.measure', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013471, 'msg.container_file_missing', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013488, 'process.merge_file_mode', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013490, 'process.base_source', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013491, 'process.post_source', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013568, 'NEED_MULTI_THREAD_MODE', 'ERROR', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013573, 'process.duration', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013575, 'process.rating', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013577, 'process.actual_speed', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013579, 'process.min_speed', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013581, 'process.speed_percent', 'CAPTION', 'PRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013583, 'process.max_duration', 'CAPTION', 'PRC', NULL)
/
