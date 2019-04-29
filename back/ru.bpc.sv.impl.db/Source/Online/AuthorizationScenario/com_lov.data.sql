insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (117, 'ATHP', NULL, 'ASC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (119, 'APPL', NULL, 'ASC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (120, NULL, 'select ''='' code, ''='' name from dual union all select ''!='' code, ''!='' name from dual union all select ''>'' code, ''>'' name from dual union all select ''>='' code, ''>='' name from dual union all select ''<'' code, ''<'' name from dual union all select ''<='' code, ''<='' name from dual union all select ''IN'' code, ''IN'' name from dual union all select ''LIKE'' code, ''LIKE'' name from dual', 'ASC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (121, NULL, 'select a.code, get_text(''asc_state'', ''description'', a.id, b.lang) name, a.scenario_id from asc_state a, com_language_vw b where a.scenario_id != 0 and b.lang = com_ui_user_env_pkg.get_user_lang', 'ASC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (122, NULL, 'select a.tag code, get_text(''aup_tag'', ''description'', a.id, b.lang) name from aup_tag a, com_language_vw b where b.lang = com_ui_user_env_pkg.get_user_lang', 'ASC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (123, NULL, 'select ''yyyymmddhh24miss'' code, ''yyyymmddhh24miss'' name from dual', 'ASC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (152, 'ANTT', NULL, 'ASC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (155, 'SPLP', NULL, 'ASC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (308, 'APAM', null, 'ASC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set is_parametrized = 1 where id in (121)
/