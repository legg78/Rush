insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1041, NULL, 'select element_value as code, get_text (i_table_name => ''net_card_type'', i_column_name => ''name'', i_object_id => element_value) as name from com_array_element where array_id = 10000033', 'QPR', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1042, NULL, 'select element_value as code, get_text (i_table_name => ''net_card_type'', i_column_name => ''name'', i_object_id => element_value) as name from com_array_element where array_id = 10000034', 'QPR', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1043, NULL, 'select ''Debit Card'' as code, ''Debit Card'' as name from dual union select ''Credit Card'' as code, ''Credit Card'' as name from dual', 'QPR', 'LVSMCODD', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1067, NULL, 'select element_number as code, element_value as name from com_array_element where array_id = 10000036', 'QPR', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (1068, NULL, 'select element_number as code, element_value as name from com_array_element where array_id = 10000037', 'QPR', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized, is_depended, is_editable) values (744, NULL, 'select op.element_value|| ''/'' || bai.element_value as code, com_api_i18n_pkg.get_text(''COM_ARRAY_ELEMENT'', ''LABEL'', op.id, ''LANGENG'')|| ''/'' || com_api_i18n_pkg.get_text(''COM_ARRAY_ELEMENT'', ''LABEL'', bai.id, ''LANGENG'') as name from com_array_element op, com_array_element bai where op.array_id = 10000122 and bai.array_id = 10000123', 'RPT', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0, NULL, NULL)
/