create index prd_referrer_ndx on prd_referrer (
    customer_id
)
/
create unique index prd_referrer_ref_code_ndx on prd_referrer (
    referral_code
)
/
