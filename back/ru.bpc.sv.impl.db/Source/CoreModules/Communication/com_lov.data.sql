insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (53, 'RCMC', NULL, 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (54, 'RCIP', NULL, 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (137, 'RCV1', NULL, 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (177, NULL, 'select c.standard_key_type code, com_api_dictionary_pkg.get_article_text(i_article => c.standard_key_type, i_lang => l.lang) name, c.standard_id, s.entity_type, l.lang from cmn_key_type_vw c, sec_key_type_vw s, com_language_vw l where c.key_type = s.key_type and s.key_algorithm = ''ENKA3DES'' and l.lang = com_ui_user_env_pkg.get_user_lang', 'CMN', NULL, NULL, NULL, 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type) values (186, NULL, 'select v.standard_id, v.id code, s.label || '' '' || v.version_number name from cmn_ui_standard_vw s, cmn_ui_standard_version_vw v where s.lang = com_ui_user_env_pkg.get_user_lang and s.id = v.standard_id and s.lang = v.lang', 'CMN', 'LVSMNAME', 'LVAPNMCD', 'DTTPNMBR')
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (203, 'RIFX', NULL, 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, module_code, sort_mode, appearance, data_type, is_parametrized) values (300, 'RCVS', 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (301, 'RCEP', null, 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (406, 'CMPL', null, 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (408, 'TCPF', NULL, 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (409, 'TCPI', NULL, 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (412, 'IBKT', NULL, 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (413, 'RCIB', NULL, 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (426, NULL, 'select 0 code, ''ASCII'' name from dual union all select 1 code, ''EBCDIC'' name from dual', 'CMN', 'LVSMNAME', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (431, NULL, 'select 16 code, ''Single Length'' name from dual union all select 32 code, ''Double Length'' name from dual union all select 64 code, ''Triple Length'' name from dual', 'CMN', 'LVSMCODE', 'LVAPNMCD', 'DTTPNMBR', 0)
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032946, 'LANGENG', NULL, 'COM_LOV', 'NAME', 431, 'Key length')
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (432, NULL, 'select ''00'' code, ''4.0 version'' name from dual union all select ''01'' code, ''5.x version'' name from dual union all select ''60'' code, ''6.0 version'' name from dual', 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032947, 'LANGENG', NULL, 'COM_LOV', 'NAME', 432, 'BASE24 Software version')
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (579, NULL, 'select sv.id as code, sv.version_number || '' ['' || s.label || case when sv.description is not null then '' | '' || sv.description end || '']'' as name from cmn_ui_standard_version_vw sv join cmn_ui_standard_vw s on s.id = sv.standard_id and s.lang = sv.lang where sv.lang = com_ui_user_env_pkg.get_user_lang and s.standard_type = ''STDT0201''', 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (644, 'NBCA', NULL, 'CMN', 'LVSMCODD', 'LVAPCDNM', 'DTTPCHAR', 0, NULL)
/
