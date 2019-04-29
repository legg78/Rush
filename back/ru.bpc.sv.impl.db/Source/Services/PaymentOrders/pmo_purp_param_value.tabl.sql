create table pmo_purp_param_value (
    id            number(12)
  , purp_param_id number(8)
  , entity_type   varchar2(8)
  , object_id     number(16)
  , param_value   varchar2(2000)
)
/

comment on table pmo_purp_param_value is 'Payment parameter''s values depending on exact object (Termanal, Host, etc).'
/

comment on column pmo_purp_param_value.id is 'Primary key'
/
comment on column pmo_purp_param_value.purp_param_id is 'Reference to purpose of payment parameter'
/
comment on column pmo_purp_param_value.entity_type is 'Entity type - value owner'
/
comment on column pmo_purp_param_value.object_id is 'Object identifier - value owner'
/
comment on column pmo_purp_param_value.param_value is 'Parameter value'
/
