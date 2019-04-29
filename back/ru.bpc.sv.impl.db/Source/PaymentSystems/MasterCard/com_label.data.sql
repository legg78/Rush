insert into com_label (id, name, label_type, module_code) values (10002059, 'MCW_CMID_NOT_REGISTRED', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002060, 'MCW_PREVIOUS_FILE_NOT_CLOSED', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002061, 'MCW_FILE_NOT_INBOUND_FOR_MEMBER', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002062, 'MCW_SYSTEM_CLEARING_MODE_DIFFERS', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002063, 'MCW_HEADER_MUST_BE_FIRST_IN_FILE', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002064, 'MCW_FILE_TRAILER_FOUND_WITHOUT_PREV_HEADER', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002065, 'MCW_FILE_ID_IN_TRAILER_DIFFERS_HEADER', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002066, 'MCW_FILE_AMOUNTS_NOT_ACTUAL', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002067, 'MCW_ROW_COUNT_NOT_ACTUAL', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002068, 'MCW_ADDENDUM_MUST_ASSOCIATED_PRESENTMENT', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002069, 'MCW_UNKNOWN_MESSAGE', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002070, 'MCW_ERROR_WRONG_VALUE', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002071, 'MCW_SUBFIELD_DELIMITER_NOT_FOUND', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002072, 'MCW_CANNOT_FIND_ORIGINAL_FILE', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002073, 'MCW_TOO_MANY_ORIGINAL_FILES', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002074, 'MCW_MANDATORY_RECONCIL_CATEGORY_EMPTY', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002075, 'MCW_UNSUPPORTED_RECONCIL_CATEGORY', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002076, 'MCW_UNKNOWN_REASON', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002077, 'MCW_TOTALS_COUNT_NOT_EQUAL', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code) values (10002078, 'MCW_TOTALS_NOT_EQUAL', 'ERROR', 'MCW')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003638, 'UNABLE_ALLOCATE_FILE_NUMBER', 'ERROR', 'MCW', 'CMID, NETWORK_ID, FILE_DATE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003639, 'ERROR_READING_NLS_CHARACTERSET', 'ERROR', 'MCW', 'PARAMETER_NAME, SQLERRM')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003640, 'MPE_INVALID_HEADER', 'ERROR', 'MCW', 'RECORD_NUM, STRING')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003641, 'MPE_WRONG_TOTAL', 'ERROR', 'MCW', 'RECORD_NUM, RECORD, TOTAL_COUNT, DATA')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003642, 'MPE_WRONG_TABLE_SEQUENCE', 'ERROR', 'MCW', 'TABLE_NAME, PREV_TABLE_NAME, RECNUM, DATA')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003643, 'MPE_WRONG_TABLE_TRAILER', 'ERROR', 'MCW', 'RECNUM, TABLE_RECNUM, TABLE_COUNT, PREV_TABLE_NAME, TABLE_NAME, DATA')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003644, 'MPE_LOAD_ERROR', 'ERROR', 'MCW', 'SESSION_FILE_ID, RECNUM, STAGE, SQLERRM')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003645, 'MCW_ERROR_WRONG_LENGTH', 'ERROR', 'MCW', 'TAG, POSITION, DATA')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003646, 'PDS_ERROR_WRONG_LENGTH', 'ERROR', 'MCW', 'DE_NAME, POSITION, DE_BODY')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003647, 'PDS_ERROR_TOO_MANY', 'ERROR', 'MCW', null)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003648, 'PDS_ERROR_WRONG_BODY', 'ERROR', 'MCW', 'DE_NAME, POSITION, PDS_LENGTH, DE_BODY')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003649, 'PDS_ERROR_WRONG_TAG', 'ERROR', 'MCW', 'DE_NAME, POSITION, DE_BODY')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003650, 'MCW_UNDEFINED_MTI', 'ERROR', 'MCW', 'MESSAGE_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003651, 'MCW_UNDEFINED_MCC', 'ERROR', 'MCW', 'MCC')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003652, 'MCW_UNDEFINED_PROC_CODE', 'ERROR', 'MCW', 'PROC_CODE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005014, 'FIRST_PRESENTMENT_MESSAGE_NOT_FOUND', 'ERROR', 'MCW', 'CARD_NUMBER,ORIGINATOR_REFNUM')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005089, 'FINANCIAL_MESSAGE_NOT_FOUND', 'ERROR', 'MCW', 'ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005108, 'MCW_FILE_ALREADY_EXIST', 'ERROR', 'MCW', 'P0105, NETWORK_ID')
/
delete from com_label where id = 10005014
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006909, 'MC_CURR_LOAD_ERROR', 'ERROR', 'MCW', 'SESSION_FILE_ID, RECNUM, SQLERRM')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006910, 'MC_CURR_LOAD_TOTAL_ERROR', 'ERROR', 'MCW', 'RECNUM, TOTALREC')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011895, 'MC_FIN_MESSAGE_IMPACT_NOT_FOUND', 'ERROR', 'MCW', 'MTI, DE024, DE003_1, IS_REVERSAL, IS_INCOMING')
/
delete from com_label where id in (10003650, 10003652)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005661, 'UNKNOWN_RECORD_TYPE', 'ERROR', 'MCW', 'REC_TYPE, REC_NUM')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009577, 'INCORRECT_CHARSET', 'ERROR', 'PRC', 'CHARSET')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009589, 'MCW_250B_BATCH_FILE_ALREADY_PROCESSED', 'ERROR', 'MCW', 'STTL_DATE, PROCESSOR_ID, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009590, 'MCW_250B_BATCH_FILE_WRONG_TEST_OPTION', 'ERROR', 'MCW', 'TEST_OPTION, FILE_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009591, 'MCW_250B_BATCH_FILE_INCORR_TRAILER_PROCESSOR', 'ERROR', 'MCW', 'HEADER_PROCESSOR_ID, TRAILER_PROCESSOR_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007067, 'MPE_BIN_RANGE_CROSSED', 'INFO', 'MCW', 'PAN_LOW_WIDE, PAN_HIGH_WIDE, PAN_LOW_NARROW, PAN_HIGH_NARROW')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007071, 'UNABLE_TO_PARSE_RECORD', 'ERROR', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007074, 'WRONG_STRUCTURE_FIN_MESSAGE', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007076, 'NOT_CREATED_ANY_ONE_OPERATION', 'ERROR', 'OPR', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001361, 'CHECK_NOT_SUCCESSFUL', 'ERROR', NULL, 'DETAILS')
/
update com_label set module_code = 'MCW' where id = 10001361
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007852, 'MCW_ATTEMPT_TO_USE_INACTIVE_PDS', 'WARN', 'MCW', 'PDS_NUMBER, PDS_DATA')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013387, 'process.business_ica', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013388, 'process.record_count', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013389, 'process.total_err_count', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013390, 'process.total_changed_count', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013391, 'process.total_added_count', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013392, 'process.total_msg_count', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013393, 'process.new_exp_date', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013394, 'process.old_exp_date', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013395, 'process.new_card_number', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013396, 'process.old_card_number', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013397, 'process.message_date', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013398, 'process.confirm_file_id', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013399, 'process.event_object_id', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013400, 'process.err_code_1', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013401, 'process.err_code_2', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013402, 'process.err_code_3', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013403, 'process.err_code_4', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013404, 'process.err_code_5', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013405, 'process.error_code_1', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013406, 'process.error_code_2', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013407, 'process.error_code_3', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013408, 'process.error_code_4', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013409, 'process.error_code_5', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013410, 'process.error_code_6', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013411, 'process.error_code_7', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013412, 'process.error_code_8', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013413, 'process.issuer_ica', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013414, 'process.acquirer_ica', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013415, 'process.request_type', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013416, 'process.request_date', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013417, 'process.process_date', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013461, 'process.err_code_6', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013462, 'process.err_code_7', 'CAPTION', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013463, 'process.err_code_8', 'CAPTION', 'MCW', NULL)
/
