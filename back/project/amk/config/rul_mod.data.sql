insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5074, 1002, ':ACQ_CONTRACT_TYPE = ''CNTPTLLR''', 60, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5073, 1002, ':ACQ_CONTRACT_TYPE = ''CNTPATM''', 50, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5072, 1002, ':ACQ_CONTRACT_TYPE = ''CNTPAGNT''', 40, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5075, -5008, 'com_api_flexible_data_pkg.get_flexible_value(''ACC_AGENT_ID'', ''ENTTACCT'', acc_api_account_pkg.get_account_id(:ACCOUNT_NUMBER)) is not null AND com_api_flexible_data_pkg.get_flexible_value(''ACC_SUB_AGENT_ID'', ''ENTTACCT'', acc_api_account_pkg.get_account_id(:ACCOUNT_NUMBER)) is null', 10, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5076, -5008, 'com_api_flexible_data_pkg.get_flexible_value(''ACC_AGENT_ID'', ''ENTTACCT'', acc_api_account_pkg.get_account_id(:ACCOUNT_NUMBER)) is not null AND com_api_flexible_data_pkg.get_flexible_value(''ACC_SUB_AGENT_ID'', ''ENTTACCT'', acc_api_account_pkg.get_account_id(:ACCOUNT_NUMBER)) is not null', 20, 1)
/
update rul_mod set condition = 'com_api_flexible_data_pkg.get_flexible_value(''CST_ACC_AGENT_ID'', ''ENTTACCT'', acc_api_account_pkg.get_account_id(:ACCOUNT_NUMBER)) is not null AND com_api_flexible_data_pkg.get_flexible_value(''CST_ACC_SUB_AGENT_ID'', ''ENTTACCT'', acc_api_account_pkg.get_account_id(:ACCOUNT_NUMBER)) is null' where id = -5075
/
update rul_mod set condition = 'com_api_flexible_data_pkg.get_flexible_value(''CST_ACC_AGENT_ID'', ''ENTTACCT'', acc_api_account_pkg.get_account_id(:ACCOUNT_NUMBER)) is not null AND com_api_flexible_data_pkg.get_flexible_value(''CST_ACC_SUB_AGENT_ID'', ''ENTTACCT'', acc_api_account_pkg.get_account_id(:ACCOUNT_NUMBER)) is not null' where id = -5076
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5088, -5008, 'com_api_flexible_data_pkg.get_flexible_value(''CST_ACC_AGENT_ID'', ''ENTTACCT'', acc_api_account_pkg.get_account_id(:ACCOUNT_NUMBER)) is not null', 30, 1)
/
