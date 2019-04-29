alter table utl_table_config add (constraint utl_table_config_pk primary key(id))
/
alter table  utl_table_config add (constraint utl_table_config_un unique (table_name, config))
/
