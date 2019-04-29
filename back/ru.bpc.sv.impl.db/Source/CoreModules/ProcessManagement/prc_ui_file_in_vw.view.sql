create or replace force view prc_ui_file_in_vw as
select a.id
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
     , s.source saver_class
     , b.saver_id
     , b.file_nature
     , b.xsd_source
     , b.file_type
     , case when exists(select 1 from sec_rsa_key where entity_type = 'ENTTFLAT' and object_id = a.id) then 1 else 0 end rsa_key_present
     , a.ignore_file_errors
     , a.parallel_degree
     , a.is_file_required
     , a.queue_identifier
     , a.time_out
     , a.port
     , a.line_separator
     , a.password_protect
  from prc_file_attribute_vw a
     , prc_file_vw b
     , prc_process_vw c
     , prc_directory_vw d
     , prc_file_saver s
 where a.file_id      = b.id
   and b.file_purpose = prc_api_file_pkg.get_file_purpose_in
   and b.process_id   = c.id
   and a.location_id = d.id(+)
   and s.id(+) = b.saver_id
/
