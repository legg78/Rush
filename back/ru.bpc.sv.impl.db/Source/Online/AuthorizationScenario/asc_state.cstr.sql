alter table asc_state add (
    constraint asc_state_pk primary key (id)
  , constraint asc_state_uk unique (scenario_id, code)
)
/