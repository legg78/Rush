insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004371, 'AUT', 'AUT_MERGE_REVERSAL', 'PLVLINST', 'MRVA0000', 'DTTPCHAR', 695, 10000938, 120, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004372, 'AUT', 'AUT_MERGE_STTL_TYPE_ID', 'PLVLINST', NULL, 'DTTPCHAR', 485, 10000938, 130, NULL)
/
update set_parameter set data_type = 'DTTPNMBR' where id = 10004372
/
