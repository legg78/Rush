insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (57, NULL, 'select b.code, b.name, a.hsm_manufacturer, a.key_type from sec_key_length_map_vw a, com_ui_dictionary_vw b where b.dict = ''ENKL'' and substr(a.key_length, 5) = b.code and b.lang = com_ui_user_env_pkg.get_user_lang', 'SEC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (66, NULL, 'select b.dict||b.code code, b.name, a.entity_type from sec_key_type_vw a, com_ui_dictionary_vw b where b.dict = ''ENKT'' and substr(a.key_type, 5) = b.code and key_algorithm = ''ENKA3DES'' and b.lang = com_ui_user_env_pkg.get_user_lang', 'SEC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (86, NULL, 'select id code, label name from rul_ui_name_format_vw where entity_type = ''ENTTKYML'' and lang = com_ui_user_env_pkg.get_user_lang', 'SEC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1023, NULL, 'select b.code, b.name, a.hsm_manufacturer, substr(a.key_length, 5) key_length from sec_key_prefix_map_vw a, com_ui_dictionary_vw b where b.dict = ''ENKP'' and substr(a.key_prefix, 5) = b.code and b.lang = com_ui_user_env_pkg.get_user_lang', 'SEC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (140, NULL, 'select b.dict||b.code code, b.name, a.entity_type from sec_key_type_vw a, com_ui_dictionary_vw b where b.dict = ''ENKT'' and substr(a.key_type, 5) = b.code and key_algorithm = ''ENKARSA'' and b.lang = com_ui_user_env_pkg.get_user_lang', 'SEC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (217, NULL, 'select b.dict||b.code code, b.name from com_ui_dictionary_vw b where b.dict = ''SGNA'' and b.lang = com_ui_user_env_pkg.get_user_lang', 'SEC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (237, 'AUTT', NULL, 'SEC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (238, NULL, 'select b.dict||b.code code, b.name, a.entity_type, s.key_schema_id from sec_key_type_vw a, com_ui_dictionary_vw b, prs_key_schema_entity s where b.dict = ''ENKT'' and substr(a.key_type, 5) = b.code and a.key_algorithm = ''ENKA3DES'' and b.lang = com_ui_user_env_pkg.get_user_lang and s.key_type = a.key_type and s.entity_type = a.entity_type', 'SEC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/  
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (241, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''IBIN'', ''TRMN'', ''HOST'') and lang = com_ui_user_env_pkg.get_user_lang', 'SEC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (281, NULL, 'select id code, name from sec_ui_authority_vw where lang = com_ui_user_env_pkg.get_user_lang', 'SEC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (340, 'PWTP', NULL, 'SEC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set is_parametrized = 1 where id in (66, 1023, 140, 238)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (427, NULL, 'select rid code, name from sec_ui_authority_vw where lang = com_ui_user_env_pkg.get_user_lang', 'SEC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (581, 'ATHS', NULL, 'SEC', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
