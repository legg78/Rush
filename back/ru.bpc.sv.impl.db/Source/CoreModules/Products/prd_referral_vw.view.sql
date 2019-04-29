create or replace view prd_referral_vw as
select rl.id
     , rl.inst_id
     , rl.split_hash
     , rl.customer_id
     , rl.referrer_id
  from prd_referral rl
/
