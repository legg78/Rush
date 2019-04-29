insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (285, NULL, 'select ur.user_id code, u.second_name||'' ''||u.first_name||'' ''||u.surname as name from acm_role r, acm_user_role ur, acm_ui_user_vw u where u.user_id = ur.user_id and ur.role_id = r.id and r.name in( ''VOUCHER_OPERATOR'', ''VOUCHER_SUPERVISOR'')', 'VCH', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 1)
/
update com_lov set is_parametrized = 0 where id in (285)
/