create table asc_parameter (
    id          number(8)
  , param_name  varchar2(200)
  , data_type   varchar2(8)
  , lov_id      number(4)
)
/

comment on column asc_parameter.data_type is
'Datatype of authorization scenario parameter. Valid values are specified by 
dictionary ''DTTP''.'
/

comment on column asc_parameter.id is
'Substitute key.'
/

comment on column asc_parameter.lov_id is
'Reference to list of values that specifies valid values for parameter.'
/

comment on column asc_parameter.param_name is
'Name of authorization scenario parameter.'
/

comment on table asc_parameter is
'Table is used to define available parameters for authorization scenario 
adjustment.'
/