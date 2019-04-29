insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (49, 'OPTP', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1008, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''CARD'', ''CINS'', ''ACCT'', ''CUST'', ''TRMN'', ''MRCH'', ''CNTR'') and lang = com_ui_user_env_pkg.get_user_lang', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (106, 'OPST', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (107, 'PSTG', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1024, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''MTST'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0200'', ''0300'')', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (145, 'INVM', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (254, 'MSGT', NULL, 'OPR', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (273, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict in (''OPST'', ''AUST'')  and lang = com_ui_user_env_pkg.get_user_lang', 'OPR', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (260, 'OALG', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (312, NULL, 'select d.dict || d.code code, d.name, r.oper_type from opr_ui_reason_vw r, com_ui_dictionary_vw d where d.dict = r.reason_dict and lang = com_ui_user_env_pkg.get_user_lang', 'OPR', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (349, 'OPSL', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (403, 'RRPC', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (376, 'CLMS', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (438, NULL, 'select id as code, name as name from gui_ui_wizard_vw where lang = com_ui_user_env_pkg.get_user_lang', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
delete com_lov where id = 454
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (454, NULL, 'select event_type as code, com_api_dictionary_pkg.get_article_text(event_type, com_ui_user_env_pkg.get_user_lang) as name from evt_subscriber where procedure_name = ''OPR_PRC_EXPORT_PKG.UPLOAD_OPERATION''', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values ('458', null, 'select a.tag code, get_text(''aup_tag'', ''name'', a.id, b.lang) name from aup_tag a, com_language_vw b where b.lang = com_ui_user_env_pkg.get_user_lang', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', '0')
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (466, 'UOST', NULL, 'OPR', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (469, NULL, 'select distinct m.result_status code, d.name, m.initial_status from evt_status_map m, com_ui_dictionary_vw d where d.dict||d.code = m.result_status and d.lang = com_ui_user_env_pkg.get_user_lang', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (472, 'WORS', NULL, 'OPR', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
update com_lov set dict = null, lov_query = 'select d.dict||d.code code, d.name from com_ui_dictionary_vw d where d.dict = ''MSGT'' and d.code like ''WF%'' and lang = com_ui_user_env_pkg.get_user_lang' where id = 472
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1048, 'OPFT', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1057, 'UTOR', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (508, 'OPCM', NULL, 'OPR', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
delete com_lov where id = 523
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (523, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict in (''AUSR'', ''RESP'') and dict || code != ''AUSR0101'' and lang = com_ui_user_env_pkg.get_user_lang', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (531, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''STTT'' and code not like ''02%'' and lang = com_ui_user_env_pkg.get_user_lang', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (532, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''STTT'' and code not like ''01%'' and lang = com_ui_user_env_pkg.get_user_lang', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (573, 'MTST', NULL, 'OPR', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (610, 'MNFT', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (641, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''PARTICIPANT_TYPES'' and a.lang = get_user_lang', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (643, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''OPERATION_STATUS'' and a.lang = get_user_lang', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (665, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''RESP_CODE'' and a.lang = get_user_lang', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (696, 'RMCH', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (709, 'OPRS', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (721, NULL, 'select code, get_article_text(i_article => dict || code, i_lang => com_ui_user_env_pkg.get_user_lang) as name, ''ENTTOPER'' as entity_type from com_dictionary where dict = ''OPTP'' union all select code, get_article_text(i_article => dict || code, i_lang => com_ui_user_env_pkg.get_user_lang) as name, ''ENTTACCT'' as entity_type from com_dictionary where dict = ''ACTP'' union all select code, get_article_text(i_article => dict || code, i_lang => com_ui_user_env_pkg.get_user_lang) as name, ''ENTTCARD'' as entity_type from com_dictionary where dict = ''CRCG''', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1, NULL)
/
update com_lov set lov_query = 'select dict || code as code, get_article_text(i_article => dict || code, i_lang => com_ui_user_env_pkg.get_user_lang) as name, ''ENTTOPER'' as entity_type from com_dictionary where dict = ''OPTP'' union all select dict || code as code, get_article_text(i_article => dict || code, i_lang => com_ui_user_env_pkg.get_user_lang) as name, ''ENTTACCT'' as entity_type from com_dictionary where dict = ''ACTP'' union all select dict || code as code, get_article_text(i_article => dict || code, i_lang => com_ui_user_env_pkg.get_user_lang) as name, ''ENTTCARD'' as entity_type from com_dictionary where dict = ''CRCG''' where id = 721
/
update com_lov set lov_query = 'select a.reference code, get_text(''aup_tag'', ''name'', a.id, com_ui_user_env_pkg.get_user_lang) name from aup_tag a ' where id = 458
/
