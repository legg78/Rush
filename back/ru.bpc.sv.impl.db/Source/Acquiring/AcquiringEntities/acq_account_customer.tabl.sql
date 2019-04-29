create table acq_account_customer (
    customer_id number(12)
  , scheme_id   number(4)
)
/

comment on table acq_account_customer is 'Accounting schemes assigned with customers.'
/

comment on column acq_account_customer.customer_id is 'Customer identifier.'
/
comment on column acq_account_customer.scheme_id is 'Accounting scheme identifier.'
/
