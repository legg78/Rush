create or replace force view acc_macros_bunch_type_vw as
select id
     , seqnum
     , bunch_type_id
     , status
     , inst_id
  from acc_macros_bunch_type
/
