-- Errors
insert into com_label (id, name, label_type, module_code, env_variable) values (10004802, 'DUPLICATE_MCC_SELECTION', 'ERROR', 'ACQ', 'TERMINAL_ID, OPER_TYPE, MCC')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004592, 'MERCHANT_TYPE_USED', 'ERROR', 'ACQ', 'MERCHANT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009887, 'EVNT_WRONG_ENTITY_TYPE', 'ERROR', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code) values (10000090, 'MERCHANT_TYPE_NOT_DEFINED', 'ERROR', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000091, 'MCC_NOT_DEFINED', 'ERROR', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000099, 'TERMINAL_TYPE_NOT_DEFINED', 'ERROR', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000162, 'ACCOUNT_SCHEME_NOT_FOUND', 'ERROR', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000163, 'ACCOUNT_SCHEME_MERCHANT_NOT_FOUND', 'ERROR', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001795, 'ACCOUNT_SCHEME_ACCOUNT_NOT_FOUND', 'ERROR', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001798, 'TERMINAL_NOT_FOUND', 'ERROR', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001800, 'PARENT_MERCHANT_NOT_FOUND_IN_TREE', 'ERROR', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10002770, 'CYCLIC_MERCHANT_TREE_FOUND', 'ERROR', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10002963, 'DUPLICATE_TYPE_TREE', 'ERROR', 'ACQ')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003806, 'ACC_SCHEME_ALREADY_USED', 'ERROR', 'ACQ', 'SCHEME_ID, CUSTOMER_ID')
/

-- Captions
insert into com_label (id, name, label_type, module_code) values (10000762, 'acq.merchants', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000763, 'acq.merchant_id', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000764, 'acq.product', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000767, 'acq.terminals', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000769, 'acq.terminal_id', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000772, 'acq.state', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000774, 'acq.control', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000775, 'acq.operations', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000777, 'acq.applications', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000781, 'acq.terminal_type', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000783, 'acq.card_data_input_cap', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000784, 'acq.crdh_auth_cap', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000785, 'acq.card_capture_cap', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000787, 'acq.crdh_data_present', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000788, 'acq.card_data_present', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000789, 'acq.card_data_input_mode', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000790, 'acq.crdh_auth_method', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000791, 'acq.crdh_auth_entity', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000792, 'acq.card_data_output_cap', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000793, 'acq.term_data_output_cap', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000794, 'acq.pin_capture_cap', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000795, 'acq.unattended', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000796, 'acq.connectivity', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000797, 'acq.keys', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000827, 'acq.products', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000829, 'acq.product_id', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000831, 'acq.institution', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000834, 'acq.merchant_templates', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000836, 'acq.terminal_templates', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000838, 'acq.conditions', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000840, 'acq.billing_schemes', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000842, 'acq.statements', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000844, 'acq.new_product', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000846, 'acq.edit_product', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000850, 'acq.parent_product', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000874, 'acq.merchant_type', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000876, 'acq.edit_mrch_templ', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000878, 'acq.new_mrch_templ', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000880, 'acq.license_type', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000882, 'acq.report_type', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000884, 'acq.edit_terminal_templ', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000886, 'acq.new_terminal_templ', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000888, 'acq.term_operating_env', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000890, 'acq.billing_id', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000892, 'acq.account_type', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000894, 'acq.account_currency', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000896, 'acq.operation_type', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000898, 'acq.new_billing_scheme', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000900, 'acq.edit_billing_scheme', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000902, 'acq.reason', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000904, 'acq.currency_code', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000906, 'acq.sttl_type', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000907, 'acq.operating_sign', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000909, 'acq.priority', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000911, 'acq.view_terminal_templ', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000913, 'acq.view_mrch_tmpl', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10000915, 'acq.view_billing_scheme', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001100, 'acq.parent_merchant_type', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001101, 'acq.add_merchant_type', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001102, 'acq.new_node', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001106, 'acq.add_node', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001108, 'acq.new_merchant_type', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001110, 'acq.merchant_type_hier', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001663, 'acq.scale', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001664, 'acq.mod_name', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001665, 'acq.start_date', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001666, 'acq.end_date', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001667, 'acq.value', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10001714, 'acq.mod', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006251, 'acq.reimbursement_date', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006252, 'acq.license_number', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006254, 'acq.terminal_number', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006256, 'acq.terminal_template', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006259, 'acq.net_amount', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006263, 'acq.operation_date_from', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006268, 'acq.new_batch', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006271, 'acq.edit_batch', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006277, 'acq.merchant', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006279, 'acq.profile', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006281, 'acq.tax_amount', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006282, 'acq.modifier', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006283, 'acq.agreement_number', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006286, 'acq.cheque_number', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006287, 'acq.agreement_start_date', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006288, 'acq.gross_amount', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006292, 'acq.status', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006295, 'acq.oper_date', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006296, 'acq.reimbursement_date_to', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006299, 'acq.agreement_end_date', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006300, 'acq.reimb_channel', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006301, 'acq.cat_level', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006307, 'acq.payment_mode', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006310, 'acq.is_mac', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006311, 'acq.reimbursement_batch', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006313, 'acq.posting_date', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006314, 'acq.edit_operation', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006319, 'acq.merchant_number', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006320, 'acq.edit_channel', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006324, 'acq.reimb_channels', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006327, 'acq.acquiring_accounts', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006332, 'acq.reimb_batches', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006334, 'acq.new_channel', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006335, 'acq.reimbursement', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006341, 'acq.templ_desc', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006344, 'acq.reload', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006346, 'acq.merchant_name', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006347, 'acq.session_file_id', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006348, 'acq.environment', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006355, 'acq.reimbursement_date_from', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006360, 'acq.oper_count', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006361, 'acq.service_charge', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006362, 'acq.channel_number', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10006363, 'acq.operation_date_to', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10009298, 'acq.terminal_profile', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10009299, 'acq.plastic_number', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10009300, 'acq.account_patterns', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10009301, 'acq.account_schemes', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10009302, 'acq.edit_account_scheme', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10009303, 'acq.new_account_scheme', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10009304, 'acq.operation_sign', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10009305, 'acq.terminal', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code) values (10009306, 'acq.sign', 'CAPTION', 'ACQ')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010228, 'acq.new_account_pattern', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010229, 'acq.edit_account_pattern', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003472, 'acq.merchant_location', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003745, 'acq.add_revenue_sharing', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003746, 'acq.edit_revenue_sharing', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003747, 'acq.revenue_sharing', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003880, 'acq.account_scheme', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003889, 'acq.view_account_pattern', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003891, 'acq.new_operation', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003920, 'acq.merchant_label', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004750, 'acq.terminal_output_cap', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004768, 'acq.available_network', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004769, 'acq.available_operation', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004770, 'acq.available_currency', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004771, 'acq.cash_dispenser_present', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004772, 'acq.payment_possibility', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004773, 'acq.use_card_possibility', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004774, 'acq.cash_in_present', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005005, 'acq.mcc_selection_tpl', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005007, 'acq.mcc_redefinitions', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005009, 'acq.merchant_name_redefinition', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005090, 'acq.edit_mcc_selection_tpl', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005091, 'acq.new_mcc_selection_tpl', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005095, 'acq.mcc_redefinition_group', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005290, 'CYCLIC_MERCHANT_DATA_FOUND', 'ERROR', 'ACQ', 'MERCHANT_ID, PARENT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005584, 'INCORRECT_PARENT_MERCHANT_TYPE', 'ERROR', 'ACQ', 'I_PARENT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005585, 'BAD_ROOT_MERCHANT', 'ERROR', 'ACQ', 'I_MERCHANT_TYPE')
/

insert into com_label (id, name, label_type, module_code, env_variable) values (10011457, 'NOT_ENOUGH_DATA_TO_FIND_MERCHANTS', 'ERROR', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011458, 'NOT_ENOUGH_DATA_TO_FIND_TERMINALS', 'ERROR', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005677, 'acq.file_id', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005700, 'acq.acq_business_id', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005702, 'acq.req_pay_service', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005703, 'acq.usage_code', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005704, 'acq.reason_code', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005707, 'acq.auth_char_ind', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005708, 'acq.pos_terminal_cap', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005710, 'acq.inter_fee_ind', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005714, 'acq.reimburst_attr', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005722, 'acq.spec_chargeback_ind', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007015, 'acq.pin_block_format', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009652, 'MERCHANT_NUMBER_IS_TOO_LONG', 'ERROR', 'ACQ', 'MERCHANT_NUMBER, MERCHANT_NUMBER_LENGTH, MAX_LENGTH')
/
update com_label set env_variable = 'MCC, OPER_TYPE, PURPOSE_ID, OPER_REASON' where id = 10004802
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007041, 'acq.instalment_support', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007790, 'MERCHANT_IS_NOT_FOUND', 'ERROR', 'ACQ', 'MERCHANT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007356, 'DEVICE_ALREADY_USED', 'ERROR', 'ACQ', 'DEVICE_ID, TERMINAL_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008009, 'TERMINAL_TYPE_INCORRECT', 'ERROR', 'ACQ', 'TERMINAL_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004196, 'STATISTIC_NOT_FOUND', 'ERROR', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10002536, 'acq.acquirer_iin', 'CAPTION', 'ACQ', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008202, 'TOO_MANY_TERMINALS', 'ERROR', 'ACQ', 'TERMINAL_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007127, 'PARTNER_ID_CODE_IS_NOT_UNIQUE', 'ERROR', 'ACQ', 'PARTNER_ID_CODE, INST_ID')
/
