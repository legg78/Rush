create table pmo_purpose_parameter(
    id                number (8) not null
  , seqnum            number (4)
  , param_id          number (8)
  , purpose_id        number (8)
  , order_stage       varchar2(8)
  , display_order     number(4)
  , is_mandatory      number(1)
  , is_template_fixed number(1)
  , is_editable       number(1)
  , default_value     varchar2(2000)
)
/

comment on table pmo_purpose_parameter is 'Parameters assigned with payment purpose'
/

comment on column pmo_purpose_parameter.id is 'Primary key'
/
comment on column pmo_purpose_parameter.seqnum is 'Data version sequence number'
/
comment on column pmo_purpose_parameter.param_id is 'Reference to parameter'
/
comment on column pmo_purpose_parameter.purpose_id is 'Reference to payment purpose'
/
comment on column pmo_purpose_parameter.order_stage is 'Stage of order details definition when such parameter will be available'
/
comment on column pmo_purpose_parameter.display_order is 'Display order'
/
comment on column pmo_purpose_parameter.is_mandatory is 'Mandatory flag'
/
comment on column pmo_purpose_parameter.is_template_fixed is 'Is parameter value should be fixed in template.'
/
comment on column pmo_purpose_parameter.is_editable is 'Is parameter value could be defined by customer or it''s hidden constant'
/
comment on column pmo_purpose_parameter.default_value is 'Default value. Must be filled if parameter not editable.'
/
alter table pmo_purpose_parameter add (param_function varchar2(200))
/
comment on column pmo_purpose_parameter.param_function is 'Function used to calculate a parameter value when this parameter is being added to a payment order. Such functions are grouped into package pmo_api_param_function_pkg.'
/
