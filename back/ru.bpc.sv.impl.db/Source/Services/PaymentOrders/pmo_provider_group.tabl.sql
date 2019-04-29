create table pmo_provider_group(
    id                    number(8)
  , seqnum                number(4)
  , parent_id             number(8)
  , region_code           varchar2(11)
  , provider_group_number varchar2(200)
  , logo_path             varchar2(200)
)
/

comment on table pmo_provider_group is 'Service provider groups'
/

comment on column pmo_provider_group.id is 'Primary key'
/
comment on column pmo_provider_group.seqnum is 'Data version sequence number'
/
comment on column pmo_provider_group.parent_id is 'Identifier of parent provider group'
/
comment on column pmo_provider_group.region_code is 'Region code (Address classifier)'
/
comment on column pmo_provider_group.provider_group_number is 'Service provider group external number'
/
comment on column pmo_provider_group.logo_path is 'Path to provider logotype'
/
alter table pmo_provider_group add inst_id number(4)
/
comment on column pmo_provider_group.inst_id is 'Institution identifier'
/
