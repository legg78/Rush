create table mcw_interchange_map (
    id                  number(4) not null
    , seqnum            number(4)
    , arrangement_type  varchar2(1) not null
    , arrangement_code  varchar2(8) not null
    , mod_id            number(4)
    , ird               varchar2(2)
    , priority          number(4)
)
/
comment on table mcw_interchange_map is 'Match modifier with code interchange'
/
comment on column mcw_interchange_map.id is 'Match identifier'
/
comment on column mcw_interchange_map.seqnum is 'Sequential number of record version'
/
comment on column mcw_interchange_map.arrangement_type is 'The business service arrangement type.'
/
comment on column mcw_interchange_map.arrangement_code is 'The business service arrangement ID code.'
/
comment on column mcw_interchange_map.mod_id is 'Modifier identifier'
/
comment on column mcw_interchange_map.ird is 'Interchange rate designator value'
/
comment on column mcw_interchange_map.priority is 'Modifier priority'
/
alter table mcw_interchange_map add is_default number(1)
/
comment on column mcw_interchange_map.is_default is 'Default ìatch modifier'
/
 