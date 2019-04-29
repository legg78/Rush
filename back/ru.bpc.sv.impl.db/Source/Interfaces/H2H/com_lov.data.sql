insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (676, NULL, 'select version_number code, c.description name from cmn_ui_standard_version_vw c where standard_id = 1052 and lang = com_ui_user_env_pkg.get_user_lang', 'H2H', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (733, NULL, 'select d.dict || d.code as code, d.name from com_ui_dictionary_vw d where d.dict = ''USIC'' and d.module_code = ''H2H'' and d.lang = com_ui_user_env_pkg.get_user_lang()', 'H2H', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL, NULL)
/
