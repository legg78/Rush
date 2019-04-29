create table frp_auth_object (
    auth_id         number(16)
  , part_key        as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , entity_type     varchar2(8)
  , object_id       number(16)
  , is_external     number(1)
  , serial_number   number(8)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition frp_auth_object_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)
******************** partition end ********************/
/

comment on table frp_auth_object is 'Historical maping authorizations and objects.'
/
comment on column frp_auth_object.auth_id is 'Reference to authorization.'
/
comment on column frp_auth_object.entity_type is 'Entity type - authorization participant.'
/
comment on column frp_auth_object.object_id is 'Object identifier - authorization participant.'
/
comment on column frp_auth_object.is_external is 'External object indicator (1 - external, 0 - own).'
/
comment on column frp_auth_object.serial_number is 'Serial number of authorization for an object.'
/
