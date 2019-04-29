create or replace force view prc_ui_session_file_vw as
select a.id
     , a.session_id
     , a.file_attr_id
     , a.file_name
     , a.file_date
     , a.record_count
     , a.crc_value
     , a.status
     , a.file_contents
     , a.file_bcontents
     , a.file_xml_contents
     , f.file_type
     , f.file_purpose
     , d.directory_path as location
     , a.thread_number
     , t.line_separator
     , a.object_id
     , a.entity_type
  from prc_session_file a
     , prc_file_attribute t
     , prc_file f
     , prc_directory_vw d
 where a.file_attr_id = t.id
   and t.file_id = f.id
   and d.id(+) = t.location_id
/
