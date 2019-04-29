truncate table utl_table
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_ACCOUNT', 'LARGE_DATA_TBS', 0, 'account_type in (select account_type from acc_account_type where product_type != ''PRDT0300'')', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_ACCOUNT_OBJECT', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_ACCOUNT_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_ACCOUNT_TYPE_ENTITY', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
delete utl_table where table_name = 'ACC_BALANCE'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_BALANCE', 'LARGE_DATA_TBS', 0, 'account_id not in (select id from acc_account where account_type in (select account_type from acc_account_type where product_type = ''PRDT0300''))', 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_BALANCE_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_BUNCH', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_BUNCH_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_ENTRY', 'ENTRY_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_ENTRY_BUFFER', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_ENTRY_TPL', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_ISO_ACCOUNT_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_MACROS', 'MACROS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_MACROS_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_PRODUCT_ACCOUNT_TYPE', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_SCHEME', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_SCHEME_ACCOUNT', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_SELECTION', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_SELECTION_PRIORITY', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_SELECTION_STEP', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_ACTION', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_ACTION_GROUP', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_ACTION_VALUE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_COMPONENT_STATE', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_DASHBOARD', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_DASHBOARD_USER', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_DASHBOARD_WIDGET', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_FAVORITE_PAGE', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_FILTER', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_FILTER_COMPONENT', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_PRIVILEGE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_PRIV_LIMITATION', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_ROLE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_ROLE_OBJECT', 'MEDIUM_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
delete utl_table where table_name = 'ACM_ROLE_PRIVILEGE'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_ROLE_PRIVILEGE', 'MEDIUM_DATA_TBS', 1, 'ID >= 50000000 AND ROLE_ID != 14', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_ROLE_ROLE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_SECTION', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_SECTION_PARAMETER', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_USER', 'MEDIUM_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_USER_AGENT', 'MEDIUM_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_USER_INST', 'MEDIUM_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_USER_ROLE', 'MEDIUM_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_WIDGET', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_WIDGET_PARAM', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_WIDGET_PARAM_VALUE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_ACCOUNT_CUSTOMER', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_ACCOUNT_PATTERN', 'SMALL_DATA_TBS', 1, 'ID >= 500000000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_ACCOUNT_SCHEME', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_CARD_DISTRIBUTION', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_MCC_SELECTION', 'LARGE_DATA_TBS', 1, 'ID >= 500000000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_MCC_SELECTION_TPL', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_MERCHANT', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_MERCHANT_TYPE_TREE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_REIMB_ACCOUNT', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_REIMB_BATCH', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_REIMB_CHANNEL', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_REIMB_MACROS_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_REIMB_OPER', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_REVENUE_SHARING', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_TERMINAL', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ADR_ALTER_PLACE', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ADR_COMPONENT', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ADR_PLACE', 'LARGE_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ADT_DETAIL', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ADT_ENTITY', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ADT_TRAIL', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_APPLICATION', 'LARGE_DATA_TBS', 0, 'ID > 2', 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_DATA', 'LARGE_DATA_TBS', 0, 'APPL_ID > 2', 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_DEPENDENCE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_ELEMENT', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_FLOW_FILTER', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_FLOW_STAGE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_FLOW_STEP', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_FLOW_TRANSITION', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_HISTORY', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_OBJECT', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_STRUCTURE', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_TYPE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ASC_PARAMETER', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ASC_SCENARIO', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ASC_SCENARIO_SELECTION', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ASC_STATE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ASC_STATE_PARAMETER', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ASC_STATE_PARAM_VALUE', 'SMALL_DATA_TBS', 1, 'STATE_ID >= 1', 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_CAPTURED_CARD', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_CASH_IN', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_COLLECTION', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_COLLECTION_STAT', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_COMMAND_LOG', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_DISPENSER', 'LARGE_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_DISPENSER_DYNAMIC', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_SCENARIO', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_SCENARIO_CONFIG', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_SCENARIO_ENCODING', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_STATUS_LOG', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_TERMINAL', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_TERMINAL_DYNAMIC', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_AGGT', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_AMOUNT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_ATM', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_ATM_DISP', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_AUTH_TEMPLATE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_CARD_STATUS_RESP', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_CHRONOPAY', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_CNPY', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_CYBERPLAT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_CYBERPLAT_IN', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_EPAY', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_ISO8583POS', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_ISO8583POS_TECH', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_LIMIT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_MASTERCARD', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_MASTERCARD_TECH', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_SCHEME', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_SCHEME_OBJECT', 'LARGE_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_SCHEME_TEMPLATE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_SV2SV', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_SV2SV_TECH', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_SVIP', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_TAG', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_TAG_VALUE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_VISA_BASEI', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_VISA_BASEI_TECH', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_VISA_SMS', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_VISA_SMS_TECH', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_WAY4', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_WAY4_TECH', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUT_ACTIVE_BUFFER', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUT_AUTH', 'AUTH_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUT_BUFFER#1', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUT_BUFFER#2', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUT_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUT_QUEUE', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUT_QUEUE_LOG', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUT_REJECT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUT_RESP_CODE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMN_DEVICE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMN_DEVICE_CONNECTION', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMN_KEY_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMN_PARAMETER_VALUE', 'MEDIUM_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMN_RESP_CODE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMN_STANDARD', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMN_STANDARD_OBJECT', 'MEDIUM_DATA_TBS', 1, 'ID > 10000001', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMN_STANDARD_VERSION', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMN_STANDARD_VERSION_OBJ', 'MEDIUM_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMN_TCP_IP', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_ADDRESS', 'LARGE_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_ADDRESS_OBJECT', 'LARGE_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_APPEARANCE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_ARRAY', 'MEDIUM_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_ARRAY_CONVERSION', 'MEDIUM_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_ARRAY_CONV_ELEM', 'MEDIUM_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_ARRAY_ELEMENT', 'MEDIUM_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_ARRAY_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_COMPANY', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_CONTACT', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_CONTACT_DATA', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_CONTACT_OBJECT', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_COUNTRY', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_CURRENCY', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_DICTIONARY', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_FLEXIBLE_DATA', 'LARGE_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_FLEXIBLE_FIELD', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_HOLIDAY', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_I18N', 'MEDIUM_DATA_TBS', 1, 'ID >= 500000000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_ID_OBJECT', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_ID_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_LABEL', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_LOV', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_MCC', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_MODULE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_PARTITION', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_PARTITION_TABLE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_PERSON', 'LARGE_DATA_TBS', 0, 'ID > 100000000002', 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_RATE', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_RATE_PAIR', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_RATE_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_SETTLEMENT_DAY', 'SMALL_DATA_TBS', 1, 'ID > 10000001', 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_SPLIT_MAP', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_STATE_HOLIDAY', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_TRANSLIT', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_VERSION', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRD_DEBT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRD_DEBT_BALANCE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRD_DEBT_INTEREST', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRD_DEBT_PAYMENT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRD_EVENT_BUNCH_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRD_INVOICE', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRD_INVOICE_DEBT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRD_INVOICE_PAYMENT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRD_PAYMENT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRP_DEPARTMENT', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRP_EMPLOYEE', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DPP_ATTRIBUTE_VALUE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DPP_INSTALMENT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DPP_PAYMENT_PLAN', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DSP_LIST_CONDITION', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ECM_3DS_MESSAGE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ECM_LINKED_CARD', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ECM_LINKED_CARD_SENS', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ECM_MERCHANT', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ECM_ORDER', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ECM_PAYMENT_METHOD', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EMV_APPLICATION', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EMV_APPL_SCHEME', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EMV_ARQC', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EMV_BLOCK', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EMV_ELEMENT', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EMV_LINKED_SCRIPT', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EMV_SCRIPT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EMV_SCRIPT_TYPE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EMV_TAG', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EMV_TAG_VALUE', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EMV_VARIABLE', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EVT_ENTITY', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EVT_EVENT', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EVT_EVENT_OBJECT', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EVT_EVENT_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EVT_RULE_SET', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EVT_STATUS_LOG', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EVT_STATUS_MAP', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EVT_SUBSCRIBER', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('EVT_SUBSCRIPTION', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_CYCLE', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_CYCLE_COUNTER', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_CYCLE_SHIFT', 'MEDIUM_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_CYCLE_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_FEE', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_FEE_COUNTER', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_FEE_RATE', 'MEDIUM_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_FEE_TIER', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_FEE_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_LIMIT', 'MEDIUM_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_LIMIT_BUFFER', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_LIMIT_COUNTER', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_LIMIT_HISTORY', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_LIMIT_RATE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FCL_LIMIT_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_ALERT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_AUTH', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_AUTH_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_AUTH_OBJECT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_CASE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_CASE_EVENT', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_CHECK', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_EXTERNAL_OBJECT', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_FRAUD', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_MATRIX', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_MATRIX_VALUE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_SUITE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('FRP_SUITE_CASE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('HSM_CONNECTION', 'MEDIUM_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('HSM_DEVICE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('HSM_LMK', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('HSM_MODEL_NUMBER_MAP', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('HSM_SELECTION', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('HSM_TCP_IP', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ISS_BIN', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ISS_BIN_INDEX_RANGE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ISS_BLACK_LIST', 'ENCRYPT_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ISS_CARD', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ISS_CARDHOLDER', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ISS_CARD_INSTANCE', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ISS_CARD_INSTANCE_DATA', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ISS_CARD_NUMBER', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ISS_PRODUCT_CARD_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('LTY_BONUS', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_ACQ_ARRANGEMENT', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_ACQ_BIN', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_ACQ_BIN_TMP', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_ADD', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_BIN_RANGE', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_BIN_RANGE_TMP', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_CAB_PROGRAM_IRD', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_CURRENCY_UPDATE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_DE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_DEF_ARRANGEMENT_TMP', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_ERROR_CODE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_FILE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_FIN', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_FPD', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_FSUM', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_INTERCHANGE_MAP', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_ISS_ARRANGEMENT', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_MCC', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_MEMBER_INFO', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_MSG_PDS', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_PDS', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_PROC_CODE_IRD', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_PRODUCT_IRD', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_REASON_CODE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_REJECT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_REJECT_CODE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_SPD', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_TEXT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_BIN_RANGE', 'MEDIUM_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_BIN_RANGE_INDEX', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_CARD_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_CARD_TYPE_FEATURE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_CARD_TYPE_MAP', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_DEVICE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_DEVICE_DYNAMIC', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_HOST_SUBSTITUTION', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_INTERFACE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_LOCAL_BIN_RANGE', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_MEMBER', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_MEMBER_INTERCHANGE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_MSG_TYPE_MAP', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_NETWORK', 'SMALL_DATA_TBS', 1, 'ID between 5000 and 9000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_OPER_TYPE_MAP', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NET_STTL_MAP', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NTB_NOTE', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NTF_CHANNEL', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NTF_CUSTOM_EVENT', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NTF_CUSTOM_OBJECT', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NTF_MESSAGE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NTF_NOTIFICATION', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NTF_SCHEME', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NTF_SCHEME_EVENT', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NTF_TEMPLATE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_CHECK', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_CHECK_GROUP', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_CHECK_SELECTION', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_ENTITY_OPER_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_MATCH_CONDITION', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_MATCH_LEVEL_CONDITION', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_OPERATION', 'OPER_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_OPER_STAGE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_PARTICIPANT', 'OPER_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_PARTICIPANT_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_PROC_STAGE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_REASON', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_RULE_SELECTION', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OST_AGENT', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OST_AGENT_TYPE_TREE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
delete utl_table where table_name = 'OST_INSTITUTION'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OST_INSTITUTION', 'SMALL_DATA_TBS', 1, 'ID not in (1001, 9001, 9002, 9003, 9004, 9005, 9998)', 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_LINKED_CARD', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_ORDER', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_ORDER_DATA', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_ORDER_DETAIL', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_PARAMETER', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_PROVIDER', 'SMALL_DATA_TBS', 1, 'ID > 50000001', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_PROVIDER_HOST', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_PURPOSE_FORMATTER', 'MEDIUM_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_PURP_PARAM_VALUE', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_SCHEDULE', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_SERVICE', 'SMALL_DATA_TBS', 1, 'ID > 50000001', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('POS_BATCH', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('POS_TERMINAL', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_CONTAINER', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_DIRECTORY', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_FILE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
delete utl_table where table_name = 'PRC_FILE_ATTRIBUTE'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_FILE_ATTRIBUTE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000 and file_id != 1312', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_FILE_RAW_DATA', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_FILE_SAVER', 'MEDIUM_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_GROUP', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_GROUP_PROCESS', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_PARAMETER', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_PARAMETER_VALUE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_PROCESS', 'LARGE_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_PROCESS_HISTORY', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_PROCESS_PARAMETER', 'SMALL_DATA_TBS', 1, 'ID > 50000001', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_SESSION', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_SESSION_FILE', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_STAT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_TASK', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_ATTRIBUTE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_ATTRIBUTE_SCALE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
delete utl_table where table_name = 'PRD_ATTRIBUTE_VALUE'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_ATTRIBUTE_VALUE', 'MEDIUM_DATA_TBS', 1, 'ENTITY_TYPE in (''ENTTPROD'', ''ENTTSRVC'', ''ENTTACCT'')', 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_CONTRACT', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_CONTRACT_HISTORY', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_CONTRACT_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_CUSTOMER', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_PRODUCT', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_PRODUCT_SERVICE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_SERVICE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_SERVICE_ATTRIBUTE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_SERVICE_LOG', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_SERVICE_OBJECT', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRD_SERVICE_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRS_BATCH', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRS_BATCH_CARD', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRS_BLANK_TYPE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRS_KEY_SCHEMA', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRS_KEY_SCHEMA_ENTITY', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRS_SORT', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRS_SORT_PARAM', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRS_TEMPLATE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QPR_GROUP', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QPR_GROUP_REPORT', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QPR_PARAM', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QPR_PARAM_GROUP', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QPR_PARAM_VALUE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QRZ_BLOB_TRIGGERS', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QRZ_CALENDARS', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QRZ_CRON_TRIGGERS', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QRZ_FIRED_TRIGGERS', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QRZ_JOB_DETAILS', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QRZ_LOCKS', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QRZ_PAUSED_TRIGGER_GRPS', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QRZ_SCHEDULER_STATE', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QRZ_SIMPLE_TRIGGERS', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QRZ_SIMPROP_TRIGGERS', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QRZ_TRIGGERS', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_BANNER', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_DOCUMENT', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_DOCUMENT_CONTENT', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_DOCUMENT_TYPE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_PARAMETER', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_REPORT', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_REPORT_TAG', 'SMALL_DATA_TBS', 1, 'REPORT_ID > 50000001', 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_RUN', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_RUN_PARAMETER', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_TAG', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_TEMPLATE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_MOD', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_MOD_PARAM', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_MOD_SCALE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_MOD_SCALE_PARAM', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_NAME_BASE_PARAM', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_NAME_FORMAT', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_NAME_INDEX_POOL', 'LARGE_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_NAME_INDEX_RANGE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_NAME_PART', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_NAME_PART_PRPT', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_NAME_PART_PRPT_VALUE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_NAME_TRANSFORM', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_PROC', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_PROC_PARAM', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_RULE', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_RULE_PARAM_VALUE', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_RULE_SET', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUS_FORM_250_1', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUS_FORM_250_3', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('SEC_AUTHORITY', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('SEC_DES_KEY', 'ENCRYPT_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('SEC_HMAC_KEY', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('SEC_KEY_LENGTH_MAP', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('SEC_KEY_PREFIX_MAP', 'SMALL_DATA_TBS', 1, 'ID >= 5000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('SEC_KEY_TYPE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('SEC_QUESTION', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('SEC_RSA_CERTIFICATE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('SEC_RSA_KEY', 'ENCRYPT_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('SEC_WORD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('SET_PARAMETER', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
delete utl_table where table_name = 'SET_PARAMETER_VALUE'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('SET_PARAMETER_VALUE', 'MEDIUM_DATA_TBS', 1, 'PARAM_LEVEL = ''PLVLUSER''', 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('TRC_LOG', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('UTL_TABLE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VCH_BATCH', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VCH_CARD_NUMBER', 'ENCRYPT_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VCH_VOUCHER', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_BATCH', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_COUNTRY', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_FEE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_FILE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_FIN_ADDENDUM', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_FIN_MESSAGE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_GENERAL_REPORT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_MONEY_TRANSFER', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_RETRIEVAL', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_RETURNED', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_VSS1', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_VSS2', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_VSS4', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_VSS6', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
update utl_table set is_split_seq = 1 where table_name = 'ACM_PRIVILEGE'
/
update utl_table set is_config_table = 0 where table_name = 'COM_COUNTRY'
/
update utl_table set is_config_table = 0 where table_name = 'COM_CURRENCY'
/
update utl_table set is_split_seq = 1 where table_name = 'COM_MCC'
/
update utl_table set is_config_table = 0 where table_name = 'COM_TRANSLIT'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACI_ATM_CASH', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACI_ATM_FIN', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACI_ATM_SETL', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACI_ATM_SETL_HOPR', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACI_ATM_SETL_TTL', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACI_CLERK_TOT', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACI_FILE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACI_POS_FIN', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACI_POS_SETL', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACI_SERVICE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACI_SERVICE_ATTRIBUTE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACI_TOKEN', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AMX_CARD', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AMX_FILE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AMX_FIN_MESSAGE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AMX_MSG_IMPACT', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AMX_REJECTED', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AMX_REJECTED_DETAIL', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_BNA_COUNTS', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_ATM_BNA', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_BELKART_TECH', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_EKASSIR', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_FIMI', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_ISO8583BIC', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_ISO8583BIC_TECH', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_ISO8583CBS', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_SPDH', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('BGN_CARD', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('BGN_ERROR_CODE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('BGN_FILE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('BGN_FIN', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('BGN_NO_FILE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('BGN_NO_FIN', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('BGN_PACKAGE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('BGN_RETRIEVAL', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMP_CARD', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMP_FILE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMP_FIN_MESSAGE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRD_AGING', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ISS_REISSUE_REASON', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_CARD', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_CLEAR_CENTRE_FILE_TYPE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_CURRENCY_RATE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_FRAUD', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_FRAUD_SEQ', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_PURPOSE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PMO_PURPOSE_PARAMETER', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRS_METHOD', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_BIN_RANGE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_CARD', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_FRAUD', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('UTL_TABLE_CONFIG', 'MEDIUM_DATA_TBS', 1, 'ID>=50000000', 1, 0)
/
update utl_table set is_split_seq = 1 where table_name = 'COM_PARTITION_TABLE'
/
update utl_table set is_split_seq = 1 where table_name = 'QPR_GROUP_REPORT'
/
update utl_table set is_split_seq = 1 where table_name = 'QPR_PARAM_GROUP'
/
update utl_table set is_split_seq = 1 where table_name = 'MCW_INTERCHANGE_MAP'
/
update utl_table set is_split_seq = 1 where table_name = 'QPR_PARAM'
/
update utl_table set is_split_seq = 1 where table_name = 'ADR_COMPONENT'
/
update utl_table set is_split_seq = 1 where table_name = 'ADR_PLACE'
/
update utl_table set is_split_seq = 1 where table_name = 'ACM_SECTION'
/
update utl_table set is_split_seq = 1 where table_name = 'DSP_LIST_CONDITION'
/
update utl_table set is_split_seq = 1 where table_name = 'ASC_PARAMETER'
/
update utl_table set is_split_seq = 1 where table_name = 'PRS_SORT_PARAM'
/
update utl_table set is_split_seq = 1 where table_name = 'EMV_SCRIPT_TYPE'
/
update utl_table set is_split_seq = 1 where table_name = 'SEC_KEY_LENGTH_MAP'
/
update utl_table set is_split_seq = 1 where table_name = 'HSM_MODEL_NUMBER_MAP'
/
update utl_table set is_split_seq = 1 where table_name = 'COM_MCC'
/
update utl_table set is_split_seq = 1 where table_name = 'ACM_SECTION_PARAMETER'
/
update utl_table set is_split_seq = 1 where table_name = 'NET_CARD_TYPE_FEATURE'
/
update utl_table set is_split_seq = 1 where table_name = 'QPR_GROUP'
/
update utl_table set is_split_seq = 1 where table_name = 'COM_APPEARANCE'
/
update utl_table set is_split_seq = 1 where table_name = 'COM_MODULE'
/
insert into utl_table (table_name, tablespace_name, is_split_seq, is_cleanup_table) values ('AUP_BELKART', 'TRANS_DATA_TBS', 0, 1)
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS', is_cleanup_table = 1 where table_name = 'AUP_BELKART_TECH'
/
insert into utl_table (table_name, tablespace_name, is_split_seq, is_cleanup_table) values ('PMO_PROVIDER_GROUP', 'SMALL_DATA_TBS', 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_split_seq, is_cleanup_table) values ('FRP_SUITE_OBJECT', 'MEDIUM_DATA_TBS', 0, 0)
/
update utl_table set is_split_seq = 1 where lower(table_name) in ('net_interface', 'net_host_substitution', 'acq_terminal', 'atm_dispenser', 'cmn_device', 'cmn_standard_version_obj', 'com_address', 'com_address_object', 'prd_product', 'prd_product_service', 'prd_attribute_value', 'fcl_cycle', 'fcl_cycle_shift', 'fcl_fee', 'fcl_fee_tier', 'fcl_limit', 'com_person', 'com_id_object', 'com_contact', 'com_contact_data', 'com_contact_object')
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_USER_PASSWORD', 'MEDIUM_DATA_TBS', 1, null, 1, 1)
/
delete utl_table where table_name in ('OPR_MATCH_LEVEL', 'APP_FLOW', 'GUI_WIZARD', 'GUI_WIZARD_STEP', 'CMN_PARAMETER')
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_MATCH_LEVEL', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('APP_FLOW', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('GUI_WIZARD', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('GUI_WIZARD_STEP', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMN_PARAMETER', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_MSG_IMPACT', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_REPORT_OBJECT', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_ATM_TECH', 'MEDIUM_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_ATM_STATUS', 'MEDIUM_DATA_TBS', 0, NULL, 0, 0)
/
delete utl_table where table_name = 'QPR_AGGR'
/
insert into utl_table ( table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ( 'QPR_AGGR', 'SMALL_DATA_TBS', 0, null, 0, 0, null )
/
delete utl_table where table_name = 'QRZ_SCHEDULER_RUNNING'
/
insert into utl_table ( table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ( 'QRZ_SCHEDULER_RUNNING', 'SMALL_DATA_TBS', 0, null, 0, 1, null )
/
update utl_table set is_split_seq = 1 where table_name = 'AUP_TAG'
/
insert into utl_table ( table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ( 'ACI_CARD', 'ENCRYPT_DATA_TBS', 0, null, 0, 0, null )
/

update utl_table set tablespace_name= 'ENCRYPT_DATA_TBS' where table_name in ('AMX_CARD','BGN_CARD','CMP_CARD','MCW_CARD','VIS_CARD')
/

update utl_table set tablespace_name= 'ENCRYPT_DATA_TBS' where table_name in ('AUP_BELKART','AUP_EPAY','AUP_FIMI', 'ACQ_CARD_DISTRIBUTION','ACQ_REIMB_OPER')
/


insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AGR_VALUE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AGR_PARAM_VALUE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AGR_RULE', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AGR_PARAMETER', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AGR_TYPE', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table ( table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ( 'QPR_CARD_AGGR', 'LARGE_DATA_TBS', 0, null, 0, 0, null )
/
insert into utl_table ( table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ( 'QPR_OPERATION_AGGR', 'LARGE_DATA_TBS', 0, null, 0, 0, null )
/
delete from utl_table where upper(table_name) in ('RUS_FORM_250_1', 'RUS_FORM_250_3','AUP_BELKART','AUP_BELKART_TECH')
/

insert into utl_table ( table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ( 'AUP_ISO8583CBS_TECH', 'LARGE_DATA_TBS', 0, null, 0, 1, null )
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ATM_DISPENSER_HISTORY', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
update utl_table set tablespace_name = 'ENCRYPT_DATA_TBS' where table_name = 'ECM_3DS_MESSAGE'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_MULTIPURPOSE', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/

insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_REJECT_DATA', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_REJECT_DATA', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/

insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_VALIDATION_RULES_DE', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_VALIDATION_RULES_PDS', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_VALIDATION_RULES', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_REJECT_CODE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_REJECT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_ADDITIONAL_AMOUNT', 'OPER_DATA_TBS', 0, NULL, 0, 1)
/
delete utl_table where table_name = 'AUP_REVERSALS'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AUP_REVERSALS', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table ( table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ( 'QPR_MC_ACQ_AGGR', 'LARGE_DATA_TBS', 0, null, 0, 0, null )
/
insert into utl_table ( table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ( 'QPR_MC_ISS_AGGR', 'LARGE_DATA_TBS', 0, null, 0, 0, null )
/
insert into utl_table ( table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ( 'QPR_VISA_ACQ_AGGR', 'LARGE_DATA_TBS', 0, null, 0, 0, null )
/
insert into utl_table ( table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ( 'QPR_VISA_ISS_AGGR', 'LARGE_DATA_TBS', 0, null, 0, 0, null )
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_ACC_BILLING_CURRENCY', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
update utl_table set is_split_seq = 1, is_cleanup_table = 1 where table_name in ('PMO_PURPOSE', 'PMO_PURPOSE_PARAMETER')
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_CURRENCY_RATE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_BUSINESS_TRANS_TYPE', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
update utl_table set is_split_seq = 0 where lower(table_name) in ('acq_terminal', 'atm_dispenser', 'cmn_device', 'cmn_standard_version_obj', 'com_address', 'com_address_object', 'fcl_cycle_shift', 'fcl_fee', 'fcl_fee_tier', 'fcl_limit', 'fcl_cycle', 'net_host_substitution', 'net_interface', 'prd_attribute_value', 'prd_product', 'prd_product_service', 'com_contact', 'com_contact_data', 'com_contact_object', 'com_id_object', 'com_person')
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_250BYTE_FILE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_250BYTE_MESSAGE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
update utl_table set is_split_seq = 1 where lower(table_name) in ('acq_terminal', 'atm_dispenser', 'cmn_device', 'cmn_standard_version_obj', 'fcl_cycle_shift', 'fcl_fee', 'fcl_fee_tier', 'fcl_limit', 'fcl_cycle', 'net_host_substitution', 'net_interface', 'prd_attribute_value', 'prd_product', 'prd_product_service', 'com_address', 'com_address_object')
/
delete from utl_table where table_name = 'ECM_LINKED_CARD_SENS'
/
update utl_table set config_condition = 'ID >= 50000000' where table_name = 'RUL_RULE'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('UTL_SCRIPT', 'MEDIUM_DATA_TBS', 1, 'ID>=50000000', 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('PRC_SEMAPHORE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CUP_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CUP_FILE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CUP_FIN_MESSAGE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('JCB_ADD', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('JCB_DE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('JCB_FILE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('JCB_FIN_MESSAGE', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('JCB_MSG_PDS', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('JCB_FIN_P3005', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('JCB_PDS', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('JCB_CARD', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('JCB_MSG_IMPACT', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DIN_FILE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DIN_RECAP', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DIN_BATCH', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DIN_FIN_MESSAGE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DIN_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DIN_BIN', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DIN_TYPE_OF_CHARGE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CUP_BIN_RANGE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
update utl_table set is_split_seq = 0 where upper(table_name) = 'ACQ_TERMINAL'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DIN_TYPE_OF_CHARGE_IMPACT', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DIN_POS_DATA', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
update utl_script set multiple_launch = 'DSMLUNLM' where id = 10000026
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CMP_ACQ_BIN', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
update utl_table set is_split_seq = 1 where upper(table_name) = 'SET_PARAMETER_VALUE'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('DIN_ADDENDUM_TYPE', 'SMALL_DATA_TBS', 0, NULL, 0, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('DIN_ADDENDUM_FIELD', 'SMALL_DATA_TBS', 0, NULL, 0, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('DIN_ADDENDUM', 'TRANS_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('DIN_ADDENDUM_VALUE', 'TRANS_DATA_TBS', 0, NULL, 0, 1, NULL)
/
update utl_table set is_cleanup_table = 0 where table_name in ('DIN_TYPE_OF_CHARGE', 'DIN_TYPE_OF_CHARGE_IMPACT', 'DIN_POS_DATA')
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('DIN_MESSAGE_TYPE', 'SMALL_DATA_TBS', 0, NULL, 0, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('DIN_MESSAGE_FIELD', 'SMALL_DATA_TBS', 0, NULL, 0, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('POS_BATCH_DETAIL', 'OPER_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('POS_BATCH_ADD_AMOUNT', 'OPER_DATA_TBS', 0, NULL, 0, 1)
/
delete from utl_table where table_name = 'POS_BATCH_ADD_AMOUNT'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('POS_BATCH_FILE', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('POS_BATCH_BLOCK', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('OPR_POS_BATCH', 'OPER_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('WAY_FILE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
delete utl_table where table_name = 'MCW_BRAND_PRODUCT'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MCW_BRAND_PRODUCT', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DIN_TYPE_OF_CHARGE_MAP', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DIN_TYPE_OF_CHARGE_REF', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NBC_FILE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NBC_FIN_MESSAGE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NBC_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
update utl_table set is_cleanup_table = 0 where table_name in ('DIN_TYPE_OF_CHARGE_MAP', 'DIN_TYPE_OF_CHARGE_REF')
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DSP_DUE_DATE_LIMIT', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QPR_MC_ISS', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QPR_MC_ACQ', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CUP_FEE', 'LARGE_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ITF_DATA_TRANSMISSION', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
delete utl_table where table_name = 'CSM_STOP_LIST'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CSM_STOP_LIST', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CSM_APPLICATION', 'LARGE_DATA_TBS', 0, 'ID > 2', 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_TCR4', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ISS_CARD_TOKEN', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('ACC_ACCOUNT_LINK', 'LARGE_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DSP_SCALE_SELECTION', 'SMALL_DATA_TBS', 1, NULL, 1, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('NBF_FIN_FILE', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('NBF_FIN_MESSAGE', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('NBC_ISS_INST_CODE', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACQ_MERCHANT_DAILY_STAT', 'TRANS_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('UTL_THEM_CARD_NUMBER', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('UTL_US_CARD_NUMBER', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RPT_REPORT_CONSTRUCTOR', 'SMALL_DATA_TBS', 0, null, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_TCR3', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('LTY_SPENT_OPERATION', 'TRANS_DATA_TBS', 0, NULL, 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('VIS_VCR_ADVICE', 'TRANS_DATA_TBS', 0, null, 0, 0, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_CURRENCY_RATE', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
update utl_table set is_config_table = 1, config_condition = 'ID >= 5000', is_split_seq = 1, is_cleanup_table = 1 where table_name = 'OPR_MATCH_LEVEL'
/
delete utl_table where table_name = 'QPR_MC_ISS'
/
delete utl_table where table_name = 'QPR_MC_ACQ'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QPR_DETAIL', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CSM_CASE', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CSM_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('JCB_REASON_CODE', 'SMALL_DATA_TBS', 1, NULL, 0, 0, NULL)
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'AMX_FILE'           -- [@skip patch]
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'AMX_FIN_MESSAGE'    -- [@skip patch]
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'CMP_FILE'           -- [@skip patch]
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'CMP_FIN_MESSAGE'    -- [@skip patch]
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'MCW_FIN'            -- [@skip patch]
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'CUP_FILE'           -- [@skip patch]
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'CUP_FIN_MESSAGE'    -- [@skip patch]
/
update utl_table set tablespace_name = 'ENCRYPT_DATA_TBS' where table_name = 'JCB_CARD'         -- [@skip patch]
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'JCB_FIN_MESSAGE'    -- [@skip patch]
/
update utl_table set config_condition = 'ID >= 50000000' where table_name = 'ACM_USER_PASSWORD'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('DSP_FIN_MESSAGE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
update utl_table set tablespace_name = 'SMALL_DATA_TBS' where table_name = 'AMX_MSG_IMPACT' -- [@skip patch]
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AMX_ADD', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AMX_ADD_CHIP', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AMX_REASON_CODE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
update utl_table set config_condition = 'USER_ID >= 50000000' where table_name = 'ACM_USER_PASSWORD'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('VIS_SMS1', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_SMS1', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_BATCH', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('TIE_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('TIE_FIN', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RCN_HOST_MSG', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RCN_CBS_MSG', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RCN_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RCN_CONDITION', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('TIE_FILE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RCN_ATM_MSG', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_UNLINK_ACCOUNT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUS_FORM_250_CARDS', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUS_FORM_250_OPERS', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACC_MACROS_BUNCH_TYPE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('LTY_LOTTERY_TICKET', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('QPR_DETAIL_VISA_BIN', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CSM_UNPAIRED_ITEM', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CUP_AUDIT_TRAILER', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CRD_RESERVE_TMP', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CST_IBBL_GL_ROUTING_FORMULAR', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
delete from utl_table where table_name = 'CST_IBBL_GL_ROUTING_FORMULAR'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_TRANS_RPT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_BIN_INFO', 'OPER_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_FLEXIBLE_FIELD_USAGE', 'SMALL_DATA_TBS', 1, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('AMX_ATM_RCN_FIN', 'TRANS_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('COM_FLEXIBLE_FIELD_STANDARD', 'SMALL_DATA_TBS', 1, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OST_FORBIDDEN_ACTION', 'SMALL_DATA_TBS', 1, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RUL_PROC_ALGORITHM', 'SMALL_DATA_TBS', 1, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('RCN_ADDITIONAL_AMOUNT', 'SMALL_DATA_TBS', 1, NULL, 0, 1)
/
delete from utl_table where table_name = 'RCN_CBS_CARD'
/
delete from utl_table where table_name = 'RCN_CBS_MSG'
/
delete from utl_table where table_name = 'RCN_CONDITION'
/
delete from utl_table where table_name = 'RCN_ATM_MSG'
/
delete from utl_table where table_name = 'RCN_CARD'
/
delete from utl_table where table_name = 'RCN_HOST_MSG'
/
delete from utl_table where table_name = 'RCN_SRVP_PARAMETER'
/
delete from utl_table where table_name = 'RCN_SRVP_MSG'
/
delete from utl_table where table_name = 'RCN_SRVP_DATA'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RCN_CBS_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RCN_CBS_MSG', 'TRANS_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RCN_CONDITION', 'SMALL_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RCN_ATM_MSG', 'LARGE_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RCN_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1, NULL)
/
delete from utl_table where table_name = 'RCN_CBS_CARD'
/
update utl_table set is_split_seq = 1, is_config_table = 1 where table_name = 'RCN_CONDITION'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RCN_HOST_MSG', 'TRANS_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RCN_SRVP_PARAMETER', 'SMALL_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RCN_SRVP_MSG', 'TRANS_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RCN_SRVP_DATA', 'TRANS_DATA_TBS', 0, NULL, 0, 1, NULL)
/
delete from utl_table where table_name = 'PRD_REFERRER'
/
delete from utl_table where table_name = 'PRD_REFERRAL'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('PRD_REFERRER', 'MEDIUM_DATA_TBS', '0', null, '0', '1', null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('PRD_REFERRAL', 'MEDIUM_DATA_TBS', '0', null, '0', '1', null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CLN_CASE', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CLN_ACTION', 'LARGE_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CLN_STAGE', 'SMALL_DATA_TBS', 0, NULL, 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CLN_STAGE_TRANSITION', 'SMALL_DATA_TBS', 0, NULL, 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_GROUP', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_USER_GROUP', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
update utl_table set is_config_table = 1, config_condition = 'ID >= 50000000', is_split_seq = 1, is_cleanup_table = 1 where table_name = 'ACM_GROUP'
/
update utl_table set is_config_table = 1, config_condition = 'ID >= 50000000', is_split_seq = 1, is_cleanup_table = 1 where table_name = 'ACM_USER_GROUP'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('MUP_FORM_1_AGGR', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('MUP_FORM_1_TRANS', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('MUP_FORM_2_2_AGGR', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('MUP_FORM_2_2_TRANS', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/

insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('ACM_PRIV_LIMIT_FIELD', 'SMALL_DATA_TBS', 1, 'ID >= 50000000', 1, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_MATCH_OPER', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('OPR_MATCH_AUTH', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
delete from utl_table where table_name = 'RUL_PROC_ALGORITHM'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUL_ALGORITHM', 'SMALL_DATA_TBS', 1, NULL, 1, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('MCW_ABU_ISS_MSG', 'ENCRYPT_DATA_TBS', 1, NULL, 1, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('MCW_ABU_FILE', 'TRANS_DATA_TBS', 1, NULL, 1, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('MCW_ABU_ACQ_MSG', 'TRANS_DATA_TBS', 1, NULL, 1, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('OPR_OPER_DETAIL', 'TRANS_DATA_TBS', 1, NULL, 1, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CPN_CAMPAIGN_PRODUCT', 'SMALL_DATA_TBS', 1, NULL, 1, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CPN_CAMPAIGN_ATTRIBUTE', 'SMALL_DATA_TBS', 1, NULL, 1, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CPN_CAMPAIGN', 'SMALL_DATA_TBS', 1, NULL, 1, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CPN_CAMPAIGN_SERVICE', 'SMALL_DATA_TBS', 1, NULL, 1, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CPN_ATTRIBUTE_VALUE', 'SMALL_DATA_TBS', 1, NULL, 1, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('UTL_TOP_SQL', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CSM_PROGRESS_MAP', 'SMALL_DATA_TBS', 1, NULL, 0, 0, NULL)
/
