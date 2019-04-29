insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (174, 'POHA', NULL, 'PMO', 'LVSMCODE', 'LVAPNMCD', NULL, 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (175, 'POOS', NULL, 'PMO', NULL, NULL, NULL, 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (231, 'PAMT', NULL, 'PMO', NULL, NULL, NULL, 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (232, NULL, 'select id code, label name from pmo_ui_purpose_vw where lang = get_user_lang ', 'PMO', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (307, 'POSA', NULL, 'PMO', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (316, NULL, 'select id code, description name from net_ui_member_vw where id in (select host_member_id from pmo_provider_host) and lang = get_user_lang', 'PMO', 'LVSMCODE', 'LVAPNMCD', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (345, NULL, 'select p.id, get_text(i_table_name => ''PMO_PROVIDER'', i_column_name => ''LABEL'', i_object_id => p.id, i_lang => get_user_lang ) name from pmo_provider p', 'PMO', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (346, 'PHST', NULL, 'PMO', 'LVSMCODE', 'LVAPCDNM', NULL, 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (398, NULL, 'select id code, label name from pmo_ui_service_vw where lang = com_ui_user_env_pkg.get_user_lang', 'PMO', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select p.id code, get_text(i_table_name => ''PMO_PROVIDER'', i_column_name => ''LABEL'', i_object_id => p.id, i_lang => get_user_lang) name from pmo_provider p' where id = 345
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (456, NULL, 'select p.id as code, get_text(i_table_name => ''pmo_provider_group'', i_column_name => ''label'', i_object_id => p.id, i_lang => get_user_lang()) as name from pmo_provider_group_vw p', 'PMO', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (563, 'POTS', NULL, 'PMO', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (564, 'POAA', NULL, 'PMO', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (623, NULL, 'select p.provider_number code, get_text(i_table_name => ''PMO_PROVIDER'', i_column_name => ''LABEL'', i_object_id => p.id, i_lang => get_user_lang) name from pmo_provider p', 'PMO', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (645, 'PSCM', NULL, 'PMO', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
update com_lov set lov_query = 'select id code, nvl(purpose_number, id) || '' - '' || label name from pmo_ui_purpose_vw where lang = get_user_lang' where id = 232
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (727, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''CUST'', ''CARD'', ''ACCT'', ''MRCH'')', 'PMO', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0, NULL)
/
update com_lov set lov_query = 'select dict||code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''CUST'', ''CARD'', ''ACCT'', ''MRCH'', ''TRMN'')' where id = 727
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (737, NULL, 'select p.id as code, p.label as name from pmo_ui_parameter_vw p where p.lang = com_ui_user_env_pkg.get_user_lang', 'PMO', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0, NULL, NULL)
/
