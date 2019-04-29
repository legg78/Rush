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
