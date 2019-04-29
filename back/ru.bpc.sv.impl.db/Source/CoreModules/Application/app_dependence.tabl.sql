create table app_dependence (
    id               number(8)
  , seqnum           number(4)
  , struct_id        number(8)
  , depend_struct_id number(8)
  , dependence       varchar2(8)
  , condition        varchar2(200)
  , affected_zone    varchar2(8)
)
/

comment on table app_dependence is 'Depenedences between elements in aplication structure.'
/

comment on column app_dependence.id is 'Primary key.'
/
comment on column app_dependence.seqnum is 'Sequence number. Describe data version.'
/
comment on column app_dependence.struct_id is 'Reference to aplication structure element.'
/
comment on column app_dependence.depend_struct_id is 'Reference to dependent aplication structure element.'
/
comment on column app_dependence.dependence is 'Dependence type.'
/
comment on column app_dependence.condition is 'Dependence condition. Calculate dependent element property value or change application structure.'
/
comment on column app_dependence.affected_zone is 'Dependency affected zone.'
/
