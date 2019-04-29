create table asc_state_parameter (
    id                  number(4)
  , seqnum              number(4)
  , state_type          varchar2(8)
  , param_id            number(8)
  , default_value       varchar2(200)
  , display_order       number(4)
)
/

comment on column asc_state_parameter.default_value is
'Default value for parameter if it is not specified 
for the authorization state instance.'
/

comment on column asc_state_parameter.display_order is
'Display order of parameter in user interface.'
/

comment on column asc_state_parameter.id is
'Substitute key.'
/

comment on column asc_state_parameter.seqnum is
'Object data version.'
/

comment on column asc_state_parameter.param_id is
'Reference to state parameter description.'
/

comment on column asc_state_parameter.state_type is
'Type of authorization scenario state. Value is obtained from 
dictionary ''ASTP''. There are different stet type: A-J, Z. State type 
defines state functions, input and output data for the state. '
/

comment on table asc_state_parameter is
'Table is used to define valid parameters for different 
authorization state types.'
/