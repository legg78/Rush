create table rul_name_format (
    id                      number(4)
    , inst_id               number(4)
    , seqnum                number(4)
    , entity_type           varchar2(8)
    , name_length           number(4)
    , pad_type              varchar2(8)
    , pad_string            varchar2(200)
    , check_algorithm       varchar2(8)
    , check_base_position   number(4)
    , check_base_length     number(4)
    , check_position        number(4)
    , index_range_id        number(8)
    , check_name            number(1)
)
/
comment on table rul_name_format is 'Format description for generation of name'
/
comment on column rul_name_format.id is 'Identifier'
/
comment on column rul_name_format.inst_id is 'Owner institution identifier'
/
comment on column rul_name_format.seqnum is 'Sequential number of data version'
/
comment on column rul_name_format.entity_type is 'Entity type'
/
comment on column rul_name_format.name_length is 'Length of name'
/
comment on column rul_name_format.pad_type is 'Padding method'
/
comment on column rul_name_format.pad_string is 'Padding string'
/
comment on column rul_name_format.check_algorithm is 'Algorithm for check digit generation'
/
comment on column rul_name_format.check_base_position is 'Starting position of base for check digit calculation'
/
comment on column rul_name_format.check_base_length is 'Ending position of base for check digit calculation'
/
comment on column rul_name_format.check_position is 'Position for check digit'
/
comment on column rul_name_format.index_range_id is 'Identifier of index range'
/
comment on column rul_name_format.check_name is 'Checking name'
/
