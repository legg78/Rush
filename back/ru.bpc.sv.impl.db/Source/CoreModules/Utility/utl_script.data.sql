insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date) values (10000001, 'Domestic BIN ranges updating', null, 'NET', 'DSRTAFTR', 'DSATBLPT', 0, null, null)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date) values (10000002, 'Credit module - split overdue and charge penalty functionality', null, 'CRD', 'DSRTAFTR', 'DSATBLPT', 0, null, null)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date) values (10000021, 'Credit module - update posting_order in crd_debt_balance', null, 'CRD', 'DSRTAFTR', 'DSATPTCH', 0, null, null)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date) values (10000022, 'Credit module - update posting_order in crd_debt_interest', null, 'CRD', 'DSRTAFTR', 'DSATPTCH', 0, null, null)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date) values (10000023, 'Events module - update inst_id', null, 'EVT', 'DSRTAFTR', 'DSATPTCH', 0, null, null)
/
update utl_script set applying_type = 'DSATBLPT' where id = 10000023
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date) values (10000024, 'Operations unloading - create new parameter on base of old parameters', null, 'OPR', 'DSRTAFTR', 'DSATPTCH', 0, null, null)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date) values (10000025, 'Utility module - Trim external_auth_id, external_orig_id from table aut_auth', null, 'UTL', 'DSRTAFTR', 'DSATBLPT', 0, null, null)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date) values (10000026, 'Terminal IDs sequences - synchronization of sequence and ID of terminals without the influence IDs of terminal templates', null, 'ACQ', 'DSRTAFTR', 'DSATBLPT', 0, null, null)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date) values (10000061, 'Remove privilege VIEW_CUP_DISPUTES from repository and current user settings.', null, 'CUP', 'DSRTAFTR', 'DSATBLPT', 0, null, null)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date) values (10000062, 'Remove privilegies VIEW_CUP_SESSION, VIEW_CUP_MODULE_GENERAL_SETTINGS, VIEW_CUP_AGGREGATION from repository and current user settings.', null, 'CUP', 'DSRTAFTR', 'DSATBLPT', 0, null, null)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date) values (10000064, 'Fill payment order number in table PMO_ORDER if it not exists.', null, 'PMO', 'DSRTAFTR', 'DSATBLPT', 0, null, null)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date) values (10000084, 'Fill card_uid in table ISS_CARD_INSTANCE if it is null. Set card_uid equal card_id.', null, 'ISS', 'DSRTAFTR', 'DSATBLPT', 0, null, null)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000104, 'Issuing module - update cardholder name to upper case', NULL, 'ISS', 'DSRTAFTR', 'DSATBLPT', 0, NULL, NULL, NULL)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000105, 'Mastercard currency update file rates and currencies correction', NULL, 'MCW', 'DSRTAFTR', 'DSATPTCH', 0, NULL, NULL, 'DSMLONEL')
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000106, 'Utility module - Update session file id for MasterCard, Visa, UnionPay, JCB', NULL, 'UTL', 'DSRTAFTR', 'DSATBLPT', 0, NULL, NULL, NULL)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000146, 'Utility module - Create events for Visa and MasterCard Quarterly reports', NULL, 'UTL', 'DSRTAFTR', 'DSATBLPT', 0, NULL, NULL, NULL)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000107, 'Duplicate value of aup_auth_tag.reference = DF8642 fix', NULL, 'UTL', 'DSRTBEFR', 'DSATBLPT', 0, NULL, NULL, 'DSMLONEL')
/
update utl_script set run_type = 'DSRTAFTR' where id = 10000107
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, script_body, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000148, 'Fill csm_case from applications', NULL, 'CSM', 'DSRTAFTR', 'DSATBLPT', NULL, 0, NULL, NULL, NULL)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, script_body, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000173, 'Replace old processes "Export dictionaries to DWH" and "Export dictionaries to Merchant Portal" with new process "Export dictionaries to external system" ', NULL, 'COM', 'DSRTAFTR', 'DSATBLPT', NULL, 0, NULL, NULL, NULL)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000153, 'Set 1 for the "Last card instance sequential number" else 0', NULL, 'ISS', 'DSRTAFTR', 'DSATBLPT', 0, NULL, NULL, NULL)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000174, 'Set the "Event type" values for event objects with status "Ready to process"', NULL, 'EVT', 'DSRTAFTR', 'DSATBLPT', 0, NULL, NULL, NULL)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000195, 'Fixed "procedure_name" for events of the process "Export cards numbers"', NULL, 'ISS', 'DSRTAFTR', 'DSATBLPT', 0, NULL, NULL, NULL)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000196, 'Flexible fields of entities card and customer use standard', NULL, 'COM', 'DSRTAFTR', 'DSATBLPT', 0, NULL, NULL, NULL)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000198, 'Utility module - Trim trace_number from table aut_auth', NULL, 'UTL', 'DSRTAFTR', 'DSATBLPT', 0, NULL, NULL, NULL)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000241, 'Fixed "Priority" for match conditions', NULL, 'OPR', 'DSRTAFTR', 'DSATBLPT', 0, NULL, NULL, NULL)
/
insert into utl_script (id, script_name, script_desc, module_code, run_type, applying_type, is_processed, last_start_date, last_finish_date, multiple_launch) values (10000242, 'Fill split_hash for products, services and its attributes', NULL, 'PRD', 'DSRTAFTR', 'DSATBLPT', 0, NULL, NULL, NULL)
/
