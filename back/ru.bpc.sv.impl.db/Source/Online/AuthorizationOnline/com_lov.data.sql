insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1009, 'RESP', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (223, NULL, 'select id code, label name, inst_id instutition_id from aup_ui_scheme_vw where lang = get_user_lang', 'AUP', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (402, 'PINP', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (401, 'CV2P', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (421, 'RCFI', NULL, 'CMN', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (43, 'CV2P', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set dict = 'AAVP' where id = 43
/
update com_lov set module_code = 'AUP' where id = 43
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (464, 'AVLG', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/