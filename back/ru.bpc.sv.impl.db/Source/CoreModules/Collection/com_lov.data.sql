insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (698, 'CLST', NULL, 'CLN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (699, 'CNRN', NULL, 'CLN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (700, 'CNAC', NULL, 'CLN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (701, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''CNAC'' and code not in (''EVNT'') and lang = com_ui_user_env_pkg.get_user_lang', 'CLN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (702, 'CRAT', NULL, 'CLN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (703, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''CRAT'' and code not in (''LEGL'', ''CMNT'') and lang = com_ui_user_env_pkg.get_user_lang', 'CLN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (704, 'CNRS', NULL, 'CLN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (705, 'ODCT', NULL, 'CLN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (706, NULL, 'select id as code, description from acm_group_vw where lang = com_ui_user_env_pkg.get_user_lang', 'ACM', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (707, NULL, 'select t.status as code, get_article_text(t.status) as name, s.status source_status, s.resolution source_resolution from cln_stage_transition st, cln_stage s, cln_stage t where st.stage_id = s.id and st.transition_stage_id = t.id', 'CLN', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 1, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (708, NULL, 'select t.resolution as code, get_article_text(t.resolution) as name, s.status source_status, s.resolution source_resolution, t.status destination_status from cln_stage_transition st, cln_stage s, cln_stage t where st.stage_id = s.id and st.transition_stage_id = t.id', 'CLN', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 1, NULL)
/
update com_lov set is_parametrized = 1, lov_query = 'select id as code, description as name, inst_id as institution_id from acm_ui_group_vw where lang = com_ui_user_env_pkg.get_user_lang' where id = 706
/
update com_lov set lov_query = 'select t.resolution as code, get_article_text(t.resolution) as name, s.status source_status, s.resolution source_resolution, t.status destination_status, st.reason_code from cln_stage_transition st, cln_stage s, cln_stage t where st.stage_id = s.id and st.transition_stage_id = t.id' where id = 708
/
