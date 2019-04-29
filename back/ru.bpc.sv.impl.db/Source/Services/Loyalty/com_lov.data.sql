insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (571, 'LTKS', NULL, 'LTY', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (584, NULL, 'select d.dict || d.code as code, d.name from com_array_element a join com_ui_dictionary_vw d on d.dict || d.code = a.element_value where a.array_id = 10000057 and d.dict = ''ENTT'' and d.lang = com_ui_user_env_pkg.get_user_lang()', 'LTY', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (589, 'RLTS', NULL, 'LTY', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (627, 'GIFT', NULL, 'LTY', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (667, NULL, 'select distinct a.id code, a.label name from prd_ui_attribute_vw a, prd_ui_service_type_vw b, prd_ui_service_vw s where b.entity_type = ''ENTTCARD'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and a.service_type_id = b.id and b.lang = s.lang and s.service_type_id = b.id', 'LTY', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (690, 'PRMA', NULL, 'LTY', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0, NULL)
/
