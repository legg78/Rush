create table cmn_standard_version_obj (
    id          number(8)
  , entity_type varchar2(8)
  , object_id   number(16)
  , version_id  number(4)
  , start_date  date
)
/


comment on table cmn_standard_version_obj is 'Standard versions assigned to objects'
/

comment on column cmn_standard_version_obj.id is 'Primary key'
/

comment on column cmn_standard_version_obj.entity_type is 'Entity type'
/

comment on column cmn_standard_version_obj.object_id is 'Object identifier'
/

comment on column cmn_standard_version_obj.version_id is 'Version identifier'
/

comment on column cmn_standard_version_obj.start_date is 'Start date of version validity for device'
/

