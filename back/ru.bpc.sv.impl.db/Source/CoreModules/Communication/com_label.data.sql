-- Errors
insert into com_label (id, name, label_type, module_code, env_variable) values (10004453, 'STANDARD_VERSION_ALREADY_EXISTS', 'ERROR', 'PRC', 'STANDARD_ID, VERSION_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004390, 'CMN_DUPLICATE_STANDARD', 'ERROR', 'CMN', 'APPLICATION_PLUGIN, STANDARD_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004070, 'STANDARD_VERSION_OBJ_ALREADY_EXISTS', 'ERROR', 'CMN', 'ENTITY_TYPE, OBJECT_ID, VERSION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003845, 'STANDARD_VERSION_IN_USE', 'ERROR', 'CMN', 'ID, CHECK_ENTITY, CHECK_OBJECT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003822, 'STANDARD_BEING_USED_FOR_ENTITIES', 'ERROR', 'CMN', 'ENTITY_TYPE, STANDARD_ID')
/
insert into com_label (id, name, label_type, module_code) values (10009268, 'DEVICE_ALREADY_REGISTERED', 'ERROR', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10000012, 'INCORRECT_PARAM_VALUE_DATA_TYPE', 'ERROR', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10000146, 'STANDARD_PARAM_NOT_EXISTS', 'ERROR', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10008833, 'COMMUNICATION_DEVICE_NETWORK_FOUND', 'ERROR', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10008834, 'COMMUNICATION_DEVICE_TERMINAL_FOUND', 'ERROR', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10009326, 'CANNOT_MODIFY_ENABLED_CMN_TCP', 'ERROR', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10009338, 'CANNOT_REMOVE_ENABLED_CMN_TCP', 'ERROR', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10009882, 'COMMUNICATION_STANDARD_APPL_PLUGIN_NOT_DEFINED', 'ERROR', 'CMN')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009883, 'STANDARD_PARAMETER_ALREADY_EXIST', 'ERROR', 'CMN', 'STANDARD_PARAMETER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009884, 'NOT_FOUND_VALUE_OWNER', 'ERROR', 'CMN', 'PARAMETER_NAME,PARAMETER_VALUE,STANDARD_ID,ENTITY_TYPE,OBJECT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009885, 'TOO_MANY_VALUE_OWNERS', 'ERROR', 'CMN', 'PARAMETER_NAME,PARAMETER_VALUE,STANDARD_ID,ENTITY_TYPE,OBJECT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010087, 'KEY_TYPE_FOR_KEY_STANDARD_NOT_FOUND', 'ERROR', 'CMN', 'STANDARD_ID, STANDARD_KEY')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003338, 'TCPIP_CHECK_RANGE', 'ERROR', 'CMN', 'TCP_IP_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003706, 'TCPIP_LOCAL_PORT_ALREADY_USED', 'ERROR', 'CMN', 'LOCAL_PORT, TCP_IP_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003707, 'TCPIP_EMPTY_REMOTE_ADDRESS', 'ERROR', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003708, 'TCPIP_EMPTY_LOCAL_PORT', 'ERROR', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003898, 'STANDARD_VERSION_NOT_FOUND_FOR_OBJECT', 'ERROR', 'CMN', 'STANDARD_ID, ENTITY_TYPE, OBJECT_ID, EFF_DATE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004561, 'RESP_CODE_NOT_UNIQUE', 'ERROR', 'CMN', 'RESP_CODE, STANDARD_ID, RESP_REASON, DEVICE_CODE_OUT')
/

-- Captions
insert into com_label (id, name, label_type, module_code) values (10001780, 'cmn.resp_codes', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001781, 'cmn.resp_code', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001782, 'cmn.standard', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001783, 'cmn.device_code_in', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001784, 'cmn.device_code_out', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001785, 'cmn.manufacturer', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001786, 'cmn.edit_mapping', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001787, 'cmn.new_mapping', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001789, 'cmn.resp_code_map_deleted', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001790, 'cmn.resp_code_map_saved', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001793, 'cmn.device_type', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001804, 'cmn.code_out_for_rc_exists', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001805, 'cmn.rc_for_code_in_exists', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001806, 'cmn.incorrect_device', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001886, 'cmn.comm_standards', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001887, 'cmn.app_plugin', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001888, 'cmn.edit_standard', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001889, 'cmn.new_standard', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001890, 'cmn.standard_deleted', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001891, 'cmn.standard_saved', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001892, 'cmn.standard_param', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001939, 'cmn.parameter_saved', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001940, 'cmn.parameter_deleted', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001941, 'cmn.standard_id', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001942, 'cmn.data_type', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001943, 'cmn.new_parameter', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001944, 'cmn.edit_parameter', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001945, 'cmn.std_type', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10001981, 'cmn.comm_params', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002181, 'cmn.tcp_ips', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002182, 'cmn.tcp_ip', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002184, 'cmn.remote_address', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002185, 'cmn.local_port', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002186, 'cmn.remote_port', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002187, 'cmn.initiator', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002188, 'cmn.format', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002189, 'cmn.keep_alive', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002190, 'cmn.new_tcp_ip', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002191, 'cmn.edit_tcp_ip', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002194, 'cmn.tcp_ip_saved', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002195, 'cmn.tcp_ip_deleted', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002197, 'cmn.device', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002208, 'cmn.tcp_devices', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002209, 'cmn.comm_plugin', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002210, 'cmn.device_name', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002211, 'cmn.edit_tcp_device', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002212, 'cmn.new_tcp_device', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10002422, 'cmn.edit_param_value', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10006594, 'cmn.no_template_for_profile', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10006598, 'cmn.new_profile', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10006608, 'cmn.response_codes_mapping', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10006624, 'cmn.profile_saved', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10006634, 'cmn.profiles', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10006635, 'cmn.app_online_plugin', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10006639, 'cmn.edit_profile', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10006643, 'cmn.profile_deleted', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10008682, 'cmn.code_in_for_rc_exists', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10009357, 'cmn.enabled', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10009358, 'cmn.monitor_connection', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10009359, 'cmn.confirm_enable_device', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10009360, 'cmn.confirm_disable_device', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10009366, 'cmn.connections', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10009367, 'cmn.status_ok', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code) values (10009368, 'cmn.status_ok_descr', 'CAPTION', 'CMN')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010011, 'cmn.key_types_mapping', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010178, 'cmn.key_type', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010179, 'cmn.standard_key_type', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010194, 'cmn.new_key_type_mapping', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010195, 'cmn.edit_key_type_mapping', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010832, 'cmn.key_types', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010910, 'cmn.version_number', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010911, 'cmn.edit_version', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010912, 'cmn.edit_standard_version', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010913, 'cmn.new_version_parameter', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010914, 'cmn.version_deleted', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010915, 'cmn.versions', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010916, 'cmn.version_saved', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010917, 'cmn.version_parameter_deleted', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010918, 'cmn.new_standard_version', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010919, 'cmn.new_version', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010920, 'cmn.version', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010921, 'cmn.version_parameter_saved', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010939, 'cmn.set_version', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010959, 'cmn.new_device', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010960, 'cmn.edit_device', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010961, 'cmn.tcp_device', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010962, 'cmn.devices', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010975, 'cmn.standards', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003216, 'cmn.start_advices_trms', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003217, 'cmn.stop_advices_trms', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003218, 'cmn.echo_test', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003334, 'cmn.multiple_connection', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003475, 'cmn.standard_version', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003476, 'cmn.standard_versions', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003909, 'STANDARD_VERSION_NOT_FOUND', 'ERROR', 'CMN', 'STANDARD_ID, VERSION_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003911, 'cmn.move_up', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003912, 'cmn.move_down', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003913, 'cmn.reorder', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004563, 'cmn.resp_reason', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005152, 'INTERFACE_NOT_FOUND_FOR_OBJECT', 'ERROR', 'CMN', 'ENTITY_TYPE, OBJECT_ID, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005313, 'cmn.s', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005487, 'DEVICE_NAME_ALREADY_EXISTS', 'ERROR', 'PMO', 'TEXT, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005517, 'DUPLICATE_MAPPING_KEY_TYPE', 'ERROR', 'CMN', 'STANDARD_KEY_TYPE, KEY_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005518, 'DUPLICATE_STANDARD_PARAMETER_NAME', 'ERROR', 'CMN', 'TEXT, STANDARD_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005524, 'KEY_ALREADY_USED', 'ERROR', 'CMN', 'ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005525, 'STANDARD_VERSION_ALREADY_USE', 'ERROR', 'CMN', 'ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011161, 'STANDARD_KEY_TYPE_FOR_SYSTEM_KEY_NOT_FOUND', 'ERROR', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011909, 'cmn.send_fee_collection', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011897, 'cmn.send_credit_adjustment', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011899, 'cmn.send_debit_adjustment', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011905, 'cmn.send_funds_disbursement', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011907, 'cmn.send_representment', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005667, 'cmn.set_parameters', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005669, 'cmn.set_standard', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005671, 'cmn.standard_already_added', 'CAPTION', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005793, 'CMN_DEVICE_NOT_FOUND', 'ERROR', 'CMN', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011596, 'STANDARD_PARAM_NOT_FOUND', 'ERROR', 'CMN', 'PARAM_NAME, INST_ID, STANDARD_ID, HOST_ID')
/
