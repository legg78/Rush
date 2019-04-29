insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002157, 'OPR', 'MATCHING', 'PLVLINST', NULL, NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002158, 'OPR', 'MATCH_DEPTH', 'PLVLINST', NULL, 'DTTPNMBR', NULL, 10002157, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002723, 'OPR', 'OPERATIONS', 'PLVLINST', NULL, NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002724, 'OPR', 'OPERATIONS_SEARCH_RESULT_MAX_RECORDS', 'PLVLINST', '000000000000001000.0000', 'DTTPNMBR', NULL, 10002723, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004379, 'OPR', 'MATCH_RESTRICTION', 'PLVLINST', 'RMCH0000', 'DTTPCHAR', 696, 10002157, 20, NULL)
/
