create table prd_service_type (
    id            number(8)
  , seqnum        number(4)
  , product_type  varchar2(8)
  , entity_type   varchar2(8)
  , is_initial    number(1)
  , enable_event_type varchar2(8)
  , disable_event_type varchar2(8)
)
/

comment on table prd_service_type is 'Services types. Describe service functionality.'
/

comment on column prd_service_type.id is 'Primary key.'
/
comment on column prd_service_type.seqnum is 'Sequential number of data version'
/
comment on column prd_service_type.product_type is 'Product type (Acquiring, Issuing, Institution)'
/
comment on column prd_service_type.entity_type is 'Entity type linked with service type.'
/
comment on column prd_service_type.is_initial is 'Service type create object of linked entity.'
/
comment on column prd_service_type.enable_event_type is 'Procedure to execute when service of that type was activated for exact object.'
/
comment on column prd_service_type.disable_event_type is'Procedure to execute when service of that type was DEactivated for exact object.'
/
alter table prd_service_type add (
    service_fee    number(8)
)
/
comment on column prd_service_type.service_fee is 'Service fee identifier'
/

alter table prd_service_type add(external_code varchar2(200))
/
comment on column prd_service_type.external_code is 'External code.'
/

