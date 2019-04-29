insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (287, 'ATPR', NULL, 'ATM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (288, 'ATMA', NULL, 'ATM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (289, 'ATMP', NULL, 'ATM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (290, 'ATMT', NULL, 'ATM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (6, NULL, 'select a.code, a.name||b.name name, a.institution_id, s from ( select level lvl, merchant_type code, lpad(''-'', (level-1)*4, ''-'') name, inst_id institution_id  , sys_connect_by_path(merchant_type,''\'') s from acq_merchant_type_tree connect by prior merchant_type = parent_merchant_type  and prior inst_id = inst_id start with parent_merchant_type is null) a, com_ui_dictionary_vw b where b.dict = ''MRCT'' and substr(a.code, 5) = b.code and b.lang = com_ui_user_env_pkg.get_user_lang order by s', 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (11, 'MRCS', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (13, 'MRCL', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (26, NULL, 'select a.account_type code, b.name, a.inst_id institution_id from acc_ui_account_type_vw a, com_ui_dictionary_vw b where b.dict = ''ACTP'' and b.code = substr(a.account_type, 5) and b.lang = com_ui_user_env_pkg.get_user_lang and a.product_type = ''PRDT0200''', 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (29, 'F221', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (30, 'F222', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (31, 'F223', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (32, 'F224', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (33, 'F225', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (34, 'F226', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (35, 'F227', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (36, 'F228', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (37, 'F229', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (38, 'F22A', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (39, 'F22B', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (40, 'F22C', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (41, 'TRMS', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (42, 'ENKT', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (46, NULL, 'select id code, lpad(''-'', (level-1)*4, ''-'')||label name, inst_id institution_id, sys_connect_by_path(label,''\'') s, status, contract_type from acq_ui_product_vw connect by prior id = parent_id and lang = prior lang start with parent_id is null and lang = com_ui_user_env_pkg.get_user_lang order by s', 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (59, 'KCHA', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (60, 'ATMT', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (68, NULL, 'select d.id code, d.caption name, d.inst_id institution_id, d.standard_id from cmn_ui_device_vw d, cmn_standard_vw s where s.id = d.standard_id and s.standard_type = ''STDT0002'' and d.lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (138, NULL, 'select m.merchant_number code, get_text(''acq_merchant'',''label'', m.id) name,  c.contract_number from acq_merchant m, prd_contract c where c.id = m.contract_id', 'AAP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (139, NULL, 'select t.terminal_number code, t.description name,  c.contract_number from acq_ui_terminal_vw t, prd_contract c where c.id = t.contract_id  and t.lang = com_ui_user_env_pkg.get_user_lang and is_template = 0', 'AAP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (197, NULL, 'select id code, name from acq_ui_reimb_channel_vw where lang = get_user_lang', 'ACQ', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (205, NULL, 'select distinct account_type code, com_api_dictionary_pkg.get_article_text(account_type) as name from acc_account_type t where product_type = ''PRDT0200''', 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (210, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''CMDV'', ''TRMN'') and lang = com_ui_user_env_pkg.get_user_lang', 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (233, NULL, 'select id code, label name from cmn_ui_standard_vw where standard_type = ''STDT0002'' and lang = com_ui_user_env_pkg.get_user_lang', 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (234, NULL, 'select id code, version_number name, standard_id from cmn_ui_standard_version_vw where lang = com_ui_user_env_pkg.get_user_lang', 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (275, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''FETP'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0201'', ''0203'')', 'ACQ', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (276, NULL, 'select a.id code, a.account_number||'' - ''||c.name name, a.customer_id from acc_account a, com_currency c where a.currency = c.code', 'ACQ', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (277, NULL, 'select c.value_id code, fcl_ui_fee_pkg.get_fee_desc(value_id) name, decode(d.attr_name, ''ACQ_INTERCHANGE_SPLIT'', ''FETP0203'', ''ACQ_SURCHARGE_SPLIT'', ''FETP0201'') fee_type, customer_id from prd_customer a, prd_contract b, prd_product_attribute_mvw c, prd_attribute d where a.id = b.customer_id and b.contract_type = ''CNTPTRCO'' and (com_api_sttl_day_pkg.get_sysdate >= b.start_date or b.start_date is null)  and (com_api_sttl_day_pkg.get_sysdate <= b.end_date or b.end_date is null) and b.product_id = c.product_id and c.attr_id = d.id and d.attr_name in (''ACQ_INTERCHANGE_SPLIT'', ''ACQ_SURCHARGE_SPLIT'')', 'ACQ', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (302, 'PSBM', NULL, 'ACQ', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (320, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''TERMINAL_AVAILABLE_CURRENCIES'' and a.lang = get_user_lang', 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (321, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''TERMINAL_AVAILABLE_NETWORKS'' and a.lang = get_user_lang', 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (322, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''TERMINAL_AVAILABLE_OPER_TYPES'' and a.lang = get_user_lang', 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (334, NULL, 'select id code, name from acq_ui_mcc_selection_tpl_vw where lang = get_user_lang', 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
update com_lov set data_type='DTTPCHAR' where id = 138
/
update com_lov set lov_query = 'select distinct account_type code, com_api_dictionary_pkg.get_article_text(account_type) as name, t.inst_id from acc_account_type t where product_type = ''PRDT0200''', is_parametrized = 1 where id = 205
/
update com_lov set is_parametrized = 1 where id in (26, 46, 68, 234, 139, 138)
/

update com_lov set lov_query = 'select distinct account_type code, com_api_dictionary_pkg.get_article_text(account_type) as name from acc_account_type t where product_type = ''PRDT0200'' and t.inst_id in (select inst_id from acm_cu_inst_vw)' where id = 205
/
update com_lov set lov_query = 'select distinct account_type code, com_api_dictionary_pkg.get_article_text(account_type) as name, t.inst_id from acc_account_type t where product_type = ''PRDT0200''', is_parametrized = 1 where id = 205
/

insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (419, NULL, 'select distinct account_type code, com_api_dictionary_pkg.get_article_text(account_type) as name from acc_account_type t where product_type = ''PRDT0200'' and t.inst_id in (select inst_id from acm_cu_inst_vw)', 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select a.code, a.name||b.name name, a.institution_id, s from ( select level lvl, merchant_type code, lpad(''-'', (level-1)*4, ''-'') name, inst_id institution_id  , sys_connect_by_path(merchant_type,''\'') s from acq_merchant_type_tree connect by prior merchant_type = parent_merchant_type  and prior inst_id = inst_id start with parent_merchant_type is null) a, com_ui_dictionary_vw b where b.dict = ''MRCT'' and a.code != ''MRCTTRMN'' and substr(a.code, 5) = b.code and b.lang = com_ui_user_env_pkg.get_user_lang order by s', is_parametrized = 1 where id = 6
/
update com_lov set lov_query = 'select distinct a.account_type code, b.name, a.inst_id institution_id, c.product_id from acc_ui_account_type_vw a, com_ui_dictionary_vw b, acc_ui_product_account_type_vw c where b.dict = ''ACTP'' and b.code = substr(a.account_type, 5) and b.lang = com_ui_user_env_pkg.get_user_lang and a.product_type = ''PRDT0200'' and c.account_type = a.account_type' where id = 26
/
update com_lov set lov_query = 'select c.id as code, fcl_ui_fee_pkg.get_fee_desc(c.id) as name, decode(d.attr_name, ''ACQ_INTERCHANGE_SPLIT'', ''FETP0203'', ''ACQ_SURCHARGE_SPLIT'', ''FETP0201'') as fee_type, b.customer_id from prd_customer a, prd_contract b, prd_attribute_value c, prd_attribute d where a.id = b.customer_id and b.contract_type = ''CNTPTRCO'' and (com_api_sttl_day_pkg.get_sysdate >= b.start_date or b.start_date is null) and (com_api_sttl_day_pkg.get_sysdate <= b.end_date or b.end_date is null) and c.object_id = b.product_id and c.attr_id = d.id and c.entity_type = ''ENTTPROD'' and d.attr_name in (''ACQ_INTERCHANGE_SPLIT'', ''ACQ_SURCHARGE_SPLIT'')' where id = 277
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (496, 'PNBF', NULL, 'PRS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1045, 'MRCT', NULL, 'ACQ', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select a.code, a.name || b.name as name, a.institution_id, s from (select level lvl, merchant_type code, lpad ('' - '', (level - 1) * 4, '' - '') name, inst_id institution_id, sys_connect_by_path(merchant_type, ''\'') s from acq_merchant_type_tree connect by nocycle prior merchant_type = parent_merchant_type and prior inst_id = inst_id start with parent_merchant_type is null) a, com_ui_dictionary_vw b where b.dict = ''MRCT'' and a.code != ''MRCTTRMN'' and substr(a.code, 5) = b.code and b.lang = com_ui_user_env_pkg.get_user_lang order by s' where id = 6
/
update com_lov set lov_query = 'select f.id as code, fcl_ui_fee_pkg.get_fee_desc(c.id) as name, decode(d.attr_name, ''ACQ_INTERCHANGE_SPLIT'', ''FETP0203'', ''ACQ_SURCHARGE_SPLIT'', ''FETP0201'') as fee_type, b.customer_id from prd_customer a, prd_contract b, prd_attribute_value c, prd_attribute d, fcl_fee_vw f where a.id = b.customer_id and b.contract_type = ''CNTPTRCO'' and (com_api_sttl_day_pkg.get_sysdate >= b.start_date or b.start_date is null) and (com_api_sttl_day_pkg.get_sysdate <= b.end_date or b.end_date is null) and c.object_id = b.product_id and c.attr_id = d.id and c.entity_type = ''ENTTPROD'' and d.attr_name in (''ACQ_INTERCHANGE_SPLIT'', ''ACQ_SURCHARGE_SPLIT'') and f.fee_type = d.object_type' where id = 277
/
update com_lov set lov_query = 'select f.id as code, ''id='' || f.id || ''-'' || fcl_ui_fee_pkg.get_fee_desc(f.id) as name, f.fee_type, b.customer_id from prd_customer a, prd_contract b, prd_attribute_value c, prd_attribute d, fcl_fee_vw f where a.id = b.customer_id and b.contract_type = ''CNTPTRCO'' and (com_api_sttl_day_pkg.get_sysdate >= b.start_date or b.start_date is null) and (com_api_sttl_day_pkg.get_sysdate <= b.end_date or b.end_date is null) and c.object_id = b.product_id and c.attr_id = d.id and c.entity_type = ''ENTTPROD'' and d.attr_name in (''ACQ_INTERCHANGE_SPLIT'', ''ACQ_SURCHARGE_SPLIT'') and to_number(c.attr_value, ''FM000000000000000000.0000'') = f.id' where id = 277
/
update com_lov set lov_query = 'select dict||code code, name from com_ui_dictionary_vw where dict = ''FETP'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0210'', ''0211'')' where id = 275
/
update com_lov set lov_query = 'select f.id as code, f.id || '' - '' || fcl_ui_fee_pkg.get_fee_desc(f.id) as name, f.fee_type, b.customer_id from prd_customer a, prd_contract b, prd_attribute_value c, prd_attribute d, fcl_fee_vw f where a.id = b.customer_id and b.contract_type = ''CNTPTRCO'' and (com_api_sttl_day_pkg.get_sysdate >= b.start_date or b.start_date is null) and (com_api_sttl_day_pkg.get_sysdate <= b.end_date or b.end_date is null) and c.object_id = b.product_id and c.attr_id = d.id and c.entity_type = ''ENTTPROD'' and d.attr_name in (''ACQ_INTERCHANGE_SPLIT'', ''ACQ_SURCHARGE_SPLIT'') and to_number(c.attr_value, ''FM000000000000000000.0000'') = f.id' where id = 277
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (656, NULL, 'select id code,lpad(''-'',(level - 1) * 4,''-'') || label name, inst_id institution_id, sys_connect_by_path(label,''\'') s, status, contract_type from iss_ui_product_vw connect by prior id = parent_id and lang = prior lang start with parent_id is null and lang = com_ui_user_env_pkg.get_user_lang order by s', 'ISS', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (657, NULL, 'select iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number, c.card_mask, pc.product_id from iss_card c, iss_card_number cn, prd_contract pc, prd_product_service ps, prd_service s where c.contract_id = pc.id and c.id = cn.card_id and pc.product_id = ps.product_id and ps.service_id = s.id and s.service_type_id = 10004094 and not exists (select 1 from acc_account_object ao where ao.object_id = c.id and ao.entity_type = ''ENTTCARD'')', 'ISS', 'LVSMCODE', 'LVAPCODE', 'DTTPCHAR', 1)
/
update com_lov set lov_query = 'select iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as code, c.card_mask name, pc.product_id, c.card_type_id card_type from iss_card c, iss_card_number cn, prd_contract pc, prd_product_service ps, prd_service s where c.contract_id = pc.id and c.id = cn.card_id and pc.product_id = ps.product_id and ps.service_id = s.id and s.service_type_id = 10004110 and not exists (select 1 from acc_account_object ao where ao.object_id = c.id and ao.entity_type = ''ENTTCARD'')' where id = 657
/
update com_lov set appearance = 'LVAPNAME' where id = 657
/
update com_lov set lov_query = 'select id code, lpad(''-'', (level - 1) * 4, ''-'') || label name, inst_id institution_id, (select ''\'' || listagg(com_api_i18n_pkg.get_text(i_table_name => ''PRD_PRODUCT'', i_column_name => ''LABEL'', i_object_id => pr.id ), ''\'') within group(order by level desc) from prd_product pr connect by pr.id = prior pr.parent_id start with pr.id = v.id) s, status, contract_type from acq_ui_product_vw v connect by prior id = parent_id and lang = prior lang start with parent_id is null and lang = com_ui_user_env_pkg.get_user_lang order by s' where id = 46
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (728, 'SLMD', NULL, 'ACQ', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (729, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''MACROS_TYPES'' and a.lang = com_ui_user_env_pkg.get_user_lang', 'ACQ', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0, NULL, NULL)
/
