insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (723, 'SYST', NULL, 'SVY', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (724, 'QRST', NULL, 'SVY', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (725, NULL, 'select p.param_name as code, p.name as name, e.entity_type, p.lang from svy_ui_parameter_vw p, svy_ui_param_entity_vw e where p.id = e.param_id and p.lang = e.lang and p.lang = com_ui_user_env_pkg.get_user_lang', 'SVY', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
