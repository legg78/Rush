insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (474, NULL, 'select e.element_value code, e.label name  from com_array a, com_ui_array_element_vw e where a.id = 10000010 and e.array_id = a.id and e.lang = get_user_lang', 'DSP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (500, 'DSPR', NULL, 'DSP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (516, 'DSPP', NULL, 'DSP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (518, NULL, 'select text as code from com_i18n where table_name = ''APP_HISTORY'' and column_name = ''COMMENTS'' and lang = ''LANGENG'' group by text order by text', 'DSP', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
delete from com_lov where id = 518
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (518, 'APHC', NULL, 'DSP', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (533, 'DSDT', NULL, 'DSP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (535, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''APST'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0014'', ''0015'', ''0016'', ''0017'')', 'DSP', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (537, 'DSCS', NULL, 'DSP', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (574, 'RFRA', NULL, 'DSP', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (576, NULL, 'select id as code, com_api_i18n_pkg.get_text(''rul_mod'', ''name'', id) as name from rul_mod where scale_id = 1023', 'DSP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (618, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''DSPP'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0001'', ''0002'', ''0003'', ''0004'')', 'DSP', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (619, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''DSPP'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0008'', ''0009'', ''0012'', ''0013'', ''0014'', ''0015'', ''0004'')', 'DSP', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (674, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''RPTF'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''RTF'')', 'DSP', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select dict||code code, name from com_ui_dictionary_vw where dict = ''APST'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0014'', ''0015'', ''0016'', ''0017'', ''0021'')' where id = 535
/
