insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data, queue_identifier, time_out, port) values (10000011, 1395, 10000002, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 1, 0, NULL, 'dbalInbox', 600, NULL)
/
insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data, queue_identifier, time_out, port) values (10000012, 1399, 10000013, NULL, NULL, 1302, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 1, 0, NULL, 'notifInbox', 180, NULL)
/
insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data, queue_identifier, time_out, port) values (10000016, 1418, 10000002, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1, 0, NULL, 'rejectOutbox', 180, NULL)
/
insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data, queue_identifier, time_out, port) values (10000017, 1419, 10000001, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1, 0, NULL, 'rejectOutbox', 180, NULL)
/
update prc_file_attribute set time_out = 3600 where id = 10000011
/
update prc_file_attribute set time_out = 3600 where id = 10000012
/
update prc_file_attribute set time_out = 600 where id = 10000016
/
update prc_file_attribute set time_out = 600 where id = 10000017
/
update prc_file_attribute set name_format_id = 1303 where id = 10000011
/
insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data, queue_identifier, time_out, port, line_separator) values (10000018, 1471, 10000026, 'UTF-8', NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1, 0, NULL, NULL, NULL, NULL, 'OS-defined')
/
insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data, queue_identifier, time_out, port, line_separator) values (10000019, 1472, 10000027, 'UTF-8', NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1, 0, NULL, NULL, NULL, NULL, 'OS-defined')
/
delete from prc_file_attribute where id = 10000018
/
delete from prc_file_attribute where id = 10000019
/
insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data, queue_identifier, time_out, port, line_separator) values (10000020, 1478, 10000005, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1, 0, NULL, 'rejectOutbox', 600, NULL, NULL)
/
insert into prc_file_attribute (id, file_id, container_id, characterset, file_name_mask, name_format_id, upload_empty_file, location, xslt_source, converter_class, is_tar, is_zip, inst_id, report_id, report_template_id, load_priority, sign_transfer_type, encrypt_plugin, ignore_file_errors, location_id, parallel_degree, is_file_name_unique, is_file_required, is_cleanup_data, queue_identifier, time_out, port, line_separator) values (10000021, 1479, 10000006, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 9999, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1, 0, NULL, 'rejectOutbox', 600, NULL, NULL)
/
