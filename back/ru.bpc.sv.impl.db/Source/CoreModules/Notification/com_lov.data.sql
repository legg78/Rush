insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (131, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''CUST'', ''CRDH'') and lang = com_ui_user_env_pkg.get_user_lang', 'NTF', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (132, NULL, 'select id code, name from ntf_ui_scheme_vw where scheme_type = ''NTFS0010'' and lang = com_ui_user_env_pkg.get_user_lang', 'NTF', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (333, NULL, 'select dict || code code, name, e.scheme_id from com_ui_dictionary_vw d, ntf_scheme_event e where dict = ''EVNT'' and e.event_type = d.dict||d.code and lang = com_ui_user_env_pkg.get_user_lang', 'NTF', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (379, 'NTES', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (380, NULL, 'select dict||code code, name name from com_ui_dictionary_all_vw where dict = ''NTES'' and code in (''0010'',''0030'') and lang = com_ui_user_env_pkg.get_user_lang', NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (414, NULL, 'select a.id as code, get_text (''ntf_channel'', ''name'', a.id, com_ui_user_env_pkg.get_user_lang) as name from ntf_channel a', 'NTF', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (441, NULL, 'select id as code, name as name from ntf_ui_channel_vw where lang = com_ui_user_env_pkg.get_user_lang', 'NTF', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (488, NULL, 'select event_type code, com_api_dictionary_pkg.get_article_text(event_type) name, inst_id institution_id from ntf_ui_notification_vw where lang = com_ui_user_env_pkg.get_user_lang', 'NTF', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
update com_lov set lov_query = 'select id code, name, inst_id from ntf_ui_scheme_vw where scheme_type = ''NTFS0010'' and lang = com_ui_user_env_pkg.get_user_lang', is_parametrized = 1 where id = 132
/
update com_lov set lov_query = 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''CUST'', ''CRDH'',''MRCH'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 131
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (569, 'SGMS', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (640, NULL, '	select bin as code, get_text ( i_table_name => ''iss_bin'' , i_column_name => ''description'' , i_object_id => n.id , i_lang => com_ui_user_env_pkg.get_user_lang() ) as name from iss_bin n', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (736, NULL, 'select id code, label name from prd_ui_service_type_vw where lang = com_ui_user_env_pkg.get_user_lang and id in (10002000, 10000540, 10002228, 10001717)', 'NTF', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
