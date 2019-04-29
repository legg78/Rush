insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (180, NULL, 'select minutes as code, ''UTC ''|| to_char(trunc(minutes/ 60  - 12), ''S00'')||'':''|| ltrim(to_char(mod(minutes, 60.0), ''00''))||'' ''||name as name from (select to_number(code, ''9999'')minutes, name from com_ui_dictionary_all_vw where dict = ''TMZN'' and lang = ''LANGENG'') order by 1', 'APP', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (263, 'INCF', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-1, NULL, 'select id code, name, data_type, module_code, is_parametrized from com_ui_lov_vw where id != -1 and lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (4, NULL, 'select substr(code, -1) code, name from com_ui_dictionary_vw where dict = ''BOOL'' and lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (5, 'LANG', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (10, NULL, 'select mcc code, name name from com_ui_mcc_vw where lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (17, 'JTTL', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (18, 'CMNM', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (19, 'PTTL', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (20, 'PSFX', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (21, 'GNDR', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (22, NULL, 'select a.id_type code, a.id_type_desc name, a.inst_id as institution_id, a.entity_type as customer_type from com_ui_id_type_vw a where a.lang=com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (24, NULL, 'select code, country_name name from com_ui_country_vw where lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (25, NULL, 'select code code, name || '' '' || currency_name name from com_ui_currency_vw where lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1007, 'RTTP', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1010, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict in (''AMPR'', ''FETP'', ''BLTP'') and lang = com_ui_user_env_pkg.get_user_lang', NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1011, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict in (''ACPR'') and lang = com_ui_user_env_pkg.get_user_lang', NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1012, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict in (''DTPR'') and lang = com_ui_user_env_pkg.get_user_lang', NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1013, 'MSGT', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1014, 'ACTP', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1015, 'BLTP', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1016, 'CITP', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1017, 'ENTT', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1018, 'EVNT', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1019, NULL, 'select id code, name from net_ui_network_vw where lang = com_ui_user_env_pkg.get_user_lang', NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1020, 'STTT', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (98, 'PRTY', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (110, NULL, 'select d.dict || d.code code, d.name, r.inst_id from com_ui_dictionary_vw d, com_rate_type r where d.dict = ''RTTP'' and d.lang = com_ui_user_env_pkg.get_user_lang and d.dict || d.code = r.rate_type', NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (164, NULL, 'select id code, name, lang from com_ui_array_type_vw where lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (167, NULL, 'select id code, label name, inst_id institution_id, lang from com_ui_array_vw where lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (191, NULL, 'select id code, name name, data_type from com_ui_lov_vw where is_parametrized = 0', 'com', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (192, NULL, 'select id code, name name, data_type from com_ui_lov_vw where is_parametrized = 1', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (225, 'ALDT', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (28, 'TRMT', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (264, NULL, 'select module_code code, name from com_module_vw', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (274, 'CVTP', NULL, NULL, 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov ( id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized ) values ( 292, NULL,'select id code, label name from rpt_ui_tag_vw where lang = com_ui_user_env_pkg.get_user_lang','RPT','LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov ( id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized ) Values (298, NULL, 'select id code, name name from ost_ui_institution_vw where lang = com_ui_user_env_pkg.get_user_lang', 'RPT', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov ( id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized ) Values (299, NULL, 'select id code, name name from ost_ui_agent_vw where lang = com_ui_user_env_pkg.get_user_lang', 'RPT', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1029, 'LVAP', NULL, 'COM', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (315, NULL, 'select code, name from com_ui_dictionary_vw where dict in (''BIMP'') and lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (330, NULL, 'select element_value code, label name from com_ui_array_element_vw where array_id = 16  and lang = com_ui_user_env_pkg.get_user_lang', 'ATM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select id code, name name, data_type from com_ui_lov_vw where is_parametrized = 0 and lang = com_ui_user_env_pkg.get_user_lang' where id = 191
/
update com_lov set lov_query = 'select id code, name name, data_type from com_ui_lov_vw where is_parametrized = 1 and lang = com_ui_user_env_pkg.get_user_lang' where id = 192
/
update com_lov set lov_query = 'select d.dict || d.code code, d.name, r.inst_id institution_id from com_ui_dictionary_vw d, com_rate_type r where d.dict = ''RTTP'' and d.lang = com_ui_user_env_pkg.get_user_lang and d.dict || d.code = r.rate_type', module_code = 'COM' where id = 110
/
update com_lov set data_type='DTTPCHAR' where id = 24
/
update com_lov set appearance = 'LVAPCDNM' where id = 342
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (359, NULL, 'select decode(code, ''0000'', -1, ''0001'', 1) code, name from com_ui_dictionary_vw where dict = ''DRCT'' and lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1002, NULL, 'select decode(code, ''0001'', -1, ''0002'', 0, ''0003'', 1) code, name from com_ui_dictionary_vw where dict = ''SIGN'' and lang = get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (385, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict in (''IDTP'', ''CITP'', ''CMNM'') and lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (387, 'NDFM', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (388, 'DICT', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (391, NULL, 'select * from com_ui_dictionary_vw where dict = ''DTTP'' and code <> ''CLOB'' and lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select dict || code code, name from com_ui_dictionary_vw where dict = ''DTTP'' and code <> ''CLOB'' and lang = com_ui_user_env_pkg.get_user_lang' where id = 391
/
update com_lov set is_parametrized = 1 where id = 22
/
update com_lov set is_parametrized = 1 where id = 110
/
update com_lov set lov_query = 'select id code, name || case when agent_number is not null then ''-'' || agent_number else null end name from ost_ui_agent_vw where lang = com_ui_user_env_pkg.get_user_lang' where id = 299
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1032, NULL, 'select m.id as code, m.name as name, s.scale_type as scale_type, s.inst_id as institution_id from rul_ui_mod_vw m, rul_ui_mod_scale_vw s where m.scale_id = s.id and m.lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1033, NULL, 'select a.id as code, a.label as name, a.array_type_id as array_type_id, a.inst_id as institution_id from com_ui_array_vw a where a.lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1034, 'SCTP', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1038, 'RTIM', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (104, NULL, 'select code, name, lang as language from com_ui_language_vw', 'COM', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (105, 'STDM', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select m.id as code, m.name as name, s.scale_type as scale_type, s.inst_id as institution_id from rul_ui_mod_vw m, rul_ui_mod_scale_vw s where m.scale_id = s.id and m.lang = com_ui_user_env_pkg.get_user_lang and m.lang = s.lang' where id = 1032
/
update com_lov set lov_query = 'select v.id as code, coalesce(v.label, v.name) as name, v.lang from com_ui_array_type_vw v where v.lang = com_ui_user_env_pkg.get_user_lang()' where id = 164
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (452, 'POST', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
delete com_lov where id = 453
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (453, NULL, 'select substr(code, -1) code, name from com_ui_dictionary_vw where dict = ''BWAO'' and lang = com_ui_user_env_pkg.get_user_lang order by decode(substr(code, -1), 1, 0, 0, 1, 2)', 'COM', 'LVSMCODE', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (460, NULL, 'select module_code code, name name from com_module_vw', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (463, NULL, 'select distinct d.dict || d.code code, d.name,  t.product_type from com_ui_dictionary_vw d, prd_contract_type_vw t where d.dict = ''ENTT'' and d.code in (''PERS'',''COMP'', ''UNDF'') and d.lang = com_ui_user_env_pkg.get_user_lang and t.customer_entity_type = d.dict||d.code', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
update com_lov set lov_query = 'select v.id as code, v.label as name, v.name as name_code,  v.lang from com_ui_array_type_vw v where v.lang = com_ui_user_env_pkg.get_user_lang()' where id = 164
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (479, NULL, 'select dict || code as code, name from com_ui_dictionary_vw where dict in (''IDTP'') and lang = com_ui_user_env_pkg.get_user_lang()', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1040, NULL, 'select id code, name name from acm_ui_role_vw where lang = com_ui_user_env_pkg.get_user_lang', NULL, 'LVSMCODE', 'LVAPCDNM', NULL, 0)
/
update com_lov set lov_query = 'select mcc code, coalesce(name, ''no description'') as name from com_ui_mcc_vw where lang = com_ui_user_env_pkg.get_user_lang' where id = 10
/
update com_lov set data_type = 'DTTPNMBR', module_code = 'ACM' where id = 1040
/
update com_lov set module_code = 'COM' where id = 1007
/
update com_lov set lov_query = 'select a.id_type code, a.id_type_desc name, a.inst_id as institution_id, a.entity_type as customer_type from com_ui_id_type_vw a where a.entity_type = ''ENTTPERS'' and a.lang=com_ui_user_env_pkg.get_user_lang' where id = 22
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (525, null, 'select t.table_name as code, tc.comments  as name from user_part_tables t, user_tab_comments tc, com_partition_table p where t.partitioning_type = ''RANGE'' and t.table_name = p.table_name(+) and t.table_name = tc.table_name(+) and p.table_name is null', 'COM', 'LVSMCODE', 'LVAPCODE', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (540, NULL, 'select a.id_type code, a.id_type_desc name, a.inst_id as institution_id, a.entity_type as customer_type from com_ui_id_type_vw a where lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (597, NULL, 'select a.id code, a.label name from com_ui_array_vw a, com_array_type t where a.array_type_id = t.id and t.name = ''OPERATION_TYPE'' and a.lang = get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (599, NULL, 'select sd.sttl_day as code, to_char(sd.sttl_date, nvl(set_ui_value_pkg.get_user_param_v(i_param_name => ''DATE_PATTERN''), ''dd.mm.yyyy'')) || '' [ '' || sd.inst_id || '' '' || inst.name || '' ]'' as name from com_settlement_day sd, ost_ui_institution_sys_vw inst where inst.id = sd.inst_id and inst.lang = get_user_lang', 'COM', 'LVSMCODD', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (604, 'MRST', NULL, 'COM', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (605, 'FREL', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (628, 'ASAD', NULL, 'LTY', 'LVSMNAME', 'LVAPNMCD', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (632, NULL, 'select t.id as code, get_text(''rpt_template'', ''label'', t.id) as name from rpt_template t, (select com_ui_lov_pkg.get_number_param(''I_REPORT_ID'') as report_id from dual) p where t.report_id = nvl(p.report_id, t.report_id)', 'RPT', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0, 1)
/
update com_lov set dict = null, lov_query = 'select element_number as code, element_value as name from com_array_element where array_id = 10000088', appearance = 'LVAPNAME' where id = 105
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (642, 'CLND', NULL, 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (651, NULL, 'select v.version_number code, nvl(v.description, v.version_number) name from cmn_ui_standard_version_vw v where v.standard_id = 1046 and lang = get_user_lang', 'COM', 'LVSMCODE', 'LVAPCODE', 'DTTPCHAR', 0, NULL)
/
update com_lov set lov_query = 'select a.element_value as code, i.text as name from com_array_element a, com_i18n i where a.array_id = 10000088 and a.id = i.object_id and table_name = ''COM_ARRAY_ELEMENT'' and i.column_name = ''LABEL'' and i.lang = com_ui_user_env_pkg.get_user_lang', appearance = 'LVAPCDNM' where id = 105
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (648, 'FVFT', NULL, 'SET', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (678, NULL, 'select id code, name from net_ui_network_vw where id in (1002, 1003) and lang = com_ui_user_env_pkg.get_user_lang', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (681, 'SPRT', NULL, 'COM', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (692, NULL, 'select dict || code code, name from com_ui_dictionary_vw where dict = ''ENTT'' and code in (''CARD'', ''CINS'', ''ACCT'', ''CUST'', ''TRMN'', ''MRCH'', ''CNTR'', ''OPER'') and lang = com_ui_user_env_pkg.get_user_lang', 'OPR', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (730, NULL, 'select p.id as code, i.text as name from rul_proc p, com_i18n i where i.object_id = p.id and i.table_name = ''RUL_PROC'' and i.lang = com_ui_user_env_pkg.get_user_lang', 'COM', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL, NULL)
/
update com_lov set lov_query = 'select p.id as code, i.text as name from rul_proc p, com_i18n i where i.object_id = p.id and i.table_name = ''RUL_PROC'' and p.category = ''RLCGALGP'' and i.lang = com_ui_user_env_pkg.get_user_lang' where id = 730
/
