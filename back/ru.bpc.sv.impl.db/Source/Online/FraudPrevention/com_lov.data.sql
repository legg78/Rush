insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (151, NULL, 'select dict||code as code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''CARD'',''TRMN'',''ACCT'') and lang = com_ui_user_env_pkg.get_user_lang', 'FRP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (153, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''EVNT'' and code like ''12%'' and lang = com_ui_user_env_pkg.get_user_lang', 'FRP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (159, NULL, 'select dict||code code, name, lang from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''TRMN'',''CARD'',''MRCT'', ''ACCT'')', 'FRP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (160, NULL, 'select id code, label name, inst_id institution_id, entity_type, description from frp_ui_suite_vw where lang = com_ui_user_env_pkg.get_user_lang and entity_type = ''ENTTACCT''', 'FRP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (161, NULL, 'select id code, label name, inst_id institution_id, entity_type, description from frp_ui_suite_vw where lang = com_ui_user_env_pkg.get_user_lang and entity_type = ''ENTTTRMN''', 'FRP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (162, NULL, 'select id code, label name, inst_id institution_id, entity_type, description from frp_ui_suite_vw where lang = com_ui_user_env_pkg.get_user_lang and entity_type = ''ENTTMRCH''', 'FRP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (163, NULL, 'select id code, label name, inst_id institution_id, entity_type, description from frp_ui_suite_vw where lang = com_ui_user_env_pkg.get_user_lang and entity_type = ''ENTTCARD''', 'FRP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
update com_lov set is_parametrized = 1 where id in (160, 161, 162, 163)
/
update com_lov set lov_query = 'select dict||code as code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''CARD'',''TRMN'',''ACCT'',''MRCH'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 151
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (455, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''RSLT'' and code not in (''WORK'', ''NVRF'') and lang = com_ui_user_env_pkg.get_user_lang', 'FRP', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (490, NULL, 'select id as code, label as name  from frp_ui_check_vw where lang = com_ui_user_env_pkg.get_user_lang', 'FRP', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
