create or replace force view mcw_ui_add_vw as
select id
     , fin_id
     , file_id
     , is_incoming
     , mti
     , de024
     , de071
     , de032
     , de033
     , de063
     , de093
     , de094
     , de100
     , p0501_1
     , p0501_2
     , p0501_3
     , p0501_4
     , p0715
  from mcw_add a
/
