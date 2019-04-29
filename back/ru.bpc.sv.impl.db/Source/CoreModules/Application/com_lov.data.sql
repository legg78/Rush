insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (242, 'LNGT', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (240, 'FEEM', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (114, NULL, 'select service_id code, service_label name, product_id from app_ui_product_service_vw s where s.lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (146, NULL, 'select name code, e.name name, s.appl_type from app_element e, app_structure s where s.element_id = e.id and nvl(s.is_wizard, 0) = 1', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (150, NULL, 'select distinct e.entity_type code, e.name, f.id flow_id, s.appl_type, fs.appl_status, s.element_id from app_structure s, app_element e,  app_flow f, app_flow_stage fs where e.id = s.element_id and e.name in (''ACCOUNT'',''MERCHANT'',''SERVICE'', ''TERMINAL'', ''CARD'') and f.appl_type = s.appl_type and fs.flow_id = f.id and not exists( select 1 from app_flow_filter ff where ff.stage_id = fs.id and ff.struct_id = s.id and ff.is_insertable=0)', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (142, NULL, 'select id code, label name, inst_id institution_id from acq_ui_account_scheme_vw where lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (7, 'APST', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (8, 'APTP', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (9, 'APRJ', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (23, 'ADTP', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (61, NULL, 'select id code, label name, inst_id institution_id from app_ui_flow_vw where lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (65, 'CNTT', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (67, NULL, 'select distinct d.dict || d.code code, d.name,  t.product_type from com_ui_dictionary_vw d, prd_contract_type_vw t where d.dict = ''ENTT'' and d.code in (''PERS'',''COMP'', ''AGNT'', ''UNDF'') and d.lang = com_ui_user_env_pkg.get_user_lang and t.customer_entity_type = d.dict||d.code', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (69, NULL, 'select b.id code, b.name name , b.inst_id institution_id, b.terminal_type, b.standard_id from acq_ui_terminal_templ_vw b where b.is_template = 1 and b.lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (70, 'F22D', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (71, NULL, 'select distinct a.id code, a.name, b.product_id from net_ui_card_type_vw a, iss_product_card_type_vw b where a.id = b.card_type_id and lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (72, 'SEQU', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (89, NULL, 'select id code, name from ntf_ui_channel_vw where lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (90, NULL, 'select substr(code, -1) code, name from com_ui_dictionary_vw where dict = ''NTFA'' and lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (92, NULL, 'select event_type code, com_api_dictionary_pkg.get_article_text(event_type) name from ntf_ui_scheme_event_vw', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (125, 'BOOL', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1026, NULL, 'select a.id as code,a.label as name, a.appl_type, a.inst_id institution_id, a.is_customer_exist, a.is_contract_exist, a.customer_type, a.contract_type, a.mod_id from app_ui_flow_vw a where a.lang = get_user_lang', 'APP', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (168, NULL, 'select m.id as code, m.name as name, a.attr_id as attribute, a.inst_id institution_id from rul_ui_mod_vw m, prd_ui_attribute_scale_vw a where m.scale_id = a.scale_id and m.lang = a.lang and m.lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (202, NULL, 'select id code, com_api_dictionary_pkg.get_article_text(appl_status) name, flow_id from app_flow_stage', 'APP', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (228, 'CMMD', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (235, NULL, 'select id code ,lpad(''-'' ,level - 1 ,''-'') || label name , corp_customer_id as customer_id from crp_ui_department_vw start with parent_id is null and lang = com_ui_user_env_pkg.get_user_lang connect by prior id = parent_id and prior lang = lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (258, 'STRT', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (259, 'HLTP', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set is_parametrized = 1 where id = 67
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (347, NULL, 'select id code, template_name name, product_id , flow_id from app_ui_template_vw where lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1001, NULL, 'select rownum-13 as code, ''GMT ''||to_char(rownum-13) as name from dual connect by level < 28', 'APP', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select rownum-13 as code, ''GMT ''|| case when rownum-13 >=0 then ''+'' else null end ||to_char(rownum -13) as name from dual connect by level < 28' where id = 1001
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (395, NULL, 'select distinct a.code code, a.name || '' '' || a.currency_name name, b.product_id from com_ui_currency_vw a, acc_ui_product_account_type_vw b where a.code = b.currency and a.lang = com_ui_user_env_pkg.get_user_lang union select a.code code, a.name || '' '' || a.currency_name name, b.product_id from com_ui_currency_vw a, acc_ui_product_account_type_vw b where b.currency is null and a.lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
update com_lov set is_parametrized = 1 where id in (150, 168, 1026, 69, 61, 142, 146)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (433, NULL, 'select distinct a.id as code, a.label as name from app_ui_flow_vw a, app_ui_flow_step_vw b where a.id = b.flow_id and a.lang = b.lang and a.lang = get_user_lang', 'APP', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (480, NULL, 'select distinct d.dict || d.code code, d.name from com_ui_dictionary_vw d where d.dict = ''ENTT'' and d.code in (''PERS'',''COMP'', ''AGNT'') and d.lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select m.id as code, m.name as name, a.attr_id as attribute, a.attr_id as attribute_char, a.attr_id as attribute_limit, a.attr_id as attribute_fee, a.attr_id as attribute_cycle, a.inst_id institution_id from rul_ui_mod_vw m, prd_ui_attribute_scale_vw a where m.scale_id = a.scale_id and m.lang = a.lang and m.lang = com_ui_user_env_pkg.get_user_lang' where id = 168
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1039, 'FEEB', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set is_parametrized = 1, lov_query = 'select event_type code, com_api_dictionary_pkg.get_article_text(event_type) name, s.scheme_type from ntf_ui_scheme_event_vw se, ntf_scheme s where se.scheme_id = s.id' where id = 92
/
update com_lov set is_parametrized = 1, lov_query = 'select event_type code, com_api_dictionary_pkg.get_article_text(event_type) name, s.scheme_type from ntf_ui_scheme_event_vw se, ntf_scheme s where se.scheme_id = s.id and s.scheme_type=''NTFS0020''' where id = 92
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (506, 'CSHT', NULL, 'FCL', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select service_id code, service_label name, product_id, entity_type, is_initial, min_count, max_count from app_ui_product_service_vw s where s.lang = com_ui_user_env_pkg.get_user_lang' where id = 114
/
delete from com_lov where (id = 5001 and dict = 'CSES') or (id = 5002 and dict = 'EMPR') or (id = 5003 and dict = 'REST') or (id = 5004 and dict = 'INCR') or (id = 5005 and dict = 'CHLD')
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (509, 'CSES', NULL, 'APP', 'LVSMNAME', 'LVAPNMCD', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (510, 'EMPR', NULL, 'APP', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (511, 'REST', NULL, 'APP', 'LVSMNAME', 'LVAPNMCD', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (512, 'INCR', NULL, 'APP', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (513, 'CHLD', NULL, 'APP', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (514, 'NTTP', NULL, 'APP', 'LVSMNAME', 'LVAPNMCD', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (515, NULL, 'select fs.flow_id, fs.appl_status, fs.reject_code as code, com_api_dictionary_pkg.get_article_text(i_article => fs.reject_code, i_lang => l.lang) as name from app_flow_stage fs cross join com_language_vw l where fs.reject_code is not null and l.lang = com_ui_user_env_pkg.get_user_lang()', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (519, NULL, 'select fs.appl_status as code, com_api_dictionary_pkg.get_article_text(i_article => fs.appl_status, i_lang => l.lang) as name from app_flow_stage fs cross join com_language_vw l where floor(fs.flow_id/100) = 15 and l.lang = com_ui_user_env_pkg.get_user_lang() group by fs.appl_status, l.lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set is_parametrized = 1, lov_query = 'select fs.flow_id, fs.appl_status as code, com_api_dictionary_pkg.get_article_text(i_article => fs.appl_status, i_lang => l.lang) as name from app_flow_stage fs cross join com_language_vw l where floor(fs.flow_id/100) = 15 and l.lang = com_ui_user_env_pkg.get_user_lang() group by fs.flow_id, fs.appl_status, l.lang' where id = 519
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (524, NULL, 'select a.id as code, a.label as name, a.appl_type, a.inst_id as institution_id, a.is_customer_exist, a.is_contract_exist, a.customer_type, a.contract_type, a.mod_id , case when lower(a.label) like ''%acquiring%'' then ''APTPACQ'' when lower(a.label) like ''%issuing%'' then ''APTPISS'' when lower(a.label) like ''%internal%'' then ''APTPISS'' end as appl_subtype from app_ui_flow_vw a where a.appl_type = ''APTPDSPT'' and a.lang = get_user_lang()', 'APP', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 1)
/
update com_lov set lov_query = 'select a.id as code, a.label as name, a.appl_type, a.inst_id as institution_id, a.is_customer_exist, a.is_contract_exist, a.customer_type, a.contract_type, a.mod_id , case when lower(a.label) like ''%acquiring%'' then ''APTPACQA'' when lower(a.label) like ''%issuing%'' then ''APTPISSA'' when lower(a.label) like ''%internal%'' then ''APTPISSA'' end as appl_subtype from app_ui_flow_vw a where a.appl_type = ''APTPDSPT'' and a.lang = get_user_lang()' where id = 524
/
update com_lov set lov_query = 'select a.id as code, a.label as name, a.appl_type, a.inst_id as institution_id, a.is_customer_exist, a.is_contract_exist, a.customer_type, a.contract_type, a.mod_id , case when lower(a.label) like ''%acquiring%'' then ''APTPACQA'' when lower(a.label) like ''%issuing%'' then ''APTPISSA'' when lower(a.label) like ''%internal%'' then ''APTPISSA'' else ''APTPDSPT'' end as appl_subtype from app_ui_flow_vw a where a.appl_type = ''APTPDSPT'' and a.lang = get_user_lang()' where id = 524
/
update com_lov set lov_query = 'select fs.flow_id, fs.appl_status, fs.reject_code as code, com_api_dictionary_pkg.get_article_text(i_article => fs.reject_code, i_lang => l.lang) as name from app_flow_stage fs cross join com_language_vw l where l.lang = com_ui_user_env_pkg.get_user_lang()' where id = 515
/
update com_lov set lov_query = 'select t.*, com_api_dictionary_pkg.get_article_text(i_article => t.code, i_lang => l.lang) as name from (select fs.flow_id, fs.appl_status as code from app_flow_stage fs where floor(fs.flow_id / 100) = 15 group by fs.flow_id, fs.appl_status union all select 0 as flow_id, fs.appl_status as code from app_flow_stage fs where floor(fs.flow_id / 100) = 15 group by fs.appl_status) t cross join com_language_vw l where l.lang = com_ui_user_env_pkg.get_user_lang()' where id = 519
/
update com_lov set lov_query = 'select t.*, com_api_dictionary_pkg.get_article_text(i_article => t.code, i_lang => l.lang) as name from (select fs.flow_id, fs.appl_status, fs.reject_code as code from app_flow_stage fs where floor(fs.flow_id / 100) = 15 union all select 0 flow_id, fs.appl_status, fs.reject_code as code from app_flow_stage fs where floor(fs.flow_id / 100) = 15 group by fs.appl_status, fs.reject_code union all select fs.flow_id, ''APST0000'' as appl_status, fs.reject_code as code from app_flow_stage fs where floor(fs.flow_id / 100) = 15 group by fs.flow_id, fs.reject_code union all select 0 flow_id, ''APST0000'' as appl_status, fs.reject_code as code from app_flow_stage fs where floor(fs.flow_id / 100) = 15 group by fs.reject_code) t cross join com_language_vw l where l.lang = com_ui_user_env_pkg.get_user_lang()' where id = 515
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (528, NULL, 'select t.*, com_api_dictionary_pkg.get_article_text(i_article => t.code, i_lang => l.lang) as name from (select fs.flow_id, fs.appl_status as code from app_flow_stage fs where fs.flow_id = 1501 group by fs.flow_id, fs.appl_status union all select 0 as flow_id, fs.appl_status as code from app_flow_stage fs where fs.flow_id = 1501 group by fs.appl_status) t cross join com_language_vw l where l.lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select distinct event_type code, com_api_dictionary_pkg.get_article_text(i_article => event_type) name, s.scheme_type from ntf_ui_scheme_event_vw se, ntf_scheme s where se.scheme_id = s.id and s.scheme_type = ''NTFS0010''' where id = 92
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (538, 'DFCR', NULL, 'APP', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (536, 'ACLT', NULL, 'APP', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (572, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''APRJ'' and lang = com_ui_user_env_pkg.get_user_lang and code not in (''0001'', ''0002'', ''0007'', ''0008'')', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
update com_lov set lov_query = 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''APRJ'' and lang = com_ui_user_env_pkg.get_user_lang and code not in (''0001'', ''0002'', ''0007'', ''0008'', ''0012'')' where id = 572
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (646, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''APRJ'' and lang = com_ui_user_env_pkg.get_user_lang and code not in (''0001'', ''0002'', ''0004'', ''0005'')', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (673, 'FMRI', NULL, 'ACQ', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (685, 'APRJ', NULL, 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
update com_lov set dict = null, lov_query = 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''APRJ'' and lang = com_ui_user_env_pkg.get_user_lang and dict || code in (select element_value from com_array_element where array_id = 10000102)' where id = 9
/
update com_lov set lov_query = 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''APRJ'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0003'', ''0004'', ''0005'', ''0006'', ''0009'', ''0010'', ''0011'')' where id = 572
/
update com_lov set lov_query = 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''APRJ'' and lang = com_ui_user_env_pkg.get_user_lang and code in (''0003'', ''0006'', ''0007'', ''0008'', ''0009'', ''0010'', ''0011'', ''0012'')' where id = 646
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (688, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''APRJ'' and lang = com_ui_user_env_pkg.get_user_lang and dict || code in (select element_value from com_array_element where array_id = 10000106)', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (689, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict = ''APRJ'' and lang = com_ui_user_env_pkg.get_user_lang and dict || code in (select element_value from com_array_element where array_id = 10000107)', 'CSM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (732, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''CARD'', ''ACCT'', ''OPER'') and lang = com_ui_user_env_pkg.get_user_lang', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL, NULL)
/
