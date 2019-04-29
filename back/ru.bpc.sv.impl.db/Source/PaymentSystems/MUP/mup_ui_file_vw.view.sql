create or replace force view mup_ui_file_vw as
select a.id
     , a.inst_id
     , a.network_id
     , a.is_incoming
     , a.proc_date
     , a.session_file_id
     , a.is_rejected
     , a.reject_id
     , a.p0026
     , a.p0105
     , a.p0110
     , a.p0122
     , a.p0301
     , a.p0306
     , a.header_mti
     , a.header_de024
     , a.header_de071
     , a.trailer_mti
     , a.trailer_de024
     , a.trailer_de071
     , a.report_type
     , a.endpoint
     , a.de094
  from mup_file a
/
