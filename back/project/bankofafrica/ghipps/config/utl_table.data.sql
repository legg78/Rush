insert into utl_table (TABLE_NAME, TABLESPACE_NAME, IS_CONFIG_TABLE, CONFIG_CONDITION, IS_SPLIT_SEQ, IS_CLEANUP_TABLE, SYNCH_GROUP) values ('CST_BOF_GHP_CARD', 'ENCRYPT_DATA_TBS', '0', null, '0', '0', null)
/
insert into utl_table (TABLE_NAME, TABLESPACE_NAME, IS_CONFIG_TABLE, CONFIG_CONDITION, IS_SPLIT_SEQ, IS_CLEANUP_TABLE, SYNCH_GROUP) values ('CST_BOF_GHP_FEE', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/
insert into utl_table (TABLE_NAME, TABLESPACE_NAME, IS_CONFIG_TABLE, CONFIG_CONDITION, IS_SPLIT_SEQ, IS_CLEANUP_TABLE, SYNCH_GROUP) values ('CST_BOF_GHP_FILE', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/
insert into utl_table (TABLE_NAME, TABLESPACE_NAME, IS_CONFIG_TABLE, CONFIG_CONDITION, IS_SPLIT_SEQ, IS_CLEANUP_TABLE, SYNCH_GROUP) values ('CST_BOF_GHP_FIN_MESSAGE', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/
insert into utl_table (TABLE_NAME, TABLESPACE_NAME, IS_CONFIG_TABLE, CONFIG_CONDITION, IS_SPLIT_SEQ, IS_CLEANUP_TABLE, SYNCH_GROUP) values ('CST_BOF_GHP_RETRIEVAL', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/
delete from utl_table where table_name = 'CST_BOF_GHP_FIN_MESSAGE'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_BOF_GHP_FIN_MSG', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/
