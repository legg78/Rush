-- Captions
insert into com_label (id, name, label_type, module_code) values (10009171, 'evt.change_status', 'CAPTION', 'EVT')
/
insert into com_label (id, name, label_type, module_code) values (10009172, 'evt.command', 'CAPTION', 'EVT')
/
insert into com_label (id, name, label_type, module_code) values (10009173, 'evt.reason', 'CAPTION', 'EVT')
/
insert into com_label (id, name, label_type, module_code) values (10009174, 'evt.status_logs', 'CAPTION', 'EVT')
/
insert into com_label (id, name, label_type, module_code) values (10009175, 'evt.initiator', 'CAPTION', 'EVT')
/
insert into com_label (id, name, label_type, module_code) values (10009176, 'evt.change_date', 'CAPTION', 'EVT')
/
insert into com_label (id, name, label_type, module_code) values (10009231, 'evt.batch', 'CAPTION', 'EVT')
/
insert into com_label (id, name, label_type, module_code) values (10009230, 'evt.batch_send', 'CAPTION', 'EVT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004041, 'evt.edit_status_map', 'CAPTION', 'EVT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004042, 'evt.event_type', 'CAPTION', 'EVT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004044, 'evt.initial_status', 'CAPTION', 'EVT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004045, 'evt.new_status_map', 'CAPTION', 'EVT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004046, 'evt.result_status', 'CAPTION', 'EVT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004047, 'evt.status_map', 'CAPTION', 'EVT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004048, 'evt.status_map_deleted', 'CAPTION', 'EVT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004049, 'evt.status_map_saved', 'CAPTION', 'EVT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004050, 'evt.status_mapping', 'CAPTION', 'EVT', NULL)
/

-- Errors
insert into com_label (id, name, label_type, module_code, env_variable) values (10003963, 'DUPLICATE_EVENT_RULE_SET', 'ERROR', 'EVT', 'EVENT_ID, RULE_SET_ID, MOD_ID, COUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003962, 'EVENT_TYPE_ALREADY_USED', 'ERROR', 'EVT', 'EVENT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003843, 'EXISTS_UNTREATED_ENTRIES', 'ERROR', 'EVT', 'STTL_DATE, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003835, 'DUPLICATE_STTL_DAY', 'ERROR', 'EVT', 'STTL_DATE, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003825, 'STTL_DAY_NOT_BUSINESS', 'ERROR', 'EVT', 'STTL_DATE, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010245, 'EVENT_SUBSCRIBER_IN_USE', 'ERROR', 'EVT', 'EVENT_SUBSCRIBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010244, 'EVENT_TYPE_IN_USE', 'ERROR', 'EVT', 'EVENT_TYPE')
/
insert into com_label (id, name, label_type, module_code) values (10008636, 'EVENT_TYPE_ALREADY_EXIST_FOR_INST', 'ERROR', 'EVT')
/
insert into com_label (id, name, label_type, module_code) values (10009772, 'ILLEGAL_STATUS_COMBINATION', 'ERROR', 'EVT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011005, 'SUBSCRIPTION_ALREADY_EXISTS', 'ERROR', 'EVT', 'EVENT_ID, SUBSCR_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003831, 'PROCESS_RESULT_SUCCESS_NOT_FOUND', 'ERROR', 'EVT', 'STTL_DATE, PROCESS_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004562, 'UNABLE_CHANGE_STATUS', 'ERROR', 'EVT', 'ENTITY_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004813, 'HOST_BY_ACCOUNT_NOT_FOUND', 'ERROR', 'EVT', 'ENTITY_TYPE, OBJECT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005282, 'DUPLICATE_STATUS_MAP', 'ERROR', 'NET', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007045, 'UNABLE_CHANGE_STATUS_OF_EXPIRED_CARD', 'ERROR', 'EVT', 'ENTITY_TYPE, OBJECT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011991, 'UNABLE_CHANGE_STATUS_OR_STATE', 'ERROR', 'EVT', 'ENTITY_TYPE, EVENT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10012002, 'EVENT_TYPE_IS_NOT_DEFINED_FOR_STATUS_COMBINATION', 'ERROR', 'EVT', 'INITIATOR, INITIAL_STATUS, RESULT_STATUS, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10012015, 'SUBSCRIPTION_WITH_CONTAINER', 'ERROR', 'EVT', 'SUBSCRIPT_ID, EVENT_ID, SUBSCR_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10012016, 'SUBSCRIPTION_WITHOUT_CONTAINER', 'ERROR', 'EVT', 'SUBSCRIPT_ID, EVENT_ID, SUBSCR_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001417, 'EVENT_TYPE_NOT_SUPPORT_IN_PROC', 'ERROR', 'EVT', 'EVENT_TYPE, ENTITY_TYPE, PROC_NAME')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004194, 'MCC_LIST_TOO_LONG', 'ERROR', 'COM', 'LENGTH')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006408, 'SUBSCRIPTION_ON_EVENT_TYPE_NOT_FOUND', 'ERROR', 'EVT', 'EVENT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006413, 'CURRENCY_UNINDENTIFIED', 'ERROR', 'EVT', 'CURRENCY_CODE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008215, 'ERROR_ROLLBACK_PROCESSING_EVENT', 'ERROR', 'EVT', 'EVENT_ID, REASON')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014264, 'CARD_IS_NOT_FOUND_BY_INSTANCE', 'CAPTION', 'EVT', 'CARD_INSTANCE_ID')
/
