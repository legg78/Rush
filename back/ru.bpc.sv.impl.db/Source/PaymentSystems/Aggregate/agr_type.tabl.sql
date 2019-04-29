create table agr_type(
  id           NUMBER(16)                       not null,
  name         VARCHAR2(200),
  description  VARCHAR2(999),
  condition    VARCHAR2(999),
  network_id   NUMBER(4))
/

comment on table agr_type is 'Aggregate type'
/
comment on column agr_type.id is 'Primary key'
/
comment on column agr_type.name is 'Aggregate name'
/
comment on column agr_type.description is 'Description'
/
comment on column agr_type.condition is 'Aggregate condition'
/
comment on column agr_type.network_id is 'Aggregate network'
/
 