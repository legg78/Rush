create table acq_reimb_macros_type (
    id              number(4)
  , seqnum          number(4)
  , macros_type_id  number(4)
  , amount_type     varchar2(8)
  , is_reversal     number(1)
  , inst_id         number(4)
)
/

comment on table acq_reimb_macros_type is 'Reimbursement macros types map.'
/

comment on column acq_reimb_macros_type.id is 'Primary key.'
/

comment on column acq_reimb_macros_type.seqnum is 'Sequence number. Describe data version.'
/

comment on column acq_reimb_macros_type.macros_type_id is 'Reference to macrors type.'
/

comment on column acq_reimb_macros_type.amount_type is 'Reimbursement amount type (Gross, Net, Tax, Service charge).'
/

comment on column acq_reimb_macros_type.is_reversal is 'Reversal flag.'
/

comment on column acq_reimb_macros_type.inst_id is 'Institution identifier.'
/

