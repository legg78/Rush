create table prc_process_parameter (
    id               number(8) not null
    , process_id     number(8)
    , param_id       number(8)
    , default_value  varchar2(2000)
    , display_order  number(4)
    , is_format      number(1)
    , is_mandatory   number(1)
)
/
comment on table prc_process_parameter is 'Association of process and parameter'
/
comment on column prc_process_parameter.id is 'Record identifier'
/
comment on column prc_process_parameter.process_id is 'Process identifier'
/
comment on column prc_process_parameter.param_id is 'Parameter identifier'
/
comment on column prc_process_parameter.default_value is 'Default value of parameter of process'
/
comment on column prc_process_parameter.display_order is 'Display order'
/
comment on column prc_process_parameter.is_format is 'Type of processing - format the value or leave as is'
/
comment on column prc_process_parameter.is_mandatory is 'Is mandatory parameter'
/
alter table prc_process_parameter add lov_id number(4)
/
comment on column prc_process_parameter.lov_id is 'List of values identifier'
/
