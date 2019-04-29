create table asc_state (
    id              number(8)
  , seqnum          number(4)
  , scenario_id     number(4)
  , code            number(4)
  , state_type      varchar2(8)
)
/

comment on column asc_state.code is 'Number of state in single scenario. Reference to scenario is specified by SCENARIO_ID.'
/

comment on column asc_state.id is 'Substitute key.'
/

comment on column asc_state.scenario_id is 'Reference to scenario that owns authorization state.'
/

comment on column asc_state.seqnum is 'Object version number.'
/

comment on column asc_state.state_type is
'Type of authorization scenario state. Value is obtained from 
dictionary ''ASTP''. There are different stet type: A-J, Z. 
State type defines state functions, input and output data for the state. '
/

comment on table asc_state is
'Table is used to store basic information about authorization scenario 
state. Table consists only common state information. Additional information 
for different state types is stored separately.'
/