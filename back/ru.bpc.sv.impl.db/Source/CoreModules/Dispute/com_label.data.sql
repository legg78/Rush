insert into com_label (id, name, label_type, module_code) values (10011487, 'NO_DISPUTE_FOUND', 'ERROR', 'DSP')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011488, 'DISPUTE_DOUBLE_REVERSAL', 'ERROR', 'DSP', 'DISPUTE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007053, 'DISPUTE_ALREADY_EXIST', 'ERROR', 'DSP', 'DISPUTE_ID, MESSAGE_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001409, 'MSG.MMT', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001410, 'MSG.DOC_INDICATOR', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001412, 'MSG.FRAUD_TYPE', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10001414, 'MSG.CANCELLED', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006384, 'DUPLICATE_SCALE_TYPE_SELECTION', 'ERROR', 'DSP', 'ID, SCALE_TYPE, MOD_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008474, 'ORIGINAL_OPERATION_NOT_FOUND', 'ERROR', 'DSP', 'DISPUTE_ID, OPERATION_ID')
/
update com_label set name='ORIGINAL_DISPUTE_OPERATION_IS_NOT_FOUND' where id = 10008474
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008203, 'DSP_FIN_MSG_NOT_FOUND', 'ERROR', 'DSP', 'DISPUTE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008205, 'CASE_ACTION_ITEM_REMOVE', 'LABEL', 'CSM', 'CASE_ID, MSGT_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008207, 'FIN_MSG_ALREADY_SEND', 'ERROR', 'DSP', 'OPERATION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10008209, 'OPER_ALREADY_PROCESSED', 'ERROR', 'DSP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006395, 'DSP_FIN_MSG_ALREADY_EXISTS', 'ERROR', 'DSP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006406, 'FIN_MESSAGE_FROM_UNSUPP_IPC', 'ERROR', 'DSP', 'OPER_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006414, 'MCW_DSP_NOT_GENERATED', 'ERROR', 'DSP', 'OPER_ID, MTI, DE024, DE025, REVERSAL INCOMING')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011783, 'NON_CLASSIFIED_SETTLEMENT_TYPE', 'ERROR', 'DSP', 'STTL_TYPE, OPER_ID')
/
update com_label set name = 'FIN_MESSAGE_FROM_UNSUPPORTED_IPS' where id = 10006406
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013361, 'msg.io', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013363, 'msg.card_listed_stop_list', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013365, 'msg.item_details', 'CAPTION', 'MSG', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013562, 'DSP_DUE_DATE_EXISTS', 'ERROR', 'DSP', 'STANDARD_ID, MESSAGE_TYPE, IS_INCOMING, REASON_CODE, USAGE')
/
