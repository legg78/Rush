create or replace force view acc_macros_type_vw as
select id
     , bunch_type_id
     , seqnum
     , status
  from acc_macros_type
/
