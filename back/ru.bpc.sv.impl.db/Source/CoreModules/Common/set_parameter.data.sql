insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1029, 'COM', 'INTERFACE', 'PLVLUSER', NULL, NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1004, 'COM', 'LANGUAGE', 'PLVLUSER', 'LANGENG', 'DTTPCHAR', 5, 1029, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (1005, 'COM', 'PARALLEL_DEGREE', 'PLVLSYST', '000000000000000001.0000', 'DTTPNMBR', NULL, 1019)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (1006, 'COM', 'SPLIT_DEGREE', 'PLVLSYST', '-000000000000000001.0000', 'DTTPNMBR', NULL, 1019)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1009, 'COM', 'DATE_PATTERN', 'PLVLUSER', 'dd.MM.yyyy', 'DTTPCHAR', NULL, 1029, 20)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (1019, 'COM', 'SYSTEM', 'PLVLSYST', NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (1020, 'COM', 'INSTANCE_NAME', 'PLVLSYST', 'Undefined', 'DTTPCHAR', NULL, 1019)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1027, 'COM', 'MENU_COLLAPSED', 'PLVLUSER', '000000000000000000.0000', 'DTTPNMBR', 4, 1029, 30)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1028, 'COM', 'MENU_BOOKMARKS_PLAIN', 'PLVLUSER', '000000000000000001.0000', 'DTTPNMBR', 4, 1029, 40)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1030, 'COM', 'MENU_BOOKMARKS_FILTER', 'PLVLUSER', '000000000000000001.0000', 'DTTPNMBR', 4, 1029, 50)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1031, 'COM', 'SECURITY', 'PLVLSYST', '', '', NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1032, 'COM', 'MASKING_CARD', 'PLVLSYST', '', '', NULL, 1031, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1033, 'COM', 'BEGIN_VISIBLE_CHAR', 'PLVLSYST', '000000000000000006.0000', 'DTTPNMBR', NULL, 1032, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1034, 'COM', 'END_VISIBLE_CHAR', 'PLVLSYST', '000000000000000004.0000', 'DTTPNMBR', NULL, 1032, 20)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10000938, 'COM', 'FRONT_END_SETTINGS', 'PLVLSYST', NULL, NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10000942, 'COM', 'FRONT_END_LOCATION', 'PLVLSYST', 'http://rhit.bpc.in', 'DTTPCHAR', NULL, 10000938, 5)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10000944, 'COM', 'SETTLEMENT', 'PLVLSYST', '', '', NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10000945, 'COM', 'COMMON_SETTLEMENT_DAY', 'PLVLSYST', '000000000000000001.0000', 'DTTPNMBR', 4, 10000944, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10000950, 'COM', 'MASTERCARD_WS_PORT', 'PLVLSYST', '000000000000035050.0000', 'DTTPNMBR', NULL, 10000938, 20)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10000951, 'COM', 'NCR_WS_PORT', 'PLVLSYST', '000000000000035051.0000', 'DTTPNMBR', NULL, 10000938, 30)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10000952, 'COM', 'VISA_BASE1_WS_PORT', 'PLVLSYST', '000000000000035052.0000', 'DTTPNMBR', NULL, 10000938, 40)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10000953, 'COM', 'WAY4_WS_PORT', 'PLVLSYST', '000000000000035056.0000', 'DTTPNMBR', NULL, 10000938, 50)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10000954, 'COM', 'UPDATE_CACHE_WS_PORT', 'PLVLSYST', '000000000000035054.0000', 'DTTPNMBR', NULL, 10000938, 60)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10000974, 'COM', 'CYBERPLAT_WS_PORT', 'PLVLSYST', NULL, 'DTTPNMBR', NULL, 10000938, 65)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001102, 'COM', 'SYSTEM_TERMINAL_NUMBER', 'PLVLINST', NULL, 'DTTPCHAR', NULL, 10000938, 70)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001176, 'COM', 'WNDC_PLUGIN_PORT', 'PLVLSYST', NULL, NULL, NULL, 10000938, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1035, 'COM', 'ARTICLE_FORMAT', 'PLVLUSER', 'LVAPCDNM', 'DTTPCHAR', 1029, 1029, 60)
/
update set_parameter set data_type = 'DTTPNMBR' where id = 10001176
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001609, 'COM', 'SENSITIVE_DATA_STORAGE', 'PLVLSYST', NULL, NULL, NULL, 1031, 20)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001610, 'COM', 'STORE_CVV_CVC', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10001609, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001999, 'COM', 'URL_HELP', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 1029, 70)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002047, 'COM', 'MULTI_INSTITUTION', 'PLVLUSER', '000000000000000000.0000', 'DTTPNMBR', 4, 1019, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002240, 'COM', 'CONFIGURATION_STAND', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', NULL, 1019, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002241, 'COM', 'PATH_TO_LOCAL_COPY', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 1019, 20)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002242, 'COM', 'SVN_LOGIN', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 1019, 30)
/
update set_parameter set name = 'CONFIGURATION_INSTANCE' where id = 10002240
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002320, 'COM', 'SVIP_PORT', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10000938, 90)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002375, 'COM', 'RECURAUTH_WS_PORT', 'PLVLSYST', NULL, 'DTTPNMBR', NULL, 10000938, 100)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002712, 'COM', 'AUTH_ADDR_CHEK_ALGORITHM', 'PLVLINST', 'AVLGSAPA', 'DTTPCHAR', 464, 1031, NULL)
/
update set_parameter set name = 'AUTH_ADDR_CHECK_ALGORITHM' where id = 10002712
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002733, 'COM', 'DEFAULT_DATE_TYPE', 'PLVLINST', 'CYDT0001', 'DTTPCHAR', 430, 10000944, 20)
/
update set_parameter set lowest_level = 'PLVLINST' where id = 10000944
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002749, 'COM', 'VISA_SMS_WS_PORT', 'PLVLSYST', '000000000000033071.0000', 'DTTPNMBR', NULL, 10000938, 80)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002778, 'COM', 'NATIONAL_CURRENCY', 'PLVLINST', null, 'DTTPCHAR', 25, 10000944, 30)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002783, 'COM', 'SVN_PASSWORD', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 1019, 40)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002789, 'COM', 'MESSAGE_QUEUE_LOCATION', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10002788, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002788, 'COM', 'MESSAGE_QUEUE_SETTINGS', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, NULL, NULL)
/
update set_parameter set module_code = 'ISS' where id in (1033, 1034)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002796, 'COM', 'BPEL_URL', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10002788, 20)
/

insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002804, 'COM', 'APACHE_CAMEL_LOCATION', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10002788, 20)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002818, 'COM', 'HSM_SETTING', 'PLVLSYST', NULL, NULL, NULL, 1031, 30)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002819, 'COM', 'USE_HSM', 'PLVLSYST', '000000000000000001.0000', 'DTTPNMBR', 4, 10002818, 10)
/
delete set_parameter where id = 10002823
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002823, 'COM', 'NUMBER_MSG', 'PLVLSYST', NULL, 'DTTPNMBR', NULL, 10002788, 30)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002824, 'COM', 'INVALIDATION_SERVICE', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002825, 'COM', 'BUSINESS_PROCESS_INVALIDATION_URL', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10002824, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002826, 'COM', 'WEB_INVALIDATION', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10002824, 20)
/
delete set_parameter where id = 10002826
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002857, 'COM', 'CALLBACK_URL', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10002788, 40)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002866, 'COM', 'PATH_TO_LOGO', 'PLVLINST', null, 'DTTPCHAR', null, 1019, 50)
/
update set_parameter set parent_id = 1029 where id = 10002866
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002868, 'COM', 'EMV_TAGS_IS_BINARY', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10000938, 110)
/
delete from set_parameter where id = 10000942
/
delete from set_parameter where id = 10000950
/
delete from set_parameter where id = 10000951
/
delete from set_parameter where id = 10000952
/
delete from set_parameter where id = 10000953
/
delete from set_parameter where id = 10000954
/
delete from set_parameter where id = 10000974
/
delete from set_parameter where id = 10001102
/
delete from set_parameter where id = 10001176
/
delete from set_parameter where id = 10002320
/
delete from set_parameter where id = 10002375
/
delete from set_parameter where id = 10002749
/
delete from set_parameter where id = 10002868
/
delete from set_parameter where id = 10000938
/
delete from set_parameter where id = 10002825
/
delete from set_parameter where id = 10002824
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002939, 'COM', 'NATIONAL_COUNTRY', 'PLVLINST', NULL, 'DTTPCHAR', 24, 10000944, 40)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10000938, 'COM', 'FRONT_END_SETTINGS', 'PLVLSYST', NULL, NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002868, 'COM', 'EMV_TAGS_IS_BINARY', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10000938, 110)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003027, 'COM', 'MESSAGE_QUEUE_LOAD_CONSUMERS', 'PLVLSYST', '000000000000000001.0000', 'DTTPNMBR', NULL, 10002788, 50)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003040, 'COM', 'IPM_MPE_SOAP_SETTINGS', 'PLVLSYST', NULL, NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003041, 'COM', 'IPM_IN_ADDRESS', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10003040, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003042, 'COM', 'IPM_OUT_ADDRESS', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10003040, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003043, 'COM', 'MPE_ADDRESS', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10003040, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003079, 'COM', 'SECURE_WEBSERVICES', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 1019, 60)
/
delete from set_parameter where id = 10002242
/
delete from set_parameter where id = 10002783
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003116, 'COM', 'BLOCK_CONCURRENT_USER_SESSIONS', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 1019, 10)
/
update set_parameter set lowest_level = 'PLVLINST' where id in (1031, 1032)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003122, 'COM', 'SESSION_TIMEOUT', 'PLVLSYST', '000000000000000020.0000', 'DTTPNMBR', null, 1019, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003223, 'COM', 'MASKING_CARD_IN_DBAL_FILE', 'PLVLINST', '000000000000000000.0000', 'DTTPNMBR', 4, 1032, 50)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003629, 'COM', 'UNMASKED_PAN_IN_RESPONSE_ON_WS', 'PLVLINST', '000000000000000001.0000', 'DTTPNMBR', 4, 1032, 60, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10004045, 'COM', 'CHANGE_USER_VIA_APPLICATION', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 1019, 70)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10004064, 'COM', 'FACE_VALUE_FORMAT', 'PLVLSYST', 'FVFT0002', 'DTTPCHAR', 648, 1029, 80)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10004084, 'COM', 'MAX_COUNT_WHEN_FORM_USES_SORTING', 'PLVLSYST', '000000000000001000.0000', 'DTTPNMBR', NULL, 1029, 90)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004151, 'COM', 'MAKER_CHECKER', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 1019, 80, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004157, 'COM', 'JMX_MONITORING_GROUP', 'PLVLSYST', NULL, NULL, NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004158, 'COM', 'JMX_MONITORING', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10004157, 10, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004159, 'COM', 'JMX_MONITORING_PORT', 'PLVLSYST', '000000000000009026.0000', 'DTTPNMBR', NULL, 10004157, 20, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004160, 'COM', 'JMX_MONITORING_POOL_SIZE', 'PLVLSYST', '000000000000000010.0000', 'DTTPNMBR', NULL, 10004157, 30, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004161, 'COM', 'JMX_MONITORING_DELAY', 'PLVLSYST', '000000000000010000.0000', 'DTTPNMBR', NULL, 10004157, 40, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004162, 'COM', 'JMX_MONITORING_SVBO', 'PLVLSYST', NULL, NULL, NULL, 10004157, 100, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004163, 'COM', 'JMX_MONITORING_SVBO_ON', 'PLVLSYST', '000000000000000001.0000', 'DTTPNMBR', 4, 10004162, 10, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004164, 'COM', 'JMX_MONITORING_SVBO_DOMAIN', 'PLVLSYST', 'com.bpcbt.svbo', 'DTTPCHAR', NULL, 10004162, 20, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004165, 'COM', 'JMX_MONITORING_SVBO_PROCESSES_PERIOD', 'PLVLSYST', '000000000000000030.0000', 'DTTPNMBR', NULL, 10004162, 30, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004166, 'COM', 'JMX_MONITORING_ORACLE', 'PLVLSYST', NULL, NULL, NULL, 10004157, 200, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004167, 'COM', 'JMX_MONITORING_ORACLE_ON', 'PLVLSYST', '000000000000000001.0000', 'DTTPNMBR', 4, 10004166, 10, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004168, 'COM', 'JMX_MONITORING_ORACLE_DOMAIN', 'PLVLSYST', 'com.bpcbt.monitoring', 'DTTPCHAR', NULL, 10004166, 20, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004174, 'COM', 'JMX_MONITORING_LOCAL_ONLY', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10004157, 50, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004175, 'COM', 'JMX_MONITORING_AUTH', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10004157, 60, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004176, 'COM', 'JMX_MONITORING_PASSWORD_FILE', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10004157, 70, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004177, 'COM', 'JMX_MONITORING_ACCESS_FILE', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10004157, 80, NULL)
/
update set_parameter set parent_id = 10002723 where id = 10004151
/
delete from set_parameter where id = 10004174
/
delete from set_parameter where id = 10004175
/
delete from set_parameter where id = 10004176
/
delete from set_parameter where id = 10004177
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004272, 'COM', 'DIGIT_GROUP_SEPARATOR', 'PLVLUSER', 'SPRT0001', 'DTTPCHAR', 681, 1029, 100, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004275, 'COM', 'CBS_SETTLEMENT_FLAG', 'PLVLINST', '000000000000000000.0000', 'DTTPNMBR', 4, 10000944, 50, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004287, 'COM', 'LDAP_GROUP', 'PLVLSYST', NULL, NULL, NULL, 1031, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004288, 'COM', 'LDAP_ACTIVE', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10004287, 10, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004289, 'COM', 'LDAP_URL', 'PLVLSYST', 'ldap://ldap.example.in', 'DTTPCHAR', NULL, 10004287, 20, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004290, 'COM', 'LDAP_PORT', 'PLVLSYST', '000000000000000389.0000', 'DTTPNMBR', NULL, 10004287, 30, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004291, 'COM', 'LDAP_MANAGER_DN', 'PLVLSYST', 'cn=ldapadmin,dc=Example,dc=local', 'DTTPCHAR', NULL, 10004287, 40, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004292, 'COM', 'LDAP_MANAGER_PASSWORD', 'PLVLSYST', 'ldapadminpassword', 'DTTPCHAR', NULL, 10004287, 50, 1)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004293, 'COM', 'LDAP_USER_DN_PATTERNS', 'PLVLSYST', 'cn={0},ou=Users,dc=Example,dc=local', 'DTTPCHAR', NULL, 10004287, 60, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004294, 'COM', 'LDAP_USER_SEARCH_BASE', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10004287, 70, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004295, 'COM', 'LDAP_USER_SEARCH_FILTER', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10004287, 80, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004296, 'COM', 'LDAP_PASSWORD_ATTRIBUTE', 'PLVLSYST', 'userPassword', 'DTTPCHAR', NULL, 10004287, 90, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004297, 'COM', 'LDAP_PASSWORD_ALGORITHM', 'PLVLSYST', 'MD5', 'DTTPCHAR', NULL, 10004287, 100, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004298, 'COM', 'LDAP_PASSWORD_PREFIX', 'PLVLSYST', '{MD5}', 'DTTPCHAR', NULL, 10004287, 110, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004299, 'COM', 'LDAP_PASSWORD_AS_BASE64', 'PLVLSYST', '000000000000000001.0000', 'DTTPNMBR', 4, 10004287, 120, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004403, 'COM', 'ALLOWED_UPLOAD_FILE_TYPES', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 1013, 90, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004404, 'COM', 'MAX_UPLOAD_FILE_SIZE', 'PLVLSYST', NULL, 'DTTPNMBR', NULL, 1013, 100, NULL)
/
delete from set_parameter where id = 10004290
/
update set_parameter set default_value = 'ldap://ldap.example.in:389' where id = 10004289
/
update set_parameter set display_order = 130 where id = 10004577
/
update set_parameter set display_order = 160 where id = 10004578
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004591, 'COM', 'LDAP_ROLE_ATTRIBUTE', 'PLVLSYST', 'cn', 'DTTPCHAR', NULL, 10004287, 140, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004592, 'COM', 'LDAP_ROLE_SEARCH_BASE', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10004287, 150, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004593, 'COM', 'CALENDAR_TYPE', 'PLVLUSER', 'CLNDGREG', 'DTTPCHAR', 642, 1029, 110, NULL)
/
