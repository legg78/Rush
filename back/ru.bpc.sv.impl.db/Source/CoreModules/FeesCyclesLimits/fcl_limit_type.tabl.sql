create table fcl_limit_type
(
    id           number(4)
  , seqnum       number(4)
  , limit_type   varchar2(8)
  , entity_type  varchar2(8)
  , cycle_type   varchar2(8)
  , is_internal  number(1)
)
/

comment on table fcl_limit_type is 'Limit types.'
/

comment on column fcl_limit_type.id is 'Primary key.'
/

comment on column fcl_limit_type.seqnum is 'Sequence number. Describe data version.'
/

comment on column fcl_limit_type.limit_type is 'Limit type. Describe destination of limit and using area.'
/

comment on column fcl_limit_type.entity_type is 'Type of business entity (Card, Account, Customer, Institution etc.).'
/

comment on column fcl_limit_type.cycle_type is 'Type of cycle.  Describe destination and using area.'
/

comment on column fcl_limit_type.is_internal is 'Is limit using only inside BO or must uploading into FE.'
/

alter table fcl_limit_type add (posting_method varchar2(8))
/
comment on column fcl_limit_type.posting_method is 'Method of implementation limit changes. '
/
alter table fcl_limit_type add (counter_algorithm varchar2(8))
/
comment on column fcl_limit_type.counter_algorithm is 'Limit counter calculation algorithm'
/
alter table fcl_limit_type add (limit_usage varchar2(8))
/
comment on column fcl_limit_type.limit_usage is 'Limit usage algorithm'
/
