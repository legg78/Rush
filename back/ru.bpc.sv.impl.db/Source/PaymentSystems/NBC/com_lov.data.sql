insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (521, NULL, 'select substr(code, -2) code, name from com_ui_dictionary_vw where dict = ''NBRS'' and lang = com_ui_user_env_pkg.get_user_lang', 'NBC', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (522, 'NBCR', NULL, 'NBC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
