insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (143, 'ENSI', NULL, 'EVT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (149, NULL, 'select a.event_type code, b.name, initiator, initial_status from evt_status_map a, com_ui_dictionary_vw b where b.lang = com_ui_user_env_pkg.get_user_lang and b.dict = ''EVNT'' and b.code = substr(event_type, 5)', 'EVT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (87, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict in (''EVNT'', ''CYTP'') and lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (156, NULL, 'select dict||code code, name name from com_ui_dictionary_vw where dict = ''EVNT'' and lang = com_ui_user_env_pkg.get_user_lang', 'EVT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (157, NULL, 'select dict||code code, name as name from com_ui_dictionary_vw where dict in (''MRCS'', ''CSTS'') and lang = com_ui_user_env_pkg.get_user_lang', 'EVT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (189, NULL, 'select event_type code, label name, entity_type from evt_ui_event_type_vw where lang = com_ui_user_env_pkg.get_user_lang', 'EVT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select dict||code code, name as name from com_ui_dictionary_vw where dict in (''MRCS'', ''CSTS'', ''CSTE'', ''ACST'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 157
/ 

update com_lov set is_parametrized = 1 where id in (149, 189)
/
update com_lov set lov_query = 'select dict||code code, name as name from com_ui_dictionary_vw where dict in (''MRCS'', ''CSTS'', ''CSTE'', ''ACST'', ''BLST'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 157
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (457, 'EOLS', NULL, 'EVT', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select dict||code code, name as name from com_ui_dictionary_vw where dict in (''MRCS'', ''CSTS'', ''CSTE'', ''ACST'', ''BLST'', ''OPST'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 157
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1044, NULL, 'select dict||code code, name from com_ui_dictionary_vw where dict = ''EVST'' and lang = com_ui_user_env_pkg.get_user_lang and code <> ''0002''', 'EVT', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (507, NULL, 'select pc.name code, p.name  name, p.procedure_name, c.id container_id from prc_ui_process_vw p, prc_container c, prc_ui_container_vw pc where p.is_container = 0 and p.id = c.process_id and pc.id = c.container_process_id and p.lang = pc.lang and p.lang = com_ui_user_env_pkg.get_user_lang', 'EVT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
update com_lov set appearance = 'LVAPNAME' where id = 507
/
update com_lov set lov_query = 'select c.id code, pc.name name, p.procedure_name, c.id container_id from prc_ui_process_vw p, prc_container c, prc_ui_container_vw pc where p.is_container = 0 and p.id = c.process_id and pc.id = c.container_process_id and p.lang = pc.lang and p.lang = com_ui_user_env_pkg.get_user_lang' where id = 507
/
update com_lov set lov_query = 'select dict||code code, name as name from com_ui_dictionary_vw where dict in (''MRCS'', ''CSTS'', ''CSTE'', ''ACST'', ''BLST'', ''OPST'', ''TSTS'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 157
/
update com_lov set lov_query = 'select dict||code code, name as name from com_ui_dictionary_vw where dict in (''MRCS'', ''CSTS'', ''CSTE'', ''ACST'', ''BLST'', ''OPST'', ''TSTS'', ''SGMS'', ''CRDS'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 157
/
update com_lov set lov_query = 'select dict||code code, name as name from com_ui_dictionary_vw where dict in (''MRCS'', ''CSTS'', ''CSTE'', ''ACST'', ''BLST'', ''OPST'', ''TSTS'', ''SGMS'', ''CRDS'', ''CTST'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 157
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (679, NULL, 'SELECT a.object_type code, a.label name, b.entity_type FROM prd_ui_attribute_vw a, prd_ui_service_type_vw b WHERE     a.entity_type = ''ENTTLIMT'' AND a.lang = com_ui_user_env_pkg.get_user_lang AND a.lang = b.lang AND b.product_type in (''PRDT0100'', ''PRDT0200'') AND a.service_type_id = b.id UNION ALL SELECT c.limit_type code, a.label name, b.entity_type FROM prd_ui_attribute_vw a, prd_ui_service_type_vw b, fcl_fee_type c WHERE     a.entity_type = ''ENTTFEES'' AND a.lang = com_ui_user_env_pkg.get_user_lang AND a.lang = b.lang AND b.product_type in (''PRDT0100'', ''PRDT0200'') AND a.service_type_id = b.id AND c.limit_type IS NOT NULL AND c.fee_type = a.object_type', 'ACQ', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (687, NULL, 'select distinct m.id code, m.name name ,m.lang from rul_ui_mod_vw m , rul_mod_scale_vw sc where sc.id=m.scale_id and sc.scale_type = ''SCTPEVNT'' and m.lang = nvl(com_ui_user_env_pkg.get_user_lang, ''LANGENG'')', 'COM', 'LVSMCODD', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
update com_lov set lov_query = 'select distinct c.id code, pc.name name, p.procedure_name, c.id container_id from prc_ui_process_vw p, prc_container c, prc_ui_container_vw pc where p.is_container = 0 and p.id = c.process_id and pc.id = c.container_process_id and p.lang = pc.lang and p.lang = com_ui_user_env_pkg.get_user_lang' where id = 507
/
update com_lov set lov_query = 'select distinct c.id code, case when get_text (''prc_container'', ''description'', c.id, p.lang) is null then pc.name else pc.name || '' - '' || get_text (''prc_container'', ''description'', c.id, p.lang) end name, p.procedure_name, c.id container_id from prc_ui_process_vw p, prc_container c, prc_ui_container_vw pc where p.is_container = 0 and p.id = c.process_id and pc.id = c.container_process_id and p.lang = pc.lang and p.lang = com_ui_user_env_pkg.get_user_lang' where id = 507
/
update com_lov set lov_query = 'select dict||code code, name as name from com_ui_dictionary_vw where dict in (''MRCS'', ''CSTS'', ''CSTE'', ''ACST'', ''BLST'', ''OPST'', ''TSTS'', ''SGMS'', ''CRDS'', ''CTST'', ''APST'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 157
/
update com_lov set lov_query = 'select dict||code code, name as name from com_ui_dictionary_vw where dict in (''MRCS'', ''CSTS'', ''CSTE'', ''ACST'', ''BLST'', ''OPST'', ''TSTS'', ''SGMS'', ''CRDS'', ''CTST'', ''APST'', ''TRMS'') and lang = com_ui_user_env_pkg.get_user_lang' where id = 157
/
