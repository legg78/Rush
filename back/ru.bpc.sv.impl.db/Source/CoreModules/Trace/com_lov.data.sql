insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (3, NULL, 'select substr(code, -1) code, name from com_ui_dictionary_vw where dict = ''TRCL'' and lang = com_ui_user_env_pkg.get_user_lang', 'TRC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1030, 'LGMD', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (486, NULL, 'select id as code, name from acm_user_vw where inst_id in (select inst_id from acm_cu_inst_vw)', 'ACM', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1054, NULL, 'select to_number(code, ''9999'') code, name from com_ui_dictionary_vw where dict = ''ORTL'' and lang = com_ui_user_env_pkg.get_user_lang', 'TRC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
