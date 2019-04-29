create table pmo_provider(
    id          number(8)
  , seqnum      number(4)
  , region_code varchar2(11)
)
/

comment on table pmo_provider is 'Service providers'
/

comment on column pmo_provider.id is 'Primary key'
/
comment on column pmo_provider.seqnum is 'Data version sequence number'
/
comment on column pmo_provider.region_code is 'Region code (Address classifier)'
/

alter table pmo_provider add (provider_number varchar2(200))
/
comment on column pmo_provider.provider_number is 'Service provider external number'
/

alter table pmo_provider add (parent_id number(8))
/
comment on column pmo_provider.parent_id is 'Identifier of parent provider group'
/
alter table pmo_provider add (logo_path varchar2(200))
/
comment on column pmo_provider.logo_path is 'Path to provider logotype'
/
alter table pmo_provider add inst_id number(4)
/
comment on column pmo_provider.inst_id is 'Institution identifier'
/
