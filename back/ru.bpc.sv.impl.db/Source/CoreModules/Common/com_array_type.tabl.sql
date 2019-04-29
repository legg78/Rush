create table com_array_type (
    id           number(4)
  , seqnum       number(4)
  , name         varchar2(200)
  , is_unique    number(1)
  , lov_id       number(4)
  , entity_type  varchar2(8)
  , data_type    varchar2(8)
  , inst_id      number(4)
)
/

comment on table com_array_type is 'Array types. '
/

comment on column com_array_type.id is 'Primary key.'
/

comment on column com_array_type.seqnum is 'Sequence number. Describe data version.'
/

comment on column com_array_type.name is 'Array type system name. Use as constant  in code.'
/

comment on column com_array_type.is_unique is 'Is item value unique in one type arrays.'
/

comment on column com_array_type.lov_id is 'List of avalable values to add into array.'
/

comment on column com_array_type.entity_type is 'Entity type of objects included into arrays.'
/

comment on column com_array_type.data_type is 'Data type of array elements.'
/

comment on column com_array_type.inst_id is 'Owner institution identifier.'
/

alter table com_array_type add (scale_id number(4))
/

comment on column com_array_type.scale_id is 'Scale identifier (for dynamic array)'
/

alter table com_array_type drop column scale_id
/

alter table com_array_type add (scale_type varchar2(8))
/

comment on column com_array_type.scale_type is 'Category of scale (for dynamic array)'
/

alter table com_array_type add (class_name varchar2(200))
/

comment on column com_array_type.class_name is 'Class name.'
/
