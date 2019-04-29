create or replace force view cst_ibbl_acc_checkbook_vw as
select id
     , checkbook_number
     , checkbook_status
     , delivery_branch_number
     , leaflet_count
     , reg_date
     , spent_date
  from cst_ibbl_acc_checkbook
/
