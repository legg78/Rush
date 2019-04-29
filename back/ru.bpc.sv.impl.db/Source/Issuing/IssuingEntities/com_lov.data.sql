insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (12, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''CRCG'' and lang = com_ui_user_env_pkg.get_user_lang', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (80, 'PNRQ', NULL, 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (81, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''PMRQ'' and lang = com_ui_user_env_pkg.get_user_lang', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (82, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''EMRQ'' and lang = com_ui_user_env_pkg.get_user_lang', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1003, 'CSTS', NULL, 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1004, NULL, 'select a.object_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b where a.entity_type = ''ENTTLIMT'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0100'' and a.service_type_id = b.id', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (126, 'PRSP', NULL, 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (127, 'RCMD', NULL, 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (128, 'SDRL', NULL, 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (129, 'EDRL', NULL, 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (166, NULL, 'select ir.id  as code, ir.name, ir.lang, ir.inst_id, ibir.bin_id from iss_ui_bin_index_range_vw ibir, rul_ui_name_index_range_vw ir, ost_ui_institution_sys_vw i where ibir.index_range_id = ir.id and ir.inst_id = i.id and ir.lang = i.lang and i.lang = com_ui_user_env_pkg.get_user_lang', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (187, NULL, 'select a.id code,lpad(''-'',(level - 1) * 4,''-'') || label name,a.inst_id institution_id,sys_connect_by_path(label,''\'') s,a.status,b.customer_entity_type from iss_ui_product_vw a, prd_contract_type_vw b where a.contract_type = b.contract_type  and a.product_type = b.product_type connect by prior a.id = a.parent_id and a.lang = prior a.lang start  with a.parent_id is null and a.lang = com_ui_user_env_pkg.get_user_lang order  by s', 'IAP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (201, NULL, 'select bin code, description name, card_type_id, inst_id from iss_ui_bin_vw where lang = com_ui_user_env_pkg.get_user_lang', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (206, NULL, 'select distinct account_type code, com_api_dictionary_pkg.get_article_text(account_type) as name from acc_account_type t where product_type = ''PRDT0100''', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (236, 'CSTE', NULL, 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select ir.id as code, ir.name, ir.lang, ir.inst_id institution_id, ibir.bin_id from iss_ui_bin_index_range_vw ibir, rul_ui_name_index_range_vw ir, ost_ui_institution_sys_vw i where ibir.index_range_id = ir.id and ir.inst_id = i.id and ir.lang = i.lang and i.lang = com_ui_user_env_pkg.get_user_lang' where id = 166
/
update com_lov set lov_query = 'select bin code, description name, card_type_id, inst_id institution_id from iss_ui_bin_vw where lang = com_ui_user_env_pkg.get_user_lang' where id = 201
/
update com_lov set is_parametrized = 1 where id in (1004, 166, 187, 201)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (350, NULL, 'select id code, customer_name name from prd_ui_customer_name_vw where lang = com_ui_user_env_pkg.get_user_lang and entity_type = ''ENTTCOMP''', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
update com_lov set data_type = 'DTTPCHAR' where id = 201
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (354, 'CRDC', NULL, 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select distinct account_type code, com_api_dictionary_pkg.get_article_text(account_type) as name, t.inst_id from acc_account_type t where product_type = ''PRDT0100''', is_parametrized = 1 where id = 206
/
update com_lov set lov_query = 'select dict || code code, name from com_ui_dictionary_vw where dict = ''EMRQ'' and code in (''DONT'', ''EMBS'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 82
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (392, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''EMRQ'' and lang = com_ui_user_env_pkg.get_user_lang', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/

update com_lov set lov_query  = 'select distinct account_type code, com_api_dictionary_pkg.get_article_text(account_type) as name from acc_account_type t where product_type = ''PRDT0100'' and t.inst_id in (select inst_id from acm_cu_inst_vw)' where id = 206
/
update com_lov set lov_query = 'select distinct account_type code, com_api_dictionary_pkg.get_article_text(account_type) as name, t.inst_id from acc_account_type t where product_type = ''PRDT0100''', is_parametrized = 1 where id = 206
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (420, NULL, 'select distinct account_type code, com_api_dictionary_pkg.get_article_text(account_type) as name from acc_account_type t where product_type = ''PRDT0100'' and t.inst_id in (select inst_id from acm_cu_inst_vw)', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (434, NULL, 'select b.bin as code, b.description as name, to_number(substr(t.ph, 1, instr(t.ph,''\'') -1)) card_type_id, b.inst_id as institution_id from (select c.id, c.parent_type_id, ltrim(sys_connect_by_path(c.id, ''\''), ''\'') || ''\'' ph from net_card_type c connect by prior c.parent_type_id = c.id) t, iss_ui_bin_vw b where b.card_type_id = t.id and b.lang = com_ui_user_env_pkg.get_user_lang', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
update com_lov set lov_query = 'select b.id as code, b.description as name, to_number(substr(t.ph, 1, instr(t.ph,''\'') -1)) card_type_id, b.inst_id as institution_id from (select c.id, c.parent_type_id, ltrim(sys_connect_by_path(c.id, ''\''), ''\'') || ''\'' ph from net_card_type c connect by prior c.parent_type_id = c.id) t, iss_ui_bin_vw b where b.card_type_id = t.id and b.lang = com_ui_user_env_pkg.get_user_lang' where id = 434
/
update com_lov set lov_query = 'select a.object_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b where a.entity_type = ''ENTTLIMT'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0100'' and a.service_type_id = b.id union all select c.limit_type code, a.label name, b.entity_type from prd_ui_attribute_vw a, prd_ui_service_type_vw b, fcl_fee_type c where a.entity_type = ''ENTTFEES'' and a.lang = com_ui_user_env_pkg.get_user_lang and a.lang = b.lang and b.product_type = ''PRDT0100'' and a.service_type_id = b.id and c.limit_type is not null and c.fee_type = a.object_type' where id = 1004
/
update com_lov set lov_query = 'select b.id as code, b.bin || '' - '' || b.description as name, to_number(substr(t.ph, 1, instr(t.ph,''\'') -1)) card_type_id, b.inst_id as institution_id from (select c.id, c.parent_type_id, ltrim(sys_connect_by_path(c.id, ''\''), ''\'') || ''\'' ph from net_card_type c connect by prior c.parent_type_id = c.id) t, iss_ui_bin_vw b where b.card_type_id = t.id and b.lang = com_ui_user_env_pkg.get_user_lang' where id = 434
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (439, 'MDLF', NULL, 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (446, NULL, 'select element_value as code, label as name from com_ui_array_element_vw where array_id = 10000008 and lang = get_user_lang()', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select id as code, description as name, card_type_id, inst_id as institution_id from iss_ui_bin_vw where lang = com_ui_user_env_pkg.get_user_lang()' where id = 201
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (482, NULL, 'select event_type code, label name from evt_ui_event_type_vw where entity_type in (''ENTTCINS'', ''ENTTCARD'') and lang = com_ui_user_env_pkg.get_user_lang', 'ISS', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (497, NULL, 'select b.id, b.bin || '' - '' || b.description name,  i.product_id from iss_ui_product_card_type_vw i ,iss_ui_bin_vw b where i.bin_id = b.id and b.lang=com_ui_user_env_pkg.get_user_lang', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
update com_lov set lov_query = 'select b.id code, b.bin || '' - '' || b.description name,  i.product_id from iss_ui_product_card_type_vw i ,iss_ui_bin_vw b where i.bin_id = b.id and b.lang=com_ui_user_env_pkg.get_user_lang' where id = 497
/
update com_lov set lov_query = 'select distinct b.id, b.bin || '' - '' || b.description name,  i.product_id from iss_ui_product_card_type_vw i ,iss_ui_bin_vw b where i.bin_id = b.id and b.lang=com_ui_user_env_pkg.get_user_lang' where id = 497
/
update com_lov set lov_query = 'select distinct b.id code, b.bin || '' - '' || b.description name,  i.product_id from iss_ui_product_card_type_vw i ,iss_ui_bin_vw b where i.bin_id = b.id and b.lang=com_ui_user_env_pkg.get_user_lang' where id = 497
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (539, 'CRDS', NULL, 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (649, 'SRVT', NULL, 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (680, NULL, 'select distinct d.dict || d.code code, d.name from com_ui_dictionary_vw d where d.dict = ''ENTT'' and d.code in (''ACCT'', ''CINS'', ''CARD'') and d.lang = com_ui_user_env_pkg.get_user_lang', 'EVT', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (710, NULL, 'select distinct dc.code, dc.name, dc.description reissue_reason_desc, dc.inst_id from  iss_ui_reissue_reason_vw rr, com_ui_dictionary_vw dc where rr.reissue_reason = dc.dict || dc.code and dc.dict = substr(rr.reissue_reason, 1, 4) and dc.code = substr(rr.reissue_reason, 5) and dc.lang = nvl(com_ui_user_env_pkg.get_user_lang,dc.lang)', 'ISS', 'LVSMCODD', 'LVAPNMCD', 'DTTPCHAR', 1, NULL)
/
update com_lov set lov_query = 'select distinct dc.dict||dc.code code, dc.name, dc.description reissue_reason_desc, rr.inst_id from iss_ui_reissue_reason_vw rr, com_ui_dictionary_vw dc where rr.reissue_reason = dc.dict || dc.code and dc.dict = substr(rr.reissue_reason, 1, 4) and dc.code = substr(rr.reissue_reason, 5) and dc.lang = nvl(com_ui_user_env_pkg.get_user_lang,dc.lang)' where id = 710
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (722, 'TSTS', NULL, 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
