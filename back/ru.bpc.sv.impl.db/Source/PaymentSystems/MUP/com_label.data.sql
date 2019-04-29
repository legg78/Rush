insert into com_label (id, name, label_type, module_code, env_variable) values (10009710, 'MUP_CMID_NOT_REGISTRED', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009711, 'MUP_PREVIOUS_FILE_NOT_CLOSED', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009712, 'MUP_FILE_NOT_INBOUND_FOR_MEMBER', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009713, 'MUP_SYSTEM_CLEARING_MODE_DIFFERS', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009714, 'MUP_HEADER_MUST_BE_FIRST_IN_FILE', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009715, 'MUP_FILE_TRAILER_FOUND_WITHOUT_PREV_HEADER', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009716, 'MUP_FILE_ID_IN_TRAILER_DIFFERS_HEADER', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009717, 'MUP_FILE_AMOUNTS_NOT_ACTUAL', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009718, 'MUP_ROW_COUNT_NOT_ACTUAL', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009719, 'MUP_ADDENDUM_MUST_ASSOCIATED_PRESENTMENT', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009720, 'MUP_UNKNOWN_MESSAGE', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009721, 'MUP_ERROR_WRONG_VALUE', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009722, 'MUP_SUBFIELD_DELIMITER_NOT_FOUND', 'ERROR', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009723, 'MUP_ERROR_WRONG_LENGTH', 'ERROR', 'MUP', 'TAG, POSITION, DATA')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009724, 'MUP_FILE_ALREADY_EXIST', 'ERROR', 'MUP', 'P0105, NETWORK_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009727, 'MUP_CANNOT_FIND_ORIGINAL_FILE', 'ERROR', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009728, 'MUP_TOO_MANY_ORIGINAL_FILES', 'ERROR', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009729, 'MUP_MANDATORY_RECONCIL_CATEGORY_EMPTY', 'ERROR', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009730, 'MUP_UNKNOWN_REASON', 'ERROR', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009731, 'MUP_TOTALS_COUNT_NOT_EQUAL', 'ERROR', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009732, 'MUP_TOTALS_NOT_EQUAL', 'ERROR', 'MCW', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009744, 'MUP_FIN_MESSAGE_IMPACT_NOT_FOUND', 'ERROR', 'MCW', 'MTI, DE024, DE003_1, IS_REVERSAL, IS_INCOMING')
/
update com_label set module_code = 'MUP' where id = 10009727
/
update com_label set module_code = 'MUP' where id = 10009728
/
update com_label set module_code = 'MUP' where id = 10009729
/
update com_label set module_code = 'MUP' where id = 10009730
/
update com_label set module_code = 'MUP' where id = 10009731
/
update com_label set module_code = 'MUP' where id = 10009732
/
update com_label set module_code = 'MUP' where id = 10009744
/

insert into com_label (id, name, label_type, module_code, env_variable) values (10014108, 'rpt.id', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014109, 'rpt.inst_id', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014110, 'rpt.inst_name', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014111, 'rpt.session_id', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014112, 'rpt.file_id', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014113, 'rpt.file_name', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014114, 'rpt.file_date', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014115, 'rpt.record_number', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014116, 'rpt.status', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014117, 'rpt.report_type', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014118, 'rpt.activity_type', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014119, 'rpt.orig_inst_id', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014120, 'rpt.mti', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014121, 'rpt.card_number', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014122, 'rpt.proc_code', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014123, 'rpt.trans_amount', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014124, 'rpt.recon_amount', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014125, 'rpt.recon_conv_rate', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014126, 'rpt.local_date_time', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014127, 'rpt.pos_entry_mode', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014128, 'rpt.func_code', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014129, 'rpt.msg_reason', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014130, 'rpt.mcc', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014131, 'rpt.acq_ref_data', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014132, 'rpt.rrn', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014133, 'rpt.app_code', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014134, 'rpt.service_code', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014135, 'rpt.card_acc_term_id', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014136, 'rpt.card_acc_id_code', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014137, 'rpt.card_acc_name', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014138, 'rpt.card_acc_street', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014139, 'rpt.card_acc_city', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014140, 'rpt.card_acc_post_code', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014141, 'rpt.card_acc_region', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014142, 'rpt.card_acc_country', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014143, 'rpt.is_reversal', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014144, 'rpt.ref_file_date', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014145, 'rpt.fee_amount', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014146, 'rpt.curr_exponents', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014147, 'rpt.is_settlement', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014148, 'rpt.fin_data', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014149, 'rpt.orig_trans_agent_id', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014150, 'rpt.sttl_data', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014151, 'rpt.trans_curr_code', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014152, 'rpt.recont_curr_code', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014153, 'rpt.addl_amount', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014154, 'rpt.trans_cycle_id', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014155, 'rpt.data_record', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014156, 'rpt.trailer_id', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014157, 'rpt.member_id', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014158, 'rpt.trailer_endpoint', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014159, 'rpt.record_count', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014160, 'rpt.lang', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014215, 'rpt.card_acc_address', 'CAPTION', 'MUP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013326, 'MUP_FIN_MESSAGE_NF_FOR_P0375', 'ERROR', 'MUP', NULL)
/
