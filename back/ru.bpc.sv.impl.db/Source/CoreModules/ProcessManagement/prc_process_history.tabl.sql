create table prc_process_history (
    id                 number(16) not null
    , part_key         as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , session_id       number(16) not null
    , param_id         number(8) not null
    , param_value      varchar2(2000)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                         -- [@skip patch]
(                                                                                           -- [@skip patch]
    partition prc_process_history_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                           -- [@skip patch]
******************** partition end ********************/
/

comment on table prc_process_history is 'History of running processes.'
/
comment on column prc_process_history.id is 'Primary key.'
/
comment on column prc_process_history.session_id is 'Session identifier.'
/
comment on column prc_process_history.param_id is 'Parameter identifier.'
/
comment on column prc_process_history.param_value is 'Parameters value.'
/
