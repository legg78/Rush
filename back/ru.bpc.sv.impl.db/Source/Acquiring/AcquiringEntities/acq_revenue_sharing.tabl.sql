create table acq_revenue_sharing
(
    id              number(12)
  , seqnum          number(4)
  , terminal_id     number(8)
  , customer_id     number(12)
  , account_id      number(12)
  , fee_type        varchar2(8)
  , fee_id          number(8)
  , inst_id         number(4)
)
/

comment on table acq_revenue_sharing is 'Acquiring fees spliting settings'
/

comment on column acq_revenue_sharing.id is 'Primary key'
/

comment on column acq_revenue_sharing.seqnum is 'Sequence number. Describe data version.'
/

comment on column acq_revenue_sharing.terminal_id is 'Terminal identifier'
/

comment on column acq_revenue_sharing.customer_id is 'Customer identifier. Participant of fee spliting.'
/

comment on column acq_revenue_sharing.account_id is 'Account for charging of splited fee.'
/

comment on column acq_revenue_sharing.fee_type is 'Type of fee for spliting'
/

comment on column acq_revenue_sharing.fee_id is 'Split rate. Described as fee algorithm.'
/

comment on column acq_revenue_sharing.inst_id is 'Institution identifier.'
/

alter table acq_revenue_sharing add (provider_id number(8))
/

comment on column acq_revenue_sharing.provider_id is 'Service provider identifier'
/

alter table acq_revenue_sharing add (mod_id number(4))
/

comment on column acq_revenue_sharing.mod_id is 'Modifier indetifier'
/

alter table acq_revenue_sharing add (service_id number(8), purpose_id number(8))
/

comment on column acq_revenue_sharing.service_id is 'Payment service id'
/

comment on column acq_revenue_sharing.purpose_id is 'Payment purpose id'
/
