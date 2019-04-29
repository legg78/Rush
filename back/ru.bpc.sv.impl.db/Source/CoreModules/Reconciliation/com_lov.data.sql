insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (590, 'RCNT', NULL, 'RCN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (591, 'RCTP', NULL, 'RCN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (592, 'RNST', NULL, 'RCN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (593, 'RMSC', NULL, 'RCN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (594, NULL, 'select d.dict || d.code code, d.name from com_ui_dictionary_vw d where d.dict = ''RMSC'' and d.code in (''0000'',''0002'') and d.lang = com_ui_user_env_pkg.get_user_lang', 'RCN', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (595, NULL, 'select d.dict || d.code code, d.name from com_ui_dictionary_vw d where d.dict = ''RCNT'' and d.code in (''ATMJ'') and d.lang = com_ui_user_env_pkg.get_user_lang', 'RCN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set dict = NULL, is_parametrized = 1, lov_query = 'select d.dict || d.code as code, d.name as name, case when d.code in (''ATMJ'') then ''ATM'' else ''CBS'' end as type from com_ui_dictionary_vw d where d.dict = ''RCNT'' and d.lang = com_ui_user_env_pkg.get_user_lang' where id = 590
/
update com_lov set dict = NULL, is_parametrized = 1, lov_query = 'select d.dict || d.code as code, d.name as name, case when d.code in (''0002'') then ''ATM'' else ''CBS'' end as type from com_ui_dictionary_vw d where d.dict = ''RMSC'' and d.lang = com_ui_user_env_pkg.get_user_lang' where id = 593
/
delete from com_lov where id = 594
/
delete from com_lov where id = 595
/
update com_lov set lov_query = 'select d.dict || d.code as code, d.name as name, case when d.code in (''ATMJ'') then ''ATM'' when d.code in (''HOST'') then ''HOST'' else ''CBS'' end as type from com_ui_dictionary_vw d where d.dict = ''RCNT'' and d.lang = com_ui_user_env_pkg.get_user_lang' where id = 590
/
update com_lov set lov_query = 'select d.dict || d.code as code, d.name as name, case when d.code in (''0002'') then ''ATM'' when d.code in (''0003'') then ''HOST'' else ''CBS'' end as type from com_ui_dictionary_vw d where d.dict = ''RMSC'' and d.lang = com_ui_user_env_pkg.get_user_lang' where id = 593
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (602, NULL, 'select dict||code as code, name from com_ui_dictionary_all_vw where lang = get_user_lang and dict = ''EVNT'' and code in (''2100'', ''2101'', ''2102'', ''2103'', ''2104'')', 'RCN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select d.dict || d.code as code , d.name as name , case when d.code in (''0002'') then ''ATM'' when d.code in (''0003'') then ''HOST'' when d.code in (''0004'') then ''SRVP'' else ''CBS'' end as type from com_ui_dictionary_vw d where d.dict = ''RMSC'' and d.lang = com_ui_user_env_pkg.get_user_lang' where id = 593
/
update com_lov set lov_query = 'select d.dict || d.code as code, d.name as name, case when d.code in (''ATMJ'') then ''ATM'' when d.code in (''HOST'') then ''HOST'' when d.code in (''SRVP'') then ''SRVP'' else ''CBS'' end as type from com_ui_dictionary_vw d where d.dict = ''RCNT'' and d.lang = com_ui_user_env_pkg.get_user_lang' where id = 590
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (669, NULL, 'select pu.id as code, pu.label as name, pu.provider_id from pmo_ui_purpose_vw pu where pu.lang = com_ui_user_env_pkg.get_user_lang', 'RCN', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 1, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (670, NULL, 'select pp.param_id as code, pp.label as name, pp.purpose_id from pmo_ui_purpose_parameter_vw pp where pp.lang = com_ui_user_env_pkg.get_user_lang', 'RCN', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 1, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (671, NULL, 'select id as code, lpad (''-'', (level - 1) * 4, ''-'') || label name, sys_connect_by_path (label, ''\'') struct from pmo_ui_provider_vw connect by prior id = parent_id and lang = prior lang start with parent_id is null and lang = com_ui_user_env_pkg.get_user_lang order by struct', 'RCN', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0, NULL)
/
update com_lov set lov_query = 'select d.dict || d.code as code , d.name as name , case when d.code in (''0002'') then ''ATM'' when d.code in (''0003'', ''0005'') then ''HOST'' when d.code in (''0004'') then ''SRVP'' else ''CBS'' end as type from com_ui_dictionary_vw d where d.dict = ''RMSC'' and d.lang = com_ui_user_env_pkg.get_user_lang' where id = 593
/
update com_lov set lov_query = 'select d.dict || d.code as code, d.name as name, case when d.code in (''ATMJ'') then ''ATM'' when d.code in (''HOST'', ''NTSW'') then ''HOST'' when d.code in (''SRVP'') then ''SRVP'' else ''CBS'' end as type from com_ui_dictionary_vw d where d.dict = ''RCNT'' and d.lang = com_ui_user_env_pkg.get_user_lang' where id = 590
/
