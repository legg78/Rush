insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (14, NULL, 'select a.object_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b where a.entity_type = ''ENTTFEES'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0200'' and a.service_type_id = b.id', 'FCL', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (15, NULL, 'select a.object_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b where a.entity_type = ''ENTTCYCL'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0200'' and a.service_type_id = b.id', 'FCL', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (16, NULL, 'select a.object_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b where a.entity_type = ''ENTTLIMT'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0200'' and a.service_type_id = b.id union all select c.limit_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b, fcl_fee_type c where a.entity_type = ''ENTTFEES'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0200'' and a.service_type_id = b.id and c.limit_type is not null and c.fee_type = a.object_type ', 'FCL', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (88, 'TXIM', NULL, 'FCL', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1021, 'CYTP', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (181, NULL, 'select a.object_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b where a.entity_type = ''ENTTFEES'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0100'' and a.service_type_id = b.id', 'FCL', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (64, NULL, 'select a.object_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b where a.entity_type = ''ENTTCYCL'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0100'' and a.service_type_id = b.id union all select c.cycle_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b, fcl_fee_type c where a.entity_type = ''ENTTFEES'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0100'' and a.service_type_id = b.id and c.cycle_type is not null and c.fee_type = a.object_type union all select c.cycle_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b, fcl_limit_type c where a.entity_type = ''ENTTLIMT'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0100'' and a.service_type_id = b.id and c.cycle_type is not null and c.limit_type = a.object_type', 'FCL', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (204, NULL, 'select l.limit_type as code, com_api_dictionary_pkg.get_article_text(limit_type) name, t.product_type from prd_ui_attribute_vw a, fcl_limit l, prd_service_type t where a.lang = com_ui_user_env_pkg.get_user_lang and a.entity_type = ''ENTTLIMT'' and a.object_type = l.limit_type and t.id = a.service_type_id union all select distinct balance_type code, com_api_dictionary_pkg.get_article_text(balance_type) name, decode(o.entity_type, ''ENTTCARD'', ''PRDT0100'', ''ENTTMRCH'', ''PRDT0200'', ''ENTTTRMN'', ''PRDT0200'') product_type from acc_balance_type bt, acc_account_type at, acc_account a, acc_account_object o where bt.account_type = at.account_type and a.account_type  = at.account_type and a.id = o.account_id and o.entity_type in (''ENTTCARD'',''ENTTMRCH'', ''ENTTTRMN'')', 'FCL', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (243, 'LNGT', NULL, 'FCL', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (278, 'FCCR', NULL, 'FCL', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (342, 'TMAM', NULL, 'FCL', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select dict||code, name from com_ui_dictionary_vw where dict = ''TMAM'' and substr(code, 1, 1) in (''0'', ''1'') and lang = com_ui_user_env_pkg.get_user_lang', dict = NULL where id = 342
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (381, NULL, 'select dict||code, name from com_ui_dictionary_vw where dict = ''TMAM'' and substr(code, 1, 1) in (''0'', ''2'') and lang = com_ui_user_env_pkg.get_user_lang', 'FCL', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (382, NULL, 'select dict||code, name from com_ui_dictionary_vw where dict = ''TMAM'' and substr(code, 1, 1) in (''0'', ''3'') and lang = com_ui_user_env_pkg.get_user_lang', 'FCL', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select dict||code code, name from com_ui_dictionary_vw where dict = ''TMAM'' and substr(code, 1, 1) in (''0'', ''1'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 342
/
update com_lov set lov_query = 'select dict||code code, name from com_ui_dictionary_vw where dict = ''TMAM'' and substr(code, 1, 1) in (''0'', ''2'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 381
/
update com_lov set lov_query = 'select dict||code code, name from com_ui_dictionary_vw where dict = ''TMAM'' and substr(code, 1, 1) in (''0'', ''3'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 382
/
update com_lov set is_parametrized = 1 where id in (204, 64, 181, 16, 15, 14)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (429, 'CYSD', NULL, 'FCL', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (430, 'CYDT', NULL, 'FCL', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select l.limit_type as code, com_api_dictionary_pkg.get_article_text(limit_type) name, t.product_type from prd_ui_attribute_vw a, fcl_limit_type_vw l, prd_service_type t where a.lang = com_ui_user_env_pkg.get_user_lang and a.entity_type = ''ENTTLIMT'' and a.object_type = l.limit_type and t.id = a.service_type_id union all select distinct balance_type code, com_api_dictionary_pkg.get_article_text(balance_type) name, decode(o.entity_type, ''ENTTCARD'', ''PRDT0100'', ''ENTTMRCH'', ''PRDT0200'', ''ENTTTRMN'', ''PRDT0200'') product_type from acc_balance_type bt, acc_account_type at, acc_account a, acc_account_object o where bt.account_type = at.account_type and a.account_type  = at.account_type and a.id = o.account_id and o.entity_type in (''ENTTCARD'',''ENTTMRCH'', ''ENTTTRMN'')' where id = 204
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (436, 'LCHT', NULL, 'FCL', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (437, 'ACCL', NULL, 'FCL', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select l.limit_type as code, com_api_dictionary_pkg.get_article_text(limit_type) name, t.product_type from prd_ui_attribute_vw a, fcl_limit_type_vw l, prd_service_type t where a.lang = com_ui_user_env_pkg.get_user_lang and a.entity_type = ''ENTTLIMT'' and a.object_type = l.limit_type and t.id = a.service_type_id union all select distinct balance_type code, com_api_dictionary_pkg.get_article_text(balance_type) name, decode(e.entity_type, ''ENTTCARD'', ''PRDT0100'', ''ENTTMRCH'', ''PRDT0200'', ''ENTTTRMN'', ''PRDT0200'') product_type from acc_balance_type bt, acc_account_type at, acc_account_type_entity e where bt.account_type = at.account_type and e.account_type  = at.account_type and e.entity_type in (''ENTTCARD'',''ENTTMRCH'', ''ENTTTRMN'')' where id = 204
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (445, 'NDYR', NULL, 'FCL', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select a.object_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b where a.entity_type = ''ENTTCYCL'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0200'' and a.service_type_id = b.id union all select c.cycle_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b, fcl_fee_type c where a.entity_type = ''ENTTFEES'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0200'' and a.service_type_id = b.id and c.cycle_type is not null and c.fee_type = a.object_type union all select c.cycle_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b, fcl_limit_type c where a.entity_type = ''ENTTLIMT'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0200'' and a.service_type_id = b.id and c.cycle_type is not null and c.limit_type = a.object_type' where id = 15
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (580, 'LMTP', NULL, 'FCL', 'LVSMCODD', 'LVAPCDNM', 'DTTPNMBR', 0)
/
update com_lov set lov_query = 'select a.object_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b where a.entity_type = ''ENTTFEES'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type in (''PRDT0100'', ''PRDT0300'') and a.service_type_id = b.id' where id = 181
/
update com_lov set lov_query = 'select a.object_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b where a.entity_type = ''ENTTFEES'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type in (''PRDT0200'', ''PRDT0300'') and a.service_type_id = b.id' where id = 14
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (683, 'LIMU', NULL, 'FCL', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (697, 'FETP', NULL, 'FCL', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
