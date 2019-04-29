-- Errors
insert into com_label (id, name, label_type, module_code, env_variable) values (10004069, 'AGENT_HAS_ACCOUNT', 'ERROR', 'RPT', 'AGENT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010950, 'CYCLIC_AGENT_TREE_FOUND', 'ERROR', 'COM', 'AGENT_TYPE, PARENT_TYPE')
/
insert into com_label (id, name, label_type, module_code) values (10000051, 'INSTITUTION_NOT_DEFINED', 'ERROR', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001881, 'PARENT_AGENT_NOT_FOUND', 'ERROR', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001882, 'AGENT_TYPE_INCONSISTENT_WITH_PARENT_AGENT', 'ERROR', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001883, 'AGENT_NOT_FOUND', 'ERROR', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001884, 'AGENT_TYPE_NOT_FOUND', 'ERROR', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001885, 'AGENT_TYPE_NOT_DEFINED', 'ERROR', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10002207, 'DUPLICATE_INSTITUTION_ID', 'ERROR', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10005975, 'DEF_AGENT_NOT_FOUND', 'ERROR', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10005976, 'CANNOT_DELETE_INSTITUTION', 'ERROR', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10009188, 'AGENT_HAS_SUBORDINATE_AGENT', 'ERROR', 'OST')
/

-- Labels
insert into com_label (id, name, label_type, module_code) values (10008754, 'SYS_INST_NAME', 'LABEL', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10010147, 'ANY_INST_NAME', 'LABEL', 'OST')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003504, 'ost.new_inst', 'CAPTION', 'OST', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003506, 'ost.edit_inst', 'CAPTION', 'OST', NULL)
/

-- Captions
insert into com_label (id, name, label_type, module_code) values (10000221, 'ost.inst_id', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10000250, 'ost.institution', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10000252, 'ost.institutions', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10000261, 'ost.agents', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10000412, 'ost.agent_types', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10000414, 'ost.agent_id', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10000418, 'ost.new_agent', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10000420, 'ost.edit_agent', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10000424, 'ost.agent_name', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001090, 'ost.agent_type_hier', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001091, 'ost.agent_type', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001092, 'ost.parent_agent_type', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001096, 'ost.add_node', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001098, 'ost.new_agent_type', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001114, 'ost.add_agent_type', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001151, 'ost.entirely', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10001575, 'ost.agent', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10002170, 'ost.inst_genitive', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10002175, 'ost.agent_genitive', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10002234, 'ost.default_inst', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10002235, 'ost.to_all_agents', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10002279, 'ost.select_insts', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code) values (10002280, 'ost.select_agents', 'CAPTION', 'OST')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004053, 'ost.default_network', 'CAPTION', 'OST', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005228, 'UNKNOWN_AGENT_TYPE', 'ERROR', 'OST', 'AGENT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005519, 'AGENT_IS_SET_AS_DEFAULT', 'ERROR', 'CMN', 'TEXT, STANDARD_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009396, 'DUPLICATE_AGENT_NUMBER', 'ERROR', 'OST', 'AGENT_NUMBER, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011154, 'ost.external_number', 'CAPTION', 'OST', NULL)
/
delete com_label where id = 10005228
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011932, 'TOO_MANY_INSTITUTIONS', 'ERROR', 'OST', 'NETWORK_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011933, 'TOO_MANY_NETWORKS', 'ERROR', 'OST', 'INST_ID, NETWORK_ID')
/
update com_label set env_variable = 'INST_ID' where id = 10002207
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011992, 'INSTITUTION_IS_NOT_DEFINED', 'ERROR', 'OST', 'INST_ID')
/
update com_label set env_variable='AGENT_ID,INST_ID' where id=10001883
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007801, 'AGENT_NOT_ACCESS', 'ERROR', 'OST', 'AGENT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007124, 'INSTITUTION_NOT_ACCESS', 'ERROR', 'OST', 'INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011590, 'DUPLICATE_INST_NUMBER', 'ERROR', 'OST', 'INSTITUTION_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014224, 'ost.agent_number', 'CAPTION', 'OST', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013256, 'ost.inst_status', 'CAPTION', 'OST', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013257, 'ost.data_action', 'CAPTION', 'OST', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013487, 'INSTITUTIONS_DONT_MATCH', 'CAPTION', 'OST', 'FIRST_INST_ID, SECOND_INST_ID')
/
