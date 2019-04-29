create or replace force view com_holiday_vw as
select id
     , holiday_date
     , inst_id
     , seqnum
  from com_holiday
/