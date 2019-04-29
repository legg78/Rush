delete com_label where id = 10011459
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011459, 'PRESENTMENT_AFTER_TRAILER', 'ERROR', 'CMP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011461, 'CMP_INSTITUTION_NOT_FOUND', 'ERROR', 'CMP', NULL)
/
delete com_label where id = 10011462
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011462, 'TRAILER_NOT_FOUND', 'ERROR', 'CMP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011494, 'HEADER_NOT_FOUND', 'ERROR', 'CMP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011503, 'CMP_WRONG_TEST_OPTION_PARAMETER', 'ERROR', 'CMP', NULL)
/
update com_label set env_variable = 'PROC_ACTION_CODE, FILE_ACTION_CODE' where id = 10011503
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009747, 'UNABLE_DETERMINE_STTL_TYPE', 'ERROR', 'CMP', 'TRAN_TYPE, CARD_NUMBER, I_ISS_INST_ID, I_ACQ_INST_ID, I_CARD_INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009748, 'UNABLE_DETERMINE_OPER_TYPE', 'ERROR', 'CMP', 'TRAN_TYPE')
/
update com_label set env_variable = 'TRAN_TYPE, CARD_NUMBER, ISS_INST_ID, ACQ_INST_ID, CARD_INST_ID, NETWORK_IDS' where id = 10009747
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008212, 'CMP_VERSION_PARAM_NOT_FOUND', 'CAPTION', 'CMP', NULL)
/
update com_label set env_variable = 'INST_ID, STANDARD_ID, HOST_ID, PARAM_NAME' where id = 10008212
/
