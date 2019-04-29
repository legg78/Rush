create table prd_referral
(
    id          number(12) not null
  , inst_id     number(4)
  , split_hash  number(4)
  , customer_id number(12)
  , referrer_id varchar2(200)
)
/
comment on table prd_referral is 'Customers referral codes'
/
comment on column prd_referral.id is 'Referrer code identifier'
/
comment on column prd_referral.inst_id is 'Institution identifier'
/
comment on column prd_referral.split_hash is 'Split hash'
/
comment on column prd_referral.customer_id is 'Customer identifier'
/
comment on column prd_referral.referrer_id is 'Reference to customer-referrer. prd_referrer.id'
/
