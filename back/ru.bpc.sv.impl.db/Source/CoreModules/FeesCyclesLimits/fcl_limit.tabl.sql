create table fcl_limit (
    id             number(16)
  , seqnum         number(4)
  , limit_type     varchar2(8)
  , cycle_id       number(8)
  , count_limit    number(16)
  , sum_limit      number(22 , 4)
  , currency       varchar2(3)
  , posting_method varchar2(8)
  , is_custom      number(1)
  , inst_id        number(4)
  , limit_base     varchar2(8)
  , limit_rate     number(22, 4))
/

comment on table fcl_limit is 'Limits defined in the system.'
/

comment on column fcl_limit.id is 'Primary key.'
/

comment on column fcl_limit.seqnum is 'Sequence number. Describe data version.'
/

comment on column fcl_limit.limit_type is 'Limit type. Describe destination of limit and using area.'
/

comment on column fcl_limit.cycle_id is 'Reference to cycle.'
/

comment on column fcl_limit.count_limit is 'Value of count limit.'
/

comment on column fcl_limit.sum_limit is 'Value of sum limit.'
/

comment on column fcl_limit.currency is 'Limit currency code.'
/

comment on column fcl_limit.posting_method is 'Method of implementation limit changes. '
/

comment on column fcl_limit.is_custom is 'Limit was added by operator (0) or by customer (1).'
/

comment on column fcl_limit.inst_id is 'Institution ID limit is defined for.'
/

comment on column fcl_limit.limit_base is 'Reference to base limit type or balance type.'
/

comment on column fcl_limit.limit_rate is 'Percent to calculate dependent limit'
/


alter table fcl_limit add (check_type varchar2(8))
/

comment on column fcl_limit.check_type is 'Type of check threshold'
/

alter table fcl_limit add (counter_algorithm varchar2(8))
/

comment on column fcl_limit.counter_algorithm is 'Algorithm for calculating the counter limit'
/
comment on column fcl_limit.posting_method is 'Method of implementation limit changes (moved to fcl_limit_type table)'
/
comment on column fcl_limit.counter_algorithm is 'Algorithm for calculating the counter limit (moved to fcl_limit_type table)'
/
alter table fcl_limit add (count_max_bound number(16))
/
comment on column fcl_limit.count_max_bound is 'Upper bound of limit''s count value'
/
alter table fcl_limit add (sum_max_bound number(22,4))
/
comment on column fcl_limit.sum_max_bound is 'Upper bound of limit''s sum value'
/
