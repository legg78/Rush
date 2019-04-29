create or replace force view atm_ui_collection_vw as
select id
     , terminal_id
     , start_date
     , end_date
     , collection_number
  from atm_collection
/ 