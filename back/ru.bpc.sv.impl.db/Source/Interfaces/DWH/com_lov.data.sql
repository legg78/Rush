insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (583, NULL, 'select version_number code, c.description name from cmn_ui_standard_version_vw c where standard_id = 1039 and lang = com_ui_user_env_pkg.get_user_lang', 'DWH', 'LVSMCODD', 'LVAPCODE', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (582, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''DICTIONARIES'' and a.lang = get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
