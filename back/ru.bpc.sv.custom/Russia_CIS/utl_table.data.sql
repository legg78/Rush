delete utl_table where table_name = 'AUP_BELKART'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('AUP_BELKART', 'ENCRYPT_DATA_TBS', NULL, NULL, 0, 1, NULL)
/
delete utl_table where table_name = 'AUP_BELKART_TECH'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('AUP_BELKART_TECH', 'TRANS_DATA_TBS', 0, NULL, 0, 1, NULL)
/
delete utl_table where table_name = 'RUS_FORM_250_1'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUS_FORM_250_1', 'SMALL_DATA_TBS', 1, NULL, 0, 0, NULL)
/
delete utl_table where table_name = 'RUS_FORM_250_3'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUS_FORM_250_3', 'SMALL_DATA_TBS', 1, NULL, 0, 0, NULL)
/
delete utl_table where table_name = 'RUS_FORM_250_1_OPERS'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUS_FORM_250_1_OPERS', 'LARGE_DATA_TBS', 0, NULL, 0, 0, NULL)
/
delete utl_table where table_name = 'RUS_FORM_250_1_CARDS'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUS_FORM_250_1_CARDS', 'LARGE_DATA_TBS', 0, NULL, 0, 0, NULL)
/
delete utl_table where table_name = 'RUS_FORM_250_1_REPORT'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUS_FORM_250_1_REPORT', 'SMALL_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_ACQ_BIN', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_ADD', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_BIN_RANGE', 'MEDIUM_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_CARD', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_DE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_FILE', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_FIN', 'ENCRYPT_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_FPD', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_FSUM', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_MSG_IMPACT', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_MSG_PDS', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_PDS', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_REASON_CODE', 'SMALL_DATA_TBS', 1, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_REJECT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_REJECT_CODE', 'SMALL_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_REJECT_DATA', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_TEXT', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_VALIDATION_RULES_DE', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('MUP_VALIDATION_RULES_PDS', 'SMALL_DATA_TBS', 0, NULL, 0, 0)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUS_FORM_259_1_OPERS', 'LARGE_DATA_TBS', 0, NULL, 0, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUS_FORM_259_1_CARDS', 'LARGE_DATA_TBS', 0, NULL, 0, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUS_FORM_259_1_REPORT', 'SMALL_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUS_FORM_259_2_OPERS', 'LARGE_DATA_TBS', 0, NULL, 0, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUS_FORM_259_2_REPORT', 'SMALL_DATA_TBS', 0, NULL, 0, 1, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUS_FORM_407_3_OPERS', 'LARGE_DATA_TBS', 0, NULL, 0, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('RUS_FORM_407_3_REPORT', 'SMALL_DATA_TBS', 0, NULL, 0, 1, NULL)
/
update utl_table set tablespace_name = 'TRANS_DATA_TBS' where table_name = 'MUP_FIN'            -- [@skip patch]
/
