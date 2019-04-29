create table emv_tag (
    id                  number(4)
    , tag               varchar2(6)
    , min_length        number(4)
    , max_length        number(4)
    , data_type         varchar2(8)
    , data_format       varchar2(200)
    , default_value     varchar2(200)
    , tag_type          varchar2(8)
)
/
comment on table emv_tag is 'EMV tags'
/
comment on column emv_tag.id is 'Identifier'
/
comment on column emv_tag.tag is 'Tag name'
/
comment on column emv_tag.min_length is 'Minimal length'
/
comment on column emv_tag.max_length is 'Maximal length'
/
comment on column emv_tag.data_type is 'Data type (EMVT dictionary)'
/
comment on column emv_tag.data_format is 'Data format mask'
/
comment on column emv_tag.default_value is 'Default value'
/
comment on column emv_tag.tag_type is 'Tag type (EMVP dictionary)'
/