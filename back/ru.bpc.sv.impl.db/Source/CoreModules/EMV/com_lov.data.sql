insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (165, NULL, 'select tag code, description name from emv_ui_tag_vw where lang = com_ui_user_env_pkg.get_user_lang', 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (190, NULL, 'select id code, name from emv_ui_application_vw where lang = com_ui_user_env_pkg.get_user_lang', 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (207, NULL, 'select id code, name, application_id, variable_type from emv_ui_variable_vw where lang = com_ui_user_env_pkg.get_user_lang', 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (218, 'EPFL', NULL, 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (219, 'EVTP', NULL, 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (220, 'EMVT', NULL, 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (221, 'EMVP', NULL, 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (309, 'EMVS', NULL, 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select id code, name from emv_ui_application_vw where lang = com_ui_user_env_pkg.get_user_lang' where id = 190
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (327, 'SRTP', NULL, 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (328, 'SRST', NULL, 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type) values (329, NULL, 'select id code, name from emv_ui_appl_scheme_vw where lang = com_ui_user_env_pkg.get_user_lang', 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR')
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type) values (335, NULL, 'select id code, script_type_name name from emv_ui_script_type_vw where is_used_by_user = get_true and lang = get_user_lang', 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR')
/
update com_lov set lov_query = 'select type code, script_type_name name from emv_ui_script_type_vw where is_used_by_user = get_true and lang = get_user_lang' where id = 335
/
update com_lov set is_parametrized = 1 where id = 207
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (407, 'SRCN', NULL, 'EMV', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set is_parametrized = 1, lov_query = 'select id code, name, inst_id from emv_ui_appl_scheme_vw where lang = com_ui_user_env_pkg.get_user_lang' where id = 329
/
update com_lov set is_parametrized = 1, lov_query = 'select id code, name, inst_id institution_id from emv_ui_appl_scheme_vw where lang = com_ui_user_env_pkg.get_user_lang' where id = 329
/