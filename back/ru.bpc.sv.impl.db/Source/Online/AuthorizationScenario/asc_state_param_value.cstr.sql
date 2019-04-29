alter table asc_state_param_value add (
    constraint asc_state_param_value_pk primary key(state_id, param_id)
)
/