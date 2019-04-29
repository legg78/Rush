create table prd_referrer
(
    id            number(12) not null
  , inst_id       number(4)
  , split_hash    number(4)
  , customer_id   number(12)
  , referral_code varchar2(200)
)
/
comment on table prd_referrer is 'Customers referral codes'
/
comment on column prd_referrer.id is 'Referrer code identifier'
/
comment on column prd_referrer.inst_id is 'Institution identifier'
/
comment on column prd_referrer.split_hash is 'Split hash'
/
comment on column prd_referrer.customer_id is 'Customer identifier'
/
comment on column prd_referrer.referral_code is 'Referral code generated for customer-referrer'
/
