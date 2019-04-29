insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_AMK_AGENT_DAILY_STAT', 'TRANS_DATA_TBS', 0, null, 0, 1, null)
/
delete from utl_table where table_name = 'CST_AMK_AGENT_DAILY_STAT'
/
