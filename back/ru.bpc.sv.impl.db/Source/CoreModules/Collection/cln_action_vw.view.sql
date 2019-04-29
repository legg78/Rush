create or replace force view cln_action_vw as
select id
     , case_id 
     , seqnum
     , split_hash
     , activity_category
     , activity_type
     , user_id
     , action_date
     , eff_date
     , status
     , resolution
     , commentary
  from cln_action
/
