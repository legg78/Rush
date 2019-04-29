insert into com_label (id, name, label_type, module_code, env_variable) values (10011470, 'AMX_CANNOT_CREATE_REVERSAL', 'ERROR', 'AMX', 'FIN_REC_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011471, 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_CR_AMOUNT', 'ERROR', 'AMX', 'FILE_CR_AMOUNT, INC_CR_AMOUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011475, 'AMX_ERR_PARSE_REASON_CODES', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011476, 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_DT_COUNT', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011477, 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_FORW_INST', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011478, 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_TOTAL_AMOUNT', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011479, 'AMX_ERR_SEARCH_ORIGIN_FILE', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011480, 'AMX_INVALID_FORW_INST', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011481, 'AMX_ERR_SEARCH_ORIGIN_MSG', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011482, 'AMX_BIN_NOT_REGISTERED', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011483, 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_MSG_NUMBER', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011484, 'AMX_PROC_CODE_RVS_NOT_FOUND', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011496, 'AMX_UNKNOWN_MSG_REASON_CODE', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011497, 'AMX_ERROR_ASSIGN_DISPUTE', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011498, 'AMX_CANNOT_CREATE_FULFILLMENT', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011499, 'AMX_CANNOT_CREATE_FIRST_CHBCK', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011501, 'AMX_CANNOT_CREATE_RETRIEVAL_REQ', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011502, 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_FILE_NUMBER', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011505, 'AMX_CANNOT_CREATE_SECOND_PRES', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011506, 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_CR_COUNT', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011507, 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_RECEIV_INST', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011508, 'AMX_CANNOT_CREATE_FINAL_CHBCK', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011510, 'AMX_INVALID_ACTION_CODE', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011511, 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_DT_AMOUNT', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011512, 'AMX_FILE_ALREADY_PROCESSED', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011513, 'AMX_FIRST_PRES_NOT_FOUND', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011514, 'AMX_INVALID_MESSAGE_IMPACT', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011515, 'AMX_WRONG_TEST_OPTION_PARAMETER', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011516, 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_DATE', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011518, 'FIRST_PRES_NOT_FOUND', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011520, 'AMX_INVALID_MESSAGE_NUMBER', 'ERROR', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011523, 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_ACTION_CODE', 'ERROR', 'AMX', NULL)
/
update com_label set env_variable = 'FILE_DT_COUNT, INC_DT_COUNT' where id = 10011476
/
update com_label set env_variable = 'FILE_AMOUNT, INC_AMOUNT' where id = 10011478
/
update com_label set env_variable = 'FORW_INST_CODE' where id = 10011480
/
update com_label set env_variable = 'RECEIV_INST_CODE' where id = 10011482
/
update com_label set env_variable = 'INC_MSG_NUMBER, FILE_MSG_NUMBER' where id = 10011483
/
update com_label set env_variable = 'PROC_CODE' where id = 10011484
/
update com_label set env_variable = 'REASON_CODE' where id = 10011496
/
update com_label set env_variable = 'ORIGINAL_FIN_ID' where id = 10011498
/
update com_label set env_variable = 'ORIGINAL_FIN_ID' where id = 10011499
/
update com_label set env_variable = 'ORIGINAL_FIN_ID' where id = 10011501
/
update com_label set env_variable = 'INC_FILE_NUMBER, FILE_FILE_NUMBER' where id = 10011502
/
update com_label set env_variable = 'ORIGINAL_FIN_ID' where id = 10011505
/
update com_label set env_variable = 'FILE_CR_COUNT, INC_CR_COUNT' where id = 10011506
/
update com_label set env_variable = 'INC_RCV_CODE, FILE_RCV_CODE' where id = 10011507
/
update com_label set env_variable = 'ORIGINAL_FIN_ID' where id = 10011508
/
update com_label set env_variable = 'ACTION_CODE' where id = 10011510
/
update com_label set env_variable = 'FILE_DT_AMOUNT, INC_DT_AMOUNT' where id = 10011511
/
update com_label set env_variable = 'FILE_NUMBER' where id = 10011512
/
update com_label set env_variable = 'AUTH_ID, CARD_MASK, ORIGINATOR_REFNUM' where id = 10011513
/            
update com_label set env_variable = 'MTID, FUNC_CODE, PROC_CODE, IS_INCOMING' where id = 10011514
/
update com_label set env_variable = 'PROC_ACTION_CODE, FILE_ACTION_CODE' where id = 10011515
/
update com_label set env_variable = 'INC_DATE, FILE_DATE' where id = 10011516
/
update com_label set env_variable = 'MSG_NUMBER' where id = 10011520
/
update com_label set env_variable = 'INC_ACTION_CODE, FILE_ACTION_CODE' where id = 10011523
/
delete from com_label where id = 10011483
/
delete from com_label where id = 10011497
/
delete from com_label where id = 10011513
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013206, 'amx.amount_requested', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013207, 'amx.dispensed_currency', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013208, 'amx.record_type', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013209, 'amx.record_seq_num', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013210, 'amx.system_trace_audit_number', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013211, 'amx.amount_ind', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013212, 'amx.sttl_conv_rate', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013214, 'amx.sttl_amount_requested', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013215, 'amx.sttl_amount_approved', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013217, 'amx.sttl_amount_dispensed', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013218, 'amx.sttl_network_fee', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013219, 'amx.sttl_fee_other', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013220, 'amx.card_acceptor_country_code', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013221, 'amx.term_country_code', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013222, 'amx.cardmember_billing_country_code', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013223, 'amx.term_location', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013236, 'amx.trans_ind', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013237, 'amx.orig_action_code', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013238, 'amx.additional_ref_num', 'CAPTION', 'AMX', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013239, 'amx.trans_id', 'CAPTION', 'AMX', NULL)
/
