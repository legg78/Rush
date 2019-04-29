insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1, NULL, 'select id code, name from ost_ui_institution_vw where lang = com_ui_user_env_pkg.get_user_lang', 'OST', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (2, NULL, 'select id code, lpad(''-'',(level - 1) * 4,''-'') || name name, inst_id institution_id from ost_ui_agent_vw where lang = com_ui_user_env_pkg.get_user_lang connect by prior id = parent_id and prior lang = lang', 'OST', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (184, NULL, 'select inst_id as code, lpad(''-'',(level - 1) * 4,''-'') || name as name from (select a.inst_id, b.parent_id, b.name, c.lang from acm_cu_inst_vw a, ost_ui_institution_sys_vw b, com_language_vw c where a.inst_id = b.id and b.lang = c.lang and b.lang = com_ui_user_env_pkg.get_user_lang) connect by prior inst_id = parent_id and lang= prior lang start with parent_id is null', 'OST', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (185, NULL, 'select inst_id as code, lpad(''-'',(level - 1) * 4,''-'') || name as name from (select a.inst_id, b.parent_id, b.name, c.lang from acm_cu_inst_vw a, ost_ui_institution_vw b, com_language_vw c where a.inst_id = b.id and b.lang = c.lang and b.lang = com_ui_user_env_pkg.get_user_lang) connect by prior inst_id = parent_id and lang= prior lang start with parent_id is null', 'OST', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (194, null, 'select id code, lpad(''-'',(level - 1) * 4,''-'') || name name from ost_ui_institution_vw where lang = com_ui_user_env_pkg.get_user_lang connect by prior id = parent_id and prior lang = lang start  with parent_id is null', 'OST', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (325, 'INTP', NULL, 'OST', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
update com_lov set lov_query = 'select inst_id as code, lpad(''-'',(level - 1) * 4,''-'') || name as name from (select b.id inst_id, b.parent_id, b.name, c.lang from ost_ui_institution_sys_vw b, com_language_vw c where b.lang = c.lang and b.lang = com_ui_user_env_pkg.get_user_lang and b.id != 9999) connect by prior inst_id = parent_id and prior lang = lang order siblings by inst_id' where id = 185
/
update com_lov set lov_query = 'select id code, lpad(''-'',(level - 1) * 4,''-'') || name name, inst_id institution_id from ost_ui_agent_vw where lang = com_ui_user_env_pkg.get_user_lang connect by prior id = parent_id and prior lang = lang start with parent_id is null' where id = 2
/
update com_lov set lov_query = 'select inst_id as code, lpad(''-'',(level - 1) * 4,''-'') || name as name from (select b.id inst_id, b.parent_id, b.name, c.lang from ost_ui_institution_sys_vw b, com_language_vw c where b.lang = c.lang and b.lang = com_ui_user_env_pkg.get_user_lang and b.id != 9999) start with parent_id is null connect by prior inst_id = parent_id and prior lang = lang order siblings by inst_id' where id = 185
/
update com_lov set lov_query = 'select id code, lpad(''-'',(level - 1) * 4,''-'') || name || case when agent_number is not null then ''-'' || agent_number else null end name, inst_id institution_id from ost_ui_agent_vw where lang = com_ui_user_env_pkg.get_user_lang connect by prior id = parent_id and prior lang = lang start with parent_id is null' where id = 2
/
update com_lov set lov_query = 'select id code, lpad(''-'',(level - 1) * 4,''-'') || name || case when agent_number is not null then '' - '' || agent_number else null end name, inst_id institution_id from ost_ui_agent_vw where lang = com_ui_user_env_pkg.get_user_lang connect by prior id = parent_id and prior lang = lang start with parent_id is null' where id = 2
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (459, NULL, 'select id code, lpad(''-'', (level-1)*4, ''-'')||label name, inst_id institution_id, sys_connect_by_path(label,''\'') s, status, contract_type from ost_ui_product_vw connect by prior id = parent_id and lang = prior lang start with parent_id is null and lang = com_ui_user_env_pkg.get_user_lang order by s', 'OST', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 1)
/
update com_lov set lov_query = 'select code, name, institution_id from (select id code, lpad(''-'',(level - 1) * 4,''-'') || name || case when agent_number is not null then '' - '' || agent_number else null end name, inst_id institution_id from (select a.id, a.inst_id, a.parent_id, get_text (''ost_agent'', ''name'', a.id, b.lang) name, b.lang, a.agent_number from ost_agent a, com_language_vw b) v where lang = com_ui_user_env_pkg.get_user_lang connect by prior id = parent_id and prior lang = lang start with parent_id is null) x where code in (select agent_id from acm_cu_agent_vw)' where id = 2
/
update com_lov set lov_query = 'select code, name from (select b.inst_id as code, b.parent_id, lpad(''-'',(level - 1) * 4,''-'') || b.name as name, b.lang from(select a.id inst_id, a.parent_id, get_text (''ost_institution'', ''name'', a.id,b.lang) name, b.lang from ost_institution a, com_language_vw b) b where b.lang = com_ui_user_env_pkg.get_user_lang start with parent_id is null connect by prior inst_id = parent_id and prior lang = lang order siblings by inst_id) where code in (select inst_id from acm_cu_inst_vw)' where id = 185
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (607, NULL, 'select to_char(i.id) as code, i.name from ost_ui_institution_vw i where i.lang = com_ui_user_env_pkg.get_user_lang and floor(i.id / 1000) = 9 and i.id != 9998 union all select to_char(null) as code, to_char(null) as name from dual', 'OST', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select to_char(i.id) as code, i.name from ost_ui_institution_vw i where i.lang = com_ui_user_env_pkg.get_user_lang and floor(i.id / 1000) = 9 and i.id != 9998' where id = 607
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (626, 'AGTP', NULL, 'APP', 'LVSMNAME', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (682, NULL, 'select id code, name from ost_ui_institution_vw where id = 9998 and lang = com_ui_user_env_pkg.get_user_lang', 'OST', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (691, 'INSS', NULL, 'OST', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
update com_lov set lov_query = 'select code, name, institution_id from (select id code, lpad(''-'',(level - 1) * 4,''-'') || name || case when agent_number is not null then '' - '' || agent_number else null end name, inst_id institution_id from (select a.id, a.inst_id, a.parent_id, get_text (''ost_agent'', ''name'', a.id, b.lang) name, b.lang, a.agent_number from ost_agent a, com_language_vw b) v where lang = com_ui_user_env_pkg.get_user_lang connect by prior id = parent_id and prior lang = lang start with parent_id is null order siblings by v.name) x where code in (select agent_id from acm_cu_agent_vw)' where id = 2
/
update com_lov set lov_query = 'select code, name, inst_id from (select id code, lpad(''-'',(level - 1) * 4,''-'') || name || case when agent_number is not null then '' - '' || agent_number else null end name, inst_id from (select a.id, a.inst_id, a.parent_id, get_text (''ost_agent'', ''name'', a.id, b.lang) name, b.lang, a.agent_number from ost_agent a, com_language_vw b) v where lang = com_ui_user_env_pkg.get_user_lang connect by prior id = parent_id and prior lang = lang start with parent_id is null order siblings by v.name) x where code in (select agent_id from acm_cu_agent_vw)' where id = 2
/
update com_lov set lov_query = 'select code, name, institution_id from (select id code, lpad(''-'',(level - 1) * 4,''-'') || name || case when agent_number is not null then '' - '' || agent_number else null end name, inst_id institution_id from (select a.id, a.inst_id, a.parent_id, get_text (''ost_agent'', ''name'', a.id, b.lang) name, b.lang, a.agent_number from ost_agent a, com_language_vw b) v where lang = com_ui_user_env_pkg.get_user_lang connect by prior id = parent_id and prior lang = lang start with parent_id is null order siblings by v.name) x where code in (select agent_id from acm_cu_agent_vw)' where id = 2
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (734, 'USIC', NULL, 'OST', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL, NULL)
/
