alter table cmn_standard_object add constraint cmn_standard_object_pk primary key (
    id
)
/
create unique index cmn_standard_object_uk on cmn_standard_object(
    object_id
    , entity_type
    , decode(standard_type, 'STDT0001', 'STDT0002', standard_type)
)
/
