insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data) values (10000001, 1312, 1, NULL, '.*', NULL, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, 1, 1, 1, 0, NULL)
/
update prc_file_attribute set is_zip = 1 where id = 10000001
/
insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data, queue_identifier, time_out, port) values (10000005, 1411, 10000010, NULL, NULL, 1298, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, 1000, NULL, 1, 0, NULL, NULL, NULL, NULL)
/
update prc_file_attribute set queue_identifier='productInbox', time_out=3600 where id=10000005
/

