create table utl_table_config
(
    id                  number(8)
  , table_name          varchar2(30)
  , config              varchar2(8)
  , config_condition    varchar2(2000)
)
/
comment on table utl_table_config is 'Configuration table for processes of configuration exporting'
/
comment on column utl_table_config.id is 'Identified'
/
comment on column utl_table_config.table_name is 'Name of table in current schema'
/
comment on column utl_table_config.config is 'Config name'
/
comment on column utl_table_config.config_condition is 'Specifies which data will be excluded during exporting'
/

