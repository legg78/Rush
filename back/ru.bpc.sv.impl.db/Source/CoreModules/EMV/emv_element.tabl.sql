create table emv_element (
    id                   number(8)  not null
    , seqnum             number(4)
    , parent_id          number(8)
    , entity_type        varchar2(8)
    , object_id          number(8)
    , element_order      number(4)
    , code               varchar2(200)
    , tag                varchar2(6)
    , value              varchar2(2000)
    , is_optional        number(1)
    , add_length         number(1)
    , start_position     number(4)
    , length             number(4)
)
/
comment on table emv_element is 'EMV element'
/
comment on column emv_element.id is 'Primary key'
/
comment on column emv_element.seqnum is 'Data version sequencial number.'
/
comment on column emv_element.parent_id is 'Reference to parent element'
/
comment on column emv_element.entity_type is 'Entity type element'
/
comment on column emv_element.object_id is 'Element object identifier'
/
comment on column emv_element.element_order is 'Order within element'
/
comment on column emv_element.code is 'Element code'
/
comment on column emv_element.tag is 'Tag name'
/
comment on column emv_element.value is 'Tag value'
/
comment on column emv_element.is_optional is 'Option if value is optional'
/
comment on column emv_element.add_length is 'Add to value of length'
/
comment on column emv_element.start_position is 'Returns a portion of element value, beginning at start_position, length long.'
/
comment on column emv_element.length is 'Returns a portion of element value, beginning at start_position, length long.'
/
alter table emv_element add profile varchar2(8)
/
comment on column emv_element.profile is 'Profile of EMV application (EPFL dictionary)'
/
