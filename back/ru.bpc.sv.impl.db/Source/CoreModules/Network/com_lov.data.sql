insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (111, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''CMDV'', ''NIFC'') and lang = com_ui_user_env_pkg.get_user_lang', 'NET', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (130, NULL, 'select id code, lpad(''-'', level-1, ''-'') || name name from net_ui_card_type_vw start with parent_type_id is null and lang = com_ui_user_env_pkg.get_user_lang connect by prior id = parent_type_id and prior lang = lang', 'NET', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (183, NULL, 'select a.id as code, a.description as name, a.network_id from net_ui_host_vw a where a.lang = com_ui_user_env_pkg.get_user_lang', 'NET', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (303, 'HSST', NULL, 'NET', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (331, 'CFCH', NULL, 'NET', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (378, NULL, 'select id code, name from net_ui_network_sys_vw where lang = com_ui_user_env_pkg.get_user_lang', NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (423, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''TERMINALS_LIST'' and a.lang = get_user_lang', 'NET', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (424, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''MERCHANTS_LIST'' and a.lang = get_user_lang', 'NET', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
