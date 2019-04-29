insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (93, NULL, 'select id code,lpad(''-'',(level - 1) * 4,''-'') || label name, inst_id institution_id, sys_connect_by_path(label,''\'') s, status, contract_type from iss_ui_product_vw connect by prior id = parent_id and lang = prior lang start with parent_id is null and lang = com_ui_user_env_pkg.get_user_lang order by s', 'IAP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (91, NULL, 'select a.account_type code, b.name, a.inst_id institution_id from acc_ui_account_type_vw a, com_ui_dictionary_vw b where b.dict = ''ACTP'' and b.code = substr(a.account_type, 5) and b.lang = com_ui_user_env_pkg.get_user_lang and a.product_type = ''PRDT0100''', 'IAP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (113, NULL, 'select distinct e.entity_type code, s.element_id, e.name from app_structure s, app_element e where s.appl_type = ''APTPISSA'' and e.id = s.element_id and e.name in (''ACCOUNT'',''SERVICES'',''CARD'')', 'IAP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (115, NULL, 'select t.lang, cn.card_number code, t.name||'' ''|| c.card_mask name, x.contract_number from iss_card c, iss_card_number cn, net_ui_card_type_vw t, prd_contract x where x.id = c.contract_id and c.card_type_id = t.id and t.lang = com_ui_user_env_pkg.get_user_lang and cn.card_id = c.id', 'IAP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (116, NULL, 'select account_number code, account_type||'' ''||currency||'' ''||account_number as name, contract_number from acc_account a, prd_contract c where a.contract_id = c.id', 'IAP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (227, NULL, 'select a.id as code, a.label as name, a.corp_contract_number as contract_number from crp_ui_department_vw a where a.lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (317, NULL, 'select c.id code, c.card_mask name from iss_ui_card_vw c', 'IAP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
update com_lov set lov_query = 'select distinct a.account_type code, b.name, a.inst_id institution_id, c.product_id from acc_ui_account_type_vw a, com_ui_dictionary_vw b, acc_ui_product_account_type_vw c where b.dict = ''ACTP'' and b.code = substr(a.account_type, 5) and b.lang = com_ui_user_env_pkg.get_user_lang and a.product_type = ''PRDT0100'' and c.account_type = a.account_type', is_parametrized = 1  where id = 91
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (405, NULL, 'select a.code code, a.name || '' '' || a.currency_name name, ap.product_id from com_ui_currency_vw a, acc_product_account_type ap where a.lang = com_ui_user_env_pkg.get_user_lang and a.code = ap.currency', 'COM', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select a.code code, a.name || ''  '' || a.currency_name name, ap.product_id FROM com_ui_currency_vw a, (select distinct product_id, currency from acc_product_account_type where currency is not null) ap where a.lang = com_ui_user_env_pkg.get_user_lang AND a.code = ap.currency' where id = 405
/
update com_lov set is_parametrized = 1 where id = 405
/
update com_lov set is_parametrized = 1, lov_query = 'select c.id as code, c.card_mask as name, c.inst_id, pc.product_id from iss_ui_card_vw c join iss_ui_product_card_type_vw pc on pc.card_type_id = c.card_type_id' where id = 317
/
update com_lov set lov_query = 'select c.id as code, c.card_mask as name, c.inst_id, pc.product_id from iss_ui_card_vw c, prd_contract_vw pc where c.contract_id = pc.id' where id = 317
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (481, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict in (''RCMD'') and code not in (''NOTR'') and lang = com_ui_user_env_pkg.get_user_lang()', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select t.lang, c.card_number code, t.name || '' '' || c.card_mask as name, c.contract_number from iss_ui_card_vw c, net_ui_card_type_vw t where c.card_type_id = t.id and t.lang = com_ui_user_env_pkg.get_user_lang()' where id = 115
/
