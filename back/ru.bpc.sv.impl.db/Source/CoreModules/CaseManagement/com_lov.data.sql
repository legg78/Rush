insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (520, NULL, 'select c.card_number as code, ct.name, c.customer_id from iss_card_vw c, net_ui_card_type_vw ct where c.card_type_id = ct.id and ct.lang = com_ui_user_env_pkg.get_user_lang()', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (526, 'DRGP', NULL, 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (527, NULL, 'select code, get_text(''rpt_template'', ''label'', code, l.lang) as name from (select tmpl.id as code from rpt_report r join rpt_report_tag tag on tag.report_id = r.id join rpt_template tmpl on tmpl.report_id = r.id where tag.tag_id = 1018) cross join com_language_vw l where l.lang = com_ui_user_env_pkg.get_user_lang()', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (543, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''ISLT'' and code in (''EXCF'', ''CRBI'') and lang = com_ui_user_env_pkg.get_user_lang()', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (544, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''ISLT'' and code in (''SIAF'', ''EWBF'') and lang = com_ui_user_env_pkg.get_user_lang()', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (545, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''EVNT'' and code in (''2001'', ''2002'', ''2003'') and lang = com_ui_user_env_pkg.get_user_lang()', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (546, 'VSLA', NULL, 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (547, 'MSLR', NULL, 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (548, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''MSLR'' and code in (''000C'', ''000F'', ''000O'', ''000X'') and lang = com_ui_user_env_pkg.get_user_lang()', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (549, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''VSLR'' and code not in (''0000'') and lang = com_ui_user_env_pkg.get_user_lang()', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (550, 'MSLG', NULL, 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
delete com_lov where id = 553
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (553, NULL, 'select id as code, label as name from app_ui_flow_vw where id in (1502, 1503, 1505) and lang = get_user_lang', 'CSM', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
delete com_lov where id = 554
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (554, NULL, 'select id as code, label as name from app_ui_flow_vw where id in (1504, 1506) and lang = get_user_lang', 'CSM', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
delete com_lov where id = 555
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (555, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''DSPP'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0005'', ''0006'', ''0007'')', 'DSP', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
update com_lov set appearance = 'LVAPCDNM' where id = 555
/
update com_lov set appearance = 'LVAPCDNM' where id = 553
/
update com_lov set appearance = 'LVAPCDNM' where id = 554
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (541, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''DSCS'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0001'', ''0004'')', 'DSP', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (542, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''DSCS'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0001'', ''0003'', ''0004'')', 'DSP', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (556, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''MSGT'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''CHBK'', ''FRDR'')', 'CSM', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (557, 'MFCI', NULL, 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (558, 'MFCO', NULL, 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (560, NULL, 'select de025 as code, description as name from mcw_reason_code where mti=1442 and de024 = 452', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
update com_lov set lov_query = 'select de025 as code, description as name from mcw_reason_code where mti = 1442 and de024 = 453' where id = 560
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (561, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''MSGT'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''FRDR'')', 'CSM', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (570, 'APRN', NULL, 'APP', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (575, NULL, 'select ur.user_id code, u.second_name||'' ''||u.first_name||'' ''||u.surname as name from acm_role r, acm_user_role ur, acm_ui_user_vw u where u.user_id = ur.user_id and ur.role_id = r.id and r.name in(''CHARGEBACK_TEAM'') and u.LANG = com_ui_user_env_pkg.get_user_lang()', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (613, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict in (''APHC'', ''CLMS'') and lang = com_ui_user_env_pkg.get_user_lang', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query =  'select u.user_id code, u.second_name||'' ''||u.first_name||'' ''||u.surname as name from acm_ui_user_vw u where com_api_array_pkg.is_element_in_array(i_array_id => 10000076, i_elem_value => to_char(u.user_id, ''FM000000000000000000.0000'')) = 1 and u.lang = com_ui_user_env_pkg.get_user_lang()' where id = 575
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (616, NULL, 'select element_number code, get_text (i_table_name => ''com_array_element'', i_column_name => ''label'', i_object_id => id) as name from com_array_element where array_id = 10000077', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (620, NULL, 'select fsn.appl_status as code, get_article_text(i_article => fsn.appl_status, i_lang => com_ui_user_env_pkg.get_user_lang()) as name, fso.flow_id, fso.appl_status as curr_appl_status, fso.reject_code as curr_reject_code from app_flow_transition ft, app_flow_stage fso, app_flow_stage fsn where fso.id = ft.stage_id and fsn.id = ft.transition_stage_id', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (621, NULL, 'select fs.reject_code as code, get_article_text(i_article => fs.reject_code, i_lang => com_ui_user_env_pkg.get_user_lang()) as name, fs.flow_id, fs.appl_status from app_flow_stage fs', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
update com_lov set lov_query = 'select distinct fsn.appl_status as code, get_article_text(i_article => fsn.appl_status, i_lang => com_ui_user_env_pkg.get_user_lang()) as name, fso.flow_id, fso.appl_status as curr_appl_status from app_flow_transition ft, app_flow_stage fso, app_flow_stage fsn where fso.id = ft.stage_id and fsn.id = ft.transition_stage_id' where id = 620
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (624, 'MCPI', NULL, 'MCW', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (658, 'APRJ', NULL, 'CSM', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (659, NULL, 'select id as code, label as name from app_ui_flow_vw where id in (1502, 1503, 1505) and lang = get_user_lang', 'CSM', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (660, NULL, 'select id as code, label as name from app_ui_flow_vw where id in (1504, 1506) and lang = get_user_lang', 'CSM', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (661, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''DSPP'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0005'', ''0006'', ''0007'')', 'CSM', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (662, NULL, 'select element_number code, get_text (i_table_name => ''com_array_element'', i_column_name => ''label'', i_object_id => id) as name from com_array_element where array_id = 10000077', 'CSM', 'LVSMCODE', 'LVAPNAME', 'DTTPNMBR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (663, NULL, 'select code, get_text (''rpt_template'', ''label'', code, l.lang) as name from (select tmpl.id as code from rpt_report r join rpt_report_tag tag on tag.report_id = r.id join rpt_template tmpl on tmpl.report_id = r.id join com_array_element ea on tmpl.id = ea.numeric_value and ea.array_id = 10000093 where tag.tag_id = 1018) cross join com_language_vw l where l.lang = com_ui_user_env_pkg.get_user_lang()', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (664, NULL, 'select code, get_text (''rpt_template'', ''label'', code, l.lang) as name from (select tmpl.id as code from rpt_report r join rpt_report_tag tag on tag.report_id = r.id join rpt_template tmpl on tmpl.report_id = r.id join com_array_element ea on tmpl.id = ea.numeric_value and ea.array_id = 10000094 where tag.tag_id = 1018) cross join com_language_vw l where l.lang = com_ui_user_env_pkg.get_user_lang()', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
update com_lov set appearance = 'LVAPNAME' where id = 575
/
update com_lov set dict = null, lov_query = 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''APRJ'' and lang = com_ui_user_env_pkg.get_user_lang and dict || code in (select element_value from com_array_element where array_id = 10000101)' where id = 658
/
delete com_lov where id = 616
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (743, NULL, 'select o.id code, o.msg_type || '' - '' || get_article_text (o.msg_type, c.lang) as name, c.id case_id, f.ext_message_id from csm_ui_case_vw c, opr_operation o, mcw_fin f  where c.dispute_id = o.dispute_id and o.id = f.id(+) and o.msg_type in (''MSGTREPR'', ''MSGTCHBK'', ''MSGTACBK'', ''MSGTRTRA'') and c.lang       = com_ui_user_env_pkg.get_user_lang', 'CSM', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 1, NULL, NULL)
/
