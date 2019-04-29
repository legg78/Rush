create table acm_widget_param (
    id             number(8) not null
    , seqnum       number(4)
    , param_name   varchar2(30)
    , data_type    varchar2(8)
    , lov_id       number(4)
    , widget_id    number(4)
)
/

comment on table acm_widget_param is 'List of parameters of widgets'
/
comment on column acm_widget_param.id is 'Parameter identifier'
/
comment on column acm_widget_param.seqnum is 'Sequential number of data version'
/
comment on column acm_widget_param.param_name is 'Parameter name'
/
comment on column acm_widget_param.data_type is 'Parameter data type'
/
comment on column acm_widget_param.lov_id is 'List of values identifier'
/
comment on column acm_widget_param.widget_id is 'Widgets identifier'
/
