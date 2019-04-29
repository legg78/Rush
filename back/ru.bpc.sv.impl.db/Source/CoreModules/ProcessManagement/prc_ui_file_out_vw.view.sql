create or replace force view prc_ui_file_out_vw as
select s.id
     , a.file_id
     , a.container_id
     , a.characterset
     , a.file_name_mask
     , a.name_format_id
     , a.upload_empty_file
     , d.directory_path as location
     , a.xslt_source
     , a.converter_class
     , a.is_tar
     , a.is_zip
     , a.inst_id
     , a.load_priority
     , a.sign_transfer_type
     , a.encrypt_plugin
     , b.process_id
     , b.file_purpose
     , f.source saver_class
     , f.post_source post_saver_class
     , b.saver_id
     , b.file_nature
     , b.xsd_source
     , b.file_type
     , s.record_count
     , s.file_contents
     , s.file_bcontents
     , s.file_name
     , s.session_id
     , case when exists(select 1 from sec_rsa_key where entity_type = 'ENTTFLAT' and object_id = a.id) then 1 else 0 end rsa_key_present
     , a.ignore_file_errors
     , a.id file_attribute_id
     , s.status
     , a.parallel_degree
     , a.queue_identifier
     , a.time_out
     , a.port
     , s.thread_number
     , a.line_separator
     , a.password_protect
  from prc_file_attribute_vw a
     , prc_file_vw b
     , prc_process_vw c
     , prc_session_file_vw s
     , prc_directory_vw d
     , prc_file_saver f
 where a.file_id      = b.id
   and b.file_purpose = prc_api_file_pkg.get_file_purpose_out
   and b.process_id   = c.id
   and s.file_attr_id = a.id
   and d.id(+) = a.location_id
   and f.id(+) = b.saver_id
/
