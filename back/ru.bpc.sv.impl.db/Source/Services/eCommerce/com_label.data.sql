insert into com_label (id, name, label_type, module_code, env_variable) values (10004974, 'CARD_NOT_LINKED', 'ERROR', 'ECM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004975, 'CARD_ALREADY_UNLINKED', 'ERROR', 'ECM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005104, 'AAV_GENERATION_FAILED', 'ERROR', 'ECM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005105, 'CAAV_GENERATION_FAILED', 'ERROR', 'ECM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005419, 'form.generateReqCert', 'CAPTION', 'COM', NULL)
/
update com_label set env_variable = 'HSM_DEVICE_ID, RESPONSE_MESSAGE' where id in (10005104, 10005105)
/
