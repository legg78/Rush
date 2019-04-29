-- Errors
insert into com_label (id, name, label_type, module_code, env_variable) values (10004372, 'DUPLICATE_EVENT_BUNCH_TYPE', 'ERROR', 'PRD', 'EVENT_TYPE, BALANCE_TYPE, BUNCH_TYPE_ID, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003830, 'DEBT_NOT_FOUND', 'ERROR', 'CRD', 'DEBT_ID, SPLIT_HASH')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003601, 'ACCOUNT_HAS_NO_INVOICES', 'ERROR', 'CRD', 'ACCOUNT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003602, 'ACCOUNT_SERVICE_NOT_FOUND', 'ERROR', 'CRD', 'ACCOUNT_ID, SERVICE_TYPE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003603, 'INVOICE_NOT_FOUND', 'ERROR', 'CRD', 'INVOICE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005186, 'PAYMENT_AMOUNT_EXCEEDS_DEBT_AMOUNT', 'ERROR', 'CRD', NULL)
/

-- Captions
insert into com_label (id, name, label_type, module_code) values (10008835, 'crd.account_number', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008836, 'crd.invoices', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008837, 'crd.serial_number', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008838, 'crd.date', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008839, 'crd.min_amount_due', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008840, 'crd.total_amount_due', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008841, 'crd.own_funds', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008842, 'crd.invoice_date', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008843, 'crd.due_date', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008844, 'crd.grace_date', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008845, 'crd.penalty_date', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008846, 'crd.minimum_amount_paid_in_due_date', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008847, 'crd.total_amount_paid_in_grace_period', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008848, 'crd.debt', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008849, 'crd.debts', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008850, 'crd.payment', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008851, 'crd.payments', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008852, 'crd.new', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008854, 'crd.oper_amount', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008853, 'crd.amount', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008855, 'crd.oper_type', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008856, 'crd.macros_type', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008857, 'crd.oper_currency', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008858, 'crd.oper_date', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008859, 'crd.merchant_name', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008860, 'crd.merchant_location', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10008861, 'crd.card', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009962, 'crd.card_number', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009964, 'crd.operation_type', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009967, 'crd.card_mask', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009968, 'crd.operation_date', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009969, 'crd.interests', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009972, 'crd.service', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009973, 'crd.settlements_type', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009974, 'crd.fee_type', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009975, 'crd.terminal_type', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009977, 'crd.posting_date', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009978, 'crd.settlement_day', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009980, 'crd.debt_amount', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009981, 'crd.merchant_category_code', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009983, 'crd.split_hash', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009984, 'crd.balance_type', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009985, 'crd.effective_payment_date', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009986, 'crd.paid_amount', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009987, 'crd.total_amount_of_macros', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009988, 'crd.fee', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009989, 'crd.interest_amount', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009991, 'crd.charged', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009992, 'crd.settlement_type', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010001, 'crd.reversal', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010003, 'crd.payment_amount', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010005, 'crd.expenditure', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010006, 'crd.oper_id', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010018, 'crd.credit_life', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010019, 'crd.seqnum', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010021, 'crd.bunch_type', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010022, 'crd.credit_event', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010025, 'crd.new_event_bunch_type', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010026, 'crd.edit_event_bunch_type', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003356, 'crd.pay_amount', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003614, 'crd.operation_amount', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003615, 'crd.unspent_amount', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003616, 'crd.credit_amount', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003617, 'crd.repayment_amount', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004028, 'crd.aging', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004029, 'crd.agings', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004030, 'crd.debt_pay_amount', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004031, 'crd.no_aging', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004032, 'crd.period', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004038, 'crd.invoice_debt', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004039, 'crd.invoice_payment', 'CAPTION', 'CRD', NULL)
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136612, 'LANGENG', NULL, 'PRD_ATTRIBUTE', 'LABEL', 10002287, 'Delivery statement method')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011319, 'CRD_INVOICE_OPERATIONS', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011320, 'CRD_INVOICE_INTEREST', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011330, 'crd.balances', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011332, 'crd.balance_amount', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011334, 'crd.mad', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011336, 'crd.minimum_amount_due', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011338, 'crd.repay_priority', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011363, 'crd.posting_date_of_payment', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011364, 'crd.paid_part_of_debt_amount', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011365, 'crd.posting_date_of_debt', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011366, 'crd.effective_date_of_repayment', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011388, 'INCORRECT_INVOICE_DATE', 'ERROR', 'CRD', 'INVOICE_DATE1, INVOICE_DATE2, ACCOUNT_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011389, 'OPERATION_NOT_FOUND', 'ERROR', 'CRD', 'ORIGINATOR_REFNUM, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009402, 'CRD_NO_INTEREST_DATA_FOR_ACTIVE_DEBT', 'ERROR', 'CRD', 'DEBT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006902, 'DEBT_WRONG_STATUS', 'ERROR', 'CRD', 'OLD_STATUS, NEW_STATUS')
/
--
insert into com_label (id, name, label_type, module_code, env_variable) values (10006990, 'CRD_SETTLEMENT_DATE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006991, 'CRD_OVERDUE_SUM', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006992, 'CRD_NOT_CHARGED_INTERESTS', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006993, 'CRD_AGING_PERIOD', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006994, 'CRD_PENALTY_DATE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006995, 'CRD_GRACE_DATE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006996, 'CRD_LAST_INVOICE_DATE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006997, 'CRD_TAD_IN_INVOICE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006998, 'CRD_TAD_NOT_PAID', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006999, 'CRD_MAD_IN_INVOICE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007000, 'CRD_MAD_NOT_PAID', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007001, 'CRD_TAD', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007004, 'CRD_PURCHASE_INTEREST_RATE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007005, 'CRD_PURCHASE_OVERDUE_INTEREST_RATE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007006, 'CRD_CASH_INTEREST_RATE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007007, 'CRD_CASH_OVERDUE_INTEREST_RATE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009555, 'crd.duration', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007046, 'CRD_DUE_BALANCE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007047, 'CRD_CLOSING_BALANCE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007048, 'CRD_NOT_CHARGED_FEES', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007049, 'CRD_UNSETTLED_AMOUNT', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007115, 'CRD_INVOICE_DISPUTED_OPERATIONS', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008004, 'CRD_OWN_FUNDS_BALANCE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code) values (10004198, 'crd.card_uid', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10004199, 'crd.uid', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10004200, 'crd.token', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10004201, 'crd.card_tokens', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10004202, 'crd.init_oper_id', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10004237, 'crd.bunch_details', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10004238, 'crd.add_bunch_details', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code) values (10004239, 'crd.add_bunch_type', 'CAPTION', 'CRD')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008193, 'MSG.IRR', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008195, 'MSG.APR', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010730, 'CRD_IMPOSSIBLE_TO_APPLY_PAYMENT_FOR_OPERATION', 'ERROR', 'CRD', 'PAYMENT_ID, ACCOUNT_ID, PAYMENT_REMAINDER_AMOUNT, OPER_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010741, 'NOMINAL_RATE', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010739, 'MAD_NOT_PAID', 'ERROR', 'CRD', 'MIN_AMOUNT_DUE, INVOICE_ID, ACCOUNT_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010740, 'FOUND_AGING_INDEBTEDNESS', 'ERROR', 'CRD', 'AGING_PERIOD, TOTAL_AGING_AMOUNT, ACCOUNT_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007572, 'CRD_CUMULATIVE_INTR_INDUE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007573, 'CRD_CUMULATIVE_INTR_OVERDUE', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007568, 'CRD_WAIVE_INTEREST_AMOUNT', 'LABEL', 'CRD', NULL)
/
delete from com_label where id = 10006385
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006385, 'DPP_RESTRUCT_INSTALMENTS', 'INFO', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006387, 'DPP_RESTRUCT_INFO', 'INFO', 'CRD', 'OPER_ID, TOTAL_DEBT, REG_DATE, INST_AMOUNT, BILLED_INSTALMENTS')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10002547, 'IMPOSSIBLE_TO_CALCULATE_DAILY_MAD', 'ERROR', 'CRD', 'MAD_CALC_ALGORITHM, AVAILABLE_MAD_CALC_ALGORITHM')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10002549, 'CRD_DAILY_MAD_AMOUNT', 'LABEL', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006409, 'CRD_AGING_PERIOD_NAME', 'LABEL', 'CRD', NULL)
/
update com_label set env_variable = 'ACCOUNT_ID, SPLIT_HASH' where id = 10003601
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008210, 'crd.aging_period_name', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007116, 'PAYMENT_NOT_FOUND', 'ERROR', 'CRD', 'PAYMENT_ID, SPLIT_HASH')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007591, 'WAIVE_INTEREST', 'INFO', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011595, 'CRD_SKIPPING_MAD_IS_NOT_AVAILBLE', 'INFO', 'CRD', 'REASON')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013260, 'crd.wallet_provider', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013262, 'crd.reverted_by', 'CAPTION', 'CRD', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013375, 'CRD_SKIP_MAD_DATE', 'CAPTION', NULL, NULL)
/
delete from com_label where id = 10002547
/
delete from com_label where id = 10013375
/
delete from com_label where id = 10011595
/
delete from com_label where id = 10002549
/
