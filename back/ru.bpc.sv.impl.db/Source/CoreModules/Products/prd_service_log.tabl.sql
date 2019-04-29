create table prd_service_log (
    id                   number(16) not null
    , service_object_id  number(12)
    , start_date         date
    , end_date           date
    , split_hash         number(4)
)
/

comment on table prd_service_log is 'Service object validity log'
/
comment on column prd_service_log.id is 'Primary key'
/
comment on column prd_service_log.service_object_id is 'Reference to link service with object'
/
comment on column prd_service_log.start_date is 'Services activated for business object.'
/
comment on column prd_service_log.end_date is 'Date when service become inactive.'
/
comment on column prd_service_log.split_hash is 'Hash value to split processing'
/
