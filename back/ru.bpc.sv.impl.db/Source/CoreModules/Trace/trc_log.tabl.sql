create table trc_log (
    trace_timestamp timestamp(9)
  , trace_level     varchar2(8)
  , trace_text      varchar2(4000)
  , trace_section   varchar2(2000)
  , user_id         varchar2(30)
  , session_id      number(16)
  , thread_number   number(4)
  , entity_type     varchar2(8)
  , object_id       number(16)
  , event_id        number(4)
  , label_id        number(8)
  , inst_id         number(4)
  , who_called      varchar2(200)                                                        -- [@skip patch]
)                                                                                        -- [@skip patch]
/****************** partition start ********************                                 -- [@skip patch]
partition by range (trace_timestamp) interval(numtoyminterval(1, 'MONTH'))               -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition trc_log_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))            -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/


comment on table trc_log is 'Storage of system trace messages'
/

comment on column trc_log.thread_number is 'Number of thread in multi-threading processing.'
/
comment on column trc_log.entity_type is 'Business entity type linked to trace massage.'
/
comment on column trc_log.inst_id is 'Institution Identifier.'
/
comment on column trc_log.trace_timestamp is 'Timestamp of trace message creation'
/
comment on column trc_log.trace_level is 'Type (level) of trace message. Possible values: FATAL, ERROR, WARNING, INFO, DEBUG.'
/
comment on column trc_log.trace_text is 'Message body'
/
comment on column trc_log.trace_section is 'Place in source code where trace message was created.'
/
comment on column trc_log.user_id is 'User ID'
/
comment on column trc_log.session_id is 'Session ID'
/
comment on column trc_log.object_id is 'Identifier of object linked to trace massage.'
/
comment on column trc_log.event_id is 'Specified event raised the trace message.'
/
comment on column trc_log.label_id is 'Reference to multilanguage message.'
/
comment on column trc_log.who_called is 'Name of object, who has created this message'
/
alter table trc_log modify trace_section varchar2(4000)
/
