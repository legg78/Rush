insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5011, NULL, 'select code, name from com_ui_dictionary_vw where dict = ''ENVT'' and lang = com_ui_user_env_pkg.get_user_lang()', 'BSM', 'LVSMCODE', 'LVAPNAME', 'DTTPCHAR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5022, NULL, 'select product_number as code, product_description as name from cst_bsm_priority_prod_details', 'APP', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
