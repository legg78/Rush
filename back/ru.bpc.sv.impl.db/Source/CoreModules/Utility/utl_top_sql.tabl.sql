create table utl_top_sql(
    session_id             number(16)
  , top_sql_order          number(4)
  , dbid                   number
  , parsing_schema_id      number
  , parsing_schema_name    varchar2(30)
  , snap_min               number
  , snap_min_time          date
  , snap_max               number
  , snap_max_time          date
  , sql_id                 varchar2(13)
  , plan_hash_value        number
  , command_type           number
  , sql_text               clob

  , parse_calls            number
  , parse_calls_all        number

  , executions             number
  , executions_all         number

  , fetches                number
  , fetches_all            number

  , disk_reads             number
  , disk_reads_all         number

  , buffer_gets            number
  , buffer_gets_all        number

  , rows_processed         number

  , cpu_time               number
  , cpu_time_all           number

  , plsexec_time           number
  , plsexec_time_all       number

  , elapsed_time           number
  , elapsed_time_all       number

  , iowait                 number
  , iowait_all             number

  , apwait                 number
  , apwait_all             number

  , ccwait                 number
  , ccwait_all             number

  , direct_writes          number
  , direct_writes_all      number
)
/
alter table utl_top_sql add sorting_type varchar2(8)
/
alter table utl_top_sql add is_aggregation number(1)
/
alter table utl_top_sql rename column snap_min to min_snap_id
/
alter table utl_top_sql rename column snap_max to max_snap_id
/

comment on column utl_top_sql.session_id             is 'Session identifier'
/
comment on column utl_top_sql.top_sql_order          is 'The order number of Top SQL statement according sorting type'
/
comment on column utl_top_sql.dbid                   is 'Database ID for the snapshot'
/
comment on column utl_top_sql.parsing_schema_id      is 'Schema ID that was used to originally build the child cursor'
/
comment on column utl_top_sql.parsing_schema_name    is 'Schema name that was used to originally build the child cursor'
/
comment on column utl_top_sql.min_snap_id            is 'Minimal snapshot ID'
/
comment on column utl_top_sql.snap_min_time          is 'Start time of the minimal snapshot'
/
comment on column utl_top_sql.max_snap_id            is 'Maximal snapshot ID'
/
comment on column utl_top_sql.snap_max_time          is 'End time of the maximal snapshot'
/
comment on column utl_top_sql.sql_id                 is 'SQL identifier of the parent cursor in the library cache'
/
comment on column utl_top_sql.plan_hash_value        is 'Numerical representation of the SQL plan for the cursor'
/
comment on column utl_top_sql.command_type           is 'Type of SQL command'
/
comment on column utl_top_sql.sql_text               is 'Text of SQL statement'
/
comment on column utl_top_sql.parse_calls            is 'Parse calls (for this child cursor)'
/
comment on column utl_top_sql.parse_calls_all        is 'Parse calls (for all cursors)'
/
comment on column utl_top_sql.executions             is 'Executions that took place on this object since it was brought into the library cache (for this child cursor)'
/
comment on column utl_top_sql.executions_all         is 'Executions that took place on this object since it was brought into the library cache (for all cursors)'
/
comment on column utl_top_sql.fetches                is 'Fetches associated with the SQL statement (for this child cursor)'
/
comment on column utl_top_sql.fetches_all            is 'Fetches associated with the SQL statement (for all cursors)'
/
comment on column utl_top_sql.disk_reads             is 'Disk reads (for this child cursor)'
/
comment on column utl_top_sql.disk_reads_all         is 'Disk reads (for all cursors)'
/
comment on column utl_top_sql.buffer_gets            is 'Buffer gets (for this child cursor)'
/
comment on column utl_top_sql.buffer_gets_all        is 'Buffer gets (for all cursors)'
/
comment on column utl_top_sql.rows_processed         is 'Cumulative number of rows the parsed SQL statement returns'
/
comment on column utl_top_sql.cpu_time               is 'CPU time (in microseconds) used by this cursor for parsing/executing/fetching (for this child cursor)'
/
comment on column utl_top_sql.cpu_time_all           is 'CPU time (in microseconds) used by this cursor for parsing/executing/fetching (for all cursors)'
/
comment on column utl_top_sql.plsexec_time           is 'PL/SQL Execution Time (for this child cursor)'
/
comment on column utl_top_sql.plsexec_time_all       is 'PL/SQL Execution Time (for all cursors)'
/
comment on column utl_top_sql.elapsed_time           is 'Elapsed time (in microseconds) used by this cursor for parsing/executing/fetching (for this child cursor)'
/
comment on column utl_top_sql.elapsed_time_all       is 'Elapsed time (in microseconds) used by this cursor for parsing/executing/fetching (for all cursors)'
/
comment on column utl_top_sql.iowait                 is 'User I/O wait time (for this child cursor)'
/
comment on column utl_top_sql.iowait_all             is 'User I/O wait time (for all cursors)'
/
comment on column utl_top_sql.apwait                 is 'Application wait time (for this child cursor)'
/
comment on column utl_top_sql.apwait_all             is 'Application wait time (for all cursors)'
/
comment on column utl_top_sql.ccwait                 is 'Concurrency wait time (for this child cursor)'
/
comment on column utl_top_sql.ccwait_all             is 'Concurrency wait time (for all cursors)'
/
comment on column utl_top_sql.direct_writes          is 'Direct writes (for this child cursor)'
/
comment on column utl_top_sql.direct_writes_all      is 'Direct writes (for all cursors)'
/
comment on column utl_top_sql.sorting_type           is 'Sorting type'
/
comment on column utl_top_sql.is_aggregation         is 'Flag shows if snapshots is aggregated (1 - Yes, 0 - No)'
/
