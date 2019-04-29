insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5005, NULL, 'select sf.session_id as code, sf.file_name as name from prc_session_file sf join prc_file_attribute fa on fa.id = sf.file_attr_id join prc_file f on f.id = fa.file_id and f.file_purpose = ''FLPSOUTG'' where sf.file_type like ''FLTPCL%'' order by 1 desc', 'REP', 'LVSMCODE', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5006, NULL, 'select 1 code, ''VISA'' name from dual union all select 2 code, ''MasterCard'' name from dual union all select 3 code, ''MIR'' name from dual', 'REP', 'LVSMCODE', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5007, NULL, 'select sd.sttl_day as code, to_char(sd.open_timestamp, ''DD.MM.YYYY HH24:MI:SS'') || '' - '' || to_char(sd2.open_timestamp, ''DD.MM.YYYY HH24:MI:SS'') as name from com_settlement_day sd left join com_settlement_day sd2 on to_number(sd2.sttl_day) - 1 = sd.sttl_day', 'REP', 'LVSMCODE', 'LVAPCDNM', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5010, NULL, 'select f.id as code, f.file_name as name from prc_session_file f where f.file_name like ''C2000%'' order by 1 desc', 'REP', 'LVSMCODE', 'LVAPNAME', 'DTTPNMBR', 0)
/
insert into com_lov (id, dict, lov_query, module_code, sort_mode, appearance, data_type, is_parametrized) values (-5009, NULL, 'select f.session_id as code, f.file_name as name from prc_session_file f where (f.file_name like ''ctf-%.i%'' or f.file_name like ''REB_IN_20%'' or f.file_name like ''REB_IN_NSPK%'') and f.status = ''PSFS0002'' order by 1 desc', 'REP', 'LVSMCODE', 'LVAPNAME', 'DTTPNMBR', 0)
/
update com_lov set lov_query = 'select f.session_id as code, f.file_name as name from prc_session_file f where (f.file_name like ''ctf-%.i%'' or f.file_name like ''REB_IN_20%'' or f.file_name like ''REB_IN_NSPK%'') and f.status = ''FLSTACPT'' order by 1 desc' where id = -5009
/
