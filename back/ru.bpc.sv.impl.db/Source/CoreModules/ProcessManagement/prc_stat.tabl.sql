create table prc_stat (
    session_id        number(16) not null
  , part_key          as (to_date(substr(lpad(to_char(session_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , thread_number     number(4) not null
  , start_time        timestamp
  , current_time      timestamp
  , end_time          timestamp
  , estimated_count   number(16)
  , current_count     number(16)
  , excepted_count    number(16)
  , processed_total   number(16)
  , rejected_total    number(16)
  , excepted_total    number(16)
  , result_code       varchar2(8)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))              -- [@skip patch]
(                                                                                -- [@skip patch]
    partition prc_stat_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                -- [@skip patch]
******************** partition end ********************/
/

comment on table prc_stat is 'Statistics of process treads working'
/
comment on column prc_stat.session_id is 'Process session identifier'
/
comment on column prc_stat.thread_number is 'Thread number'
/
comment on column prc_stat.start_time is 'Process start time'
/
comment on column prc_stat.current_time is 'Last update time'
/
comment on column prc_stat.end_time is 'Process end time'
/
comment on column prc_stat.estimated_count is 'Estimated volume of job'
/
comment on column prc_stat.current_count is 'Current count of job'
/
comment on column prc_stat.excepted_count is 'Excepted count of job'
/
comment on column prc_stat.processed_total is 'Total count of processed records'
/
comment on column prc_stat.rejected_total is 'Total count of rejected records'
/
comment on column prc_stat.excepted_total is 'Total count of excepted records'
/
comment on column prc_stat.result_code is 'Process end result code'
/
alter table prc_stat add measure varchar2(8)
/
comment on column prc_stat.measure is 'Count measure (dictionary value ''ENTT'')'
/
