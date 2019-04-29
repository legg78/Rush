insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data, queue_identifier, time_out, port) values (10000007, 1396, 10000012, NULL, NULL, 1296, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 1, 0, NULL, NULL, NULL, NULL)
/
insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data, queue_identifier, time_out, port) values (10000008, 1389, 10000005, NULL, NULL, 1299, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 1, 0, NULL, NULL, NULL, NULL)
/
insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data, queue_identifier, time_out, port) values (10000009, 1390, 10000006, NULL, NULL, 1300, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 1, 0, NULL, NULL, NULL, NULL)
/
update prc_file_attribute set queue_identifier='ratesInbox', time_out=3600 where id=10000007
/
update prc_file_attribute set queue_identifier='merchInbox', time_out=3600 where id=10000008
/
update prc_file_attribute set queue_identifier='termInbox', time_out=3600 where id=10000009
/

