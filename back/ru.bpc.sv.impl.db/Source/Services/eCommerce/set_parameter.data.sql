insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001442, 'ECM', 'ECOMMERCE', 'PLVLSYST', NULL, NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001443, 'ECM', 'MPI', 'PLVLSYST', NULL, NULL, NULL, 10001442, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001444, 'ECM', 'MPI_TERMINAL_URL', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10001443, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001445, 'ECM', 'ECOMMERCE_LOCATION', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10001442, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001446, 'ECM', 'MPI_PAYMENT_PAGE', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10001443, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001458, 'ECM', 'ECOMMERCE_PROXY_SERVER', 'PLVLSYST', NULL, NULL, NULL, 10001442, 20)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001459, 'ECM', 'ECOMMERCE_USE_PROXY_SERVER', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10001458, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001460, 'ECM', 'ECOMMERCE_PROXY_SERVER_ADDRESS', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10001458, 20)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001461, 'ECM', 'ECOMMERCE_PROXY_SERVER_PORT', 'PLVLSYST', NULL, 'DTTPNMBR', NULL, 10001458, 30)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002125, 'ECM', 'ACS', 'PLVLSYST', NULL, NULL, NULL, 10001442, 30)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002126, 'ECM', 'ACS_URL', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10002125, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002138, 'ECM', 'ACS_ID', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10002125, 20)
/
