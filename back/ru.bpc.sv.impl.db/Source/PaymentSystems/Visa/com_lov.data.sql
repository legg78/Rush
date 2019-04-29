insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (193, 'VIKT', null, 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (270, 'VIB2', NULL, 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (343, 'ACAB', NULL, 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (396, null, 'select substr(code, -1) code, name from com_ui_dictionary_vw where dict = ''VDCI'' and lang = com_ui_user_env_pkg.get_user_lang', 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/

insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (416, 'VFTP', NULL, 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (417, 'VFNC', NULL, 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (418, 'VFGA', NULL, 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (428, NULL, 'select code, name from com_ui_dictionary_vw where dict = ''VIRC'' and lang = com_ui_user_env_pkg.get_user_lang', 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (118, 'VFTR', NULL, 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set dict = null, lov_query = 'select substr(code, -1) code, name from com_ui_dictionary_vw where dict = ''VFTR'' and lang = com_ui_user_env_pkg.get_user_lang' where id = 118
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (47, NULL, 'select code, name from com_ui_dictionary_vw where dict = ''FCRC'' and lang = com_ui_user_env_pkg.get_user_lang', 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (470, 'VCOC', NULL, 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (99, NULL, 'select substr(code, -2) code, name from com_ui_dictionary_vw where dict = ''RCRC'' and lang = com_ui_user_env_pkg.get_user_lang', 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/

insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (478, 'VIQR', NULL, 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (551, 'VMRC', NULL, 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (552, 'VIDS', NULL, 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (565, NULL, 'select code, name from com_ui_dictionary_vw where dict = ''FCRC'' and to_number(code) < 5000 and lang = com_ui_user_env_pkg.get_user_lang', 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set data_type = 'DTTPCHAR' where id = 396
/
update com_lov set lov_query = 'select nvl(trim(substr(code, -1)), ''[ ]'') code, name from com_ui_dictionary_vw where dict = ''VDCI'' and lang = com_ui_user_env_pkg.get_user_lang' where id = 396
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (588, 'VSMA', NULL, 'VIS', 'LVSMCODE', 'LVAPCODE', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (625, 'DSCD', NULL, 'VIS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (666, 'VSAT', NULL, 'VIS', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
