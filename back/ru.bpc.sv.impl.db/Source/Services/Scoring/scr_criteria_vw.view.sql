create or replace force view scr_criteria_vw
as
select id            
     , seqnum       
     , evaluation_id
     , order_num
  from scr_criteria
/
