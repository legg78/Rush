create or replace force view prd_ui_referral_vw as
select rl.id
     , rl.inst_id
     , rl.split_hash
     , rl.customer_id
     , rl.referrer_id
  from prd_referral rl
 where rl.inst_id in (select inst_id from acm_cu_inst_vw)
/
