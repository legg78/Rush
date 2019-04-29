insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (-5024, '5004', NULL, 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (-5030, NULL, 'select name as code, short_description as name from rul_ui_mod_param_vw where lang = get_user_lang', 'RUL', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0, NULL, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (-5033, NULL, 'select id as code, get_text(''rul_rule_set'', ''name'', id, com_ui_user_env_pkg.get_user_lang) as name from rul_rule_set_vw', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL, NULL)
/
