create or replace force view din_ui_file_vw as
select f.id
     , f.is_incoming
     , f.network_id
     , f.inst_id
     , f.recap_total
     , f.file_date
     , f.is_rejected
  from din_file f
/
