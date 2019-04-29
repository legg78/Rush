create table acc_scheme(
    id                 number(4)
  , seqnum             number(4)
  , inst_id            number(4)
)
/
comment on table acc_scheme is 'Account schemes'
/

comment on column acc_scheme.id is 'Primary key'
/
comment on column acc_scheme.seqnum is 'Data version number'
/
comment on column acc_scheme.inst_id is 'Institution identifier'
/

