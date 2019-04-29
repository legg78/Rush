alter table evt_subscription
    add constraint evt_subscription_pk primary key(id)
/
alter table evt_subscription
    add constraint evt_subscription_un unique (event_id, subscr_id)
/

alter table evt_subscription drop constraint evt_subscription_un
/
           
alter table evt_subscription
    add constraint evt_subscription_un unique (event_id, subscr_id, container_id)
/
