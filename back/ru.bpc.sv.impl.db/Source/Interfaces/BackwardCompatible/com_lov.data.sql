insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (517, NULL, 'select vw.element_value code , vw.label name from com_array a , com_array_type t , com_ui_array_element_vw vw where a.array_type_id = t.id and t.name = ''FRAUD_MONITORING_VERSION'' and vw.array_id = a.id and vw.lang = get_user_lang', 'ITF', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select version_number as code, description as name from cmn_ui_standard_version_vw x where standard_id = 1041 and lang = get_user_lang' where id = 517
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (630, NULL, 'select version_number code, c.description name from cmn_ui_standard_version_vw c where standard_id = 1044 and lang = com_ui_user_env_pkg.get_user_lang', 'ISS', 'LVSMCODE', 'LVAPCODE', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (686, NULL, 'select id as code, label as name from app_ui_flow_vw vv where vv.appl_type = ''APTPISSA'' and vv.id not in (1002, 1004, 1005, 1006, 1008, 1010, 1011, 1013, 1014, 1015, 1017, 1018) and vv.lang = get_user_lang', 'ITF', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
