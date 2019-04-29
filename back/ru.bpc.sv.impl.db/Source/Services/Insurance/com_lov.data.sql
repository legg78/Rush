insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (229, NULL, 'select a.id code, c.label||'' - ''||a.contract_number name from prd_contract a, prd_customer b, com_ui_company_vw c where a.customer_id = b.id and b.entity_type = ''ENTTCOMP'' and b.object_id = c.id and a.contract_type = ''CNTPINSR'' and (get_sysdate >= a.start_date or a.start_date is null) and (get_sysdate <= a.end_date or a.end_date is null) and a.inst_id in (select inst_id from acm_cu_inst_vw) and c.lang = get_user_lang', 'INS', 'LVSMNAME', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (230, 'INSB', NULL, 'INS', 'LVSMCODE', 'LVAPCDNM', 'DTTPCHAR', 0)
/
