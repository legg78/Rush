create table ntf_custom_event (
    id                  number(12)
    , scheme_event_id   number(8)
    , entity_type       varchar2(8)
    , object_id         number(16)
    , channel_id        number(4)
    , delivery_address  varchar2(200)
    , delivery_time     varchar2(200)
    , is_active         number(1)
    , mod_id            number(4)
    , start_date        date
    , end_date          date
)
/
comment on table ntf_custom_event is 'Custom setting of notification delivery.'
/
comment on column ntf_custom_event.id is 'Primary key.'
/
comment on column ntf_custom_event.scheme_event_id is 'Reference to notification scheme event which redefined.'
/
comment on column ntf_custom_event.entity_type is 'Entity type to be notified.'
/
comment on column ntf_custom_event.object_id is 'Notified object identifier. customer identifier.'
/
comment on column ntf_custom_event.channel_id is 'Reference to delivery channel.'
/
comment on column ntf_custom_event.delivery_address is 'Delivery address.'
/
comment on column ntf_custom_event.delivery_time is 'Time interval for delivery. Filled in format XX-YY. Where XX start hour and YY end hour.'
/
comment on column ntf_custom_event.is_active is 'Activation flag. if event is not active for customer then notification will not be created.'
/
comment on column ntf_custom_event.mod_id is 'Modifier to filter event objects.'
/
comment on column ntf_custom_event.start_date is 'Custom settings start date.'
/
comment on column ntf_custom_event.end_date is 'Custom settings end date.'
/
alter table ntf_custom_event add (
    event_type        varchar2(8)
)
/
comment on column ntf_custom_event.event_type is 'Event type raised notification.'
/
alter table ntf_custom_event add status varchar2(8)
/
comment on column ntf_custom_event.status is 'Custom event notification status (NTES dictionary)'
/
alter table ntf_custom_event add customer_id number(12)
/
comment on column ntf_custom_event.customer_id is 'Customer identifier'
/
alter table ntf_custom_event modify delivery_address varchar2(2000)
/
alter table ntf_custom_event add contact_type varchar2(8)
/
comment on column ntf_custom_event.contact_type is 'Contact type for notification (CNTT dictionary)'
/
