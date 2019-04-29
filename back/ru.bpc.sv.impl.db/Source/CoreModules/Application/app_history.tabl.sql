create table app_history (
    id             number(16) not null
    , part_key     as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , seqnum       number(4)
    , appl_id      number(16) not null
    , change_date  date
    , change_user  number(8)
    , appl_status  varchar2(8)
    , comments     varchar2(2000)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition app_history_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table app_history is 'History of application change status.'
/
comment on column app_history.id is 'Primary key'
/
comment on column app_history.seqnum is 'Data version sequencial number.'
/
comment on column app_history.appl_id is 'Refrence to application'
/
comment on column app_history.change_date is 'Data of changing'
/
comment on column app_history.change_user is 'User who change the application status'
/
comment on column app_history.appl_status is 'Result of changing'
/
comment on column app_history.comments is 'Comment for changing (reason).'
/
alter table app_history add (change_action varchar2(200))
/
comment on column app_history.change_action is 'Change action'
/
alter table app_history add (reject_code varchar2(8))
/
comment on column app_history.reject_code is 'Reject code, dictionaries APST, APRJ'
/
