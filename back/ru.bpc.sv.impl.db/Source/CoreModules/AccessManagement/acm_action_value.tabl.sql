create table acm_action_value(
    id             number(8)
  , action_id      number(4)
  , param_id       number(8)
  , param_value    varchar2(200)
  , param_function varchar2(200)
)
/

comment on table acm_action_value is 'Default values for input parameters for certain action.'
/

comment on column acm_action_value.id is 'Primary key.'
/
comment on column acm_action_value.action_id is 'Reference to action.'
/
comment on column acm_action_value.param_id is 'Parameter identifier.'
/
comment on column acm_action_value.param_value is 'Default value.'
/
comment on column acm_action_value.param_function is 'Name of function returning parameter value if value should be calculated.'
/

