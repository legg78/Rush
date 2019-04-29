create table evt_subscription
(
    id              number(4)
  , seqnum          number(4)
  , event_id        number(4)
  , subscr_id       number(4)
  , mod_id          number(4)
)
/

comment on table evt_subscription is 'Active subsribers for event.'
/

comment on column evt_subscription.id is 'Primary key.'
/

comment on column evt_subscription.seqnum is 'Data version number.'
/

comment on column evt_subscription.event_id is 'Reference to event.'
/

comment on column evt_subscription.subscr_id is 'Subscriber identifier.'
/

comment on column evt_subscription.mod_id is 'Modifier containing filter on objects will be processed by current subscriber.'
/

alter table evt_subscription add(container_id number(8))
/
comment on column evt_subscription.container_id is 'Reference to process container.'
/
