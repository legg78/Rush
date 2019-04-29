create table utl_script
(
    id                  number(8)
  , script_name         varchar2(200 char)
  , script_desc         varchar2(2000 char)
  , module_code         varchar2(3 char)
  , run_type            varchar2(8 char)
  , applying_type       varchar2(8 char)
  , script_body         clob
  , is_processed        number(1)
  , last_start_date     date
  , last_finish_date    date
)
/
comment on table utl_script is 'Configuration table for scripts which run before or after build/patch applying'
/
comment on column utl_script.id is 'Primary key'
/
comment on column utl_script.script_name is 'Script name'
/
comment on column utl_script.script_desc is 'Script description'
/
comment on column utl_script.module_code is 'Reference to system module. Module code.'
/
comment on column utl_script.run_type is 'Run type. Dictionary DSRT'
/
comment on column utl_script.applying_type is 'Applying type. Dictionary DSAT'
/
comment on column utl_script.script_body is 'Script body'
/
comment on column utl_script.is_processed is 'It is equal to TRUE when this script is processed'
/
comment on column utl_script.last_start_date is 'Start date and time for last launch of this script'
/
comment on column utl_script.last_finish_date is 'Finish date and time for last launch of this script'
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'UTL_SCRIPT' and column_name = 'MULTIPLE_LAUNCH')
    loop
      if rec.cnt = 0 then
          execute immediate 'alter table utl_script add (multiple_launch varchar2(8))';
          execute immediate 'comment on column utl_script.multiple_launch is ''Multiple launch of deploying scripts. Dictionary DSML''';
      end if;
    end loop;
end;
/

