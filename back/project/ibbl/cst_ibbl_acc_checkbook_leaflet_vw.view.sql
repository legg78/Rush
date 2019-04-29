create or replace force view cst_ibbl_acc_cb_leaflet_vw as
select id
     , checkbook_id
     , leaflet_number
     , leaflet_status
     , reg_date
     , used_date
  from cst_ibbl_acc_checkbook_leaflet
/
