insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F68', 'SMALL_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_BATCH_TIME', 'SMALL_DATA_TBS', 1, null, 0, 0, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F79', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F55', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F77', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F67', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F65', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F73', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F70', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F138', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F128', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F136', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F130', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F78', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F129', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F127', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_MAPPING_F64F65', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_MAPPING_F72F73', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_HEADER', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F140', 'TRANS_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_IMPORT_F59', 'ENCRYPT_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_RCN_GL_BALANCE', 'TRANS_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_RCN_GL_BALANCE_TEMP', 'SMALL_DATA_TBS', 0, null, 0, 1, null)
/
delete from utl_table where table_name = 'CST_WOO_IMPORT_F55'
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'CST_WOO_IMPORT_HEADER'
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'CST_WOO_IMPORT_F65'
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'CST_WOO_IMPORT_F73'
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'CST_WOO_IMPORT_F138'
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'CST_WOO_IMPORT_F136'
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'CST_WOO_IMPORT_F129'
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'CST_WOO_MAPPING_F64F65'
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'CST_WOO_MAPPING_F72F73'
/
update utl_table set tablespace_name = 'ENCRYPT_DATA_TBS' where table_name = 'CST_WOO_IMPORT_F127'
/
update utl_table set tablespace_name = 'ENCRYPT_DATA_TBS' where table_name = 'CST_WOO_IMPORT_F128'
/
update utl_table set tablespace_name = 'ENCRYPT_DATA_TBS' where table_name = 'CST_WOO_IMPORT_F78'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_PAYMENT_GL_ROUTING_LOG', 'MEDIUM_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_CARD_CHOSEN', 'ENCRYPT_DATA_TBS', 0, null, 0, 1, null)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_WOO_DPP_PAYMENT_HIS', 'TRANS_DATA_TBS', 0, null, 0, 1, null)
/
