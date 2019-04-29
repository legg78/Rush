create table prc_session (
    id                  number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , process_id          number(8)
  , parent_id           number(16)
  , start_time          timestamp
  , end_time            timestamp
  , thread_count        number(4)
  , estimated_count     number(16)
  , processed           number(16)
  , rejected            number(16)
  , excepted            number(16)
  , user_id             number(8)
  , result_code         varchar2(8)
  , inst_id             number(4)
  , sttl_day            number(8)
  , sttl_date           date
  , ip_address          varchar2(200)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition prc_session_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table prc_session is 'Sessions of runs of processes are registering here'
/
comment on column prc_session.id is 'Session identifier'
/
comment on column prc_session.process_id is 'Process identifier'
/
comment on column prc_session.parent_id is 'Identifier of session of container process'
/
comment on column prc_session.start_time is 'Session start time'
/
comment on column prc_session.end_time is 'Session end time'
/
comment on column prc_session.thread_count is 'Thread count'
/
comment on column prc_session.estimated_count is 'Estimated volume'
/
comment on column prc_session.processed is 'Total  number of processed records'
/
comment on column prc_session.rejected is 'Number of rejected (ignored) records'
/
comment on column prc_session.excepted is 'Number of excepted records'
/
comment on column prc_session.user_id is 'User identifier'
/
comment on column prc_session.result_code is 'Result code (prsr dictionary)'
/
comment on column prc_session.inst_id is 'Institution identifier'
/
comment on column prc_session.sttl_day is 'Number of settlement day of session registering'
/
comment on column prc_session.sttl_date is 'Settlement date'
/
comment on column prc_session.ip_address is 'IP address'
/
alter table prc_session add(container_id number(8))
/
comment on column prc_session.container_id is 'Container identifier.'
/
alter table prc_session add measure varchar2(8)
/
comment on column prc_session.measure is 'Count measure (dictionary value ''ENTT'')'
/
