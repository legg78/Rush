create table pmo_provider_host (
    host_member_id number(4)
  , provider_id    number(8)
  , execution_type varchar2(8)
  , priority       number(4)
  , mod_id         number(4)
  , inactive_till  date
)
/

comment on table pmo_provider_host is 'Hosts assigned with service provider'
/

comment on column pmo_provider_host.host_member_id is 'Host identifier'
/

comment on column pmo_provider_host.provider_id is 'Service provider identifier'
/

comment on column pmo_provider_host.execution_type is 'Type of payment order execution'
/

comment on column pmo_provider_host.priority is 'Priority of host for exact service provider. Could be used in host choosing algorithm.'
/

comment on column pmo_provider_host.mod_id is 'Modifier define availability of paying to service provider.'
/

comment on column pmo_provider_host.inactive_till is 'Until that date system will not use this host for sending financial transactions. Applicable only if current date less that date of inactivity.'
/

alter table pmo_provider_host add (status varchar2(8))
/

comment on column pmo_provider_host.status is 'Provider-host status. PHST dict.'
/
