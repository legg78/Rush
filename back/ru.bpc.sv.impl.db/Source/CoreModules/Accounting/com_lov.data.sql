insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (55, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''INST'', ''AGNT'', ''CARD'', ''MRCH'', ''TRMN'', ''CUST'', ''CNTC'') and lang = com_ui_user_env_pkg.get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (27, 'ACST', NULL, 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1005, NULL, 'select id code, name from acc_ui_macros_type_vw where lang = com_ui_user_env_pkg.get_user_lang', NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (100, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''OPTP'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0402'', ''0422'')', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1022, NULL, 'select id code, name from acc_ui_bunch_type_vw where lang = com_ui_user_env_pkg.get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1006, NULL, 'select id code, description name from acc_ui_selection_vw where lang = com_ui_user_env_pkg.get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (222, NULL, 'select a.dict||a.code code, a.name, b.inst_id institution_id from com_ui_dictionary_vw a, acc_account_type b where a.dict = ''ACTP'' and a.code = substr(b.account_type, 5) and a.lang = get_user_lang', 'ACC', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (313, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict in (''EXMD'') and lang = com_ui_user_env_pkg.get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (314, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''DTPR'' and code in (''0001'', ''0006'')  and lang = com_ui_user_env_pkg.get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (348, 'ENTR', NULL, 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (377, 'TRNT', NULL, 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (383, 'ABCA', NULL, 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (435, 'ABCL', NULL, 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (440, 'MCST', 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''MCST'' and lang = com_ui_user_env_pkg.get_user_lang', 'ACC', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (471, NULL, 'select a.id as account_id, b.balance_type from acc_ui_account_vw a join acc_ui_balance_type_vw b on b.account_type = a.account_type and b.inst_id = a.inst_id where b.update_macros_type is not null', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
update com_lov set lov_query = 'select a.id as account_id, b.balance_type as code, get_article_text(b.balance_type, get_user_lang()) as name from acc_ui_account_vw a join acc_ui_balance_type_vw b on b.account_type = a.account_type and b.inst_id = a.inst_id where b.update_macros_type is not null' where id = 471
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (483, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''BALANCE_RECONCIL'' and a.lang = get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (484, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''TRANSACTION_TYPES'' and a.lang = get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (485, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''SETTLEMENT_TYPES'' and a.lang = get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (487, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''ACCOUNT_TYPES'' and a.lang = get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (606, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''ACCOUNT_NUMBERS'' and a.lang = get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (629, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''FRONT_END_ACCOUNT_TYPES'' and a.lang = get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (668, NULL, 'select v.version_number as code, v.description as name from cmn_ui_standard_version_vw v where v.standard_id = 1050 and lang = get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCODE', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (672, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''CBS_ACCOUNT_TYPES'' and a.lang = get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
update com_lov set lov_query = 'select id code, name from acc_ui_macros_type_vw where lang = com_ui_user_env_pkg.get_user_lang union select id code, name from acc_ui_macros_bunch_type_vw where lang = com_ui_user_env_pkg.get_user_lang' where id = 1005
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (739, NULL, 'select s.id as code, case when s.service_number is not null then s.service_number || '' - '' else null end || s.label as name, s.inst_id as institution_id from prd_ui_service_vw s, prd_ui_service_type_vw t where s.service_type_id = t.id and s.lang = t.lang and t.is_initial = 0 and s.lang = com_ui_user_env_pkg.get_user_lang', 'ACC', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (740, 'RNDM', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL, NULL)
/
