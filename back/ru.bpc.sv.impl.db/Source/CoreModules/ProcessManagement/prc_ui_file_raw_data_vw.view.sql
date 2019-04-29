create or replace force view prc_ui_file_raw_data_vw
as
  select   a.session_file_id
         , a.record_number
         , a.raw_data
  from     prc_file_raw_data a
  order by a.session_file_id
         , a.record_number
/
