create or replace force view prc_file_attribute_vw as
select a.id
     , a.file_id
     , a.container_id
     , a.characterset
     , a.file_name_mask
     , a.name_format_id
     , a.upload_empty_file
     , a.location_id
     , a.xslt_source
     , a.converter_class
     , a.is_tar
     , a.is_zip
     , a.inst_id
     , a.report_id
     , a.report_template_id
     , a.load_priority
     , a.sign_transfer_type
     , a.encrypt_plugin
     , a.ignore_file_errors
     , a.parallel_degree
     , a.is_file_name_unique
     , a.is_file_required
     , a.queue_identifier
     , a.time_out
     , a.port
     , a.line_separator
     , a.password_protect
     , a.is_cleanup_data
     , a.file_merge_mode
  from prc_file_attribute a
/
