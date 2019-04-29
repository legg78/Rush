create or replace force view scr_grade_vw
as
select id            
     , seqnum       
     , evaluation_id
     , total_score  
     , grade
  from scr_grade
/
