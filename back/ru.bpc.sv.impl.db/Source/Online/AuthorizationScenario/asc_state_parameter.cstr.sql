alter table asc_state_parameter add( 
    constraint asc_state_parameter_pk primary key (id)
  , constraint asc_state_parameter_uk unique (state_type, param_id)
)
/