create table ntf_scheme_event (
    id                 number(8)
    , seqnum           number(4)
    , scheme_id        number(4)
    , event_type       varchar2(8)
    , entity_type      varchar2(8)
    , contact_type     varchar2(8)
    , notif_id         number(4)
    , channel_id       number(4)
    , delivery_time    varchar2(200)
    , is_customizable  number(1)
    , is_active        number(1)
    , is_batch_send    number(1)
    , scale_id         number(4)
)
/
comment on table ntf_scheme_event is 'Events included in notification scheme.'
/
comment on column ntf_scheme_event.id is 'Primary key.'
/
comment on column ntf_scheme_event.seqnum is 'Data version sequencial number.'
/
comment on column ntf_scheme_event.scheme_id is 'Reference to notification scheme.'
/
comment on column ntf_scheme_event.event_type is 'Event type raised notification.'
/
comment on column ntf_scheme_event.entity_type is 'Entity type to be notified.'
/
comment on column ntf_scheme_event.contact_type is 'Contact type for notification.'
/
comment on column ntf_scheme_event.notif_id is 'Reference to notification.'
/
comment on column ntf_scheme_event.channel_id is 'Reference to notification channel.'
/
comment on column ntf_scheme_event.delivery_time is 'Time interval for delivery. filled in format xx-yy. where xx start hour and yy end hour.'
/
comment on column ntf_scheme_event.is_customizable is 'Possibily to redefine delivery settings by customer.'
/
comment on column ntf_scheme_event.is_active is 'Activation flag. if event is not active for scheme then notification will not be created.'
/
comment on column ntf_scheme_event.is_batch_send is 'All events will be represented by single message.'
/
comment on column ntf_scheme_event.scale_id is 'Modifier scale for filter event objects.'
/

alter table ntf_scheme_event add (
    priority           number(4) 
)
/
comment on column ntf_scheme_event.scale_id is 'Priority'
/
alter table ntf_scheme_event add status varchar2(8)
/
comment on column ntf_scheme_event.status is 'Event notification status (NTES dictionary)'
/

comment on column ntf_scheme_event.priority is 'Priority'
/
comment on column ntf_scheme_event.scale_id is 'Modifier scale for filter event objects.'
/
