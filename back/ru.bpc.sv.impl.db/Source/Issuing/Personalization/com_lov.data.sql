insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (78, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''IBIN'') and lang = com_ui_user_env_pkg.get_user_lang', 'PRS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (79, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''TRK1'', ''TRK2'', ''EMBS'', ''CHIP'', ''PNML'') and lang = com_ui_user_env_pkg.get_user_lang', 'PRS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (83, NULL, 'select id code, label name from prs_ui_sort_vw where lang = com_ui_user_env_pkg.get_user_lang', 'PRS', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (84, NULL, 'select id code, description name from prs_ui_batch_vw where status = ''BTST0001'' and lang = com_ui_user_env_pkg.get_user_lang', 'PRS', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (200, NULL, 'select id code, description name, card_type_id, inst_id from prs_ui_blank_type_vw where lang = com_ui_user_env_pkg.get_user_lang', 'PRS', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (208, 'PKOF', NULL, 'PRS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (209, 'PKCF', NULL, 'PRS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (216, NULL, 'select id code, name from prs_ui_sort_param_vw where lang = com_ui_user_env_pkg.get_user_lang', 'PRS', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (323, 'EXDF', NULL, 'PRS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select id code, description name, card_type_id, inst_id institution_id from prs_ui_blank_type_vw where lang = com_ui_user_env_pkg.get_user_lang' where id = 200
/
update com_lov set is_parametrized = 1 where id = 200
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (397, null, 'select element_value code, label name from com_ui_array_element_vw where array_id = 10000002 and lang = get_user_lang', 'PRS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (411, 'PNVM', NULL, 'PRS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select id code, description name from prs_ui_batch_vw where status in (''BTST0001'', ''BTST0003'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 84
/
update com_lov set lov_query = 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''TRK1'', ''TRK2'', ''TRK3'', ''EMBS'', ''CHIP'', ''PNML'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 79
/
update com_lov set lov_query = 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''TRK1'', ''TRK2'', ''TRK3'', ''CTR1'', ''CTR2'', ''EMBS'', ''CHIP'', ''PNML'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 79
/
update com_lov set lov_query = 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''TRK1'', ''TRK2'', ''TRK3'', ''CTR1'', ''CTR2'', ''EMBS'', ''CHIP'', ''PNML'', ''P3CP'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 79
/
update com_lov set lov_query = 'select id code, batch_name name from prs_batch where status in (''BTST0001'', ''BTST0003'')' where id = 84
/
update com_lov set lov_query = 'select d.dict || d.code code, d.name from com_array_element a, com_ui_dictionary_vw d where a.array_id = 10000009 and d.dict||d.code = a.element_value and dict = ''ENTT'' and d.lang = com_ui_user_env_pkg.get_user_lang' where id = 79
/
update com_lov set lov_query = 'select id code, label name, inst_id institution_id from prs_ui_sort_vw where lang = com_ui_user_env_pkg.get_user_lang', is_parametrized = 1 where id = 83
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (468, NULL, 'select x.code, d.name, x.batch_id from (select distinct sm.result_status code, bc.batch_id from prs_batch_card bc, iss_card_instance ci, evt_status_map sm where bc.card_instance_id = ci.id and sm.initial_status = ci.state) x, com_ui_dictionary_vw d where d.dict = substr(x.code, 1, 4) and d.code = substr(x.code, 5, 4) and d.lang = com_ui_user_env_pkg.get_user_lang', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
