create or replace force view scr_ui_bucket_vw as
select s.id
     , s.account_id
     , s.customer_id
     , s.revised_bucket
     , s.eff_date
     , s.expir_date
     , s.valid_period
     , s.reason
     , s.user_id
     , l.lang
     , log_date
  from scr_bucket s
     , com_language_vw l
/
