insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('H2H_FIN_MESSAGE', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('H2H_FILE', 'TRANS_DATA_TBS', '0', null, '0', '1', null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('H2H_TAG', 'SMALL_DATA_TBS', '1', null, '1', '1', null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('H2H_TAG_VALUE', 'SMALL_DATA_TBS', '1', null, '0', '0', null)
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'H2H_TAG_VALUE'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('H2H_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
