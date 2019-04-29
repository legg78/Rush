insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000377, 10000403, NULL, 'CRD_INTEREST_CHARGE', 'DTTPNMBR', NULL, 10, 'ENTTAGRP', NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000378, 10000403, 10000377, 'CRD_INTEREST_RATE', 'DTTPNMBR', NULL, 10, 'ENTTFEES', 'FETP1001', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000379, 10000403, 10000377, 'CRD_INTEREST_CHARGE_PERIOD', 'DTTPNMBR', NULL, 20, 'ENTTCYCL', 'CYTP1005', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000380, 10000403, NULL, 'CRD_INVOICING', 'DTTPNMBR', NULL, 20, 'ENTTAGRP', NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000381, 10000403, 10000380, 'CRD_INVOICING_PERIOD', 'DTTPNMBR', NULL, 10, 'ENTTCYCL', 'CYTP1001', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000382, 10000403, 10000380, 'CRD_MAD_PERCENTAGE', 'DTTPNMBR', NULL, 20, 'ENTTFEES', 'FETP1002', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000383, 10000403, 10000380, 'CRD_MAD_THRESHOLD', 'DTTPNMBR', NULL, 30, 'ENTTFEES', 'FETP1007', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000384, 10000403, NULL, 'CRD_GRACE_PERIOD', 'DTTPNMBR', NULL, 30, 'ENTTAGRP', NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000390, 10000403, 10000380, 'CRD_DUE_DATE_PERIOD', 'DTTPNMBR', NULL, 40, 'ENTTCYCL', 'CYTP1003', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000391, 10000403, 10000387, 'CRD_PENALTY_FEE', 'DTTPNMBR', NULL, 20, 'ENTTFEES', 'FETP1003', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000392, 10000403, NULL, 'CRD_REPAYMENT', 'DTTPNMBR', NULL, 50, 'ENTTAGRP', NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000393, 10000403, 10000392, 'CRD_REPAYMENT_PRIORITY', 'DTTPNMBR', NULL, 10, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000394, 10000403, NULL, 'CRD_EXCEED_LIMIT', 'DTTPNMBR', NULL, 60, 'ENTTAGRP', NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000395, 10000403, 10000394, 'CRD_LIMIT_VALUE', 'DTTPNMBR', NULL, 10, 'ENTTFEES', 'FETP1004', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000396, 10000403, 10000394, 'CRD_PRIVIDE_LIMIT_FEE', 'DTTPNMBR', NULL, 20, 'ENTTFEES', 'FETP1005', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000397, 10000403, 10000394, 'CRD_CHANGE_LIMIT_FEE', 'DTTPNMBR', NULL, 30, 'ENTTFEES', 'FETP1006', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000398, 10000403, 10000387, 'CRD_PENALTY_PERIOD', 'DTTPNMBR', NULL, 30, 'ENTTCYCL', 'CYTP1004', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000386, 10000403, 10000384, 'CRD_GRACE_PERIOD_LENGTH', 'DTTPNMBR', NULL, 20, 'ENTTCYCL', 'CYTP1002', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000387, 10000403, NULL, 'CRD_AGING_PENALTY', 'DTTPNMBR', NULL, 40, 'ENTTAGRP', NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000385, 10000403, 10000384, 'CRD_GRACE_PERIOD_ENABLE', 'DTTPNMBR', 4, 10, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000388, 10000403, 10000387, 'CRD_CHARGE_PENALTY', 'DTTPNMBR', 4, 10, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000399, 10000403, 10000384, 'CRD_MINIMUM_AMOUNT_TOLERANCE', 'DTTPNMBR', NULL, 30, 'ENTTFEES', 'FETP1008', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000400, 10000403, 10000387, 'CRD_TOTAL_AMOUNT_TOLERANCE', 'DTTPNMBR', NULL, 40, 'ENTTFEES', 'FETP1009', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000782, 10000403, 10000380, 'CRD_FLOATING_INVOICE_PERIOD', 'DTTPNMBR', 4, 50, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000783, 10000403, 10000377, 'CRD_FORCED_INTEREST_CHARGE_PERIOD', 'DTTPNMBR', NULL, 30, 'ENTTCYCL', 'CYTP1006', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000785, 10000403, 10000392, 'CRD_USE_OWN_FUNDS', 'DTTPNMBR', 4, 30, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000786, 10000403, 10000394, 'CRD_LIMIT_SERVICING_FEE', 'DTTPNMBR', NULL, 40, 'ENTTFEES', 'FETP1010', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000787, 10000403, 10000384, 'CRD_GRACE_REPAYMENT_AMOUNT', 'DTTPNMBR', NULL, 40, 'ENTTFEES', 'FETP1011', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000788, 10000403, 10000384, 'CRD_GRACE_INTEREST_RATE', 'DTTPNMBR', NULL, 50, 'ENTTFEES', 'FETP1012', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000913, 10000403, 10000392, 'CRD_REPAYMENT_CONDITION', 'DTTPCHAR', 171, 30, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10001828, 10000403, 10000377, 'CRD_INTEREST_CALC_START_DATE', 'DTTPCHAR', 355, 40, NULL, NULL, 'SADLPRDT', 1)
/
update prd_attribute set attr_name = 'CRD_MANDATORY_AMOUNT_DUE' where id = 10000382
/
update prd_attribute set attr_name = 'CRD_MAD_MINIMUM' where id = 10000383
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002134, 10000403, 10000392, 'CRD_REPAY_MAD_FIRST', 'DTTPNMBR', 4, 40, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002287, 10000403, 10000380, 'CRD_INVOICING_DELIVERY_STATEMENT_METHOD', 'DTTPCHAR', 105, 51, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002319, 10000403, 10000377, 'CRD_ADDITIONAL_INTEREST_RATE', 'DTTPNMBR', NULL, 15, 'ENTTFEES', 'FETP1013', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002378, 10000403, 10000377, 'CRD_ALGORITHM_CALC_INTEREST', 'DTTPCHAR', 450, 12, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002386, 10000403, 10000392, 'CRD_CHARGE_INTR_BEFORE_PAYMENT', 'DTTPNMBR', 4, 50, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002771, 10000403, NULL, 'CRD_RESERV_CALC', 'DTTPNMBR', NULL, 70, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002772, 10000403, 10002771, 'CRD_RESERV_RATE', 'DTTPNMBR', NULL, 10, 'ENTTFEES', 'FETP0401', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002773, 10000403, 10002771, 'CRD_GUARANTEE_TYPE', 'DTTPCHAR', 476, 20, NULL, NULL, 'SADLOBJT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002774, 10000403, 10002771, 'CRD_GUARANTEE_SUM', 'DTTPNMBR', NULL, 30, NULL, NULL, 'SADLOBJT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002817, 10000403, 10000392, 'CRD_PAYMENT_REV_PROC_METHOD', 'DTTPCHAR', 489, 60, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002837, 10000403, 10000394, 'CRD_OVERLIMIT_FEE', 'DTTPNMBR', NULL, 50, 'ENTTFEES', 'FETP1014', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002937, 10000403, 10000387, 'CRD_OVERDUE_DATE', 'DTTPNMBR', NULL, 50, 'ENTTCYCL', 'CYTP1008', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002938, 10000403, 10000387, 'CRD_ALGORITHM_CALC_PENALTY', 'DTTPCHAR', 461, 60, NULL, NULL, 'SADLPRDT', 1)
/
update prd_attribute set parent_id = 10000387 where id = 10000399
/
update prd_attribute set parent_id = 10000384 where id = 10000400
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000001, 10000403, 10000377, 'CRD_INTEREST_START_DATE_TRANSFORMATION', 'DTTPCHAR', 499, 50, NULL, NULL, 'SADLPRDT', 1)
/
update prd_attribute set id = 10003084 where id = 10000001
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003190, 10000403, 10000377, 'CRD_INTEREST_FOR_PAYMENT_ORDER', 'DTTPNMBR', NULL, 60, 'ENTTFEES', 'FETP0402', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003254, 10000403, 10000394, 'CRD_CHANGE_CUSTOMER_CREDIT_LIMIT_FEE', 'DTTPNMBR', NULL, 60, 'ENTTFEES', 'FETP0404', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003295, 10000403, 10000380, 'CRD_STATEMENT_DATE', 'DTTPNMBR', NULL, 60, 'ENTTCYCL', 'CYTP0406', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003298, 10003288, 10003289, 'CRD_CUSTOMER_OVERLIMIT_VALUE', 'DTTPNMBR', NULL, 30, 'ENTTFEES', 'FETP0905', 'SADLPRDT', 1)
/
delete from prd_attribute where id = 10003295
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003330, 10000403, 10000394, 'CRD_ACCOUNT_CASH_LIMIT_VALUE', 'DTTPNMBR', NULL, 70, 'ENTTLIMT', 'LMTP0408', 'SADLPRDT', 1)
/
update prd_attribute set id = 10003350 where id = 10003330
/
delete from prd_attribute where id = 10003298
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003351, 10000403, 10000394, 'CRD_ALLOWABLE_OVERLIMIT_FEE', 'DTTPNMBR', NULL, 80, 'ENTTFEES', 'FETP0411', 'SADLPRDT', 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003359, 10000403, 10000380, 'CRD_SEND_BLANK_STATEMENT', 'DTTPNMBR', 4, 60, NULL, NULL, 'SADLPRDT', 1)
/
update prd_attribute set parent_id = 10000392, attr_name = 'CRD_DIRECT_DEBIT_AMOUNT' where id = 10003190
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003461, 10000403, 10000377, 'CRD_ALGORITHM_CALC_RETURN_INTEREST_PART', 'DTTPCHAR', 577, 60, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003462, 10000403, 10000377, 'CRD_INTEREST_CALC_END_DATE', 'DTTPCHAR', 578, 70, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003471, 10000403, 10000380, 'CRD_CREDIT_INVOICE_CREATION_THRESHOLD', 'DTTPNMBR', NULL, 70, 'ENTTFEES', 'FETP1015', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003501, 10000403, 10000377, 'CRD_PERIODIC_INTEREST_CHARGE', 'DTTPNMBR', NULL, 35, 'ENTTCYCL', 'CYTP0406', 'SADLPRDT', 1)
/
update prd_attribute set is_visible = 1 where id = 10003351
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003516, 10000403, 10000392, 'CRD_DIRECT_DEBIT_PERIOD', 'DTTPNMBR', NULL, 80, 'ENTTCYCL', 'CYTP0407', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003612, 10000403, NULL, 'CRD_STATEMENT', 'DTTPNMBR', NULL, 80, 'ENTTAGRP', NULL, NULL, 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003613, 10000403, 10003612, 'CRD_STATEMENT_MESSAGE', 'DTTPCHAR', NULL, 10, NULL, NULL, 'SADLPRDT', 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003619, 10000403, 10000387, 'CRD_AGING_ZERO_PERIOD', 'DTTPNMBR', NULL, 55, 'ENTTCYCL', 'CYTP0408', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003732, 10000403, 10000392, 'CRD_REG_MAD_EVENT_IN_PENALTY_PERIOD', 'DTTPNMBR', 4, 190, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003686, 10000403, 10000394, 'CRD_SOFT_LIMIT', 'DTTPNMBR', NULL, 90, 'ENTTLIMT', 'LMTP0419', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003746, 10000403, 10000380, 'CRD_EXTRA_MAD', 'DTTPNMBR', NULL, 80, 'ENTTFEES', 'FETP0421', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003747, 10000403, 10000380, 'CRD_EXTRA_DUE_DATE', 'DTTPNMBR', NULL, 90, 'ENTTCYCL', 'CYTP0411', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003748, 10000403, 10000380, 'CRD_MAD_CALC_ALGORITHM', 'DTTPCHAR', 611, 100, NULL, NULL, 'SADLPRDT', 1)
/
update prd_attribute set object_type = 'CYTP1010' where id = 10003516
/
update prd_attribute set object_type = 'CYTP1011' where id = 10003619
/
update prd_attribute set object_type = 'CYTP1012' where id = 10003501
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003761, 10000403, NULL, 'CRD_WAIVE_INTEREST', 'DTTPNMBR', NULL, 15, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003764, 10000403, 10003761, 'CRD_CHARGE_WAIVED_INTEREST', 'DTTPNMBR', 4, 20, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003765, 10000403, 10003761, 'CRD_WAIVE_INTEREST_PERIOD', 'DTTPNMBR', NULL, 30, 'ENTTCYCL', 'CYTP1009', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003774, 10000403, 10000380, 'CRD_ARRIVAL_DUE_DATE_NOTIFICATION', 'DTTPNMBR', NULL, 110, 'ENTTCYCL', 'CYTP1014', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003779, 10000403, 10000394, 'CRD_INCREASE_CREDIT_LIMIT_PERIOD', 'DTTPNMBR', NULL, 100, 'ENTTCYCL', 'CYTP1015', 'SADLPRDT', 1)
/
update prd_attribute set object_type = 'FETP1016' where id = 10003746
/
update prd_attribute set object_type = 'CYTP1013' where id = 10003747
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003782, 10000403, 10000387, 'CRD_AGING_ALGORITHM', 'DTTPCHAR', 614, 80, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003783, 10000403, 10000387, 'CRD_AGING_EVENT_TYPE', 'DTTPCHAR', 615, 90, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003784, 10000403, 10000387, 'CRD_AGING_PERIOD', 'DTTPNMBR', NULL, 100, 'ENTTCYCL', 'CYTP1016', 'SADLPRDT', 1)
/
update prd_attribute a set a.is_visible = 0  where a.id = 10003619
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003790, 10000403, 10000387, 'CRD_STOP_AGING_EVENT', 'DTTPCHAR', 615, 110, NULL, NULL, 'SADLPRDT', 1)
/
delete from prd_attribute where id = 10003746
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003746, 10000403, 10000380, 'CRD_EXTRA_MAD', 'DTTPNMBR', NULL, 80, 'ENTTFEES', 'FETP1016', 'SADLPRDT', 1)
/
update prd_attribute set display_order = 40 where id = 10000399
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003871, 10000403, NULL, 'CRD_COLLECTION', 'DTTPNMBR', NULL, 90, 'ENTTAGRP', NULL, NULL, 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003872, 10000403, 10003871, 'CRD_ENABLE_COLLECTING', 'DTTPNMBR', 4, 10, NULL, NULL, 'SADLPRDT', 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003873, 10000403, 10003871, 'CRD_COLLECTION_THRESHOLD', 'DTTPNMBR', NULL, 20, 'ENTTFEES', 'FETP1017', 'SADLPRDT', 0)
/
update prd_attribute set is_visible = 0 where id = 10003746
/
update prd_attribute set is_visible = 0 where id = 10003747
/
update prd_attribute set is_visible = 0 where id = 10003748
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004001, 10000403, 10000380, 'CRD_MAD_CALC_THRESHOLD', 'DTTPNMBR', NULL, 140, 'ENTTFEES', 'FETP1018', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004096, 10000403, 10000392, 'CRD_DEBT_REPAYMENTS_SORTING_ALGORITHM', 'DTTPCHAR', 655, 90, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004100, 10000403, 10004103, 'CRD_PROMOTIONAL_PERIOD', 'DTTPNMBR', NULL, 10, 'ENTTCYCL', 'CYTP1018', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004103, 10000403, NULL, 'CRD_PROMOTIONAL_INTEREST', 'DTTPNMBR', NULL, 18, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004104, 10000403, 10004103, 'CRD_PROMOTIONAL_INTEREST_RATE', 'DTTPNMBR', NULL, 20, 'ENTTFEES', 'FETP1019', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004101, 10000403, 10000394, 'CRD_CREDIT_LIMIT_INCREASE_AUTO', 'DTTPNMBR', 4, 110, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004102, 10000403, 10000392, 'CRD_INSTANT_PAYMENT_INDICATOR', 'DTTPNMBR', 4, 200, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004106, 10000403, 10000380, 'CRD_NEW_ACCOUNT_SKIP_MAD_WINDOW', 'DTTPNMBR', NULL, 150, NULL, NULL, 'SADLPRDT', 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004107, 10000403, 10000380, 'CRD_MAD_ROUNDING_UP_EXPONENT', 'DTTPNMBR', NULL, 160, NULL, NULL, 'SADLPRDT', 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004422, 10000403, 10000377, 'CRD_CURRENT_BALANCE', 'DTTPNMBR', 4, 80, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004449, 10000403, 10000377, 'CRD_INTEREST_RATE_EFF_DATE', 'DTTPCHAR', 720, 90, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004424, 10000403, 10000380, 'CRD_REPAYMENT_SKIP_MAD_WINDOW', 'DTTPNMBR', NULL, 155, NULL, NULL, 'SADLPRDT', 0)
/
delete from prd_attribute where id = 10003747
/
delete from prd_attribute where id = 10004106
/
delete from prd_attribute where id = 10004424
/
update prd_attribute set is_visible = 1 where id = 10003748
/
