-- Errors
insert into com_label (id, name, label_type, module_code) values (10008963, 'KEY_TRANSLATION_FAILED', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10005972, 'KEY_GENERATION_FAILED', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10005973, 'KCV_VALIDATION_FAILED', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10005974, 'KCV_GENERATION_FAILED', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008941, 'DUPLICATE_SEC_DES_KEY', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008942, 'KEY_NOT_FOUND', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008944, 'KCV_NOT_VALID', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10009166, 'ERROR_GENERATE_RSA_KEYPAIR_CERT', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10009167, 'TRACKING_NUMBER_NOT_FOUND', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10009168, 'SERVICE_IDENTIFIER_NOT_FOUND', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10009169, 'CERT_SERIAL_NO_NOT_FOUND', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10009170, 'UNKNOWN_CERTIFICATION_AUTHORITY', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009906, 'AUTHORITY_NOT_FOUND', 'ERROR', 'SEC', 'AUTHORITY_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009907, 'CA_PUBLIC_KEY_ALGORITHM_MISMATCH', 'ERROR', 'SEC', 'HASH_ALGORITHM,CERT_ALGORITHM')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009908, 'CA_PUBLIC_KEY_CERTIFICATE_FILE_HEADER_MISMATCH', 'ERROR', 'SEC', 'CERT_HEADER,SPECIFICATION')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009909, 'CA_PUBLIC_KEY_INDEX_MISMATCH', 'ERROR', 'SEC', 'KEY_INDEX,CA_KEY_INDEX,ISS_KEY_INDEX,HASH_KEY_INDEX')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009910, 'CERTIFICATE_EXPIRATION_DATE_MISMATCH', 'ERROR', 'SEC', 'ISS_PK_EXP_DATE,ISS_PK_EXP_DATE_CERT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009911, 'CERTIFICATE_FILES_EMPTY', 'ERROR', 'SEC', '')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009912, 'CERTIFICATE_SUBJECT_ID_MISMATCH', 'ERROR', 'SEC', '')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009913, 'CERTIFICATION_AUTHORITY_MISMATCH', 'ERROR', 'SEC', 'AUTHORITY_TYPE, AUTHORITY_TYPE_KEY')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009914, 'ERROR_VALIDATE_CA_PK_CERT', 'ERROR', 'SEC', '')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009915, 'ERROR_VALIDATE_ISSUER_CERT', 'ERROR', 'SEC', '')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009916, 'ISSUER_PUBLIC_EXPONENT_MISMATCH', 'ERROR', 'SEC', '')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009917, 'ISS_PUBLIC_KEY_CERTIFICATE_FILE_HEADER_MISMATCH', 'ERROR', 'SEC', 'HEADER,SPECIFICATION')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009918, 'RSA_CERTIFICATE_KEYS_NOT_FOUND', 'ERROR', 'SEC', 'AUTHORITY_KEY_ID,CERTIFIED_KEY_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009919, 'RSA_CERTIFICATE_NOT_FOUND', 'ERROR', 'SEC', 'CERTIFICATE_ID,KEY_ID,KEY_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009920, 'RSA_KEY_NOT_FOUND', 'ERROR', 'SEC', 'ID,KEY_TYPE,KEY_INDEX')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009921, 'SEC_FILE_NOT_FOUND', 'ERROR', 'SEC', 'FILE_NAME,FILE_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009922, 'UNKNOWN_CA_FILE_NAME', 'ERROR', 'SEC', 'FILE_NAME,FILE_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009923, 'VISA_SERVICE_IDENTIFIER_MISMATCH', 'ERROR', 'SEC', 'CA_VISA_SERVICE_ID_CA,CA_VISA_SERVICE_ID_ISS,VISA_SERVICE_ID')
/
-- Captions
insert into com_label (id, name, label_type, module_code) values (10001866, 'sec.key_type', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10001867, 'sec.key_prefix', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10001868, 'sec.key_length', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10001869, 'sec.check_value', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10001870, 'sec.key', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10001871, 'sec.new_des_key', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10001872, 'sec.edit_des_key', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10001873, 'sec.des_key_deleted', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10001874, 'sec.des_key_saved', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008559, 'sec.translate_des_key', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008563, 'sec.key_encryption_key', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008566, 'sec.print_clear_components', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008567, 'sec.translate', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008568, 'sec.des_key', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008571, 'sec.key_cryptogram', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008572, 'sec.generate', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008573, 'sec.generate_des_key', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008574, 'sec.format', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008576, 'sec.key_component_number', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008578, 'sec.encrypted_key', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008579, 'sec.key_index', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008774, 'sec.check_word', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008775, 'sec.check_sec_word', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008776, 'sec.question', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008777, 'sec.answer', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008778, 'sec.validation', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008779, 'sec.word_incorrect', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008780, 'sec.word_correct', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008943, 'sec.des_key_exists_warning', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008945, 'sec.confirm_key_overwrite', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code) values (10008965, 'sec.new_key_prefix', 'CAPTION', 'SEC')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003303, 'sec.authority', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003304, 'sec.type', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003305, 'sec.rid', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003306, 'sec.name', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003307, 'sec.new_sec_authority', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003308, 'sec.edit_sec_authority', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003460, 'SEC_RSA_KEY_ALREADY_USED', 'ERROR', 'EMV', '')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003902, 'sec.standard_key_type', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003934, 'sec.authority_id', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003935, 'sec.rsa_certificate', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003936, 'sec.expir_date', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003937, 'sec.subject_id', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003938, 'sec.certified_key_id', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003939, 'sec.authority_key_id', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003940, 'sec.serial_number', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003941, 'sec.visa_service_id', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003942, 'sec.certificate', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003943, 'sec.reminder', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003944, 'sec.hash', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003945, 'sec.tracking_number', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003946, 'sec.state', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003950, 'sec.description', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003951, 'sec.modulus_length', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003952, 'sec.lmk_id', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003953, 'sec.hsm_device_id', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003954, 'sec.sign_algorithm', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003955, 'sec.exponent', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003956, 'sec.edit_rsa_key', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003957, 'sec.new_rsa_key', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003958, 'sec.view_rsa_key', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003959, 'sec.rsa_keys', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003996, 'sec.is_not_hexadecimal_value', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003997, 'sec.fill_only_one_field', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003998, 'sec.public_key_mac', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003999, 'sec.public_key', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004000, 'sec.private_key', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004001, 'sec.rsa_certificates', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004002, 'sec.set_ca_index', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004003, 'sec.authority_key_index', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004004, 'sec.bin', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004811, 'sec.object_description', 'CAPTION', 'SEC', NULL)
/
delete from com_label where id in (10009919, 10003460)
/
insert into com_label (id, name, label_type, module_code) values (10004943, 'DUPLICATE_SEC_HMAC_KEY', 'ERROR', 'SEC')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004978, 'sec.hmac_keys', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004980, 'sec.key_value', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004982, 'sec.generate_date', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004984, 'sec.generate_user_name', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004987, 'sec.new_hmac_key', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004989, 'sec.hmac_key', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004991, 'sec.generate_hmac_key', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004994, 'sec.des_keys', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005473, 'sec.private_key_mac', 'CAPTION', 'SEC', NULL)
/
update com_label set env_variable = 'AUTHORITY_TYPE' where id = 10009166
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005526, 'DUPLICATE_RSA_KEY', 'ERROR', 'SEC', 'KEY_INDEX, KEY_TYPE, ENTITY_TYPE, OBJECT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005552, 'sec.not_found_public_key', 'CAPTION', 'SEC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005588, 'DUPLICATE_AUTHORITY', 'ERROR', 'SEC', 'TYPE,RID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009471, 'UNKNOWN_PINBLOCK_FORMAT', 'ERROR', 'SEC', 'PINBLOCK_FORMAT')
/
update com_label set env_variable = 'HSM_DEVICE_ID, STANDARD_KEY_TYPE, RESPONSE_MESSAGE' where id in (10005972, 10008963)
/
update com_label set env_variable = 'HSM_DEVICE_ID, AUTHORITY_TYPE, RESPONSE_MESSAGE' where id in (10009166, 10009914, 10009915)
/
update com_label set env_variable = 'HSM_DEVICE_ID, KEY_TYPE, RESPONSE_MESSAGE' where id in (10005974, 10005973)
/
