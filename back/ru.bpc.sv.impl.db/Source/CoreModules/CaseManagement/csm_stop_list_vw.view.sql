create or replace force view csm_stop_list_vw as
select sl.id
     , sl.stop_list_type
     , sl.reason_code
     , sl.purge_date
     , sl.region_list
     , sl.product
  from csm_stop_list sl
/

