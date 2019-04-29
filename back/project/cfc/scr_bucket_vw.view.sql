create or replace force view scr_bucket_vw as
select id
     , account_id
     , customer_id
     , revised_bucket
     , eff_date
     , expir_date
     , valid_period
     , reason
     , user_id
     , log_date
  from scr_bucket
/
