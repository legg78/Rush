insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (501, NULL, 'select de025 as code, description as name from jcb_reason_code where mti=1442 and de024 = 451', 'JCB', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (502, NULL, 'select de025 as code, description as name from jcb_reason_code where mti=1442 and de024 = 450', 'JCB', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (503, NULL, 'select de025 as code, description as name from jcb_reason_code where mti=1240 and de024 = 205', 'JCB', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (504, NULL, 'select de025 code, description name from jcb_reason_code where mti = ''1644'' and de024 = ''603''', 'JCB', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (505, NULL, 'select substr(code, -1) code, name from com_ui_dictionary_vw where dict = ''JCRD'' and lang = com_ui_user_env_pkg.get_user_lang', 'JCB', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
