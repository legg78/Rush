create table cln_case(
    id             number(16)
  , seqnum         number(4)
  , inst_id        number(4)
  , split_hash     number(4)
  , case_number    varchar2(200) 
  , creation_date  date
  , customer_id    number(12)
  , user_id        number(8)
  , status         varchar2(8)
  , resolution     varchar2(8)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table cln_case is 'Collection case.'
/
comment on column cln_case.id is 'Primary key.'
/
comment on column cln_case.seqnum is 'Sequence number. Describes data version.'
/
comment on column cln_case.inst_id is 'Institution identifier'
/
comment on column cln_case.split_hash is 'Hash value to split processing'
/
comment on column cln_case.case_number is 'Case number'
/
comment on column cln_case.creation_date is 'Case creation date'
/
comment on column cln_case.customer_id is 'Reference to customer identifier (prd_customer.id)'
/
comment on column cln_case.user_id is 'Reference to user identifier (acm_user.id)'
/
comment on column cln_case.status is 'Case status. Dictionary CNST'
/
comment on column cln_case.resolution is 'Status resolution. Dictionary CNRN'
/
