insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5026, NULL, 'select dict || code as code, get_article_text(i_article => dict || code, i_lang => com_ui_user_env_pkg.get_user_lang) as name from com_dictionary where dict = ''FLTP'' and code in (''6010'', ''6011'', ''6012'')', 'OPR', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5028, NULL, 'select element_value as code, get_text (i_table_name => ''com_array_element'', i_column_name => ''label'', i_object_id => id) as name from com_array_element where array_id = -50000070', 'OPR', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5027, NULL, 'select s.id as code, to_char(s.start_date, ''yyyy-mm-dd hh24:mi:ss'') || '' - '' || nvl2(s.end_date, to_char(s.end_date - 1/24/3600, ''yyyy-mm-dd hh24:mi:ss''), ''...'') as name from cst_ap_session s', 'OPR', 'LVSMCODD', 'LVAPCDNM', 'DTTPNMBR', 0)
/
update com_lov set sort_mode = 'LVSMCODE' where id = -5028
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5029, 'ENVO', NULL, 'CST', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
