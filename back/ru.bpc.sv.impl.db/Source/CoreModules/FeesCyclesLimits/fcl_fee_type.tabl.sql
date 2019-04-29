create table fcl_fee_type
(
    id           number(4)
  , seqnum       number(4)
  , fee_type     varchar2(8)
  , entity_type  varchar2(8)
  , cycle_type   varchar2(8)
  , limit_type   varchar2(8)
)
/

comment on table fcl_fee_type is 'Fee types'
/

comment on column fcl_fee_type.id is 'Primary key.'
/

comment on column fcl_fee_type.seqnum is 'Sequence number. Describe data version.'
/

comment on column fcl_fee_type.fee_type is 'Fee type. Describe destination of fee and using area.'
/

comment on column fcl_fee_type.entity_type is 'Type of business entity (Card, Account, Customer, Institution etc.).'
/

comment on column fcl_fee_type.cycle_type is 'Type of cycle if not empty fee is cyclic.'
/

comment on column fcl_fee_type.limit_type is 'Type of limit describing start point when fee is calculating.'
/
alter table fcl_fee_type add (need_length_type number(1))
/
comment on column fcl_fee_type.need_length_type is 'Field length_type in fcl_fee_tier table is mandatory'
/
