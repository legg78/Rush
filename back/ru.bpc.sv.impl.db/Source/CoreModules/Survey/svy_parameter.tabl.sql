create table svy_parameter(
    id               number(8)
  , seqnum           number(4)
  , param_name       varchar2(50)
  , data_type        varchar2(8)
  , display_order    number(4)
  , lov_id           number(4)
  , is_multi_select  number(1)
  , is_system_param  number(1)
  , table_name       varchar2(50) 
)
/
comment on table svy_parameter is 'Surveys parameters stored here.'
/
comment on column svy_parameter.id is 'Parameter identifier.'
/
comment on column svy_parameter.seqnum is 'Sequence number. Describe data version.'
/
comment on column svy_parameter.param_name is 'System name of parameter. For system parameter it must be equal field name from table.'
/
comment on column svy_parameter.data_type is 'Data type.'
/
comment on column svy_parameter.display_order is 'Parameter order in survey.'
/
comment on column svy_parameter.lov_id is 'List of available values.'
/
comment on column svy_parameter.is_multi_select is 'Multi-values flag. Parameter can has several values in survey.'
/
comment on column svy_parameter.is_system_param is 'It is system parameter flag. Indicates that parameter name is equal to field from system table.'
/
comment on column svy_parameter.table_name is 'System table whose field is used as survey parameter. Used together with flag is_system_param.'
/
