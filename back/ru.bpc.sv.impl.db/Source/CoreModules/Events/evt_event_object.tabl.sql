create table evt_event_object
(
    id                  number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , event_id            number(4)
  , procedure_name      varchar2(200)
  , entity_type         varchar2(8)
  , object_id           number(16)
  , eff_date            date
  , event_timestamp     timestamp(6)
  , inst_id             number(4)
  , split_hash          number(4)
  , session_id          number(16)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
    partition evt_event_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table evt_event_object is 'Objects awaiting processing by subscribers.'
/

comment on column evt_event_object.id is 'Primary key.'
/
comment on column evt_event_object.event_id is 'Reference to event.'
/
comment on column evt_event_object.procedure_name is 'Subscriber procedure name.'
/
comment on column evt_event_object.entity_type is 'Business-entity type.'
/
comment on column evt_event_object.object_id is 'Reference to the object.'
/
comment on column evt_event_object.eff_date is 'Event effective date.'
/
comment on column evt_event_object.event_timestamp is 'Event registration timestamp.'
/
comment on column evt_event_object.inst_id is 'Institution identifier.'
/
comment on column evt_event_object.split_hash is 'Hash value to split further processing.'
/
comment on column evt_event_object.session_id is 'Session identifier.'
/
alter table evt_event_object add( proc_session_id number(16), status varchar2(8))
/
comment on column evt_event_object.proc_session_id is 'Processed session identifier.'
/
comment on column evt_event_object.status is 'Event status.'
/

alter table evt_event_object add(container_id number(8))
/
comment on column evt_event_object.container_id is 'Reference to process container.'
/

alter table evt_event_object enable row movement
/

alter table evt_event_object add (event_type varchar2(8))
/
comment on column evt_event_object.event_type is 'Event type code (dictionary EVNT)'
/
alter table evt_event_object add (proc_session_file_id number(16))
/
comment on column evt_event_object.proc_session_file_id is 'Reference to the file which was processed fot this event'
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'EVT_EVENT_OBJECT' and column_name = 'PART_KEY')
    loop
        if rec.cnt = 0 then
            execute immediate 'alter table evt_event_object add (part_key as (to_date(substr(lpad(to_char(id), 16, ''0''), 1, 6), ''yymmdd'')) virtual)';
            execute immediate 'comment on column evt_event_object.part_key is ''Partition key''';
        end if;
    end loop;
end;
/
