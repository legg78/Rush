create table acm_widget_param_value (
    id                     number(8) not null
    , seqnum               number(4)
    , param_value          varchar2(200)
    , widget_param_id      number(8)
    , dashboard_widget_id  number(8)
)
/

comment on table acm_widget_param_value is 'Values of widget parameters'
/
comment on column acm_widget_param_value.id is 'Parameter value identifier'
/
comment on column acm_widget_param_value.seqnum is 'Sequential number of data version'
/
comment on column acm_widget_param_value.param_value is 'Parameter value'
/
comment on column acm_widget_param_value.widget_param_id is 'Parameter identifier'
/
comment on column acm_widget_param_value.dashboard_widget_id is 'Dashboard widget identifier'
/
