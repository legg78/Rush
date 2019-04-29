insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_IBBL_ACC_CHECKBOOK', 'LARGE_DATA_TBS', 0, NULL, 0, 0, NULL)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_IBBL_ACC_CHECKBOOK_LEAFLET', 'LARGE_DATA_TBS', 0, NULL, 0, 0, NULL)
/
delete from utl_table where table_name = 'CST_IBBL_GL_ROUTING_FORMULAR'
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table) values ('CST_IBBL_GL_ROUTING_FORMULAR', 'TRANS_DATA_TBS', 0, NULL, 0, 1)
/
insert into utl_table (table_name, tablespace_name, is_config_table, config_condition, is_split_seq, is_cleanup_table, synch_group) values ('CST_IBBL_BANK_RIT', 'MEDIUM_DATA_TBS', 0, NULL, 0, 0, NULL)
/
