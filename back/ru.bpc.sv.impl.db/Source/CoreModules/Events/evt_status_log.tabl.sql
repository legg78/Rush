create table evt_status_log
(
    id                  number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
  , entity_type         varchar2(8)
  , object_id           number(16)
  , event_type          varchar2(8)
  , initiator           varchar2(8)
  , reason              varchar2(8)
  , status              varchar2(8)
  , change_date         date
  , user_id             number(8)
  , session_id          number(16)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition evt_status_log_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))     -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table evt_status_log is 'Changing status log'
/

comment on column evt_status_log.id is 'Primary key.'
/
comment on column evt_status_log.entity_type is 'Entity type.'
/
comment on column evt_status_log.object_id is 'Object identifier which status is loged.'
/
comment on column evt_status_log.event_type is 'Status change event type.'
/
comment on column evt_status_log.initiator is 'Status changing initiator.'
/
comment on column evt_status_log.reason is 'Status changing reason.'
/
comment on column evt_status_log.status is 'Status after changing.'
/
comment on column evt_status_log.change_date is 'Status change date.'
/
comment on column evt_status_log.user_id is 'User identifier.'
/
comment on column evt_status_log.session_id is 'User session identifier.'
/
alter table evt_status_log add (event_date date)
/
comment on column evt_status_log.event_date is 'Event occurred date.'
/
