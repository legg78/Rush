insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (85, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''HSMA'' and lang = com_ui_user_env_pkg.get_user_lang', 'HSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (173, NULL, 'select distinct b.dict || b.code code, b.name, a.hsm_manufacturer from hsm_model_number_map a, com_ui_dictionary_vw b where b.dict = ''HSMV'' and substr(a.model_number, 5) = b.code and b.lang = com_ui_user_env_pkg.get_user_lang', 'HSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (179, NULL, 'select b.dict || b.code code, b.name, a.hsm_manufacturer, a.model_number from hsm_model_number_map a, com_ui_dictionary_vw b where b.dict = ''HSMF'' and substr(a.firmware, 5) = b.code and b.lang = com_ui_user_env_pkg.get_user_lang', 'HSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (384, NULL, 'select id code, description name from hsm_ui_lmk_vw where lang = com_ui_user_env_pkg.get_user_lang', 'HSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
update com_lov set is_parametrized = 1 where id in (179, 173)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (473, NULL, 'select d.id as code, d.description as name, s.action from hsm_ui_device_vw d join hsm_selection s on s.hsm_device_id = d.id', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select h.id as code, h.description as name from hsm_ui_device_vw h join hsm_ui_lmk_vw lmk on lmk.id = h.lmk_id and lmk.lang = h.lang where h.lang = com_ui_user_env_pkg.get_user_lang' where id = 473
/

insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (475, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code = ''HSMD'' and lang = com_ui_user_env_pkg.get_user_lang', 'HSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
