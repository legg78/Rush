insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (171, 'RPCD', NULL, 'CRD', 'LVSMCODE', 'LVAPNMCD', NULL, 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (172, NULL, 'select dict||code as code, name as name from com_ui_dictionary_vw where dict in (''EVNT'',''CYTP'') and module_code in (''CRD'', ''DPP'') and lang = com_ui_user_env_pkg.get_user_lang', 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (355, 'ICSD', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (450, 'ACIL', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (467, 'DBTS', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (476, 'CRDP', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (489, 'PRPM', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (461, 'PLTA', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (499, 'ISDT', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (562, NULL, 'select a.object_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b where a.entity_type = ''ENTTFEES'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0100'' and a.service_type_id = b.id and a.attr_name like ''%OVERLIMIT%FEE%''', 'CRD', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (577, 'ACIR', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (578, 'ICED', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (600, 'CRPR', NULL, 'CRD', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (601, NULL, 'select dict || code code, name from com_ui_dictionary_vw where (dict, code) in  ((''ENTT'',''TRMN''),(''PRTY'',''ISS''),(''PRTY'',''ACQ'')) and lang = com_ui_user_env_pkg.get_user_lang', 'CRD', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (609, 'TRTP', NULL, 'CRD', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (611, 'MADA', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (615, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''EVNT'' and code in (''1010'',''1011'',''1012'',''1013'',''1014'',''1015'',''1023'',''1024'',''1025'',''1026'',''1027'',''1028'',''1029'',''1030'',''1031'') and lang = com_ui_user_env_pkg.get_user_lang', 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (614, 'AGAL', NULL, 'CRD', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select dict || code code, name from com_ui_dictionary_vw where dict = ''EVNT'' and code in (''1011'',''1012'',''1013'',''1014'',''1015'',''1023'',''1024'',''1025'',''1026'',''1027'',''1028'',''1029'',''1030'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 615
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (655, 'DRSA', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (720, 'IREF', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (719, 'CRMD', NULL, 'CRD', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/

