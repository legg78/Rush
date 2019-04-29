create table fcl_fee
(
    id               number(8)
  , seqnum           number(4)
  , fee_type         varchar2(8)
  , currency         varchar2(3)
  , fee_rate_calc    varchar2(8)
  , fee_base_calc    varchar2(8)
  , limit_id         number(16)
  , cycle_id         number(8)
  , inst_id          number(4)
)
/

comment on table fcl_fee is 'Fees defined in system.'
/

comment on column fcl_fee.id is 'Primary key.'
/

comment on column fcl_fee.seqnum is 'Sequence number. Describe data version.'
/

comment on column fcl_fee.fee_type is 'Fee type. Describe destination of fee and using area.'
/

comment on column fcl_fee.currency is 'Currency for fixed value.'
/

comment on column fcl_fee.fee_rate_calc is 'Fee parameter describing how is rate calculating.'
/

comment on column fcl_fee.fee_base_calc is 'Fee parameter describing how is base calculating.'
/

comment on column fcl_fee.limit_id is 'Reference to limit.'
/

comment on column fcl_fee.cycle_id is 'Reference to cycle.'
/

comment on column fcl_fee.inst_id is 'Institution ID fee is defined for.'
/