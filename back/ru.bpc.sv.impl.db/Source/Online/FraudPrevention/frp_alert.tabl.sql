create table frp_alert (
    id          number(16)
  , check_id    number(8)
  , auth_id     number(16)
  , entity_type varchar2(8)
  , object_id   number(16)
  , is_external number(1)
)
/

comment on table frp_alert is 'Alert storage.'
/

comment on column frp_alert.id is 'Primary key.'
/

comment on column frp_alert.check_id is 'Reference to check returning TRUE.'
/

comment on column frp_alert.auth_id is 'Reference to authorization.'
/

comment on column frp_alert.entity_type is 'Entity type alert is registred for.'
/

comment on column frp_alert.object_id is 'Object identifier alert is registred for.'
/

comment on column frp_alert.is_external is 'External object indicator (1 - external, 0 - own).'
/