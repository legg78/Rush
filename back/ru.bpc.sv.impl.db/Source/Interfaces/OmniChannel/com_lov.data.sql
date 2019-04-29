insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (653, NULL, 'select v.version_number as code, v.description as name from cmn_ui_standard_version_vw v where v.standard_id = 1049 and lang = get_user_lang', 'OMN', 'LVSMCODE', 'LVAPCODE', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (652, NULL, 'SELECT a.id code, a.label name FROM com_ui_array_vw a, com_array_type t WHERE     a.array_type_id = t.id AND t.name = ''SERVICES''AND a.lang = get_user_lang', 'ITF', 'LVSMCODD', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (654, NULL, 'select id code, com_api_i18n_pkg.get_text(''prd_service_type'', ''label'', id, get_user_lang) name from prd_service where service_type_id in  (select id from prd_service_type where entity_type = ''ENTTCARD'' and is_initial = 0)', 'ITF', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
update com_lov set lov_query = 'select id code, com_api_i18n_pkg.get_text(''prd_service'', ''label'', id, get_user_lang) name from prd_service where service_type_id in  (select id from prd_service_type where entity_type = ''ENTTCARD'' and is_initial = 0)' where id = 654
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (684, NULL, 'select v.version_number as code, v.description as name from cmn_ui_standard_version_vw v where v.standard_id = 1048 and lang = get_user_lang', 'OMN', 'LVSMCODE', 'LVAPCODE', 'DTTPCHAR', 0, NULL)
/
