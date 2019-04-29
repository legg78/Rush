create table ntf_notification (
    id              number(4)
    , seqnum        number(4)
    , event_type    varchar2(8)
    , report_id     number(8)
    , inst_id       number(4)
)
/
comment on table ntf_notification is 'Notifications.'
/
comment on column ntf_notification.id is 'Primary key.'
/
comment on column ntf_notification.seqnum is 'Data version sequencial number.'
/
comment on column ntf_notification.event_type is 'Event type for which notification is intended.'
/
comment on column ntf_notification.report_id is 'Report contained data source for message generation.'
/
comment on column ntf_notification.inst_id is 'Institution identifier.'
/
