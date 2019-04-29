create or replace force view prc_api_outgoing_file_vw as
select s.id
     , s.file_name
     , s.session_id
  from prc_session_file s
     , prc_file_attribute a
     , prc_file f
 where a.id           = s.file_attr_id
   and f.id           = a.file_id
   and f.file_purpose = 'FLPSOUTG'
/
