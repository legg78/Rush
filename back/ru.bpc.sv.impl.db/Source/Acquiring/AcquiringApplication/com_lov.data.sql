insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (147, 'DSTP', NULL, 'AAP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (178, NULL, 'select id code, label name, atm_type, luno from atm_ui_scenario_vw where lang = com_ui_user_env_pkg.get_user_lang', 'AAP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set is_parametrized = 1 where id in (178)
/
