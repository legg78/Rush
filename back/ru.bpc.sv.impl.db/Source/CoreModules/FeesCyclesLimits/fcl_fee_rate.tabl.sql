create table fcl_fee_rate
(
    id              number(4)
  , seqnum          number(4)
  , fee_type        varchar2(8)
  , rate_type       varchar2(8)
  , inst_id         number(4)
)
/

comment on table fcl_fee_rate is 'Fee types conversion rate map.'
/

comment on column fcl_fee_rate.id is 'Primary key.'
/

comment on column fcl_fee_rate.seqnum is 'Data version number.'
/

comment on column fcl_fee_rate.fee_type is 'Fee type.'
/

comment on column fcl_fee_rate.rate_type is 'Conversion rate type.'
/

comment on column fcl_fee_rate.inst_id is 'Institution identifier.'
/