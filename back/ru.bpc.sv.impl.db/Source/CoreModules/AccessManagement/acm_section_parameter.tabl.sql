create table acm_section_parameter(
    id         number(8)
  , seqnum     number(4)
  , section_id number(4)
  , name       varchar2(200)
  , data_type  varchar2(8)
  , lov_id     number(4)
)
/

comment on table acm_section_parameter is 'Input parameters taking by form/section.'
/

comment on column acm_section_parameter.id is 'Primary key'
/
comment on column acm_section_parameter.seqnum is 'Sequential number of data version'
/
comment on column acm_section_parameter.section_id is 'Reference to visual form.'
/
comment on column acm_section_parameter.name is 'Parameter system name.'
/
comment on column acm_section_parameter.data_type is 'Data type.'
/
comment on column acm_section_parameter.lov_id is 'List of accepted values.'
/
