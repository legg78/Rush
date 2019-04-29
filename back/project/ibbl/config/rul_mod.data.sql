insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5109, -5011, 'com_api_flexible_data_pkg.get_flexible_value(''CST_IBBL_PREPAID_STATEMENT_DELIVERY'', acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, :OBJECT_ID) = ''STCFPAPR''', 20, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5108, -5011, 'com_api_flexible_data_pkg.get_flexible_value(''CST_IBBL_PREPAID_STATEMENT_DELIVERY'', acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, :OBJECT_ID) = ''STCFELEC''', 10, 1)
/
update rul_mod set condition = 'com_api_flexible_data_pkg.get_flexible_value(''CST_IBBL_PREPAID_STATEMENT_DELIVERY'', acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, :OBJECT_ID) = ''STCFPAPR'' and com_api_flexible_data_pkg.get_flexible_value(''CST_IBBL_PREPAID_STATEMENT'', acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, :OBJECT_ID) = 1' where id = -5109
/
update rul_mod set condition = 'com_api_flexible_data_pkg.get_flexible_value(''CST_IBBL_PREPAID_STATEMENT_DELIVERY'', acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, :OBJECT_ID) = ''STCFELEC'' and com_api_flexible_data_pkg.get_flexible_value(''CST_IBBL_PREPAID_STATEMENT'', acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, :OBJECT_ID) = 1' where id = -5108
/
