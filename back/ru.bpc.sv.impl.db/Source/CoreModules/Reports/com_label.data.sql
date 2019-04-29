-- Errors
insert into com_label (id, name, label_type, module_code, env_variable) values (10004066, 'REPORT_RETURNS_EMPTY_RESULT', 'ERROR', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010207, 'RPT_NOT_ENOUGH_RIGHTS', 'ERROR', 'RPT', 'I_REPORT_ID')
/
insert into com_label (id, name, label_type, module_code) values (10002202, 'CAN_NOT_FIND_REPORT', 'ERROR', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10002206, 'BAD_PARAMETER_TYPE', 'ERROR', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10002214, 'MANDATORY_PARAM_VALUE_NOT_PRESENT', 'ERROR', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10002215, 'BAD_REPORT_STATUS', 'ERROR', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10002216, 'REPORT_RUN_NOT_FOUND', 'ERROR', 'RPT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011007, 'REPORT_PARAM_DISPLAY_ORDER_ALREADY_EXISTS', 'ERROR', 'RPT', 'REPORT_ID, DISPLAY_ORDER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003383, 'REPORT_TAG_ALREADY_EXIST', 'ERROR', 'RPT', 'REPORT_ID, TAG_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003611, 'BAD_XML_SOURCE', 'ERROR', 'RPT', 'REPORT_NAME, REPORT_DATASOURCE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003612, 'REPORT_PARAM_NOT_FOUND', 'ERROR', 'RPT', 'PARAM_NAME, REPORT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003613, 'REPORT_NOT_FOUND', 'ERROR', 'RPT', 'REPORT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004291, 'REPORT_TEMPLATE_NOT_FOUND', 'ERROR', 'RPT', 'REPORT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004351, 'REPORT_DOCUMENT_NOT_FOUND', 'ERROR', 'RPT', 'DOCUMENT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004354, 'REPORT_DATA_NOT_FOUND', 'ERROR', 'RPT', '')
/
--insert into com_label (id, name, label_type, module_code, env_variable) values (10004767, 'DUPLICATE_REPORT_DOCUMENT_CONTENT', 'ERROR', 'RPT', 'DOCUMENT_ID, CONTENT_TYPE')
--/

-- Captions
insert into com_label (id, name, label_type, module_code) values (10005984, 'rpt.banners', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005985, 'rpt.report_parameter', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005986, 'rpt.start_date_to', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005987, 'rpt.new_report', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005989, 'rpt.start_date', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005990, 'rpt.edit_banner', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005991, 'rpt.new_parameter', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005992, 'rpt.edit_parameter', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005993, 'rpt.reports', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005994, 'rpt.report_source', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005995, 'rpt.new_banner', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005996, 'rpt.source_type', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005997, 'rpt.run', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005998, 'rpt.mandatory', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10005999, 'rpt.finish_date', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10006001, 'rpt.file', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10006002, 'rpt.run_report', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10006003, 'rpt.edit_report', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10006004, 'rpt.start_date_from', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10006005, 'rpt.banner', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10006028, 'rpt.template', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10006029, 'rpt.templates', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10006030, 'rpt.new_template', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10006031, 'rpt.edit_template', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code) values (10006035, 'rpt.template_lang', 'CAPTION', 'RPT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010196, 'rpt.recompile_template', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010197, 'rpt.recompilation_successfully_completed', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010198, 'rpt.view_template', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003395, 'rpt.tags', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003396, 'rpt.new_tag', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003397, 'rpt.edit_tag', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003424, 'rpt.tag', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003422, 'rpt.roles', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003598, 'rpt.template_file_needed', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003805, 'rpt.deterministic', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003807, 'rpt.report_template', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003808, 'rpt.report', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003847, 'rpt.save_path_empty_for_deterministic_report', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003849, 'rpt.format', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003850, 'rpt.processor', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003851, 'rpt.type_not_allowed', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004355, 'rpt.document_number', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004356, 'rpt.document_date', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004357, 'rpt.document_type', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004361, 'rpt.document', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004441, 'DOCUMENT_NUMBER_DUPLICATED', 'ERROR', 'RPT', 'DOCUMENT_TYPE, DOCUMENT_NUMBER, DOCUMENT_DATE, INSTITUTION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004449, 'rpt.documents', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004825, 'msg.templates_compiled', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004827, 'rpt.compile_all_reports', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004829, 'REPORT_TAG_ALREADY_USED', 'ERROR', 'RPT', 'TAG_ID, REPORT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004861, 'rpt.view_document', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004863, 'rpt.document_number_from', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004865, 'rpt.document_number_to', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011193, 'rpt.is_sorting', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011194, 'rpt.is_grouping', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011191, 'rpt.output_parameters', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011270, 'rpt.edit_out_parameter', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011268, 'rpt.new_out_parameter', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011864, 'msg.tag_value_type_group', 'CAPTION', 'COM', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011867, 'rpt.tag_value', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011868, 'rpt.tag_type', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007802, 'rptc.report_name', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007803, 'rptc.export_report', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007804, 'rptc.export_html', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007805, 'rptc.export_xls', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007806, 'rptc.export_pdf', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007807, 'rptc.save_as_pdf', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007808, 'rptc.save_as_xls', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007809, 'rptc.confirm_export_message', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007810, 'rptc.validation_reportname_required', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007811, 'rptc.general', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007812, 'rptc.new_report_data', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007813, 'rptc.displayed_parameters', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007814, 'rptc.validation_outputparams_required', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007815, 'rptc.ascending', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007816, 'rptc.descending', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007817, 'rptc.nulls_first', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007818, 'rptc.nulls_last', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007819, 'rptc.select_raw_value', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007820, 'rptc.add_condition', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007821, 'rptc.add_before', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007822, 'rptc.add_after', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007823, 'rptc.add_into', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007824, 'rptc.number_expected', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007825, 'rptc.not_acceptable', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007826, 'rptc.parse_error', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007827, 'rptc.conditions_required', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007828, 'rptc.conditions_not_completed', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007829, 'rptc.wrong_order', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007830, 'rptc.wrong_last_node', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007831, 'rptc.empty_bracket', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007832, 'rptc.remove_sorting', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007833, 'rptc.remove_conditions', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007834, 'rptc.datasource_error', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007869, 'rptcm.DISPUTE_ID', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007870, 'rptcm.FORW_INST_BIN', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007871, 'rptcm.OPERATION_ID', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007872, 'rptcm.PAYMENT_ORDER_ID', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007873, 'rptcm.MCC', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007874, 'rptcm.OPER_CASHBACK_AMOUNT', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007875, 'rptcm.OPER_COUNT', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007876, 'rptcm.OPER_REPLACEMENT_AMOUNT', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007877, 'rptcm.POS_ENTRY_MODE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007878, 'rptcm.ORIGINATOR_REFNUM', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007879, 'rptcm.TERMINAL_OUTPUT_CAP', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007880, 'rptcm.MERCHANT_ADDRESS', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007881, 'rptcm.ACQ_INST_BIN', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007882, 'rptcm.OPER_AMOUNT_ALGORITHM', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007883, 'rptcm.OPER_AMOUNT', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007884, 'rptcm.OPER_CURRENCY', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007885, 'rptcm.STTL_CURRENCY', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007886, 'rptcm.OPER_DATE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007887, 'rptcm.CRDH_AUTH_CAP', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007888, 'rptcm.CARD_DATA_INPUT_CAP', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007889, 'rptcm.CARD_DATA_OUTPUT_CAP', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007890, 'rptcm.CARD_CAPTURE_CAP', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007891, 'rptcm.PIN_CAPTURE_CAP', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007892, 'rptcm.EMV_DATA', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007893, 'rptcm.HOST_DATE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007894, 'rptcm.POSTING_DATE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007895, 'rptcm.UNHOLD_DATE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007896, 'rptcm.ADDL_DATA', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007897, 'rptcm.IS_COMPLETED', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007898, 'rptcm.OPER_REQUEST_AMOUNT', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007899, 'rptcm.ORIGINAL_ID', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007900, 'rptcm.MATCH_ID', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007902, 'rptcm.CVC_INDICATOR', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007903, 'rptcm.UCAF_INDICATOR', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007904, 'rptcm.AUTH_CODE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007907, 'rptcm.RESP_CODE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007908, 'rptcm.POS_COND_CODE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007909, 'rptcm.CRDH_AUTH_METHOD', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007911, 'rptcm.CERTIFICATE_METHOD', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007912, 'rptcm.MERCHANT_NAME', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007914, 'rptcm.CVV2_PRESENCE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007915, 'rptcm.PIN_PRESENCE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007916, 'rptcm.CARD_PRESENCE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007917, 'rptcm.CARD_NUMBER', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007920, 'rptcm.ACCOUNT_NUMBER', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007922, 'rptcm.TERMINAL_NUMBER', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007924, 'rptcm.MERCHANT_NUMBER', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007926, 'rptcm.PAYMENT_HOST_ID', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007927, 'rptcm.IS_REPEAT', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007929, 'rptcm.CRDH_PRESENCE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007930, 'rptcm.OPER_REASON', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007931, 'rptcm.STATUS_REASON', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007932, 'rptcm.TERM_OPERATING_ENV', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007933, 'rptcm.IS_EARLY_EMV', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007935, 'rptcm.CARD_DATA_INPUT_MODE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007936, 'rptcm.PROC_MODE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007938, 'rptcm.CVV2_RESULT', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007940, 'rptcm.ACQ_DEVICE_PROC_RESULT', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007942, 'rptcm.SERVICE_CODE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007945, 'rptcm.CARDHOLDER_CERTIF', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007946, 'rptcm.MERCHANT_CERTIF', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007947, 'rptcm.CARD_EXPIR_DATE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007949, 'rptcm.CARD_STATUS', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007950, 'rptcm.MATCH_STATUS', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007952, 'rptcm.ACCOUNT_AMOUNT', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007955, 'rptcm.STTL_AMOUNT', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007956, 'rptcm.OPER_SURCHARGE_AMOUNT', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007960, 'rptcm.CRDH_AUTH_ENTITY', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007961, 'rptcm.ATC', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007962, 'rptcm.CARD_TYPE_ID', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007963, 'rptcm.PROC_TYPE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007964, 'rptcm.OPER_TYPE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007965, 'rptcm.STTL_TYPE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007971, 'rptcm.CERTIFICATE_TYPE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007973, 'rptcm.MSG_TYPE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007975, 'rptcm.IS_ADVICE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007976, 'rptcm.CAT_LEVEL', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007978, 'rptcm.TERMINAL_TYPE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007981, 'rptcm.TVR', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007983, 'rptcm.CVR', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007985, 'rptcm.OPERATION_CARD_NUMBER', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007987, 'rptcm.OPERATION_CARD_EXPIRY_DATE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007988, 'rptcm.ARN', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007990, 'rptcm.INST_ID', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007992, 'rptcm.MERCHANT_COUNTRY', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007994, 'rptcm.MERCHANT_CITY', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007997, 'rptcm.CARD_NETWORK', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007998, 'rptcm.CUSTOMER_ID', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006401, 'UNSUPPORTED_ENTITY_TYPE', 'ERROR', 'RPT', 'ENTITY_TYPE')
/
update com_label set env_variable = 'REPORT_ID, TEMPLATE_ID' where id = 10004291
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010742, 'rptcm.CARD_UID', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010746, 'rptcm.SYSTEM_DATE', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010744, 'rptcm.MONTH_BEGINNING', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010748, 'rptcm.YEAR_BEGINNING', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010750, 'rptcm.WEEK_BEGINNING', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010752, 'rptcm.HALF_YEAR_AGO', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010754, 'rptcm.FRIDAY_PREV_WEEK', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014094, 'rpt.banner_id', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014096, 'rpt.banner_name', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014098, 'rpt.banner_descr', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014100, 'rpt.show_banner_image', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014102, 'rpt.banner_image', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014104, 'rpt.images', 'CAPTION', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10014262, 'EXISTS_RPTB_CHILD_RECORD', 'ERROR', 'RPT', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013252, 'rpt.notification', 'CAPTION', 'RPT', NULL)
/
