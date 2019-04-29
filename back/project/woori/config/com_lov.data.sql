insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5003, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict in (''5001'') and lang = com_ui_user_env_pkg.get_user_lang()', 'COM', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5004, NULL, 'select a.id as code, a.label as name from rul_ui_name_format_vw a where a.entity_type = ''ENTTACCT'' and a.lang = get_user_lang', 'ACC', 'LVSMNAME', 'LVAPNMCD', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5008, NULL, 'select ae.element_value as code, com_api_i18n_pkg.get_text(''COM_ARRAY_ELEMENT'',''LABEL'', ae.id, com_ui_user_env_pkg.get_user_lang) as name  from com_array_element ae where ae.array_id = -50000017', 'RPT', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
