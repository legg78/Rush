insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (109, 'DTPL', NULL, 'PRC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (224, NULL, 'select id code, name from prc_ui_process_vw where lang = com_ui_user_env_pkg.get_user_lang', 'PRC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (226, 'FLNT', NULL, 'PRC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (280, 'FLTP', NULL, 'PRC', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (286, NULL, 'select procedure_name code, name from prc_ui_process_vw where lang = com_ui_user_env_pkg.get_user_lang', 'PRC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (336, null, 'select element_value code, label name from com_ui_array_element_vw where array_id = 17 and lang = get_user_lang', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set module_code = 'PRC' where id = 336
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (390, NULL, 'select id code, name from prc_ui_process_all_vw where lang = com_ui_user_env_pkg.get_user_lang', 'PRC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (399, 'DENC', NULL, 'PRC', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (400, NULL, 'select a.id as code, a.directory_path as name from prc_directory a', 'PRC', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (404, NULL, 'select id as code, name from prc_ui_file_saver_vw where lang = com_ui_user_env_pkg.get_user_lang', 'PRC', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1037, NULL, 'select process_id as code, process_desc_short as name, group_id from prc_ui_group_process_vw where lang = com_ui_user_env_pkg.get_user_lang', 'PRC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
update com_lov set lov_query = 'select p.id as code, p.name as name, g.group_id from prc_ui_process_vw p, prc_group_process g where p.id = g.process_id(+) and p.lang = com_ui_user_env_pkg.get_user_lang', is_parametrized = 1 where id = 1037
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (7004, NULL, 'select element_value code, label name from com_ui_array_element_vw where array_id = 10000027 and lang = com_ui_user_env_pkg.get_user_lang', 'NET', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
update com_lov set id = 1051 where id = 7004
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1059, NULL, 'select numeric_value as code, get_text (i_table_name => ''prc_process'', i_column_name => ''name'', i_object_id => numeric_value) as name from com_array_element where array_id = 10000041', 'PRC', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (712, 'FMMD', NULL, 'PRC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (741, 'EXEM', NULL, 'PRC', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0, NULL, NULL)
/
