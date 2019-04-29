create table prd_service (
    id                  number(8)
    , seqnum            number(4)
    , service_type_id   number(8)
    , template_appl_id  number(16)
    , inst_id           number(4)
    , status            varchar2(8)
)
/

comment on table prd_service is 'Product services.'
/
comment on column prd_service.id is 'Primary key.'
/
comment on column prd_service.seqnum is 'Sequential number of data version'
/
comment on column prd_service.service_type_id is 'Reference to service type.'
/
comment on column prd_service.template_appl_id is 'Reference to template application.'
/
comment on column prd_service.inst_id is 'Institution identifier.'
/
comment on column prd_service.status is 'Service status (Active, Inactive).'
/

alter table prd_service add(service_number varchar2(200))
/
comment on column prd_service.service_number is 'External service number.'
/
update prd_service set service_number = to_char(id) where service_number is null
/
alter table prd_service add (split_hash number(4))
/
comment on column prd_service.split_hash is 'Hash value to split processing which is calculated by service identifier'
/
