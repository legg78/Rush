create table prd_product_service (
    id                  number(8)
    , seqnum            number(4)
    , parent_id         number(8)
    , service_id        number(8)
    , product_id        number(8)
    , min_count         number(4)
    , max_count         number(4)
)
/

comment on table prd_product_service is 'Services linked with exact product.'
/
comment on column prd_product_service.id is 'Primary key'
/
comment on column prd_product_service.seqnum is 'Sequential number of data version'
/
comment on column prd_product_service.parent_id is 'Reference to initial service. Could be null only for initial services.'
/
comment on column prd_product_service.service_id is 'Reference to service.'
/
comment on column prd_product_service.product_id is 'Reference to product.'
/
comment on column prd_product_service.product_id is 'Minimum of services opened for one contract.'
/
comment on column prd_product_service.product_id is 'Maxmum of services opened for one contract.'
/
comment on column prd_product_service.product_id is 'Reference to product.'
/
comment on column prd_product_service.max_count is 'Maximum of services opened for one contract.'
/
comment on column prd_product_service.min_count is 'Minimum of services opened for one contract.'
/
alter table prd_product_service add (conditional_group varchar2(8))
/
comment on column prd_product_service.conditional_group is 'Conditions of service group (dictionary CNDS).'
/

