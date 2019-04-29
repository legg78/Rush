insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (7003, 'CUPV', NULL, 'CUP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set id = 1052 where id = 7003
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (587, 'UFCR', NULL, 'CUP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select code, name from com_ui_dictionary_vw where dict in (''UFCR'') and lang = com_ui_user_env_pkg.get_user_lang', dict = NULL where id = 587
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (598, NULL, 'select p.id as code, p.file_name || '' - '' || to_char(p.file_date, ''dd/mm/yyyy'') as name from prc_session_file p where p.id >= com_api_id_pkg.get_from_id(i_date => com_api_sttl_day_pkg.get_sysdate - 90) and exists(select 1 from cup_audit_trailer c where c.file_id = p.id)', 'CUP', 'LVSMCODD', 'LVAPNAME', 'DTTPNMBR', 0)
/
