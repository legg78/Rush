-- Errors
insert into com_label (id, name, label_type, module_code) values (10001728, 'MATCH_CONDITION_INCLUDED_IN_LEVEL', 'ERROR', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009048, 'OPR_CHECK_GROUP_ALREADY_USED', 'ERROR', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009165, 'ERROR_PROCESSING_OPERATION', 'ERROR', 'OPR')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003628, 'OPERATION_ACCOUNT_NOT_FOUND', 'ERROR', 'OPR', 'ACCOUNT_NUMBER, INSTITUTION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003629, 'OPERATION_ENTITY_NOT_AVAILABLE', 'ERROR', 'OPR', 'ENTITY_TYPE, ACCOUNT_NUMBER, PARTY_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003653, 'ERROR_PROCESSING_OPERATION_FATAL', 'ERROR', 'OPR', 'OPERATION_ID, SQLERRM')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003654, 'AUTH_ENTITY_NOT_AVAILABLE', 'ERROR', 'OPR', 'ENTITY_TYPE, ACCOUNT_NAME, PARTY_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003655, 'ATTEMPT_TO_SUBTRACT_DIFFERENT_CURRENCY', 'ERROR', 'OPR', 'CURRENCY1, CURRENCY2')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003656, 'ATTEMPT_TO_ADD_DIFFERENT_CURRENCY', 'ERROR', 'OPR', 'CURRENCY1, CURRENCY2')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003657, 'SET_OPERATION_NOT_AVAILABLE', 'ERROR', 'OPR', 'ID, OPERATION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004005, 'UNKNOWN_ISSUING_NETWORK', 'ERROR', 'OPR', 'CARD_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004006, 'ACCOUNT_RESTRICTED', 'ERROR', 'OPR', 'ACCOUNT_NUMBER, CARD_INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004007, 'UNKNOWN_CHECK_TYPE', 'ERROR', 'OPR', 'CHECK_TYPE, MSG_TYPE, OPER_TYPE, PARTY_TYPE, INST_ID, NETWORK_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004008, 'UNKNOWN_CUSTOMER', 'ERROR', 'OPR', 'ACCOUNT_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004009, 'UNKNOWN_MERCHANT', 'ERROR', 'OPR', 'MERCHANT_NUMBER, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004010, 'UNKNOWN_TERMINAL', 'ERROR', 'OPR', 'INST_ID, MERCHANT_NUMBER, MERCHANT_ID, TERMINAL_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004011, 'UNKNOWN_DESTINATION_NETWORK', 'ERROR', 'OPR', 'CARD_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004012, 'UNKNOWN_INSTITUTION_NETWORK', 'ERROR', 'OPR', 'INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004435, 'ACQ_INST_NOT_FOUND', 'ERROR', 'OPR', 'OPERATION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004566, 'WRONG_BALANCE_TYPE_SPECIFIED', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004567, 'BALANCE_OF_DIFFERENT_CURRENCY', 'ERROR', 'OPR', NULL)
/

-- Captions
insert into com_label (id, name, label_type, module_code) values (10000658, 'opr.actions', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000660, 'opr.exec_order', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000662, 'opr.rule_set', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000666, 'opr.procedure', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000670, 'opr.edit_action', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000672, 'opr.edit_rule_set', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000674, 'opr.new_rule_set', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000720, 'opr.procedures', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000722, 'opr.proc_name', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000728, 'opr.oper_type', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000730, 'opr.msg_type', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000732, 'opr.sttl_type', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000733, 'opr.reversal', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000735, 'opr.oper_purpose', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000737, 'opr.src_inst', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000739, 'opr.dest_inst', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000742, 'opr.terminal_type', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000744, 'opr.operation_currency', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000747, 'opr.sttl_currency', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000750, 'opr.process_stage', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000754, 'opr.rules', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10000757, 'opr.new_action', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001112, 'opr.rule_sets', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001579, 'opr.operations', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001581, 'opr.card_number', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001583, 'opr.host_date_from', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001584, 'opr.host_date_to', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001585, 'opr.operation_id', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001587, 'opr.host_date_n_time', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001588, 'opr.operation_amount', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001589, 'opr.operation_type', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001590, 'opr.issuer_data', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001591, 'opr.acquirer_data', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001592, 'opr.settlement', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001593, 'opr.accounting', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001801, 'opr.action_saved', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001802, 'opr.action_deleted', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10001803, 'opr.exec_order_exists', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10002424, 'opr.procedure_param', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10002425, 'opr.edit_procedure_param', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10002426, 'opr.new_procedure_param', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10002427, 'opr.new_procedure', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10002428, 'opr.edit_procedure', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007905, 'opr.level_condition_added', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007906, 'opr.edit_proc_tmpl', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007910, 'opr.condition', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007913, 'opr.match_levels', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007918, 'opr.new_rule', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007919, 'opr.account_currency', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007921, 'opr.oper_reason', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007923, 'opr.conditions', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007925, 'opr.new_condition', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007928, 'opr.add_condition', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007934, 'opr.iss_inst', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007937, 'opr.new_proc_tmpl', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007939, 'opr.match_condition_saved', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007941, 'opr.edit_match_level', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007943, 'opr.match_condition_deleted', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007944, 'opr.match_level_saved', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007948, 'opr.level_condition_removed', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007951, 'opr.match_level_deleted', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007953, 'opr.acq_inst', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007954, 'opr.edit_condition', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007957, 'opr.processing_templates', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007958, 'opr.new_match_level', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007959, 'opr.match_conditions', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10007966, 'opr.edit_rule', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009060, 'opr.create_adjusment', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009069, 'opr.adjusment', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009079, 'opr.account_number', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009120, 'opr.check_type', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009121, 'opr.edit_check', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009122, 'opr.new_check', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009123, 'opr.check_groups', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009124, 'opr.check_group', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009125, 'opr.edit_check_group', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009126, 'opr.new_check_group', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009127, 'opr.check_selections', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009128, 'opr.party_type', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009129, 'opr.checks', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009130, 'opr.edit_check_selection', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009131, 'opr.new_check_selection', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009132, 'opr.network', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009133, 'opr.entity_oper_types', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009134, 'opr.invoke_method', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009135, 'opr.reason_lov', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009136, 'opr.edit_entity_oper_type', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009137, 'opr.new_entity_oper_type', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009218, 'opr.create_manual_operation', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code) values (10009219, 'opr.new_manual_operation', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010128, 'opr.status_reason', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003461, 'opr.auth', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003462, 'opr.amount_from', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003463, 'opr.amount_to', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003464, 'opr.auth_id', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003465, 'opr.oper_date', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003466, 'opr.from_network', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003467, 'opr.to_network', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003468, 'opr.auth_code', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003469, 'opr.rrn', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003470, 'opr.sttl_amount', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003471, 'opr.sttl_date', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003590, 'opr.new_match_condition', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003591, 'opr.edit_match_condition', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003713, 'opr.client_id_type', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003714, 'opr.client_id_value', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003715, 'opr.destination', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004292, 'UNDEFINED_PARTICIPANT_SPLIT_HASH', 'ERROR', 'OPR', 'PARTICIPANT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004349, 'opr.payment_order_id', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004364, 'opr.operation', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004598, 'opr.original_id', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004599, 'opr.acq_inst_bin', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004600, 'opr.forw_inst_bin', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004601, 'opr.originator_refnum', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004602, 'opr.network_refnum', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004603, 'opr.oper_count', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004604, 'opr.oper_request_amount', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004605, 'opr.oper_amount_alogrithm', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004606, 'opr.oper_currency', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004607, 'opr.oper_cashback_amount', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004608, 'opr.oper_replacement_amount', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004609, 'opr.oper_surcharge_amount', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004610, 'opr.unhold_date', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004611, 'opr.dispute_id', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004612, 'opr.payment_host', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004613, 'opr.forced_processing', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004614, 'opr.match_status', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004615, 'opr.match_id', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004616, 'opr.participant', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004617, 'opr.participants', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004836, 'PARTICIPANT_WITH_OPER_ALREADY_EXIST', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004847, 'opr.select_rule_set', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004849, 'opr.register_new_rule_set', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004851, 'opr.rule_set_mode', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005094, 'EVENT_TYPE_NOT_CORRESPOND_TO_ENTITY_TYPE', 'ERROR', 'OPR', 'EVENT_TYPE,ENTITY_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005097, 'opr.processing_stage', 'CAPTION', 'OPR', NULL)
/

insert into com_label (id, name, label_type, module_code, env_variable) values (10005109, 'ATM_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005111, 'CHRONOPAY_GATEWAY_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005115, 'CYBERPLAT_BASED_REQUESTS', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005117, 'E_PAY_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005119, 'ISO8583POS_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005121, 'MASTERCARD_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005123, 'VISA_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005125, 'VISA_SMS_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005127, 'WAY4_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005129, 'MASTERCARD_CLEARING_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005131, 'VISA_CLEARING_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005133, 'AUTHORIZATIONS_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005135, 'SVIP_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005137, 'TAGS', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005151, 'opr.messages', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005159, 'WRONG_FEE_TYPE_SPECIFIED', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005163, 'opr.disputes', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005209, 'opr.clone_rule_set', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005211, 'opr.target', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005223, 'opr.additional_amounts', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005288, 'PAYMENT_ORDER_NOT_FOUND', 'ERROR', 'OPR', 'PAYMENT_ORDER_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005305, 'WRONG_MESSAGE_TYPE', 'ERROR', 'OPR', 'OPER_ID, MSG_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005392, 'opr.initiator', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005394, 'opr.select_oper_type', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005470, 'BAD_REVERSAL_CURRENCY', 'ERROR', 'OPR', 'ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005479, 'CONDITION_ALREADY_EXISTS_IN_INST', 'ERROR', 'OPR', 'TEXT, INSTITUTION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005475, 'opr.reason_dict', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005476, 'opr.new_reason_mapping', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005477, 'opr.edit_reason_mapping', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005483, 'opr.reversed', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005563, 'opr.terminal_array_id', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005565, 'opr.merchant_array_id', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005574, 'PERIOD_GREATER_60', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005576, 'NOT_ENOUGH_DATA_TO_FIND_OPERATIONS', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011245, 'OPERATION_RULE_TEMPLATE_NOT_UNIQUE', 'ERROR', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011273, 'BASE24_ATM_FINANCIAL_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011274, 'BASE24_POS_FINANCIAL_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011275, 'BASE24_ATM_BALANCING_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011276, 'BASE24_ATM_CASH_ADJUSTMENT_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011277, 'BASE24_ATM_SETTLEMENT_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011155, 'USE_DIFFERENT_CURRENCY_FOR_PROPORTIONAL_AMOUNT', 'ERROR', 'OPR', 'CURRENCY1, CURRENCY2')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011195, 'DIVISOR_IS_ZERO_FOR_PROPORTIONAL_AMOUNT', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011347, 'opr.issuer_network_short', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011348, 'opr.issuer_network', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011349, 'opr.acquirer_network_short', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011350, 'opr.acquirer_network', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011351, 'opr.card_network_short', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011352, 'opr.card_network', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011400, 'ISO8583BIC_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011408, 'MASTERCARD_CLEARING_ADDENDUM_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011409, 'ACI_ATM_FIN_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011410, 'ACI_POS_FIN_MESSAGE', 'INFO', 'OPR', NULL)
/
delete com_label where id = 10011443
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011443, 'END_DATE_LESS_THAN_START_DATE', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011466, 'ORIGINAL_OPERATION_IS_NOT_FOUND', 'ERROR', 'OPR', 'OPER_ID, ORIGINATOR_REFNUM, CARD_NUMBER, OPER_DATE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011493, 'BASEII_DATA_NOT_FOUND', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011500, 'IPM_DATA_NOT_FOUND', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011504, 'AUTH_DATA_NOT_FOUND', 'ERROR', 'OPR', NULL)
/
delete com_label where id = 10005479
/
delete com_label where id = 10001728
/
delete com_label where id = 10005288
/
delete com_label where id = 10005305
/
insert into com_label (id, name, label_type, module_code) values (10001728, 'MATCH_CONDITION_INCLUDED_IN_LEVEL', 'ERROR', 'OPR')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005479, 'CONDITION_ALREADY_EXISTS_IN_INST', 'ERROR', 'OPR', 'TEXT, INSTITUTION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011874, 'SV2SV_MESSAGE', 'INFO', 'OPR', NULL)
/
delete from com_label where id = 10003628
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009411, 'TOO_MANY_TRANSACTION_FOUND', 'ERROR', 'OPR', 'OPER_ID, MACROS_TYPE, TRANSACTION_TYPE, AMOUNT_PURPOSE')
/
update com_label set env_variable = 'OPER_ID, ORIGINATOR_REFNUM, OPER_DATE, CLIENT_ID_TYPE, CLIENT_ID_VALUE' where id = 10011466
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009435, 'OPERATION_FREEZED', 'ERROR', 'OPR', 'ORIGINATOR_REFNUM')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009436, 'WRONG_PARTICIPANT_TYPE', 'ERROR', 'OPR', 'PARTY_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009437, 'OPR_CUSTOMER_NOT_FOUND', 'ERROR', 'OPR', 'CLIENT_ID_TYPE, CLIENT_ID_VALUE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009442, 'ACI_ATM_SETL_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009443, 'ACI_ATM_SETL_TTL_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009444, 'ACI_ATM_CASH_MESSAGE', 'INFO', 'OPR', NULL)
/
update com_label set env_variable = 'MERCHANT_NUMBER, INST_ID, TERMINAL_NUMBER' where id = 10004009
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011878, 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED', 'ERROR', 'OPR', 'PARAMETER_NAME')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011893, 'opr.oper_status', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005697, 'opr.acquirer_bin', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005705, 'opr.settlement_flag', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005716, 'opr.chargeback_ref_num', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005719, 'opr.spec_cond_ind', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009494, 'OPR_CHECK_ALREADY_EXIST', 'ERROR', 'OPR', 'CHECK_GROUP_ID, CHECK_TYPE, EXEC_ORDER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009501, 'AUP_TAG_NOT_FOUND', 'ERROR', 'OPR', 'TAG_NAME')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007002, 'opr.arn', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007040, 'DUPLICATE_ORIGINAL_OPERATION', 'ERROR', 'OPR', 'ORIGINATOR_REFNUM, OPER_DATE, CLIENT_ID_TYPE, CLIENT_ID_VALUE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009525, 'REFERENCE_TO_UNDEFINED_ADDITIONAL_AMOUNT', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009553, 'DUPLICATE_OPERATION', 'ERROR', 'OPR', 'EXTERNAL_AUTH_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009562, 'TRANSACTION_IS_NOT_FOUND', 'ERROR', 'OPR', 'OPER_ID, MACROS_TYPE_ID, TRANSACTION_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009601, 'OPR_STAGE_ALREADY_EXIST', 'ERROR', 'OPR', 'PROC_STAGE, PARENT_STAGE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009603, 'OPR_STAGE_NOT_FOUND', 'ERROR', 'OPR', 'PROC_STAGE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009626, 'ERROR_ROLLBACK_PROCESSING_OPERATION', 'ERROR', 'OPR', 'OPERATION_ID, STATUS, REASON')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009680, 'CUP_CLEARING_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011957, 'opr.pos_voucher_number', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011958, 'opr.pos_debit_credit', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011961, 'opr.pos_trans_type', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011963, 'opr.pos_data_code', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011965, 'opr.pos_trans_status', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011967, 'opr.pos_additional_data', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011969, 'opr.pos_emv_data', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011971, 'opr.pos_service_identifier', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011973, 'opr.pos_payment_details', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011975, 'opr.pos_service_provider_identifier', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011977, 'opr.pos_unique_number_payment', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011979, 'opr.pos_additional_amounts', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011981, 'opr.pos_svfe_trace_number', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011983, 'opr.pos_batch', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10012013, 'ORIGINAL_OPERATION_IS_NOT_SUCCESSFUL', 'ERROR', 'OPR', 'OPER_ID, OPER_STATUS, ORIGINAL_OPER_ID, ORIGINAL_OPER_STATUS')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10012023, 'VISA_CLEARING_RETRIEVAL', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001360, 'MUP_CLEARING_MESSAGE', 'INFO', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007977, 'AMOUNT_IS_NOT_SUFFICIENT_FOR_DPP_AUTO_CREATION', 'INFO', 'OPR', 'AMOUNT_VALUE, AUTOCREATION_THRESHOLD')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001379, 'DPP_AUTO_CREATION_IS_DISABLED', 'ERROR', 'OPR', 'ACCOUNT_ID, ACCOUNT_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007995, 'OPR_STAGE_NOT_UNIQUE', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code) values (10004205, 'opr.external_auth_id', 'CAPTION', 'OPR')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008463, 'ERROR_REGISTER_PIN_OFFSET', 'ERROR', 'OPR', 'OBJECT_ID, SEQ_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010726, 'NOT_ENOUGH_PARAMETERS_FOR_PARTICIPANT', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011569, 'REQUIRED_OPERATION_NOT_FOUND', 'ERROR', 'OPR', 'EXTERNAL_AUTH_ID, IS_REVERSAL')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007571, 'OPERATION_IS_NOT_MATCHED', 'ERROR', 'OPR', 'OPER_ID')
/
update com_label set env_variable = 'CLIENT_ID_TYPE, CLIENT_ID_VALUE, PAYMENT_ORDER_PARTICIPANT_TYPE, PURPOSE_ID' where id = 10009437
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10002538, 'opr.forwarding_iin', 'CAPTION', 'OPR', NULL)
/
update com_label set env_variable = 'CLIENT_ID_TYPE, CLIENT_ID_VALUE' where id = 10009437
/
update com_label set env_variable = 'OPER_ID, SQLERRM' where id = 10011504
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013371, 'opr.entity_object_type', 'CAPTION', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013454, 'OPERATION_HAS_INVALID_CARD_STATUS', 'ERROR', 'OPR', 'OPER_ID, CARD_ID, CARD_STATUS, CARD_STATE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013475, 'TOO_MANY_OPERATIONS_FOUND', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013476, 'PARTICIPANT_NOT_CREATED', 'CAPTION', 'PMO', 'OPER_ID, ENTITY_TYPE, ORDER_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013586, 'rul.due_date_limits', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013587, 'rul.add_due_date_limits', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013588, 'rul.edit_due_date_limits', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013589, 'rul.respond_due_date', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013590, 'rul.resolve_due_date', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013591, 'rul.standard_name', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013592, 'rul.direction', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013593, 'rul.is_incoming', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013594, 'rul.is_outgoing', 'CAPTION', 'COM', NULL)
/
