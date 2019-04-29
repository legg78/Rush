create or replace force view scr_value_vw
as
select id         
     , seqnum     
     , criteria_id
     , score
  from scr_value
/
