create table fcl_fee_tier
(
    id              number(8)
  , seqnum          number(3)
  , fee_id          number(8)
  , fixed_rate      number(22,4)
  , percent_rate    number(22,4)
  , min_value       number(22,4)
  , max_value       number(22,4)
  , length_type     varchar2(8)
  , sum_threshold   number(22,4)
  , count_threshold number(22,4)
)
/

comment on table fcl_fee_tier is 'Fee ranges if fee depends on incoming amount.'
/

comment on column fcl_fee_tier.id is 'Primary key.'
/

comment on column fcl_fee_tier.seqnum is 'Sequence number. Describe data version.'
/

comment on column fcl_fee_tier.fee_id is 'Reference to fee.'
/

comment on column fcl_fee_tier.fixed_rate is 'Fixed fee amount in fee currency.'
/

comment on column fcl_fee_tier.percent_rate is 'Percent calculating on incoming amount.'
/

comment on column fcl_fee_tier.min_value is 'Minimum amount of final sum'
/

comment on column fcl_fee_tier.max_value is 'Minimum amount of final sum'
/

comment on column fcl_fee_tier.length_type is 'Period interest calculation unit (Year, Month, Day).'
/

comment on column fcl_fee_tier.sum_threshold is 'Range lower threshold for sum.'
/

comment on column fcl_fee_tier.count_threshold is 'Range lower threshold for count.'
/

alter table fcl_fee_tier add (length_type_algorithm varchar2(8))
/
comment on column fcl_fee_tier.length_type_algorithm is 'Algorithm for determining the length of the year.'
/
