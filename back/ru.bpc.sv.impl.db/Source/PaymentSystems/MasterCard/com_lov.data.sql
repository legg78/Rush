insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (262, 'MCKT', null, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (326, 'MCMM', NULL, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (332, 'IP00', NULL, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (337, NULL, 'select substr(code, -1) code, name from com_ui_dictionary_vw where dict = ''CLRM'' and lang = com_ui_user_env_pkg.get_user_lang', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (338, NULL, 'select code, name from com_ui_dictionary_vw where dict = ''RCLM'' and lang = com_ui_user_env_pkg.get_user_lang', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set dict = 'RCLM' where id = 338
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (344, 'RCFM', null, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (358, NULL, 'select ''BIN'' as code, ''BIN'' as name  from dual union select ''CARD TYPE'', ''CARD TYPE''  from dual union select ''PRODUCT'', ''PRODUCT''  from dual', 'RPT', 'LVSMCODE', 'LVAPCODE', 'DTTPCHAR', 0)
/

insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (360, NULL, 'select de025 as id, description name from mcw_reason_code where mti=1644 and de024 = 603', 'MCW', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (361, 'MDRD', NULL, 'MCW', 'LVSMNAME', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (362, 'MDDI', NULL, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (363, NULL, 'select de025 as code, description as name from mcw_reason_code where mti=1442 and de024 = 450', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (364, NULL, 'select de025 as code, description as name from mcw_reason_code where mti=1240 and de024 = 205', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (365, NULL, 'select de025 as code, description as name from mcw_reason_code where mti=1442 and de024 = 451', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (366, NULL, 'select de025 as code, description as name from mcw_reason_code where mti=1740 and de024 = 700', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (367, NULL, 'select de025 as code, description as name from mcw_reason_code where mti=1740 and de024 = 780', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (368, 'MFPC', NULL, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (369, NULL, 'select member_id as code, name from mcw_member_info', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (370, 'MFRT', NULL, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (371, 'MFTC', NULL, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (372, 'MSFT', NULL, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (373, 'MCCI', NULL, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (374, 'MCIE', NULL, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (375, 'MADT', NULL, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select de025 code, description name from mcw_reason_code where mti = ''1644'' and de024 = ''603''' where id = 360
/
update com_lov set dict = null, lov_query = 'select substr(code, -1) code, name from com_ui_dictionary_vw where dict = ''MDRD'' and lang = com_ui_user_env_pkg.get_user_lang' where id = 361
/
update com_lov set dict = null, lov_query = 'select substr(code, -1) code, name from com_ui_dictionary_vw where dict = ''MDDI'' and lang = com_ui_user_env_pkg.get_user_lang' where id = 362
/
update com_lov set dict = null, lov_query = 'select substr(code, -2) code, name from com_ui_dictionary_vw where dict = ''MFPC'' and lang = com_ui_user_env_pkg.get_user_lang' where id = 368
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (422, NULL, 'select distinct local_clearing_centre code, null name from mcw_clear_centre_file_type', 'MCW', 'LVSMCODE', 'LVAPCODE', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (44, null, 'select substr(code, -1) code, name from com_ui_dictionary_vw where dict = ''USCD'' and lang = com_ui_user_env_pkg.get_user_lang', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (45, 'UPIN', NULL, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
delete com_lov where id = 465
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (465, NULL, 'select id as code, name from com_ui_lov_vw where module_code in (''COM'', ''CMN'') and id <> - 1 and lang = get_user_lang()', 'CMN', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (477, 'MCQR', NULL, 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select de025 as code, description as name from mcw_reason_code where mti=''1442'' and de024 = ''450''' where id = 363
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (568, NULL, 'select de025 as code, description as name from mcw_reason_code where mti=''1442'' and de024 = ''450'' and de025 not in (''4807'', ''4812'', ''4831'', ''4841'', ''4842'', ''4846'', ''4855'', ''4859'', ''4860'')', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
update com_lov set lov_query = 'select id as code, name from com_ui_lov_vw where module_code in (''COM'', ''CMN'', ''FCL'') and id <> - 1 and lang = get_user_lang()' where id = 465
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (713, NULL, 'select member_id code, name from mcw_member_info where nvl(mcw_api_shared_data_pkg.get_country_code, country) = country', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (714, NULL, 'select ltrim(mi.member_id, ''0'') code, mi.name, pv.version_id from cmn_parameter_value pv, cmn_parameter p, mcw_member_info mi where p.id = pv.param_id and p.standard_id = 1016 and upper(p.name) = ''BUSINESS_ICA'' and pv.entity_type = ''ENTTSTVR'' and ltrim(mi.member_id, ''0'') = pv.param_value', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0, NULL)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended) values (717, NULL, 'select e.element_value || '' - '' || get_text(i_table_name => ''COM_ARRAY_ELEMENT'', i_column_name => ''LABEL'', i_object_id => e.id) as name, mcw_api_dsp_init_pkg.get_formatted_de72(i_format_id => 1319, i_claim_reason_code => e.element_value) as code from com_array a, com_array_element e where a.id = 10000113 and a.id = e.array_id', 'MCW', 'LVSMNAME', 'LVAPNMCD', 'DTTPCHAR', 0, NULL)
/
update com_lov set lov_query = 'select distinct ltrim(mi.member_id, ''0'') code, mi.name, pv.version_id from cmn_parameter_value pv, cmn_parameter p, mcw_member_info mi where p.id = pv.param_id and p.standard_id = 1016 and upper(p.name) = ''BUSINESS_ICA'' and pv.entity_type = ''ENTTSTVR'' and ltrim(mi.member_id, ''0'') = pv.param_value' where id = 714
/
update com_lov set is_editable = 1 where id = 713
/
update com_lov set is_editable = 1 where id = 714
/
update com_lov set is_editable = 1 where id = 717
/
update com_lov set lov_query = 'select distinct ltrim(mi.member_id, ''0'') code, mi.name from cmn_parameter_value pv, cmn_parameter p, mcw_member_info mi where p.id = pv.param_id and p.standard_id = 1016 and upper(p.name) = ''BUSINESS_ICA'' and pv.entity_type = ''ENTTSTVR'' and ltrim(mi.member_id, ''0'') = ltrim(pv.param_value, ''0'') and pv.version_id = (select cmn_api_standard_pkg.get_current_version(i_standard_id => 1016, i_entity_type => ''ENTTSTVR'', i_object_id => 1, i_eff_date => sysdate) from dual)' where id = 714
/
update com_lov set lov_query = 'select distinct ltrim(mi.member_id, ''0'') code,  mi.name from cmn_parameter_value pv, cmn_parameter p, mcw_member_info mi where p.id = pv.param_id and p.standard_id = 1016 and upper(p.name) = ''BUSINESS_ICA'' and pv.entity_type in (''ENTTSTVR'', ''ENTTNIFC'') and ltrim(mi.member_id, ''0'') = ltrim(nvl(pv.param_value, p.default_value), ''0'')' where id = 714
/
update com_lov set lov_query = 'select member_id code, name from (select mcw_api_shared_data_pkg.get_country_code as country, rownum as rn from dual) c, mcw_member_info i where nvl(c.country, i.country) = i.country' where id = 713
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (726, NULL, 'select d.dict || d.code as code, com_api_dictionary_pkg.get_article_text(d.dict || d.code, com_ui_user_env_pkg.get_user_lang) as name, d.dict as dict from com_dictionary d where d.code in (select a.code from com_dictionary a where a.dict = ''ABUF'')', 'MCW', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 1, 0, 1)
/
update com_lov set dict = null, lov_query = 'select d.dict || d.code as code, d.name from com_ui_dictionary_vw d where d.dict = ''USIC'' and d.module_code = ''MCW'' and d.lang = com_ui_user_env_pkg.get_user_lang()' where id = 45
/
