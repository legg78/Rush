create or replace force view prd_ui_referrer_vw as
select rr.id
     , rr.inst_id
     , rr.split_hash
     , rr.customer_id
     , rr.referral_code
  from prd_referrer rr
 where rr.inst_id in (select acm.inst_id from acm_cu_inst_vw acm)
/
