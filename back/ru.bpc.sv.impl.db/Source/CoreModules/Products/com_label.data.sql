-- Errors
insert into com_label (id, name, label_type, module_code, env_variable) values (10004370, 'CANNOT_MODIFY_CLOSED_CUSTOMER', 'ERROR', 'PRD', 'CUSTOMER_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003994, 'CONTRACT_ALREADY_EXISTS', 'ERROR', 'PRD', 'ID, INST_ID, CONTRACT_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003817, 'SERVICE_ACTIVATION_START_DATE_INVALID', 'ERROR', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003661, 'INVALID_START_DATE', 'ERROR', 'PRD', 'START_DATE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003418, 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER', 'ERROR', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003389, 'PRD_NO_ACTIVE_SERVICE', 'ERROR', 'PRD', 'ENTITY_TYPE, OBJECT_ID, ATTR_NAME, EFF_DATE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003351, 'CLIENT_NOT_FOUND', 'ERROR', 'APP', 'CLIENT_ID_TYPE, CLIENT_ID_VALUE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003350, 'TOO_MANY_CLIENTS', 'ERROR', 'APP', 'CLIENT_ID_TYPE, CLIENT_ID_VALUE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003315, 'CANNOT_UPDATE_CONTRACT', 'ERROR', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003296, 'CONTRACT_TYPE_ALREADY_EXISTS', 'ERROR', 'PRD', 'CONTRACT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010243, 'SERVICES_OF_SAME_TYPE_INTERSECTED', 'ERROR', 'PRD', 'SERVICE_ID1, START_DATE1, END_DATE1, SERVICE_ID2, START_DATE2, END_DATE2')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010242, 'TOO_MANY_INITIAL_SERVICES', 'ERROR', 'PRD', 'COUNT, MAX_COUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010241, 'NOT_ENOUGH_SERVICES', 'ERROR', 'PRD', 'COUNT, MIN_COUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010223, 'CONTRACT_TYPE_ALREADY_USED', 'ERROR', 'PRD', 'CONTRACT_TYPE')
/
insert into com_label (id, name, label_type, module_code) values (10009227, 'CYCLIC_ATTRIBUTE_TREE_FOUND', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009212, 'SERVICE_IS_ALREADY_USED', 'ERROR', 'PRD', 'SERVICE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008969, 'CANNOT_CHANGE_CUSTOMER_TYPE', 'ERROR', 'APP', 'CUSTOMER_NUMBER, INST_ID, OLD_CUSTOMER_TYPE, CUSTOMER_TYPE')
/
insert into com_label (id, name, label_type, module_code) values (10008950, 'SERVICE_IS_NOT_ACTIVE', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008878, 'CUSTOMER_IS_ALREADY_USED', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008832, 'CONTRACT_NOT_FOUND', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10001674, 'WRONG_ATTRIBUTE_DATA_TYPE', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10001713, 'ATTRIBUTE_NOT_FOUND', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10001818, 'ATTR_HAS_DEPENDANT', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10001807, 'PRODUCT_OF_WRONG_TYPE', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10001808, 'PARENT_PRODUCT_NOT_FOUND', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10001814, 'PARENT_PRODUCT_OF_DIFFERENT_TYPE', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10002684, 'ATTR_NOT_FOUND_FOR_ENTITY', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10002907, 'PRODUCT_IS_ALREADY_IN_USE', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10003138, 'ATTR_SCALE_ALREADY_EXISTS', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10003160, 'ATTR_SCALE_ALREADY_USED', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008632, 'INCONSISTENT_ATTR_FEE', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008708, 'CONTRACT_ID_NOT_DEFINED', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008783, 'ATTR_WITH_NAME_ALREADY_EXISTS', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008890, 'CUSTOMER_CONTRACTS_IS_ALREADY_USED', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008893, 'CONTRACT_NUMBER_IS_MANDATORY', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008894, 'ENTITY_TYPE_IS_MANDATORY', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008895, 'OBJECT_ID_IS_MANDATORY', 'ERROR', 'PRD')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009924, 'INCONSISTENT_ATTR_CYCLE', 'ERROR', 'PRD', 'ENTITY_TYPE,OBJECT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009925, 'INCONSISTENT_ATTR_LIMIT', 'ERROR', 'PRD', 'ENTITY_TYPE,OBJECT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009926, 'LIMIT_TYPE_NOT_FOUND', 'ERROR', 'PRD', 'LIMIT_TYPE,ENTITY_TYPE,OBJECT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009928, 'SERVICE_TYPE_IS_ALREADY_USED', 'ERROR', 'PRD', 'SERVICE_TYPE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009955, 'DUPLICATE_SERVICE_NAME', 'ERROR', 'PRD', 'SERVICE_NAME,INSTITUTION')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004375, 'INVALID_CONTRACT_DATE', 'ERROR', 'PRD', 'START_DATE')
/
-- Captions
insert into com_label (id, name, label_type, module_code) values (10008690, 'prd.products', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008691, 'prd.is_multiple', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008692, 'prd.attributes', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008693, 'prd.edit_service_type', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008694, 'prd.new_service_type', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008695, 'prd.service_type_deleted', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008696, 'prd.service_type_saved', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008697, 'prd.service_type', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008698, 'prd.service_types', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008699, 'prd.service', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008700, 'prd.services', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008701, 'prd.contracts', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008702, 'prd.contract', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008703, 'prd.edit_service', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008704, 'prd.new_service', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008705, 'prd.service_deleted', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008706, 'prd.service_saved', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008709, 'prd.product_type', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008710, 'prd.product', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008711, 'prd.min_count', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008712, 'prd.max_count', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008713, 'prd.prod_serv_rel_deleted', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008714, 'prd.prod_serv_rel_saved', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008715, 'prd.min_count_gt_max_count', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008717, 'prd.def_level', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008729, 'prd.contract_number', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008730, 'prd.customer', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008731, 'prd.objects', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008732, 'prd.new_contract', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008733, 'prd.edit_contract', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008734, 'prd.contract_deleted', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008735, 'prd.contract_saved', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008736, 'prd.customer_saved', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008737, 'prd.customer_deleted', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008738, 'prd.customers', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008739, 'prd.customer_number', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008740, 'prd.new_customer', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008741, 'prd.edit_customer', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008764, 'prd.new_product_service', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008765, 'prd.edit_product_service', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10006037, 'prd.cycle_for', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10006038, 'prd.limit_for', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008875, 'prd.is_initial', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008897, 'prd.edit_attr_value', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008898, 'prd.new_attr_value', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10008954, 'prd.prod_serv_rel_exists', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10009229, 'prd.initiating', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10009290, 'prd.contract_types', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10009291, 'prd.contract_type', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10009292, 'prd.customer_type', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10009293, 'prd.new_contract_type', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10009294, 'prd.edit_contact_type', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10009296, 'prd.enable_event_type', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code) values (10009297, 'prd.disable_event_type', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010990, 'prd.relation', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003169, 'prd.service_terms', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003171, 'prd.acquiring_hierarchy', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003172, 'prd.acq_h', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003173, 'prd.issuing_hierarchy', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003174, 'prd.iss_h', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003188, 'prd.attr_level_msg', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003219, 'DUPLICATE_PRODUCT_SERVICE', 'ERROR', 'PRD', 'SERVICE_ID,PRODUCT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003312, 'prd.exclude', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003515, 'prd.service_term_type', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003516, 'prd.edit_service_term', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003517, 'prd.new_service_term', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003518, 'prd.new_service_term_scale_relation', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003519, 'prd.service_term', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003520, 'prd.edit_service_term_value', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003521, 'prd.new_service_term_value', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003748, 'prd.from', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003749, 'prd.till', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003859, 'prd.service_term_is_immutable', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003862, 'prd.edit_contract_type', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003865, 'prd.visible', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004416, 'prd.general_data', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004420, 'prd.person_data', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004422, 'prd.company_data', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004426, 'prd.nationality', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004427, 'prd.credit_rating', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004428, 'prd.money_laundry_risk', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004429, 'prd.money_laundry_reason', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004568, 'prd.association', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004570, 'prd.associate', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004572, 'prd.customer_must_be_company', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004867, 'prd.registered', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004869, 'prd.effective', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004918, 'prd.service_fee', 'CAPTION', NULL, NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004930, 'net.feature', 'CAPTION', 'NET', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004931, 'net.features', 'CAPTION', 'NET', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004934, 'net.edit_feature', 'CAPTION', 'NET', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004936, 'net.new_feature', 'CAPTION', 'NET', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004947, 'emv.new_script_type', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004945, 'emv.edit_script_type', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004948, 'emv.mac', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004950, 'emv.tag71', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004952, 'emv.tag72', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004954, 'emv.retransmission', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004956, 'emv.repeat_count', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004958, 'emv.instruction_byte', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004960, 'emv.parameter1', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004962, 'emv.parameter2', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004964, 'emv.req_length_data', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004966, 'emv.is_used_by_user', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004968, 'emv.form_url', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004970, 'emv.class_byte', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005001, 'prd.customer_role', 'CAPTION', 'PRD', NULL)
/
delete from com_label where id = 10010223
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005154, 'SERVICE_TYPE_NOT_FOUND', 'ERROR', 'PRD', 'SERVICE_TYPE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005169, 'WRONG_CONTRACT_TYPE', 'ERROR', 'PRD', 'CONTRACT_TYPE, PRODUCT_ID, PRD_CONTRACT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005175, 'prd.change_visibility', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005222, 'DIFFERENT_PRODUCT_TYPE_FOR_SERVICE_AND_PRODUCT', 'ERROR', 'PRD', 'PRODUCT_ID, PRODUCT_TYPE, SERVICE_ID, SERVICE_PRODUCT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010223, 'CONTRACT_TYPE_ALREADY_USED', 'ERROR', 'PRD', 'CONTRACT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005303, 'WRONG_ATTRIBUTE_VALUE', 'ERROR', 'PRD', 'ATTRIBUTE_NAME, VALUE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005366, 'prd.inherited_from_parent_prd', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005368, 'prd.receiver_customer_number', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011190, 'SERVICE_TERM_DISPLAY_ORDER_ALREADY_USED', 'ERROR', 'PRD', 'DISPLAY_ORDER, SERVICE_TYPE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011754, 'PRODUCT_NOT_FOUND', 'ERROR', 'PRD', 'PRODUCT_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011758, 'PRODUCT_NAME_NOT_DEFINED', 'ERROR', 'PRD', 'PRODUCT_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011759, 'PRODUCT_ALREADY_EXIST', 'ERROR', 'PRD', 'PRODUCT_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011762, 'DUPLICATE_PRODUCT_NUMBER', 'ERROR', 'PRD', 'PRODUCT_NUMBER, INSTITUTION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011764, 'DUPLICATE_SERVICE_NUMBER', 'ERROR', 'PRD', 'SERVICE_NUMBER, INSTITUTION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011768, 'common.product_number', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011772, 'prd.product_number', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011775, 'prd.service_number', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011777, 'common.service_number', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011248, 'PRODUCT_NUMBER_DOESNT_CORRELATE_WITH_PRODUCT_ID', 'ERROR', 'PRD', 'PRODUCT_NUMBER, INSTITUTION_ID, PRODUCT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011250, 'SERVICE_NUMBER_DOESNT_CORRELATE_WITH_SERVICE_ID', 'ERROR', 'PRD', 'SERVICE_NUMBER, INSTITUTION_ID, SERVICE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011765, 'CONTRACT_DOES_NOT_BELONG_TO_CUSTOMER', 'ERROR', 'PRD', 'CONTRACT_NUMBER, CUSTOMER_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009413, 'prd.service_provider', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009415, 'prd.ext_customer_type', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009447, 'ENTITY_IS_ALREADY_ASSOCIATED_WITH_CUSTOMER', 'ERROR', 'PRD', 'EXT_ENTITY_TYPE, EXT_OBJECT_ID, CUSTOMER_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009457, 'emv.view_script_type', 'CAPTION', 'EMV', NULL)
/
insert into com_label (id, name, label_type, module_code) values (10006901, 'SERVICE_NOT_FOUND_ON_PRODUCT', 'ERROR', 'PRD')
/
delete from com_label where id = 10004375
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005643, 'ACCOUNT_TYPE_NOT_FOUND', 'ERROR', 'ACC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005645, 'BIN_INDEX_RANGE_NOT_FOUND_BY_ID', 'ERROR', 'ISS', 'INDEX_RANGE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005647, 'EMV_APPL_SCHEME_NOT_FOUND', 'ERROR', 'EMV', 'ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005649, 'BLANK_TYPE_NOT_FOUND', 'ERROR', 'PRS', 'ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005651, 'CARD_TYPE_NOT_FOUND', 'ERROR', 'ISS', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005653, 'CARD_TYPE_FOR_PRODUCT_ALREADY_EXISTS', 'ERROR', 'ISS', 'CARD_TYPE_ID, PRODUCT_ID, SERVICE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005655, 'CARD_PERSONALIZATION_METHOD_NOT_FOUND', 'ERROR', 'PRS', 'ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005679, 'prd.record_number', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005725, 'prd.service_development', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005734, 'TOO_MANY_CUSTOMERS_ARE_FOUND', 'ERROR', 'PRD', 'INST_ID')
/
delete from com_label where id = 10008893
/
update com_label set env_variable = 'CONTRACT_TYPE, CUSTOMER_TYPE, PRODUCT_TYPE' where id = 10003296
/
update com_label set env_variable = 'INSTITUTION' where id = 10003138
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009503, 'EXT_CUSTOMER_DOES_NOT_EXIST', 'ERROR', 'PRD', 'EXT_ENTITY_TYPE, EXT_OBJECT_ID, INST_ID')
/
insert into com_label (id, name, label_type, module_code) values (10009576, 'SERVICE_MUST_DEFINED_ON_PARENT_PRODUCT', 'ERROR', 'PRD')
/
update com_label set name = 'ATTR_MUST_DEFINED_ON_PARENT_PRODUCT' where id = 10009576
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009600, 'ATTR_IS_USED_ON_PROD_OR_OBJECT', 'ERROR', 'PRD', 'ID, TEXT')
/
update com_label set env_variable = 'ATTRIBUTE_ID' where id = 10001713
/
update com_label set env_variable = 'ID' where id = 10003160
/
update com_label set env_variable = 'SERVICE_ID, PRODUCT_ID' where id = 10006901
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009664, 'INCONSISTENT_ENTITY_TYPE_FOR_SERVICE', 'ERROR', 'PRD', 'ENTITY_TYPE, SERVICE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009725, 'WRONG_CONTRACT_TYPE_IN_FILE', 'ERROR', 'PRD', 'CONTRACT_TYPE, PRODUCT_ID, PRD_CONTRACT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001363, 'MSG.CREATED_FROM', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001364, 'MSG.CREATED_TO', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001369, 'MSG.DISPUTED_CURRENCY', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001371, 'MSG.DISPUTED_AMOUNT', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001373, 'MSG.TRANS_CURRENCY', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001375, 'MSG.CASE_STATUS', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001377, 'MSG.CASE_RESOLUTION', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007788, 'MSG.CASE_STATE', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007793, 'MSG.VISIBLE', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007795, 'MSG.HIDDEN', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007797, 'MSG.ADD_CASE', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007799, 'MSG.CASE_OWNER', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007967, 'MSG.CASE_PROGRESS', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007307, 'MSG.CASE_DETAILS', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007358, 'MSG.CASE_CREATION', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007360, 'MSG.TYPE_CASES', 'CAPTION', 'MSG', NULL)
/

insert into com_label (id, name, label_type, module_code, env_variable) values (10007321, 'MSG.MANDATORY_COMBINATIONS', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007323, 'ISS.DELIV_REF_NUM', 'CAPTION', 'ISS', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007330, 'ISS.DELIVERY_STATUS', 'CAPTION', 'ISS', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007335, 'EVT.SET_DELIVERY_REF_NUM', 'CAPTION', 'EVT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007337, 'FORM.SUBMIT', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007341, 'CRD.CARD_ID', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007345, 'ISS.PRECEDING_CARD_INSTANCE', 'CAPTION', 'ISS', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007347, 'ISS.REISSUE_REASON', 'CAPTION', 'ISS', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007349, 'ISS.REISSUE_DATE', 'CAPTION', 'ISS', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007351, 'MSG.MANDATORY_FIELDS_NOT_FILED', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007354, 'ISS.AMOUNT', 'CAPTION', 'ISS', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007363, 'MSG.MERCH_COUNTRY_CODE', 'CAPTION', 'MSG', NULL)
/
delete com_label where name = 'MSG.DOCUMENTS_UNLOADED'
/
delete com_label where id = 10007968
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007968, 'MSG.DOCUMENTS_UNLOADED', 'CAPTION', 'MSG', NULL)
/
delete com_label where id = 10007970
/
delete com_label where name = 'MSG.CHARGEBACK_WARNING'
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007970, 'MSG.CHARGEBACK_WARNING', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007972, 'MSG.FRAUD_WARNING', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006368, 'MSG.CLAIM_ID', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001381, 'MSG.ADD_COMMENT', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001382, 'MSG.SYSTEM_COMMENT', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001386, 'MSG.USER_COMMENT', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001388, 'MSG.COMMENT_WARN_LBL', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001390, 'MSG.AUTHOR', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001408, 'INVALID_SEARCH_ENTITY', 'ERROR', 'PRD', 'DST_ENTITY_TYPE, ENTITY_TYPE, OBJECT_ID, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006374, 'MSG.ATTACH', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006378, 'MSG.TAKE_BTN', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006380, 'MSG.CONFIRM_REFUSE', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006382, 'MSG.REASSIGN_CASE', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007980, 'MSG.CLAIM_STATUS', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007982, 'MSG.DOC_TYPE', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code) values (10004230, 'prd.length_type_is_mandatory', 'CAPTION', 'PRD')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008085, 'prd.employment_status', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008091, 'prd.employment_period', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008096, 'prd.residence_type', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008098, 'prd.marital_status_date', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008103, 'prd.income_range', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008106, 'prd.number_of_children', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008471, 'CONDITIONAL_SERVICE_CHECK_FAILED', 'ERROR', 'PRD', 'PRODUCT_SERVICE_ID, SERVICE_COUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007576, 'PRODUCT_NOT_FOUND_BY_CUSTOMER', 'ERROR', 'PRD', 'CUSTOMER_ID, INSTITUTION_ID, LANGUAGE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014232, 'prd.priority_products', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014238, 'prd.product_category', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014240, 'prd.product_subcategory', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014242, 'prd.parent_product_id', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014244, 'prd.product_description', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014246, 'prd.product_level3', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014247, 'prd.product_level4', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014248, 'prd.product_lag', 'CAPTION', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013244, 'prd.referral_code', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013250, 'REFERRAL_CODE_ALREADY_EXISTS', 'ERROR', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013251, 'REFERRER_CUSTOMER_ALREADY_EXISTS', 'ERROR', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013300, 'REFERRAL_CODE_NOT_FOUND', 'ERROR', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013301, 'REFERRAL_SERVICE_NOT_FOUND', 'ERROR', 'PRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013302, 'REFERRER_SERVICE_NOT_FOUND', 'ERROR', 'PRD', NULL)
/
update com_label set name = 'REFERRER_CODE_ALREADY_EXISTS' where id = 10013250
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013337, 'ATTR_WRONG_NUMBER_VALUES', 'ERROR', 'PRD', 'ATTRIBUTE_NAME, NUM_VALUES')
/
update com_label set env_variable = 'INST_ID, FOUND_RECORDS, MAX_COUNT, COMMUN_METHOD, COMMUN_ADDRESS, ID_NUMBER' where id = 10005734
/
