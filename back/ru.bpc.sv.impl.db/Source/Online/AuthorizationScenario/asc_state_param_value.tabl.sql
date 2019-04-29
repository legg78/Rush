create table asc_state_param_value (
    state_id    number(8)
  , param_id    number(8)
  , param_value varchar2(200)
)
/

comment on column asc_state_param_value.param_id is
'Reference to state parameter description.'
/

comment on column asc_state_param_value.state_id is
'Reference to state for which parameters specification is required.'
/

comment on column asc_state_param_value.param_value is
'Value of parameter referenced by PARAMETER_ID for the state 
referenced by STATE_ID.'
/

comment on table asc_state_param_value is
'Table is used for storing values of parameters for authorization 
state instances.'
/