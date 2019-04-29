create table acq_account_scheme (
    id       number(4)
  , seqnum   number(4)
  , inst_id  number(4)
)
/

comment on table acq_account_scheme is 'Acquiring accounting scheme. Describing rules of account choosing.'
/

comment on column acq_account_scheme.id is 'Primary key.'
/
comment on column acq_account_scheme.seqnum is 'Sequence number. Describe data version.'
/
comment on column acq_account_scheme.inst_id is 'Instutition identifier.'
/
