insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (10002737, 'COM', 'PASSWORD_POLICY', 'PLVLSYST', null, null, null, 1031)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002739, 'COM', 'PASSWORD_EXPIRATION', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', null, 10002737, 2)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002740, 'COM', 'WARNING_EXPIRATION', 'PLVLSYST', '000000000000000010.0000', 'DTTPNMBR', null, 10002737, 3)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002741, 'COM', 'DEPTH_CHECK_UNIQUE', 'PLVLSYST', '000000000000000005.0000', 'DTTPNMBR', null, 10002737, 4)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003952, 'ACM', 'PASSWORD_MIN_LENGTH', 'PLVLSYST', '000000000000000008.0000', 'DTTPNMBR', NULL, 10002737, 30, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003953, 'ACM', 'PASSWORD_MAX_LENGTH', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', NULL, 10002737, 40, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003954, 'ACM', 'PASSWORD_MIN_ALPHA_CHARS', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', NULL, 10002737, 50, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003955, 'ACM', 'PASSWORD_MIN_NUM_CHARS', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', NULL, 10002737, 50, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003956, 'ACM', 'PASSWORD_MIN_LOWERCASE_CHARS', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', NULL, 10002737, 60, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003957, 'ACM', 'PASSWORD_MIN_UPPERCASE_CHARS', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', NULL, 10002737, 70, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003958, 'ACM', 'PASSWORD_MIN_NON_ALPHANUM_CHARS', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', NULL, 10002737, 80, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003959, 'ACM', 'PASSWORD_MIN_NON_ALPHABET_CHARS', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', NULL, 10002737, 90, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003960, 'SEC', 'AUTHENTICATION_USE_SSO_MODULE', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10003467, 5, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003961, 'SEC', 'AUTHENTICATION_SSO_MODULE_URL', 'PLVLSYST', 'http://localhost:7002/auth', 'DTTPCHAR', NULL, 10003467, 6, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004170, 'COM', 'MAX_LOGIN_ATTEMPTS', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', NULL, 10002737, 100, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004171, 'COM', 'LOCKOUT_DURATION', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', NULL, 10002737, 100, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004577, 'COM', 'LDAP_ROLES_USE', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10004287, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004578, 'COM', 'LDAP_ROLE_SEARCH_FILTER', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10004287, NULL, NULL)
/
