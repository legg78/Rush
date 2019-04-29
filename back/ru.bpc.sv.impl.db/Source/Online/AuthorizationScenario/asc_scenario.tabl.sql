create table asc_scenario (
    id          number(4)
  , seqnum      number(4)
)
/

comment on table asc_scenario is 'Table is used to store authorization scenarios and their descriptions.'
/

comment on column asc_scenario.id is 'Primary key.'
/
comment on column asc_scenario.seqnum is 'Object version number.'
/
