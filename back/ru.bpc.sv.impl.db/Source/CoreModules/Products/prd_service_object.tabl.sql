create table prd_service_object (
    id           number(12)
  , contract_id  number(12)
  , service_id   number(8)
  , entity_type  varchar2(8)
  , object_id    number(16)
  , status       varchar2(8)
  , start_date   date
  , end_date     date
  , split_hash   number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/

comment on table prd_service_object is 'Services activated for business object.'
/
comment on column prd_service_object.contract_id is 'Reference to contract.'
/
comment on column prd_service_object.service_id is 'Reference to service.'
/
comment on column prd_service_object.entity_type is 'Entity type of service owner.'
/
comment on column prd_service_object.object_id is 'Service owner identifier.'
/
comment on column prd_service_object.object_id is 'Service owner identifier.'
/
comment on column prd_service_object.status is 'Service status for object (SROS dictionary)'
/
comment on column prd_service_object.start_date is 'Service activation start date.'
/
comment on column prd_service_object.end_date is 'Date when service become inactive.'
/
comment on column prd_service_object.split_hash is 'Hash value to split processing'
/
comment on column prd_service_object.id is 'Record identifier'
/
alter table prd_service_object enable row movement
/
