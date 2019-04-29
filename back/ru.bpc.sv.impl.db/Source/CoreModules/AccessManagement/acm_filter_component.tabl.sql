create table acm_filter_component(
    id number(8) not null
  , seqnum number(4)
  , filter_id number(8)
  , name varchar2(200)
  , value varchar2(200)
)
/
comment on table acm_filter_component is 'Filter components'
/

comment on column acm_filter_component.id is 'Record identifier'
/
comment on column acm_filter_component.seqnum is 'Sequential number of record data'
/
comment on column acm_filter_component.filter_id is 'Filter identifier'
/
comment on column acm_filter_component.name is 'Component name'
/
comment on column acm_filter_component.value is 'Component value'
/
