create or replace view prd_referrer_vw as
select rr.id
     , rr.inst_id
     , rr.split_hash
     , rr.customer_id
     , rr.referral_code
  from prd_referrer rr
/
