delete from com_label where name = 'IMPOSSIBLE_TO_REISSUE_NEARLY_EXPIRED_CARD'
/
insert into com_label (id, name, label_type, module_code, env_variable) values (-50000008, 'IMPOSSIBLE_TO_REISSUE_NEARLY_EXPIRED_CARD', 'ERROR', 'ISS', 'CARD_MASK, APPLICATION_FLOW_ID, DAYS_LEFT, LIMIT_OF_DAYS_FOR_REISSUE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (-50000002, 'CST_ICC_AUTOCHANGE_PRODUCT_FOR_WRONG_ENTITY', 'ERROR', 'CST', 'ENTITY_TYPE, OBJECT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (-50000003, 'CST_ICC_PRODUCT_IS_NOT_FOUND_FOR_AUTOCHANGE', 'ERROR', 'CST', 'PRODUCT_ID, EVENT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (-50000001, 'CST_ICC_INCONSISTENT_FEE_PROPERTIES', 'LABEL', 'CRD', 'FEE_TYPE, FEE_RATE_CALC, FEE_BASE_CALC')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (-50000004, 'CST_ICC_MAD_MORE_THAT_CREDIT_LIMIT', 'LABEL', 'CRD', 'MAD, FEE_AMOUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (-50000005, 'CST_ICC_DPP_AMOUNT_MORE_THAT_CREDIT_LIMIT', 'LABEL', 'CRD', 'DPP_AMOUNT, FEE_AMOUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (-50000006, 'CST_ICC_MIN_MAD_LESS_MAD', 'LABEL', 'CRD', 'OPER_AMOUNT, FEE_AMOUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (-50000007, 'CST_ICC_INSTALMENT_AMOUNT_LESS_MIN_VALUE', 'LABEL', 'CRD', 'INSTALMENT_AMOUNT, FEE_AMOUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (-50000009, 'CST_ICC_IMPOSSIBLE_TO_APPLY_PAYMENT_FOR_DPP_REGISTRATION', 'ERROR', 'CST', 'PAYMENT_ID, ACCOUNT_ID, PAYMENT_AMOUNT, OPER_TYPE')
/
