insert into com_label (id, name, label_type, module_code) values (10002791, 'CUSTOMER_NOT_FOUND', 'ERROR', 'IAP')
/
insert into com_label (id, name, label_type, module_code) values (10006036, 'CARDHOLDER_ALREADY_EXIST', 'ERROR', 'IAP')
/
insert into com_label (id, name, label_type, module_code) values (10008961, 'CARDHOLDER_NOT_FOUND', 'ERROR', 'IAP')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10010945, 'CARD_ALREADY_EXISTS', 'ERROR', 'IAP', 'CARD_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003192, 'PERSON_LINKED_TO_MULTIPLE_CARDHOLDERS', 'ERROR', 'IAP', 'PERSON_ID, INST_ID,  COUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003827, 'CANNOT_CHANGE_INST', 'ERROR', 'IAP', 'OLD_INST_ID, NEW_INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011256, 'INCONSISTENT_DATA_IN_BLOCK_PRECEDING_CARD', 'ERROR', 'IAP', 'CARD_ID, CARD_NUMBER, SEQUENTIAL_NUMBER, EXPIRATION_DATE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011340, 'REISSUE_CARD_NUMBER_IS_REQUIRED', 'ERROR', 'IAP', 'REISSUE_COMMAND')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011341, 'PERSON_LINK_WITH_MANY_CARDHOLDERS', 'ERROR', 'IAP', 'PERSON_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011519, 'INSTANCE_NOT_FOUND', 'ERROR', 'IAP', NULL)
/
delete com_label where id = 10011340
/
update com_label set module_code = 'ISS' where id = 10008961
/
update com_label set env_variable = 'CARDHOLDER_NUMBER, CARD_ID' where id = 10008961
/
update com_label set module_code = 'PRD' where id = 10002791
/
update com_label set name = 'CARDHOLDER_ALREADY_EXISTS', env_variable = 'SEARCH_CONDITION' where id = 10006036
/
update com_label set env_variable = 'SEARCH_CONDITION' where id = 10008961
/
update com_label set env_variable = 'CUSTOMER, INST_ID' where id = 10002791
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006979, 'DEFAULT_POS_ACCOUNT_EXISTS', 'ERROR', 'IAP', 'ACCOUNT_ID, CARD_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006980, 'DEFAULT_ATM_ACCOUNT_EXISTS', 'ERROR', 'IAP', 'ACCOUNT_ID, CARD_ID')
/
delete from com_label where id = 10007046
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001368, 'IMPOSSIBLE_RENEWAL_FOR_CLOSED_CARD', 'ERROR', 'IAP', 'CARD_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007313, 'iss.fetch_cbs', 'CAPTION', 'ISS', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007999, 'MSG.FETCH_EWALLET', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10012310, 'REISSUE_SAME_CARD_NUMBER', 'ERROR', 'IAP', 'CARD_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013269, 'INCORRECT_TAG_CARD_FOR_CONTRACT_TYPE', 'ERROR', 'APP', 'CONTRACT_TYPE')
/
