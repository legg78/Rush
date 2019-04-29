insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (244, NULL, 'select id code, name as name from rul_mod_param', 'RUL', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
delete from com_lov where id = 267
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (267, null, 'select function_name  as code, description as name from rul_ui_name_transform_vw  where inst_id in (select inst_id from acm_cu_inst_vw) and lang=get_user_lang', 'RUL', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (279, NULL, 'select id code, label name , inst_id, entity_type, lang from rul_ui_name_format_vw', 'RUL', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 1)
/
update com_lov set lov_query = 'select id code, label name , inst_id, entity_type from rul_ui_name_format_vw where lang = get_user_lang' where id = 279
/
update com_lov set lov_query = 'select id code, label name, inst_id institution_id, entity_type from rul_ui_name_format_vw where lang = get_user_lang' where id = 279
/
update com_lov set lov_query = 'select id code, short_description name from rul_ui_mod_param_vw where lang = get_user_lang' where id = 244
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (731, NULL, 'select dict || code code, name from com_ui_dictionary_vw where lang = com_ui_user_env_pkg.get_user_lang() and dict in (''MADA'', ''DPPA'', ''POAA'')', 'RUL', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL, NULL)
/
