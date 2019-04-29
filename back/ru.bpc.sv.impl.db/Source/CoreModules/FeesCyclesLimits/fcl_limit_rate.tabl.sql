create table fcl_limit_rate
(
    id                  number(4)
  , seqnum              number(4)
  , limit_type          varchar2(8)
  , rate_type           varchar2(8)
  , inst_id             number(4)
)
/

comment on table fcl_limit_rate is 'Limit types conversion rate map.'
/

comment on column fcl_limit_rate.id is 'Primary key.'
/

comment on column fcl_limit_rate.seqnum is 'Data version number.'
/

comment on column fcl_limit_rate.limit_type is 'Limit type.'
/

comment on column fcl_limit_rate.rate_type is 'Conversion rate type.'
/

comment on column fcl_limit_rate.inst_id is 'Institution identifier.'
/