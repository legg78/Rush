create table utl_table
(
    table_name          varchar2(30)
  , tablespace_name     varchar2(30)
  , is_config_table     number(1)
  , config_condition    varchar2(2000)
  , is_split_seq        number(1)
)
/
alter table utl_table add (is_cleanup_table number(1))
/
comment on table utl_table is 'Configuration table for processes of configuration exporting and clearing user data in tables'
/
comment on column utl_table.table_name is 'Name of table in current schema'
/
comment on column utl_table.tablespace_name is 'Name of tablespace in which data of this table must be stored'
/
comment on column utl_table.is_config_table is 'If 1 then data in this table needs to be expoted, if 0 - table not exported'
/
comment on column utl_table.config_condition is 'Specifies which data will be excluded during exporting or deleted during cleanup'
/
comment on column utl_table.is_split_seq is 'If 1 then data in this table needs to be splited, if 0 - table not splited'
/
comment on column utl_table.is_cleanup_table is 'If 1 then data in this table needs to be deleted(users data), if 0 - data must not table be deleted(configuration data)'
/
comment on column utl_table.is_config_table is 'Obsolete, not used.'
/
comment on column utl_table.config_condition is 'Obsolete, not used.'
/
alter table utl_table add (synch_group varchar2(30))
/
comment on column utl_table.synch_group is 'Syncronization group'
/
