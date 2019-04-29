create table app_type
(
    appl_type    varchar2(8)
  , module_code  varchar2(3)
  , xsd_source   clob
)
/

comment on table app_type is 'Application types. Define application structure.'
/

comment on column app_type.appl_type is 'Application type. '
/

comment on column app_type.module_code is 'Module code (issuer ISS or acquier ACQ).'
/

comment on column app_type.xsd_source is 'XSD document defined by application structure.'
/