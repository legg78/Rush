create or replace force view com_ui_holiday_vw as
select id
     , holiday_date
     , inst_id
     , seqnum
 from com_holiday
/