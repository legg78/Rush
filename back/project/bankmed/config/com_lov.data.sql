insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5001, 'RIPS', NULL, 'RPT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5002, NULL, 'select t.*, com_api_dictionary_pkg.get_article_text(i_article => t.code, i_lang => l.lang) as name from (select fs.appl_status as code from app_flow_stage fs where floor(fs.flow_id / 100) = 15 and fs.appl_status in (''APST0014'', ''APST0015'', ''APST0016'', ''APST0017'') group by fs.appl_status) t cross join com_language_vw l where l.lang = com_ui_user_env_pkg.get_user_lang()', 'RPT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5015, 'BMGW', NULL, 'CST', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0)
/
