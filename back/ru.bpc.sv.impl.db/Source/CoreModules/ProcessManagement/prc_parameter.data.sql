insert into prc_parameter (id, param_name, data_type, lov_id) values (10001053, 'I_AGENT_ID', 'DTTPNMBR', 2)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10000430, 'I_STAGE', 'DTTPCHAR', 107)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10000372, 'I_INST_ID', 'DTTPNMBR', 1)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001054, 'I_SESSION_FILES_ONLY', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001146, 'I_NETWORK_ID', 'DTTPNMBR', 1019)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001147, 'I_TEST_OPTION', 'DTTPCHAR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10000857, 'I_STTL_DATE', 'DTTPDATE', null)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10000465, 'I_ALG_DAY', 'DTTPCHAR', 225)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001296, 'I_MODE', 'DTTPCHAR', 313)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001297, 'I_START_DATE', 'DTTPDATE', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001298, 'I_END_DATE', 'DTTPDATE', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001299, 'I_SHIFT_FROM', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001300, 'I_SHIFT_TO', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001301, 'I_BALANCE_TYPE', 'DTTPCHAR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001302, 'I_DATE_TYPE', 'DTTPCHAR', 314)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10000431, 'I_EFF_DATE', 'DTTPDATE', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10000432, 'I_CYCLE_TYPE', 'DTTPCHAR', 1021)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10000462, 'I_BATCH_ID', 'DTTPNMBR', 84)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10000463, 'I_EMBOSSING_REQUEST', 'DTTPCHAR', 82)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10000464, 'I_PIN_MAILER_REQUEST', 'DTTPCHAR', 81)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10000830, 'I_SERVICE_ID', 'DTTPNMBR', 182)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10000967, 'I_PURPOSE_ID', 'DTTPNMBR', 232)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10000968, 'I_HOST_ID', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001308, 'I_ORDER_STATUS', 'DTTPCHAR', 307)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001309, 'I_ATTEMPTS_NUMBER', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001349, 'I_HOST_INST_ID', 'DTTPNMBR', 1)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001350, 'I_ACCOUNT_NUMBER', 'DTTPCHAR', 116)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001383, 'I_CARD_NETWORK_ID', 'DTTPNMBR', 1019)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001384, 'I_CARD_INST_ID', 'DTTPNMBR', 1)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001376, 'I_CHARSET', 'DTTPCHAR', NULL)
/
update prc_parameter set lov_id = 336 where id = 10001376
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001729, 'I_DOCUMENT_TYPE', 'DTTPCHAR', 293)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001791, 'I_DEST_CURR', 'DTTPCHAR', 25)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001792, 'I_YEAR', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001793, 'I_QUARTER', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001813, 'I_BIN_ID', 'DTTPCHAR', 201)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001814, 'I_AUTHORITY_ID', 'DTTPNMBR', 281)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002039, 'I_DST_INST_ID', 'DTTPNMBR', 1)
/
update prc_parameter set param_name = 'I_BIN' where id = 10001813
/
update prc_parameter set lov_id = 184 where id = 10000372
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002202, 'I_LANG', 'DTTPCHAR', 5)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002203, 'I_CHANNEL_ID', 'DTTPNMBR', 414)
/
update prc_parameter set lov_id = null where id = 10001350
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002243, 'I_USER_SESSION_ID', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002309, 'I_HSM_DEVICE_ID', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002310, 'I_PRODUCT_ID', 'DTTPNMBR', 93)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002311, 'I_CARD_TYPE_ID', 'DTTPNMBR', 130)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002312, 'I_PERSO_PRIORITY', 'DTTPCHAR', 126)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002314, 'I_SORT_ID', 'DTTPNMBR', 83)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002341, 'I_CYCLE_DATE_TYPE', 'DTTPCHAR', 430)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002355, 'I_COUNT', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002389, 'I_TERMINAL_TYPE', 'DTTPCHAR', 28)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002390, 'I_ALREADY_LOADED', 'DTTPNMBR', 453)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002391, 'I_LOAD_REVERSALS', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002392, 'I_LOAD_REVERSED', 'DTTPNMBR', 4)
/
delete prc_parameter where id = 10002595
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002595, 'I_SLEEP_MINUTES ', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002720, 'I_CREATE_OPERATION', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002785, 'I_PROCESS_CONTAINER', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002786, 'I_SESSION_ID', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002791, 'I_UNLOAD_FILE', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002803, 'I_PRIORITY', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002863, 'I_EXPORT_CLEAR_PAN', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002862, 'I_IMPORT_CLEAR_PAN', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002876, 'I_SVFE_NETWORK', 'DTTPNMBR', 7004)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002881, 'I_BASE_RATE_EXPORT', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002882, 'I_CLEANUP_BINS', 'DTTPNMBR', 4)
/
update prc_parameter set param_name = 'I_EXPORT_ENCODED_PAN' where id = 10002863
/
update prc_parameter set param_name = 'I_EXPORT_CLEAR_PAN' where id = 10002863
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003029, 'I_INCLUDE_AFFILIATE', 'DTTPNMBR', 4)
/
update prc_parameter set lov_id = 1051 where id = 10002876
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003037, 'I_ACTION_CODE', 'DTTPNMBR', NULL)
/
update prc_parameter set lov_id=1015 where id=10001301
/
update prc_parameter set lov_id=1055 where id=10001792
/
update prc_parameter set lov_id=1056 where id=10001793
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003163, 'I_CREATE_DISP_CASE', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003653, 'I_STTL_DAY', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003654, 'I_NEED_AGGREGATE', 'DTTPNMBR', 4)
/
update prc_parameter set lov_id = 599 where id = 10003653
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003693, 'I_FILE_TYPE', 'DTTPCHAR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003770, 'I_CUSTOMER_NUMBER', 'DTTPCHAR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003881, 'I_USE_CUSTOM_METHOD', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10003982, 'I_IS_RECONCILE_BNB', 'DTTPNMBR', 4, NULL)
/
update prc_parameter set lov_id = 280 where id = 10003693
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10004063, 'I_WELCOME_GIFT', 'DTTPCHAR', 627)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004384, 'I_WITHOUT_CHECKS', 'DTTPNMBR', 4, NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004438, 'I_FILE_MERGE_MODE', 'DTTPCHAR', 712, NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004546, 'I_FOUND_BIN_PRIORITY', 'DTTPNMBR', NULL, NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004590, 'I_EXECUTION_MODE', 'DTTPCHAR', 741, NULL)
/
