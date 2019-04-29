insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (297, 'MRAC', NULL, 'RPT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (296, 'STCP', NULL, 'RPT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (295, 'STCF', NULL, 'RPT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (134, 'RPTP', NULL, 'RPT', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (135, 'RPTF', NULL, 'RPT', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (136, NULL, 'select object_id code, object_name||''.''||procedure_name as name from user_procedures p where p.object_type = ''PACKAGE'' and subprogram_id > 0 and exists( select 1 from user_arguments a where a.object_id= p.object_id and a.argument_name = ''O_XML'') and exists( select 1 from user_arguments a where a.object_id= p.object_id and a.argument_name = ''I_LANG'')', 'RPT', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (251, NULL, 'select id code , label name, inst_id as institution_id from rpt_ui_tag_vw where lang = get_user_lang', 'RPT', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (252, NULL, 'select a.id as code, a.label as label, b.label as tag_label, (select count(1) from rpt_report_tag d where d.report_id =a.id and d.tag_id = b.id) in_tag from rpt_ui_report_vw a, rpt_ui_tag_vw b where a.lang = b.lang and a.lang = get_def_lang', 'RPT', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (253, NULL, 'select b.id as code ,b.label as label,a.label as report_label,(select count(1) from rpt_report_tag d where d.report_id = a.id and d.tag_id = b.id) in_report from rpt_ui_report_vw a ,rpt_ui_tag_vw b where a.lang = b.lang and a.lang = get_def_lang', 'RPT', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (265, NULL, 'select id code, label name from rpt_ui_report_vw where lang = com_ui_user_env_pkg.get_user_lang', 'RPT', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (282, NULL, 'select id code, label name from rpt_ui_report_vw where lang = get_user_lang', 'RPT', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (293, 'DCMT', NULL, 'RPT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (294, 'MIME', NULL, 'RPT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (306, 'CHMD', NULL, 'PMO', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (324, 'DCCT', NULL, 'RPT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set is_parametrized = 0 where id = 293
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1055, NULL, 'select to_number(to_char(sysdate,''yyyy''))-11+level as code, ''year'' as name from dual connect by level <= 21', 'RPT', 'LVSMCODE', 'LVAPCODE', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1056, NULL, 'select level as code, ''quarter'' as name from dual connect by level <= 4', 'RPT', 'LVSMCODE', 'LVAPCODE', 'DTTPNMBR', 0)
/
update com_lov set lov_query = 'select to_number(to_char(sysdate,''yyyy''))-21+level as code, ''year'' as name from dual connect by level <= 41' where id = 1055
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (675, NULL, 'select id code, get_text(''net_network'', ''name'', id, com_ui_user_env_pkg.get_user_lang) name from net_ui_network_vw where id = 1002 and lang = com_ui_user_env_pkg.get_user_lang', 'ACQ', 'LVSMCODE', 'LVAPNMCD', 'DTTPNMBR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (677, NULL, 'select id code, get_text(''net_network'', ''name'', id, com_ui_user_env_pkg.get_user_lang) name from net_ui_network_vw where id = 1003 and lang = com_ui_user_env_pkg.get_user_lang', 'ACQ', 'LVSMCODE', 'LVAPNMCD', 'DTTPNMBR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (738, 'DCST', NULL, 'RPT', 'LVSMCODE', 'LVAPNMCD', 'DTTPCHAR', 0, NULL, NULL)
/
